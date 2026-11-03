# Settings and functions inventory Beta 1.35

This inventory links every declared parameter to its consumers. A static reference shows a connection, not proof of a physical result. The `PARAMETER_BOUNDARY_ENGINE` tests and the two full walks through the interface complete this trace.

| Section | Parameter | Range | Default J / P / Q / C | Consumers |
|---|---|---|---|---|
| general | `levelPct` — Level (%) | 40 to 110 | 95 / 100 / 100 / 100 | src/director.lua:98, src/groups.lua:8, src/lang_en.lua:127, src/mistakes.lua:33, src/tips_en.lua:6 |
| general | `aggressionPct` — Aggression (%) | 0 to 100 | 55 / 45 / 45 / 80 | src/director.lua:99, src/director.lua:810, src/groups.lua:8, src/lang_en.lua:127, src/tips_en.lua:7 |
| general | `caution` — Caution | 0.5 to 8 | 1.6 / 2.2 / 2.2 / 1.2 | src/applier.lua:10, src/applier.lua:69, src/applier.lua:266, src/applier.lua:271, src/applier.lua:294, src/applier.lua:877, src/applier.lua:883, src/applier.lua:947, src/applier.lua:967, src/caps.lua:2, src/director.lua:100, src/director.lua:102, src/director.lua:105, src/director.lua:107, src/director.lua:108, src/director.lua:453, src/director.lua:454, src/director.lua:483, src/director.lua:518, src/director.lua:550, src/director.lua:631, src/director.lua:633, src/director.lua:752, src/director.lua:753, src/director.lua:755, src/director.lua:756, src/director.lua:774, src/director.lua:794, src/director.lua:810, src/director.lua:813, src/director.lua:815, src/director.lua:861, src/director.lua:867, src/director.lua:870, src/engine.lua:114, src/engine.lua:161, src/engine.lua:446, src/engine.lua:498, src/groups.lua:8, src/lang_en.lua:59, src/lang_en.lua:62, src/lang_en.lua:127, src/lang_en.lua:161, src/lang_en.lua:277, src/tips_en.lua:8, src/tips_en.lua:9, src/tips_en.lua:12, src/tips_en.lua:64, src/tips_en.lua:99, src/tips_en.lua:173, src/tips_en.lua:180, src/tips_en.lua:222, src/tips_en.lua:229, src/tips_en.lua:238 |
| general | `brakeZonePct` — Emulated braking zone (%) | 50 to 150 | 100 / 100 / 100 / 100 | src/director.lua:815, src/groups.lua:8, src/lang_en.lua:127, src/tips_en.lua:9 |
| general | `paceSpreadPct` — Level spread (%) | 0 to 20 | 8 / 3 / 3 / 2 | src/groups.lua:9, src/lang_en.lua:127, src/persona.lua:13, src/tips_en.lua:10 |
| general | `aggrSpreadPct` — Aggression spread (%) | 0 to 30 | 12 / 8 / 8 / 10 | src/groups.lua:9, src/lang_en.lua:127, src/persona.lua:14, src/tips_en.lua:11 |
| general | `cautSpreadPct` — Caution spread (%) | 0 to 30 | 12 / 8 / 8 / 8 | src/groups.lua:9, src/lang_en.lua:127, src/persona.lua:15, src/tips_en.lua:12 |
| general | `pitExitSpread` — Staggered pit exits, practice and qualifying (s per AI, 0 = free) | 0 to 30 | 0 / 10 / 10 / 0 | src/groups.lua:10, src/lang_en.lua:127, src/lang_en.lua:266, src/tips_en.lua:13, src/traffic.lua:17, src/traffic.lua:52, src/traffic.lua:115 |
| general | `spawnMode` — AI distribution at session start | native, pits, track | track / pits / pits / native | src/flood.lua:105, src/groups.lua:10, src/lang_en.lua:127, src/tips_en.lua:14, src/traffic.lua:26 |
| general | `spawnMinCars` — Spread from (AI) | 2 to 60 | 10 / 10 / 10 / 10 | src/engine.lua:234, src/flood.lua:106, src/groups.lua:10, src/lang_en.lua:127, src/tips_en.lua:17, src/traffic.lua:10, src/traffic.lua:67 |
| general | `spawnPitPct` — AI left in the pits at the start (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/groups.lua:10, src/lang_en.lua:127, src/tips_en.lua:15, src/traffic.lua:72, src/traffic.lua:74 |
| general | `spawnGapVariation` — Start gap variation (%) | 0 to 100 | 100 / 100 / 100 / 100 | src/groups.lua:10, src/lang_en.lua:127, src/tips_en.lua:16, src/traffic.lua:80, src/traffic.lua:83 |
| general | `floodRangeKm` — CSP AI flood range, below the threshold (km) | 1 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:219, src/engine.lua:234, src/engine.lua:235, src/groups.lua:10, src/lang_en.lua:127, src/tips_en.lua:18 |
| yield | `yieldEnabled` — Standard yielding | boolean | true / true / true / false | src/director.lua:314, src/director.lua:561, src/groups.lua:18, src/lang_en.lua:128, src/tips_en.lua:20 |
| yield | `yieldSide` — Yield side | left, right, auto | right / right / right / right | src/director.lua:79, src/director.lua:80, src/director.lua:87, src/director.lua:90, src/director.lua:353, src/director.lua:520, src/groups.lua:18, src/lang_en.lua:128, src/persona.lua:23, src/tips_en.lua:21 |
| yield | `yieldOffset` — Yield offset | 0.2 to 0.95 | 0.65 / 0.8 / 0.8 / 0.6 | src/director.lua:545, src/groups.lua:18, src/lang_en.lua:128, src/tips_en.lua:22 |
| yield | `yieldDetectBehind` — Rear detection (m) | 30 to 400 | 100 / 200 / 200 / 80 | src/director.lua:320, src/groups.lua:18, src/lang_en.lua:128, src/tips_en.lua:23 |
| yield | `yieldBehindMargin` — Follower speed advantage (km/h) | 1 to 30 | 6 / 4 / 4 / 6 | src/director.lua:274, src/director.lua:317, src/director.lua:561, src/groups.lua:18, src/lang_en.lua:128, src/tips_en.lua:24 |
| yield | `yieldHorizon` — Rear horizon (s) | 3 to 30 | 10 / 12 / 12 / 8 | src/director.lua:318, src/groups.lua:18, src/lang_en.lua:128, src/tips_en.lua:25 |
| yield | `confirmTime` — Confirmation (s) | 0.1 to 2 | 0.6 / 0.4 / 0.4 / 0.5 | src/director.lua:334, src/director.lua:720, src/groups.lua:18, src/lang_en.lua:128, src/tips_en.lua:26 |
| yield | `yieldHoldMin` — Minimum hold (s) | 0.3 to 5 | 1 / 1 / 1 / 1 | src/director.lua:361, src/director.lua:562, src/director.lua:577, src/flash.lua:78, src/groups.lua:19, src/lang_en.lua:129, src/tips_en.lua:27 |
| yield | `yieldHoldAfterMin` — Hold after the pass, min. (s) | 0.2 to 6 | 0.8 / 0.6 / 0.6 / 0.8 | src/groups.lua:19, src/lang_en.lua:129, src/persona.lua:27, src/persona.lua:35, src/tips_en.lua:28 |
| yield | `yieldHoldAfterMax` — Hold after the pass, max. (s) | 0.2 to 6 | 2.2 / 1.6 / 1.6 / 1.8 | src/groups.lua:19, src/lang_en.lua:129, src/persona.lua:27, src/persona.lua:35, src/tips_en.lua:29 |
| yield | `yieldSlowdownPct` — Slowdown while yielding (%) | 0 to 20 | 6 / 8 / 8 / 6 | src/director.lua:549, src/director.lua:818, src/groups.lua:20, src/lang_en.lua:129, src/tips_en.lua:30 |
| yield | `inviteSlowdownPct` — Extra slowdown to invite a pass (%) | 0 to 25 | 10 / 10 / 10 / 10 | src/director.lua:554, src/groups.lua:20, src/lang_en.lua:129, src/tips_en.lua:31 |
| yield | `yieldMaxHold` — Maximum yield duration (s) | 8 to 60 | 25 / 25 / 25 / 25 | src/director.lua:579, src/flash.lua:45, src/groups.lua:19, src/lang_en.lua:129, src/tips_en.lua:32 |
| yield | `pressureEnabled` — Reaction to pressure | boolean | true / true / true / false | src/director.lua:324, src/director.lua:330, src/groups.lua:21, src/lang_en.lua:130, src/tips_en.lua:33 |
| yield | `pressureGap` — Pressure distance (m) | 5 to 30 | 15 / 15 / 15 / 15 | src/director.lua:324, src/director.lua:327, src/groups.lua:21, src/lang_en.lua:130, src/tips_en.lua:34 |
| yield | `pressureTime` — Pressure duration (s) | 1 to 15 | 4 / 3 / 3 / 4 | src/director.lua:330, src/groups.lua:21, src/lang_en.lua:130, src/tips_en.lua:35 |
| blue | `blueFlagEnabled` — Blue flags | boolean | false / true / true / true | src/director.lua:264, src/director.lua:886, src/engine.lua:41, src/groups.lua:22, src/lang_en.lua:131, src/panel.lua:20, src/tips_en.lua:37 |
| blue | `blueFlagRange` — Blue flag range (m) | 50 to 400 | 150 / 200 / 200 / 150 | src/director.lua:296, src/director.lua:886, src/director.lua:894, src/engine.lua:41, src/groups.lua:22, src/lang_en.lua:131, src/panel.lua:29, src/tips_en.lua:38 |
| blue | `blueFlagSide` — Side under blue flag | auto, left, right | auto / auto / auto / auto | src/director.lua:80, src/groups.lua:22, src/lang_en.lua:131, src/tips_en.lua:39 |
| flash | `flashMode` — Headlight flashes | never, lapped, always | always / always / always / lapped | src/director.lua:305, src/flash.lua:50, src/flash.lua:59, src/groups.lua:23, src/lang_en.lua:132, src/tips_en.lua:41 |
| flash | `flashRange` — Flash range (m) | 40 to 250 | 200 / 200 / 200 / 150 | src/director.lua:283, src/director.lua:289, src/director.lua:321, src/director.lua:436, src/director.lua:440, src/engine.lua:656, src/engine.lua:657, src/flash.lua:58, src/groups.lua:23, src/lang_en.lua:132, src/tips_en.lua:42 |
| flash | `flashMinAdvantage` — Speed advantage for a flash (km/h) | 3 to 40 | 12 / 8 / 8 / 15 | src/director.lua:825, src/flash.lua:45, src/groups.lua:23, src/lang_en.lua:132, src/tips_en.lua:43 |
| flash | `flashCloseAdvantage` — Close-range advantage (km/h) | -10 to 15 | -5 / -5 / -5 / 6 | src/flash.lua:44, src/groups.lua:23, src/lang_en.lua:132, src/tips_en.lua:44 |
| flash | `flashRequestTTL` — Request lifetime (s) | 3 to 20 | 8 / 8 / 8 / 8 | src/director.lua:834, src/flash.lua:73, src/flash.lua:74, src/groups.lua:23, src/lang_en.lua:132, src/tips_en.lua:45 |
| flash | `flashObliviousPct` — First flash missed (%) | 0 to 40 | 10 / 5 / 5 / 10 | src/flash.lua:70, src/groups.lua:24, src/lang_en.lua:132, src/tips_en.lua:46 |
| flash | `flashMaxReactors` — Cars reacting | 1 to 3 | 3 / 3 / 3 / 3 | src/flash.lua:67, src/groups.lua:24, src/lang_en.lua:132, src/tips_en.lua:47 |
| flash | `hornEnabled` — Horn counts as a flash | boolean | false / false / false / false | src/engine.lua:650, src/engine.lua:651, src/groups.lua:24, src/lang_en.lua:132, src/tips_en.lua:48 |
| flash | `aiFlashEnabled` — AI-to-AI headlight flashes | boolean | true / true / true / true | src/director.lua:821, src/groups.lua:24, src/lang_en.lua:132, src/tips_en.lua:49 |
| overtake | `overtakeEnabled` — Overtaking | boolean | true / true / true / true | src/director.lua:665, src/director.lua:676, src/groups.lua:25, src/lang_en.lua:133, src/tips_en.lua:51 |
| overtake | `overtakeSide` — Overtaking side | opposite, auto, left, right | left / left / left / left | src/director.lua:87, src/director.lua:88, src/director.lua:718, src/groups.lua:25, src/lang_en.lua:133, src/tips_en.lua:52 |
| overtake | `overtakeOffset` — Overtaking offset | 0.2 to 0.95 | 0.7 / 0.65 / 0.65 / 0.6 | src/director.lua:583, src/groups.lua:26, src/lang_en.lua:133, src/tips_en.lua:53 |
| overtake | `overtakeDetectAhead` — Forward detection (m) | 20 to 200 | 60 / 50 / 50 / 50 | src/director.lua:626, src/director.lua:690, src/groups.lua:25, src/lang_en.lua:133, src/tips_en.lua:54 |
| overtake | `overtakeAheadMargin` — Speed advantage to overtake (km/h) | 1 to 30 | 8 / 10 / 10 / 3 | src/director.lua:683, src/groups.lua:25, src/lang_en.lua:133, src/tips_en.lua:55 |
| overtake | `overtakeHorizon` — Forward horizon (s) | 2 to 20 | 6 / 6 / 6 / 6 | src/director.lua:690, src/groups.lua:25, src/lang_en.lua:133, src/tips_en.lua:56 |
| overtake | `overtakeClearMargin` — Clearance after overtaking (m) | 8 to 40 | 18 / 20 / 20 / 10 | src/director.lua:624, src/director.lua:717, src/groups.lua:26, src/lang_en.lua:133, src/tips_en.lua:57 |
| overtake | `overtakeRestTime` — Pause after overtaking (s) | 0 to 10 | 2 / 3 / 3 / 1 | src/director.lua:630, src/groups.lua:26, src/lang_en.lua:133, src/tips_en.lua:58 |
| overtake | `overtakeChain` — Chain overtakes | boolean | true / false / false / true | src/director.lua:626, src/groups.lua:26, src/lang_en.lua:134, src/tips_en.lua:59 |
| overtake | `stuckTime` — Held-up confirmation (s) | 0.5 to 10 | 2 / 3 / 3 / 1.2 | src/director.lua:692, src/director.lua:825, src/groups.lua:25, src/lang_en.lua:134, src/tips_en.lua:60 |
| overtake | `stuckPaceRatio` — Held-up pace threshold | 0.8 to 0.99 | 0.93 / 0.93 / 0.93 / 0.95 | src/director.lua:261, src/groups.lua:25, src/lang_en.lua:134, src/tips_en.lua:61 |
| overtake | `pullOutGapBase` — Pull-out distance (m) | 4 to 15 | 8 / 8 / 8 / 8 | src/director.lua:621, src/groups.lua:26, src/lang_en.lua:134, src/tips_en.lua:62 |
| overtake | `pullOutGapPerMps` — Pull-out gain (s) | 0 to 0.5 | 0.25 / 0.25 / 0.25 / 0.25 | src/director.lua:621, src/groups.lua:26, src/lang_en.lua:134, src/tips_en.lua:63 |
| overtake | `slipstreamEnabled` — Slipstream | boolean | true / true / true / true | src/director.lua:749, src/director.lua:755, src/groups.lua:26, src/lang_en.lua:134, src/tips_en.lua:64 |
| overtake | `defenseEnabled` — Defending | boolean | true / true / true / true | src/director.lua:642, src/groups.lua:27, src/lang_en.lua:134, src/tips_en.lua:65 |
| overtake | `defenseMaxOffset` — Maximum defending offset | 0.1 to 0.5 | 0.35 / 0.35 / 0.35 / 0.35 | src/director.lua:633, src/groups.lua:27, src/lang_en.lua:134, src/tips_en.lua:66 |
| overtake | `defenseCooldown` — Pause between defences (s) | 2 to 30 | 8 / 8 / 8 / 8 | src/director.lua:649, src/groups.lua:27, src/lang_en.lua:134, src/tips_en.lua:67 |
| overtake | `defenseTriggerGap` — Defending distance (m) | 5 to 25 | 12 / 12 / 12 / 12 | src/director.lua:642, src/groups.lua:27, src/lang_en.lua:134, src/tips_en.lua:68 |
| lateral | `rampSpeed` — Lateral movement speed | 0.1 to 1 | 0.3 / 0.3 / 0.3 / 0.45 | src/director.lua:218, src/groups.lua:15, src/lang_en.lua:135, src/tips_en.lua:70 |
| lateral | `rampAccel` — Lateral acceleration | 0.5 to 4 | 1.5 / 1.5 / 1.5 / 2 | src/director.lua:220, src/groups.lua:15, src/lang_en.lua:135, src/tips_en.lua:71 |
| lateral | `lowPassTau` — Lateral smoothing (s) | 0.05 to 1 | 0.25 / 0.25 / 0.25 / 0.2 | src/director.lua:221, src/groups.lua:15, src/lang_en.lua:135, src/tips_en.lua:72 |
| lateral | `maxSideOffset` — Maximum offset | 0.3 to 0.95 | 0.85 / 0.85 / 0.85 / 0.8 | src/director.lua:152, src/director.lua:526, src/director.lua:545, src/director.lua:633, src/groups.lua:16, src/lang_en.lua:135, src/tips_en.lua:73 |
| lateral | `cornerMin` — Straight threshold | 0 to 1 | 0.35 / 0.35 / 0.35 / 0.5 | src/director.lua:280, src/director.lua:351, src/director.lua:372, src/director.lua:666, src/director.lua:675, src/director.lua:822, src/director.lua:845, src/director.lua:860, src/groups.lua:16, src/lang_en.lua:135, src/tips_en.lua:74, src/traffic.lua:199 |
| lateral | `cornerYawRef` — Yaw rate reference (rad/s) | 0.2 to 1.2 | 0.5 / 0.5 / 0.5 / 0.5 | src/director.lua:402, src/groups.lua:16, src/lang_en.lua:135, src/tips_en.lua:75 |
| lateral | `lateralCooldown` — Pause between direction changes (s) | 0.3 to 5 | 1.2 / 1.2 / 1.2 / 1 | src/director.lua:117, src/director.lua:130, src/groups.lua:16, src/lang_en.lua:135, src/tips_en.lua:76 |
| lateral | `emergencyReleaseFactor` — Release factor | 1 to 4 | 2 / 2 / 2 / 2 | src/director.lua:207, src/groups.lua:16, src/lang_en.lua:135, src/tips_en.lua:77 |
| human | `reactMin` — Minimum reaction (s) | 0.1 to 2 | 0.25 / 0.2 / 0.2 / 0.2 | src/groups.lua:11, src/lang_en.lua:136, src/persona.lua:10, src/tips_en.lua:79 |
| human | `reactMax` — Maximum reaction (s) | 0.1 to 2 | 0.9 / 0.6 / 0.6 / 0.6 | src/groups.lua:11, src/lang_en.lua:136, src/persona.lua:10, src/tips_en.lua:80 |
| human | `awMin` — Minimum awareness delay (s) | 0.2 to 5 | 0.6 / 0.4 / 0.4 / 0.4 | src/groups.lua:11, src/lang_en.lua:136, src/persona.lua:10, src/tips_en.lua:81 |
| human | `awMax` — Maximum awareness delay (s) | 0.2 to 5 | 2 / 1.2 / 1.2 / 1.2 | src/groups.lua:11, src/lang_en.lua:136, src/persona.lua:10, src/tips_en.lua:82 |
| human | `paceDriftPct` — Slow pace drift (%) | 0 to 6 | 2 / 1 / 1 / 1 | src/director.lua:97, src/groups.lua:12, src/lang_en.lua:136, src/tips_en.lua:83 |
| human | `personalLineJitter` — Line variation | 0 to 0.15 | 0.05 / 0.03 / 0.03 / 0.02 | src/director.lua:638, src/groups.lua:12, src/lang_en.lua:136, src/tips_en.lua:84 |
| human | `lapseEnabled` — Brief lapses in focus | boolean | true / false / false / false | src/director.lua:799, src/groups.lua:13, src/lang_en.lua:136, src/tips_en.lua:85 |
| human | `lapseIntervalMin` — Minimum interval (s) | 20 to 900 | 60 / 120 / 120 / 120 | src/groups.lua:13, src/lang_en.lua:137, src/persona.lua:24, src/persona.lua:42, src/tips_en.lua:86 |
| human | `lapseIntervalMax` — Maximum interval (s) | 20 to 900 | 300 / 600 / 600 / 600 | src/groups.lua:13, src/lang_en.lua:137, src/persona.lua:24, src/persona.lua:42, src/tips_en.lua:87 |
| human | `lapseDurMin` — Minimum duration (s) | 0.5 to 8 | 1.5 / 1 / 1 / 1 | src/groups.lua:13, src/lang_en.lua:137, src/persona.lua:25, src/persona.lua:43, src/tips_en.lua:88 |
| human | `lapseDurMax` — Maximum duration (s) | 0.5 to 8 | 3 / 2 / 2 / 2 | src/groups.lua:13, src/lang_en.lua:137, src/persona.lua:25, src/persona.lua:43, src/tips_en.lua:89 |
| human | `lapseDropMin` — Minimum pace loss (%) | 0 to 25 | 6 / 3 / 3 / 3 | src/groups.lua:13, src/lang_en.lua:137, src/persona.lua:26, src/persona.lua:44, src/tips_en.lua:90 |
| human | `lapseDropMax` — Maximum pace loss (%) | 0 to 25 | 12 / 7 / 7 / 7 | src/groups.lua:13, src/lang_en.lua:137, src/persona.lua:26, src/persona.lua:44, src/tips_en.lua:91 |
| human | `laneBiasEnabled` — Pace-based line | boolean | true / false / false / false | src/groups.lua:12, src/lang_en.lua:137, src/persona.lua:23, src/tips_en.lua:92 |
| human | `laneBiasMax` — Maximum line bias | 0 to 0.4 | 0.25 / 0.25 / 0.25 / 0.25 | src/groups.lua:12, src/lang_en.lua:137, src/persona.lua:23, src/tips_en.lua:93 |
| human | `mistakesEnabled` — AI driving mistakes (lock-ups, wheelspin) | boolean | true / true / true / true | src/groups.lua:14, src/lang_en.lua:138, src/lang_en.lua:266, src/mistakes.lua:44, src/tips_en.lua:94 |
| human | `mistakeRate` — Mistakes: rate (per hour per AI) | 0 to 6 | 1 / 0.5 / 0.5 / 0.5 | src/groups.lua:14, src/lang_en.lua:138, src/lang_en.lua:267, src/mistakes.lua:44, src/mistakes.lua:65, src/tips_en.lua:95 |
| start | `startDelay` — Start delay (s) | 0 to 30 | 0 / 0 / 0 / 1 | src/applier.lua:11, src/applier.lua:236, src/applier.lua:391, src/applier.lua:392, src/applier.lua:395, src/applier.lua:411, src/applier.lua:623, src/applier.lua:858, src/applier.lua:863, src/caps.lua:2, src/director.lua:458, src/director.lua:468, src/director.lua:486, src/director.lua:742, src/director.lua:791, src/director.lua:792, src/engine.lua:114, src/engine.lua:349, src/engine.lua:353, src/engine.lua:357, src/engine.lua:369, src/groups.lua:17, src/lang_en.lua:139, src/mistakes.lua:47, src/tips_en.lua:97, src/traffic.lua:17, src/traffic.lua:145, src/traffic.lua:163, src/traffic.lua:167 |
| start | `startCautionMult` — Caution at the start | 1 to 3 | 1 / 1 / 1 / 1.3 | src/director.lua:794, src/engine.lua:41, src/groups.lua:17, src/lang_en.lua:139, src/tips_en.lua:99 |
| start | `startAggrMult` — Aggression at the start | 0.2 to 1 | 1 / 1 / 1 / 0.8 | src/director.lua:794, src/engine.lua:41, src/groups.lua:17, src/lang_en.lua:139, src/tips_en.lua:100 |
| start | `startRelax` — Settling time after the start (s) | 2 to 30 | 12 / 12 / 12 / 25 | src/director.lua:458, src/director.lua:742, src/director.lua:791, src/director.lua:792, src/engine.lua:357, src/groups.lua:17, src/lang_en.lua:139, src/mistakes.lua:47, src/tips_en.lua:101 |
| start | `startLaneHold` — Hold the grid lane at the start | boolean | false / false / false / false | src/director.lua:796, src/engine.lua:41, src/engine.lua:357, src/groups.lua:17, src/lang_en.lua:139, src/tips_en.lua:98 |
| accidents | `obstacleEnabled` — Avoid stopped or crashed cars | boolean | true / true / true / true | src/director.lua:486, src/groups.lua:29, src/lang_en.lua:140, src/tips_en.lua:103 |
| accidents | `obstacleSpeedKmh` — Obstacle speed (km/h) | 5 to 50 | 25 / 25 / 25 / 25 | src/director.lua:490, src/director.lua:491, src/director.lua:530, src/engine.lua:388, src/groups.lua:29, src/incidents.lua:146, src/incidents.lua:188, src/incidents.lua:198, src/incidents.lua:231, src/lang_en.lua:140, src/lights.lua:54, src/penalties.lua:39, src/tips_en.lua:104 |
| accidents | `obstacleDetect` — Obstacle detection (m) | 50 to 300 | 150 / 150 / 150 / 150 | src/director.lua:490, src/director.lua:507, src/groups.lua:29, src/lang_en.lua:140, src/tips_en.lua:105 |
| accidents | `obstacleLevelDrop` — Level drop near an obstacle (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/director.lua:518, src/groups.lua:29, src/lang_en.lua:140, src/tips_en.lua:106 |
| accidents | `obstacleCautionMult` — Caution near an obstacle | 1 to 3 | 1.5 / 1.5 / 1.5 / 1.5 | src/director.lua:518, src/groups.lua:29, src/lang_en.lua:140, src/tips_en.lua:107 |
| accidents | `avoidOffset` — Avoidance offset | 0.3 to 0.9 | 0.6 / 0.6 / 0.6 / 0.6 | src/director.lua:526, src/groups.lua:30, src/lang_en.lua:140, src/tips_en.lua:108 |
| accidents | `contactRecovery` — Recovery after contact | boolean | true / true / true / true | src/director.lua:474, src/groups.lua:30, src/lang_en.lua:141, src/tips_en.lua:109 |
| accidents | `incidentStop` — Crashed AI stop | boolean | true / true / true / true | src/groups.lua:30, src/incidents.lua:229, src/lang_en.lua:141, src/tips_en.lua:110 |
| accidents | `incidentStopMin` — Minimum stop (s) | 1 to 15 | 3 / 3 / 3 / 3 | src/groups.lua:30, src/incidents.lua:233, src/lang_en.lua:141, src/tips_en.lua:111 |
| accidents | `incidentStopMax` — Maximum stop (s) | 1 to 30 | 8 / 8 / 8 / 8 | src/groups.lua:30, src/incidents.lua:233, src/lang_en.lua:141, src/tips_en.lua:112 |
| accidents | `rejoinGap` — Clear track behind to rejoin (m) | 30 to 300 | 120 / 120 / 120 / 120 | src/groups.lua:30, src/incidents.lua:134, src/lang_en.lua:141, src/tips_en.lua:113 |
| accidents | `yellowEnabled` — Yellow flags (incident zone) | boolean | true / true / true / true | src/groups.lua:31, src/incidents.lua:433, src/incidents.lua:491, src/lang_en.lua:142, src/lights.lua:46, src/tips_en.lua:114 |
| accidents | `yellowBefore` — Zone start before the incident (m) | 50 to 800 | 300 / 300 / 300 / 300 | src/groups.lua:31, src/incidents.lua:423, src/incidents.lua:438, src/incidents.lua:441, src/incidents.lua:496, src/incidents.lua:497, src/incidents.lua:505, src/incidents.lua:506, src/lang_en.lua:142, src/tips_en.lua:118 |
| accidents | `yellowAfter` — Zone end after the incident (m) | 0 to 300 | 50 / 50 / 50 / 50 | src/groups.lua:31, src/incidents.lua:438, src/incidents.lua:496, src/lang_en.lua:142, src/tips_en.lua:119 |
| accidents | `yellowHold` — Hold after clearing (s) | 0 to 60 | 10 / 10 / 10 / 10 | src/groups.lua:31, src/incidents.lua:220, src/lang_en.lua:142, src/penalties.lua:39, src/tips_en.lua:120 |
| accidents | `yellowDecel` — Approach deceleration (m/s²) | 2 to 10 | 5 / 5 / 5 / 5 | src/delta.lua:146, src/delta.lua:178, src/director.lua:425, src/engine.lua:765, src/groups.lua:31, src/incidents.lua:449, src/incidents.lua:488, src/lang_en.lua:142, src/tips_en.lua:121 |
| accidents | `zoneDeltaPct` — Double yellow: reference time slower by (%) | 5 to 200 | 15 / 15 / 15 / 15 | src/delta.lua:77, src/groups.lua:32, src/lang_en.lua:143, src/lang_en.lua:267, src/tips_en.lua:116 |
| accidents | `slowZoneKmh` — Double yellow: Slow Zone speed (km/h, 0 = delta time) | 0 to 150 | 0 / 0 / 0 / 0 | src/delta.lua:76, src/groups.lua:32, src/lang_en.lua:143, src/lang_en.lua:267, src/tips_en.lua:117 |
| accidents | `yellowSpeedKmh` — Double yellow: fallback speed, unknown pace (km/h) | 30 to 200 | 50 / 50 / 50 / 50 | src/delta.lua:77, src/groups.lua:32, src/incidents.lua:487, src/lang_en.lua:143, src/lang_en.lua:268, src/tips_en.lua:115 |
| accidents | `yellowHud` — AC native yellow flag on the HUD | boolean | false / false / false / false | src/groups.lua:33, src/incidents.lua:517, src/lang_en.lua:144, src/tips_en.lua:133 |
| accidents | `flagPanel` — ACAdvancedIA flag panel while driving | boolean | true / true / true / true | src/groups.lua:33, src/lang_en.lua:144, src/lang_en.lua:268, src/panel.lua:141, src/tips_en.lua:134 |
| accidents | `yellowMessage` — On-screen incident messages | boolean | true / true / true / true | src/engine.lua:621, src/engine.lua:626, src/engine.lua:641, src/groups.lua:33, src/incidents.lua:76, src/incidents.lua:86, src/incidents.lua:90, src/incidents.lua:272, src/incidents.lua:287, src/incidents.lua:295, src/incidents.lua:303, src/incidents.lua:321, src/incidents.lua:331, src/incidents.lua:368, src/incidents.lua:386, src/incidents.lua:392, src/incidents.lua:403, src/incidents.lua:506, src/lang_en.lua:144, src/tips_en.lua:135 |
| accidents | `deltaBeeps` — Delta: beeps | boolean | true / true / true / true | src/engine.lua:519, src/groups.lua:33, src/lang_en.lua:144, src/tips_en.lua:131 |
| accidents | `playerPenalties` — Player penalties under flags | boolean | false / true / true / true | src/engine.lua:728, src/groups.lua:34, src/lang_en.lua:145, src/penalties.lua:77, src/penalties.lua:78, src/tips_en.lua:129 |
| accidents | `deltaTolerance` — Delta: mini-sector tolerance (s) | 0 to 1 | 0.5 / 0.5 / 0.5 / 0.5 | src/delta.lua:125, src/groups.lua:34, src/lang_en.lua:145, src/tips_en.lua:130 |
| accidents | `penaltySeconds` — Penalty: throttle cut (s) | 2 to 15 | 5 / 5 / 5 / 5 | src/engine.lua:643, src/groups.lua:34, src/lang_en.lua:145, src/penalties.lua:80, src/penalties.lua:81, src/penalties.lua:83, src/penalties.lua:87, src/penalties.lua:118, src/penalties.lua:128, src/penalties.lua:141, src/tips_en.lua:132 |
| accidents | `penaltyDisqualify` — Infringements allowed before disqualification | 1 to 20 | 5 / 5 / 5 / 5 | src/engine.lua:610, src/engine.lua:625, src/engine.lua:629, src/engine.lua:643, src/groups.lua:34, src/lang_en.lua:145, src/penalties.lua:53, src/penalties.lua:140, src/tips_en.lua:127 |
| accidents | `aiPenalties` — AI sanctions under flags | boolean | false / true / true / true | src/groups.lua:34, src/lang_en.lua:145, src/penalties.lua:151, src/tips_en.lua:128 |
| rules | `noMoveBraking` — No change of direction under braking | boolean | true / true / true / true | src/director.lua:466, src/groups.lua:40, src/lang_en.lua:146, src/tips_en.lua:137 |
| rules | `neutralization` — Neutralisation after a major incident | local, fcy, vsc, sc | local / local / local / local | src/engine.lua:59, src/groups.lua:40, src/incidents.lua:257, src/incidents.lua:396, src/lang_en.lua:146, src/tips_en.lua:138 |
| rules | `majorIncidentTime` — Major incident: car stopped on track (s) | 5 to 60 | 15 / 15 / 15 / 15 | src/engine.lua:58, src/engine.lua:59, src/groups.lua:40, src/incidents.lua:217, src/incidents.lua:267, src/lang_en.lua:146, src/tips_en.lua:139 |
| rules | `fcySpeedKmh` — FCY: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:85, src/delta.lua:88, src/delta.lua:90, src/groups.lua:41, src/incidents.lua:400, src/incidents.lua:464, src/lang_en.lua:146, src/lang_en.lua:269, src/tips_en.lua:140 |
| rules | `fcyDeltaPct` — FCY: reference time slower by (%) | 10 to 150 | 50 / 50 / 50 / 50 | src/delta.lua:88, src/delta.lua:90, src/groups.lua:41, src/incidents.lua:287, src/incidents.lua:464, src/lang_en.lua:146, src/lang_en.lua:269, src/panel.lua:168, src/tips_en.lua:141 |
| rules | `vscDeltaPct` — VSC: reference time slower by (%) | 10 to 80 | 30 / 30 / 30 / 30 | src/delta.lua:85, src/groups.lua:41, src/incidents.lua:287, src/incidents.lua:464, src/lang_en.lua:146, src/lang_en.lua:270, src/panel.lua:167, src/tips_en.lua:142 |
| rules | `neutralizationHold` — Minimum neutralisation time (s) | 10 to 180 | 30 / 30 / 30 / 30 | src/groups.lua:40, src/incidents.lua:269, src/incidents.lua:297, src/incidents.lua:400, src/lang_en.lua:147, src/tips_en.lua:143 |
| rules | `safetyCarSpeedKmh` — Safety Car speed (km/h) | 60 to 250 | 120 / 120 / 120 / 120 | src/delta.lua:145, src/groups.lua:50, src/incidents.lua:354, src/incidents.lua:417, src/incidents.lua:462, src/incidents.lua:465, src/lang_en.lua:147, src/tips_en.lua:144 |
| rules | `safetyCarEscalation` — Safety Car if the incident escalates | boolean | false / true / true / true | src/engine.lua:52, src/groups.lua:50, src/incidents.lua:265, src/incidents.lua:266, src/lang_en.lua:147, src/tips_en.lua:146 |
| rules | `restartOvertake` — Overtaking allowed after the restart | line, scIn | line / line / line / line | src/groups.lua:50, src/incidents.lua:90, src/incidents.lua:311, src/lang_en.lua:148, src/panel.lua:162, src/tips_en.lua:145 |
| rules | `redFlagEnabled` — Red flag on a serious accident (practice, qualifying, race) | boolean | true / true / true / true | src/engine.lua:53, src/groups.lua:42, src/incidents.lua:362, src/lang_en.lua:148, src/lang_en.lua:270, src/tips_en.lua:147 |
| rules | `redFlagCars` — Red flag: cars stopped on track | 2 to 10 | 3 / 3 / 3 / 3 | src/groups.lua:42, src/incidents.lua:363, src/lang_en.lua:148, src/lang_en.lua:270, src/tips_en.lua:148 |
| rules | `redFlagSpeedKmh` — Red flag: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:82, src/groups.lua:42, src/incidents.lua:365, src/incidents.lua:469, src/lang_en.lua:148, src/lang_en.lua:271, src/tips_en.lua:149 |
| rules | `redDeltaPct` — Red flag: reference time slower by (%) | 10 to 200 | 60 / 60 / 60 / 60 | src/delta.lua:82, src/groups.lua:42, src/incidents.lua:469, src/lang_en.lua:148, src/lang_en.lua:271, src/tips_en.lua:150 |
| rules | `redFlagHold` — Red flag: minimum suspension (s) | 20 to 600 | 60 / 60 / 60 / 60 | src/groups.lua:42, src/incidents.lua:365, src/incidents.lua:381, src/lang_en.lua:148, src/lang_en.lua:271, src/tips_en.lua:151 |
| rules | `redFlagWork` — Red flag: tyres changed in the pits (stop counts) | boolean | false / false / false / false | src/groups.lua:42, src/lang_en.lua:148, src/lang_en.lua:272, src/pits.lua:94, src/pits.lua:119, src/pits.lua:124, src/tips_en.lua:153 |
| rules | `redRestart` — Restart after a red flag | rolling, standing | rolling / rolling / rolling / rolling | src/groups.lua:39, src/groups.lua:42, src/incidents.lua:82, src/incidents.lua:279, src/lang_en.lua:148, src/panel.lua:161, src/tips_en.lua:152 |
| rules | `mandatoryStops` — Mandatory stops in the race | 0 to 3 | 0 / 0 / 0 / 0 | src/engine.lua:686, src/engine.lua:689, src/groups.lua:47, src/hudinfo.lua:106, src/hudinfo.lua:107, src/hudinfo.lua:108, src/lang_en.lua:149, src/pits.lua:47, src/pits.lua:57, src/pits.lua:62, src/pits.lua:105, src/pits.lua:107, src/pits.lua:115, src/pits.lua:159, src/pits.lua:160, src/tips_en.lua:154 |
| rules | `pitWindowOpenPct` — Window opens (% of race) | 5 to 95 | 25 / 25 / 25 / 25 | src/groups.lua:47, src/lang_en.lua:149, src/pits.lua:53, src/tips_en.lua:155 |
| rules | `pitWindowClosePct` — Window closes (% of race) | 5 to 100 | 75 / 75 / 75 / 75 | src/groups.lua:47, src/lang_en.lua:149, src/pits.lua:53, src/tips_en.lua:156 |
| rules | `pitTyres` — New tyres at every stop (pit rules active) | boolean | true / true / true / true | src/groups.lua:48, src/lang_en.lua:149, src/lang_en.lua:275, src/pits.lua:119, src/tips_en.lua:157 |
| rules | `pitRepair` — Repairs at every stop in the race (bodywork, suspension, engine) | boolean | true / true / true / true | src/applier.lua:353, src/engine.lua:114, src/groups.lua:48, src/lang_en.lua:149, src/lang_en.lua:275, src/pits.lua:99, src/pits.lua:124, src/pits.lua:126, src/tips_en.lua:158 |
| rules | `pitCompoundChange` — Change dry compound (F1) | boolean | false / false / false / false | src/groups.lua:48, src/lang_en.lua:149, src/pits.lua:33, src/pits.lua:56, src/tips_en.lua:159 |
| rules | `minPitTime` — Minimum stop time (s, 0 = free) | 0 to 120 | 0 / 0 / 0 / 0 | src/groups.lua:48, src/lang_en.lua:150, src/pits.lua:47, src/pits.lua:118, src/tips_en.lua:160 |
| rules | `maxStintMin` — Maximum stint (min, 0 = free) | 0 to 240 | 0 / 0 / 0 / 0 | src/groups.lua:48, src/lang_en.lua:150, src/pits.lua:47, src/pits.lua:111, src/pits.lua:165, src/tips_en.lua:162 |
| rules | `pitFuel` — Fuel at enforced stops | refuel, plan, ac | refuel / refuel / refuel / refuel | src/groups.lua:49, src/lang_en.lua:150, src/pits.lua:172, src/tips_en.lua:161 |
| rules | `pitsClosed` — Pit lane closed under neutralisation | open, pitFcy, pitFcySc | open / open / open / open | src/engine.lua:682, src/groups.lua:49, src/incidents.lua:20, src/incidents.lua:31, src/incidents.lua:353, src/incidents.lua:356, src/lang_en.lua:150, src/tips_en.lua:163 |
| rules | `pitMessage` — Pit window opening message | boolean | true / true / true / true | src/groups.lua:47, src/lang_en.lua:150, src/lang_en.lua:274, src/pits.lua:59, src/pits.lua:69, src/tips_en.lua:164 |
| rules | `overtakeMode` — Overtake Mode (F1 2026, within one second at detection) | boolean | false / false / false / false | src/director.lua:841, src/groups.lua:43, src/lang_en.lua:151, src/lang_en.lua:272, src/tips_en.lua:165 |
| rules | `overtakeModeGap` — Overtake Mode: detection gap (s) | 0.3 to 2 | 1 / 1 / 1 / 1 | src/director.lua:843, src/groups.lua:43, src/lang_en.lua:151, src/lang_en.lua:272, src/tips_en.lua:166 |
| rules | `overtakeModeBoostPct` — Overtake Mode: level gain (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/director.lua:845, src/groups.lua:43, src/lang_en.lua:151, src/lang_en.lua:273, src/tips_en.lua:167 |
| rules | `drsAssist` — Player DRS: beep and panel | boolean | true / true / true / true | src/engine.lua:377, src/engine.lua:583, src/engine.lua:649, src/groups.lua:44, src/lang_en.lua:152, src/panel.lua:114, src/panel.lua:147, src/tips_en.lua:126 |
| rules | `rulesDrs` — DRS: racing rules (rain, flags, start, Safety Car, red flag) | boolean | false / true / true / true | src/engine.lua:530, src/groups.lua:44, src/lang_en.lua:152, src/lang_en.lua:260, src/lang_en.lua:273, src/tips_en.lua:123 |
| rules | `rulesDrsLaps` — DRS: leader laps before enabling (start, SC, red flag) | 0 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:554, src/groups.lua:44, src/lang_en.lua:152, src/lang_en.lua:273, src/tips_en.lua:124 |
| rules | `aiDrs` — AI DRS: opened in the zones | boolean | true / true / true / true | src/engine.lua:568, src/groups.lua:44, src/lang_en.lua:152, src/tips_en.lua:125 |
| rules | `drsBeepVolume` — Beeps (DRS and delta): volume (%) | 25 to 400 | 200 / 200 / 200 / 200 | src/engine.lua:377, src/engine.lua:523, src/engine.lua:649, src/groups.lua:44, src/lang_en.lua:152, src/lang_en.lua:274, src/tips_en.lua:122 |
| rules | `bopEnabled` — BoP: pace evened out within each class | boolean | false / false / false / false | src/classes.lua:42, src/director.lua:102, src/groups.lua:45, src/lang_en.lua:153, src/lang_en.lua:274, src/tips_en.lua:168 |
| rules | `bopStrengthPct` — BoP: maximum correction (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/classes.lua:45, src/groups.lua:45, src/lang_en.lua:153, src/tips_en.lua:169 |
| rules | `proAmEnabled` — Pro-Am driver ratings (Bronze to Platinum) | boolean | false / false / false / false | src/groups.lua:45, src/lang_en.lua:153, src/persona.lua:31, src/persona.lua:32, src/tips_en.lua:170 |
| rules | `predictableSlowClass` — Slower class: predictable line | boolean | false / false / false / false | src/director.lua:546, src/groups.lua:46, src/lang_en.lua:153, src/tips_en.lua:171 |
| endurance | `enduranceOverlay` — Endurance layer | boolean | false / false / false / false | src/director.lua:103, src/director.lua:399, src/director.lua:800, src/groups.lua:35, src/lang_en.lua:154, src/persona.lua:6, src/tips_en.lua:173 |
| endurance | `multiClass` — Multi-class | boolean | false / false / false / false | src/delta.lua:122, src/director.lua:74, src/director.lua:895, src/engine.lua:243, src/engine.lua:435, src/engine.lua:594, src/engine.lua:660, src/groups.lua:36, src/incidents.lua:430, src/lang_en.lua:154, src/tips_en.lua:174 |
| endurance | `classGapPct` — Gap between classes (%) | 3 to 25 | 8 / 8 / 8 / 8 | src/classes.lua:31, src/groups.lua:36, src/lang_en.lua:154, src/tips_en.lua:175 |
| endurance | `classYieldMargin` — Class speed advantage (km/h) | 1 to 15 | 4 / 4 / 4 / 4 | src/director.lua:300, src/director.lua:561, src/groups.lua:36, src/lang_en.lua:154, src/tips_en.lua:176 |
| endurance | `stintLevelSwing` — Variation between stints (%) | 0 to 8 | 3 / 3 / 3 / 3 | src/groups.lua:35, src/lang_en.lua:154, src/persona.lua:28, src/tips_en.lua:177 |
| endurance | `stintDegradationPct` — Degradation over a stint (%) | 0 to 5 | 1 / 1 / 1 / 1 | src/director.lua:104, src/groups.lua:35, src/lang_en.lua:154, src/tips_en.lua:178 |
| weather | `weatherAdaptation` — Adapt pace to the weather | boolean | true / true / true / true | src/director.lua:107, src/director.lua:320, src/groups.lua:37, src/lang_en.lua:155, src/tips_en.lua:180 |
| weather | `weatherTyresEnabled` — Manage dry and wet tyres | boolean | true / true / true / true | src/engine.lua:668, src/groups.lua:37, src/lang_en.lua:155, src/tips_en.lua:181, src/weather.lua:25 |
| weather | `weatherMessage` — On-screen message on a weather change | boolean | true / true / true / true | src/engine.lua:674, src/groups.lua:38, src/lang_en.lua:155, src/lang_en.lua:269, src/tips_en.lua:182 |
| weather | `rainGripBoostPct` — Rain compensation without wet tyres (%) | 0 to 30 | 15 / 15 / 15 / 15 | src/groups.lua:37, src/lang_en.lua:155, src/lang_en.lua:268, src/tips_en.lua:183, src/weather.lua:38 |
| traffic | `trafficGapSeconds` — Base gap (s) | 0.5 to 5 | 2.5 / 2.5 / 2.5 / 2.5 | src/groups.lua:28, src/lang_en.lua:156, src/tips_en.lua:185, src/traffic.lua:209 |
| traffic | `trafficDensityGain` — Distance added per AI (m) | 0.5 to 5 | 2.8 / 2.8 / 2.8 / 2.8 | src/groups.lua:28, src/lang_en.lua:156, src/tips_en.lua:186, src/traffic.lua:209 |
| traffic | `trafficVariation` — Gap variation (%) | 0 to 50 | 45 / 45 / 45 / 45 | src/groups.lua:28, src/lang_en.lua:156, src/tips_en.lua:187, src/traffic.lua:208 |
| traffic | `trafficMaxReduction` — Maximum speed reduction (%) | 2 to 20 | 14 / 14 / 14 / 14 | src/groups.lua:28, src/lang_en.lua:156, src/tips_en.lua:188, src/traffic.lua:219 |

## Adjustable global options

| Key | Default | Range | Consumers |
|---|---|---|---|
| `levelMode` | auto | auto, native, grip, none | src/applier.lua:878, src/applier.lua:885, src/caps.lua:4, src/caps.lua:52, src/caps.lua:53, src/lang_en.lua:60, src/tips_en.lua:205 |
| `useGripBoost` | false | boolean | src/applier.lua:885, src/caps.lua:53, src/tips_en.lua:206 |
| `gripPerLevelPct` | 0.004 | [0, 0.01] | src/applier.lua:885, src/lang_en.lua:125, src/tips_en.lua:217 |
| `useBrakeAssist` | true | boolean | src/applier.lua:866, src/applier.lua:892, src/director.lua:764, src/engine.lua:41, src/tips_en.lua:207 |
| `overrideAwareness` | false | boolean | src/applier.lua:873, src/tips_en.lua:208 |
| `occLatMin` | 0.3 | [0.1, 1] | src/lang_en.lua:125, src/lang_en.lua:276, src/perception.lua:53, src/perception.lua:54, src/perception.lua:55, src/tips_en.lua:213 |
| `occLatMax` | 5.5 | [2, 8] | src/director.lua:452, src/director.lua:526, src/director.lua:597, src/director.lua:626, src/director.lua:720, src/lang_en.lua:125, src/lang_en.lua:276, src/perception.lua:42, src/perception.lua:47, src/perception.lua:54, src/perception.lua:55, src/perception.lua:105, src/tips_en.lua:214 |
| `occMargin` | 6 | [2, 15] | src/lang_en.lua:125, src/lang_en.lua:276, src/perception.lua:45, src/perception.lua:50, src/tips_en.lua:215 |
| `occSpeedGain` | 0.8 | [0, 2] | src/lang_en.lua:125, src/lang_en.lua:276, src/perception.lua:45, src/perception.lua:50, src/tips_en.lua:216 |
| `seed` | 19731019 | [0, 2147483647] | src/director.lua:54, src/director.lua:341, src/director.lua:398, src/director.lua:648, src/director.lua:802, src/engine.lua:93, src/engine.lua:167, src/engine.lua:337, src/engine.lua:433, src/engine.lua:662, src/engine.lua:682, src/engine.lua:722, src/flash.lua:70, src/grid.lua:163, src/grid.lua:195, src/incidents.lua:155, src/incidents.lua:233, src/lang_en.lua:61, src/mistakes.lua:65, src/mistakes.lua:74, src/persona.lua:5, src/persona.lua:8, src/persona.lua:9, src/persona.lua:28, src/persona.lua:30, src/persona.lua:37, src/persona.lua:40, src/persona.lua:42, src/persona.lua:43, src/persona.lua:44, src/pits.lua:46, src/pits.lua:108, src/tips_en.lua:218, src/tips_en.lua:235, src/tips_en.lua:298, src/traffic.lua:69, src/traffic.lua:86, src/traffic.lua:120, src/traffic.lua:197, src/util.lua:18, src/util.lua:19, src/util.lua:32, src/weather.lua:9, src/weather.lua:11, src/weather.lua:14, src/weather.lua:28 |
| `debugLog` | false | boolean | src/director.lua:71, src/lang_en.lua:61, src/tips_en.lua:212 |

The section switches go through `C.on`/`C.effective` and are walked by the interface tests. `classPatterns` uses the `C.patterns` parser, `Classes.configure/update`, the eight dedicated rows and validated storage. The manual/automatic choice, the main button, panic, presets and the diagnostics tools are examined in AUDIT_V1.md.

## Functions examined

List taken from the AST of the 38 active files, including local and anonymous functions. The review, fixes and limits are in AUDIT_V1.md. This list does not mean 100% branch coverage.

| File | Line | Function |
|---|---|---|
| ACAdvancedIA.lua | 11 | `(anonymous)` |
| ACAdvancedIA.lua | 16 | `none` |
| ACAdvancedIA.lua | 20 | `(anonymous)` |
| ACAdvancedIA.lua | 21 | `(anonymous)` |
| ACAdvancedIA.lua | 21 | `(anonymous)` |
| ACAdvancedIA.lua | 21 | `(anonymous)` |
| ACAdvancedIA.lua | 26 | `(anonymous)` |
| ACAdvancedIA.lua | 39 | `restartOnly` |
| ACAdvancedIA.lua | 40 | `script.update` |
| ACAdvancedIA.lua | 41 | `script.HUMANAI__UPDATE` |
| ACAdvancedIA.lua | 42 | `script.HUMANAI__MAIN` |
| ACAdvancedIA.lua | 43 | `script.HUMANAI__MENU` |
| ACAdvancedIA.lua | 44 | `script.HUMANAI__FLAGS` |
| ACAdvancedIA.lua | 45 | `script.HUMANAI__HUD` |
| ACAdvancedIA.lua | 91 | `announce` |
| ACAdvancedIA.lua | 98 | `dirty` |
| ACAdvancedIA.lua | 106 | `(anonymous)` |
| ACAdvancedIA.lua | 118 | `writeJournal` |
| ACAdvancedIA.lua | 130 | `cancelProbe` |
| ACAdvancedIA.lua | 131 | `syncRestored` |
| ACAdvancedIA.lua | 141 | `anyOwned` |
| ACAdvancedIA.lua | 146 | `step` |
| ACAdvancedIA.lua | 152 | `stop` |
| ACAdvancedIA.lua | 158 | `saveRace` |
| ACAdvancedIA.lua | 164 | `release` |
| ACAdvancedIA.lua | 178 | `updateLog` |
| ACAdvancedIA.lua | 182 | `(anonymous)` |
| ACAdvancedIA.lua | 194 | `(anonymous)` |
| ACAdvancedIA.lua | 212 | `session` |
| ACAdvancedIA.lua | 219 | `lightsCheck` |
| ACAdvancedIA.lua | 226 | `update` |
| ACAdvancedIA.lua | 250 | `(anonymous)` |
| ACAdvancedIA.lua | 251 | `(anonymous)` |
| ACAdvancedIA.lua | 351 | `updateTick` |
| ACAdvancedIA.lua | 371 | `protect` |
| ACAdvancedIA.lua | 384 | `script.HUMANAI__UPDATE` |
| ACAdvancedIA.lua | 398 | `script.update` |
| ACAdvancedIA.lua | 399 | `script.HUMANAI__MENU` |
| ACAdvancedIA.lua | 402 | `protectUI` |
| ACAdvancedIA.lua | 410 | `script.HUMANAI__MAIN` |
| ACAdvancedIA.lua | 422 | `script.HUMANAI__FLAGS` |
| ACAdvancedIA.lua | 424 | `script.HUMANAI__HUD` |
| src/applier.lua | 14 | `note` |
| src/applier.lua | 17 | `callable` |
| src/applier.lua | 25 | `initClock` |
| src/applier.lua | 33 | `present` |
| src/applier.lua | 39 | `setBrake` |
| src/applier.lua | 44 | `setFlash` |
| src/applier.lua | 45 | `write` |
| src/applier.lua | 61 | `(anonymous)` |
| src/applier.lua | 65 | `M.new` |
| src/applier.lua | 74 | `(anonymous)` |
| src/applier.lua | 84 | `M.clock` |
| src/applier.lua | 94 | `M.access` |
| src/applier.lua | 101 | `M.openStore` |
| src/applier.lua | 128 | `M.savePreset` |
| src/applier.lua | 134 | `(anonymous)` |
| src/applier.lua | 142 | `M.deletePreset` |
| src/applier.lua | 144 | `(anonymous)` |
| src/applier.lua | 149 | `readRaceFlagsHidden` |
| src/applier.lua | 152 | `M.readFlagsHidden` |
| src/applier.lua | 156 | `M.menu` |
| src/applier.lua | 170 | `M.compactWindow` |
| src/applier.lua | 174 | `(anonymous)` |
| src/applier.lua | 176 | `(anonymous)` |
| src/applier.lua | 181 | `M.baselines` |
| src/applier.lua | 187 | `M.dirty` |
| src/applier.lua | 188 | `M.rebase` |
| src/applier.lua | 199 | `M.save` |
| src/applier.lua | 202 | `(anonymous)` |
| src/applier.lua | 214 | `restoreRain` |
| src/applier.lua | 218 | `restoreSkin` |
| src/applier.lua | 222 | `(anonymous)` |
| src/applier.lua | 226 | `M.restore` |
| src/applier.lua | 276 | `send` |
| src/applier.lua | 284 | `field` |
| src/applier.lua | 289 | `claim` |
| src/applier.lua | 298 | `weather` |
| src/applier.lua | 325 | `tyreLabel` |
| src/applier.lua | 331 | `pitRequest` |
| src/applier.lua | 391 | `startDelay` |
| src/applier.lua | 401 | `place` |
| src/applier.lua | 417 | `hold` |
| src/applier.lua | 432 | `flagText` |
| src/applier.lua | 437 | `unwritten` |
| src/applier.lua | 444 | `redHidden` |
| src/applier.lua | 455 | `nativeFree` |
| src/applier.lua | 456 | `M.flag` |
| src/applier.lua | 486 | `M.reportCaps` |
| src/applier.lua | 496 | `gridNode` |
| src/applier.lua | 503 | `M.gridNodes` |
| src/applier.lua | 519 | `folder` |
| src/applier.lua | 520 | `lightsRead` |
| src/applier.lua | 557 | `M.trackLights` |
| src/applier.lua | 566 | `flash` |
| src/applier.lua | 578 | `safetySkin` |
| src/applier.lua | 582 | `(anonymous)` |
| src/applier.lua | 584 | `(anonymous)` |
| src/applier.lua | 591 | `safety` |
| src/applier.lua | 599 | `(anonymous)` |
| src/applier.lua | 634 | `recover` |
| src/applier.lua | 644 | `M.releaseBlackFlag` |
| src/applier.lua | 651 | `M.penalty` |
| src/applier.lua | 665 | `disposeBeep` |
| src/applier.lua | 665 | `(anonymous)` |
| src/applier.lua | 666 | `M.beep` |
| src/applier.lua | 674 | `play` |
| src/applier.lua | 687 | `M.deltaBeep` |
| src/applier.lua | 694 | `(anonymous)` |
| src/applier.lua | 698 | `play` |
| src/applier.lua | 703 | `(anonymous)` |
| src/applier.lua | 708 | `M.drs` |
| src/applier.lua | 732 | `releaseDrs` |
| src/applier.lua | 739 | `M.sessionBox` |
| src/applier.lua | 740 | `M.screen` |
| src/applier.lua | 746 | `M.listenMessages` |
| src/applier.lua | 750 | `M.blockMessages` |
| src/applier.lua | 754 | `M.dispose` |
| src/applier.lua | 760 | `scriptFolder` |
| src/applier.lua | 765 | `M.fontDir` |
| src/applier.lua | 767 | `(anonymous)` |
| src/applier.lua | 776 | `M.appFile` |
| src/applier.lua | 784 | `M.journalOpen` |
| src/applier.lua | 786 | `(anonymous)` |
| src/applier.lua | 802 | `M.clockText` |
| src/applier.lua | 807 | `M.journalWrite` |
| src/applier.lua | 811 | `(anonymous)` |
| src/applier.lua | 816 | `M.storeText` |
| src/applier.lua | 817 | `M.loadText` |
| src/applier.lua | 818 | `M.message` |
| src/applier.lua | 820 | `M.probeMessage` |
| src/applier.lua | 823 | `floodPath` |
| src/applier.lua | 828 | `M.floodRead` |
| src/applier.lua | 837 | `M.floodWrite` |
| src/applier.lua | 843 | `M.apply` |
| src/applier.lua | 908 | `M.register` |
| src/applier.lua | 912 | `M.unregister` |
| src/applier.lua | 914 | `(anonymous)` |
| src/applier.lua | 919 | `M.nextSession` |
| src/applier.lua | 940 | `M.clipboard` |
| src/applier.lua | 941 | `M.checkpoint` |
| src/applier.lua | 952 | `M.recover` |
| src/calibration.lua | 7 | `M.new` |
| src/calibration.lua | 8 | `resetSafe` |
| src/calibration.lua | 18 | `safe` |
| src/calibration.lua | 32 | `M.step` |
| src/calibration.lua | 80 | `M.cancel` |
| src/caps.lua | 3 | `M.new` |
| src/caps.lua | 8 | `M.call` |
| src/caps.lua | 19 | `M.restoreCall` |
| src/caps.lua | 21 | `probeSwapped` |
| src/caps.lua | 22 | `probeRestore` |
| src/caps.lua | 24 | `M.cancelProbe` |
| src/caps.lua | 30 | `M.probe` |
| src/caps.lua | 51 | `M.mode` |
| src/classes.lua | 4 | `M.new` |
| src/classes.lua | 5 | `M.configure` |
| src/classes.lua | 8 | `M.laps` |
| src/classes.lua | 13 | `M.update` |
| src/classes.lua | 41 | `M.balance` |
| src/config.lua | 58 | `M.solo` |
| src/config.lua | 61 | `M.hidden` |
| src/config.lua | 66 | `add` |
| src/config.lua | 72 | `n` |
| src/config.lua | 73 | `b` |
| src/config.lua | 74 | `e` |
| src/config.lua | 329 | `M.defaults` |
| src/config.lua | 338 | `M.sectionsChanged` |
| src/config.lua | 345 | `M.anySection` |
| src/config.lua | 349 | `choice` |
| src/config.lua | 350 | `M.patterns` |
| src/config.lua | 360 | `M.validate` |
| src/config.lua | 390 | `M.validateGlobals` |
| src/config.lua | 411 | `M.preset` |
| src/config.lua | 423 | `M.on` |
| src/config.lua | 424 | `M.any` |
| src/config.lua | 429 | `M.effective` |
| src/config.lua | 460 | `M.effectiveGlobals` |
| src/config.lua | 467 | `M.needsOffset` |
| src/config.lua | 470 | `equal` |
| src/config.lua | 486 | `M.legacyMatch` |
| src/config.lua | 511 | `M.upgradeObstacles` |
| src/config.lua | 522 | `M.migrateProfile` |
| src/config.lua | 578 | `M.migrate` |
| src/config.lua | 642 | `M.kept` |
| src/config.lua | 643 | `ruleValue` |
| src/config.lua | 644 | `M.restore` |
| src/config.lua | 653 | `applyValues` |
| src/config.lua | 657 | `M.weekendSwitch` |
| src/config.lua | 666 | `M.applyRules` |
| src/config.lua | 681 | `M.spreadRules` |
| src/config.lua | 695 | `M.mark` |
| src/config.lua | 699 | `M.setMark` |
| src/config.lua | 705 | `M.withRules` |
| src/config.lua | 716 | `category13` |
| src/config.lua | 730 | `M.migrateRules` |
| src/config.lua | 740 | `M.closestRuleCategory` |
| src/config.lua | 749 | `M.ruleCategory` |
| src/config.lua | 761 | `M.autoProfile` |
| src/delta.lua | 10 | `accumulator` |
| src/delta.lua | 11 | `M.new` |
| src/delta.lua | 17 | `M.reset` |
| src/delta.lua | 21 | `M.rebase` |
| src/delta.lua | 25 | `bin` |
| src/delta.lua | 29 | `M.refresh` |
| src/delta.lua | 59 | `M.pace` |
| src/delta.lua | 67 | `M.reference` |
| src/delta.lua | 75 | `M.zoneReference` |
| src/delta.lua | 81 | `regime` |
| src/delta.lua | 94 | `sectors` |
| src/delta.lua | 97 | `advance` |
| src/delta.lua | 111 | `brakeFloor` |
| src/delta.lua | 112 | `zoneExists` |
| src/delta.lua | 117 | `M.update` |
| src/delta.lua | 186 | `M.penalized` |
| src/director.lua | 15 | `M.newState` |
| src/director.lua | 36 | `M.reset` |
| src/director.lua | 53 | `M.configure` |
| src/director.lua | 59 | `transition` |
| src/director.lua | 74 | `faster` |
| src/director.lua | 75 | `sideFree` |
| src/director.lua | 77 | `userSide` |
| src/director.lua | 78 | `fixedSide` |
| src/director.lua | 79 | `yieldSide` |
| src/director.lua | 86 | `passSide` |
| src/director.lua | 95 | `baseModifiers` |
| src/director.lua | 112 | `directionAllowed` |
| src/director.lua | 129 | `directionBudget` |
| src/director.lua | 139 | `wanted` |
| src/director.lua | 140 | `limitText` |
| src/director.lua | 149 | `M.reachable` |
| src/director.lua | 160 | `laneTarget` |
| src/director.lua | 169 | `laneHold` |
| src/director.lua | 195 | `M.lateral` |
| src/director.lua | 232 | `busy` |
| src/director.lua | 245 | `pace` |
| src/director.lua | 263 | `lapOrClass` |
| src/director.lua | 268 | `yieldTrigger` |
| src/director.lua | 370 | `M.trafficCap` |
| src/director.lua | 380 | `M.step` |
| src/engine.lua | 23 | `startReport` |
| src/engine.lua | 49 | `decisionTime` |
| src/engine.lua | 65 | `contacts` |
| src/engine.lua | 89 | `M.new` |
| src/engine.lua | 97 | `(anonymous)` |
| src/engine.lua | 99 | `(anonymous)` |
| src/engine.lua | 118 | `M.changed` |
| src/engine.lua | 119 | `M.select` |
| src/engine.lua | 122 | `M.reset` |
| src/engine.lua | 126 | `M.rebase` |
| src/engine.lua | 155 | `M.configure` |
| src/engine.lua | 172 | `drsBeep` |
| src/engine.lua | 178 | `drive` |
| src/engine.lua | 192 | `M.message` |
| src/engine.lua | 201 | `M.floodInit` |
| src/engine.lua | 210 | `flood` |
| src/engine.lua | 242 | `slowCars` |
| src/engine.lua | 275 | `M.step` |
| src/flash.lua | 4 | `M.new` |
| src/flash.lua | 13 | `M.learn` |
| src/flash.lua | 14 | `M.sampleLearn` |
| src/flash.lua | 26 | `M.step` |
| src/flash.lua | 43 | `M.advantage` |
| src/flash.lua | 47 | `M.dispatch` |
| src/flood.lua | 12 | `trim` |
| src/flood.lua | 13 | `lines` |
| src/flood.lua | 20 | `header` |
| src/flood.lua | 21 | `keyOf` |
| src/flood.lua | 23 | `M.get` |
| src/flood.lua | 35 | `M.edit` |
| src/flood.lua | 67 | `truthy` |
| src/flood.lua | 69 | `M.state` |
| src/flood.lua | 76 | `round` |
| src/flood.lua | 78 | `M.values` |
| src/flood.lua | 86 | `M.backup` |
| src/flood.lua | 94 | `M.restore` |
| src/flood.lua | 104 | `M.decide` |
| src/grid.lua | 21 | `M.new` |
| src/grid.lua | 25 | `clearCars` |
| src/grid.lua | 26 | `clearPlayer` |
| src/grid.lua | 27 | `M.reset` |
| src/grid.lua | 31 | `M.rebase` |
| src/grid.lua | 38 | `byPosition` |
| src/grid.lua | 44 | `M.sortByPosition` |
| src/grid.lua | 54 | `M.resolve` |
| src/grid.lua | 82 | `M.start` |
| src/grid.lua | 103 | `gap` |
| src/grid.lua | 115 | `approach` |
| src/grid.lua | 128 | `pitStarter` |
| src/grid.lua | 134 | `release` |
| src/grid.lua | 147 | `expected` |
| src/grid.lua | 157 | `placedPlayer` |
| src/grid.lua | 163 | `M.step` |
| src/groups.lua | 54 | `M.build` |
| src/hudinfo.lua | 10 | `M.new` |
| src/hudinfo.lua | 17 | `M.lapTime` |
| src/hudinfo.lua | 23 | `M.clock` |
| src/hudinfo.lua | 29 | `reset` |
| src/hudinfo.lua | 36 | `M.message` |
| src/hudinfo.lua | 48 | `M.flood` |
| src/hudinfo.lua | 55 | `passes` |
| src/hudinfo.lua | 76 | `recap` |
| src/hudinfo.lua | 93 | `item` |
| src/hudinfo.lua | 98 | `strip` |
| src/hudinfo.lua | 115 | `M.update` |
| src/incidents.lua | 8 | `clearCar` |
| src/incidents.lua | 13 | `M.new` |
| src/incidents.lua | 28 | `M.reset` |
| src/incidents.lua | 36 | `M.rebase` |
| src/incidents.lua | 53 | `message` |
| src/incidents.lua | 59 | `note` |
| src/incidents.lua | 62 | `unavailable` |
| src/incidents.lua | 69 | `restart` |
| src/incidents.lua | 81 | `standing` |
| src/incidents.lua | 90 | `restartRule` |
| src/incidents.lua | 93 | `leaderLap` |
| src/incidents.lua | 116 | `release` |
| src/incidents.lua | 127 | `traffic` |
| src/incidents.lua | 141 | `queued` |
| src/incidents.lua | 155 | `M.update` |
| src/incidents.lua | 413 | `M.safety` |
| src/incidents.lua | 423 | `position` |
| src/incidents.lua | 428 | `M.cap` |
| src/incidents.lua | 475 | `M.player` |
| src/journal.lua | 3 | `M.new` |
| src/journal.lua | 5 | `M.collect` |
| src/journal.lua | 14 | `M.take` |
| src/journal.lua | 22 | `M.summary` |
| src/journal.lua | 45 | `c` |
| src/lights.lua | 19 | `M.new` |
| src/lights.lua | 24 | `M.reset` |
| src/lights.lua | 29 | `M.rebase` |
| src/lights.lua | 37 | `slow` |
| src/lights.lua | 68 | `damage` |
| src/lights.lua | 84 | `M.decide` |
| src/lights.lua | 107 | `M.update` |
| src/lights.lua | 118 | `M.output` |
| src/lights.lua | 128 | `M.scan` |
| src/lights.lua | 132 | `close` |
| src/lights.lua | 165 | `M.equipped` |
| src/locale.lua | 12 | `copy` |
| src/locale.lua | 19 | `fill` |
| src/locale.lua | 25 | `texts` |
| src/locale.lua | 30 | `M.valid` |
| src/locale.lua | 32 | `M.set` |
| src/mistakes.lua | 10 | `car` |
| src/mistakes.lua | 11 | `M.new` |
| src/mistakes.lua | 16 | `M.reset` |
| src/mistakes.lua | 20 | `M.rebase` |
| src/mistakes.lua | 32 | `risk` |
| src/mistakes.lua | 43 | `M.update` |
| src/panel.lua | 14 | `M.new` |
| src/panel.lua | 19 | `blue` |
| src/panel.lua | 40 | `native` |
| src/panel.lua | 65 | `show` |
| src/panel.lua | 106 | `M.native` |
| src/panel.lua | 122 | `M.visible` |
| src/panel.lua | 128 | `M.infractions` |
| src/panel.lua | 136 | `M.warn` |
| src/panel.lua | 138 | `M.notice` |
| src/panel.lua | 140 | `M.update` |
| src/penalties.lua | 9 | `M.new` |
| src/penalties.lua | 15 | `clear` |
| src/penalties.lua | 18 | `grant` |
| src/penalties.lua | 19 | `entitled` |
| src/penalties.lua | 20 | `M.reset` |
| src/penalties.lua | 26 | `M.rebase` |
| src/penalties.lua | 39 | `passable` |
| src/penalties.lua | 42 | `serving` |
| src/penalties.lua | 47 | `M.mayPass` |
| src/penalties.lua | 51 | `decide` |
| src/penalties.lua | 58 | `deadline` |
| src/penalties.lua | 62 | `M.update` |
| src/penalties.lua | 138 | `sanction` |
| src/penalties.lua | 150 | `M.ai` |
| src/penalties.lua | 218 | `M.serialize` |
| src/penalties.lua | 228 | `M.restore` |
| src/penalties.lua | 248 | `M.resume` |
| src/perception.lua | 5 | `M.new` |
| src/perception.lua | 14 | `M.relative` |
| src/perception.lua | 34 | `M.occupancy` |
| src/perception.lua | 61 | `M.prepare` |
| src/perception.lua | 73 | `M.refresh` |
| src/perception.lua | 94 | `M.find` |
| src/perception.lua | 98 | `M.corridor` |
| src/persona.lua | 5 | `M.fill` |
| src/persona.lua | 8 | `r` |
| src/persona.lua | 9 | `trait` |
| src/persona.lua | 40 | `M.nextLapse` |
| src/pits.lua | 5 | `clear` |
| src/pits.lua | 9 | `M.new` |
| src/pits.lua | 14 | `M.reset` |
| src/pits.lua | 18 | `M.rebase` |
| src/pits.lua | 23 | `M.progress` |
| src/pits.lua | 30 | `M.compound` |
| src/pits.lua | 40 | `M.repairTime` |
| src/pits.lua | 46 | `M.update` |
| src/pits.lua | 132 | `learn` |
| src/pits.lua | 150 | `lapsLeft` |
| src/pits.lua | 157 | `stintLaps` |
| src/pits.lua | 171 | `M.fuel` |
| src/pits.lua | 201 | `M.serialize` |
| src/pits.lua | 207 | `M.forget` |
| src/pits.lua | 208 | `M.restore` |
| src/presets.lua | 7 | `M.signature` |
| src/presets.lua | 16 | `M.layout` |
| src/presets.lua | 22 | `M.decode` |
| src/presets.lua | 71 | `M.capture` |
| src/presets.lua | 77 | `M.encode` |
| src/presets.lua | 83 | `M.apply` |
| src/remote.lua | 18 | `callable` |
| src/remote.lua | 19 | `folder` |
| src/remote.lua | 26 | `hex` |
| src/remote.lua | 29 | `(anonymous)` |
| src/remote.lua | 33 | `files` |
| src/remote.lua | 34 | `(anonymous)` |
| src/remote.lua | 42 | `rank` |
| src/remote.lua | 46 | `ordered` |
| src/remote.lua | 47 | `(anonymous)` |
| src/remote.lua | 51 | `parseList` |
| src/remote.lua | 63 | `lib` |
| src/remote.lua | 68 | `M.new` |
| src/remote.lua | 83 | `exists` |
| src/remote.lua | 84 | `load` |
| src/remote.lua | 85 | `save` |
| src/remote.lua | 86 | `delete` |
| src/remote.lua | 87 | `clock` |
| src/remote.lua | 90 | `watch` |
| src/remote.lua | 91 | `list` |
| src/remote.lua | 92 | `clear` |
| src/remote.lua | 93 | `copy` |
| src/remote.lua | 96 | `swap` |
| src/remote.lua | 104 | `listOf` |
| src/remote.lua | 105 | `complete` |
| src/remote.lua | 111 | `p.get` |
| src/remote.lua | 113 | `(anonymous)` |
| src/remote.lua | 118 | `p.json` |
| src/remote.lua | 119 | `p.sha256` |
| src/remote.lua | 120 | `p.entries` |
| src/remote.lua | 121 | `p.entry` |
| src/remote.lua | 122 | `p.installedVersion` |
| src/remote.lua | 124 | `p.sourceVersion` |
| src/remote.lua | 125 | `p.sourceComplete` |
| src/remote.lua | 126 | `p.sourceHas` |
| src/remote.lua | 131 | `p.markerFile` |
| src/remote.lua | 132 | `p.marker` |
| src/remote.lua | 134 | `p.mark` |
| src/remote.lua | 136 | `p.clearMarker` |
| src/remote.lua | 141 | `p.report` |
| src/remote.lua | 142 | `p.takeReport` |
| src/remote.lua | 149 | `p.boot` |
| src/remote.lua | 154 | `p.bootSet` |
| src/remote.lua | 155 | `p.bootClear` |
| src/remote.lua | 157 | `p.bootOk` |
| src/remote.lua | 158 | `p.failedNote` |
| src/remote.lua | 159 | `p.failed` |
| src/remote.lua | 160 | `p.clearFailed` |
| src/remote.lua | 162 | `p.log` |
| src/remote.lua | 163 | `p.open` |
| src/remote.lua | 166 | `p.stage` |
| src/remote.lua | 169 | `(anonymous)` |
| src/remote.lua | 182 | `p.snapshot` |
| src/remote.lua | 203 | `p.place` |
| src/remote.lua | 226 | `p.promote` |
| src/remote.lua | 246 | `p.restart` |
| src/snapshot.lua | 4 | `hexByte` |
| src/snapshot.lua | 6 | `collidedWith` |
| src/snapshot.lua | 10 | `damageValues` |
| src/snapshot.lua | 16 | `damageRead` |
| src/snapshot.lua | 21 | `playerDamage` |
| src/snapshot.lua | 28 | `M.new` |
| src/snapshot.lua | 40 | `vector` |
| src/snapshot.lua | 43 | `laneProbe` |
| src/snapshot.lua | 44 | `(anonymous)` |
| src/snapshot.lua | 47 | `readCar` |
| src/snapshot.lua | 126 | `simRead` |
| src/snapshot.lua | 144 | `raceRead` |
| src/snapshot.lua | 152 | `conflictingApp` |
| src/snapshot.lua | 159 | `tyres` |
| src/snapshot.lua | 183 | `M.read` |
| src/snapshot.lua | 206 | `(anonymous)` |
| src/snapshot.lua | 218 | `(anonymous)` |
| src/snapshot.lua | 254 | `M.zones` |
| src/snapshot.lua | 269 | `utf8Char` |
| src/snapshot.lua | 274 | `jsonName` |
| src/snapshot.lua | 294 | `carName` |
| src/snapshot.lua | 303 | `M.carDatabase` |
| src/snapshot.lua | 305 | `(anonymous)` |
| src/snapshot.lua | 309 | `(anonymous)` |
| src/snapshot.lua | 319 | `(anonymous)` |
| src/snapshot.lua | 322 | `menuVisible` |
| src/snapshot.lua | 323 | `M.menu` |
| src/traffic.lua | 5 | `M.new` |
| src/traffic.lua | 24 | `M.mode` |
| src/traffic.lua | 28 | `identity` |
| src/traffic.lua | 31 | `check` |
| src/traffic.lua | 49 | `plan` |
| src/traffic.lua | 69 | `(anonymous)` |
| src/traffic.lua | 126 | `M.exits` |
| src/traffic.lua | 179 | `M.update` |
| src/ui.lua | 22 | `idOf` |
| src/ui.lua | 31 | `fmt` |
| src/ui.lua | 39 | `wrap` |
| src/ui.lua | 41 | `number` |
| src/ui.lua | 45 | `shown` |
| src/ui.lua | 50 | `wrapAll` |
| src/ui.lua | 51 | `globalTips` |
| src/ui.lua | 69 | `ruleView` |
| src/ui.lua | 72 | `ruleCategoryOf` |
| src/ui.lua | 79 | `texts` |
| src/ui.lua | 95 | `same` |
| src/ui.lua | 95 | `(anonymous)` |
| src/ui.lua | 97 | `(anonymous)` |
| src/ui.lua | 106 | `M.new` |
| src/ui.lua | 126 | `(anonymous)` |
| src/ui.lua | 136 | `text` |
| src/ui.lua | 140 | `fontsOnce` |
| src/ui.lua | 144 | `mark` |
| src/ui.lua | 146 | `touch` |
| src/ui.lua | 149 | `presetTarget` |
| src/ui.lua | 158 | `loadBuiltin` |
| src/ui.lua | 172 | `builtinActive` |
| src/ui.lua | 194 | `carDatabase` |
| src/ui.lua | 217 | `input` |
| src/ui.lua | 242 | `valueText` |
| src/ui.lua | 248 | `intText` |
| src/ui.lua | 253 | `shortLabel` |
| src/ui.lua | 255 | `modified` |
| src/ui.lua | 260 | `segmentFits` |
| src/ui.lua | 271 | `settingControl` |
| src/ui.lua | 340 | `hiddenNote` |
| src/ui.lua | 350 | `groupHeight` |
| src/ui.lua | 361 | `drawGroup` |
| src/ui.lua | 385 | `split` |
| src/ui.lua | 401 | `groupColumns` |
| src/ui.lua | 415 | `ruleBlock` |
| src/ui.lua | 462 | `safetyBlock` |
| src/ui.lua | 523 | `patternBlock` |
| src/ui.lua | 577 | `globalSwitch` |
| src/ui.lua | 584 | `globalChoice` |
| src/ui.lua | 592 | `globalSlider` |
| src/ui.lua | 609 | `globalBlock` |
| src/ui.lua | 657 | `statusLines` |
| src/ui.lua | 691 | `switchList` |
| src/ui.lua | 700 | `overlayBlock` |
| src/ui.lua | 778 | `resetSection` |
| src/ui.lua | 793 | `sectionsOn` |
| src/ui.lua | 795 | `modifiedCount` |
| src/ui.lua | 802 | `sectionContent` |
| src/ui.lua | 823 | `language` |
| src/ui.lua | 832 | `updateAct` |
| src/ui.lua | 842 | `megabytes` |
| src/ui.lua | 844 | `updateText` |
| src/ui.lua | 874 | `updateBlock` |
| src/ui.lua | 960 | `stateKey` |
| src/ui.lua | 971 | `live` |
| src/ui.lua | 975 | `headerBar` |
| src/ui.lua | 1107 | `banner` |
| src/ui.lua | 1126 | `addWarning` |
| src/ui.lua | 1129 | `currentSignature` |
| src/ui.lua | 1135 | `entrySignature` |
| src/ui.lua | 1142 | `openTarget` |
| src/ui.lua | 1148 | `kpi` |
| src/ui.lua | 1160 | `homeTab` |
| src/ui.lua | 1424 | `sectionPane` |
| src/ui.lua | 1476 | `settingsTab` |
| src/ui.lua | 1524 | `ruleRow` |
| src/ui.lua | 1533 | `rulesTab` |
| src/ui.lua | 1596 | `diagnosticTab` |
| src/ui.lua | 1827 | `M.compactSize` |
| src/ui.lua | 1830 | `windowSetup` |
| src/ui.lua | 1862 | `drawWindow` |
| src/ui.lua | 1870 | `M.main` |
| src/ui.lua | 1901 | `faded` |
| src/ui.lua | 1902 | `panelPalette` |
| src/ui.lua | 1931 | `box` |
| src/ui.lua | 1935 | `write` |
| src/ui.lua | 1945 | `font` |
| src/ui.lua | 1953 | `fontRelease` |
| src/ui.lua | 1956 | `textWidth` |
| src/ui.lua | 1972 | `fitSize` |
| src/ui.lua | 1980 | `M.flagLayout` |
| src/ui.lua | 2014 | `quad` |
| src/ui.lua | 2019 | `cutBack` |
| src/ui.lua | 2025 | `drsBadge` |
| src/ui.lua | 2032 | `badge` |
| src/ui.lua | 2039 | `checker` |
| src/ui.lua | 2043 | `diagonal` |
| src/ui.lua | 2049 | `meatball` |
| src/ui.lua | 2055 | `stripes` |
| src/ui.lua | 2060 | `startLights` |
| src/ui.lua | 2068 | `deltaText` |
| src/ui.lua | 2078 | `deltaBox` |
| src/ui.lua | 2089 | `placeBox` |
| src/ui.lua | 2099 | `pillsWidth` |
| src/ui.lua | 2101 | `pillRow` |
| src/ui.lua | 2119 | `pill` |
| src/ui.lua | 2126 | `giveBackText` |
| src/ui.lua | 2130 | `blueText` |
| src/ui.lua | 2136 | `lightsCode` |
| src/ui.lua | 2142 | `placeText` |
| src/ui.lua | 2155 | `M.overlayParts` |
| src/ui.lua | 2174 | `M.overlayHeight` |
| src/ui.lua | 2184 | `sessionStrip` |
| src/ui.lua | 2223 | `flags` |
| src/ui.lua | 2330 | `M.flags` |
| src/ui.lua | 2338 | `nativeBox` |
| src/ui.lua | 2342 | `M.restoreNative` |
| src/ui.lua | 2343 | `screenSize` |
| src/ui.lua | 2346 | `hudContent` |
| src/ui.lua | 2381 | `M.hud` |
| src/ui.lua | 2398 | `(anonymous)` |
| src/update.lua | 38 | `M.version` |
| src/update.lua | 45 | `M.label` |
| src/update.lua | 47 | `M.newer` |
| src/update.lua | 53 | `str` |
| src/update.lua | 54 | `starts` |
| src/update.lua | 56 | `M.cut` |
| src/update.lua | 63 | `M.notes` |
| src/update.lua | 77 | `M.release` |
| src/update.lua | 99 | `M.digest` |
| src/update.lua | 107 | `safe` |
| src/update.lua | 117 | `M.content` |
| src/update.lua | 128 | `M.files` |
| src/update.lua | 135 | `M.requires` |
| src/update.lua | 151 | `M.manifestVersion` |
| src/update.lua | 156 | `M.stopped` |
| src/update.lua | 162 | `M.new` |
| src/update.lua | 167 | `event` |
| src/update.lua | 173 | `M.take` |
| src/update.lua | 180 | `M.busy` |
| src/update.lua | 187 | `fail` |
| src/update.lua | 193 | `parse` |
| src/update.lua | 202 | `M.parseReport` |
| src/update.lua | 214 | `bootCheck` |
| src/update.lua | 235 | `M.recover` |
| src/update.lua | 277 | `(anonymous)` |
| src/update.lua | 278 | `(anonymous)` |
| src/update.lua | 279 | `(anonymous)` |
| src/update.lua | 280 | `(anonymous)` |
| src/update.lua | 281 | `(anonymous)` |
| src/update.lua | 282 | `(anonymous)` |
| src/update.lua | 283 | `(anonymous)` |
| src/update.lua | 284 | `(anonymous)` |
| src/update.lua | 285 | `M.recoverText` |
| src/update.lua | 292 | `M.start` |
| src/update.lua | 320 | `live` |
| src/update.lua | 322 | `M.check` |
| src/update.lua | 326 | `(anonymous)` |
| src/update.lua | 340 | `M.cancel` |
| src/update.lua | 348 | `place` |
| src/update.lua | 378 | `M.install` |
| src/update.lua | 390 | `(anonymous)` |
| src/update.lua | 395 | `(anonymous)` |
| src/update.lua | 403 | `(anonymous)` |
| src/update.lua | 406 | `(anonymous)` |
| src/update.lua | 419 | `M.rollback` |
| src/update.lua | 429 | `M.tick` |
| src/update.lua | 453 | `M.view` |
| src/update.lua | 472 | `M.fresh` |
| src/update.lua | 479 | `M.offered` |
| src/util.lua | 4 | `M.finite` |
| src/util.lua | 5 | `M.clamp` |
| src/util.lua | 6 | `M.number` |
| src/util.lua | 7 | `M.lerp` |
| src/util.lua | 8 | `M.sign` |
| src/util.lua | 9 | `M.wrap` |
| src/util.lua | 10 | `M.spline` |
| src/util.lua | 11 | `M.approach` |
| src/util.lua | 12 | `M.ema` |
| src/util.lua | 14 | `M.imul` |
| src/util.lua | 18 | `M.hash` |
| src/util.lua | 24 | `M.random` |
| src/util.lua | 32 | `M.unit` |
| src/util.lua | 33 | `M.newLog` |
| src/util.lua | 38 | `M.log` |
| src/util.lua | 54 | `M.wrapText` |
| src/weather.lua | 5 | `M.new` |
| src/weather.lua | 9 | `M.dryChoice` |
| src/weather.lua | 14 | `M.step` |
| src/widgets.lua | 13 | `hex` |
| src/widgets.lua | 20 | `W.colors` |
| src/widgets.lua | 55 | `forget` |
| src/widgets.lua | 57 | `W.setFonts` |
| src/widgets.lua | 62 | `W.fonts` |
| src/widgets.lua | 65 | `use` |
| src/widgets.lua | 72 | `release` |
| src/widgets.lua | 74 | `level` |
| src/widgets.lua | 76 | `role` |
| src/widgets.lua | 80 | `W.upper` |
| src/widgets.lua | 90 | `vec` |
| src/widgets.lua | 96 | `W.point` |
| src/widgets.lua | 101 | `W.begin` |
| src/widgets.lua | 114 | `W.frame` |
| src/widgets.lua | 115 | `W.rect` |
| src/widgets.lua | 119 | `W.frameRect` |
| src/widgets.lua | 123 | `W.line` |
| src/widgets.lua | 124 | `W.circle` |
| src/widgets.lua | 126 | `canQuad` |
| src/widgets.lua | 131 | `W.quad` |
| src/widgets.lua | 140 | `W.tri` |
| src/widgets.lua | 147 | `W.para` |
| src/widgets.lua | 152 | `W.panel` |
| src/widgets.lua | 158 | `W.text` |
| src/widgets.lua | 162 | `count` |
| src/widgets.lua | 163 | `width` |
| src/widgets.lua | 174 | `fitted` |
| src/widgets.lua | 193 | `tail` |
| src/widgets.lua | 202 | `W.shrink` |
| src/widgets.lua | 206 | `W.cell` |
| src/widgets.lua | 208 | `W.right` |
| src/widgets.lua | 210 | `W.lines` |
| src/widgets.lua | 227 | `W.paragraph` |
| src/widgets.lua | 233 | `W.lineHeight` |
| src/widgets.lua | 235 | `inside` |
| src/widgets.lua | 245 | `W.help` |
| src/widgets.lua | 250 | `hashId` |
| src/widgets.lua | 254 | `W.hit` |
| src/widgets.lua | 263 | `W.mouseX` |
| src/widgets.lua | 265 | `W.marker` |
| src/widgets.lua | 270 | `bar` |
| src/widgets.lua | 274 | `W.heading` |
| src/widgets.lua | 288 | `W.label` |
| src/widgets.lua | 289 | `W.labelWidth` |
| src/widgets.lua | 292 | `W.titleFit` |
| src/widgets.lua | 301 | `buttonStyle` |
| src/widgets.lua | 312 | `W.button` |
| src/widgets.lua | 328 | `W.link` |
| src/widgets.lua | 335 | `W.linkWidth` |
| src/widgets.lua | 337 | `W.icon` |
| src/widgets.lua | 352 | `W.switchShape` |
| src/widgets.lua | 358 | `W.switch` |
| src/widgets.lua | 366 | `W.toggle` |
| src/widgets.lua | 381 | `chipStyle` |
| src/widgets.lua | 386 | `W.chipWidth` |
| src/widgets.lua | 387 | `W.chip` |
| src/widgets.lua | 392 | `W.chipRight` |
| src/widgets.lua | 398 | `W.choiceIds` |
| src/widgets.lua | 404 | `W.segment` |
| src/widgets.lua | 444 | `W.segmentFits` |
| src/widgets.lua | 450 | `W.cycle` |
| src/widgets.lua | 463 | `W.tile` |
| src/widgets.lua | 482 | `W.row` |
| src/widgets.lua | 492 | `W.nav` |
| src/widgets.lua | 504 | `W.slider` |
| src/widgets.lua | 528 | `W.pm` |
| src/widgets.lua | 538 | `W.inputFrame` |
| src/widgets.lua | 545 | `W.message` |
| src/widgets.lua | 555 | `W.scroll` |
| src/widgets.lua | 570 | `W.clip` |
| src/widgets.lua | 574 | `W.visible` |
| src/widgets.lua | 580 | `tipColors` |
| src/widgets.lua | 591 | `W.finish` |
| src/widgets.lua | 603 | `W.step` |
| src/zones.lua | 6 | `M.parse` |
| src/zones.lua | 9 | `skip` |
| src/zones.lua | 17 | `token` |
| src/zones.lua | 18 | `value` |
| src/zones.lua | 67 | `M.at` |
| src/zones.lua | 77 | `M.export` |
