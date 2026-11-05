# Adversarial review — HumanAI / AdvancedIA

Date: 19 October 2026. Status: candidate implementation, **full validation not achieved**. Unchanged reference: `HumanAI_PDR_v1.0.md`, SHA256 `4b55783096e4c819ca2bafb07146bccab9941e3feb653934a9011b2413157f00` (the French original as of that date; the English translation published in this repository has a different hash).

This page is the **history** of the reviews, from milestones J0 to 1.1; the adversarial reviews of the following versions (up to Beta 1.4) are summarised in [CHANGELOG.md](CHANGELOG.md), and the current results in [docs/MESURES.md](docs/MESURES.md) and [docs/VALIDATION.md](docs/VALIDATION.md). The 1.1 review is detailed in [AUDIT_V1_1.md](docs/AUDIT_V1_1.md): left/right sides, recovery, unloading, Spacing, weather pit stops, garage, 110%, Qualifying preset and detection. The V1 review remains in [AUDIT_V1.md](docs/AUDIT_V1.md). The 1.1 inventory covered 97 profile parameters, 11 global options and 176 functions in 19 Lua files (186 checks and 50 integration cases); the current counts are in [VALIDATION.md](docs/VALIDATION.md) and [PARAMETER_AUDIT.md](docs/PARAMETER_AUDIT.md). 1.2.0 added the Practice profile and detection of Content Manager modes, 1.3.0 the Accidents and Racing rules tabs (see CHANGELOG.md). The current measurements are in [MESURES.md](docs/MESURES.md). The rc.2/rc.4 review and counts below remain historical.

## Reviews by milestone

| Milestone | Risks examined and fixes | Automated evidence |
|---|---|---|
| J0 | Local SDK read before the behaviour; callable cdata, normalised units/metres, time in ms, grip ratio, absence of a distance API, `Disposable` as a function. A single CSP callback. | API_NOTES, APPLIER_CDATA, loading of the real entry point. |
| J1 | Bounds and types, schema versions, unknown keys, storage error, missing/throwing API, player at a non-zero index, restoration without writing in the pits. | S01–S14, SCHEMA_MIGRATION, APPLIER_FILTERS, PLAYER_NONZERO_INDEX, linter. |
| J2 | Canonical left frame, ±8 neighbourhood, lap wrap-around, spline/world consistency, hairpin, aberrant sizes, occupancy recomputed every frame, bounded pace map and deterministic RNG. | S11–S12, GEOMETRY_FIXTURES, RNG_DETERMINISM, fuzz. |
| J3 | Excessively slow initial smoothing fixed; cancellable confirmation and reaction; occupied return frozen; hold duration and post-pass reference fixed; fast follower not masked by a slow one. | T01–T05, T10–T13, Q01–Q03, RESET_OCCUPIED_SIDE. |
| J4 | Overtake confirmation, locked side, corridor, abandonment, chaining, lost target, obstacles/contacts and side-by-side hold. Resumption after a stop synchronised with the restored native offset. | T06–T10, T14–T15, P01–P05, R05–R07 and integration. |
| J5 | Burst of three pulses actually recognised; hold >4 s ignored; inattention cancelled by repetition; limit of three and propagation; occupied side during calibration and counter-steering bias handled. | F01–F12, FLASH_URGENT_DETECTOR, FLASH_CALIBRATION, CALIBRATION_SAFETY, CALIBRATION_ABORT_OCCUPIED. |
| J6 | Defending forbidden against the leader/a higher class; hold range adapted to a distant blue flag; predictable cornering; partial stint and team reference; time wrap-around; quarantine kept when a setting changes; per-car return so that an AI car in the pits does not block the others. | R01–R10, E01–E06, M01–M06, L01–L07, TIME_WRAP, CAR_QUARANTINE, SESSION_DIRECTION_RESET, soak. |
| J7 | Horizontal tabs without checkboxes, real activation of each section below the title, adaptation from 420 to 1060 px, native single-line height, cdata UI functions recognised, full-width sliders, French parameter names from the schema, eight class mappings, three profile buttons, preset library, saving during pause, export without writing a file. | 24 integration cases, walk-through of all parameters/choices/bounds via the real interface, square-tabs regression, doubled font, PROFILE_ISOLATION, panel source and parameter validation. |
| J8 | Reproducible fuzz, data parser without execution, bounded paths, rejection of unknown functions/fields, memory/log limits and check of the native files. | 124 checks, linter over 18 files, integration, JSON reports, inventory and hashes. |

## Additional rc.2 review

- **Real opt-in**: the old values are kept, the new activations start as false. Starting with no section calls no setter, no level probe and no calibration. Disabling General avoids imposing its prepared level on the other behaviours; the known native references are used. Profiles store their activations independently. Since rc.3, explicitly loading a built-in preset enables the recommended sections; custom presets get back their saved checkboxes.
- **Command reservation**: clearing inactive commands interrupts neither a native probe in progress nor the car reserved for calibration. This defect was detected by integration and then fixed. An offset that is already zero and was never modified does not block the restoration of a speed limit.
- **Automatic profile**: manual/auto switching, declared session type read-only, qualifying and the stages of a weekend. The manual choice stays stable as long as automatic is not re-enabled.
- **Spacing**: real count, exclusion of the player and of non-controllable cars, 9/50 AI density, variation kept on a short track, bounds by capacity, progressive reduction and no application in the race. The speed cap is restored on deactivation; the recovery flag survives a reload and accepts the old format without the flag.
- **Menus and presets**: content and opening controlled by the pause/setup context, diagnostics on request; changes saved during the pause. Preset names and values validated, 16 slots, explicit replacement by name, exact highlighting and indication after modification. Preset data is never executed.

The new checks are SECTIONS_DEFAULT_OFF, SECTIONS_EFFECT_ISOLATION, AUTO_PROFILE_SELECTION, CUSTOM_PRESET_VALIDATION, TRAFFIC_DENSITY_RANDOMIZATION, TRAFFIC_PROGRESSIVE_LIMIT and TRAFFIC_NATIVE_RECOVERY. The rc.2 eight-hour kinematic run enables Spacing and Endurance on J and uses the commanded speed limits to move the bench's cars. Real physical observations remain open.

## rc.3 fixes

The missing panel in setup is covered by a case calling the real `script.update`, with no HUD and no window open; a single engine step is checked. The user then confirms that the display is back. BUILTIN_PRESET_ACTIVATIONS and integration check the active sections of the Nordschleife, Realistic race and Endurance presets, the sub-options, the checkboxes shown and the highlighting. Creating a profile stays neutral; custom presets keep their exact checkboxes.

The reviews are grouped here by milestone; the executed and timestamped results are kept in `tests/results.json`, `tests/integration-results.json`, `tests/lint-results.txt` and `tests/soak-results.json`. A row of this table describes the bench's coverage, not a physical certification of in-game behaviour.

## Security and robustness

- No network access, track writes, DLL loading or execution of external text. The only imports are the local modules and the LuaJIT `bit`/`ffi` libraries.
- Only the two adapters access `ac`/`physics` directly. Native calls are protected. Setters stop after three consecutive failures; the other cars/capabilities carry on.
- The zone parser rejects code, functions, unknown fields, duplicates, non-finite/out-of-bounds values, escapes and size/count overflows. The native read returns a text before the size check: this point must not be presented as a partial read with guaranteed memory.
- Restoration references include the model and the driver's name, encoded without interpretation. Replay, pause, player, remote, invalid vehicle, pits and identity replacement guard the writes.
- The reset to zero has no exception to occupancy. A blocked car keeps a pending recovery. A resumption does not reuse the old virtual offset after native restoration.
- Timers wrap around at 24 h, with a consistent shift of the core's and the adapter's deadlines. Bounded car arrays, pace map, neighbourhood, zones, mappings and log.
- The log is limited to 20 entries/second, deduplicated over five seconds, circular over 200 lines. The scenarios also invoke the error paths.

## Native files and dependencies

Spa's `surfaces.ini` and the RARE controller match their original backups exactly. The two Traffic Planner files modified by the old app have been restored exactly:

| File | Restored SHA256 |
|---|---|
| `TrafficDriver.lua` | `14b83a5406f56b9a73b56d9dc1f4002110bd07d48bdcdfd1cbc8983f0e38ef2a` |
| `TrafficSimulation.lua` | `5365ddaf9c2ac9b420eaeead7352dde237851f684ce1e067498e087e5b0c894f` |
| Spa `surfaces.ini` | `c5b4af8a1d822e23da3d81a6f33a28b76027cae4754771e54b14837740c430cd` |
| RARE `src/controllers/ai.lua` | `cfcbec0bedc150babaff3aa0596b6d79e8e5c77a450717e4e20f598bdaf5a8d9` |

The old shared Traffic module and the per-track access tool have been archived in `_ACAdvancedIA_archives/legacy_v0_3_3`, at the game root, and removed from the active paths. The engine imports neither RARE nor this old integration.

## Criteria still open (rc.2 to rc.4 history)

Measurements from that time, kept as they were; the measurements of the current version are in [docs/MESURES.md](docs/MESURES.md).


Historical rc.4 result: 124 checks and 24 integration cases passed; eight hours/40 AI without engine errors. Core with 30 AI: mean 0.324 ms, P99 0.921 ms, raw peak 23.766 ms; both CPU targets fail. Total memory variation: 519.7 KiB, of which 3.2 KiB over the last hour; the strict overall 256 KiB threshold fails. Physical in-game observations remain open. Details and exact values in [MESURES.md](docs/MESURES.md).

Final rc.2 measurement: 109 checks and 20 integration cases passed; eight hours/40 AI without engine errors. Core with 30 AI: mean 0.204 ms, P99 0.511 ms, raw maximum 9.098 ms. The mean passes and the peak fails. Overall memory variation after collection: 435.4 KiB, above the strict internal 256 KiB threshold; variation over the last hour: 3.3 KiB. Both windows are reported, without removing the initial variation and without any undemonstrated causal attribution. The soak result remains `ok=false`. See [MESURES.md](docs/MESURES.md).

The raw peak <1 ms is not validated by the first benchmark, despite a mean <0.3 ms. The final campaign keeps the observed maximum in its JSON, without removing outliers. The real CSP log confirms the loading of this version, two windows and several successful reloads. No real driving test of this version is declared complete. See the open checklist in [VALIDATION.md](docs/VALIDATION.md).

The presence of all the functions, the 78 scenarios and the safeguards is therefore not enough to declare “all OK” or to announce an accepted final v1.0.
