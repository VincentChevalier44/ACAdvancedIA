# HumanAI — PDR v1.0 FINAL

**CSP Lua app for Assetto Corsa — opponent AI with “human” driving (single-player only)**
Author: Vincent Chevalier (LHK Informatique) · Date: 19 October 2026 · Status: **LOCKED, ready for development**
Supersedes: `HumanAI_PDR_v0.1.md`. Document language: English (translated from the French original). Code identifiers: English. Code comments: French. Interface text: English and French (language tables `src/lang_en.lua` and `src/lang.lua`).

---

## 0. Instructions for the coding agent (read first)

1. This document is the **single source of truth**. Every numerical value in it is an **adjustable** starting value (it lives in `config.lua`, never hard-coded in the logic).
2. **No code with gaps, no `TODO`, no stubs.** Every delivered module is complete, tested and annotated. If a CSP function is unknown, it is detected (Milestone 0) and the capability is cleanly disabled: no signature is invented.
3. **Milestone 0 is mandatory before any behaviour code** (§3.3): read the CSP Lua SDK files in the user's installation (`<assettocorsa>/extension/internal/lua-sdk/`, including `ac_physics_ai.lua` and the file that defines `ac.StateCar`) and record the actual signatures in `docs/API_NOTES.md`. If these files are inaccessible, ask Vincent to provide them; do not guess.
4. **Required quality**: adversarial review at every milestone, strict linter (globals forbidden, unused variables), off-game test suite (§19), security/robustness review (§18) with fixes supplied. Nothing is “done” without these three elements.
5. **Context constraints**: work module by module, never paste a whole file back into the conversation if a diff is enough; deliver by milestones (§20).
6. When a value or behaviour is not explicitly defined here, apply the most **cautious** behaviour (do not move laterally, do not overtake, do not change settings) and record it in the debug log.

---

## 1. Goal, scope, non-goals

### 1.1 Goal
Replace the “bot on rails” behaviour of Assetto Corsa's AI with that of a driver **aware of the other cars**:
- **Track day (Nordschleife Touristenfahrten style)**: mixed traffic (slow tourists, fast ones). The AI move over to **a single predefined side** to let the faster cars through, overtake on **the opposite side**, and return to their line as soon as the way is clear. They react to the player's **headlight flashes**.
- **Qualifying**: slow AI move clearly out of the way of a flying lap, without zigzagging.
- **Race / weekend**: credible racing opponents (tactical overtaking, measured defence, no yielding except for a lapped car, clean start, respect for others).
- **Settings** (on top of Content Manager): level up to **110%**, aggression, caution, braking zone.

### 1.2 Scope
Offline single-player, **all modes with AI** (race, track day, qualifying, weekend). Compatible with Content Manager + CSP + **Pure** (Pure touches neither the physics nor the AI: no dedicated logic, checked in game).

### 1.3 Non-goals
Online multiplayer (app **inert** online) · control of the player's car · modification of the physics · network/external files · panel built into Content Manager's setup page (impossible from a Lua app; see D5).

---

## 2. Locked decisions

| # | Decision |
|---|---|
| D1 | Complete rewrite, no code taken from the “Realistic Trackday” app (MIT). It serves only as a reference to confirm CSP signatures. Mentioned in the README. |
| D2 | **Pure core**: the decision engine never reads `ac.*` or `physics.*`. It consumes snapshots (tables of numbers) and returns commands (tables). Only `snapshot.lua` and `applier.lua` touch the CSP API. Consequence: the whole engine can be tested outside the game. |
| D3 | Three profiles (Track day, Qualifying, Race) with independent settings, automatic selection by session type + manual switch. |
| D4 | **Fixed**, configurable yield side (left/right, default **right**) in Track day and Qualifying; overtaking on the **opposite** side. In Race: yielding disabled except under blue flag; overtaking side **automatic**. |
| D5 | Interface = standard CSP Lua app (app bar): main window + debug window. No integration into CM's setup page. |
| D6 | **110% level**: mode detected at Milestone 0 (`levelMode` = `native` if `setAILevel` accepts > 1 and reads it back; `grip` otherwise: native cap 100% + proportional grip bonus; `none` as a last resort = capped at 100% with a warning in the UI). |
| D7 | **Braking zone**: if Milestone 0 finds a native function, it is wired in; otherwise, **emulation** by modulating caution and safety braking (§12.4). The slider remains present in both cases. |
| D8 | Headlight flashes: detection through **player state fields** to be identified at Milestone 0 (+ built-in calibration tool). Full behaviour in §11. |
| D9 | `overrideAwareness` of `setAISplineOffset` exposed, default **false**. |
| D10 | Persistence in `ac.storage`, per profile. Per-track settings: **outside v1.0** (planned for v1.1). |
| D11 | Detection of another active AI mod (Realistic Trackday, Full Send AI, AI Whisperer, Verve…): warning in the debug window; the app does not attempt to coexist. |
| D12 | Pits and off-track cars: never driven, never taken as targets. |
| D13 | **Deterministic** randomness (persisted seed): an AI keeps the same personality from one session to the next; “Regenerate personalities” button. |
| D14 | No AI is ever moved **towards an occupied side** (universal safety rule, §7.5). |
| D15 | Safety braking through `ac.overrideCarControls`: **optional**, disabled by default until validated in game (§12.4). |
| D16 | Speed map (“pace map”) per AI to know whether it is held up (§7.6). |
| D17 | “No manoeuvring” zones: optional data file per track (§10.13), empty by default. |
| D18 | No network calls, no disk writes outside `ac.storage`, no `loadstring`/`load` of unfiltered external text. |
| D19 | **Endurance mode** = overlay (`enduranceOverlay`) that can be enabled on the Race and Track day profiles (automatic suggestion if the session exceeds 60 min). It enables: multi-class, lapped-car logic, driver changes (stints), weather adaptation, long-duration safeguards (§10.15). |
| D20 | **Multi-class**: pace classes detected automatically (clustering of free-running paces) + optional manual mapping by car identifier pattern (e.g. `lmp1`, `lmp3`, `gt3`). Slow classes yield to fast classes; fast classes overtake slow ones with reduced margins (§10.16). |
| D21 | **Lapped cars (1, 2, n laps)**: never obstructive, never defensive against a leader lapping them; right of way to the leader; a lapped car never fights a competitor on the leader's lap (§10.17). |
| D22 | Edge cases covered by the **situation catalogue** (Appendix A, 70+ cases), which also serves as the test plan. |

---

## 3. Environment and API

### 3.1 Installation (CSP Lua app)
Folder `assettocorsa/apps/lua/HumanAI/`. `manifest.ini`: `[ABOUT]` (NAME, AUTHOR, VERSION, DESCRIPTION), `[CORE]` `LAZY = NONE`, two `[WINDOW_...]` sections (main, debug) with ID, NAME, FUNCTION_MAIN, SIZE, and `[SIM_CALLBACKS]` `UPDATE = <global function>`. **Validate the exact syntax against the manifest of a Lua app that is already installed** before freezing it. Global functions prefixed `HUMANAI__` to avoid collisions.

### 3.2 API truth table

| API | Status | Use |
|---|---|---|
| `physics.setAISplineOffset(i, offset, overrideAwareness)` | Verified. Normalised offset −1 (left) … +1 (right), 0 = line. | Lateral movement |
| `physics.setAIAggression(i, 0..1)` | Verified. The launcher's 100% equals 0.95. | Aggression |
| `physics.setAICaution(i, 0..16)` | Verified. Default 1. Caution < 1 = very assertive. Front/rear avoidance. | Caution |
| `physics.setAILevel(i, v)` | Verified. Documented range 0–1; the reference app's comments say 0–2 → **to be tested** (D6). Read-back via `ac.getCar(i).aiLevel`. | Level |
| `physics.setExtraAIGrip(i, v)` | Verified, **unit not confirmed** (1.2 or 120?). | Level bonus (`grip` mode), disabled by default |
| `physics.setAIThrottleLimit`, `physics.setAITopSpeed` | Reported to have no effect on the AI (CSP 0.2.12). | Best-effort, **off the critical path** |
| `ac.overrideCarControls(i)` | Verified: final pedal = max(AI, imposed) → **can only add** throttle/brake. | Optional safety braking (D15) |
| `physics.setAIStopCounter`, `setGentleStop`, `preventAIFromRetiring` | Verified (reference app) | Not used in v1.0 except `preventAIFromRetiring` (option) |
| `ac.getCar(i)`: `position`, `look`, `side`, `speedKmh`, `splinePosition`, `lapCount`, `isInPit`/`isInPitlane`, `aabbSize`, `index`, `aiLevel`, `brake`, `gas` | Verified for most; `side` = **left** vector (to be confirmed by calibration §6.3); `brake`/`gas` to be confirmed. | Snapshots |
| `ac.getSim()`: `carsCount`, `raceSessionType`, `timeToSessionStart`, `isOnlineRace`, `isPaused`, `isReplayActive`; `ac.getTrackID()`; track length | **To be confirmed** (Milestone 0). | Session |
| Player's light state (`headlightsActive`, `lowBeams`, horn…) | **Exact names unknown** → calibration §11.3. | Headlight flashes |
| Native AI “braking zone” function | **Not found** | D7 |

Rule: **every** CSP function is called through `pcall`; it is “probe-tested” at startup (harmless call on a current value); a failure marks the capability `unavailable` and the interface greys it out, with the reason.

### 3.3 Milestone 0 — discovery (deliverable: `docs/API_NOTES.md` + “Capabilities” debug panel)
For each “to be confirmed” row of the table, record: exact name, signature, range, unit, observed behaviour. Contents of the “Capabilities” panel: list of the `physics.*` functions whose name contains `AI`, presence/absence of each capability, detected `levelMode`, grip units, candidate light fields, CSP version, session mode, track length. Automatic test of the **direction of the offset sign** and of `side` (§6.3).

---

## 4. Architecture

```
apps/lua/HumanAI/
  manifest.ini
  HumanAI.lua            -- AC glue: callbacks, windows, global safeguards
  src/util.lua           -- maths, filters, deterministic RNG, ring buffers
  src/config.lua         -- single schema: per-profile defaults, bounds, labels, validation
  src/caps.lua           -- detection/probing of CSP capabilities (pcall)
  src/snapshot.lua       -- ac.getCar(...) -> snapshots (reused tables, 0 allocations in the loop)
  src/perception.lua     -- relative geometry, neighbours, lateral occupancy, pace map
  src/persona.lua        -- deterministic per-car personalities
  src/flash.lua          -- headlight flash detection + events
  src/director.lua       -- per-AI state machine, arbitration, offset and modulator targets
  src/applier.lua        -- writes to physics.* with change filtering and pcall
  src/ui.lua             -- ImGui windows generated from the schema
  src/zones.lua          -- optional “no-maneuver” zones (data)
  src/classes.lua        -- pace classes / manual classes, race relations (lapped, leader), stints
  tracks/<trackId>.lua   -- optional data (pure tables)
  docs/API_NOTES.md, README.md, CHANGELOG.md
tests/                   -- off-game test bench (lupa) + strict linter
```

Data contracts (tables reused from one frame to the next, no `{}` created in the hot loop):
- `Snap[i]`: `idx, x, z, lx, lz (look), sx, sz (side), v (smoothed m/s), vRaw, yawRate (smoothed rad/s), spl (0..1), lap, inPit, valid, halfLen, halfWid, brake, gas, progress (lap + spl), carModel (model identifier), classId, stintId`.
- `Rel[i][n]` (neighbour n of i): `j, long, lat, gap, vrelMps, sameDir, splOK, behind (bool), side ('L'|'R'|'C')`.
- `Cmd[i]`: `offset, level, aggr, caution, brakeAssist`.

---

## 5. Execution loop (`UPDATE(dt)`)

1. **Guard**: if the app is disabled, online session, replay, pause, `dt <= 0` or `dt > 0.25` → drive nothing (if `dt > 0.25`: reset the filters). Detect a **teleport** (position jump > 40 m in one frame) → reset the state of the car concerned.
2. **1 Hz**: resolve the active profile (session type), track length, number of cars, detection of a competing AI mod.
3. **Every frame**: `snapshot` (positions, speeds, EMA smoothing, `yawRate`, `cornerFactor`).
4. **10 Hz, staggered** (car `i` processed when `(frame + i) % k == 0`, k such that each car is evaluated every 0.1 s): `perception` (neighbours, `Rel`, occupancy, guard timers).
5. **Every frame**: `flash` (reading the player's lights), `director.step(i, dt)` for each AI, modulator filters (τ 0.4 s), offset smoothing (§10.12).
6. **Every frame**: `applier` (filtered writes, §16).
7. Budget: < 0.3 ms/frame for 30 AI. No allocation in 3–6.

Cars concerned: indices `1 … carsCount−1` (the player is index 0; single-player invariant checked at Milestone 0, otherwise use the index of the car controlled by the player). Cap: 60 AI. Cars beyond that are ignored (logged once).

---

## 6. Conventions

### 6.1 Units
Metres, seconds, m/s internally; km/h only in the UI and in the speed-margin parameters (converted on input). Angles in radians.

### 6.2 Local frame (car `i`, XZ plane, Y vertical)
For another vehicle `j`: `d = pos_j − pos_i`. `long = d·look_i` (**forward positive**). `lat = d·side_i` (**left positive** if `side` = left). `gap` (bumper-to-bumper distance) `= |long| − (L_i + L_j)/2`. Length `L = aabbSize.z`, width `W = aabbSize.x`; validity bounds L ∈ [3.5, 6.5] m, W ∈ [1.5, 2.3] m, otherwise default values 4.4 and 1.85.
Offsets: **+ = right, − = left**. `ySign`: right = +1, left = −1.
Side of a car `j` as seen from `i`: `lat > 0` → 'L', `lat < 0` → 'R'.

### 6.3 Sign calibration (automatic, debug panel)
Test: two AI close together on the same line, lined up; impose +0.5 on one of them for 3 s; measure the change in `lat` relative to the other. Result → `offsetSign` (±1) and `sideSign` (±1) persisted in global `ac.storage`; applied in `snapshot` (inversion of `side`) and `applier` (inversion of the offset). “Rerun sign calibration” button.

### 6.4 Derived measurements
- `v`: EMA of `speedKmh/3.6`, τ = 0.4 s. `yawRate`: change in heading `atan2(look.x, look.z)` wrapped to ]−π, π], EMA τ = 0.3 s.
- `cornerFactor = clamp(1 − |yawRate| / cornerYawRef, 0, 1)` (cornerYawRef = 0.5 rad/s); 1 = straight, 0 = tight corner.
- `ttc = gap / closing` if `closing > 0.1 m/s`, otherwise ∞.
- `progress = lapCount + splinePosition`.

---

## 7. Perception

### 7.1 Neighbourhood
Sort the AI + player by `splinePosition` (reused array). For each AI, consider only the **8 neighbours ahead and 8 behind** in this circular order, plus always the player if within 400 m.

### 7.2 Validity of a pair (i, j)
- `sameDir`: `look_i·look_j > 0.5` (angle < 60°).
- `splOK`: spline gap consistent with the geometry: `|long − dSplineM| ≤ max(15, 0.35·|dSplineM|)` where `dSplineM` = signed spline gap in metres (with lap wrap-around). Avoids confusing two neighbouring sections of a hairpin (Nordschleife). If the track length is unknown: `splOK = true` and the maximum distance is reduced to 80 m.
- Exclude: cars in the pits, `valid == false`, slow off-track car (> 10 s at < 5 km/h outside the pits = **obstacle**, §10.8).

### 7.3 Lateral relevance
- Follower/target “in the same lane”: `|lat| ≤ 4.0 m` (yielding) / `|lat| ≤ 3.2 m` (overtaking).
- Occupant of a side: see §7.5.

### 7.4 Persistence filter
Every trigger condition must remain true for **confirmTime** seconds (per profile) before arming the reaction; it resets if it becomes false for more than 0.3 s. Avoids triggering on a speed spike or a cut line.

### 7.5 Lateral occupancy (safety rule D14)
`occupied(i, side s)` is true if there is a car `k` (same direction, outside the pits) such that:
- `side(k) = s` and `0.3 m ≤ |lat_k| ≤ 5.5 m`;
- `−Lb ≤ long_k ≤ Lf` with
  `Lf = (L_i+L_k)/2 + 6 + 0.8·max(0, v_i − v_k)` (I am catching k: widened front window) and
  `Lb = (L_i+L_k)/2 + 6 + 0.8·max(0, v_k − v_i)` (k is catching me: widened rear window).
- If `|lat_k| < 0.3 m` and `|long_k| ≤ (L_i+L_k)/2 + 2` (overlap): **both sides are occupied** (freeze).
Rules of use: (a) no offset command **moves away from the centre towards an occupied side**; (b) during a movement, if the destination side becomes occupied: **freeze** the offset; if still occupied after 0.3 s, **release** towards the previous position at `emergencyReleaseFactor` (2×) the ramp speed, without ever crossing to the opposite side; (c) a movement **towards the centre** is checked against the occupancy of the side being moved towards (the case of returning after a yield: the follower overtakes on the other side).

### 7.6 Pace map (D16)
For each AI, an array of `NB = 400` bins covering the lap (bin = `floor(spl·NB)`). When the AI is **free** (no car within 80 m ahead, DRIVE state, not in LAPSE), update `free[bin] = EMA(v, α = 0.3)` (initial value = nil). Use: `heldUp(i)` is true if `free[bin]` exists and `v_i < free[bin]·stuckPaceRatio` (0.93) for `stuckTime`. Without data (first lap): fall back on the closing-in rule (§10.2, trigger R1). Memory only (not persisted in v1.0). Size: 60 × 400 floats.

---

## 8. Personality (deterministic)

`u(i, salt) ∈ [0,1)` = mulberry32 seeded with `hash32(seed, carIndex, salt)` (LuaJIT `bit.*` operations). Traits (bounds → value = `lerp(min, max, u)`):

| Trait | Range | Effect |
|---|---|---|
| `reaction` | `reactMin … reactMax` (0.25–0.9 s) | Delay before executing a confirmed decision |
| `awareness` | `awMin … awMax` (0.6–2.0 s) | Mean “mirror check” delay (added to the reaction for unsignalled yields) |
| `patience` | 0.7 … 1.4 | Multiplies hold, `stuckTime`, tolerance before overtaking |
| `courtesy` | 0 … 1 | Effective yield margin ×`lerp(1.25, 0.75, courtesy)` (courteous = reacts to a smaller speed difference) |
| `assertiveness` | 0 … 1 | Overtaking margin ×`lerp(1.3, 0.7, assertiveness)`, defence probability (§10.5) |
| `levelFactor` | `1 ± paceSpread` | Multiplies the level |
| `aggrFactor` | `1 ± aggrSpread` | Multiplies aggression |
| `cautFactor` | `1 ± cautSpread` | Multiplies caution |
| `paceRank` | derived from `levelFactor`, normalised 0..1 | 0 = slow/tourist, 1 = fast |
| `laneBias` | `ySign·laneBiasMax·(1 − paceRank)` (Track day) | Slow cars drive slightly towards the yield side |
| `lineJitter` | amplitude `personalLineJitter` | Slow line offset (low-frequency noise) |
| `brakeMargin` | 0.9 … 1.15 | Multiplies caution in the braking phase |
| `lapse` | random scheduling | Lapses in concentration (§10.11) |
| `oblivious(event)` | Bernoulli(`flashObliviousPct`) per event | Does not notice an isolated headlight flash |

The values are recomputed only when the seed/profile changes.

---

## 9. State machine (per AI)

States: `IDLE` (pits, off track, start delay, disabled) · `DRIVE` · `YIELD_IN` · `YIELD_HOLD` · `YIELD_OUT` · `OVT_ARM` · `OVT_IN` · `OVT_HOLD` · `OVT_OUT` · `DEFEND` · `AVOID` · `CALM` (post-contact).
Modulation sub-states (do not affect the FSM): `FOLLOW`, `START`, `LAPSE`.

### 9.1 Priorities (arbitration when several conditions are true)
`CALM` > `AVOID` > `YIELD_*` (blue flag, headlight flash, catching up, pressure) > `DEFEND` > `OVT_*` > `DRIVE`.
A yield triggered during `OVT_IN/ARM` interrupts the overtake; during `OVT_HOLD` in the **side-by-side** position, the yield waits for the end of the overtake and `OVT_OUT` goes **directly** to the yield side (without passing back through the centre).

### 9.2 Transition table

| From | To | Guard | Entry action |
|---|---|---|---|
| any | `IDLE` | pits, `valid=false`, `startDelay` active, app disabled, car off track > 3 s | offset → 0 (ramp), modulators → base (race start: `START` modulators, §10.6) |
| `IDLE` | `DRIVE` | IDLE conditions lifted | timers reset |
| `DRIVE` | `YIELD_IN` | yield guard (§10.1) true, confirmed, reaction elapsed, side clear, corner OK, outside cooldown | yield offset target |
| `DRIVE` | `OVT_ARM` | overtakeable target being followed (§10.2) but pull-out conditions not yet met | approach modulator |
| `DRIVE` | `OVT_IN` | overtake guard (§10.2) true, corridor clear | overtake offset target |
| `DRIVE` | `DEFEND` | defence guard (§10.5) | defence offset target |
| `DRIVE` | `AVOID` | obstacle (§10.8) | avoidance offset target |
| `YIELD_IN` | `YIELD_HOLD` | `|offset − target| < 0.03` | — |
| `YIELD_HOLD` | `YIELD_OUT` | all triggering followers have **passed** (§10.1.4) + post-pass wait elapsed, or followers lost, or max hold 25 s | offset target = base |
| `YIELD_OUT` | `DRIVE` | `|offset − base| < 0.03` | — |
| `YIELD_OUT` | `YIELD_IN` | new yield guard | — (no return to the centre) |
| `OVT_ARM` | `OVT_IN` | pull-out distance reached (§10.2) | — |
| `OVT_ARM` | `DRIVE` | target lost/passed >3 s | — |
| `OVT_IN` | `OVT_HOLD` | offset reached | — |
| `OVT_IN`/`HOLD` | `OVT_OUT` | all targets passed + margin, or abort (§10.2.4) | offset target = base (or yield if a request is active) |
| `OVT_OUT` | `DRIVE` | base offset reached | overtake cooldown |
| `OVT_OUT` | `YIELD_HOLD` | yield request active (headlight flash/blue flag) | — |
| `DEFEND` | `DRIVE` | attacker alongside or behind outside the guard, or max duration 2.5 s | defence cooldown |
| `AVOID` | `DRIVE` | obstacle passed by 12 m | — |
| any | `CALM` | contact detected (§10.14) | calm modulators 4 s; previous state forgotten |
| `CALM` | `DRIVE` | 4 s elapsed | — |

Every transition respects `lateralCooldown` (1.2 s minimum between two lateral **changes of direction**) to prevent zigzagging, except `CALM`, `AVOID` and the emergency release (§7.5).

---

## 10. Detailed behaviours

Notation: `P.x` = parameter `x` of the active profile (§13). “Follower” = car behind; “target” = car ahead.

### 10.1 Yielding (letting cars through)

**10.1.1 Follower candidates.** For AI `i`, every `j` with `behind`, `sameDir`, `splOK`, `|lat_j| ≤ 4.0 m`, `gap_j ≥ 0`.
Speed advantage `sa_j = (v_j − v_i)·3.6` (km/h).
Effective margin: `m(g) = P.yieldBehindMargin · lerp(1.25, 0.75, courtesy_i) · lerp(0.5, 1.0, clamp(g/50, 0, 1))`.
Effective detection distance: `D = max(P.yieldDetectBehind, min(400, closing_mps · P.yieldHorizon))` (essential in multi-class: large speed difference).

**10.1.2 Triggers** (the first true one is enough, each subject to `confirmTime`, §7.4):
- **C1 catching up**: `gap ≤ D` ∧ `sa ≥ m(gap)` ∧ `ttc ≤ P.yieldHorizon`.
- **C2 fast car close behind**: `gap ≤ 25 m` ∧ `sa ≥ 0.5·m(gap)`.
- **C3 pressure** (if `P.pressureEnabled`): the follower stays at `gap ≤ P.pressureGap` (15 m) for `P.pressureTime` (4 s) with `|sa| ≤ 8 km/h`; counter reset if `gap > 1.5·P.pressureGap` for 1 s. A human glued to your bumper wants to get by.
- **C4 headlight flash / horn**: §11.
- **C5 blue flag** (race/qualifying): §10.17.
- **C6 higher class** (multi-class): §10.16.

**10.1.3 Execution conditions** (all required): `P.yieldEnabled` (or C4/C5/C6 active) · `v_i ≥ 20 km/h` · outside `startDelay` · outside a “no-maneuver” zone (§10.13) · `lateralCooldown` elapsed · **corner OK**: `cornerFactor ≥ P.cornerMin` (otherwise *pending intention*: keep the decision for 12 s, execute it as soon as `cornerFactor ≥ P.cornerMin`, without a new reaction delay) · yield side clear (§7.5) — otherwise wait; if the side stays occupied > 3 s and `gap < 10 m`, do nothing lateral and apply only the yield slowdown (§12). Then **reaction delay**: `reaction_i + U(0, awareness_i)` (unsignalled) or `reaction_i` alone (headlight flash). If the condition drops during the delay, cancel.

**10.1.4 Execution and “pass completed”.**
- `YIELD_IN`: target `o* = ySide · min(P.maxSideOffset, P.yieldOffset · amp)` with `amp = clamp(0.4 + 0.6·cornerFactor, 0.4, 1)` (amplitude reduced in corners); `urgency` (repeated headlight flash, blue flag): `amp ×1.1` capped by `maxSideOffset`.
- `YIELD_HOLD`: hold. The set of **triggering followers** is updated every tick. A follower `j` has **passed** when `long_j > (L_i+L_j)/2 + 3 m` (it is ahead and clear). A follower is **lost** when `gap > 1.3·D` or when `sa < 0.3·m` for 2.5 s with `gap > 15 m`.
- When all the triggering followers have passed/been lost: post-pass wait `U(P.yieldHoldAfterMin, P.yieldHoldAfterMax)·patience_i` (0.8–2.2 s), floor `P.yieldHoldMin` (1.0 s) since entering HOLD, then `YIELD_OUT`.
- **Hesitant follower**: if a follower stays at `gap < 25 m` for more than 12 s without trying to pass, add an *invitation*: extra slowdown up to `P.inviteSlowdownPct` (4 s ramp), which disappears once it passes. After `yieldMaxHold` (25 s): forced exit and `ignore[j]` for 10 s (no new yield to this follower).
- `YIELD_OUT`: return to `base` (§10.12); **the movement towards the centre is subject to the occupancy of the destination side** (the follower overtakes on the other side). If a new yield guard becomes true: go back to `YIELD_IN` without passing through the centre.

**10.1.5 Multiple followers (train).** Several followers: stay moved over until **all** have passed. A new follower arriving during the post-pass wait extends `HOLD` (re-arms `P.yieldHoldMin`).

### 10.2 Overtaking

**10.2.1 Targets and triggers** (target `k`, `long_k > 0`, `|lat_k| ≤ 3.2 m`, `sameDir`, `splOK`):
- Effective margin `ma(g) = P.overtakeAheadMargin · lerp(1.3, 0.7, assertiveness_i) · lerp(0.5, 1.0, clamp(g/40, 0, 1))`, `sa = (v_i − v_k)·3.6`.
- **R1 catching up**: `gap ≤ P.overtakeDetectAhead` ∧ `sa ≥ ma(gap)` ∧ `ttc ≤ P.overtakeHorizon`.
- **R2 held up**: `gap ≤ max(10, 1.5·v_i)` ∧ `heldUp(i)` true for `P.stuckTime·patience_i` (pace map §7.6).
- **R3 obstacle**: almost stationary target → `AVOID` state (§10.8), not `OVT`.
- **R4 class priority** (multi-class): §10.16 (reduced margin).
- **R5 lapped car ahead**: §10.17.

**10.2.2 Overtaking side.**
- Track day/Qualifying: `oSide = −ySide` (opposite to the yield side).
- Race (`P.overtakeSide = auto`): choose among the clear sides (§7.5 + corridor §10.2.3); priority 1: the side opposite to the target's lateral offset (if the target has moved over, pass on the other side); priority 2: **inside of the next corner**, estimated from the sign of the target's `yawRate` (target turning left → left inside) — only if `cornerFactor_i ≥ 0.6`; priority 3: personal preferred side `(u(i,'side') < 0.5 ? left : right)`. Once chosen, the side is **locked** until `OVT_OUT`.

**10.2.3 Clear corridor.** The `oSide` side must remain clear over the overtaking distance `dReq = clamp((gap + L_i + L_k + 2·P.overtakeClearMargin) · v_i / max(v_i − v_k, 1.5 m/s), 40, 250)`: no car `m` on the `oSide` side with `−Lb ≤ long_m ≤ dReq` and `0.3 ≤ |lat_m| ≤ 5.5`. Yield conflict: if the target is itself in `YIELD_*` towards `oSide`, wait (or change sides in a race).

**10.2.4 Execution, hold, abort, end.**
- Starting preconditions: `P.overtakeEnabled` · `v_i ≥ 30 km/h` · `sa ≥ 4 km/h` (3 in a race) · `cornerFactor ≥ 0.6` (trackday: `P.cornerMin`) · `brake_i < 0.3` unless already side by side · `overtakeRestTime` elapsed since the end of the last overtake · `lateralCooldown` · outside a no-maneuver zone · no active yield towards that side.
- **Pull-out (`OVT_ARM`)**: as long as `gap > pullOutGap = clamp(P.pullOutGapBase + P.pullOutGapPerMps · v_i, 8, 22)` (with `pullOutGapBase = 8 m`, `pullOutGapPerMps = 0.25`), the AI follows in the slipstream (§10.3). At `gap ≤ pullOutGap` ∧ straight → `OVT_IN`. (Trackday: direct pull-out when R1 is true; `OVT_ARM` is kept for racing and endurance.)
- `OVT_IN`: target `o* = oSign · min(P.maxSideOffset, P.overtakeOffset · amp)`.
- `OVT_HOLD`: hold. **Side by side** (`|long_k| ≤ (L_i+L_k)/2 + 3 m`): offset frozen (except emergency release), base aggression (no boost), no new lateral decision.
- **Abort** (before side by side only): side closed > 0.4 s; or `sa < 0` for 3 s while `gap > 5 m`; or a much faster follower appears (`sa_follower ≥ 25 km/h`, `gap < 30 m`; in a race, only if it is lapping the car or comes from a faster class) → `OVT_OUT`. After side by side: the move is completed.
- **Pass after a yield**: a car yielding to the AI, or the player clearly moved off their line on a straight (≥ 2 m, within 40 m, not overtaking themselves), triggers the overtake without a speed advantage, directly in `OVT_IN`, on the side left free, in a race too.
- **Chaining** (`P.overtakeChain`): if during `OVT_HOLD` another target `k2` satisfies R1/R2 within `P.overtakeDetectAhead` and the side is clear up to `k2` → retarget without passing back through the centre.
- **End**: all targets satisfy `long < −((L_i+L_k)/2 + P.overtakeClearMargin)` for ≥ 0.6 s → `OVT_OUT`. Before moving back across towards the side of the overtaken car, check the occupancy (§7.5); otherwise wait.
- After `OVT_OUT`: `overtakeRestTime` (2 s trackday, 1 s race) before a new overtake.

### 10.3 Following, safety distance and early braking
When a target is ahead at `gap < 60 m` in the same lane (`|lat| ≤ 3.2 m`) with no overtaking decision: `FOLLOW` sub-state.
- **Caution**: `caution = base · lerp(1.35, 1.0, clamp((gap − 5)/30, 0, 1)) · brakeMargin_i`, and ×1.1 if `ttc < 3 s`.
- **Target time gap**: trackday ≈ 1.0–1.5 s, race ≈ 0.4–0.8 s (obtained through caution; there is no direct control).
- **Slipstream** (`P.slipstreamEnabled`, race/endurance): on a straight (`cornerFactor ≥ 0.9` for 1 s) and `v_i > 150 km/h`, lower caution ×0.85 (floor 0.6) to tuck in behind, then pull out according to §10.2.4.
- **Safety braking** (optional, D15): if `gap < gMin = max(6, 0.35·v_i)` and `closing > 2 m/s`, add braking `b = clamp(closing/10, 0, 0.6)` through `ac.overrideCarControls`; released as soon as `gap > 1.3·gMin`; never in side-by-side `OVT_HOLD`; disabled if the capability is missing.
- **Progressive slowing ahead of an obstacle or a very slow car**: `caution ×P.obstacleCautionMult` from 150 m (§10.8).

### 10.4 Return to the line
The return towards `base` (§10.12) is always: (a) ramped, (b) conditional on the occupancy of the destination side, (c) delayed if `cornerFactor < 0.35` (the corner is finished first), (d) interrupted and reversed if a yield guard becomes true.

### 10.5 Defence (race/endurance, `P.defenseEnabled`)
An AI may defend with probability `pDef = 0.3 + 0.5·assertiveness_i` (drawn once per attacker and per lap). Conditions: an attacker is behind at `gap ≤ P.defenseTriggerGap` (12 m), `closing > 0`, in the same lane; the AI is **not** being lapped by it (§10.17); not in a tight corner (`cornerFactor ≥ 0.6`); `defenseCooldown` elapsed (8 s); the attacker is not already side by side (once alongside, moving back across is forbidden: **a single defensive move per straight**, no zigzagging).
Action: `DEFEND` → offset of `min(P.defenseMaxOffset, 0.35)` towards the attacker's side, max duration 2.5 s, ramped return. Modulators: aggression ×1.2, caution ×0.9. Early exit if the side is occupied.

### 10.6 Start (race)
`startDelay`: IDLE for `P.startDelay` (12 s) after the start to avoid the accordion effect, with the start modulators (`START`) from the grid onwards: caution ×`P.startCautionMult` (1.6) and aggression ×`P.startAggrMult` (0.6), at full strength during the wait (first corner included, test R01), then returning to 1 over `P.startRelax` (12 s); no lateral overtaking before the end of `START` (except for an obstacle). **Lane hold** (`P.startLaneHold`, race; deliberate exception to “no commanded movement at the start”): each AI's lateral offset from its line, read once only on the grid (if it reaches 0.5 m), shifted by 0.3 m away from a neighbour (never towards it), is commanded as is while the car is stationary; after the green light, it is held as long as a car is running alongside (1 s margin) and during braking, at most until the end of `START`, then handed back to the line by the ordinary ramp, which never goes towards an occupied side (D14). Bound: width of the side the car is on (the ordinary symmetric bound would pull it back towards the line, and so towards its inside neighbour). The metres → offset scale is not verified in game: the log records the offset read, then the offset measured on the return. Rolling/standing start: the phase is detected through `timeToSessionStart` (if missing: app start = t0). Track day: no delay.

### 10.7 Blue flag → see §10.17.

### 10.8 Obstacles, stopped and crashed cars (`AVOID`)
**Obstacle**: car (AI or player) outside the pits with `v < P.obstacleSpeedKmh` (25 km/h) for > 2 s **and** not on the starting grid, or slip angle > 35°, or car stopped on the track > 10 s. Detection at `≤ P.obstacleDetect` (150 m) ahead, same direction.
Behaviour: slowing down (level ×`(1 − P.obstacleLevelDrop)` = −25%, caution ×`P.obstacleCautionMult` = 1.5), then moving over to the side **opposite** to the obstacle's lateral offset (if the obstacle is in the centre: the widest clear side, otherwise the yield side) by `min(0.6, maxSideOffset)`, only if the side is clear over the distance; otherwise *do not move over, slow down more* (level −40%). Return to `base` when the obstacle is 12 m behind. The obstacle is **not** taken as a regular overtaking target and does not trigger any yield on its part.

### 10.9 Corners
`cornerFactor` drives: (a) the lateral amplitude (§10.1.4), (b) the ban on **initiating** a yield/overtake below the threshold, (c) the delay of the return to the line, (d) no defending in a tight corner. Movements already under way **continue**, but the target amplitude follows `amp`.

### 10.10 Trains and groups
- Several slow cars in a line: each AI applies its own rules; the chained overtake (§10.2.4) makes it possible to pass the group in one go if the corridor is clear.
- Several followers: §10.1.5.
- Two AI wanting to move over to the same side at the same time: occupancy (§7.5) blocks the second one; priority: the **slower** one keeps the yield side, the other waits.
- No AI yields to a follower that is itself in `YIELD_*` (it does not want to pass).

### 10.11 Humanisation
- **Pace drift**: `levelEff ×= 1 + paceDrift_i(t)` where `paceDrift` = sum of two sinusoids (periods 90–240 s, random phases) with a total amplitude of `P.paceDriftPct` (±2%).
- **Line jitter** (no car within 40 m): `base_i = personalLine + lineJitter · (sin(2π t/T1 + φ1) + 0.5·sin(2π t/T2 + φ2))/1.5`, T1 7–19 s, amplitude `P.personalLineJitter` (0.05 trackday; 0.02 race).
- **Lapse** (`P.lapseEnabled`): every `U(P.lapseIntervalMin, P.lapseIntervalMax)` s (60–300), a lapse in concentration lasting `U(P.lapseDurMin, P.lapseDurMax)` s (1.5–3): `levelEff ×= (1 − U(P.lapseDropMin, P.lapseDropMax))` (6–12%), 0.3 s ramp; forbidden during side-by-side `OVT_HOLD`, `DEFEND`, `YIELD_IN`.
- **Traffic heterogeneity**: `paceSpread` (§8); in trackday, the distribution reproduces slow / average / fast tourists.
- **Lane bias**: `laneBias` (§8), active only if `P.laneBiasEnabled` and no lateral decision is under way.
- **Courtesy towards the player**: if the nearest target ahead is the player at `gap < 8 m`, caution ×1.15 (race, endurance).

### 10.12 Lateral movement (offset smoothing)
`offsetCmd` follows the target `o*` as follows: (1) rate limiter `rate = P.rampSpeed · clamp(100/max(v_kmh,30), 0.6, 1.6)` in offset units/s; (2) acceleration limiter `P.rampAccel` (1.5 /s²); (3) low-pass filter τ = `P.lowPassTau` (0.25 s); (4) bound `|offset| ≤ P.maxSideOffset` and zone bounds (§10.13); (5) emergency release = `emergencyReleaseFactor`× the ramp speed, towards the previous position. The direction of movement is that of `o* − offset`; any component directed **towards an occupied side** is cancelled (§7.5).
`base_i = personalLine_i + laneBias_i + jitter_i(t)`, bounded to `±0.25`.

### 10.13 “No-maneuver” zones (D17)
Optional file `tracks/<trackId>.lua`, **pure table** (no functions):
`return { zones = { {from=0.123, to=0.131, noYield=true, noOvertake=true, maxOffset=0.4, note="..."} , ... } }`.
Loaded by a restricted loader: size ≤ 64 KB, `load` in text mode with an empty environment (`setfenv`), rejection of any field not listed, bounds validated. Effects: forbids **initiating** a yield/overtake in the zone; reduces `maxSideOffset`; manoeuvres under way are brought back to `base` at normal speed. Shipped empty in v1.0; the debug window makes it possible to **mark** a zone (start/end at the current position) and to export the text to paste.
Defaults without a file: no zones, and an implicit zone around the pit entry/exit (|spl − pitSpline| < 60 m) where yielding is limited to `maxSideOffset 0.5`.

### 10.14 Contact and incident (`CALM`)
Detection: speed drop > 25 km/h within 0.3 s with a car within 6 m, or `yawRate` > 1.2 rad/s outside a corner. Reaction: `CALM` for 4 s (aggression ×0.5, caution ×1.3, no lateral manoeuvre initiated, offset brought back to `base`). If the car remains stopped or at a slip angle > 35°: it becomes an **obstacle** for the others (§10.8) and goes to `IDLE` until it has got back to `v > 40 km/h`.

### 10.15 Endurance mode (overlay, D19)
Activation: “Endurance” checkbox per profile (Race, Track day); automatic suggestion if the session duration ≥ 60 min. Contents:
1. **Multi-class** (§10.16) and **lapped cars** (§10.17) enabled.
2. **Driver changes / stints**: `stintId` increments each time an AI leaves the pits; at each new stint, re-draw a new partial personality (`reaction`, `awareness`, `patience`, `courtesy`, `assertiveness`, `laneBias`, pace drift; the `levelFactor` varies by ±`P.stintLevelSwing` (3%) around the team's value). Stint degradation (`P.stintDegradationPct`, default 1%): `levelEff ×= 1 − degr · clamp(tStint/ 2400 s, 0, 1)` (reset in the pits).
3. **Weather/visibility** (`P.weatherAdaptation`, optional capability): if CSP wetness/rain is available, `levelEff ×= 1 − 0.10·wet` (0..1), caution ×`(1 + 0.4·wet)`, aggression ×`(1 − 0.25·wet)`, detection distance ×`(1 + 0.3·wet)`. Without the capability: ignored.
4. **Long duration**: no unbounded accumulator; session time stored in seconds with periodic wrap-around (floating-point precision); `pace map` with **decay** (fixed α, no memory growth); circular debug log (200 lines); saturating error counters; stability test over 8 simulated hours (§19).
5. **Traffic fatigue**: after 90 min without an event, *lapse* probability ×1.3 (cap ×2); reset to 1 on contact.
6. **AI pace around pit stops**: an AI in `inPit` stays `IDLE`; on leaving the pits, `IDLE` extended by 3 s and caution ×1.3 for 8 s (merging into fast traffic), immediate yield possible to arriving cars of a higher class.

### 10.16 Multi-class (D20)
**Class determination** (`classes.lua`, recomputed every 60 s, 2-cycle hysteresis):
1. *Manual (takes priority)*: table `P.classPatterns = { {pattern="lmp1", class=1}, {pattern="lmp3", class=2}, ... }` applied to `carModel` (substring, case-insensitive). Class 1 = the fastest.
2. *Automatic*: for each AI, `vFree_i` = mean of its pace map (≥ 40 bins filled); descending sort; split when the relative gap between two consecutive values > `P.classGapPct` (8%); at most 4 classes; the class of a vehicle without data = that of its unknown size/power → `unknown` (treated as a middle class). The player is classified by their measured free speed (same method) or, failing that, by pattern.
**Effects** (if `P.multiClass`):
- **C6**: an AI of a *lower* class yields to a follower of a *higher* class with `classYieldMargin` (4 km/h), extended `D` (§10.1.1), `confirmTime` ×0.7, `reaction` ×0.8. In a race: yielding on a straight only (`cornerFactor ≥ 0.7`); the side follows the clearest overtaking side (otherwise `P.yieldSide`).
- **R4**: an AI of a higher class overtakes a lower class with `ma` ×0.5, same corridor, caution ×0.9 during the approach, and does **not defend** against a higher class.
- **Same class**: normal racing rules (no yielding, defending allowed).
- An AI of a lower class fighting a car of its own class does not break off the fight for a higher class **as long as** the speed difference with the latter is < 15 km/h; beyond that, it yields as soon as the fight is safe (side clear).

### 10.17 Lapped cars and blue flag (D21)
**Race relation** (`classes.lua`) for `(j, i)` with `progress = lap + spl`:
- `lapGap = progress_j − progress_i`.
- `j` **laps** `i` (`LAPPING`): `j` physically behind at `g` metres and `lapGap + g/L_track ≥ 1 − 0.02` (the leader is one lap or more ahead in cumulative terms); applies to 1, 2, n laps (`lapsDown = floor(lapGap + g/L_track + 0.02)`).
- `SAME_LAP`: otherwise.
- `BEHIND_LAPPED`: `j` is at least one lap down on `i`.
**Rules for the lapped car `i`** (race/qualifying/endurance):
1. **Blue flag**: yields to every `j` in `LAPPING` that catches it at `gap ≤ P.blueFlagRange` (150 m; ×1.5 if `lapsDown ≥ 2` or a class difference) with `sa ≥ 3 km/h`. Priority C5, `confirmTime` 0.3 s, `reaction ×0.8`, no patience test.
2. **Side**: `P.blueFlagSide` = `auto`: the side **opposite** to the leader's lateral offset (if the leader is on the left of the lane, move over to the right), failing that `yieldSide`, failing that the clearest. Yielding **on a straight only** (`cornerFactor ≥ 0.7`); in a corner: **hold the line, lift slightly** (level −8%), stay predictable; the yield is carried out at the corner exit (pending intention 12 s).
3. **Slight slowdown** during the yield (level −8%, 0.8 s ramp) to make the overtake easier; builds back up gradually after the pass.
4. **Never defensive** against a leader in `LAPPING` (DEFEND forbidden), and **never any pressure or aggressive overtaking** towards a car on the leader's lap that is fighting ahead; a lapped car catching a group of leaders does not attempt to overtake as long as the group is fighting within 2 s (speed difference < 4 km/h): it stays behind.
5. **Does not interfere with fights**: if two leaders (`SAME_LAP`) are fighting as they approach a lapped car, the latter moves over once only and stays moved over until both have passed (post-pass wait lengthened by 1 s).
6. **No yielding to `BEHIND_LAPPED` cars** (slower in cumulative terms): never a blue flag for them.
7. **Track day**: the lap logic does not apply (no classification); only the C1–C3/C4/C6 logic remains active. Disabled if `lapCount` is unavailable.

### 10.18 Interaction with the player
- The player is a target/follower like the other AI (occupancy, yielding, overtaking), **except**: the AI never treats them as an “obstacle” as long as `v > 25 km/h`; if they are stopped outside the pits > 2 s or spinning, they become an obstacle (§10.8).
- The AI never yields to a stopped/slow player car; it passes it (R3/AVOID).
- No lateral manoeuvre towards a side where the player is (§7.5, the player is included among the neighbours).
- Player in the pits, in the garage or in replay: no reaction; on returning to the track, the states are re-evaluated with the normal `confirmTime`.

### 10.19 Pits and pit exit
Cars in `inPit`/`inPitlane`: `IDLE` (no setting changed). On exit: see §10.15 item 6; outside Endurance mode: `IDLE` extended by 2 s. An AI entering the pits during a yield/overtake: immediate abort, offset untouched (the AI follows the pit lane).

---

## 11. Headlight flashes (D8) — full specification

### 11.1 Principle
The player flashes their headlights behind an AI to ask to get past. The AI concerned **note the request** and, if the player is indeed much faster, yield quickly and cleanly. If the pace difference is small, they do not yield (like a human who cannot go any faster) but stop any defending and stand ready.

### 11.2 Detection (`flash.lua`)
Source: the player's light state read every frame (fields identified by the calibration §11.3). Events:
- **Pulse**: high beams on ≤ 1.2 s then off.
- **Burst**: ≥ 2 pulses within ≤ 1.5 s → `count`.
- **Hold**: high beams on for 0.8–4 s (treated as a burst with `count = 2`).
- The horn (`P.hornEnabled`, default false) counts as a pulse if the field is available.
Each event carries `{t, count, id}`. Debounce: 0.15 s. Deduplication: one event per 0.4 s window. Hold > 4 s: ignored (high beams left on continuously, not a flash).

### 11.3 Calibration (built-in tool, debug window)
The exact names of the light fields are not guaranteed. The tool:
1. Reads the list of candidate fields of `ac.getCar(0)` defined in `config` (`flashFieldCandidates`, by default `headlightsActive`, `lowBeams`, `hornActive` and any light field documented in the SDK read at Milestone 0).
2. “Learn” mode: for 6 s, the user flashes their headlights; the tool records the fields that change at 60 Hz and proposes the best candidate (the one that toggles in short pulses).
3. The choice is persisted. If no field toggles, the `flash` capability is marked unavailable, the UI says so, and the other yield triggers (C1–C3) remain active.

### 11.4 Who reacts?
An AI `i` is a **recipient** if: `P.flashMode ≠ never` · the player is `behind` · `sameDir` · `splOK` · `long_player` negative and `gap ∈ [0, P.flashRange]` (120 m; 200 m since Beta 1.29) · `|lat| ≤ 6.0 m` · `v_player > 30 km/h` · the AI is not in `IDLE`/`CALM`.
Ranked by increasing `gap`; **at most `P.flashMaxReactors` (3)** AI react; rank `r` (0,1,2) adds a delay of `0.5·r` s (the request propagates).
In a race (`flashMode = lapped`, default): only the cars in a `LAPPING` relation (the player is lapping them) react. In `always`: all recipient AI. In trackday/qualifying: `always`.

### 11.5 Decision
- The player must be “really faster”: `sa ≥ P.flashMinAdvantage` (12 km/h trackday, 8 qualifying, 15 race/always), **or** `gap ≤ 30 m` ∧ `sa ≥ P.flashCloseAdvantage` (5 km/h).
- *Beta 1.29, at the author's request:* the close range becomes `gap ≤ 60 m` and `P.flashCloseAdvantage` defaults to −5 km/h outside the race (6 in the race): a flash from a car stuck behind at the same speed means “let me by”. Beyond it, the player must also catch the AI within `P.yieldMaxHold − 5 s` (`gap ≤ sa/3.6 · (P.yieldMaxHold − 5)`); otherwise the AI would move over too early, time out and ignore him. The decision is re-evaluated while the request lives, so a flash refused from further back is understood once the player closes in.
- Probability of ignoring: `oblivious(i, eventId)` = true with probability `P.flashObliviousPct` (10%, trackday) for an isolated **first** pulse; a 2nd pulse within 4 s cancels the inattention (always noticed).
- If accepted: *yield request* `req = {from=player, until = t + P.flashRequestTTL (8 s), urgent = (count ≥ 3 or 2nd event)}`.
- If refused because the pace difference is too small: no yield, but **defending disabled** against this follower for the TTL, and the `confirmTime` of triggers C1/C2 halved.

### 11.6 Effects of the request
1. **Reaction**: delay `reaction_i · 0.6` (the flash catches the attention: no mirror delay), `confirmTime = 0.1 s`.
2. Relaxed thresholds: `m(g) ×0.5`, horizon ×1.5, `D = max(D, P.flashRange)`.
3. **Urgency**: amplitude ×1.1 (cap `maxSideOffset`), invitation (extra slowdown) enabled as soon as `HOLD` is entered.
4. Corner: same rule as everywhere (pending intention up to 12 s, instead of 10 s without a request).
5. Yield already under way: the `HOLD` is extended (re-arms `yieldHoldMin`), the request adds up.
6. AI overtaking: if side by side → finish, then `OVT_OUT` goes directly to the yield side; otherwise abort the overtake (priority C4 > R1).
7. End of request: `until` reached, or the player has passed, or been lost (§10.1.4) → normal behaviour.
8. The yield side is **always** that of the profile (`yieldSide`) in trackday/qualifying; in race/endurance: that of `blueFlagSide` (§10.17).

### 11.7 Special cases
- Headlight flash while the player is **alongside** (|long| < length): ignored.
- Player in the pits, in replay, stopped, or going the wrong way: ignored.
- Several AI in the line: §11.4 (propagation, 3 max).
- AI already moved over to the correct side: keeps its position (no movement).
- Yield side occupied: wait (§10.1.3); the AI signals nothing else.
- Headlight flashes made **forwards by the AI**: not simulated in v1.0 (no reliable API for AI lights).

---

## 12. Modulators (level, aggression, caution, braking, grip)

### 12.1 Native outputs
- `levelNative = clamp(levelEff, 0.30, levelCap)` with `levelCap = 1.10` if `levelMode = native`, otherwise `1.00`.
- `aggrNative = clamp(0.95 · aggrEff, 0, 0.95)`.
- `cautionNative = clamp(cautEff, 0.5, 16)`.
- `grip` mode: `gripNative = gripBase · (1 + P.gripPerLevelPct · (levelPct − 100))` (0.004 per point = +4% at 110%), only if `levelMode = grip` AND the grip unit was confirmed at Milestone 0; otherwise disabled.

### 12.2 Composition
`levelEff = P.levelPct/100 · levelFactor_i · (1 + paceDrift_i(t)) · Π mL(states)`
`aggrEff = P.aggressionPct/100 · aggrFactor_i · Π mA(states)`
`cautEff = P.caution · cautFactor_i · Π mC(states)`
The `m*` multipliers are smoothed (1st-order filter τ = 0.4 s; τ = 0.15 s for `CALM` and `AVOID`). The composition order is fixed: base → personality → FSM states → sub-states (FOLLOW, START, LAPSE) → weather → stint → clamp.

### 12.3 Per-state table (starting values)

| State / sub-state | `mL` | `mA` | `mC` |
|---|---|---|---|
| `DRIVE` | 1 | 1 | 1 |
| `FOLLOW` | 1 | 1 | formula §10.3 |
| `YIELD_IN` | `1 − P.yieldSlowdownPct` (1 s ramp) | 0.5 | 1.0 |
| `YIELD_HOLD` | `1 − P.yieldSlowdownPct − invitation` | 0.5 | 1.1 |
| `YIELD_OUT` | back to 1 over 1.5 s | back to 1 over 1.5 s | 1 |
| `OVT_ARM` | 1 | 1 | `max(0.6, 0.85)` (see slipstream) |
| `OVT_IN`, `OVT_HOLD` | 1 | `min(1.15, 0.95/aggrBase)` | `max(0.6, 0.7)` |
| `OVT_HOLD` side by side | 1 | 1 | 0.8 |
| `OVT_OUT` | back to 1 | back to 1 | back to 1 |
| `DEFEND` | 1 | 1.2 | 0.9 |
| `AVOID` | `1 − P.obstacleLevelDrop` | 0.6 | `P.obstacleCautionMult` |
| `START` | 1 | `P.startAggrMult → 1` | `P.startCautionMult → 1` |
| `LAPSE` | `1 − U(drop)` | 1 | 1 |
| `CALM` | 0.95 | 0.5 | 1.3 |
| Lapped car yielding | `1 − 0.08` | 0.5 | 1.1 |

### 12.4 Braking zone (D7) and braking distances
- If a native function is detected (Milestone 0): `brakeZoneNative = brakeZonePct/100` applied per AI, with the `brakeMargin_i` personality.
- Otherwise, **emulation**: `cautEff ×= (1 + 0.8·(brakeZonePct − 100)/100)` applied when `brake_i > 0.2` or when a target is at `gap < 80 m` under braking (`closing > 3 m/s`), with a 0.3 s ramp; and, if `useBrakeAssist`: the safety braking of §10.3 has its `gMin` threshold multiplied by `brakeZonePct/100`.
- Humanisation of braking distances: `brakeMargin_i ∈ [0.9, 1.15]`; a “late” driver (`brakeMargin < 1`) brakes later, a “cautious” one earlier.

### 12.5 Write order and caps
No value leaves the native bounds; a non-finite value (NaN, ±inf) is replaced by the last valid value and counted (§18).

---

## 13. Profiles and parameters (full schema — single source in `config.lua`)

Columns: **J** = Track day · **Q** = Qualifying · **C** = Race/weekend. All values are starting defaults, bounded and validated (§15). Units: % = percentage, m, s, km/h, ratio (0..1) unless stated otherwise.

### 13.1 General AI settings
| Key | Label | Bounds | J | Q | C |
|---|---|---|---|---|---|
| `levelPct` | Level | 40–110% | 95 | 100 | 100 |
| `aggressionPct` | Aggression | 0–100% | 55 | 45 | 80 |
| `caution` | Caution | 0.5–8 | 1.6 | 2.2 | 1.2 |
| `brakeZonePct` | Braking zone | 50–150% | 100 | 100 | 100 |
| `paceSpreadPct` | Level spread | 0–20% | 8 | 3 | 2 |
| `aggrSpreadPct` | Aggression spread | 0–30% | 12 | 8 | 10 |
| `cautSpreadPct` | Caution spread | 0–30% | 12 | 8 | 8 |

### 13.2 Yielding
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `yieldEnabled` | bool | yes | yes | no |
| `yieldSide` | left/right/auto | right | right | auto |
| `yieldOffset` | 0.2–0.95 | 0.65 | 0.80 | 0.60 |
| `yieldDetectBehind` | 30–400 m | 100 | 200 | 80 |
| `yieldBehindMargin` | 1–30 km/h | 6 | 4 | 6 |
| `yieldHorizon` | 3–30 s | 10 | 12 | 8 |
| `confirmTime` | 0.1–2 s | 0.6 | 0.4 | 0.5 |
| `yieldHoldMin` | 0.3–5 s | 1.0 | 1.0 | 1.0 |
| `yieldHoldAfterMin`/`Max` | 0.2–6 s | 0.8/2.2 | 0.6/1.6 | 0.8/1.8 |
| `yieldSlowdownPct` | 0–20% | 6 | 8 | 6 |
| `inviteSlowdownPct` | 0–25% | 10 | 10 | 10 |
| `yieldMaxHold` | 8–60 s | 25 | 25 | 25 |
| `pressureEnabled` | bool | yes | yes | no |
| `pressureGap`/`pressureTime` | 5–30 m / 1–15 s | 15/4 | 15/3 | — |

### 13.3 Blue flag, lapped cars
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `blueFlagEnabled` | bool | no | yes | yes |
| `blueFlagRange` | 50–400 m | — | 200 | 150 |
| `blueFlagSide` | auto/left/right | — | auto | auto |

### 13.4 Headlight flashes
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `flashMode` | never/lapped/always | always | always | lapped |
| `flashRange` | 40–250 m | 120 (200 since Beta 1.29) | 150 (200) | 100 (150) |
| `flashMinAdvantage` | 3–40 km/h | 12 | 8 | 15 |
| `flashCloseAdvantage` | −10–15 km/h (1–15 until Beta 1.28) | −5 (5 until Beta 1.28) | −5 (4) | 6 |
| `flashRequestTTL` | 3–20 s | 8 | 8 | 8 |
| `flashObliviousPct` | 0–40% | 10 | 5 | 10 |
| `flashMaxReactors` | 1–6 | 3 | 3 | 3 |
| `hornEnabled` | bool | no | no | no |

### 13.5 Overtaking and defending
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `overtakeEnabled` | bool | yes | yes (rare) | yes |
| `overtakeSide` | opposite/auto/left/right | opposite | opposite | auto |
| `overtakeOffset` | 0.2–0.95 | 0.70 | 0.65 | 0.60 |
| `overtakeDetectAhead` | 20–200 m | 60 | 50 | 50 |
| `overtakeAheadMargin` | 1–30 km/h | 8 | 10 | 3 |
| `overtakeHorizon` | 2–20 s | 6 | 6 | 6 |
| `overtakeClearMargin` | 8–40 m | 18 | 20 | 10 |
| `overtakeRestTime` | 0–10 s | 2.0 | 3.0 | 1.0 |
| `overtakeChain` | bool | yes | no | yes |
| `stuckTime` | 0.5–10 s | 2.0 | 3.0 | 1.2 |
| `stuckPaceRatio` | 0.8–0.99 | 0.93 | 0.93 | 0.95 |
| `pullOutGapBase`/`PerMps` | 4–15 m / 0–0.5 | 8/0.25 | 8/0.25 | 8/0.25 |
| `slipstreamEnabled` | bool | no | no | yes |
| `defenseEnabled` | bool | no | no | yes |
| `defenseMaxOffset` | 0.1–0.5 | — | — | 0.35 |
| `defenseCooldown`/`TriggerGap` | 2–30 s / 5–25 m | — | — | 8/12 |

### 13.6 Lateral movement
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `rampSpeed` | 0.1–1.0 /s | 0.30 | 0.30 | 0.45 |
| `rampAccel` | 0.5–4 /s² | 1.5 | 1.5 | 2.0 |
| `lowPassTau` | 0.05–1 s | 0.25 | 0.25 | 0.20 |
| `maxSideOffset` | 0.3–0.95 | 0.85 | 0.85 | 0.80 |
| `cornerMin` | 0–1 | 0.35 | 0.35 | 0.50 |
| `cornerYawRef` | 0.2–1.2 rad/s | 0.5 | 0.5 | 0.5 |
| `lateralCooldown` | 0.3–5 s | 1.2 | 1.2 | 1.0 |
| `emergencyReleaseFactor` | 1–4 | 2 | 2 | 2 |

### 13.7 Humanisation
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `reactMin`/`reactMax` | 0.1–2 s | 0.25/0.9 | 0.2/0.6 | 0.2/0.6 |
| `awMin`/`awMax` | 0.2–5 s | 0.6/2.0 | 0.4/1.2 | 0.4/1.2 |
| `paceDriftPct` | 0–6% | 2 | 1 | 1 |
| `personalLineJitter` | 0–0.15 | 0.05 | 0.03 | 0.02 |
| `lapseEnabled` | bool | yes | no | no (yes in endurance) |
| `lapseIntervalMin`/`Max` | 20–900 s | 60/300 | — | 120/600 |
| `lapseDurMin`/`Max` | 0.5–8 s | 1.5/3.0 | — | 1.0/2.0 |
| `lapseDropMin`/`Max` | 0–25% | 6/12 | — | 3/7 |
| `laneBiasEnabled` | bool | yes | no | no |
| `laneBiasMax` | 0–0.4 | 0.25 | — | — |

### 13.8 Start and obstacles
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `startDelay` | 0–30 s | 0 | 0 | 12 |
| `startCautionMult` | 1–3 | 1 | 1 | 1.6 |
| `startAggrMult` | 0.2–1 | 1 | 1 | 0.6 |
| `startRelax` | 2–30 s | — | — | 12 |
| `startLaneHold` | bool | no | no | yes |
| `obstacleEnabled` | bool | yes | yes | yes |
| `obstacleSpeedKmh` | 5–50 | 25 | 25 | 25 |
| `obstacleDetect` | 50–300 m | 150 | 150 | 150 |
| `obstacleLevelDrop` | 0–50% | 25 | 25 | 25 |
| `obstacleCautionMult` | 1–3 | 1.5 | 1.5 | 1.5 |

### 13.9 Endurance and multi-class (overlay)
| Key | Bounds | J | Q | C |
|---|---|---|---|---|
| `enduranceOverlay` | bool | no | no | no (suggested if session ≥ 60 min) |
| `multiClass` | bool | no | no | yes if overlay |
| `classGapPct` | 3–25% | 8 | 8 | 8 |
| `classYieldMargin` | 1–15 km/h | 4 | 4 | 4 |
| `classPatterns` | list of {pattern, class} | empty | empty | empty |
| `stintLevelSwing` | 0–8% | 3 | — | 3 |
| `stintDegradationPct` | 0–5% | 1 | — | 1 |
| `weatherAdaptation` | bool | yes | yes | yes |

### 13.10 Global settings (outside profiles)
`enabled` (yes) · `autoProfile` (yes) · `manualProfile` · `offsetSign`/`sideSign` (calibrated) · `overrideAwareness` (no) · `levelMode` (auto) · `useGripBoost` (no) · `gripPerLevelPct` (0.004) · `useBrakeAssist` (no) · `flashField` (calibrated) · `occLatMin` 0.3 / `occLatMax` 5.5 m / `occMargin` 6 m / `occSpeedGain` 0.8 s · `seed` · `language` · `debugLog`.

### 13.11 Automatic profile selection
Session type → profile: Race → C; Qualifying → Q; Practice/Track day/Hotlap → J. If the session is online: app inert. Session change during play: states and timers reset, offsets ramped towards `base`. Manual switch: the manual value prevails until the next session change if `autoProfile` is on.

---

## 14. Interface

### 14.1 “Human AI” window (main)
Status banner: `ACTIVE/INACTIVE`, current profile, capabilities (green/orange/red indicators: Level, Aggression, Caution, Offset, Headlight flashes, Braking), competing AI mod warning, Endurance mode.
Tabs/collapsible sections (one section per block of §13); each control carries a **tooltip** in French: effect, unit, default value. Controls: sliders (bounds §13), checkboxes, lists (`ui.combo`), class pattern entry (editable table). Buttons: **Restore this profile**, **Presets** (3: “Nordschleife Touristenfahrten”, “Realistic race”, “Multi-class endurance”; they only fill in the values of §13), **Panic** (offsets to 0, states to `DRIVE`, base modulators), **Regenerate personalities**.
Changes apply immediately with ramps (never a jump) and are saved with a 1 s delay.
“Braking zone” field: greyed out with an explanation if only emulation is available (D7). “Level” field: shows the detected mode (`native 110%`, `grip`, `capped at 100%`).

### 14.2 “Human AI Debug” window
Table (one row per AI): no., model, class, state, commanded offset, level/aggression/caution sent, level read back, target, gap, `sa`, reason for the last transition, active timers. Panels: **Capabilities** (§3.3), **Headlight flashes** (calibration §11.3, last event), **Sign calibration** (§6.3), **Zones** (mark start/end, export), **Log** (200 circular lines, level filters), **Performance** (ms/frame, cars processed, error counters).

### 14.3 UI requirements
No text outside the language table; no table allocation per frame; minimum width 420 px; readable in 4K; no external dependencies. Use only proven ImGui calls (`ui.text`, `ui.separator`, `ui.checkbox`, `ui.slider`, `ui.button`, `ui.sameLine`, `ui.itemHovered`/`ui.setTooltip`, `ui.combo` if present — capability probe).

---

## 15. Persistence and validation

- `ac.storage` with the prefixes `humanai:g:` (global) and `humanai:p:<profile>:` (profile). `schemaVersion` key: explicit migration (missing values → defaults, unknown keys ignored).
- **Validation on read AND on write**: type, finiteness, bounds of §13; any invalid value is replaced by the default and reported in the log. Class patterns: length ≤ 32, characters `[%w_%-]`, 8 patterns maximum.
- No trust in the storage contents (INI file that can be modified by the user or by another mod).
- Writes spaced out (≥ 1 s, batched). No writes during replay sessions.
- Per-track settings: outside v1.0 (D10).

---

## 16. Applier (writing to `physics.*`)

- Calls guarded by `pcall`; failure counter per capability; **3 consecutive failures** → capability `unavailable`, red indicator, message in the log, no further calls.
- **Change filtering**: offset if `|Δ| ≥ 0.002`; level if `|Δ| ≥ 0.005`; aggression if `|Δ| ≥ 0.01`; caution if `|Δ| ≥ 0.02`. Level/aggression/caution written at most at 5 Hz per car; offset at the loop frequency.
- **Read-back** (`aiLevel`) every 2 s on a sample of cars to check the clipping (D6) and report any drift.
- Safety: never a write to the player's index; non-finite values rejected; `overrideAwareness` according to the global setting.
- **Clean shutdown**: when the app is disabled, when the script is unloaded, on going online or on `Panic`: offsets to 0 (one write per car), then no further calls. Register an unload callback if the API offers one (capability probe).
- At script start (hot reload): **idempotent** initialisation (no residual state, no double registration).

---

## 17. Logging and telemetry

Levels: ERROR, WARN, INFO, DEBUG. Rate-limited (≤ 20 lines/s, deduplication of identical messages over 5 s). Every FSM state change is logged at DEBUG with the reason (`trigger`, `gap`, `sa`, `ttc`). Counters: transitions per state, aborted overtakes, blocked sides, emergency releases, rejected NaNs, `pcall` failures, max frame time. No file writes.

---

## 18. Security and robustness (“pentest” review of the Lua code)

### 18.1 Threat model
Local offline app; untrusted inputs: contents of `ac.storage`, `tracks/*.lua` files, car data from other mods (NaN, absurd values, duplicated indices), user actions (extreme sliders), another competing Lua app writing to the same AI.

### 18.2 Mandatory checks
1. Strict mode in development: any read/write of an **undeclared global** raises an error (test bench); in production, a single global table `HUMANAI` + callback functions `HUMANAI__*`.
2. Ban on `os.*`, `io.*`, `web.*`, `loadstring`, `dofile`, `require` of external paths. Restricted zone loader (§10.13).
3. Validation of all numerical inputs (finiteness, bounds); **division by zero** impossible (denominators bounded by `max(ε, …)`).
4. No unbounded allocation: all arrays have a maximum size (60 cars, 400 bins, 200 log lines, 64 zones).
5. Each callback is wrapped in a global `pcall`; an error in one car does not stop the others (disables the car for 5 s and resets its offset to 0; 3 consecutive errors → the car is excluded until the next session).
6. Protection against oscillation: `lateralCooldown`, cap of **6 changes of direction per minute and per car** (beyond that: the car stays in `DRIVE` for 20 s and a WARN is logged). A yield or an overtake does not start if the cap would immediately refuse its change of side.
7. No trust in time: `dt` bounded to `]0, 0.25]`.
8. Log rate limit (denial of service through logging).
9. Detection of a conflict with another AI mod (D11); in case of conflict, warning banner.

### 18.3 Adversarial scenarios to test (minimum list)
NaN/inf in a car's position/speed · `dt = 0`, negative, 10 s · teleport (return to the pits) · 0 AI, 1 AI, 60 AI, 100 AI · duplicated/missing indices · `trackLength = 0` · `splinePosition` outside [0,1] or jumping · `lapCount` negative/missing · session changing in the middle of a yield · profile switched during an overtake · corrupted storage (wrong types, huge values, unknown keys) · malformed/gigantic zone file/with functions · `physics.*` API missing or throwing · `aiLevel` read back ≠ sent · player forcing headlight flashes at 60 Hz · debug window permanently open (cost) · script unload/reload during an overtake.
Each scenario: **no unhandled error, no out-of-bounds offset, no oscillation, return to a safe state**.

---

## 19. Tests and acceptance criteria

### 19.1 Test bench (off-game, Python `lupa` + Lua 5.1/LuaJIT)
- **Strict environment** (globals forbidden) + `bit` simulated if missing.
- **Mock** `ac`/`physics`/`ui`/`ac.storage`: kinematic cars with `position`, `look`, `side`, `speedKmh`, `splinePosition`, `lapCount`, `aabbSize`, `brake`, player light flags; simulated tracks: **looped straight**, **oval** (corners), **hairpin** (spline neighbours), **narrow track**.
- **Linter**: analysis of globals + unused variables (external tool if available, otherwise an in-house check), `luac -p` equivalent through `load`.
- **Fuzz**: 10,000 steps with valid and invalid random inputs (fixed seed, reproducible).
- **Soak**: 8 simulated hours at 60 frames/s with 40 AI, memory measurement (no growth after stabilisation) and time per frame.

### 19.2 Scenarios
All the cases of **Appendix A** are automated tests with numerical assertions (states reached, offsets, no dangerous lateral crossing, reaction times within the personality interval, no oscillation > 6/min).

### 19.3 Acceptance criteria
- No red test, clean linter, 8 h soak with no leak or drift.
- Mean cost < 0.3 ms/frame and peak < 1.0 ms with 30 AI (excluding UI).
- **No** offset command towards an occupied side across all the scenarios (global assertion).
- Yielding: reaction within [`reaction`, `reaction + awareness`]; pass completed; return to the line without crossing.
- Headlight flash: AI yielding within [0.25, 1.6] s after the event if `sa ≥ threshold`; no yield if `sa` is too small; ≤ 3 reactors.
- Lapped cars: 100% of yields on straights, 0 defending, 0 fights disrupted.
- Multi-class: 0 yields to a lower class; the slow class yields within < `D`/closing.

### 19.4 In-game tests (user checklist)
1. Nordschleife, Track day, 30+ AI: yielding to the right, overtaking on the left, return to the line, no collision caused over 30 min.
2. Headlight flashes from a fast lap behind a slow AI: clean yield in < 2 s; AI with a similar pace: no yield.
3. Read-back of the level at 110% and detected mode.
4. Qualifying: player's flying lap, slow AI out of the way.
5. 20-car race: start without the accordion effect, clean overtakes, measured defence, no yielding except by lapped cars.
6. 3 h endurance, 2 classes (LMP1/LMP3), changing weather (Pure): lapped cars moving aside, slow classes yielding, no performance drift.
7. Triple 4K + Pure: no loss of smoothness attributable to the app.
8. Script reload mid-session: return to a healthy state.

---

## 20. Delivery milestones

| Milestone | Contents | Output |
|---|---|---|
| **J0** | API discovery (§3.3), `API_NOTES.md`, Capabilities panel, sign and light calibration (prototype), quantified D6/D7 decision | Report + capabilities |
| **J1** | `util`, `config` (full schema), `snapshot`, `caps`, `applier`, test bench + linter | Green tests |
| **J2** | `perception` (neighbourhood, occupancy, pace map), `persona` | Perception tests |
| **J3** | `director`: DRIVE, yielding (C1–C3), modulators, offset smoothing | T scenarios |
| **J4** | Overtaking (R1–R2, `OVT_ARM`, chaining, abort), obstacles, contact | T/O scenarios |
| **J5** | Full headlight flashes (`flash.lua`) + calibration | F scenarios |
| **J6** | Race: start, defence, blue flag, lapped cars, classes, endurance (stints, weather, soak) | R/E/M/L scenarios |
| **J7** | UI + persistence + presets + debug | UI review |
| **J8** | Full adversarial review, fuzz, pentest §18, fixes, README, `CHANGELOG`, packaging | v1.0.0 |

At each milestone: written adversarial review (defects found, fixes), tests run (log attached), update of `API_NOTES.md`.

---

## 21. Risks and open points

| Risk / point | Severity | Countermeasure / default decision |
|---|---|---|
| CSP signature/range differs between versions | High | `caps`, `pcall`, Capabilities panel |
| `setAILevel` capped at 1 | Medium | `levelMode` auto (D6) |
| No native braking zone function | Medium | Emulation (D7) |
| Unknown light fields | Medium | Calibration (§11.3); otherwise C1–C3 only |
| Speed limiters without effect | Medium | Not used as the main lever |
| Offset sign / `side` inverted | Medium | Automatic calibration (§6.3) |
| Offsets too large on narrow tracks | Medium | `maxSideOffset`, zones (§10.13) |
| Side collisions during manoeuvres | High | Occupancy (§7.5), freeze, release |
| Oscillations | Medium | Cooldown, hysteresis, 6/min cap |
| Wrong class detection in endurance | Medium | Manual patterns take priority |
| Pure compatibility | Low | In-game test (J8) |
| Conflict with another AI mod | Medium | Warning (D11) |
| CPU cost with 60 AI | Low | ±8 neighbourhood, 10 Hz staggering |

---

## 22. Sources
- CSP Lua wiki: https://github.com/ac-custom-shaders-patch/acc-lua-sdk/wiki/Lua-apps
- CSP Lua SDK: https://github.com/ac-custom-shaders-patch/acc-lua-sdk
- CSP documentation: https://docs.assetto.cn/en/ and https://cup.acstuff.club/docs/csp/
- Reference app (signatures only, MIT): https://github.com/dreasgrech/AssettoCorsaRealisticTrackday
- `setAILevel` discussion: https://www.overtake.gg/threads/is-it-possible-to-dinamically-change-ai-level-aggression-with-a-script-lua.244648/

---

## Appendix A — Situation catalogue (test cases)

| ID | Situation | Expected behaviour | § |
|---|---|---|---|
| **Track day (T)** | | | |
| T01 | Fast car approaching from behind on a straight | Yield to the `yieldSide` side after the reaction; the follower passes on the other side; return to the line | 10.1 |
| T02 | Same case in a tight corner | Pending intention; executed at the corner exit | 10.1.3 |
| T03 | Yield side occupied | No lateral movement; slight slowdown; wait | 7.5 |
| T04 | Follower does not dare to pass (12 s) | Invitation (slowdown); forced exit at 25 s; `ignore` 10 s | 10.1.4 |
| T05 | Follower glued behind without much relative speed | Pressure after 4 s → yield | 10.1.2 |
| T06 | Faster AI behind a slow AI | Overtake on the side opposite to the yield side, return to the line | 10.2 |
| T07 | Target already yielding | Overtake on the opposite side without conflict | 10.2.3 |
| T08 | Train of 4 slow cars | Chained overtake if the corridor is clear | 10.2.4 |
| T09 | Overtake with a very fast follower arriving | Before side by side: abort; otherwise finish, then yield directly | 9.1 |
| T10 | Return to the line with the overtaken car right alongside | Wait until the `clearMargin` margin; occupancy checked | 10.2.4 |
| T11 | Narrow zones / pit entry | Reduced offset, no initiation | 10.13 |
| T12 | Slow tourists (low paceRank) | Lane bias towards the yield side | 8 |
| T13 | Driver with a lapse in concentration | Brief slowdown 1.5–3 s, no manoeuvre meanwhile | 10.11 |
| T14 | Car stopped on the track | Slowdown, move over to the clear side, return | 10.8 |
| T15 | Car spinning ahead | `AVOID`, then `CALM` for the car involved | 10.8, 10.14 |
| **Headlight flashes (F)** | | | |
| F01 | Headlight flash, player +15 km/h | Yield in < 2 s | 11.5 |
| F02 | Headlight flash, player +2 km/h, gap 100 m (40 m until Beta 1.28) | No yield; defending disabled | 11.5 |
| F03 | Burst ×3 | Urgent mode, amplitude ×1.1 | 11.6 |
| F04 | 3 AI ahead in a line | 3 reactors max, delay +0.5 s per rank | 11.4 |
| F05 | First pulse ignored (inattention) | 2nd pulse → always noticed | 11.5 |
| F06 | Headlight flash in a tight corner | Executed at the exit, TTL extended | 11.6 |
| F07 | Player alongside the AI | Ignored | 11.7 |
| F08 | High beams held > 4 s | Ignored | 11.2 |
| F09 | AI overtaking side by side during the flash | Finishes, then yields directly | 11.6 |
| F10 | Light field not found | Capability unavailable, C1–C3 active | 11.3 |
| F11 | Player in a race, AI not lapped | No reaction (`lapped`) | 11.4 |
| F12 | Player in a race, AI lapped | Yield as under a blue flag | 10.17 |
| **Qualifying (Q)** | | | |
| Q01 | Flying lap behind a slow AI | Clear yield (offset 0.8, detection 200 m) | 10.1 |
| Q02 | Several slow AI over the lap | Each AI moves aside; no zigzagging | 10.10 |
| Q03 | AI on an out/in lap | Moves aside to the right | 10.1 |
| **Race (R)** | | | |
| R01 | Standing start, grid of 20 | `startDelay`, caution ↑, no lateral manoeuvre | 10.6 |
| R02 | Faster AI behind an AI on the same lap | No yield; tactical overtake | 10.2 |
| R03 | Attacker in the slipstream | Single defensive move, ≤ 0.35, no zigzagging | 10.5 |
| R04 | Attacker already side by side | No moving back across | 10.5 |
| R05 | Overtake on the inside of the corner | Inside estimated from the target's heading | 10.2.2 |
| R06 | Both sides occupied | Stay in `OVT_ARM`, no manoeuvre | 7.5 |
| R07 | Contact | `CALM` 4 s, return to `base` | 10.14 |
| R08 | Lapped car fighting another | Stays predictable, a single move over | 10.17 |
| R09 | End of race / chequered flag | No new manoeuvre (disabled if the session capability is available) | 5 |
| R10 | Session restart | Full reset | 5 |
| **Endurance (E)** | | | |
| E01 | 6 h session | No leak, no performance drift | 10.15 |
| E02 | Pit stop and rejoin | New stint, new partial personality | 10.15 |
| E03 | Pit exit ahead of a fast car | `IDLE` 3 s, immediate yield possible | 10.15 |
| E04 | Increasing rain | Level ↓, caution ↑, detection ↑ | 10.15 |
| E05 | Night / fatigue | Lapse probability ↑, capped | 10.15 |
| E06 | Traffic peak (60 AI) | Cap, no error | 5 |
| **Multi-class (M)** | | | |
| M01 | LMP1 behind LMP3 | LMP3 yields (straight), extended detection | 10.16 |
| M02 | LMP3 behind LMP1 | No yield | 10.16 |
| M03 | LMP3 fighting LMP3 | Normal fight, a single move over if an LMP1 is close | 10.16 |
| M04 | Classes wrongly detected | Manual patterns take priority | 10.16 |
| M05 | Three classes | Cascading yields according to rank | 10.16 |
| M06 | LMP1 stuck behind LMP3 in a corner | Pull-out on the straight | 10.2.4 |
| **Lapped cars (L)** | | | |
| L01 | Leader at +1 lap arrives | Blue flag, yield on a straight | 10.17 |
| L02 | Leader at +2 laps | Same, range ×1.5 | 10.17 |
| L03 | Lapped car attacked in a corner | Holds the line, lifts −8% | 10.17 |
| L04 | Lapped car wanting to defend | Defending forbidden | 10.17 |
| L05 | Lapped car catches a group of leaders | Stays behind | 10.17 |
| L06 | `lapCount` unavailable | Lapped-car logic disabled, C1–C3 only | 10.17 |
| L07 | Car laps down (BEHIND_LAPPED) catches a leader | No blue flag, the leader does not yield | 10.17 |
| **Player (P)** | | | |
| P01 | Player stopped outside the pits | Obstacle | 10.18 |
| P02 | Player in the pits | No reaction | 10.18 |
| P03 | Player alongside an AI that wants to move over | No movement towards them | 7.5 |
| P04 | Player in replay | App inactive | 5 |
| P05 | Player going the wrong way | `sameDir` false: ignored | 7.2 |
| **System (S)** | | | |
| S01 | Track without an AI spline | App inert, banner | 3 |
| S02 | Online | App inert | 1.3 |
| S03 | AI teleported | Its state is reset | 5 |
| S04 | Abnormal `dt` | No driving, filters reset | 5 |
| S05 | Script reload | Idempotent initialisation | 16 |
| S06 | Corrupted storage | Defaults + log | 15 |
| S07 | Capability failing 3× | Capability disabled, red UI | 16 |
| S08 | Another AI mod active | Warning | D11 |
| S09 | Profile changed during a manoeuvre | Ramp towards `base`, states reset | 13.11 |
| S10 | Sliders at the extremes | Values bounded, no dangerous behaviour | 15 |
| S11 | Car with aberrant dimensions | Default values | 6.2 |
| S12 | Hairpin: spline neighbours going the opposite way | `splOK` false: ignored | 7.2 |
| S13 | AI car removed/added mid-session | Arrays recomputed without error | 5 |
| S14 | App disabled | Offsets to 0, then no further calls | 16 |

---

## Appendix B — Completeness review (v1.0)

**Added after a full check**: headlight flashes and horn (calibration, anti-inattention, propagation to 3 reactors) · pressure from a follower glued behind · Endurance mode (stints, degradation, weather, long duration) · automatic and manual multi-class · lapped cars at n laps (race relation, blue flag, no interference with fights) · pull-out and slipstream · single non-zigzagging defence · start · obstacles and incidents · contact (`CALM`) · no-maneuver zones · held-up pace map · ramps with an acceleration limiter · cap on changes of direction · pits and pit exit · player interaction · hot reload · competing mod detection · storage validation · quantified test plan and 8 h soak.

**Deliberately left out (gimmicks or unreliable)**: AI flashing their headlights (no reliable API) · telemetry export · voice/sounds · per-track settings (v1.1) · driven Safety Car/yellow flags (cannot be detected reliably) · pace map persistence (v1.1) · panel built into CM.

**Backlog v1.1**: per-track settings · pace map persistence · CM panel · preloaded no-maneuver zones for the Nordschleife · AI lights/indicators if the API allows it.
