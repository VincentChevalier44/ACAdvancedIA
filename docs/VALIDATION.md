# Validation — ACAdvancedIA HumanAI

## What the test bench checks

- The **78 identifiers of Appendix A** are extracted from the PDR and must each have a test function. The assertions cover states, distances, offsets, delays, outputs and commands. The fixtures are kinematic; some freeze a geometry to isolate a behaviour, others reposition a target to test a specific transition.
- **304 additional checks** (382 in total with Appendix A): RNG, cdata functions, native filters, calibration, quarantine, profiles, time fallback, migration, log, zone parser, straight/loop/oval/hairpin/narrow-track geometry, player at a non-zero index, occupied returns, loss of advantage during a reaction, autonomous horn, obstacle threshold, Endurance preset on a track day, sections disabled by default and isolated, return to the automatic profile, validated named programmes, progressive spacing, densities of 9/50 AI on long/short tracks and recovery of the speed cap after reloading. The rc.4 checks cover all false booleans, the requested defaults, forced/automatic sides, the bounds of every parameter in the engine, the log, continuous slipstream, temporary identities, brake only, restore failure, the behaviour and weather switches, as well as saving/restoring all programme fields and refusing deletion when storage fails. Version 1.1 adds side orientation for both calibrated signs, spacing through a corner with a dynamic gap, the reset during a spacing episode, the Qualifying preset and its one-time application, the migration of setting markers, and the neutral additional brake released in the pits.
- Fuzz of **10,000 steps**, fixed seed, NaN/inf, aberrant positions/speeds/splines/laps/dimensions/flags, up to 60 AI.
- AST linter for scopes, forbidden globals, unused local variables, external `require` calls rejected; syntax also loaded by LuaJIT 2.1. Explicitly unused parameters carry a `_` prefix.
- Integration of the real entry file, **90 cases** (Beta 1.27 keeps grid lane hold covered with the setting ticked, now that it is off by default; Beta 1.26 checks AI placement over the whole track and the lifting of the AC message hiding if it removed them from the overlay; Beta 1.25 checks the in-game overlay — position, lock, size, replay, session box and AC messages —, its settings section and the Safety Car coming out; Beta 1.24 checks the reset of each settings section and the reading of the main dry compounds; Beta 1.23 checks that a stop with no remaining damage neither writes nor logs any repair; Beta 1.22 adds staggered pit exits in practice and qualifying through the native wait alone, cancelled away from the pit box and on unloading, no AI held back at the start of a track day, and the Safety Car brought back every time it leaves its pit box; Beta 1.21 keeps AI parked with the native wait and logs their actual exit; Beta 1.20 adds staggered pit exits on a track day and repairs at race stops; Beta 1.19 adds the row titles of the Racing rules tab, which show their settings without changing anything, the stops and Safety Car views on the Race profile, the kept highlight, the reset, the default Safety Car absent from or present on the grid, and the track day declared as qualifying; Beta 1.18 adds the Mandatory stop and Safety Car toggles: set by each rule set, Practice, Qualifying and Race together, saved, notes for the cases with no effect, scrolling column; Beta 1.17 adds the Racing rules tab: tab order, Rules section removed from Settings, toggle specific to the profile shown and saved, editable rule sets and settings; Beta 1.16 adds the interface language: English on first install, French on click, choice saved and kept on reload, flag panel retranslated, existing installation kept in French; and a pass through all the tooltips in French): first install as “Base rules” (Track day with no commands, probe or calibration), windows limited to the menus, opening in the setup screen with no HUD or window already open and without a double update, four highlighted profile buttons, auto after a manual choice and race.ini type, real and persistent activation of the sections, named custom library with edit/reload/highlight, built-in presets enabling their sections with ticked boxes and highlight, storage even while paused, calibration after activation, native spacing and restore, weekend, replay, alt-online, deactivation, unloading and reloading. One case also checks persistent deletion active/inactive, reusable slots and long names. The two rc.4 walkthroughs select every choice, every boolean and the numeric bounds of the 147 parameters of the four profiles and of the 11 global options, then check engine and storage. The tabs are checked from 420 to 1060 px with normal height, doubled font and `cdata` UI functions. Version 1.1 adds 10 cases, each failing on 1.0.1: yielding to the right in an indirect and in a direct AC coordinate frame, reloading with or without saved settings, unloading while paused, 110% at the pit exit and actual clipping, pit request maintained in the lane, native rain strategy in the dry, garage, session restart, J/Q/C weekend with race.ini per session, and neutral first install. Version 1.2.0 adds detection of the Content Manager modes (Track Day, Practice, Race) and adapts the weekend cases (Practice → Qualifying → Race) and the preset cases to the retained automatic mode. Version 1.3.0 adds the migration of 1.2.0 profiles with backup, the accident end to end (limit written, flag and message, forced stop, everything handed back), the race with a mandatory stop (requests, tyres, lifting, storing, restore) and the Safety Car parked then handed back; 1.3.2 adds the on-disk session log (rotation, versioned header, session, incident, summary, end, cut-off). Version 1.5.1 adds a check of reading the game on a heading that crosses ±180°, failing on 1.5.0. The soak and the performance bench trigger neither a red flag nor the panel: these 1.5.0 paths are covered by the checks and integration cases below, not by the 8 h workload. Version 1.5.0 adds five checks (red flag procedure, player excluded, race only, no endless restart; panel priorities and texts; player's blue flag; “panel only” migration; stop under red flag not counted) and two integration cases (red flag end to end with the window open, bounded drawing, recovery and restart; empty panel with no flag). Version 1.4.0 adds a tooltip content check (one per setting and global option, distinct, in French, bounded lines) and four integration cases: a tooltip after every control on the four profiles and the fourteen tabs, diagnostics window included, with only the chosen tab highlighted and colours always restored; rules selectable from Track day and independent of the presets; profile shown distinct from the profile in use; tyres adapted on the grid before the start, without a requested stop, dry compounds distributed. The tyre case fails on 1.3.7. Version 1.3.7 adds four checks (yielding and overtaking through linked corners with smoothed rotation as in the game, yielding on a headlight flash in a corner, counter of interrupted manoeuvres); three fail on 1.3.6, the overtaking-in-corners check being a guard; the line-variation check also covers the maximum variation. Compared with 1.3.6, 1.3.7 changes the manoeuvres that the cap no longer cuts (first deviations when pulling out, profiles J, Q and C; profile P identical on this bench). Version 1.3.6 adds two checks (full avoidance during the anti-zigzag rest and cap already reached; spin followed by a slow stop counted as a single incident), each failing on 1.3.5. Version 1.3.5 adds two checks (overtake completed after the side-by-side phase, including a closed corridor, abandoned only if the target gets back ahead; no return to holding during the cut-back), each failing on 1.3.4. Version 1.3.4 adds two checks (stabilised end of incident, per-minute log counters), each failing on 1.3.3. Version 1.3.3 adds three checks (line variation never counted by the anti-zigzag cap, manoeuvre cap with a single warning, missing zones file), each failing on 1.3.2. Since 1.3.3, the equivalence bench against 1.2.0 shows intended differences: free-driving moves are no longer subject to the delay between direction changes or to the cap; the differences recorded are of the order of a hundredth of offset, and the ban on moving towards an occupied side, checked on every frame of every scenario, is still respected.
- **757 mutations** (`tests/mutate.py`): each important rule is altered in a throwaway copy and the named test must fail; all detected in Beta 1.29. Since 1.8.0, errors caught on shutdown, on restore, on session change and in the interface also make the tests fail.
- V1 soak of **8 h / 1,728,000 frames / 40 AI**, Track day profile with Spacing and Endurance, variable weather, classes, stints and traffic on a ring. The kinematic bench takes the commanded speed limits into account; periodic memory collection. Benchmark of 30,000 frames with 30 AI. The raw maximum time is kept, including process interruptions: no spike is masked. The current status and the exact values are in MESURES.md; the rc.2 result is kept separately.

## Validation limits

V1 adds tests for a tight queue without cumulative reduction, pace recovery after a slow exit, shared-neighbourhood equivalence, overtake abandonment, C setter arguments, weather decisions and migration. The simulated native cases cover real wet tyres in the pits, compensation without wet tyres, native priority, return to the dry, keeping another dry compound and reloading during a stop. The standby case checks zero car reads while the app is inactive, then fresh identities on resuming and a complete restore before going back to standby. The current inventory covers 161 profile fields, 11 global options and 31 Lua files; see [PARAMETER_AUDIT.md](PARAMETER_AUDIT.md).

A safety assertion checks every move of the core in the bench: no movement towards an occupied side, offset bounds and at most six direction changes per minute. This does not prove the absence of collisions in the real physics engine, between two perceptions or with another app writing at the same time.

The CSP calls in the integration tests are simulated. Native detection of level >100%, headlight calibration and the signs must produce their observations in the game. The bench checks their branches, their restores and their safeguards.

The benchmark times the **pure core**, without the SDK reads/writes or the UI. The QPC counter in the debug window measures the AI update loop, with SDK reads/writes but excluding window drawing, if the sandbox allows it. The total cost including the interface must be observed with the CSP profiler.

The Beta 1.29 soak finished without errors (8 simulated hours on a track day, memory between 7.8 and 8.7 MB; one hour of regulated racing, 0.34 ms on average); benchmark 30 AI 0.18 ms (Beta 1.28: 0.19), 60 AI 0.49 ms (Beta 1.28: 0.50). The Beta 1.28 soak finished without errors (8 simulated hours on a track day, memory between 7.4 and 8.3 MB; one hour of regulated racing, 0.27 ms on average); benchmark 30 AI 0.19 ms (Beta 1.27: 0.21), 60 AI 0.55 ms (Beta 1.27: 0.55). The Beta 1.27 soak finished without errors (8 simulated hours on a track day, memory between 7.4 and 8.2 MB; one hour of regulated racing, 0.18 ms on average); benchmark 30 AI 0.20 ms (Beta 1.26: 0.21), 60 AI 0.53 ms (Beta 1.26: 0.57). The Beta 1.26 soak finished without errors (8 simulated hours on a track day, memory between 7.2 and 7.9 MB; one hour of regulated racing, 0.19 ms on average); benchmark 30 AI 0.21 ms (Beta 1.25: 0.22), 60 AI 0.55 ms (Beta 1.25: 0.59). The Beta 1.25 soak finished without errors (8 simulated hours on a track day, memory between 7.6 and 8.5 MB; one hour of regulated racing, 0.24 ms on average); benchmark 30 AI 0.22 ms (Beta 1.24: 0.23), 60 AI 0.69 ms (Beta 1.24: 0.53). The Beta 1.24 soak finished without errors (8 simulated hours on a track day, memory between 7.12 and 7.73 MB; one hour of regulated racing, 0.192 ms on average); benchmark 30 AI 0.183 ms (Beta 1.23: 0.157), 60 AI 0.498 ms (Beta 1.23: 0.445). The Beta 1.23 soak finished without errors (8 simulated hours on a track day, memory between 6.31 and 6.88 MB; one hour of regulated racing, 0.149 ms on average); benchmark 30 AI 0.165 ms (Beta 1.22: 0.173), 60 AI 0.479 ms (Beta 1.22: 0.469). The Beta 1.22 soak finished without errors (8 simulated hours on a track day, memory between 7.47 and 8.10 MB; one hour of regulated racing, 0.158 ms on average); benchmark 30 AI 0.178 ms (Beta 1.21: 0.187), 60 AI 0.468 ms (Beta 1.21: 0.480). The Beta 1.21 soak finished without errors (8 simulated hours on a track day, memory between 7.45 and 8.12 MB; one hour of regulated racing, 0.167 ms on average); benchmark 30 AI 0.163 ms (Beta 1.20: 0.174), 60 AI 0.442 ms (Beta 1.20: 0.441). The Beta 1.20 soak finished without errors (8 simulated hours on a track day, memory between 6.19 and 6.76 MB; one hour of regulated racing, 0.175 ms on average); benchmark 30 AI 0.177 ms (Beta 1.19: 0.172), 60 AI 0.475 ms (Beta 1.19: 0.467). The Beta 1.19 soak finished without errors (8 simulated hours on a track day, memory between 5.64 and 6.10 MB; one hour of regulated racing, 6 neutralisations, 0.182 ms on average; no Safety Car on its grid); benchmark 30 AI 0.190 ms (Beta 1.18: 0.212), 60 AI 0.515 ms (Beta 1.18: 0.482). The Beta 1.18 soak finished without errors (8 simulated hours on a track day, memory between 6.54 and 7.05 MB; one hour of regulated racing, 6 neutralisations, 0.170 ms on average; its workload contains no Safety Car, the escalation is covered by the checks); benchmark 30 AI 0.199 ms (Beta 1.17: 0.184), 60 AI 0.516 ms (Beta 1.17: 0.504). The Beta 1.17 soak finished without errors (8 simulated hours on a track day, memory between 7.43 and 7.90 MB; one hour of regulated racing, 6 neutralisations, 0.163 ms on average); benchmark 30 AI 0.190 ms (Beta 1.16: 0.172), 60 AI 0.480 ms (Beta 1.16: 0.465). The Beta 1.16 soak finished without errors (8 simulated hours on a track day, memory between 6.46 and 6.95 MB, about 0.45 MB more for the English texts; one hour of regulated racing, 6 neutralisations, 0.167 ms on average); benchmark 30 AI 0.170 ms (Beta 1.15: 0.163), 60 AI 0.457 ms (Beta 1.15: 0.438). The Beta 1.15 soak finished without errors (8 simulated hours on a track day, memory between 5.86 and 6.39 MB; one hour of regulated racing, 6 neutralisations, 0.168 ms on average); benchmark 30 AI 0.203 ms (Beta 1.14: 0.167), 60 AI 0.538 ms (Beta 1.14: 0.522). The Beta 1.14 soak finished without errors (8 simulated hours on a track day, memory between 6.40 and 7.00 MB; one hour of regulated racing, 6 neutralisations, 0.162 ms on average); benchmark 30 AI 0.191 ms (Beta 1.13: 0.171), 60 AI 0.559 ms (Beta 1.13: 0.463). The Beta 1.13 soak finished without errors (8 simulated hours on a track day, memory between 7.38 and 8.06 MB; one hour of regulated racing, 6 neutralisations, 0.193 ms on average); benchmark 30 AI 0.184 ms (Beta 1.12: 0.205), 60 AI 0.526 ms (Beta 1.12: 0.481). The Beta 1.12 soak finished without errors (8 simulated hours on a track day, memory between 5.89 and 6.39 MB; one hour of regulated racing, 6 neutralisations, 0.214 ms on average); benchmark 30 AI 0.216 ms (Beta 1.11: 0.221), 60 AI 0.584 ms (Beta 1.11: 0.540). The Beta 1.11 soak finished without errors (8 simulated hours on a track day, memory between 5.23 and 5.72 MB; one hour of regulated racing, 6 neutralisations, 0.184 ms on average); benchmark 30 AI 0.182 ms (Beta 1.10: 0.179), 60 AI 0.534 ms (Beta 1.10: 0.496). The Beta 1.10 soak finished without errors (8 simulated hours on a track day, memory between 5.92 and 6.40 MB; one hour of regulated racing, 6 neutralisations, 0.195 ms on average); benchmark 30 AI 0.191 ms (Beta 1.9: 0.210), 60 AI 0.546 ms (Beta 1.9: 0.532). The Beta 1.9 soak finished without errors (8 simulated hours on a track day, memory between 5.86 and 6.37 MB; one hour of regulated racing, 6 neutralisations, 0.214 ms on average); benchmark 30 AI 0.213 ms (Beta 1.8: 0.194), 60 AI 0.619 ms (Beta 1.8: 0.542). The Beta 1.8 soak finished without errors (8 simulated hours on a track day, memory between 5.33 and 5.75 MB; one hour of regulated racing, 6 neutralisations, 0.246 ms on average); benchmark 30 AI 0.157 ms (Beta 1.7: 0.154), 60 AI 0.430 ms (Beta 1.7: 0.412). The Beta 1.7 soak finished without errors (8 simulated hours on a track day, memory between 5.29 and 5.87 MB; one hour of regulated racing, 6 neutralisations, 0.167 ms on average); benchmark 30 AI 0.173 ms (Beta 1.6: 0.163), 60 AI 0.482 ms (Beta 1.6: 0.459). The Beta 1.6 soak finished without errors (8 simulated hours on a track day, memory between 6.62 and 7.17 MB; one hour of regulated racing, 6 neutralisations, 0.184 ms on average); benchmark 30 AI 0.176 ms (Beta 1.5: 0.173), 60 AI 0.468 ms (Beta 1.5: 0.461). The Beta 1.5 soak finished without errors (8 simulated hours on a track day, memory between 5.24 and 5.85 MB; one hour of regulated racing, 6 neutralisations, 0.204 ms on average, measured during a game session); benchmark 30 AI 0.166 ms (Beta 1.4: 0.167), 60 AI 0.429 ms (Beta 1.4: 0.458). The Beta 1.4 soak finished without errors (8 simulated hours on a track day, memory between 5.62 and 6.05 MB; one hour of regulated racing, 6 neutralisations, 0.179 ms on average; the app's JIT compiler cache enabled); benchmark 30 AI 0.162 ms (Beta 1.3: 0.273), 60 AI 0.437 ms (Beta 1.3: 0.644). The Beta 1.3 soak finished without errors (8 simulated hours on a track day, memory between 3.14 and 3.77 MB; one hour of regulated racing, 6 neutralisations, 0.230 ms on average); benchmark 30 AI 0.239 ms, 60 AI 0.603 ms. The Beta 1.2 soak finished without errors: 8 simulated hours on a track day (memory between 2.73 and 3.82 MB), then one simulated hour of regulated racing (delta time, 6 neutralisations, DRS rules, AI DRS and driving errors; average cost 0.205 ms at 30 AI, memory stable to within 821 KB). Benchmark with the game closed: 30 AI 0.239 ms, 60 AI 0.593 ms. The Beta 1.1 soak finished without errors: memory between 3.04 and 3.74 MB; benchmark 30 AI 0.234 ms, 60 AI 0.633 ms (engine unchanged since Beta 1.0). The car database was read from a real `content/cars` folder of 343 cars: names identical to those from a full JSON parser. The Beta 1.0 soak finished without errors (1,728,000 frames, 40 AI): memory between 2.53 and 3.75 MB, garbage collector included, no trend. Benchmark with the game closed, alternating with 1.8.0 (no difference beyond noise): 30 AI 0.211 ms, 60 AI 0.572 ms. The 1.8.0 soak finished without errors (1,728,000 frames, 40 AI): memory between 3.01 and 3.68 MB, garbage collector included, no trend. Benchmark with the game closed: 30 AI 0.193 ms (P99 0.352 ms, raw maximum 1.6 ms), 60 AI 0.554 ms (P99 0.843 ms). The 1.7.2 soak finished without errors (1,728,000 frames, 40 AI; measured while the game was running): memory between 3.08 and 3.52 MB excluding garbage collector passes, no trend. The 1.7.0 soak finished without errors (1,728,000 frames, 40 AI): average 30 AI 0.218 ms, P99 0.395 ms, raw maximum 1.8 ms; memory between 3.24 and 3.53 MB excluding garbage collector passes, no trend. The 1.5.1 soak finished without errors (1,728,000 frames, 40 AI): average 30 AI 0.243 ms, P99 0.605 ms, raw maximum 7.2 ms, memory between 3.05 and 3.30 MB excluding garbage collector passes, no trend. The 1.5.0 soak finished without errors (1,728,000 frames, 40 AI; neither red flag nor panel in the workload): average 30 AI 0.224 ms, P99 0.472 ms, raw maximum 2.9 ms; total memory variation 629.8 KiB, of which 7.7 KiB in the last hour. The 1.4.0 soak finished without errors (1,728,000 frames, 40 AI): average 30 AI 0.243 ms, P99 0.564 ms, raw maximum 6.5 ms; total memory variation 425.6 KiB, of which 2.5 KiB in the last hour. The 1.3.7 soak finished without errors (1,728,000 frames, 40 AI, all new features active in the workload): average 30 AI 0.247 ms, P99 0.547 ms, raw maximum 74.0 ms (PC under load during the measurement); total memory variation 756.5 KiB, of which 277.1 KiB in the last hour. This last figure (maximum minus minimum) comes from the garbage collector: over 8 simulated hours, the memory curves of 1.3.6 and 1.3.7 stay bounded between 2.9 and 3.4 MiB with no growth, with 190 and 192 KiB of spread over the last hour. As since 1.0.0, the bench's strict criteria (maximum under 1 ms, less than 256 KiB of total variation) remain open and the soak ends with the status `ok: false`. The 1.3.6 soak had given 0.248 ms, P99 0.611 ms, maximum 15.9 ms, 7.7 KiB over the last hour. The 1.3.5 soak had given 0.196 ms, P99 0.494 ms, maximum 2.8 ms, 6.1 KiB over the last hour; the difference in average between successive soaks mostly reflects the PC load during the measurement (separate benchmark: 0.173 ms). The 1.3.4 soak had given 0.216 ms, P99 0.455 ms, maximum 9.6 ms, 10.0 KiB over the last hour. The 1.3.3 soak had given 0.255 ms, P99 0.623 ms, maximum 4.5 ms, 10.7 KiB over the last hour. The 1.3.2 soak had given 0.220 ms, P99 0.552 ms, maximum 4.4 ms, 6.5 KiB over the last hour. The 1.3.1 soak had given 0.270 ms, P99 0.627 ms, maximum 10.6 ms, 10 KiB over the last hour. The earlier 1.3.0 soak had given 0.272 ms, P99 0.649 ms, maximum 18.8 ms. In the benchmark with the game closed, **the average criterion (<0.3 ms at 30 AI) passes; the maximum criterion (<1 ms) fails**, as since 1.2.0; the [MESURES.md](MESURES.md) report applies its own criteria to the soak workload. Measured separately, with the game closed, alternating the versions over four rounds: 1.2.0 ≈ 0.157 ms, 1.3.0 with the new features off ≈ 0.168 ms, 1.3.0 with everything on ≈ 0.204 ms, i.e. about 1.5 µs per AI per frame for the new features. In the 1.3.0 soak, the total memory variation had reached 929.8 KiB, of which 599.6 KiB in the last hour: this max−min spread included a periodic garbage-collector drop, absent from the last hour of the 1.3.1 soak. Curves over 8 simulated hours, measured every 10 minutes after collection, show the same bounded profile in 1.2.0 (3,058 → 2,841 KiB) and in 1.3.0 (3,011 → 3,182 KiB, final plateau within ±60 KiB): no continuous growth, 1.3.0 using about 340 KiB more in steady state (incident, pit and AI-to-AI headlight flash tables). The strict 256 KiB threshold over the whole window is still not met, as since 1.0.0. The final measurement and the exact values are kept in `tests/soak-results.json`.

The first rc.2 campaign ran its eight hours without engine errors, then failed on the internal memory-variation criterion of <256 KiB. The old bench then stopped the run before the JSON and the benchmark. The instrumented campaign now always produces its values, its strict status and the last-hour variation; the threshold has not been raised and the global window has not been removed. The PDR requires no growth after stabilisation; the global 256 KiB threshold is an additional bench check.

The real log `Documents/Assetto Corsa/logs/custom_shaders_patch.log`, consulted on 19 October 2026, confirms **`App: ACAdvancedIA loaded and ready to run`**, two windows declared and several reloads. After the missing panel in the setup screen reported at 19:54, the user confirmed the display and the apparent operation with the rc.3 fix. This finding certifies neither the manoeuvres, nor the calibration, nor the cost of commands while driving. These tests remain open.

## In-game tests still open

To check first (Beta 1.29):

- [ ] Rules tab: in the Track day and Hotlap views, **Mandatory stop in the race** and **Safety Car** are off and ignore clicks, even when the Race profile has a mandatory stop.
- [ ] Add a mandatory stop by hand, then load **Realistic race** (or **Free practice**, **Flying-lap qualifying**): the mandatory stop is off for Practice, Qualifying and Race. **Nordschleife Touristenfahrten** leaves the race weekend as it is.
- [ ] In Practice (automatic profile), no built-in preset is highlighted until you click one; only the clicked preset of the profile shown lights up.
- [ ] Practice: pass an AI just before a corner: it does not force its way back in the corner, and does not attack you for about 20 s.
- [ ] An AI stuck in a gravel trap is taken back to its pit about 30 s after it stops making progress (log `IA immobile depannee a son stand (bloquee, …)`).
- [ ] Far fewer `direction_limit` lines than in Beta 1.28 (630 in the four sessions of 2 November); yields and overtakes are no longer cut halfway.
- [ ] Track day: stuck behind an AI at the same speed, one double flash makes it yield (log `appel de phares du joueur: … compris par 1`, then `cede sur appel de phares du joueur`). From 150–200 m with a large speed advantage (about 40 km/h), the AI yields earlier than before; with a small one, it waits until you are closer.

To check first (Beta 1.28):

- [ ] Track day with many cars: when a car holds up a queue, `IA anormalement lente: … a … km/h depuis … s, allure de sa classe ici … km/h` (abnormally slow AI) names it with its model, the app's speed limit (`limite de vitesse app`), its state and damage; then `roule de nouveau normalement` (back to normal).
- [ ] AI distribution: a car still in trouble 3 s after placement is named, `… en difficulte apres le placement (aux stands | hors piste | lente | glissade, …)`.

To check first (Beta 1.27):

- [ ] Race start with the new defaults (start delay 1 s, settling time 25 s, no grid lane hold): the pack gets away quickly and keeps its positions into the first corner, as in your “Course Test” preset.
- [ ] Existing install: profile update line `profils mis a jour vers les prereglages Beta 1.27: C:depart` (profiles updated) only if the Race profile was still on the old start defaults.

To check (Beta 1.26):

- [x] Track day, 60 AI at the Nürburgring: `45 IA posees en piste sur 45 prevues` (… AI placed on track out of … planned), `45 IA roulent normalement, 0 en difficulte (glissement max 1 deg)` (… AI driving normally, … in trouble, max slip … deg).
- [ ] Varied gaps at placement: `… m d ecart en moyenne (de … a … m)` (average gap, from … to … m); some AI almost one behind the other and others widely spaced.
- [ ] AI flood: below the threshold, `AI flood de CSP: active … portee … km` (CSP AI flood: on … range … km) then, at the next launch, AI around the player over the chosen range (beyond 2 km: effect to be confirmed).
- [ ] AC messages: `messages d AC: affichage d origine masque, messages repris sur l overlay` (AC messages: original display hidden, messages shown on the overlay); no duplicate message.
- [ ] Overtakes: `cible perdue` (target lost) rare; faster AI overtaking slower ones.

To check (Beta 1.25):

- [ ] Log: `sens lateral retabli: -1 / -1` (lateral direction restored), then `sens lateral: -1 / -1` at every session; AI moving aside, pulling out and avoiding again, without jerks.
- [ ] Start: `depart: maintien de ligne actif, … maintenues N` (start: line hold on, … held) with N > 0; `depart: peloton a … km/h` (start: field at … km/h); field flat out to the first corner, cautious in the corner.
- [ ] Safety Car: `voiture de securite: liberee` (released), then `sortie de son stand apres … s` (out of its pit box after … s) and `en piste apres … s` (on track after … s); it takes the lead of the field.
- [ ] In-game overlay centred at the top, session line (position, lap, best lap, fuel); AC session box hidden; unlock, move, size, right-click to lock; opaque, dimmed, transparent background.
- [ ] Crossing the line: “LAP n/N”, last lap and best lap; yellow flag and double yellow with their explanation.
- [ ] End of race: “RACE OVER”, chequered flag and recap (position, start, places, best lap, overtakes), `fin de course:` (end of race) line in the log.
- [ ] AC messages shown on the overlay; `message d AC: …` (AC message) lines in the log (decide which ones to hide).

To check (Beta 1.24):

- [ ] Race start: `depart: maintien de ligne …` line (AI measured, offset, held, width known, sign) and `pneus au depart` (tyres at the start); fewer AI lifting off before the first corner.
- [ ] First corner: `radar avant: … freine derriere …` (front radar: … brakes behind …) and `contact: …` lines; fewer rear-end impacts, driving still smooth (no visible brake stabs).
- [ ] Race: backmarker stuck in front of you at the same pace, `drapeau bleu: … laisse passer le joueur` (blue flag: … lets the player through); otherwise the reason logged.
- [ ] Stationary AI alone on track under a local yellow flag: cleared in 8 s, or 3 s if broken (`depannee a son stand (cassee, … )`, i.e. recovered to its pit box, broken), with no `arret aux stands` (pit stop) line afterwards.
- [ ] Chosen neutralisation (VSC, FCY, Safety Car): `neutralisation: …` in the log before `depannee a son stand`; several cars stopped on track: red flag or escalation as in Beta 1.23.
- [ ] Under a yellow flag, neutralisation or red flag: no AI yields, no `drapeau bleu` (blue flag) line.
- [ ] WHK Macca V8 1.2: `pneus poses` (tyres fitted) with an original compound (H, M, S or SS), no more compound 15; repeated stops at the same place gone.
- [ ] RESET SECTION button visible and readable in every settings section.

To check (Beta 1.23):

- [ ] Practice or qualifying with many cars: `sorties des stands etalees … s d ecart, la derniere dans 180 s` (staggered pit exits … s apart, the last one in … s) at most, actual exits close to the planned turn.
- [x] Beta 1.22 seen in game on 30 October: staggered exit in practice (Spa, 48 cars) and bodywork repair in a race.

To check (Beta 1.22):

- [ ] Track day: no AI stopped or crawling after the start; no `sortie des stands etalee` (staggered pit exit) line in the log.
- [ ] Practice and qualifying with at least 10 AI: `sortie des stands: tour prevu a X s, sortie a Y s` (pit exit: turn planned at X s, exit at Y s) lines close together, without `attente annulee` (wait cancelled).
- [ ] Safety Car from the grid stayed in its pit box for the whole session.

To check (Beta 1.21):

- [ ] Track day: `sortie des stands: tour prevu a X s, sortie a Y s` lines close to each other (AI kept in their pit box until their turn).
- [ ] No more cascading yields in a queue (log summary: few simultaneous `cession` (yield) entries).

To check (Beta 1.20):

- [ ] Track day: AI leaving the pits one by one at the start of the session (log `sorties des stands etalees`, staggered pit exits), spaced traffic with no trains.
- [ ] Race: damaged AI repaired at its stop (log `reparations`, repairs), held for the duration of the repair; note whether AC was already repairing on its own.
- [ ] Endurance: end-of-stint stops with refuelling and tyres, native fuel stops between two stints if the tank is small.

To check (Beta 1.19):

- [ ] Content Manager track day declared as qualifying: Track day profile and spacing active.
- [ ] Racing rules tab: titles that display without toggling, only the pills active, stops and Safety Car views, reset.
- [ ] Ferrari 458 Italia Stage 3 added to a race grid: parked in the pits, comes out on an escalated incident.

To check (Beta 1.18):

- [ ] Safety Car escalation in a race (car chosen and on the grid): VSC or FCY, then the Safety Car called on a second incident or a long recovery, pit exit, in-lap and green flag.
- [ ] Mandatory stop and Safety Car toggles: state following the chosen rule set.

To check (Beta 1.17):

- [ ] Racing rules tab: left column (toggle, rule sets, notes) readable without overlap at your window size; settings on the right.

To check (Beta 1.16):

- [ ] FR | EN selector to the right of PANIC: immediate switch of the window, tooltips, flag panel and messages; choice kept on reload.
- [ ] English labels readable at your window size (TRACK DAY in a smaller font in the small profile buttons).

To check (Beta 1.15):

- [ ] Hotlap: only the Rules section is ticked (base rules); panel, flag messages, DRS beep and badge.

To check (Beta 1.14):

- [ ] Banner overlay: readable at your window size, short instruction on one line, pills below only if there are any (screenshot welcome).
- [ ] DRS: beep in hotlap; badge cleared as soon as the flap opens, without coming back at the braking point of the same zone.
- [ ] Overlay settings (Accidents section): opacity down to transparent, permanent display (“TRACK CLEAR”), information duration.

To check (Beta 1.13):

- [ ] Race: a clearly faster AI stuck behind a slower one attempts an overtake within a few seconds (log: `pass` then `clear` or `pass_end`), with no queue frozen for laps.

To check (Beta 1.12):

- [ ] Fuel: in the log of a race with a mandatory stop, `carburant demande` (fuel requested) then `carburant : X L avant l'arrêt, Y L après` (fuel: X L before the stop, Y L after); Y close to the requested amount (otherwise the request is an added amount: report it).
- [ ] Race fuel from the start (F1, GT): `carburant au depart` (fuel at the start) in the log on the grid, and the fuel kept after the start.
- [ ] Red flag in practice or qualifying: AI back in the pits, then staggered restart at the green flag.
- [ ] Driving errors on a track day and in qualifying: rare, never near your car.
- [ ] Hotlap chosen by hand (Automatic profile unticked): still Hotlap after a game restart.
- [ ] Hotlap: starting green flag cleared after 5 s; DRS badge in the panel; `DRS joueur : disponible / indisponible (AC)` (player DRS: available / unavailable) lines in the log.

To check (Beta 1.11):

- [ ] AC's own flags hidden (CSP “Hide race flags”); the panel shows the black flag, the drive-through with the laps remaining, the chequered flag, the last lap and the game's blue flag.
- [ ] Home › To check: “AC’s own flags are shown” item absent once the CSP option is ticked.

To check (Beta 1.10):

- [ ] Hotlap profile: chosen in hotlap (and time attack, drift, drag); Track day is no longer affected.
- [ ] Home: built-in and custom presets (save, load, delete); Diagnostics tab: AI table, log filter, buttons (calibration, headlights, zones, copy).
- [ ] Windows without a title bar: moved by dragging an empty area, resized from the corner.
- [ ] Settings › Rules: Safety Car under the common rules.

To check (Beta 1.9):

- [ ] New window readable at your resolution; tabs, sliders (drag, − and +, right-click), mouse wheel.
- [ ] Input fields (preset name, Safety Car) that accept typing.

To check (Beta 1.8):

- [ ] Start: log `maintien de ligne: … a +x m de la trajectoire` (line hold: … at +x m from the racing line) then `rendu apres … s, ecart mesure … m` (handed back after … s, measured gap … m); a measured gap close to 0 confirms the scale (otherwise it needs correcting); fewer AI cutting from the outside to the inside at the first corner.
- [ ] Illegal overtake under flags: the car passed (AI or you) takes its place back without a sanction.
- [ ] Delta time: lifting off up to about 2 s after the signal (Safety Car called, double yellow board), without a penalty.
- [ ] Track day at Spa: in each `direction_limit`, `voulu` (target before the width bound) and `fige` (frozen) will show whether the cancelled yields come from a bound that collapses in corners (voulu -0.60 logged as +0), from a target frozen near the line, or from real side changes.
- [ ] Race: an AI that yields (blue flag, headlight flash) is passed straight away by the one following it; with you moved at least 2 m aside on a straight, the AI following you passes on the free side (log: `passages sur cession` (passes on yield) and `invitations du joueur` (player invitations) in the per-minute summary).
- [ ] Race: fewer queues behind a slow car, fewer `direction_limit`, fewer abandoned attacks.
- [ ] Crashed AI in the middle of the track: never held on the racing line; when stationary, brought back to its pit box after 20 s, or 8 s since Beta 1.24 when it is alone on track under a local yellow flag (log: `depannee a son stand (en piste, … )`, i.e. recovered to its pit box, on track).
- [ ] Per-minute summary: `hors gestion : …` (not managed) lists the unmanaged AI and their reason.
- [ ] Log of each session: `onglets: … ; regles: …` (sections, rules) line (settings actually active).
- [ ] Race start (Start section ticked): field more spread out at the first braking point, fewer collisions at the first corner; AC's AI still chooses its line on corner entry.
- [ ] Race restarted: the Safety Car stays parked in its pit box (log: a single `garee sans pilote` (parked without a driver) line, not one every 5 s).
- [ ] Log of a busy practice session: each `direction_limit` details the side changes counted (AI state, target side, age) then the refused change.
- [ ] Crashed AI: never `repart apres … s` (rejoins after … s) immediately followed by `arretee` (stopped) for the same accident.
- [ ] Start of a race on a grid placed before the line (Spa): no blue flag on the first straight, no AI pulling over at the start to let a car from behind through; blue flag still shown when a car about to lap you arrives behind.
- [ ] Safety Car: log `voiture de securite: en piste apres … s` (pit exit time), or `restee dans la voie des stands` (stayed in the pit lane) after 90 s (estimated delay; neutralisation finished as an FCY); `rentre ce tour` (in this lap) only once on track, green when it enters the pit lane, at the end of the lap.
- [ ] Log at launch: `compilateur JIT: cache agrandi` (JIT compiler: cache enlarged) line (otherwise `options indisponibles` (options unavailable): the app then drives the cars one by one); diagnostics window: average and maximum time per frame.
- [ ] VSC (F1 rules): “VSC ENDING” on the panel, green flag about a dozen seconds later; no penalty when staying in the green.
- [ ] FCY (GT or Endurance rules): field at the equivalent of 80 km/h, “PIT LANE CLOSED” pill, no AI entering the pits during the FCY.
- [ ] Double yellow: slowdown much milder than in Beta 1.3 (+15%); Endurance: Slow Zone at 80 km/h.
- [ ] Safety Car: at the green, no AI overtakes before the line; nor do you (“No overtaking” pill).
- [ ] Red flag: AI leaving the pits one by one in classification order, restart lap behind the Safety Car (or under FCY/VSC), then green.
- [ ] Giving the position back: the AI you passed when the flag was triggered gets back past when you lift off; retaking a position that an AI gives back to you is not penalised.
- [ ] Restarting a race and going from qualifying to the race: Safety Car and reserves parked in their pit boxes again, none on the grid.
- [ ] F1 2026 rules: AI Overtake Mode on the lap after a detection within one second (end of lap); F1 2025 rules: DRS only.
- [ ] Rules section unticked: DRS never disabled by the app, even on the first lap.

Still to check (Beta 1.3):

- [ ] “Manual” grid: the Safety Car wears the Safety_Car livery (chosen among the Mercedes cars, or applied by the app: log `livree Safety_Car appliquee`, livery applied).

Still to check (Beta 1.2):

- [ ] FCY or VSC triggered at full speed: normal braking, green delta (no penalty); red delta and penalty only when staying too fast.
- [ ] Double yellow (car stopped on track): “!!”, delta reset at the entry; single yellow (car off track): no delta.
- [ ] Overtake while braking for the flag: “GIVE THE POSITION BACK” pill; once given back, nothing.
- [ ] AI in a queue under a yellow flag: no more serial sanctions.
- [ ] Delta beeps audible, closer and closer together near zero.
- [ ] DRS disabled on the first lap (message), allowed afterwards, disabled in the rain; AI opening their DRS (log: `DRS des IA : ouvertures`, AI DRS: openings).
- [ ] AI driving errors (log): reasonable frequency, realistic off-track excursions; Safety Car added to the grid: it comes out on a major incident.
- [ ] “Manual” grid with the Safety Car among the candidates: only one deployed, the others parked in the pits (log: `voiture de securite en reserve`, Safety Car in reserve).

Still to check (Beta 1.1):

- [ ] Racing rules tab, “Safety Car” neutralisation: all installed cars in the list, under their Content Manager name followed by the folder; the filter finds “safety car”.

Still to check (Beta 1.0):

- [ ] Redesigned flag panel: readable at a glance at the default size (620 × 150) and reduced; flag and acronym, green or red delta time, pills; no text cut off.
- [ ] Version “Beta 1.x” at the top of the settings and diagnostics windows and of the flag panel.
- [ ] Red flag: the restart waits for your car in the pit lane; a restart outside the pits is penalised.
- [ ] Race with a mandatory stop: “MANDATORY PIT STOP” reminder when the window opens and towards its end; penalty if the stop is missed.

Still to check (1.8.0):

- [ ] Track day: move 2 to 6 m aside on a straight in front of a following AI; it pulls out on the freed side within 1 to 2 s and does not give the position back straight away; the following AI in a train pass in turn.
- [ ] Pit exit: AI leaving behind you no longer hit you after the limiter line.
- [ ] Yellow zone: approach panel earlier at high speed (“Yellow zone in X m”), then “Incident zone” in the zone; “No overtaking” line at 150 m; braking normally from the panel onwards: no penalty (practice, qualifying, race).
- [ ] Yellow zone in a DRS zone: flag shown with “DRS disabled under flags”, no beep; beep at the end of the flag. AC's native yellow flag picked up by the panel.
- [ ] Multi-class: at the start of a session, an AI still learning its pace overtakes normally (log: successful overtakes).
- [ ] Race: black flag lifted when unloading the app or on restart; disqualified AI still parked after an app reload.
- [ ] 1.7.2: DRS beep loud enough at 200% in cockpit view; DRS badge distinct from the green flag; in the rain, no more tyre changes in a loop (log `pneus adaptes`, tyres adapted).

New in 1.3.0, each relying on a CSP call never observed in game:

- [ ] Yellow zone: an AI stopped on track; the AI slow down gradually to the zone's reference time, do not overtake in the zone, go around the car; lifted 10 s after clearing.
- [ ] Yellow flag on the player's HUD (`overrideRacingFlag`) and message; never over a blue flag; handed back when paused, at the end of the session and on unloading.
- [ ] Stopping crashed AI (`setAIStopCounter`): stop of 3 to 8 s, rejoining with the track clear, never stuck beyond that.
- [ ] AI headlight flash (`headlightsFlash`): visible, and the flashing AI keeps throttle, brake and steering.
- [ ] FCY and VSC on delta time: field slowed, no overtaking, green flag.
- [ ] Safety Car added to the grid: parked (`setAINoInput`) and brought back to the pit box (`teleportCarTo`); on a major incident, field under FCY during the call (10 s) and the run down the pit lane, then a smooth exit into already slowed traffic, single file, coming in, green flag.
- [ ] Mandatory stop in the race: request, stop, new tyres, exit; native refuelling (`isRefueling`, `fuel`) observed; minimum stop time set by hand.
- [ ] Line change forbidden under braking: AI yielding and defending under heavy braking.
- [ ] Update from 1.2.0: “Updated to the current presets” message and sections ticked.
- [x] Session log: file created in `Documents/Assetto Corsa/logs` (race at Spa, 10 cars, 20 October 2026).
- [x] 1.3.3: race at Spa, 10 cars (20 October 2026): 5 `direction_limit` warnings in 4 minutes instead of 69, overtake visible; real yellow zone after an AI spin, 3 AI under yellow flag.
- [x] 1.3.4: per-minute counters recorded (Spa, 10 cars): they revealed 0 successful overtakes for 8 attempted and 15 cancelled, fixed in 1.3.5.
- [x] 1.3.5 (Spa, 25 cars): crashed AI stopped for 6.7 s then rejoined with the track clear; yellow flag to the player then handed back to AC; first successful overtake; pile-up revealing the avoidance/rest flip-flop, fixed in 1.3.6.
- [x] 1.3.6 (practice at Spa, 20 cars): cancellation details recorded; they revealed yields never completed, fixed in 1.3.7. Avoidance in a pile-up not yet observed.
- [x] 1.3.6 (Nordschleife, track day, 13 cars): yellow zones, HUD flag then handed back to AC, crashed AI rejoined; three launches stuck on a manual profile after a click on a profile, fixed in 1.4.0.
- [ ] 1.3.7: `abouties` (completed) yields non-zero in practice; `manœuvres interrompues par blocage` (manoeuvres interrupted by blocking) close to zero; avoidance without flip-flopping during an accident in the pack.
- [x] 1.5.0: flag panel shown in game (Nordschleife, 35 cars); title hidden by the title bar, fixed in 1.5.1.
- [ ] 1.7.0: escalation: “infringements: n / 5” counter on the panel; AC black flag at the 6th infringement; disqualified AI brought back and parked in its pit box (classification, laps).
- [ ] 1.6.0: player penalty (throttle cut) for negative delta time and for overtaking under flags, in the race; check that AC applies it with the race settings used.
- [ ] 1.6.0: no more false incidents at the start of a track day or in a waiting queue (log); neutralisation lifted after 10 minutes at most.
- [x] 1.6.0: DRS beep audible, DRS panel and “No overtaking” line green then red, confirmed in game by the driver (20 October 2026); beep judged too quiet, raised in 1.7.1/1.7.2, green square replaced by a DRS badge.
- [x] 1.6.0 (confirmed by the 1.7.0 logs at Spa, track day, 20 to 24 cars, 20 October 2026: no false stops or avoidance in traffic jams): track day log: number of incidents and of yellow flags to the player clearly down, `arrets ecartes` (stops dismissed) and `bouchons suivis` (jams tracked) counters filled in.
- [ ] 1.6.0: stationary AI recovered to its pit box after 20 s of neutralisation or 90 s without neutralisation (number of laps, position, damage).
- [ ] 1.5.1: flag window invisible while driving with no flag (title bar only on hover); in the dry, no AI on wet tyres (log: `meteo au lancement: sec` (weather at launch: dry), `pneus IA : ... pluie 0` (AI tyres: … wet)); panel title fully visible.
- [ ] 1.5.0: flag panel readable and well placed while driving (yellow, FCY/VSC, Safety Car, blue, green); red flag on a pile-up of at least three cars: AI in the pits, restart behind the Safety Car (or restart lap).
- [ ] 1.5.0: recovery of an AI by `teleportCarTo(..., 'PIT')` during a race, never observed in game: check its lap count, its position in the classification and its damage after the restart.
- [ ] 1.5.0: red flag, all AI called in at the same time (the limit of three simultaneous calls does not apply): check there is no jam in the pit lane.
- [ ] 1.4.0: highlight of the chosen tab and tooltips readable in game; F1 2025, F1 2026, GT and Endurance rules selectable from all profiles; automatic profile kept after a click on a profile; no AI on wet tyres on the grid in the dry (`pneus adaptes a la meteo sur la grille` (tyres adapted to the weather on the grid) lines in the log).

- [ ] Pause/setup menus: automatic opening/closing, diagnostics, changes saved before resuming.
- [ ] First V1 load, rc.1 migration, manual/auto choice and named programme after a full game restart.
- [ ] Track day with 9, 40 and 50 AI: evolution of the intervals, no sudden braking, corners and pit exits; short and long track; disabling/restoring the cap.

- [ ] Nordschleife, track day, 30+ AI, 30 minutes: yielding on the correct side, overtaking on the opposite side, trains and returns without causing a collision.
- [ ] 1.1: diagnostic “Offset / side sign” at −1 / −1 in AC; Yield side = Right moves the AI to the driver's right; Overtaking side = Left makes it pass on the left.
- [ ] 1.2: Content Manager modes Track Day, Practice, Weekend and Race; “Session detected” line and expected profile at every session.
- [ ] 1.1: rain with the Weather section, actual stop at the pit box and compound change; garage during practice; practice/qualifying/race weekend with the preset recognised at every session.
- [ ] Pit entry with line bias active: alignment in the pit lane (offset not reset to zero in the pits, rule D12).
- [ ] Headlight flashes: large pace difference, small difference, three recipients, corner, side by side and hold >4 s.
- [ ] 110% mode actually read, cap if clipping, additional grip/brake only after explicit activation.
- [ ] Qualifying: flying lap, several slow AI, lap start/end.
- [ ] 20-car race: start, overtake preparation, defending and blue flags.
- [ ] 3 h endurance, LMP1/LMP3, rain/Pure, pit stops, cars one and several laps down.
- [ ] Triple 4K screens and debug window open: average and maximum native measurement, real CSP cost.
- [ ] Reload during a manoeuvre; deactivation while a side is occupied; check of the delayed return.

These boxes stay open until actually observed. The current version is Beta 1.29; the automated tests are not enough to certify all the physics and FPS criteria of the PDR.
