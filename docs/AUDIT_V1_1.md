# Adversarial review of 1.0.1 and 1.1.0 fixes

Complete review of the entry point and the 18 modules, signatures checked in the local CSP SDK (0.3.0-preview675). Each defect was reproduced with the real entry point and the simulated host before being fixed. Each added test fails on 1.0.1 and passes on 1.1.0. Physical in-game tests remain separate from this evidence.

## Defects fixed

| # | 1.0.1 defect | 1.1.0 fix | Evidence |
|---|---|---|---|
| 1 | **Left/right swapped.** The internal lateral basis `(-look.z, look.x)` only points left in a left-handed frame. In AC, +X is left: `DRIVEREYES.x > 0` on left-hand-drive cars. Calibration therefore gives `offsetSign = -1`, the value actually recorded on the user's installation, and “Right” sent a negative SDK offset (left). | The interface sides (yielding, overtaking, blue flag, “opposite”, line bias, width tie-break) are converted from the SDK convention (+1 = right) with the calibrated sign. Occupancy and the recorded signs do not change. | `SIDE_ORIENTATION_CALIBRATED_SIGN` (signs +1 and −1). Integration: host in a left-handed frame and host in AC's right-handed frame (`side.x = +1`), yield right = positive SDK offset in both cases. |
| 2 | **Recovery overwritten.** `host.session` was not initialised: `nextSession` replaced the recovered original level with the modified level, or abandoned recovery after a first frame on standby. | Session known before recovery; a recovered entry keeps its originals on a real session change. | “Reload” integration case, with and without saved settings: 0.900 restored instead of 0.803. |
| 3 | **Ratcheting Spacing.** The cap followed the speed under braking, then only rose again at 8 km/h/s; in corners, the reference was resampled at the cornering speed. | The cap never drops below the target. The reference is the highest uncapped straight-line speed since the last reset; there is no longer any fallback to the instantaneous speed. During an episode, the target is never below the leader's speed minus the reduction. | `TRAFFIC_CORNER_EXIT_NO_RATCHET` (real `traffic.lua`, dynamic gap, swept cycle): maximum deviation of 12.8 km/h, versus 48.8 km/h, and 0 phases out of 72 beyond 30 km/h, versus 42. `TRAFFIC_RESET_DURING_EPISODE`: pit exit at 70 km/h during an episode, without being held back; this test fails with a fallback to the instantaneous speed (34 km/h). |
| 4 | **Pit request cancelled in the pit lane.** `false` was sent before the pit box, whereas the SDK states that this value also blocks the pits. | Request kept until the compound change; lifted only outside the pit lane, except on unload. | Integration: request true in the lane, compound changed at the stop, lifted after the exit. |
| 5 | **Setup/garage menu treated as a pause.** Commands stayed frozen while the session went on. | Only `isPaused` freezes the engine; `isInMainMenu` only controls the windows. Assumption: the session goes on in the garage, as the AI laps in practice show; to be confirmed in game. Changing a setting in the garage brings ongoing manoeuvres back to their baseline. | Integration: time and frames advance in the garage, real pause frozen. |
| 6 | **110% wrongly disabled.** The read-back compared the level written in the frame with the earlier snapshot; a level between 1.000 and 1.010 was also taken as clipped. | Read-back of a level written in a previous frame and above 1.01; write tracking resynchronised at the end of the probe. | Integration: 110% kept at pit exit, real clipping still detected. |
| 7 | **Unload during pause without restoration.** | Final restoration in pause, in replay, in the pits and off track; offset subject to occupancy and never judged on replay positions. | Integration: 0.900 / 0.450 restored on unload during pause. |
| 8 | **Native rain strategy forced in the dry.** | `setAIRainTyres` written only if the native state differs from the decision, or if the app has already taken over. | Integration: no call in the dry, call once rain is confirmed. |
| 10 | **Extra braking**: `CarControlsInput` fields left at their unknown initial value; brake frozen when not commanded. | Documented neutral values (steering `math.huge`, throttle/handbrake 0, clutch 1, gear 0, MGU-H −1); immediate release when not commanded, including in the pits. | `BRAKE_NEUTRAL_AND_PIT_RELEASE`. |
| 11 | `race.ini` re-read every second. | Re-read on session change, or after a failure. | Existing suite and weekend case. |
| 12 | Restart at the same index: write caches not resynchronised. | `nextSession` on every session start reported by CSP. | Integration: level rewritten after restart, original updated. |
| 14 | Minor inconsistencies. | Obstacle threshold read from the effective values, headlight learning kept, stable player state, fixed order of the global sliders. | Full suite. |

## Qualifying and detection

- New built-in **Qualifying** preset: General, Yielding, Headlights, Overtaking, Lines, Personality, Start/obstacles and Weather. Lap-count blue flags are excluded, as they serve no purpose outside the race.
- **Profile never set up**: `configured` marker per profile, migrated to true if a section is already active. As soon as a preset has been used (`presetsUsed`, migrated from `loadedPreset`), a profile that has never been set up receives its recommended preset once only, when detection or a button activates it. A profile modified, unticked or restored by hand counts as set up and is never replaced. A first installation stays neutral.
- **Preset recognised by content** for the active profile, independently of the last load: Nordschleife in practice, Qualifying in qualifying, Realistic race in the race.
- The panel shows the detected session, its source (race.ini or CSP) and the automatic profile.

Evidence: `QUALIFICATIONS_PRESET_AND_AUTO`, `CONFIGURED_AND_PRESETS_USED_MIGRATION`, the “J/Q/C weekend” integration case (race.ini per session, presets recognised, single application, cleared profile never reapplied) and “first installation”.

## 1.1.0 measurements

- Catalogue and checks: 142/142; integration: 38 cases; linter: 19 files without errors.
- Soak: 8 simulated hours, 1,728,000 frames, 40 AI, 0 engine errors. Core with 30 AI: mean 0.174 ms, P99 0.411 ms, raw peak 0.676 ms. Mean <0.3 ms and peak <1 ms: achieved.
- Memory: total variation of 717.1 KiB, and of 5.1 KiB over the last hour. The strict 256 KiB threshold over the whole window remains open, as in 1.0.0.
- Details: [MESURES.md](MESURES.md) and `RELEASE_STATUS.json`. The bench excludes the real cost of CSP calls and of drawing the interface.

## Deliberately left unchanged

- **Residual offset in the pit lane (no. 9).** The PDR (D12) forbids any offset command in the pits, even a reset to zero. No harmful effect has been demonstrated. The change is postponed until an in-game observation: pit entry with line bias active.

## To observe in game

- Diagnostics “Offset / side sign”: −1 / −1 is expected in AC. Yield right = movement towards the driver's right.
- Rain: actual stop in the pit box and compound change.
- Spacing: no marked slowdown at corner exit or at pit exit.
- Garage during practice: the AI cars keep driving with their settings; no frozen command.
