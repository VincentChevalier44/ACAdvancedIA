# Current compatibility

AdvancedIA follows the scope of the HumanAI PDR: standard physics-driven AI cars, offline, exposed by CSP. Track day (Content Manager Track day mode, hotlap, time attack, drift, drag), Practice (standalone Practice and the practice sessions of a weekend), Qualifying and Race profiles, chosen automatically from `race.ini`. The Safety Car must be on the Content Manager grid; the AI cars' indicators cannot be controlled from a CSP app.

Since rc.2, all sections are opt-in and disabled on first load. Profile detection uses the type declared for the current session in race.ini when it is available, otherwise the CSP type. The settings and diagnostic windows are reserved for the pause/setup menus; the engine stays loaded while driving, and the AdvancedIA Drapeaux window appears while driving when a flag or DRS shows up. Spacing requires `physics.setAITopSpeed` and only works in the Track day profile. Named presets use this app's CSP storage.

V1: independent weather in each profile (four since 1.2.0), with `setAIRainTyres`, `setAIPitStopRequest` and `setAITyres` depending on availability. A real compound is only changed in the pits (when stopped, or while driving in the pit lane) or on the grid before the start. Grip compensation is suspended if the native wet-tyre status cannot be confirmed. The limitations of signatures and of compound recognition are shown in the diagnostics and in [AUDIT_V1.md](docs/AUDIT_V1.md).

1.1: left/right sides consistent with the SDK whatever the calibrated sign (−1 expected in AC). Engine active in the garage (setup menu), frozen only in a real pause. Qualifying preset and one-time application of the recommended preset to a profile that has never been set up; preset recognised per profile during a weekend. See [AUDIT_V1_1.md](docs/AUDIT_V1_1.md).

1.2 to 1.8, then Beta 1.0 to 1.4: Practice profile, accidents and racing rules, flag panel, penalties, delta time, DRS, Safety Car, F1 2025, F1 2026, GT and Endurance rule sets; details in [CHANGELOG.md](CHANGELOG.md). Player penalties require race settings that allow the throttle cut.

No RARE dependency or integration. The kinematic Traffic Planner and alt-online remain inert. Its former hook-ups have been removed and its native files restored exactly. No track file is modified.

The capabilities actually available depend on the installed CSP: protected detection and debug panel. Level >100% only after probe/read-back; otherwise capped at 100%, or grip with an explicit option. Early braking emulated through caution; extra braking disabled by default. Without a calibrated sign, no behavioural lateral offset.

Pure: no code dependency, weather read from CSP; physical validation with Pure still open. The presence of another AI app is reported; its activity cannot be inferred with certainty from the visibility of its window.

See [README.md](README.md) and [docs/VALIDATION.md](docs/VALIDATION.md). Signature compatibility does not constitute a driving validation on every track.
