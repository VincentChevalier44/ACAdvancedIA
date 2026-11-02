# Settings and functions inventory Beta 1.33

This inventory links every declared parameter to its consumers. A static reference shows a connection, not proof of a physical result. The `PARAMETER_BOUNDARY_ENGINE` tests and the two full walks through the interface complete this trace.

| Section | Parameter | Range | Default J / P / Q / C | Consumers |
|---|---|---|---|---|
| general | `levelPct` — Level (%) | 40 to 110 | 95 / 100 / 100 / 100 | src/director.lua:98, src/lang_en.lua:128, src/mistakes.lua:33, src/tips_en.lua:6 |
| general | `aggressionPct` — Aggression (%) | 0 to 100 | 55 / 45 / 45 / 80 | src/director.lua:99, src/director.lua:810, src/lang_en.lua:128, src/tips_en.lua:7 |
| general | `caution` — Caution | 0.5 to 8 | 1.6 / 2.2 / 2.2 / 1.2 | src/applier.lua:10, src/applier.lua:69, src/applier.lua:265, src/applier.lua:270, src/applier.lua:293, src/applier.lua:785, src/applier.lua:791, src/applier.lua:855, src/applier.lua:875, src/caps.lua:2, src/director.lua:100, src/director.lua:102, src/director.lua:105, src/director.lua:107, src/director.lua:108, src/director.lua:453, src/director.lua:454, src/director.lua:483, src/director.lua:518, src/director.lua:550, src/director.lua:631, src/director.lua:633, src/director.lua:752, src/director.lua:753, src/director.lua:755, src/director.lua:756, src/director.lua:774, src/director.lua:794, src/director.lua:810, src/director.lua:813, src/director.lua:815, src/director.lua:861, src/director.lua:867, src/director.lua:870, src/engine.lua:110, src/engine.lua:157, src/engine.lua:435, src/engine.lua:487, src/lang_en.lua:59, src/lang_en.lua:62, src/lang_en.lua:128, src/lang_en.lua:162, src/tips_en.lua:8, src/tips_en.lua:9, src/tips_en.lua:12, src/tips_en.lua:64, src/tips_en.lua:99, src/tips_en.lua:171, src/tips_en.lua:178, src/tips_en.lua:220, src/tips_en.lua:227, src/tips_en.lua:236 |
| general | `brakeZonePct` — Emulated braking zone (%) | 50 to 150 | 100 / 100 / 100 / 100 | src/director.lua:815, src/lang_en.lua:128, src/tips_en.lua:9 |
| general | `paceSpreadPct` — Level spread (%) | 0 to 20 | 8 / 3 / 3 / 2 | src/lang_en.lua:128, src/persona.lua:13, src/tips_en.lua:10 |
| general | `aggrSpreadPct` — Aggression spread (%) | 0 to 30 | 12 / 8 / 8 / 10 | src/lang_en.lua:128, src/persona.lua:14, src/tips_en.lua:11 |
| general | `cautSpreadPct` — Caution spread (%) | 0 to 30 | 12 / 8 / 8 / 8 | src/lang_en.lua:128, src/persona.lua:15, src/tips_en.lua:12 |
| general | `pitExitSpread` — Staggered pit exits, practice and qualifying (s per AI, 0 = free) | 0 to 30 | 0 / 10 / 10 / 0 | src/lang_en.lua:128, src/tips_en.lua:13, src/traffic.lua:17, src/traffic.lua:52, src/traffic.lua:115 |
| general | `spawnMode` — AI distribution at session start | native, pits, track | track / pits / pits / native | src/flood.lua:105, src/lang_en.lua:128, src/tips_en.lua:14, src/traffic.lua:26 |
| general | `spawnMinCars` — Spread from (AI) | 2 to 60 | 10 / 10 / 10 / 10 | src/engine.lua:230, src/flood.lua:106, src/lang_en.lua:128, src/tips_en.lua:17, src/traffic.lua:10, src/traffic.lua:67 |
| general | `spawnPitPct` — AI left in the pits at the start (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/lang_en.lua:128, src/tips_en.lua:15, src/traffic.lua:72, src/traffic.lua:74 |
| general | `spawnGapVariation` — Start gap variation (%) | 0 to 100 | 100 / 100 / 100 / 100 | src/lang_en.lua:128, src/tips_en.lua:16, src/traffic.lua:80, src/traffic.lua:83 |
| general | `floodRangeKm` — CSP AI flood range, below the threshold (km) | 1 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:215, src/engine.lua:230, src/engine.lua:231, src/lang_en.lua:128, src/tips_en.lua:18 |
| yield | `yieldEnabled` — Standard yielding | boolean | true / true / true / false | src/director.lua:314, src/director.lua:561, src/lang_en.lua:129, src/tips_en.lua:20 |
| yield | `yieldSide` — Yield side | left, right, auto | right / right / right / right | src/director.lua:79, src/director.lua:80, src/director.lua:87, src/director.lua:90, src/director.lua:353, src/director.lua:520, src/lang_en.lua:129, src/persona.lua:23, src/tips_en.lua:21 |
| yield | `yieldOffset` — Yield offset | 0.2 to 0.95 | 0.65 / 0.8 / 0.8 / 0.6 | src/director.lua:545, src/lang_en.lua:129, src/tips_en.lua:22 |
| yield | `yieldDetectBehind` — Rear detection (m) | 30 to 400 | 100 / 200 / 200 / 80 | src/director.lua:320, src/lang_en.lua:129, src/tips_en.lua:23 |
| yield | `yieldBehindMargin` — Follower speed advantage (km/h) | 1 to 30 | 6 / 4 / 4 / 6 | src/director.lua:274, src/director.lua:317, src/director.lua:561, src/lang_en.lua:129, src/tips_en.lua:24 |
| yield | `yieldHorizon` — Rear horizon (s) | 3 to 30 | 10 / 12 / 12 / 8 | src/director.lua:318, src/lang_en.lua:129, src/tips_en.lua:25 |
| yield | `confirmTime` — Confirmation (s) | 0.1 to 2 | 0.6 / 0.4 / 0.4 / 0.5 | src/director.lua:334, src/director.lua:720, src/lang_en.lua:129, src/tips_en.lua:26 |
| yield | `yieldHoldMin` — Minimum hold (s) | 0.3 to 5 | 1 / 1 / 1 / 1 | src/director.lua:361, src/director.lua:562, src/director.lua:577, src/flash.lua:78, src/lang_en.lua:130, src/tips_en.lua:27 |
| yield | `yieldHoldAfterMin` — Hold after the pass, min. (s) | 0.2 to 6 | 0.8 / 0.6 / 0.6 / 0.8 | src/lang_en.lua:130, src/persona.lua:27, src/persona.lua:35, src/tips_en.lua:28 |
| yield | `yieldHoldAfterMax` — Hold after the pass, max. (s) | 0.2 to 6 | 2.2 / 1.6 / 1.6 / 1.8 | src/lang_en.lua:130, src/persona.lua:27, src/persona.lua:35, src/tips_en.lua:29 |
| yield | `yieldSlowdownPct` — Slowdown while yielding (%) | 0 to 20 | 6 / 8 / 8 / 6 | src/director.lua:549, src/director.lua:818, src/lang_en.lua:130, src/tips_en.lua:30 |
| yield | `inviteSlowdownPct` — Extra slowdown to invite a pass (%) | 0 to 25 | 10 / 10 / 10 / 10 | src/director.lua:554, src/lang_en.lua:130, src/tips_en.lua:31 |
| yield | `yieldMaxHold` — Maximum yield duration (s) | 8 to 60 | 25 / 25 / 25 / 25 | src/director.lua:579, src/flash.lua:45, src/lang_en.lua:130, src/tips_en.lua:32 |
| yield | `pressureEnabled` — Reaction to pressure | boolean | true / true / true / false | src/director.lua:324, src/director.lua:330, src/lang_en.lua:131, src/tips_en.lua:33 |
| yield | `pressureGap` — Pressure distance (m) | 5 to 30 | 15 / 15 / 15 / 15 | src/director.lua:324, src/director.lua:327, src/lang_en.lua:131, src/tips_en.lua:34 |
| yield | `pressureTime` — Pressure duration (s) | 1 to 15 | 4 / 3 / 3 / 4 | src/director.lua:330, src/lang_en.lua:131, src/tips_en.lua:35 |
| blue | `blueFlagEnabled` — Blue flags | boolean | false / true / true / true | src/director.lua:264, src/director.lua:886, src/engine.lua:40, src/lang_en.lua:132, src/panel.lua:19, src/tips_en.lua:37 |
| blue | `blueFlagRange` — Blue flag range (m) | 50 to 400 | 150 / 200 / 200 / 150 | src/director.lua:296, src/director.lua:886, src/director.lua:894, src/engine.lua:40, src/lang_en.lua:132, src/panel.lua:28, src/tips_en.lua:38 |
| blue | `blueFlagSide` — Side under blue flag | auto, left, right | auto / auto / auto / auto | src/director.lua:80, src/lang_en.lua:132, src/tips_en.lua:39 |
| flash | `flashMode` — Headlight flashes | never, lapped, always | always / always / always / lapped | src/director.lua:305, src/flash.lua:50, src/flash.lua:59, src/lang_en.lua:133, src/tips_en.lua:41 |
| flash | `flashRange` — Flash range (m) | 40 to 250 | 200 / 200 / 200 / 150 | src/director.lua:283, src/director.lua:289, src/director.lua:321, src/director.lua:436, src/director.lua:440, src/engine.lua:641, src/engine.lua:642, src/flash.lua:58, src/lang_en.lua:133, src/tips_en.lua:42 |
| flash | `flashMinAdvantage` — Speed advantage for a flash (km/h) | 3 to 40 | 12 / 8 / 8 / 15 | src/director.lua:825, src/flash.lua:45, src/lang_en.lua:133, src/tips_en.lua:43 |
| flash | `flashCloseAdvantage` — Close-range advantage (km/h) | -10 to 15 | -5 / -5 / -5 / 6 | src/flash.lua:44, src/lang_en.lua:133, src/tips_en.lua:44 |
| flash | `flashRequestTTL` — Request lifetime (s) | 3 to 20 | 8 / 8 / 8 / 8 | src/director.lua:834, src/flash.lua:73, src/flash.lua:74, src/lang_en.lua:133, src/tips_en.lua:45 |
| flash | `flashObliviousPct` — First flash missed (%) | 0 to 40 | 10 / 5 / 5 / 10 | src/flash.lua:70, src/lang_en.lua:133, src/tips_en.lua:46 |
| flash | `flashMaxReactors` — Cars reacting | 1 to 3 | 3 / 3 / 3 / 3 | src/flash.lua:67, src/lang_en.lua:133, src/tips_en.lua:47 |
| flash | `hornEnabled` — Horn counts as a flash | boolean | false / false / false / false | src/engine.lua:635, src/engine.lua:636, src/lang_en.lua:133, src/tips_en.lua:48 |
| flash | `aiFlashEnabled` — AI-to-AI headlight flashes | boolean | true / true / true / true | src/director.lua:821, src/lang_en.lua:133, src/tips_en.lua:49 |
| overtake | `overtakeEnabled` — Overtaking | boolean | true / true / true / true | src/director.lua:665, src/director.lua:676, src/lang_en.lua:134, src/tips_en.lua:51 |
| overtake | `overtakeSide` — Overtaking side | opposite, auto, left, right | left / left / left / left | src/director.lua:87, src/director.lua:88, src/director.lua:718, src/lang_en.lua:134, src/tips_en.lua:52 |
| overtake | `overtakeOffset` — Overtaking offset | 0.2 to 0.95 | 0.7 / 0.65 / 0.65 / 0.6 | src/director.lua:583, src/lang_en.lua:134, src/tips_en.lua:53 |
| overtake | `overtakeDetectAhead` — Forward detection (m) | 20 to 200 | 60 / 50 / 50 / 50 | src/director.lua:626, src/director.lua:690, src/lang_en.lua:134, src/tips_en.lua:54 |
| overtake | `overtakeAheadMargin` — Speed advantage to overtake (km/h) | 1 to 30 | 8 / 10 / 10 / 3 | src/director.lua:683, src/lang_en.lua:134, src/tips_en.lua:55 |
| overtake | `overtakeHorizon` — Forward horizon (s) | 2 to 20 | 6 / 6 / 6 / 6 | src/director.lua:690, src/lang_en.lua:134, src/tips_en.lua:56 |
| overtake | `overtakeClearMargin` — Clearance after overtaking (m) | 8 to 40 | 18 / 20 / 20 / 10 | src/director.lua:624, src/director.lua:717, src/lang_en.lua:134, src/tips_en.lua:57 |
| overtake | `overtakeRestTime` — Pause after overtaking (s) | 0 to 10 | 2 / 3 / 3 / 1 | src/director.lua:630, src/lang_en.lua:134, src/tips_en.lua:58 |
| overtake | `overtakeChain` — Chain overtakes | boolean | true / false / false / true | src/director.lua:626, src/lang_en.lua:135, src/tips_en.lua:59 |
| overtake | `stuckTime` — Held-up confirmation (s) | 0.5 to 10 | 2 / 3 / 3 / 1.2 | src/director.lua:692, src/director.lua:825, src/lang_en.lua:135, src/tips_en.lua:60 |
| overtake | `stuckPaceRatio` — Held-up pace threshold | 0.8 to 0.99 | 0.93 / 0.93 / 0.93 / 0.95 | src/director.lua:261, src/lang_en.lua:135, src/tips_en.lua:61 |
| overtake | `pullOutGapBase` — Pull-out distance (m) | 4 to 15 | 8 / 8 / 8 / 8 | src/director.lua:621, src/lang_en.lua:135, src/tips_en.lua:62 |
| overtake | `pullOutGapPerMps` — Pull-out gain (s) | 0 to 0.5 | 0.25 / 0.25 / 0.25 / 0.25 | src/director.lua:621, src/lang_en.lua:135, src/tips_en.lua:63 |
| overtake | `slipstreamEnabled` — Slipstream | boolean | true / true / true / true | src/director.lua:749, src/director.lua:755, src/lang_en.lua:135, src/tips_en.lua:64 |
| overtake | `defenseEnabled` — Defending | boolean | true / true / true / true | src/director.lua:642, src/lang_en.lua:135, src/tips_en.lua:65 |
| overtake | `defenseMaxOffset` — Maximum defending offset | 0.1 to 0.5 | 0.35 / 0.35 / 0.35 / 0.35 | src/director.lua:633, src/lang_en.lua:135, src/tips_en.lua:66 |
| overtake | `defenseCooldown` — Pause between defences (s) | 2 to 30 | 8 / 8 / 8 / 8 | src/director.lua:649, src/lang_en.lua:135, src/tips_en.lua:67 |
| overtake | `defenseTriggerGap` — Defending distance (m) | 5 to 25 | 12 / 12 / 12 / 12 | src/director.lua:642, src/lang_en.lua:135, src/tips_en.lua:68 |
| lateral | `rampSpeed` — Lateral movement speed | 0.1 to 1 | 0.3 / 0.3 / 0.3 / 0.45 | src/director.lua:218, src/lang_en.lua:136, src/tips_en.lua:70 |
| lateral | `rampAccel` — Lateral acceleration | 0.5 to 4 | 1.5 / 1.5 / 1.5 / 2 | src/director.lua:220, src/lang_en.lua:136, src/tips_en.lua:71 |
| lateral | `lowPassTau` — Lateral smoothing (s) | 0.05 to 1 | 0.25 / 0.25 / 0.25 / 0.2 | src/director.lua:221, src/lang_en.lua:136, src/tips_en.lua:72 |
| lateral | `maxSideOffset` — Maximum offset | 0.3 to 0.95 | 0.85 / 0.85 / 0.85 / 0.8 | src/director.lua:152, src/director.lua:526, src/director.lua:545, src/director.lua:633, src/lang_en.lua:136, src/tips_en.lua:73 |
| lateral | `cornerMin` — Straight threshold | 0 to 1 | 0.35 / 0.35 / 0.35 / 0.5 | src/director.lua:280, src/director.lua:351, src/director.lua:372, src/director.lua:666, src/director.lua:675, src/director.lua:822, src/director.lua:845, src/director.lua:860, src/lang_en.lua:136, src/tips_en.lua:74, src/traffic.lua:199 |
| lateral | `cornerYawRef` — Yaw rate reference (rad/s) | 0.2 to 1.2 | 0.5 / 0.5 / 0.5 / 0.5 | src/director.lua:402, src/lang_en.lua:136, src/tips_en.lua:75 |
| lateral | `lateralCooldown` — Pause between direction changes (s) | 0.3 to 5 | 1.2 / 1.2 / 1.2 / 1 | src/director.lua:117, src/director.lua:130, src/lang_en.lua:136, src/tips_en.lua:76 |
| lateral | `emergencyReleaseFactor` — Release factor | 1 to 4 | 2 / 2 / 2 / 2 | src/director.lua:207, src/lang_en.lua:136, src/tips_en.lua:77 |
| human | `reactMin` — Minimum reaction (s) | 0.1 to 2 | 0.25 / 0.2 / 0.2 / 0.2 | src/lang_en.lua:137, src/persona.lua:10, src/tips_en.lua:79 |
| human | `reactMax` — Maximum reaction (s) | 0.1 to 2 | 0.9 / 0.6 / 0.6 / 0.6 | src/lang_en.lua:137, src/persona.lua:10, src/tips_en.lua:80 |
| human | `awMin` — Minimum awareness delay (s) | 0.2 to 5 | 0.6 / 0.4 / 0.4 / 0.4 | src/lang_en.lua:137, src/persona.lua:10, src/tips_en.lua:81 |
| human | `awMax` — Maximum awareness delay (s) | 0.2 to 5 | 2 / 1.2 / 1.2 / 1.2 | src/lang_en.lua:137, src/persona.lua:10, src/tips_en.lua:82 |
| human | `paceDriftPct` — Slow pace drift (%) | 0 to 6 | 2 / 1 / 1 / 1 | src/director.lua:97, src/lang_en.lua:137, src/tips_en.lua:83 |
| human | `personalLineJitter` — Line variation | 0 to 0.15 | 0.05 / 0.03 / 0.03 / 0.02 | src/director.lua:638, src/lang_en.lua:137, src/tips_en.lua:84 |
| human | `lapseEnabled` — Brief lapses in focus | boolean | true / false / false / false | src/director.lua:799, src/lang_en.lua:137, src/tips_en.lua:85 |
| human | `lapseIntervalMin` — Minimum interval (s) | 20 to 900 | 60 / 120 / 120 / 120 | src/lang_en.lua:138, src/persona.lua:24, src/persona.lua:42, src/tips_en.lua:86 |
| human | `lapseIntervalMax` — Maximum interval (s) | 20 to 900 | 300 / 600 / 600 / 600 | src/lang_en.lua:138, src/persona.lua:24, src/persona.lua:42, src/tips_en.lua:87 |
| human | `lapseDurMin` — Minimum duration (s) | 0.5 to 8 | 1.5 / 1 / 1 / 1 | src/lang_en.lua:138, src/persona.lua:25, src/persona.lua:43, src/tips_en.lua:88 |
| human | `lapseDurMax` — Maximum duration (s) | 0.5 to 8 | 3 / 2 / 2 / 2 | src/lang_en.lua:138, src/persona.lua:25, src/persona.lua:43, src/tips_en.lua:89 |
| human | `lapseDropMin` — Minimum pace loss (%) | 0 to 25 | 6 / 3 / 3 / 3 | src/lang_en.lua:138, src/persona.lua:26, src/persona.lua:44, src/tips_en.lua:90 |
| human | `lapseDropMax` — Maximum pace loss (%) | 0 to 25 | 12 / 7 / 7 / 7 | src/lang_en.lua:138, src/persona.lua:26, src/persona.lua:44, src/tips_en.lua:91 |
| human | `laneBiasEnabled` — Pace-based line | boolean | true / false / false / false | src/lang_en.lua:138, src/persona.lua:23, src/tips_en.lua:92 |
| human | `laneBiasMax` — Maximum line bias | 0 to 0.4 | 0.25 / 0.25 / 0.25 / 0.25 | src/lang_en.lua:138, src/persona.lua:23, src/tips_en.lua:93 |
| human | `mistakesEnabled` — AI driving mistakes (lock-ups, wheelspin) | boolean | true / true / true / true | src/lang_en.lua:139, src/mistakes.lua:44, src/tips_en.lua:94 |
| human | `mistakeRate` — Mistakes: rate (per hour per AI) | 0 to 6 | 1 / 0.5 / 0.5 / 0.5 | src/lang_en.lua:139, src/mistakes.lua:44, src/mistakes.lua:65, src/tips_en.lua:95 |
| start | `startDelay` — Start delay (s) | 0 to 30 | 0 / 0 / 0 / 1 | src/applier.lua:11, src/applier.lua:235, src/applier.lua:390, src/applier.lua:391, src/applier.lua:394, src/applier.lua:410, src/applier.lua:560, src/applier.lua:768, src/caps.lua:2, src/director.lua:458, src/director.lua:468, src/director.lua:486, src/director.lua:742, src/director.lua:791, src/director.lua:792, src/engine.lua:110, src/engine.lua:345, src/engine.lua:349, src/engine.lua:353, src/engine.lua:365, src/lang_en.lua:140, src/mistakes.lua:47, src/tips_en.lua:97, src/traffic.lua:17, src/traffic.lua:145, src/traffic.lua:163, src/traffic.lua:167 |
| start | `startCautionMult` — Caution at the start | 1 to 3 | 1 / 1 / 1 / 1.3 | src/director.lua:794, src/engine.lua:40, src/lang_en.lua:140, src/tips_en.lua:99 |
| start | `startAggrMult` — Aggression at the start | 0.2 to 1 | 1 / 1 / 1 / 0.8 | src/director.lua:794, src/engine.lua:40, src/lang_en.lua:140, src/tips_en.lua:100 |
| start | `startRelax` — Settling time after the start (s) | 2 to 30 | 12 / 12 / 12 / 25 | src/director.lua:458, src/director.lua:742, src/director.lua:791, src/director.lua:792, src/engine.lua:353, src/lang_en.lua:140, src/mistakes.lua:47, src/tips_en.lua:101 |
| start | `startLaneHold` — Hold the grid lane at the start | boolean | false / false / false / false | src/director.lua:796, src/engine.lua:40, src/engine.lua:353, src/lang_en.lua:140, src/tips_en.lua:98 |
| accidents | `obstacleEnabled` — Avoid stopped or crashed cars | boolean | true / true / true / true | src/director.lua:486, src/lang_en.lua:141, src/tips_en.lua:103 |
| accidents | `obstacleSpeedKmh` — Obstacle speed (km/h) | 5 to 50 | 25 / 25 / 25 / 25 | src/director.lua:490, src/director.lua:491, src/director.lua:530, src/engine.lua:381, src/incidents.lua:110, src/incidents.lua:150, src/incidents.lua:160, src/incidents.lua:193, src/lang_en.lua:141, src/lights.lua:47, src/penalties.lua:39, src/tips_en.lua:104 |
| accidents | `obstacleDetect` — Obstacle detection (m) | 50 to 300 | 150 / 150 / 150 / 150 | src/director.lua:490, src/director.lua:507, src/lang_en.lua:141, src/tips_en.lua:105 |
| accidents | `obstacleLevelDrop` — Level drop near an obstacle (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/director.lua:518, src/lang_en.lua:141, src/tips_en.lua:106 |
| accidents | `obstacleCautionMult` — Caution near an obstacle | 1 to 3 | 1.5 / 1.5 / 1.5 / 1.5 | src/director.lua:518, src/lang_en.lua:141, src/tips_en.lua:107 |
| accidents | `avoidOffset` — Avoidance offset | 0.3 to 0.9 | 0.6 / 0.6 / 0.6 / 0.6 | src/director.lua:526, src/lang_en.lua:47, src/lang_en.lua:141, src/tips_en.lua:108 |
| accidents | `contactRecovery` — Recovery after contact | boolean | true / true / true / true | src/director.lua:474, src/lang_en.lua:142, src/tips_en.lua:109 |
| accidents | `incidentStop` — Crashed AI stop | boolean | true / true / true / true | src/incidents.lua:191, src/lang_en.lua:142, src/tips_en.lua:110 |
| accidents | `incidentStopMin` — Minimum stop (s) | 1 to 15 | 3 / 3 / 3 / 3 | src/incidents.lua:195, src/lang_en.lua:142, src/tips_en.lua:111 |
| accidents | `incidentStopMax` — Maximum stop (s) | 1 to 30 | 8 / 8 / 8 / 8 | src/incidents.lua:195, src/lang_en.lua:142, src/tips_en.lua:112 |
| accidents | `rejoinGap` — Clear track behind to rejoin (m) | 30 to 300 | 120 / 120 / 120 / 120 | src/incidents.lua:98, src/lang_en.lua:142, src/tips_en.lua:113 |
| accidents | `yellowEnabled` — Yellow flags (incident zone) | boolean | true / true / true / true | src/incidents.lua:379, src/incidents.lua:437, src/lang_en.lua:47, src/lang_en.lua:143, src/lights.lua:39, src/tips_en.lua:114 |
| accidents | `yellowBefore` — Zone start before the incident (m) | 50 to 800 | 300 / 300 / 300 / 300 | src/incidents.lua:369, src/incidents.lua:384, src/incidents.lua:387, src/incidents.lua:442, src/incidents.lua:443, src/incidents.lua:451, src/incidents.lua:452, src/lang_en.lua:143, src/tips_en.lua:118 |
| accidents | `yellowAfter` — Zone end after the incident (m) | 0 to 300 | 50 / 50 / 50 / 50 | src/incidents.lua:384, src/incidents.lua:442, src/lang_en.lua:143, src/tips_en.lua:119 |
| accidents | `yellowHold` — Hold after clearing (s) | 0 to 60 | 10 / 10 / 10 / 10 | src/incidents.lua:182, src/lang_en.lua:143, src/penalties.lua:39, src/tips_en.lua:120 |
| accidents | `yellowDecel` — Approach deceleration (m/s²) | 2 to 10 | 5 / 5 / 5 / 5 | src/delta.lua:146, src/delta.lua:178, src/director.lua:425, src/engine.lua:727, src/incidents.lua:395, src/incidents.lua:434, src/lang_en.lua:143, src/tips_en.lua:121 |
| accidents | `zoneDeltaPct` — Double yellow: reference time slower by (%) | 5 to 200 | 15 / 15 / 15 / 15 | src/delta.lua:77, src/lang_en.lua:47, src/lang_en.lua:144, src/tips_en.lua:116 |
| accidents | `slowZoneKmh` — Double yellow: Slow Zone speed (km/h, 0 = delta time) | 0 to 150 | 0 / 0 / 0 / 0 | src/delta.lua:76, src/lang_en.lua:144, src/tips_en.lua:117 |
| accidents | `yellowSpeedKmh` — Double yellow: fallback speed, unknown pace (km/h) | 30 to 200 | 50 / 50 / 50 / 50 | src/delta.lua:77, src/incidents.lua:433, src/lang_en.lua:144, src/tips_en.lua:115 |
| accidents | `yellowHud` — AC native yellow flag on the HUD | boolean | false / false / false / false | src/incidents.lua:463, src/lang_en.lua:47, src/lang_en.lua:145, src/tips_en.lua:133 |
| accidents | `flagPanel` — ACAdvancedIA flag panel while driving | boolean | true / true / true / true | src/lang_en.lua:145, src/panel.lua:134, src/tips_en.lua:134 |
| accidents | `yellowMessage` — On-screen incident messages | boolean | true / true / true / true | src/engine.lua:606, src/engine.lua:611, src/engine.lua:626, src/incidents.lua:69, src/incidents.lua:234, src/incidents.lua:244, src/incidents.lua:252, src/incidents.lua:260, src/incidents.lua:272, src/incidents.lua:279, src/incidents.lua:315, src/incidents.lua:333, src/incidents.lua:339, src/incidents.lua:349, src/incidents.lua:452, src/lang_en.lua:145, src/tips_en.lua:135 |
| accidents | `deltaBeeps` — Delta: beeps | boolean | true / true / true / true | src/engine.lua:508, src/lang_en.lua:145, src/tips_en.lua:131 |
| accidents | `playerPenalties` — Player penalties under flags | boolean | false / true / true / true | src/lang_en.lua:47, src/lang_en.lua:146, src/penalties.lua:77, src/penalties.lua:78, src/tips_en.lua:129 |
| accidents | `deltaTolerance` — Delta: mini-sector tolerance (s) | 0 to 1 | 0.5 / 0.5 / 0.5 / 0.5 | src/delta.lua:125, src/lang_en.lua:146, src/tips_en.lua:130 |
| accidents | `penaltySeconds` — Penalty: throttle cut (s) | 2 to 15 | 5 / 5 / 5 / 5 | src/engine.lua:628, src/lang_en.lua:146, src/penalties.lua:80, src/penalties.lua:81, src/penalties.lua:85, src/penalties.lua:116, src/penalties.lua:126, src/penalties.lua:139, src/tips_en.lua:132 |
| accidents | `penaltyDisqualify` — Infringements allowed before disqualification | 1 to 20 | 5 / 5 / 5 / 5 | src/engine.lua:596, src/engine.lua:610, src/engine.lua:614, src/engine.lua:628, src/lang_en.lua:146, src/penalties.lua:53, src/penalties.lua:138, src/tips_en.lua:127 |
| accidents | `aiPenalties` — AI sanctions under flags | boolean | false / true / true / true | src/lang_en.lua:146, src/penalties.lua:149, src/tips_en.lua:128 |
| rules | `noMoveBraking` — No change of direction under braking | boolean | true / true / true / true | src/director.lua:466, src/lang_en.lua:46, src/lang_en.lua:147, src/tips_en.lua:137 |
| rules | `neutralization` — Neutralisation after a major incident | local, fcy, vsc, sc | local / local / local / local | src/engine.lua:58, src/incidents.lua:219, src/incidents.lua:343, src/lang_en.lua:147, src/tips_en.lua:138 |
| rules | `majorIncidentTime` — Major incident: car stopped on track (s) | 5 to 60 | 15 / 15 / 15 / 15 | src/engine.lua:57, src/engine.lua:58, src/incidents.lua:179, src/incidents.lua:229, src/lang_en.lua:147, src/tips_en.lua:139 |
| rules | `fcySpeedKmh` — FCY: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:85, src/delta.lua:88, src/delta.lua:90, src/incidents.lua:346, src/incidents.lua:410, src/lang_en.lua:147, src/tips_en.lua:140 |
| rules | `fcyDeltaPct` — FCY: reference time slower by (%) | 10 to 150 | 50 / 50 / 50 / 50 | src/delta.lua:88, src/delta.lua:90, src/incidents.lua:244, src/incidents.lua:410, src/lang_en.lua:147, src/panel.lua:155, src/tips_en.lua:141 |
| rules | `vscDeltaPct` — VSC: reference time slower by (%) | 10 to 80 | 30 / 30 / 30 / 30 | src/delta.lua:85, src/incidents.lua:244, src/incidents.lua:410, src/lang_en.lua:147, src/panel.lua:154, src/tips_en.lua:142 |
| rules | `neutralizationHold` — Minimum neutralisation time (s) | 10 to 180 | 30 / 30 / 30 / 30 | src/incidents.lua:231, src/incidents.lua:254, src/incidents.lua:346, src/lang_en.lua:148, src/tips_en.lua:143 |
| rules | `safetyCarSpeedKmh` — Safety Car speed (km/h) | 60 to 250 | 120 / 120 / 120 / 120 | src/delta.lua:145, src/incidents.lua:301, src/incidents.lua:363, src/incidents.lua:408, src/incidents.lua:411, src/lang_en.lua:148, src/tips_en.lua:144 |
| rules | `safetyCarEscalation` — Safety Car if the incident escalates | boolean | false / true / true / true | src/engine.lua:51, src/incidents.lua:227, src/incidents.lua:228, src/lang_en.lua:148, src/tips_en.lua:145 |
| rules | `redFlagEnabled` — Red flag on a serious accident (practice, qualifying, race) | boolean | true / true / true / true | src/engine.lua:52, src/incidents.lua:309, src/lang_en.lua:46, src/lang_en.lua:149, src/tips_en.lua:146 |
| rules | `redFlagCars` — Red flag: cars stopped on track | 2 to 10 | 3 / 3 / 3 / 3 | src/incidents.lua:310, src/lang_en.lua:149, src/tips_en.lua:147 |
| rules | `redFlagSpeedKmh` — Red flag: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:82, src/incidents.lua:312, src/incidents.lua:415, src/lang_en.lua:149, src/tips_en.lua:148 |
| rules | `redDeltaPct` — Red flag: reference time slower by (%) | 10 to 200 | 60 / 60 / 60 / 60 | src/delta.lua:82, src/incidents.lua:415, src/lang_en.lua:149, src/tips_en.lua:149 |
| rules | `redFlagHold` — Red flag: minimum suspension (s) | 20 to 600 | 60 / 60 / 60 / 60 | src/incidents.lua:312, src/incidents.lua:328, src/lang_en.lua:149, src/tips_en.lua:150 |
| rules | `redFlagWork` — Red flag: tyres changed in the pits (stop counts) | boolean | false / false / false / false | src/lang_en.lua:149, src/pits.lua:94, src/pits.lua:119, src/pits.lua:124, src/tips_en.lua:151 |
| rules | `mandatoryStops` — Mandatory stops in the race | 0 to 3 | 0 / 0 / 0 / 0 | src/engine.lua:671, src/engine.lua:674, src/hudinfo.lua:106, src/hudinfo.lua:107, src/hudinfo.lua:108, src/lang_en.lua:46, src/lang_en.lua:150, src/pits.lua:47, src/pits.lua:57, src/pits.lua:62, src/pits.lua:105, src/pits.lua:107, src/pits.lua:115, src/pits.lua:159, src/pits.lua:160, src/tips_en.lua:152 |
| rules | `pitWindowOpenPct` — Window opens (% of race) | 5 to 95 | 25 / 25 / 25 / 25 | src/lang_en.lua:150, src/pits.lua:53, src/tips_en.lua:153 |
| rules | `pitWindowClosePct` — Window closes (% of race) | 5 to 100 | 75 / 75 / 75 / 75 | src/lang_en.lua:150, src/pits.lua:53, src/tips_en.lua:154 |
| rules | `pitTyres` — New tyres at every stop (pit rules active) | boolean | true / true / true / true | src/lang_en.lua:150, src/pits.lua:119, src/tips_en.lua:155 |
| rules | `pitRepair` — Repairs at every stop in the race (bodywork, suspension, engine) | boolean | true / true / true / true | src/applier.lua:352, src/engine.lua:110, src/lang_en.lua:150, src/pits.lua:99, src/pits.lua:124, src/pits.lua:126, src/tips_en.lua:156 |
| rules | `pitCompoundChange` — Change dry compound (F1) | boolean | false / false / false / false | src/lang_en.lua:150, src/pits.lua:33, src/pits.lua:56, src/tips_en.lua:157 |
| rules | `minPitTime` — Minimum stop time (s, 0 = free) | 0 to 120 | 0 / 0 / 0 / 0 | src/lang_en.lua:151, src/pits.lua:47, src/pits.lua:118, src/tips_en.lua:158 |
| rules | `maxStintMin` — Maximum stint (min, 0 = free) | 0 to 240 | 0 / 0 / 0 / 0 | src/lang_en.lua:151, src/pits.lua:47, src/pits.lua:111, src/pits.lua:165, src/tips_en.lua:160 |
| rules | `pitFuel` — Fuel at enforced stops | refuel, plan, ac | refuel / refuel / refuel / refuel | src/lang_en.lua:151, src/pits.lua:172, src/tips_en.lua:159 |
| rules | `pitsClosed` — Pit lane closed under neutralisation | open, pitFcy, pitFcySc | open / open / open / open | src/engine.lua:667, src/incidents.lua:17, src/incidents.lua:28, src/incidents.lua:300, src/incidents.lua:303, src/lang_en.lua:151, src/tips_en.lua:161 |
| rules | `pitMessage` — Pit window opening message | boolean | true / true / true / true | src/lang_en.lua:151, src/pits.lua:59, src/pits.lua:69, src/tips_en.lua:162 |
| rules | `overtakeMode` — Overtake Mode (F1 2026, within one second at detection) | boolean | false / false / false / false | src/director.lua:841, src/lang_en.lua:46, src/lang_en.lua:152, src/tips_en.lua:163 |
| rules | `overtakeModeGap` — Overtake Mode: detection gap (s) | 0.3 to 2 | 1 / 1 / 1 / 1 | src/director.lua:843, src/lang_en.lua:152, src/tips_en.lua:164 |
| rules | `overtakeModeBoostPct` — Overtake Mode: level gain (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/director.lua:845, src/lang_en.lua:152, src/tips_en.lua:165 |
| rules | `drsAssist` — Player DRS: beep and panel | boolean | true / true / true / true | src/engine.lua:370, src/engine.lua:572, src/engine.lua:634, src/lang_en.lua:46, src/lang_en.lua:153, src/panel.lua:107, src/panel.lua:140, src/tips_en.lua:126 |
| rules | `rulesDrs` — DRS: racing rules (rain, flags, start, Safety Car, red flag) | boolean | false / true / true / true | src/engine.lua:519, src/lang_en.lua:153, src/tips_en.lua:123 |
| rules | `rulesDrsLaps` — DRS: leader laps before enabling (start, SC, red flag) | 0 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:543, src/lang_en.lua:153, src/tips_en.lua:124 |
| rules | `aiDrs` — AI DRS: opened in the zones | boolean | true / true / true / true | src/engine.lua:557, src/lang_en.lua:153, src/tips_en.lua:125 |
| rules | `drsBeepVolume` — Beeps (DRS and delta): volume (%) | 25 to 400 | 200 / 200 / 200 / 200 | src/engine.lua:370, src/engine.lua:512, src/engine.lua:634, src/lang_en.lua:153, src/tips_en.lua:122 |
| rules | `bopEnabled` — BoP: pace evened out within each class | boolean | false / false / false / false | src/classes.lua:42, src/director.lua:102, src/lang_en.lua:46, src/lang_en.lua:154, src/tips_en.lua:166 |
| rules | `bopStrengthPct` — BoP: maximum correction (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/classes.lua:45, src/lang_en.lua:154, src/tips_en.lua:167 |
| rules | `proAmEnabled` — Pro-Am driver ratings (Bronze to Platinum) | boolean | false / false / false / false | src/lang_en.lua:154, src/persona.lua:31, src/persona.lua:32, src/tips_en.lua:168 |
| rules | `predictableSlowClass` — Slower class: predictable line | boolean | false / false / false / false | src/director.lua:546, src/lang_en.lua:46, src/lang_en.lua:154, src/tips_en.lua:169 |
| endurance | `enduranceOverlay` — Endurance layer | boolean | false / false / false / false | src/director.lua:103, src/director.lua:399, src/director.lua:800, src/lang_en.lua:155, src/persona.lua:6, src/tips_en.lua:171 |
| endurance | `multiClass` — Multi-class | boolean | false / false / false / false | src/delta.lua:122, src/director.lua:74, src/director.lua:895, src/engine.lua:239, src/engine.lua:424, src/engine.lua:582, src/engine.lua:645, src/incidents.lua:376, src/lang_en.lua:155, src/tips_en.lua:172 |
| endurance | `classGapPct` — Gap between classes (%) | 3 to 25 | 8 / 8 / 8 / 8 | src/classes.lua:31, src/lang_en.lua:155, src/tips_en.lua:173 |
| endurance | `classYieldMargin` — Class speed advantage (km/h) | 1 to 15 | 4 / 4 / 4 / 4 | src/director.lua:300, src/director.lua:561, src/lang_en.lua:155, src/tips_en.lua:174 |
| endurance | `stintLevelSwing` — Variation between stints (%) | 0 to 8 | 3 / 3 / 3 / 3 | src/lang_en.lua:155, src/persona.lua:28, src/tips_en.lua:175 |
| endurance | `stintDegradationPct` — Degradation over a stint (%) | 0 to 5 | 1 / 1 / 1 / 1 | src/director.lua:104, src/lang_en.lua:155, src/tips_en.lua:176 |
| weather | `weatherAdaptation` — Adapt pace to the weather | boolean | true / true / true / true | src/director.lua:107, src/director.lua:320, src/lang_en.lua:156, src/tips_en.lua:178 |
| weather | `weatherTyresEnabled` — Manage dry and wet tyres | boolean | true / true / true / true | src/engine.lua:653, src/lang_en.lua:156, src/tips_en.lua:179, src/weather.lua:25 |
| weather | `weatherMessage` — On-screen message on a weather change | boolean | true / true / true / true | src/engine.lua:659, src/lang_en.lua:156, src/tips_en.lua:180 |
| weather | `rainGripBoostPct` — Rain compensation without wet tyres (%) | 0 to 30 | 15 / 15 / 15 / 15 | src/lang_en.lua:156, src/tips_en.lua:181, src/weather.lua:38 |
| traffic | `trafficGapSeconds` — Base gap (s) | 0.5 to 5 | 2.5 / 2.5 / 2.5 / 2.5 | src/lang_en.lua:157, src/tips_en.lua:183, src/traffic.lua:209 |
| traffic | `trafficDensityGain` — Distance added per AI (m) | 0.5 to 5 | 2.8 / 2.8 / 2.8 / 2.8 | src/lang_en.lua:157, src/tips_en.lua:184, src/traffic.lua:209 |
| traffic | `trafficVariation` — Gap variation (%) | 0 to 50 | 45 / 45 / 45 / 45 | src/lang_en.lua:157, src/tips_en.lua:185, src/traffic.lua:208 |
| traffic | `trafficMaxReduction` — Maximum speed reduction (%) | 2 to 20 | 14 / 14 / 14 / 14 | src/lang_en.lua:157, src/tips_en.lua:186, src/traffic.lua:219 |

## Adjustable global options

| Key | Default | Range | Consumers |
|---|---|---|---|
| `levelMode` | auto | auto, native, grip, none | src/applier.lua:786, src/applier.lua:793, src/caps.lua:4, src/caps.lua:41, src/caps.lua:42, src/lang_en.lua:60, src/tips_en.lua:203 |
| `useGripBoost` | false | boolean | src/applier.lua:793, src/caps.lua:42, src/tips_en.lua:204 |
| `gripPerLevelPct` | 0.004 | [0, 0.01] | src/applier.lua:793, src/lang_en.lua:126, src/tips_en.lua:215 |
| `useBrakeAssist` | true | boolean | src/applier.lua:774, src/applier.lua:800, src/director.lua:764, src/engine.lua:40, src/tips_en.lua:205 |
| `overrideAwareness` | false | boolean | src/applier.lua:781, src/tips_en.lua:206 |
| `occLatMin` | 0.3 | [0.1, 1] | src/lang_en.lua:126, src/perception.lua:46, src/perception.lua:47, src/perception.lua:48, src/tips_en.lua:211 |
| `occLatMax` | 5.5 | [2, 8] | src/director.lua:452, src/director.lua:526, src/director.lua:597, src/director.lua:626, src/director.lua:720, src/lang_en.lua:126, src/perception.lua:47, src/perception.lua:48, src/perception.lua:98, src/tips_en.lua:212 |
| `occMargin` | 6 | [2, 15] | src/lang_en.lua:126, src/perception.lua:43, src/tips_en.lua:213 |
| `occSpeedGain` | 0.8 | [0, 2] | src/lang_en.lua:126, src/perception.lua:43, src/tips_en.lua:214 |
| `seed` | 19731019 | [0, 2147483647] | src/director.lua:54, src/director.lua:341, src/director.lua:398, src/director.lua:648, src/director.lua:802, src/engine.lua:92, src/engine.lua:163, src/engine.lua:333, src/engine.lua:422, src/engine.lua:647, src/engine.lua:667, src/flash.lua:70, src/incidents.lua:119, src/incidents.lua:195, src/lang_en.lua:61, src/mistakes.lua:65, src/mistakes.lua:74, src/persona.lua:5, src/persona.lua:8, src/persona.lua:9, src/persona.lua:28, src/persona.lua:30, src/persona.lua:37, src/persona.lua:40, src/persona.lua:42, src/persona.lua:43, src/persona.lua:44, src/pits.lua:46, src/pits.lua:108, src/tips_en.lua:216, src/tips_en.lua:233, src/tips_en.lua:292, src/traffic.lua:69, src/traffic.lua:86, src/traffic.lua:120, src/traffic.lua:197, src/util.lua:18, src/util.lua:19, src/util.lua:32, src/weather.lua:9, src/weather.lua:11, src/weather.lua:14, src/weather.lua:28 |
| `debugLog` | false | boolean | src/director.lua:71, src/lang_en.lua:61, src/tips_en.lua:210 |

The section switches go through `C.on`/`C.effective` and are walked by the interface tests. `classPatterns` uses the `C.patterns` parser, `Classes.configure/update`, the eight dedicated rows and validated storage. The manual/automatic choice, the main button, panic, presets and the diagnostics tools are examined in AUDIT_V1.md.

## Functions examined

List taken from the AST of the 36 active files, including local and anonymous functions. The review, fixes and limits are in AUDIT_V1.md. This list does not mean 100% branch coverage.

| File | Line | Function |
|---|---|---|
| ACAdvancedIA.lua | 43 | `announce` |
| ACAdvancedIA.lua | 50 | `dirty` |
| ACAdvancedIA.lua | 58 | `(anonymous)` |
| ACAdvancedIA.lua | 69 | `writeJournal` |
| ACAdvancedIA.lua | 88 | `cancelProbe` |
| ACAdvancedIA.lua | 97 | `syncRestored` |
| ACAdvancedIA.lua | 107 | `anyOwned` |
| ACAdvancedIA.lua | 112 | `step` |
| ACAdvancedIA.lua | 118 | `stop` |
| ACAdvancedIA.lua | 124 | `saveRace` |
| ACAdvancedIA.lua | 130 | `release` |
| ACAdvancedIA.lua | 143 | `updateLog` |
| ACAdvancedIA.lua | 147 | `(anonymous)` |
| ACAdvancedIA.lua | 157 | `(anonymous)` |
| ACAdvancedIA.lua | 175 | `session` |
| ACAdvancedIA.lua | 180 | `update` |
| ACAdvancedIA.lua | 200 | `(anonymous)` |
| ACAdvancedIA.lua | 201 | `(anonymous)` |
| ACAdvancedIA.lua | 298 | `updateTick` |
| ACAdvancedIA.lua | 311 | `protect` |
| ACAdvancedIA.lua | 320 | `script.HUMANAI__UPDATE` |
| ACAdvancedIA.lua | 334 | `script.update` |
| ACAdvancedIA.lua | 335 | `script.HUMANAI__MENU` |
| ACAdvancedIA.lua | 338 | `protectUI` |
| ACAdvancedIA.lua | 346 | `script.HUMANAI__MAIN` |
| ACAdvancedIA.lua | 358 | `script.HUMANAI__FLAGS` |
| ACAdvancedIA.lua | 360 | `script.HUMANAI__HUD` |
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
| src/applier.lua | 198 | `M.save` |
| src/applier.lua | 201 | `(anonymous)` |
| src/applier.lua | 213 | `restoreRain` |
| src/applier.lua | 217 | `restoreSkin` |
| src/applier.lua | 221 | `(anonymous)` |
| src/applier.lua | 225 | `M.restore` |
| src/applier.lua | 275 | `send` |
| src/applier.lua | 283 | `field` |
| src/applier.lua | 288 | `claim` |
| src/applier.lua | 297 | `weather` |
| src/applier.lua | 324 | `tyreLabel` |
| src/applier.lua | 330 | `pitRequest` |
| src/applier.lua | 390 | `startDelay` |
| src/applier.lua | 400 | `place` |
| src/applier.lua | 416 | `hold` |
| src/applier.lua | 431 | `flagText` |
| src/applier.lua | 432 | `M.flag` |
| src/applier.lua | 456 | `folder` |
| src/applier.lua | 457 | `lightsRead` |
| src/applier.lua | 494 | `M.trackLights` |
| src/applier.lua | 503 | `flash` |
| src/applier.lua | 515 | `safetySkin` |
| src/applier.lua | 519 | `(anonymous)` |
| src/applier.lua | 521 | `(anonymous)` |
| src/applier.lua | 528 | `safety` |
| src/applier.lua | 536 | `(anonymous)` |
| src/applier.lua | 571 | `recover` |
| src/applier.lua | 581 | `M.releaseBlackFlag` |
| src/applier.lua | 588 | `M.penalty` |
| src/applier.lua | 602 | `disposeBeep` |
| src/applier.lua | 602 | `(anonymous)` |
| src/applier.lua | 603 | `M.beep` |
| src/applier.lua | 611 | `play` |
| src/applier.lua | 624 | `M.deltaBeep` |
| src/applier.lua | 631 | `(anonymous)` |
| src/applier.lua | 635 | `play` |
| src/applier.lua | 640 | `(anonymous)` |
| src/applier.lua | 645 | `M.drs` |
| src/applier.lua | 669 | `releaseDrs` |
| src/applier.lua | 676 | `M.sessionBox` |
| src/applier.lua | 677 | `M.screen` |
| src/applier.lua | 683 | `M.listenMessages` |
| src/applier.lua | 687 | `M.blockMessages` |
| src/applier.lua | 691 | `M.dispose` |
| src/applier.lua | 694 | `M.journalOpen` |
| src/applier.lua | 696 | `(anonymous)` |
| src/applier.lua | 712 | `M.clockText` |
| src/applier.lua | 717 | `M.journalWrite` |
| src/applier.lua | 721 | `(anonymous)` |
| src/applier.lua | 726 | `M.storeText` |
| src/applier.lua | 727 | `M.loadText` |
| src/applier.lua | 728 | `M.message` |
| src/applier.lua | 730 | `M.probeMessage` |
| src/applier.lua | 733 | `floodPath` |
| src/applier.lua | 738 | `M.floodRead` |
| src/applier.lua | 747 | `M.floodWrite` |
| src/applier.lua | 753 | `M.apply` |
| src/applier.lua | 816 | `M.register` |
| src/applier.lua | 820 | `M.unregister` |
| src/applier.lua | 822 | `(anonymous)` |
| src/applier.lua | 827 | `M.nextSession` |
| src/applier.lua | 848 | `M.clipboard` |
| src/applier.lua | 849 | `M.checkpoint` |
| src/applier.lua | 860 | `M.recover` |
| src/calibration.lua | 7 | `M.new` |
| src/calibration.lua | 8 | `resetSafe` |
| src/calibration.lua | 18 | `safe` |
| src/calibration.lua | 32 | `M.step` |
| src/calibration.lua | 80 | `M.cancel` |
| src/caps.lua | 3 | `M.new` |
| src/caps.lua | 8 | `M.call` |
| src/caps.lua | 18 | `M.restoreCall` |
| src/caps.lua | 19 | `M.probe` |
| src/caps.lua | 40 | `M.mode` |
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
| src/config.lua | 327 | `M.defaults` |
| src/config.lua | 336 | `M.sectionsChanged` |
| src/config.lua | 343 | `M.anySection` |
| src/config.lua | 347 | `choice` |
| src/config.lua | 348 | `M.patterns` |
| src/config.lua | 358 | `M.validate` |
| src/config.lua | 386 | `M.validateGlobals` |
| src/config.lua | 405 | `M.preset` |
| src/config.lua | 417 | `M.on` |
| src/config.lua | 418 | `M.any` |
| src/config.lua | 423 | `M.effective` |
| src/config.lua | 454 | `M.effectiveGlobals` |
| src/config.lua | 461 | `M.needsOffset` |
| src/config.lua | 464 | `equal` |
| src/config.lua | 480 | `M.legacyMatch` |
| src/config.lua | 505 | `M.upgradeObstacles` |
| src/config.lua | 516 | `M.migrateProfile` |
| src/config.lua | 572 | `M.migrate` |
| src/config.lua | 636 | `M.kept` |
| src/config.lua | 637 | `ruleValue` |
| src/config.lua | 638 | `M.restore` |
| src/config.lua | 647 | `applyValues` |
| src/config.lua | 651 | `M.weekendSwitch` |
| src/config.lua | 660 | `M.applyRules` |
| src/config.lua | 675 | `M.spreadRules` |
| src/config.lua | 689 | `M.mark` |
| src/config.lua | 693 | `M.setMark` |
| src/config.lua | 699 | `M.withRules` |
| src/config.lua | 710 | `category13` |
| src/config.lua | 724 | `M.migrateRules` |
| src/config.lua | 734 | `M.closestRuleCategory` |
| src/config.lua | 743 | `M.ruleCategory` |
| src/config.lua | 755 | `M.autoProfile` |
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
| src/engine.lua | 22 | `startReport` |
| src/engine.lua | 48 | `decisionTime` |
| src/engine.lua | 64 | `contacts` |
| src/engine.lua | 88 | `M.new` |
| src/engine.lua | 96 | `(anonymous)` |
| src/engine.lua | 98 | `(anonymous)` |
| src/engine.lua | 114 | `M.changed` |
| src/engine.lua | 115 | `M.select` |
| src/engine.lua | 118 | `M.reset` |
| src/engine.lua | 122 | `M.rebase` |
| src/engine.lua | 151 | `M.configure` |
| src/engine.lua | 168 | `drsBeep` |
| src/engine.lua | 174 | `drive` |
| src/engine.lua | 188 | `M.message` |
| src/engine.lua | 197 | `M.floodInit` |
| src/engine.lua | 206 | `flood` |
| src/engine.lua | 238 | `slowCars` |
| src/engine.lua | 271 | `M.step` |
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
| src/incidents.lua | 7 | `clearCar` |
| src/incidents.lua | 12 | `M.new` |
| src/incidents.lua | 25 | `M.reset` |
| src/incidents.lua | 31 | `M.rebase` |
| src/incidents.lua | 46 | `message` |
| src/incidents.lua | 52 | `note` |
| src/incidents.lua | 55 | `unavailable` |
| src/incidents.lua | 62 | `restart` |
| src/incidents.lua | 74 | `release` |
| src/incidents.lua | 81 | `(anonymous)` |
| src/incidents.lua | 91 | `traffic` |
| src/incidents.lua | 105 | `queued` |
| src/incidents.lua | 119 | `M.update` |
| src/incidents.lua | 359 | `M.safety` |
| src/incidents.lua | 369 | `position` |
| src/incidents.lua | 374 | `M.cap` |
| src/incidents.lua | 421 | `M.player` |
| src/journal.lua | 3 | `M.new` |
| src/journal.lua | 5 | `M.collect` |
| src/journal.lua | 14 | `M.take` |
| src/journal.lua | 22 | `M.summary` |
| src/journal.lua | 45 | `c` |
| src/lights.lua | 19 | `M.new` |
| src/lights.lua | 24 | `M.reset` |
| src/lights.lua | 29 | `M.rebase` |
| src/lights.lua | 37 | `slow` |
| src/lights.lua | 61 | `damage` |
| src/lights.lua | 77 | `M.decide` |
| src/lights.lua | 94 | `M.update` |
| src/lights.lua | 105 | `M.output` |
| src/lights.lua | 115 | `M.scan` |
| src/lights.lua | 119 | `close` |
| src/lights.lua | 152 | `M.equipped` |
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
| src/panel.lua | 13 | `M.new` |
| src/panel.lua | 18 | `blue` |
| src/panel.lua | 39 | `native` |
| src/panel.lua | 63 | `show` |
| src/panel.lua | 99 | `M.native` |
| src/panel.lua | 115 | `M.visible` |
| src/panel.lua | 121 | `M.infractions` |
| src/panel.lua | 129 | `M.warn` |
| src/panel.lua | 131 | `M.notice` |
| src/panel.lua | 133 | `M.update` |
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
| src/penalties.lua | 136 | `sanction` |
| src/penalties.lua | 148 | `M.ai` |
| src/penalties.lua | 216 | `M.serialize` |
| src/penalties.lua | 226 | `M.restore` |
| src/penalties.lua | 246 | `M.resume` |
| src/perception.lua | 5 | `M.new` |
| src/perception.lua | 14 | `M.relative` |
| src/perception.lua | 34 | `M.occupancy` |
| src/perception.lua | 54 | `M.prepare` |
| src/perception.lua | 66 | `M.refresh` |
| src/perception.lua | 87 | `M.find` |
| src/perception.lua | 91 | `M.corridor` |
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
| src/remote.lua | 8 | `callable` |
| src/remote.lua | 9 | `folder` |
| src/remote.lua | 16 | `hex` |
| src/remote.lua | 19 | `(anonymous)` |
| src/remote.lua | 23 | `files` |
| src/remote.lua | 24 | `(anonymous)` |
| src/remote.lua | 33 | `lib` |
| src/remote.lua | 36 | `M.new` |
| src/remote.lua | 47 | `exists` |
| src/remote.lua | 48 | `load` |
| src/remote.lua | 49 | `save` |
| src/remote.lua | 50 | `delete` |
| src/remote.lua | 51 | `p.get` |
| src/remote.lua | 53 | `(anonymous)` |
| src/remote.lua | 58 | `p.json` |
| src/remote.lua | 59 | `p.sha256` |
| src/remote.lua | 60 | `p.entries` |
| src/remote.lua | 61 | `p.entry` |
| src/remote.lua | 62 | `p.previous` |
| src/remote.lua | 63 | `p.installedVersion` |
| src/remote.lua | 64 | `p.marker` |
| src/remote.lua | 65 | `p.mark` |
| src/remote.lua | 66 | `p.unmark` |
| src/remote.lua | 67 | `p.done` |
| src/remote.lua | 68 | `p.takeDone` |
| src/remote.lua | 69 | `p.open` |
| src/remote.lua | 71 | `p.backup` |
| src/remote.lua | 79 | `(anonymous)` |
| src/remote.lua | 88 | `clear` |
| src/remote.lua | 93 | `place` |
| src/remote.lua | 111 | `p.extract` |
| src/remote.lua | 120 | `(anonymous)` |
| src/remote.lua | 127 | `p.restart` |
| src/snapshot.lua | 4 | `hexByte` |
| src/snapshot.lua | 6 | `collidedWith` |
| src/snapshot.lua | 9 | `damageRead` |
| src/snapshot.lua | 18 | `playerDamage` |
| src/snapshot.lua | 27 | `M.new` |
| src/snapshot.lua | 39 | `vector` |
| src/snapshot.lua | 42 | `laneProbe` |
| src/snapshot.lua | 43 | `(anonymous)` |
| src/snapshot.lua | 46 | `readCar` |
| src/snapshot.lua | 125 | `simRead` |
| src/snapshot.lua | 143 | `raceRead` |
| src/snapshot.lua | 151 | `conflictingApp` |
| src/snapshot.lua | 158 | `tyres` |
| src/snapshot.lua | 182 | `M.read` |
| src/snapshot.lua | 205 | `(anonymous)` |
| src/snapshot.lua | 217 | `(anonymous)` |
| src/snapshot.lua | 253 | `M.zones` |
| src/snapshot.lua | 268 | `utf8Char` |
| src/snapshot.lua | 273 | `jsonName` |
| src/snapshot.lua | 293 | `carName` |
| src/snapshot.lua | 302 | `M.carDatabase` |
| src/snapshot.lua | 304 | `(anonymous)` |
| src/snapshot.lua | 308 | `(anonymous)` |
| src/snapshot.lua | 318 | `(anonymous)` |
| src/snapshot.lua | 321 | `menuVisible` |
| src/snapshot.lua | 322 | `M.menu` |
| src/traffic.lua | 5 | `M.new` |
| src/traffic.lua | 24 | `M.mode` |
| src/traffic.lua | 28 | `identity` |
| src/traffic.lua | 31 | `check` |
| src/traffic.lua | 49 | `plan` |
| src/traffic.lua | 69 | `(anonymous)` |
| src/traffic.lua | 126 | `M.exits` |
| src/traffic.lua | 179 | `M.update` |
| src/ui.lua | 21 | `wrap` |
| src/ui.lua | 23 | `number` |
| src/ui.lua | 27 | `shown` |
| src/ui.lua | 32 | `wrapAll` |
| src/ui.lua | 33 | `globalTips` |
| src/ui.lua | 51 | `ruleView` |
| src/ui.lua | 54 | `texts` |
| src/ui.lua | 70 | `same` |
| src/ui.lua | 70 | `(anonymous)` |
| src/ui.lua | 72 | `(anonymous)` |
| src/ui.lua | 78 | `M.new` |
| src/ui.lua | 102 | `text` |
| src/ui.lua | 105 | `mark` |
| src/ui.lua | 107 | `touch` |
| src/ui.lua | 110 | `presetTarget` |
| src/ui.lua | 119 | `loadBuiltin` |
| src/ui.lua | 133 | `builtinActive` |
| src/ui.lua | 148 | `carDatabase` |
| src/ui.lua | 165 | `input` |
| src/ui.lua | 172 | `heading` |
| src/ui.lua | 174 | `valueText` |
| src/ui.lua | 180 | `settingControl` |
| src/ui.lua | 209 | `ruleBlock` |
| src/ui.lua | 228 | `safetyBlock` |
| src/ui.lua | 263 | `patternBlock` |
| src/ui.lua | 306 | `globalBlock` |
| src/ui.lua | 342 | `statusLines` |
| src/ui.lua | 378 | `switches` |
| src/ui.lua | 386 | `overlayBlock` |
| src/ui.lua | 440 | `resetSection` |
| src/ui.lua | 453 | `sectionContent` |
| src/ui.lua | 459 | `flush` |
| src/ui.lua | 498 | `language` |
| src/ui.lua | 507 | `updateAct` |
| src/ui.lua | 516 | `megabytes` |
| src/ui.lua | 518 | `updateText` |
| src/ui.lua | 537 | `updateBlock` |
| src/ui.lua | 579 | `headerBar` |
| src/ui.lua | 618 | `profileButtons` |
| src/ui.lua | 629 | `homeTab` |
| src/ui.lua | 750 | `sectionPane` |
| src/ui.lua | 764 | `settingsTab` |
| src/ui.lua | 797 | `ruleRow` |
| src/ui.lua | 812 | `rulesTab` |
| src/ui.lua | 863 | `diagnosticTab` |
| src/ui.lua | 976 | `M.recovery` |
| src/ui.lua | 982 | `M.compactSize` |
| src/ui.lua | 983 | `M.main` |
| src/ui.lua | 1016 | `faded` |
| src/ui.lua | 1017 | `panelPalette` |
| src/ui.lua | 1042 | `write` |
| src/ui.lua | 1047 | `textWidth` |
| src/ui.lua | 1052 | `fitSize` |
| src/ui.lua | 1059 | `M.flagLayout` |
| src/ui.lua | 1092 | `drsBadge` |
| src/ui.lua | 1099 | `checker` |
| src/ui.lua | 1103 | `diagonal` |
| src/ui.lua | 1109 | `meatball` |
| src/ui.lua | 1115 | `stripes` |
| src/ui.lua | 1120 | `deltaText` |
| src/ui.lua | 1130 | `deltaBox` |
| src/ui.lua | 1143 | `pillsWidth` |
| src/ui.lua | 1145 | `pillRow` |
| src/ui.lua | 1162 | `pill` |
| src/ui.lua | 1169 | `giveBackText` |
| src/ui.lua | 1173 | `blueText` |
| src/ui.lua | 1182 | `M.overlayParts` |
| src/ui.lua | 1201 | `M.overlayHeight` |
| src/ui.lua | 1210 | `strong` |
| src/ui.lua | 1216 | `sessionStrip` |
| src/ui.lua | 1239 | `M.flags` |
| src/ui.lua | 1335 | `nativeBox` |
| src/ui.lua | 1339 | `M.restoreNative` |
| src/ui.lua | 1340 | `screenSize` |
| src/ui.lua | 1343 | `hudContent` |
| src/ui.lua | 1378 | `M.hud` |
| src/ui.lua | 1393 | `(anonymous)` |
| src/update.lua | 23 | `M.version` |
| src/update.lua | 30 | `M.label` |
| src/update.lua | 32 | `M.newer` |
| src/update.lua | 38 | `str` |
| src/update.lua | 39 | `starts` |
| src/update.lua | 41 | `M.notes` |
| src/update.lua | 55 | `M.release` |
| src/update.lua | 77 | `M.digest` |
| src/update.lua | 85 | `M.content` |
| src/update.lua | 96 | `M.manifestVersion` |
| src/update.lua | 101 | `M.stopped` |
| src/update.lua | 103 | `M.new` |
| src/update.lua | 108 | `event` |
| src/update.lua | 114 | `M.take` |
| src/update.lua | 120 | `M.busy` |
| src/update.lua | 123 | `fail` |
| src/update.lua | 128 | `parse` |
| src/update.lua | 136 | `M.start` |
| src/update.lua | 150 | `(anonymous)` |
| src/update.lua | 165 | `M.check` |
| src/update.lua | 168 | `(anonymous)` |
| src/update.lua | 181 | `M.cancel` |
| src/update.lua | 183 | `M.install` |
| src/update.lua | 189 | `(anonymous)` |
| src/update.lua | 193 | `(anonymous)` |
| src/update.lua | 201 | `(anonymous)` |
| src/update.lua | 207 | `(anonymous)` |
| src/update.lua | 211 | `(anonymous)` |
| src/update.lua | 227 | `M.rollback` |
| src/update.lua | 234 | `(anonymous)` |
| src/update.lua | 249 | `M.view` |
| src/update.lua | 265 | `M.offered` |
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
| src/widgets.lua | 9 | `W.colors` |
| src/widgets.lua | 19 | `W.begin` |
| src/widgets.lua | 28 | `W.frame` |
| src/widgets.lua | 29 | `W.point` |
| src/widgets.lua | 30 | `W.rect` |
| src/widgets.lua | 33 | `W.line` |
| src/widgets.lua | 34 | `W.circle` |
| src/widgets.lua | 35 | `W.bold` |
| src/widgets.lua | 39 | `W.text` |
| src/widgets.lua | 44 | `width` |
| src/widgets.lua | 49 | `fitted` |
| src/widgets.lua | 68 | `W.cell` |
| src/widgets.lua | 76 | `W.lines` |
| src/widgets.lua | 93 | `W.paragraph` |
| src/widgets.lua | 100 | `inside` |
| src/widgets.lua | 107 | `W.help` |
| src/widgets.lua | 111 | `W.hit` |
| src/widgets.lua | 117 | `W.button` |
| src/widgets.lua | 135 | `W.toggle` |
| src/widgets.lua | 146 | `W.pill` |
| src/widgets.lua | 152 | `W.slider` |
| src/widgets.lua | 177 | `W.scroll` |
| src/widgets.lua | 191 | `W.clip` |
| src/widgets.lua | 195 | `W.visible` |
| src/widgets.lua | 200 | `W.finish` |
| src/widgets.lua | 207 | `W.step` |
| src/zones.lua | 6 | `M.parse` |
| src/zones.lua | 9 | `skip` |
| src/zones.lua | 17 | `token` |
| src/zones.lua | 18 | `value` |
| src/zones.lua | 67 | `M.at` |
| src/zones.lua | 77 | `M.export` |
