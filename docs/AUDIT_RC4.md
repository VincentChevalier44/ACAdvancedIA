# Detailed adversarial review — AdvancedIA rc.4

19 October 2026. Scope: the 18 active Lua files, the manifest, the presets and the test benches. The archived sources are not loaded. Review carried out by reading the code, comparing it with the CSP SDK and regression tests. No branch coverage rate and no 100% physical certification is claimed.

## Result and traceability

The defects below have been fixed. The inventory [PARAMETER_AUDIT.md](PARAMETER_AUDIT.md) details the 95 profile parameters, the 11 global options and the 166 functions, with lines and consumers. Its JSON version keeps the hashes of the sources. The executed counts and measurements are in [MESURES.md](MESURES.md) and [RELEASE_STATUS.json](RELEASE_STATUS.json).

The presence of a static consumer does not, on its own, demonstrate a physical effect. The interface walk-through separately checks the choices, the bounds, the effective values and the storage. Targeted scenarios check the decisions and the commands produced. Real CSP calls and driving remain a separate level.

## Defects found and fixes

| Defect | Consequence | Fix and evidence |
|---|---|---|
| Drop-down list indices shifted | The last option, notably Automatic, was rejected; the other choices could designate their neighbour. | Direct use of the lists' Lua indices. The [official `ui.combo` code](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/blob/main/common/ac_ui.lua) returns the index of the array provided. The bench refuses a non-existent preview and selects every choice of the three profiles as well as every global mode. |
| `sectionActive and value or default` for booleans | An explicitly unticked checkbox reverted to its true default in the engine. | Explicit branch in `C.effective`. OPTIONS_FALSE_PRESERVED covers all booleans; SWITCHES_DISABLE_BEHAVIOR and WEATHER_SWITCH_PHYSICS check their effects. |
| Identifier shared by the Blue flags tab and its checkbox | Ambiguous UI controls. | Distinct `###setting_<key>` identifiers for the setting booleans and lists. Full walk-through of the real interface. |
| Automatic yielding equivalent to fixed right | The automatic choice had no logic of its own. | Preference for the side opposite to the follower's offset, right when aligned, fallback to the free side. No start if both sides are occupied. Side locked during the manoeuvre. AUTO_YIELD_FREE_SIDE covers the four occupancy cases. |
| Blue-flag side ignored in Qualifying | The ordinary yield setting imposed its side on the blue flag. | Separate choice for a real lap-based priority. BLUE_SIDE_AND_OVERTAKE_CHOICES tests Qualifying and Race. |
| Detailed log without an effective consumer | The option did not change the transitions logged. | DEBUG conditional on `runtimeG.debugLog`; WARN/ERROR remain available. DEBUG_LOG_OPTION. Option added to the custom preset capture. |
| Slipstream time kept after losing the car being followed | Several short episodes could add up. | Reset to zero without eligible following, below the speed threshold, in a corner or on deactivation. SLIPSTREAM_CONTINUOUS_TIME. |
| Probe and calibration not checking the car's identity | A temporary reference could target a car that had replaced the old one at the same index. | Identities kept for the probe, the calibrated car and its reference. Cancellation without writing to a replacement. TRANSIENT_IDENTITY_GUARDS. |
| Offset restoration considered complete if the API was unavailable | Possible loss of tracking of a remaining lateral offset. | Ownership and checkpoint kept until a successful reset to zero. FAILED_OFFSET_RESTORE_RETAINED. |
| Brake alone excluded from the ownership calculation | An optional brake command could be ignored when no other field was modified. | Allowed brake taken into account, then restored. BRAKE_ONLY_OWNERSHIP. |
| Headlight reaction range 1–6 despite an effective limit of three | Settings 4–6 with no additional effect. | Slider limited to 1–3, in line with the propagation limit. |
| Old preset with 4–6 reactions or without a detailed-log field | Risk of rejection when moving to the new settings format. | Targeted migration to the effective limit of three, and log false if the field is missing; all other fields remain subject to strict validation. CUSTOM_PRESET_VALIDATION. |
| Reset after an error using the raw global options | Disabled occupancy parameters could influence the error path. | Effective options used in this path too. |
| Value returned by the preset generator not retrieved when no buffer was provided | A call without an output table was invalid. | The generator keeps the table returned by the validation. |

## Requested values and presets

The three profiles now have **yield right**, **overtake left**, **slipstream true**, **defence true** in their prepared values. Section activation remains independent: on first start-up, all are false and no physical command is sent. Defending only runs in Race; its checkbox can be stored in the other profiles without creating any defending there.

Existing profiles and custom presets keep the saved choices. Loading a built-in preset again applies the new defaults. Activating a section does not force its sub-options again: a deliberately unticked checkbox stays unticked after the tab is disabled/re-enabled.

| Section | Nordschleife J | Realistic race C | Endurance J | Endurance C |
|---|---|---|---|---|
| General | yes | yes | yes | yes |
| Yielding | yes | no | yes | no |
| Blue flags | no | yes | no | yes |
| Headlights | yes | yes | yes | yes |
| Overtaking | yes | yes | yes | yes |
| Lines | yes | yes | yes | yes |
| Personality | yes | yes | yes | yes |
| Start / obstacles | yes | yes | yes | yes |
| Endurance | no | no | yes | yes |
| Spacing | yes | no | yes | no |
| Global options | no | no | no | no |

Endurance also enables the layer, classes and concentration lapses. From Qualifying, its button loads the Race base. The built-in presets define the profile and its values; they leave the stored global values in place but disable their section. A custom preset restores its saved global values, its checkboxes and its profile. The highlighting matches the signature of the preset's values; a modification of the loaded profile is flagged.

Custom presets also have a Delete button. Deletion is persistent and keeps the current settings; the identification of the active preset is removed if necessary. Gaps in the library can be reused without moving the other presets. The bench tests active/inactive deletion, reload, reuse, storage failure and 64-character names in a narrow panel. Long names are contained within the width and available on hover; the Delete button wraps to the next line if necessary.

## Review by module

| Module | Functions and paths reviewed | Consistency and checks |
|---|---|---|
| `AdvancedIA.lua` | Initialisation, dirty, interrupted probe, synchronisation after restoration, stop/release/session, update/protect, window callbacks. | A single `script.update`, active without a window. Idempotent reload and unsubscription. No setter online/in replay/in pause. Restoration deferred if the context forbids it. Protected error triggering panic and an attempted restoration. |
| `config.lua` | Declaration of the 95 fields, defaults, patterns, validations, presets, effective sections, global options, calibration need, automatic profile. | Types, bounds, future versions, non-finite extremes, min/max pairs. False preserved. Neutral start, separate profiles. Prepared values distinct from applied values. |
| `ui.lua` | Building of the controls, eight patterns, help, line wrapping, sliders, checkboxes, buttons, lists, loading/identification of presets, main panel and diagnostics. | Distinct identifiers, lists with correct indices, checkboxes actually wired, saving during pause, normal-height tabs. Walk-through of the parameters in J/Q/C and of the global options. |
| `snapshot.lua` | Snapshot, vectors, car, simulation, app identification, metadata, zone reading, menu context. | Validation of coordinates, heading, speed, spline, laps and dimensions; conversion of milliseconds. Non-zero player protected, remote cars and cars without physics excluded. Invalid data inert. |
| `applier.lua` | Callable API, clock, setters, storage, presets and deletion, menus, native references, saving, restoration, threshold-based sending, application, subscriptions, session change, checkpoint/recovery. | Protected setters, numeric limits, rates and identity. Offset continuous; other values spaced out. Brake/grip/speed restored. Return side checked. No unrestored offset forgotten. Deletion refused without erasing the in-memory entry if storage fails. |
| `caps.lua` | API presence, call with failure counter, >100% probe, mode choice. | C functions accepted; stop after three failures. Deferred level read-back, restoration of its reference, identity protection. No invented native >100% success. |
| `calibration.lua` | Initial/active conditions, relative measurement, safe reset to zero, cancellation. | Aligned and isolated pair, no player/pit/off-track. Sign measured in the reference frame. Identities checked. Waiting if the return is occupied; insufficient result reported. |
| `perception.lua` | Relative projection, occupancy, neighbour selection, target search, corridor. | km/h converted, TTC in seconds, looped spline and spatial consistency. Occupancy recomputed every frame. Pits/off-track excluded, player included as an obstacle. |
| `director.lua` | States, reset/configuration, transitions, side choice, modulators, limiting of directions, movement, pace map, laps/classes, triggering and holding of manoeuvres. | Yielding, overtaking, defending, obstacle, start, return, recovery, fatigue, braking and slipstream reviewed. Forced sides respected, automatic picks the free side, priority to occupancy. Tests of behaviours, booleans and bounds. |
| `engine.lua` | Construction, selection, reset, time wrap-around, configuration, loop. | J/Q/C profiles, inactive section, guards, simulated time, per-car quarantine, commands disabled outside the field, headlights/classes/spacing. Effective options including in case of error. |
| `persona.lua` | Building of traits and next concentration lapses. | Deterministic randomness, percentages converted once, min/max limits. Inactive personality neutralised; general spread independent. |
| `classes.lua` | Patterns, estimate of the lap difference, ranking by pace. | Bounded literal patterns, manual priority, classes 1–4, stabilisation delay. No lap-based priority in Track day. |
| `flash.lua` | Learning, sampling, debouncing, bursts/hold, ranking and distribution of requests. | Field unconfirmed as long as nothing is observed. Three recipients maximum, TTL and propagation. Deterministic inattention and second request, real advance required. |
| `traffic.lua` | Counting, leader on the spline, variable target, longitudinal limit. | J only, local AI cars on track, deterministic variation, cap tied to length/field size. No instantaneous movement. Limit applied progressively and released outside the behaviour. |
| `presets.lua` | Signature, layout, decoding, capture, encoding, application. | 16 slots, bounded name, values validated and copied, replacement by name. No text executed. Log options included. |
| `zones.lua` | Data lexer, types/bounds, zone lookup, export. | No `load` of a user file. Fields and size limited, cautious overlaps, 0/1 loop, escaped export to the clipboard. |
| `util.lua` | Finite numbers, clamp/lerp, signs/angles/spline, approach/EMA, 32-bit multiplication, RNG, log. | Values and repeatability tested. Circular log, deduplication and rate limiting. No CSP access. |
| `lang.lua` | Labels, categories, choices, states, reasons, help texts, units. | Groups/choices matching. Defending marked as Race only; braking marked as emulated. Interface labels are distinct from the persistent identifiers. |

## Calculations, units and physics

- Positions, distances, sizes and track width: metres. Native speed: km/h; calculation speed: m/s. TTC = free distance / positive closing speed, otherwise infinite. The lap difference uses laps + progress and subtracts the local separation.
- The offsets sent by `setAISplineOffset` are **normalised**, not in metres. The sign depends on the calibration. Limited by available width, car size, zone and profile maximum. Ramps and acceleration apply to this normalised coordinate; they do not constitute a guaranteed physical lateral acceleration in m/s².
- Occupancy and corridor take precedence over an overtake, yield or return request. A reduced target does not make the current lateral offset jump. An occupied forced side causes a wait. With both sides occupied, Automatic waits too.
- Internal level bounded at 1.1, then native cap of 1 if >100% is not confirmed. Aggression at most 0.95. Caution 0.5–16. Grip expressed as a ratio, SDK base 1.2; at 110% with a coefficient of 0.004, target 1.248. Extra braking bounded at 0.6 and explicitly allowed.
- The braking zone slider acts on caution and, if allowed, on the extra braking threshold. No native distance API is assumed. Slipstream adjusts caution after continuous following; it does not create an artificial physical aerodynamic effect.
- Nine or fifty AI cars do not imply the same spacing target. The target includes speed, field size and variation; the track's capacity bounds what is possible. The number of cars cannot increase the available length. The limit decreases by at most 4 km/h/s; its progressive removal uses 8 km/h/s when ordinary following continues.
- No simulation of tyre grip, mass, surface adhesion or collisions by the app: these calculations stay within AC/CSP. The bench's guarantees cover commands and decisions, not the exact physical reaction of the game.

## Setting dependencies to know about

- Defending: Race only. Ordinary yielding: Track day and Qualifying. Lap-based blue flags: Race and Qualifying. Spacing: Track day only.
- Line limits are needed for manoeuvres; if their section is inactive, the internal limits remain available. The other sections do not need this tab enabled in order to work.
- `confirmTime` is shared by yielding and overtake preparation; its setting belongs to Yielding. If this section is inactive, overtaking uses the profile's default safety value. The yield side and yield offset parameters also serve the explicit “Opposite to yield side” option.
- Endurance can produce classes, stints and fatigue; its concentration lapses are possible with the layer even if the ordinary personality switch is off. The concentration values then fall back to the effective defaults. In Qualifying, the Endurance layer is unavailable.
- Global options alone do not create an AI behaviour. Their section allows the options for the active functions. Without a behaviour section, the engine stays neutral.
- A built-in preset does not replace calibrations or restoration references. A custom preset does not save them either.

## Criteria still to be observed

The cost of CSP calls, real collisions, the sign obtained on each track, menu transitions, headlight calibration and the >100% level require in-game observation. Loading and display have been confirmed by the user, without this constituting a driving validation.

The new rc.4 soak completed its 1,728,000 frames with 40 AI without engine errors. Benchmark with 30 AI: mean 0.324 ms, P99 0.921 ms, raw maximum 23.766 ms. The mean <0.3 ms and the peak <1 ms fail. Total memory variation after warm-up: 519.7 KiB, above the strict internal 256 KiB threshold; variation over the last hour: 3.2 KiB. Both windows are kept; this observation is not enough to identify a leak or to rule one out. No peak is filtered and no system/code cause is asserted without further measurement.

The soak status remains `ok=false`. No threshold is raised to obtain a pass. The exact values are in MESURES.md. The driving checklist remains in VALIDATION.md. This release remains a candidate as long as these open points are not resolved.
