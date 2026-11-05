# Final review — AdvancedIA 1.0.0

This release brings together the complete review of the active code, the optimisation of the core, the fix for the slowdown on track days and the requested weather handling. The exact results are in [MESURES.md](MESURES.md), with a separate status for the strict criteria not met. The release number does not constitute a physical certification or a universal FPS guarantee.

## Defects fixed since rc.4

| Item | Finding and fix | Verification |
|---|---|---|
| Field crawling at Le Mans with the Nordschleife preset | The capped speed was fed back into the next calculation, propagating from the leader. Reproduction: 40 AI at 100 km/h dropped to 30 km/h in a tight queue. New reference taken during the free phases, bounded reduction, six-second episodes staggered between cars, and twelve free seconds. No correction below 60 km/h. | TRAFFIC_NO_SPEED_RATCHET: on the same bench, the limit stays at 90 km/h or more with a 10% reduction allowed. TRAFFIC_FREE_PHASE_RECOVERS_PACE checks that a car can accelerate beyond 190 km/h after a slow exit. These values describe the bench, not a speed imposed on every track. |
| Neighbourhood CPU cost | The same array was sorted for each car, with a sixteen-neighbour search loop for each candidate. Sort kept between frames and shared by the perceptions of the same frame; circular ranks pre-indexed. | PERCEPTION_SHARED_ORDER_EQUIVALENCE compares the selected sets over 80 configurations, up to 61 cars, with wrap-around and ties. The geometry and occupancy scenarios remain active. |
| Closest distance | A square root was computed for each pair in the occupancy check. | Minimum of the squared distances computed, then a single root per car. Occupancy is still recomputed every frame, with no reduction in its rate. |
| Section activations | Repeated string concatenations in the most frequently called paths. | Keys built once in the schema; direct reading of the known booleans in the AI loop. The isolation and unticked-checkbox tests stay green. |
| Abandoning an overtake | The blocked-corridor delay reused the lateral occupancy counter, which could cancel it. | Separate `passBlocked` counter. PASS_BLOCK_TIMER_INDEPENDENT places an obstacle in the corridor without blocking the immediate side and checks the abandonment. |
| Native C calls | The setters always received a third argument, even for a two-argument signature. | Number of arguments adapted to each API: two arguments, except the offset with its boolean. NATIVE_SETTER_ARITY tests real numeric and boolean C FFI pointers. |
| Duplicates and obsolete state | Manual fields that had become useless, counters with no reader, a second SimState read per update, a redundant import, a copy of the load generator in the soak. | Dead fields and paths removed; SimState reused for the menus; load scenario shared by both measurements. The tools' version comes from the manifest. |
| Legacy code | The pre-HumanAI sources remained in a subfolder of the app. | Moved to `_ACAdvancedIA_archives/legacy_v0_3_3`, at the game root and outside the loaded folder. No legacy source is packaged in V1. |
| Interface | All fields were iterated to draw a single group. | Controls indexed by group; only the controls of the active category are iterated. Windows always closed while driving. |
| Inactive app | Cars were still being read with no active section. | Standby without reading cars after the commands are restored; resumption with identities refreshed before any write. The integration case measures zero reads and zero commands on standby, then checks activation and deactivation. |

## Independent weather

The Weather tab is enabled in the three built-in presets. The first launch stays neutral, with all sections disabled. Schema 2 profiles and presets are migrated to schema 3 while keeping their activations; the former weather choice tied to Endurance is carried over.

- The pace uses the actual track wetness. The tyre strategy also watches rain intensity and standing water. A hysteresis and fifteen seconds of confirmation avoid changing the decision at every variation.
- The catalogues are read through the CSP tyre APIs, with a budget of two cars per frame, then kept per identity. Dry, intermediate and wet names are told apart, with a legality check if the API is available. Recognition by name is not a guarantee for a mod with arbitrary labels.
- In dry weather on a sufficiently dry track: a dry compound already fitted is kept, including if the native strategy has changed it. To come off a wet tyre, the original dry compound is preferred when it is available. In the rain: intermediate or wet depending on the conditions and the compounds available.
- The native `setAIRainTyres` command takes priority. If a real compound has to change, a pit stop request is sent; `setAITyres` is only called when stopped in the pits. This API also resets tyre damage, as the SDK states: it is never used to replace the tyres at racing speed.
- With no wet compound available and if the native field confirms that no wet tyre is active: adjustable grip compensation from 0 to 30%, default 15%, modulated by the conditions. This is a configurable assist, not a universal wet-tyre model. Rain FX physics continues to apply.
- If CSP already reports a native wet tyre, no extra compensation is added. The >100% level bonus and the weather share a single grip write point to avoid competing setters.
- The compensation is removed in the dry and on deactivation. Wet tyre and pit requests are tracked per identity and in the recovery on reload. The compound actually changed in the pits stays fitted: disabling the app does not cause a new instant tyre change.

Pit service operations are the explicit exception to the earlier “no setter in the pits” principle: they only concern authorised weather, a local AI car and a verified stop. Levels, offsets and other driving commands remain forbidden in the pits, as does any command online, in replay or in pause. The SDK provides no documented automatic return to the default rain strategy; restoration reinstates the rain state observed when the app took over.

## Tests and measurements

The tests run the real entry point and the adapters with a simulated SDK, then check the parameters, the lists, the checkboxes, the presets, their deletion, the weather, the changes in the pits and recovery. The pure bench also checks the extremes, the fuzz and the manoeuvres. The linter rejects globals and unused variables.

The current inventory [PARAMETER_AUDIT.md](PARAMETER_AUDIT.md) covers every schema field and every active function. The counts are generated and the hashes kept in JSON. The rc.4 review remains a historical reference, supplemented by the fixes above.

The comparative measurements use the same load, in independent VMs, on the rc.4 archive and the current code, with no profiler enabled for the compared figures. The LuaJIT statistical profiler was used to find the costly spots; its instrumented measurements remain separate. The scenario now includes the V1 weather data; the rc.4 engine ignores them.

The eight-hour soak with 40 AI and the 30-AI benchmark finished without engine errors. Core mean with 30 AI: 0.173 ms; P99: 0.402 ms; raw peak: 1.960 ms. The mean meets the 0.3 ms target; the peak exceeds the 1 ms one. The total memory variation of 663.5 KiB exceeds the bench's additional 256 KiB check; the last hour varies by 39.3 KiB. None of these values is filtered. The out-of-game measurements exclude the cost of CSP physics calls and of drawing the interface. The comparison table and the structured results are kept in MESURES.md and the result files.

## GPU load and limits

The engine draws no 3D object, texture or shader. The interface code is reserved for the pause/setup menus. V1 modifies no track, car file or global CSP graphics setting, and imports no other AI controller.

An absence of FPS drop cannot be inferred from the pure core alone: it also depends on the processor, the cars, the track, the rain and the graphics settings. Driving tests, the native pit strategy and real weather transitions remain to be observed on the installation. The results and the criteria not met are declared in MESURES.md; no 100% physical validation is inferred from simulated tests.
