# J0 — Local API, HumanAI engine in ACAdvancedIA

Installation inspected: CSP 0.3.0-preview675, build 4210, 19 October 2026.
Local source: `extension/internal/lua-sdk/ac_apps/lib.lua` and `README.md`, generated and shipped with CSP. No separate `ac_physics_ai.lua` is provided in this installation: its definitions are built into `lib.lua`.

## Signatures checked before the behaviour code

| Function/field | Contract actually documented | Decision |
|---|---|---|
| `physics.setAISplineOffset(index, offset, overrideAiAwareness?)` | Normalised −1 left, +1 right; limited by the track width; boolean third argument, false by default. Lines 15230–15235. | Use the normalised value, never metres. Calibration before the automatic manoeuvres. |
| `physics.setAISplineAbsoluteOffset(index, offsetMeters, overrideAiAwareness?)` | Value in metres; negative left. | Not used. |
| `physics.setAILevel(index, level)` | Setter range **0–2**, line 15130; the `aiLevel` field states 0–1, line 5043. | The SDK does not prove read-back beyond 1. Native probe at 1.05, deferred read-back, restoration; otherwise cap at 1. No invented runtime result. |
| `physics.setAIAggression(index, aggression)` | 0–1; 100% in the launcher corresponds to 0.95. | Cap applied: 0.95. |
| `physics.setAICaution(index, caution)` | 0–16, default 1, experimental. | Command values bounded 0.5–16. No getter for the initial caution. |
| `physics.setAIBrakeHint(index, value)` | Replaces `ai.ini/[PEDALS]/BRAKE_HINT`, default 1; line 15207. | This is not a braking distance/zone contract. Do not present this hint as a native zone function. D7 emulation. |
| `physics.setExtraAIGrip(index, value)` | **1 = normal grip**, “120% by default”, lines 15251–15254. | Ratio unit confirmed by the SDK, not by experiment. Bonus disabled by default; documented base 1.2 if explicitly enabled. |
| `ac.overrideCarControls(index)` | Returns `ac.CarControlsInput?`, line 15783. Final `brake` = maximum of the native and the imposed brake; line 18269. | Extra braking only, option disabled by default. No throttle imposed. |
| `physics.preventAIFromRetiring(index)` | It has to be repeated to prevent retirement durably. | Non-critical option, disabled by default. |
| `physics.allowed()` | Access boolean; function exposed as **callable cdata** in a real session of this installation. | Accept C functions and non-null function pointers; do not treat every `cdata` as a function. |
| `ac.getCar(index)` | 0-based; the player is normally 0 in single player. | Also exclude **all** `isUserControlled` vehicles; detect a player at a non-zero index. Never any command to the player, to a remote car or to a vehicle without local physics. |
| `position`, `look`, `side`, `velocity`, `aabbSize` | Vectors; position in metres, velocity in m/s; `side` is only described as “sideways”. | Do not assume that `side` means left. Canonical left basis derived from the heading, check of its sign and relative calibration on a safe pair. |
| `speedKmh`, `splinePosition`, `lapCount` | km/h; progress 0–1; laps completed. | Conversion to m/s, numeric validation; lapped-car logic disabled if laps/length are unavailable; no lap gained by a car that has not completed any (grid before the line: crossing the line at the start does not complete one). |
| `gas`, `brake` | 0–1, lines 5003–5004. | Direct reading validated. |
| `isInPit`, `isInPitlane`, `wheelsOutside` | Booleans and number of wheels outside the limits. | No command or target in the pits; off track, not driven. |
| `highBeams` | **High beams on or headlight flash**, line 5089. | First documented candidate. Learning through real transitions; no false availability if no signal is observed. |
| `headlightsActive`, `lowBeams`, `hornActive`, `flashingLightsActive` | Documented on lines 5069–5089; `lowBeams` represents the switch, not necessarily a pulse. | Calibration candidates; horn optional. |
| `ac.getSim()` | `carsCount`, `raceSessionType`, `isOnlineRace`, `isPaused`, `isReplayActive`, `isReplayOnlyMode`. | Inert online, including alt-online, according to the PDR. |
| `timeToSessionStart`, `currentSessionTime`, `sessionTimeLeft` | **Milliseconds**, not seconds. | Conversion /1000 in snapshot only. |
| `trackLengthM` | Metres, from the AI spline. | Zero length: no lateral manoeuvre; short geometry available for a cautious diagnosis. |
| `isSessionFinished`, `isRaceFinished` | Session finished / car finished. | New manoeuvres stopped. |
| `rainIntensity`, `rainWetness`, `rainWater`, `timeHours` | Documented SimState fields. | Optional weather adaptation, validated data, no dependency on Pure. |
| `ac.getTrackAISplineSides(progress)` | Returns `vec2`, x left, y right, distances in metres. | Width and safety bound; protected read. |
| `ac.storage(layout, prefix)` | Native persistence, prefix available. | Prefixes `humanai:g:` and `humanai:p:<profile>:`; grouped writes, not during a replay. |
| `ac.onRelease(callback)`, `ac.onSessionStart(callback)` | Unload / session change callback. | Single registration, protected callbacks. |

## Manifest checked

The local apps and the SDK use `[CORE] LAZY`, `[WINDOW_...] FUNCTION_MAIN` and allow `[SIM_CALLBACKS] UPDATE`. The names refer to **methods of the CSP `script` table**, not free Lua globals. Since rc.3, the automatic `script.update` callback is the only update entry point; the manifest declares no SIM_CALLBACKS; since Beta 1.25, only `[UI_CALLBACKS] IN_GAME=HUMANAI__HUD` draws the in-game overlay (a `ui.transparentWindow` window, like SuperHUD), without updating the engine. AC's session box: `ac.disableExtraHUDElements('sessionTime')`, given back on unload; AC's messages: `ac.onMessage`, optional hiding with `ac.blockSystemMessages('.')`; CSP Disposables are functions to be called. The windows keep their `script.HUMANAI__...` methods; only the authorised global table `HUMANAI` is added. The ACAdvancedIA name and folder are kept in line with Vincent's explicit choice; the engine and the modules follow the HumanAI PDR.

## Runtime results and no invented signatures

- Already observed in game on the original Spa: `physics.allowed()` callable cdata, access true without modifying `surfaces.ini`.
- Level >100%, offset sign, headlight fields and extra braking: **not declared validated in driving**. They are probed/calibrated with safeguards and shown as “pending” as long as the necessary conditions are not met.
- There is no documented getter for the current offset or the current grip. It would be wrong to claim to probe them without risk: initial offset assumed to be 0 only when the app takes over alone; grip not probed by writing as long as its option is not enabled.
- Sign calibration requires a pair outside the pits, travelling in the same direction, isolated, and a straight; it is abandoned if a side becomes occupied. No test movement in the pits or near the player.
- The level is probe-tested with a current value before the deferred 1.05 attempt; it immediately returns to the initial value if the attempt fails.
- Unconfirmed capabilities remain disabled, with their reason. Speed/throttle limits are not used as the main mechanism.

## Cautious resolutions of the PDR's contradictions

1. D2: the core never touches CSP. `snapshot` reads, `applier` writes and hosts the lifecycle/storage ports; `caps` only receives these ports, never the `ac`/`physics` globals.
2. D12 takes precedence over the generic IDLE transition: on entering the pits, no offset command, not even a reset to zero. A pending reset to zero is carried out at the controllable exit. Beta 1.41 exception: the pit exit hold through the native stop counter (see *Beta 1.41: pit exit merge*).
3. D18 and §10.13: zones use a table parser **without code execution**, without `load`/`loadstring`. Only a bounded local read of a data file from the `tracks` subfolder, via the snapshot port; no disk writes, no network access.
4. D7 and §14.1: zone shown with its mode; in emulation mode the control carries the requested explanation. No fake native function is created.
5. Calibrations: if the observation is inconclusive, no behavioural lateral offset; the available longitudinal modulators remain usable.

## J0 review

Defects avoided: confusion between metres and normalised offset; start time in seconds instead of ms; `side` assumed to be left; grip 120 instead of 1.2; `BRAKE_HINT` wrongly presented as a distance; native cdata function rejected; command to an alternative player or in the pits. The presence of the signatures is established locally; the dynamic validations remain honestly shown by the CSP capabilities panel.

## Additions checked during J1–J8

- The [official CSP wiki, Lua apps](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/wiki/Lua-apps) confirms `[SIM_CALLBACKS] UPDATE=fn` → `script.fn(dt)` and the automatic `script.update` callback, even with no window open. Since rc.3, only the latter calls `HUMANAI__UPDATE`; no SIM_CALLBACKS/UI_CALLBACKS callback is registered. Integration checks a single timer step per frame and opening in setup without a HUD.
- `ac.readDataFile(filename)` (SDK line 3189) reads a text; it is used only for the internal path `tracks/<trackId>.lua`, with a filtered identifier. The text is rejected beyond 64 KiB, then parsed without execution. The limit is checked after this API returns: the SDK offers no partial read without using the I/O APIs forbidden by the PDR.
- `ac.getPatchVersion()` and `ac.getPatchVersionCode()` are documented on lines 3041–3045; the version string is shown in the debug panel.
- `ac.Disposable` is a **function to be called**, line 5609, and not an object with a supposed `dispose` method. Callbacks are therefore unsubscribed with `pcall(token)` if they are callable.
- `ac.perfBegin/End` exist, lines 3353–3363, and feed Lua App Debug, without returning a duration to the script. For the figures shown in the app's own window, the adapter optionally probes `QueryPerformanceCounter/Frequency` via the FFI already provided by LuaJIT. [Windows QPC contract](https://learn.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter). Read-only counter, reused int64 buffer, no DLL loading and no `os.*` access. Three failures suspend this measurement. The branch works on the Windows bench; its availability in the CSP sandbox will be shown in game.
- `ui.sameLine`, `ui.newLine`, `ui.availableSpaceX` (line 13125) and `ui.measureText` (13934) make the requested **horizontal** bar possible. Wrapping depends on the real width; a three-column fallback exists if the measurements are not exposed.
- The signs are measured in the frame of the **reference car**, so that counter-steering by the moved car cannot invert the result. Start only on a straight and in the DRIVE state; monitored hold, safe abandonment and deferred reset to zero if necessary.
- A model/driver identity is encoded in bounded hexadecimal for recovery; no string is executed. A replaced identity never inherits a restoration intended for the previous one.

## Further resolutions recorded

- The D14 occupancy priority also prevails during a stop, an error and a calibration. A dangerous reset to zero waits; it is never forced through a vehicle. Likewise, no command is sent online/in replay to attempt a restoration: it waits for a controllable local context to return.
- Zone sizes reduce a **target**; if a new limit is below the current lateral offset, the return stays ramped and subject to occupancy. A newly reduced bound does not cause a lateral jump.
- The PDR gives two forms of zones. The normative form `return { zones = {...} }` and the direct list are both accepted; the export produces the normative form.
- The braking slider remains usable in explicitly “emulated” mode, in accordance with D7; no native distance function is simulated in the panel. This favours D7 over the contradictory request in §14.1 to grey out that same slider.
- Class mappings are edited as eight rows and stored as validated text (`pattern:class`). This primitive representation suits `ac.storage` and avoids any serialisation of Lua code.
- In Track day, even with the Endurance layer, the explicit §10.17 rule excluding lap-based ranking is kept; classes and stints remain active.
- A known app window does not prove that its controller is active. The banner therefore reports the detection with “check what it does”, rather than as a certain detection of competing writes.

The real observations of this new version remain separate from the simulated tests. The assessment and the criteria not met are in `VALIDATION.md` and `tests/soak-results.json`.


## Adaptive interface and observed loading

`ui.selectable(label, selected, flags, size)` expects a size (SDK line 14169), not just a width. The numeric size sent initially produced squares, seen on the user's screenshot of 19 October at 17:25. The tabs now pass a **vec2**, obtained through `ui.measureText`, with `x = text width + 16` and `y = 0` to keep the native height of one line. They have a native selected state and wrap according to the available space. The UI function probes accept Lua functions and `cdata` C functions; their initial rejection could force the three-column fallback despite the space available. The bench covers these native calls, three widths and a doubled font scale.

No tab title uses `ui.checkbox`. Since rc.2, the checkbox below the title controls the real activation of the section and the display of its settings. `ui.setNextItemWidth(-1)` and the `##` slider identifiers allow separate labels and the full available width; `ui.textWrapped` adapts long texts.

The local CSP log consulted on 19 October 2026 confirms the loading of the app, two declared windows and several successful reloads. This observation does not validate the physical movements or the native probes.

## rc.2 extension requested by the user

- `ac.INIConfig.raceConfig()` is documented on line 7099: read-only configuration, without password or online GUID. The app reads only `SESSION_<currentSessionIndex>/TYPE` with `config:get(..., 0)`, protected by `pcall`, at the metadata rate and immediately on a session change. If the type is valid, it takes precedence over `raceSessionType` to choose J/Q/C; otherwise fallback to CSP. The free-text session name is not used. Re-enabling automatic cancels the manual lock; clicking one of the three buttons disables automatic.
- `physics.setAITopSpeed(index, limit)` is documented on line 15223 in **km/h**; `1e9` removes the limit. No getter for the initial cap: another app imposing a cap cannot be restored identically. The `speed` capability is optional and follows the same stop after three failures as the other setters.
- Spacing is opt-in and limited to J. Count of the AI cars present/on track, target bounded by length/field size then varied by hash, recalculated every 0.5 s. The speed reduction is progressive, at most 4 km/h/s, with restoration when the behaviour ends. Cars are not teleported. The `ac.store` recovery adds a modified-cap flag; old records without this flag remain readable.
- The rc.3 windows use `SETUP`, `GROUP=SETTINGS` and the setup background. Their opening is synchronised from `script.update` with `isPaused`/`isInMainMenu`; the content also checks the context before drawing. This fixes the missing panel in setup with the old UI callback and SETUP_HIDDEN. `ac.setWindowOpen` and `ac.isWindowOpen` are protected. A button in the panel opens the diagnostics. The engine continues regardless of visibility. The user confirmed the display after this fix.
- The schema version moves to 2. The primitive keys `section_<group>` are all false on first load; a migration keeps the values but initialises these keys to false. The calculation builds effective parameters without overwriting the prepared values. General disabled uses the known native references; inactive movement settings use the internal safety bounds for the manoeuvres of the sections still active. If all sections are inactive, the core returns `nosections` before any command, probe or calibration.
- The 16 custom presets are kept in separate bounded `ac.storage` spaces. Names non-empty, without control characters, 64 bytes maximum; profile and fields validated with the same schema. The last write validates the name. No code parser, Lua loading or writing to a track. The calibration options and the recovery data are not preset settings.

Since rc.3, explicitly loading a built-in preset enables its recommended sections and their sub-options. Profile creation stays neutral; custom presets restore their exact checkboxes. BUILTIN_PRESET_ACTIVATIONS and integration check this distinction, the checkboxes shown and the highlighting.

## rc.4 review

The [official `ui.combo` code](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/blob/main/common/ac_ui.lua) uses the indices of the Lua array provided directly. The subtraction/addition of 1 has been removed; the app's lists start at 1. The bench checks each choice and its preview, including the last entry, Automatic. False booleans are preserved by `C.effective` thanks to an explicit branch. The controls use distinct `###setting_<key>` identifiers. The new temporary identities and the failed restorations are described in [AUDIT_RC4.md](AUDIT_RC4.md).

## V1: weather API and call cost

Flags (1.5.0): `ac.FlagType.SessionSuspended` (red flag) is documented as “does not work yet”; the flag panel is an app window (`[WINDOW_2]`, FLAGS=MAIN,NO_BACKGROUND) drawn with `ui.drawRectFilled`, `ui.textColored` and `ui.pushFont(ui.Font.Title)`, without DirectWrite. `ac.setWindowOpen('flags', true)` opens it when a flag appears. Recovery of stranded cars under the red flag uses `physics.teleportCarTo(index, 'PIT')`, already used for the Safety Car.

Local SDK `ac_apps/lib.lua`: `setAIRainTyres(carIndex, boolean)` line 15285; `setAIPitStopRequest(carIndex, boolean)` line 15259; `setAITyres(carIndex, compoundIndex)` line 15269. The latter also resets tyre damage: called only in the pits (when stopped, and since 1.7.0 also while driving in the pit lane), and since 1.4.0 when stopped on the grid before the start (session not started or countdown in progress) or in the first 15 seconds of a session, to correct a compound unsuited to the conditions. `setTyresCompound` is not used. Catalogue through `getTyresName`/`getTyresLongName`, 0-based indices, at most 32 entries and two new catalogues per frame. `compoundIndex` and `isAIUsingRainTyres` are documented on lines 5148 and 5046.

The weather compensation does not stack with a confirmed native wet tyre. The grip setter is centralised to combine, if they are allowed, the >100% bonus and the weather compensation. The recovery fields include the original rain state and the pit requests, with reading compatible with the old formats. No driving setter is allowed in the pits; only the explicitly requested weather service operations are an exception.

Numeric and boolean setters receive two arguments; only the offset receives the documented third boolean. NATIVE_SETTER_ARITY checks this distinction with real C FFI functions. The core draws no GPU content; the windows remain limited to the menus. The native counter times the update and the adapters, excluding UI drawing.

## 1.1.0: contracts re-checked

- `physics.setAISplineOffset`: −1 full left, +1 full right (line 15233). In AC, +X is the left of a car looking towards +Z: `DRIVEREYES.x > 0` on the installed left-hand-drive cars. The internal lateral basis `(-look.z, look.x)` therefore points right there, and the calibration measures `offsetSign = −1`. Occupancy remains expressed in this internal basis, which keeps it consistent with the calibrated sign. Only the sides chosen in the interface are converted from the SDK convention. The test host exists in a left-handed frame and in a right-handed frame.
- `physics.setAIPitStopRequest(index, false)` also blocks the pits for a while since 0.3.0-preview147 (line 15256). The weather request therefore stays true in the pit lane, and `false` is only sent outside it, except on unload.
- `physics.setAIRainTyres` overrides the default behaviour (line 15282). It is only called if the native `isAIUsingRainTyres` state differs from the decision or if the app has already taken over.
- `ac.CarControlsInput` (line 18245): `steer = math.huge` keeps the steering; `gas`, `brake` and `handbrake` take the maximum with the original value; `clutch` takes the minimum. `requestedGearIndex = 0` and `mguhMode = −1` keep the existing state. The app writes these neutral values with every extra-braking command.
- `ac.SimState.isPaused` (5346) and `isInMainMenu` (5347) are distinct. The setup/garage menu does not stop the session: it opens the windows without freezing the engine.
- `ac.onSessionStart(callback)` (3818) also reports a restart at the same index. The tracked writes are then resynchronised.
- `ac.INIConfig.raceConfig()` (7099): `race.ini` is re-read on session change, or after a read failure. `SESSION_<n>/TYPE` values: 1 practice, 2 qualifying, 3 race, 4 hotlap, 5 time attack, 6 drift, 7 drag, as in `ac.SessionType`.

## 1.2.0: Content Manager modes

- The `race.ini` files from the installation's CSP crash archives (78 launches) give three signatures: Track day = one session `NAME=Track Day`, `TYPE=1` (49); Practice = one session `NAME=Practice`, `TYPE=1` (7); Weekend = `Practice`/1, `Qualifying`/2, `Race`/3 (22). The Content Manager logs confirm `Mode=TrackdayProperties` and “Track Day” sessions.
- `snapshot` therefore reads `SESSION_<n>/NAME` in addition to `TYPE`, once per session. A name containing `trackday` (case and punctuation ignored) designates Track day; any other declared practice session uses the Practice profile. Without a readable `race.ini`, the CSP type alone keeps the old Track day choice for practice.

## 1.3.0: accidents, rules, Safety Car

All these functions are in the local SDK (CSP 0.3.0-preview675); none has been observed in game yet.

- `ac.StateSim.raceFlagType` / `raceFlagCause`: the player's native flag. `physics.overrideRacingFlag(ac.FlagType.Caution)` imposes it, `ac.FlagType.None` hands control back to AC. The app only imposes it when there is no native flag or over its own, and gives it back on every exit (stop, panic, session, unload, resumption after a reload through the `;F` header of the resume point).
- `physics.setAIStopCounter(index, s)`: “makes the AI brake for a given time, the mechanism AC uses after an incident”; 1.5 s pulses renewed every 0.5 s, then 0 to release. If the app cuts out, the car is therefore released by itself.
- `physics.setAITopSpeed`: yellow zone, FCY, VSC and the queue behind the Safety Car, combined with Spacing (minimum of the two) in the applier.
- `ac.overrideCarControls(index).headlightsFlash`: an AI car's headlight flash (one frame); all the other fields receive the documented neutral values (`combineAxis=true`, `steer=math.huge`, pedals 0/1, gear 0, MGU-H −1, KERS −1).
- `ac.setTurningLights(mode)` has no car index: in an app, it acts on the player's car; `ac.CarControlsInput` has no indicator field. The AI cars' indicators cannot be controlled.
- `physics.setAINoInput(index, true)` parks the Safety Car (“parked”), `physics.teleportCarTo(index, 'PIT')` brings it back to its pit box once if it is on track.
- `io.scanDir(ac.getFolder(ac.FolderID.ContentCars), '*', callback)` lists the car database; the attributes are an FFI structure (`isDirectory`), not a Lua table.
- `ac.StateSim.pitWindowStartTime` / `pitWindowEndTime` (declared window), `time`, `leaderLapCount`, and `ac.getSession(i).laps` / `durationMinutes` / `isTimedRace` give the progress of the race. `ac.StateCar.collidedWith` (≥ 0 when in contact) is used to recognise an accident.
- The `ac.getSim()` and `ac.getCar()` structures are cdata: reading an undeclared member throws an error in the game, invisible with the test host's Lua tables. The fields read are therefore checked by the lint against `tests/sdk-fields.json`, extracted from the installed SDK, and new reads have their own `pcall`.

## Beta 1.2 to 1.4: DRS, driving mistakes, Safety Car, compiler

- `physics.allowCarDRS(index, disable)` (`true` = DRS forbidden; marked deprecated in the SDK, with no documented replacement) disables DRS according to the racing rules, player included, and gives it back: at the end of the rule, tab unticked, app disabled with no car tracked, unload, and on reload after an abrupt stop (`;D` marker of the resume data). `physics.setCarDRS(index, active)` opens or closes an AI car's DRS (one opening per second at most, closing immediately under braking).
- `physics.setAIBrakeMistake(index, duration)` and `physics.setAITractionMistake(index, duration, severity)`: AI driving mistakes, written once per decision, to an AI car on track whether it is commanded or not (nothing to give back).
- `ac.getCarSkinID(index)` (livery folder), `ac.findNodes('carRoot:'..index):applySkin(folder)` (since CSP 0.3.0): “safety” livery applied to the Safety Car when it does not already wear it, original livery reapplied when it stops being the Safety Car and on unload.
- `ac.StateCar.racePosition` (1 = first, 0 if unknown): pit exit order at the resumption after a red flag.
- `jit.opt.start('maxtrace=8000','maxmcode=16384')` in the entry file: enlarged JIT compiler cache (with the default 1,000 traces and 512 KB, the engine recompiled all its code every one to two minutes). No effect on decisions; if it is refused, the app drives the cars one by one as before and the log says so.

## Beta 1.35: update staged outside the app folder

- CSP reloads an app when a file of its folder changes, so nothing is written there before the final copy. Work folder: `ac.getFolder(ac.FolderID.ExtCfgState)` (25, `Documents/Assetto Corsa/cfg/extension/state`, no live reload), subfolder `ACAdvancedIA-update` (`next`, `current`, `backup`, `installing.txt`, `updated.txt`).
- `io.extractFromZipAsync(data, folder, {crucial = 'apps/lua/ACAdvancedIA/manifest.ini'}, callback)` unpacks into `next`; `io.scanDir(folder, '*', callback(name, attributes))` lists files (`attributes.isDirectory`).
- `io.copyFile(existing, new, false)` copies (overwrite allowed). `io.move` is MoveFileEx without copy: it fails between drives (Steam on D:, Documents on C:), hence copies for everything that crosses into the app folder.
- `ac.pauseFilesWatching(true)` suspends CSP's file watching for a few seconds; the final copy runs synchronously in one frame, re-asserts the pause before each changed file and resumes watching at the end.
- `io.deleteDir` removes an empty folder only; the updater empties a folder, then removes its sub-folders deepest first, then the folder itself, so that `io.move` of a whole folder (the kept version) never meets an existing, empty destination (Beta 1.36).
- A module whose loading failed cannot be required again (LuaJIT: *loop or previous error loading module*); the main script stores its stand-in for `src/update` in `package.loaded`, so the interface's own `require` gets it (Beta 1.36).
- The recovery runs at the very top of `ACAdvancedIA.lua`, under `pcall`, before any other module is required; when it copied files it asks one `ac.restartApp()` on the first frame, before the engine drives anything.
- GitHub answers 403 or 429 when the unauthenticated request limit (60 per hour) is reached.
- Atomic replacement: each file is copied to `<destination>.new` in the destination folder, then `io.move(tmp, destination, true)` renames it (same volume, so a rename). Kept versions are swapped by renaming folders.
- Boot sentinel `boot.txt` (version, tries) in the work folder: written by a fresh install, counted at each start before the other modules load, removed after the first successful `script.update`; two failed starts roll back to `backup`.
- Settings: a store whose `schemaVersion` is newer than the app's is no longer replaced by the defaults; each known key is validated and the higher version is kept on save, so a roll back keeps them.

## Beta 1.34: standing restarts, AC's start flag, capability failures

- `ac.StateSim.raceFlagType` can stay at `ac.FlagType.Start` (1) for a long time (the whole session in hotlap; observed by the app's own panel code). Beta 1.32 only wrote `physics.overrideRacingFlag` over 0 or AC's yellow, so a held start flag blocked the track light panels without a trace. The start flag now counts as free; blue (12), white (14), chequered (13), black (5) and penalty (8) are still never covered.
- `pcall` returns CSP's error text on a failed call: the capability layer keeps it (160 characters) and the log shows the first failure of each function and its disabling after three failures.
- Grid slots: `ac.findNodes('AC_START_<k>')` (local SDK, line 10789), `SceneReference:size()` (10008), `:getWorldTransformationRaw()` (10289, `nil` without a node) and its `.position`, then `ac.worldCoordinateToTrack(v)` (3135): X is the normalised lateral position (-1 left, +1 right), Z the track progress. Read once per track under `pcall`; any failure falls back to computed slots.
- Standing start actuators, all already used by the app: `physics.setAIStopCounter` pulses (hold), `physics.setAITopSpeed` (approach cap), `ac.overrideCarControls(i).brake` (assist brake, final brake = max(native, imposed)), `physics.setAISplineOffset` (column), `physics.awakeCar` and `physics.setAITimeToStart(i,0)` at lights out. No teleport (`physics.teleportCarTo` with `START` would use each car's original slot and its timing behaviour is unknown). The gantry lights cannot be driven: no track condition input exists for them, so the lights are drawn by the overlay.

## Beta 1.33: update from GitHub

- Network: `web.get(url, headers, callback(err, response))` (local SDK, line 8018), at most two requests at once, default timeouts 30 s; `response.status`, `response.body` (binary-safe). No progress callback: the size shown comes from the release's asset size. `api.github.com` needs a `User-Agent` header; `releases/latest` answers 404 while nothing is published (shown as *No release published yet*). `browser_download_url` redirects to GitHub's storage; the redirect is followed.
- `JSON.parse(text)` (line 8201) decodes the release; `ac.checksumSHA256(data)` (line 3290) gives the digest as text (32 raw bytes also accepted).
- Zips: `io.scanZip(data)` lists entries, `io.loadFromZip(data, entry)` reads the package manifest, `io.createZipAsync(filename, entries, callback)` writes the backup (entries `{filename = …}`), `io.extractFromZipAsync(data or filename, destination, {crucial = …}, callback)` unpacks (since 0.2.10 the crucial entry is extracted last under a temporary name and its absence is an error).
- Files: all writes stay in the app folder, `ac.getFolder(ac.FolderID.ScriptOrigin)` (1024). The package is unpacked into `backup/next`, then `io.move(from, to, true)` (line 4375) replaces each changed file, `manifest.ini` last; `io.createFileDir` creates new folders. A copied app folder holding `manifest.ini` would be loaded by CSP as a second app, hence a zip for the backup.
- `ac.restartApp()` (line 16244) reloads the app on the next frame; the app releases everything first (the same full release as on unload). `os.openURL(url)` (line 4669) opens the release page (https only).

## Beta 1.32: track light panels and the player's FIA signals

- Track configurations (the track's `extension/ext_config.ini`, CSP's `extension/config/tracks/loaded/<track>.ini`) define conditions `[CONDITION_…] NAME=… INPUT=FLAG_TYPE` with a LUT from the flag value to a colour. The usual LUT: 1 green, 2 yellow, 3 orange, 4 orange-red, 5 red, 6 grey-white, 12 blue, 13 off or red, 14 white. Materials and light series light up through `CONDITION=<name>`. CSP's shared `common/conditions.ini` defines `RACING_FLAG` on `FLAG_TYPE`, so a track that includes it may light sections with `CONDITION=RACING_FLAG` only (Sepang, Vallelunga).
- `FLAG_TYPE` is the player's flag. `physics.overrideRacingFlag(flag)` (local SDK, line 15002) overrides it until `ac.FlagType.None`; the SDK note on `ui.drawRaceFlag` says it "would also affect track conditions". `ac.FlagType` 3, 4, 6, 7, 9, 10, 11, 15 and 16 are marked *does not work yet* (AC's own display); 5 (`Stop`) is AC's black flag there.
- `ac.StateSim.raceFlagType` returns the overridden value: the main loop marks the frame (`flagOwned`) and the panel never reads its own value as an AC flag; AC penalties (`currentPenaltyType`) are still read.
- Files: `ac.getFolder(ac.FolderID.ContentTracks)` (15), `ac.FolderID.ExtCfgSys` (17), `ac.getTrackID()`, `ac.getTrackLayout()` (line 3208, empty without a layout), `io.load`. Track identifiers with `..` or other characters are not read.
- Player damage (black flag with an orange disc): `ac.StateCar.damage` (five zones, km/h of impact), `suspensionDamage` (0–1), `engineLifeLeft` (1000 new, breaks at 0), `gearboxDamage` (0–1), `wheels[i].isBlown`, `ac.StateSim.mechanicalDamageRate` (0: damage off). Read once a second under protection, apart from the AI's (read only at their pit box).

## 1.6.0 to 1.8.0: penalties, DRS, sanctions

- `physics.setCarPenalty(type, parameter)`: `ac.PenaltyType.SlowDown` (3, throttle cut for the given number of seconds; only with race settings that allow it), `BlackFlag` (4, no parameter), `ReleaseBlackFlag` (5, no parameter): the black flag is lifted on unload, on deactivation and on session change, and imposed again after an app reload.
- `ac.AudioEvent.fromFile({filename, use3D=false, loop=false}, false)` plays the DRS beep; `cameraInteriorMultiplier` is 0.25 by default (app sound reduced in cockpit view): the three camera multipliers are set to 1, `volume` follows the setting (25 to 400%) and `setVolumeChannel(ac.AudioChannel.Main)` ties it to the master volume. The previous event is released (`dispose`) at each beep and on unload.
- `ac.StateCar.drsPresent`, `drsAvailable`, `drsActive`: AC's DRS, read for the beep and the panel badge (and, since Beta 1.2, for the DRS rules and the AI DRS, below).
- `physics.teleportCarTo(index, 'PIT')` (`ac.SpawnSet.Pits`) without `preserveDamage`: the car brought back to its pit box is repaired (stranded AI car recovered, disqualified AI car, Safety Car).
- Deliberate deviation from the PDR: contact detection through a yaw jump (additional criterion) was removed in 1.8.0; on a smoothed yaw, it could not trigger. Contact is still recognised by the sharp loss of speed near a car.

## Beta 1.40: CSP display options (gui.ini)

- `ac.blockSystemMessages('.')` does not hide AC's own top banner (*CUT DETECTED: LAP WILL NOT COUNT*): it was still drawn in Beta 1.39 while `ac.onMessage` received it. CSP's `[HIDE] HIDE_SYSTEM_MESSAGES` (*Hide system messages (like ABS)*, `extension/config/gui.ini`) is the switch for that display; `HIDE_RACE_FLAGS` hides AC's flags.
- User file: `ac.getFolder(ac.FolderID.ExtCfgUser)` + `gui.ini` (written by Content Manager; absent until something is changed). Applied values: `ac.INIConfig.cspModule(ac.CSPModuleID.GUI):get('HIDE', key, false)`. `ac.onCSPConfigChanged(ac.CSPModuleID.GUI, fn)` reports a re-read. Whether CSP applies a changed `[HIDE]` key live is **not confirmed** on CSP 0.3.2-preview2: the app handles both cases.
- Between the app's write and a re-read by CSP, the applied value is the one read at the first app start of the game process (kept in `ac.store('humanai:cspgui')`, which survives app reloads but not a game restart), never the file's.
- State file outside the update work folder: `ac.FolderID.ExtCfgState` + `ACAdvancedIA-cspgui.ini`. It holds `v1`, one line per held key (`KEY=original` or `KEY` when absent), then `original <bytes>` and `written <bytes>` blocks (`-` when the file did not exist). The updater's clean-up only touches `ACAdvancedIA-update/`.
- Writes use `io.save(path, data, true)`; the `.bak` CSP's safe replacement leaves is deleted after each write, as for `new_behaviour.ini`.

## Beta 1.41: AC's cut and penalty banners

- With CSP's `[HIDE] HIDE_SYSTEM_MESSAGES=1` applied (re-read live) and `ac.blockSystemMessages('.')` active, AC still draws its red banners *CUT DETECTED* / *LAP WILL NOT COUNT* and *PENALTY, SLOW DOWN FOR n SECONDS OR SLOW DOWN TO 35 KMH* / *BEFORE THE END OF CURRENT LAP* (Beta 1.40 sessions, 3 November), and they also reach `ac.onMessage`. No documented CSP option or function hides them (gui.ini defaults, `lib.lua`).
- AC's own texts (UTF-16 strings in `acs.exe`): `CUT DETECTED`, `LAP WILL NOT COUNT`, `PENALTY, SLOW DOWN FOR`, `OR SLOW DOWN TO`, `BEFORE THE END OF CURRENT LAP`, `DRIVE THROUGH PENALTY`, `Jump-start: Drive-through`, `DISQUALIFIED`, `You have been disqualified for not clearing the … penalty`. The app matches them in upper case (`Config.acDrawnMessages`) on the title or the description, whatever the message kind, and never shows them on the overlay; other messages are unaffected.

## Beta 1.41: included track configuration files

- CSP track configurations include other files with `[INCLUDE: file]` section headers or `INCLUDE = a, b` keys. The F1 2026 layouts (Melbourne, Monza, Silverstone…) use `[INCLUDE: ../../common/…]`, `[INCLUDE: ../../extension/ext_config.ini]` and `[INCLUDE: extension/config/tracks/loaded/<track>.ini]`.
- The app resolves an include from the folder of the including file with `.` and `..` segments resolved; `common/…` in `extension/config/tracks/common`; `extension/…` also from the Assetto Corsa folder (`ac.FolderID.Root` when present, else derived from `content/tracks` or `extension/config`). A resolved path is read only inside `content/tracks/<track>/` or `extension/config/`; absolute paths, drive letters and escapes are refused. Paths are compared without case.
- At most 64 files (`K.lightsFiles`), 4 MB each (`K.lightsBytes`) and 8 MB in all (`K.lightsTotalBytes`), once per track, and reading stops at the first match.

## Beta 1.41: pit exit merge (D12 exception) and frame clock

- Rule D12 (pits and off-track cars never driven) has one exception since Beta 1.41, in track day only. An AI driving out of the pit lane (at least 5 km/h when the hold begins, at least 15 m past its own pit box of this visit), 80 m to 5 m before the learned merge point, is held while a car on track, the player included, reaches the merge within 3 s plus its own time to get there (5 s at most), or is past it by less than 15 m. The hold lasts 10 s at most, once per exit, never for the player or the Safety Car, never under a red flag, and only while the native stop counter works (`host.caps.stop.available`, `engine.stopCap`). A car driving to its own pit box is never held.
- It uses the same native stop counter as the pit-box hold (`physics.setAIStopCounter`, `cmd.mergeHold` in the applier's `hold()`). No offset, speed, brake or level command is written in the pit lane; pit stop requests (`physics.setAIPitStopRequest`) stay active there until the stop, as before.
- Pit lane state: `ac.StateCar.isInPitlane` or `isInPit` (frame field `pit`), `isInPit` alone for the pit box (`inPitBox`). The merge point is learned from cars leaving the pit lane while driving (at least 5 s in the lane, at most 120 km/h, never a teleport): a moving average, replaced after three exits in a row more than 200 m away. Nothing is read from the track files.
- Pit-lane cars from 100 m before to 50 m after the merge, unless held, are listed by perception for the cars on track (forward radar, obstacle, pass) when they move at 15 km/h or more, or at 3 km/h or more within 30 m of the merge; never in lateral occupancy or the corridor. A stopped car (a queue, the waiting player) stays invisible.
- `physics.teleportCarTo(index, 'PIT')` without `preserveDamage` repairs the car it moves: a slow damaged AI recovered in track day, practice or qualifying arrives repaired (log `IA lente et endommagee depannee a son stand, reparee par le deplacement`).
- Yield top-speed cut: released as soon as the yield ends. In track day with the Traffic tab, the next speed limit starts from the last cut and rises at `K.trafficAccelKmh` per second, a short carry-over by design.
- Frame cost clock: `QueryPerformanceCounter` through `ffi` when CSP allows it, else `os.preciseClock` if it advances within a short probe loop at launch, else `os.clock` (1 ms steps: the mean stays right, the maximum is rounded). The source is logged once (`cout par image mesure par: …`).

## Beta 1.26: CSP AI flood and AI placement

- `io.save(path, data, true)` goes through `io.replaceFile` when the file exists, which keeps the old content as `<path>.bak` (CSP's safe replacement). The updater deletes that `.bak` right after each write and on each deletion (Beta 1.37); `boot.txt`, rewritten at the launch that counts the start, was the source of the `boot.txt.bak` left by Beta 1.36.
- User setting: `ac.getFolder(ac.FolderID.ExtCfgUser)` (`Documents/Assetto Corsa/cfg/extension`), file `new_behaviour.ini`, absent as long as nothing has been changed; defaults: `ac.FolderID.ExtCfgSys` (`extension/config/new_behaviour.ini`, `[AI_FLOOD] ENABLED=1`, `MIN_TRACK_LENGTH=7000`). Read with `io.load`, written with `io.save(path, text, true)` (temporary file, then replacement); only the `ENABLED` and `SPAWN_*` keys of `[AI_FLOOD]` change. Checked in game: CSP reads it at launch, not when a session restarts.
- Placement: `physics.setCarPosition(index, position, nil)` (nil: CSP aligns the car with the AI line), position given by `ac.trackProgressToWorldCoordinate`, native wait cancelled first (`setAITimeToStart(index, 0)`). The `physics.setCarVelocity` launch is only given once the position jump has been seen, along the car's axis: a computed direction and a speed set together sent all 30 AI cars sliding on the first attempt.
- The pit indicators (`isInPit`, `isInPitlane`) are false for a short moment at the start of a session, and sometimes no car is loaded yet on the first frame: the distribution waits for the AI cars and 0.5 s, then counts an AI car as placed only if it is within 100 m of its spot.
- `ac.blockSystemMessages('.')`: a test message (`ac.setMessage`, 0.1 s) checks that the `ac.onMessage` listener still receives the hidden messages.

## 1.3.2: session log

- `ac.getFolder(ac.FolderID.Logs)` gives `Documents/Assetto Corsa/logs`. The app writes there with `io.open(path, 'a')` every two seconds (small appends, never a complete rewrite), after an `io.fileExists` / `io.move` rotation on the first cycle of a game launch (since 1.8.0, a marker in `ac.store` makes it continue the same file after an app reload). `os.date` timestamps the lines. If `io.open` is missing or fails three times, the log switches off with no effect on the engine.
- The CSP and AC logs are truncated when they exceed their maximum size, often as soon as a 30-car grid is loaded: they then do not cover the race. The app's log is independent of this limit.

## Beta 1.42: AI strategy and sanctions

- `physics.setAIThrottleLimit(index, limit)` (0 to 1): the throttle cut of a sanction, dirty air and failures. The app lowers it gradually (never below 0.3), writes it once per change, returns exactly 1 when the limit comes back above 0.99, and gives it back when the car is not driven (pits, off track, release). After a reload on error, every recovered car gets its throttle back.
- `physics.setTyresVirtualKM(index, wheel, km)`: the flat spot of a lock-up on the more worn front tyre, one event at a time, bounded per stint.
- Read for the AI: `car.wheels[i].tyreWear` (0 new to 1 worn per the SDK, still to confirm in game), `tyreVirtualKM`, core and optimum temperatures, `car.fuel`, `car.maxFuel`, `car.fuelPerLap` (AC's estimate), `car.wheelsOutside`, `car.isLapValid`, `car.currentSector`, `sim.pitsSpeedLimit` (ignored below 40 km/h).
- Not possible with CSP: AC's penalties (`physics.setCarPenalty`) apply to the player only, and AC's results cannot be changed; `markLapAsSpoiled` works only in a race for an AI, so invalidated AI laps in practice and qualifying stay in the app. An AI drive-through is a pit request without service (AC's AI stops briefly at its box).
- The `isInPitlane` flag can drop for a frame: a pit-lane exit is confirmed after 1 s out of the lane (the exit point and the pit junction are taken from the first frame out).

