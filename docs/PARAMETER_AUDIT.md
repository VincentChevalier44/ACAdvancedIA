# Settings and functions inventory Beta 1.27

This inventory links every declared parameter to its consumers. A static reference shows a connection, not proof of a physical result. The `PARAMETER_BOUNDARY_ENGINE` tests and the two full walks through the interface complete this trace.

| Section | Parameter | Range | Default J / P / Q / C | Consumers |
|---|---|---|---|---|
| general | `levelPct` — Level (%) | 40 to 110 | 95 / 100 / 100 / 100 | src/director.lua:87, src/lang_en.lua:126, src/mistakes.lua:33, src/tips_en.lua:6 |
| general | `aggressionPct` — Aggression (%) | 0 to 100 | 55 / 45 / 45 / 80 | src/director.lua:88, src/director.lua:745, src/lang_en.lua:126, src/tips_en.lua:7 |
| general | `caution` — Caution | 0.5 to 8 | 1.6 / 2.2 / 2.2 / 1.2 | src/applier.lua:9, src/applier.lua:68, src/applier.lua:262, src/applier.lua:267, src/applier.lua:290, src/applier.lua:714, src/applier.lua:720, src/applier.lua:784, src/applier.lua:804, src/caps.lua:2, src/director.lua:89, src/director.lua:91, src/director.lua:94, src/director.lua:96, src/director.lua:97, src/director.lua:428, src/director.lua:450, src/director.lua:485, src/director.lua:517, src/director.lua:598, src/director.lua:600, src/director.lua:689, src/director.lua:690, src/director.lua:692, src/director.lua:693, src/director.lua:711, src/director.lua:729, src/director.lua:745, src/director.lua:748, src/director.lua:750, src/director.lua:796, src/director.lua:799, src/engine.lua:107, src/engine.lua:152, src/engine.lua:402, src/lang_en.lua:59, src/lang_en.lua:62, src/lang_en.lua:126, src/lang_en.lua:160, src/tips_en.lua:8, src/tips_en.lua:9, src/tips_en.lua:12, src/tips_en.lua:64, src/tips_en.lua:99, src/tips_en.lua:171, src/tips_en.lua:178, src/tips_en.lua:219, src/tips_en.lua:226, src/tips_en.lua:235 |
| general | `brakeZonePct` — Emulated braking zone (%) | 50 to 150 | 100 / 100 / 100 / 100 | src/director.lua:750, src/lang_en.lua:126, src/tips_en.lua:9 |
| general | `paceSpreadPct` — Level spread (%) | 0 to 20 | 8 / 3 / 3 / 2 | src/lang_en.lua:126, src/persona.lua:13, src/tips_en.lua:10 |
| general | `aggrSpreadPct` — Aggression spread (%) | 0 to 30 | 12 / 8 / 8 / 10 | src/lang_en.lua:126, src/persona.lua:14, src/tips_en.lua:11 |
| general | `cautSpreadPct` — Caution spread (%) | 0 to 30 | 12 / 8 / 8 / 8 | src/lang_en.lua:126, src/persona.lua:15, src/tips_en.lua:12 |
| general | `pitExitSpread` — Staggered pit exits, practice and qualifying (s per AI, 0 = free) | 0 to 30 | 0 / 10 / 10 / 0 | src/lang_en.lua:126, src/tips_en.lua:13, src/traffic.lua:17, src/traffic.lua:47, src/traffic.lua:110 |
| general | `spawnMode` — AI distribution at session start | native, pits, track | track / pits / pits / native | src/flood.lua:105, src/lang_en.lua:126, src/tips_en.lua:14, src/traffic.lua:26 |
| general | `spawnMinCars` — Spread from (AI) | 2 to 60 | 10 / 10 / 10 / 10 | src/engine.lua:225, src/flood.lua:106, src/lang_en.lua:126, src/tips_en.lua:17, src/traffic.lua:10, src/traffic.lua:62 |
| general | `spawnPitPct` — AI left in the pits at the start (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/lang_en.lua:126, src/tips_en.lua:15, src/traffic.lua:67, src/traffic.lua:69 |
| general | `spawnGapVariation` — Start gap variation (%) | 0 to 100 | 100 / 100 / 100 / 100 | src/lang_en.lua:126, src/tips_en.lua:16, src/traffic.lua:75, src/traffic.lua:78 |
| general | `floodRangeKm` — CSP AI flood range, below the threshold (km) | 1 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:210, src/engine.lua:225, src/engine.lua:226, src/lang_en.lua:126, src/tips_en.lua:18 |
| yield | `yieldEnabled` — Standard yielding | boolean | true / true / true / false | src/director.lua:297, src/director.lua:528, src/lang_en.lua:127, src/tips_en.lua:20 |
| yield | `yieldSide` — Yield side | left, right, auto | right / right / right / right | src/director.lua:68, src/director.lua:69, src/director.lua:76, src/director.lua:79, src/director.lua:336, src/director.lua:487, src/lang_en.lua:127, src/persona.lua:23, src/tips_en.lua:21 |
| yield | `yieldOffset` — Yield offset | 0.2 to 0.95 | 0.65 / 0.8 / 0.8 / 0.6 | src/director.lua:512, src/lang_en.lua:127, src/tips_en.lua:22 |
| yield | `yieldDetectBehind` — Rear detection (m) | 30 to 400 | 100 / 200 / 200 / 80 | src/director.lua:303, src/lang_en.lua:127, src/tips_en.lua:23 |
| yield | `yieldBehindMargin` — Follower speed advantage (km/h) | 1 to 30 | 6 / 4 / 4 / 6 | src/director.lua:259, src/director.lua:300, src/director.lua:528, src/lang_en.lua:127, src/tips_en.lua:24 |
| yield | `yieldHorizon` — Rear horizon (s) | 3 to 30 | 10 / 12 / 12 / 8 | src/director.lua:301, src/lang_en.lua:127, src/tips_en.lua:25 |
| yield | `confirmTime` — Confirmation (s) | 0.1 to 2 | 0.6 / 0.4 / 0.4 / 0.5 | src/director.lua:317, src/director.lua:660, src/lang_en.lua:127, src/tips_en.lua:26 |
| yield | `yieldHoldMin` — Minimum hold (s) | 0.3 to 5 | 1 / 1 / 1 / 1 | src/director.lua:344, src/director.lua:529, src/director.lua:544, src/flash.lua:67, src/lang_en.lua:128, src/tips_en.lua:27 |
| yield | `yieldHoldAfterMin` — Hold after the pass, min. (s) | 0.2 to 6 | 0.8 / 0.6 / 0.6 / 0.8 | src/lang_en.lua:128, src/persona.lua:27, src/persona.lua:35, src/tips_en.lua:28 |
| yield | `yieldHoldAfterMax` — Hold after the pass, max. (s) | 0.2 to 6 | 2.2 / 1.6 / 1.6 / 1.8 | src/lang_en.lua:128, src/persona.lua:27, src/persona.lua:35, src/tips_en.lua:29 |
| yield | `yieldSlowdownPct` — Slowdown while yielding (%) | 0 to 20 | 6 / 8 / 8 / 6 | src/director.lua:516, src/director.lua:753, src/lang_en.lua:128, src/tips_en.lua:30 |
| yield | `inviteSlowdownPct` — Extra slowdown to invite a pass (%) | 0 to 25 | 10 / 10 / 10 / 10 | src/director.lua:521, src/lang_en.lua:128, src/tips_en.lua:31 |
| yield | `yieldMaxHold` — Maximum yield duration (s) | 8 to 60 | 25 / 25 / 25 / 25 | src/director.lua:546, src/lang_en.lua:128, src/tips_en.lua:32 |
| yield | `pressureEnabled` — Reaction to pressure | boolean | true / true / true / false | src/director.lua:307, src/director.lua:313, src/lang_en.lua:129, src/tips_en.lua:33 |
| yield | `pressureGap` — Pressure distance (m) | 5 to 30 | 15 / 15 / 15 / 15 | src/director.lua:307, src/director.lua:310, src/lang_en.lua:129, src/tips_en.lua:34 |
| yield | `pressureTime` — Pressure duration (s) | 1 to 15 | 4 / 3 / 3 / 4 | src/director.lua:313, src/lang_en.lua:129, src/tips_en.lua:35 |
| blue | `blueFlagEnabled` — Blue flags | boolean | false / true / true / true | src/director.lua:249, src/director.lua:815, src/engine.lua:39, src/lang_en.lua:130, src/panel.lua:17, src/tips_en.lua:37 |
| blue | `blueFlagRange` — Blue flag range (m) | 50 to 400 | 150 / 200 / 200 / 150 | src/director.lua:281, src/director.lua:815, src/director.lua:823, src/engine.lua:39, src/lang_en.lua:130, src/panel.lua:26, src/tips_en.lua:38 |
| blue | `blueFlagSide` — Side under blue flag | auto, left, right | auto / auto / auto / auto | src/director.lua:69, src/lang_en.lua:130, src/tips_en.lua:39 |
| flash | `flashMode` — Headlight flashes | never, lapped, always | always / always / always / lapped | src/director.lua:288, src/flash.lua:40, src/flash.lua:49, src/lang_en.lua:131, src/tips_en.lua:41 |
| flash | `flashRange` — Flash range (m) | 40 to 250 | 120 / 150 / 150 / 100 | src/director.lua:268, src/director.lua:274, src/director.lua:304, src/director.lua:418, src/director.lua:422, src/flash.lua:48, src/lang_en.lua:131, src/tips_en.lua:42 |
| flash | `flashMinAdvantage` — Speed advantage for a flash (km/h) | 3 to 40 | 12 / 8 / 8 / 15 | src/director.lua:286, src/director.lua:760, src/flash.lua:66, src/lang_en.lua:131, src/tips_en.lua:43 |
| flash | `flashCloseAdvantage` — Close-range advantage (km/h) | 1 to 15 | 5 / 4 / 4 / 6 | src/director.lua:286, src/flash.lua:66, src/lang_en.lua:131, src/tips_en.lua:44 |
| flash | `flashRequestTTL` — Request lifetime (s) | 3 to 20 | 8 / 8 / 8 / 8 | src/director.lua:769, src/flash.lua:63, src/flash.lua:64, src/lang_en.lua:131, src/tips_en.lua:45 |
| flash | `flashObliviousPct` — First flash missed (%) | 0 to 40 | 10 / 5 / 5 / 10 | src/flash.lua:60, src/lang_en.lua:131, src/tips_en.lua:46 |
| flash | `flashMaxReactors` — Cars reacting | 1 to 3 | 3 / 3 / 3 / 3 | src/flash.lua:57, src/lang_en.lua:131, src/tips_en.lua:47 |
| flash | `hornEnabled` — Horn counts as a flash | boolean | false / false / false / false | src/engine.lua:534, src/engine.lua:535, src/lang_en.lua:131, src/tips_en.lua:48 |
| flash | `aiFlashEnabled` — AI-to-AI headlight flashes | boolean | true / true / true / true | src/director.lua:756, src/lang_en.lua:131, src/tips_en.lua:49 |
| overtake | `overtakeEnabled` — Overtaking | boolean | true / true / true / true | src/director.lua:628, src/lang_en.lua:132, src/tips_en.lua:51 |
| overtake | `overtakeSide` — Overtaking side | opposite, auto, left, right | left / left / left / left | src/director.lua:76, src/director.lua:77, src/director.lua:658, src/lang_en.lua:132, src/tips_en.lua:52 |
| overtake | `overtakeOffset` — Overtaking offset | 0.2 to 0.95 | 0.7 / 0.65 / 0.65 / 0.6 | src/director.lua:550, src/lang_en.lua:132, src/tips_en.lua:53 |
| overtake | `overtakeDetectAhead` — Forward detection (m) | 20 to 200 | 60 / 50 / 50 / 50 | src/director.lua:593, src/director.lua:638, src/lang_en.lua:132, src/tips_en.lua:54 |
| overtake | `overtakeAheadMargin` — Speed advantage to overtake (km/h) | 1 to 30 | 8 / 10 / 10 / 3 | src/director.lua:631, src/lang_en.lua:132, src/tips_en.lua:55 |
| overtake | `overtakeHorizon` — Forward horizon (s) | 2 to 20 | 6 / 6 / 6 / 6 | src/director.lua:638, src/lang_en.lua:132, src/tips_en.lua:56 |
| overtake | `overtakeClearMargin` — Clearance after overtaking (m) | 8 to 40 | 18 / 20 / 20 / 10 | src/director.lua:591, src/director.lua:657, src/lang_en.lua:132, src/tips_en.lua:57 |
| overtake | `overtakeRestTime` — Pause after overtaking (s) | 0 to 10 | 2 / 3 / 3 / 1 | src/director.lua:597, src/lang_en.lua:132, src/tips_en.lua:58 |
| overtake | `overtakeChain` — Chain overtakes | boolean | true / false / false / true | src/director.lua:593, src/lang_en.lua:133, src/tips_en.lua:59 |
| overtake | `stuckTime` — Held-up confirmation (s) | 0.5 to 10 | 2 / 3 / 3 / 1.2 | src/director.lua:639, src/director.lua:760, src/lang_en.lua:133, src/tips_en.lua:60 |
| overtake | `stuckPaceRatio` — Held-up pace threshold | 0.8 to 0.99 | 0.93 / 0.93 / 0.93 / 0.95 | src/director.lua:246, src/lang_en.lua:133, src/tips_en.lua:61 |
| overtake | `pullOutGapBase` — Pull-out distance (m) | 4 to 15 | 8 / 8 / 8 / 8 | src/director.lua:588, src/lang_en.lua:133, src/tips_en.lua:62 |
| overtake | `pullOutGapPerMps` — Pull-out gain (s) | 0 to 0.5 | 0.25 / 0.25 / 0.25 / 0.25 | src/director.lua:588, src/lang_en.lua:133, src/tips_en.lua:63 |
| overtake | `slipstreamEnabled` — Slipstream | boolean | true / true / true / true | src/director.lua:686, src/director.lua:692, src/lang_en.lua:133, src/tips_en.lua:64 |
| overtake | `defenseEnabled` — Defending | boolean | true / true / true / true | src/director.lua:609, src/lang_en.lua:133, src/tips_en.lua:65 |
| overtake | `defenseMaxOffset` — Maximum defending offset | 0.1 to 0.5 | 0.35 / 0.35 / 0.35 / 0.35 | src/director.lua:600, src/lang_en.lua:133, src/tips_en.lua:66 |
| overtake | `defenseCooldown` — Pause between defences (s) | 2 to 30 | 8 / 8 / 8 / 8 | src/director.lua:616, src/lang_en.lua:133, src/tips_en.lua:67 |
| overtake | `defenseTriggerGap` — Defending distance (m) | 5 to 25 | 12 / 12 / 12 / 12 | src/director.lua:609, src/lang_en.lua:133, src/tips_en.lua:68 |
| lateral | `rampSpeed` — Lateral movement speed | 0.1 to 1 | 0.3 / 0.3 / 0.3 / 0.45 | src/director.lua:203, src/lang_en.lua:134, src/tips_en.lua:70 |
| lateral | `rampAccel` — Lateral acceleration | 0.5 to 4 | 1.5 / 1.5 / 1.5 / 2 | src/director.lua:205, src/lang_en.lua:134, src/tips_en.lua:71 |
| lateral | `lowPassTau` — Lateral smoothing (s) | 0.05 to 1 | 0.25 / 0.25 / 0.25 / 0.2 | src/director.lua:206, src/lang_en.lua:134, src/tips_en.lua:72 |
| lateral | `maxSideOffset` — Maximum offset | 0.3 to 0.95 | 0.85 / 0.85 / 0.85 / 0.8 | src/director.lua:141, src/director.lua:493, src/director.lua:512, src/director.lua:600, src/lang_en.lua:134, src/tips_en.lua:73 |
| lateral | `cornerMin` — Straight threshold | 0 to 1 | 0.35 / 0.35 / 0.35 / 0.5 | src/director.lua:265, src/director.lua:334, src/director.lua:354, src/director.lua:629, src/director.lua:757, src/director.lua:780, src/lang_en.lua:134, src/tips_en.lua:74, src/traffic.lua:194 |
| lateral | `cornerYawRef` — Yaw rate reference (rad/s) | 0.2 to 1.2 | 0.5 / 0.5 / 0.5 / 0.5 | src/director.lua:384, src/lang_en.lua:134, src/tips_en.lua:75 |
| lateral | `lateralCooldown` — Pause between direction changes (s) | 0.3 to 5 | 1.2 / 1.2 / 1.2 / 1 | src/director.lua:106, src/director.lua:119, src/lang_en.lua:134, src/tips_en.lua:76 |
| lateral | `emergencyReleaseFactor` — Release factor | 1 to 4 | 2 / 2 / 2 / 2 | src/director.lua:196, src/lang_en.lua:134, src/tips_en.lua:77 |
| human | `reactMin` — Minimum reaction (s) | 0.1 to 2 | 0.25 / 0.2 / 0.2 / 0.2 | src/lang_en.lua:135, src/persona.lua:10, src/tips_en.lua:79 |
| human | `reactMax` — Maximum reaction (s) | 0.1 to 2 | 0.9 / 0.6 / 0.6 / 0.6 | src/lang_en.lua:135, src/persona.lua:10, src/tips_en.lua:80 |
| human | `awMin` — Minimum awareness delay (s) | 0.2 to 5 | 0.6 / 0.4 / 0.4 / 0.4 | src/lang_en.lua:135, src/persona.lua:10, src/tips_en.lua:81 |
| human | `awMax` — Maximum awareness delay (s) | 0.2 to 5 | 2 / 1.2 / 1.2 / 1.2 | src/lang_en.lua:135, src/persona.lua:10, src/tips_en.lua:82 |
| human | `paceDriftPct` — Slow pace drift (%) | 0 to 6 | 2 / 1 / 1 / 1 | src/director.lua:86, src/lang_en.lua:135, src/tips_en.lua:83 |
| human | `personalLineJitter` — Line variation | 0 to 0.15 | 0.05 / 0.03 / 0.03 / 0.02 | src/director.lua:605, src/lang_en.lua:135, src/tips_en.lua:84 |
| human | `lapseEnabled` — Brief lapses in focus | boolean | true / false / false / false | src/director.lua:734, src/lang_en.lua:135, src/tips_en.lua:85 |
| human | `lapseIntervalMin` — Minimum interval (s) | 20 to 900 | 60 / 120 / 120 / 120 | src/lang_en.lua:136, src/persona.lua:24, src/persona.lua:42, src/tips_en.lua:86 |
| human | `lapseIntervalMax` — Maximum interval (s) | 20 to 900 | 300 / 600 / 600 / 600 | src/lang_en.lua:136, src/persona.lua:24, src/persona.lua:42, src/tips_en.lua:87 |
| human | `lapseDurMin` — Minimum duration (s) | 0.5 to 8 | 1.5 / 1 / 1 / 1 | src/lang_en.lua:136, src/persona.lua:25, src/persona.lua:43, src/tips_en.lua:88 |
| human | `lapseDurMax` — Maximum duration (s) | 0.5 to 8 | 3 / 2 / 2 / 2 | src/lang_en.lua:136, src/persona.lua:25, src/persona.lua:43, src/tips_en.lua:89 |
| human | `lapseDropMin` — Minimum pace loss (%) | 0 to 25 | 6 / 3 / 3 / 3 | src/lang_en.lua:136, src/persona.lua:26, src/persona.lua:44, src/tips_en.lua:90 |
| human | `lapseDropMax` — Maximum pace loss (%) | 0 to 25 | 12 / 7 / 7 / 7 | src/lang_en.lua:136, src/persona.lua:26, src/persona.lua:44, src/tips_en.lua:91 |
| human | `laneBiasEnabled` — Pace-based line | boolean | true / false / false / false | src/lang_en.lua:136, src/persona.lua:23, src/tips_en.lua:92 |
| human | `laneBiasMax` — Maximum line bias | 0 to 0.4 | 0.25 / 0.25 / 0.25 / 0.25 | src/lang_en.lua:136, src/persona.lua:23, src/tips_en.lua:93 |
| human | `mistakesEnabled` — AI driving mistakes (lock-ups, wheelspin) | boolean | true / true / true / true | src/lang_en.lua:137, src/mistakes.lua:44, src/tips_en.lua:94 |
| human | `mistakeRate` — Mistakes: rate (per hour per AI) | 0 to 6 | 1 / 0.5 / 0.5 / 0.5 | src/lang_en.lua:137, src/mistakes.lua:44, src/mistakes.lua:65, src/tips_en.lua:95 |
| start | `startDelay` — Start delay (s) | 0 to 30 | 0 / 0 / 0 / 1 | src/applier.lua:10, src/applier.lua:232, src/applier.lua:387, src/applier.lua:388, src/applier.lua:391, src/applier.lua:407, src/applier.lua:489, src/applier.lua:697, src/caps.lua:2, src/director.lua:431, src/director.lua:435, src/director.lua:453, src/director.lua:679, src/director.lua:726, src/director.lua:727, src/engine.lua:107, src/engine.lua:296, src/engine.lua:300, src/engine.lua:304, src/engine.lua:316, src/lang_en.lua:138, src/mistakes.lua:47, src/tips_en.lua:97, src/traffic.lua:17, src/traffic.lua:140, src/traffic.lua:158, src/traffic.lua:162 |
| start | `startCautionMult` — Caution at the start | 1 to 3 | 1 / 1 / 1 / 1.3 | src/director.lua:729, src/engine.lua:39, src/lang_en.lua:138, src/tips_en.lua:99 |
| start | `startAggrMult` — Aggression at the start | 0.2 to 1 | 1 / 1 / 1 / 0.8 | src/director.lua:729, src/engine.lua:39, src/lang_en.lua:138, src/tips_en.lua:100 |
| start | `startRelax` — Settling time after the start (s) | 2 to 30 | 12 / 12 / 12 / 25 | src/director.lua:431, src/director.lua:679, src/director.lua:726, src/director.lua:727, src/engine.lua:304, src/lang_en.lua:138, src/mistakes.lua:47, src/tips_en.lua:101 |
| start | `startLaneHold` — Hold the grid lane at the start | boolean | false / false / false / false | src/director.lua:731, src/engine.lua:39, src/engine.lua:304, src/lang_en.lua:138, src/tips_en.lua:98 |
| accidents | `obstacleEnabled` — Avoid stopped or crashed cars | boolean | true / true / true / true | src/director.lua:453, src/lang_en.lua:139, src/tips_en.lua:103 |
| accidents | `obstacleSpeedKmh` — Obstacle speed (km/h) | 5 to 50 | 25 / 25 / 25 / 25 | src/director.lua:457, src/director.lua:458, src/director.lua:497, src/engine.lua:332, src/incidents.lua:110, src/incidents.lua:145, src/incidents.lua:155, src/incidents.lua:188, src/lang_en.lua:139, src/penalties.lua:39, src/tips_en.lua:104 |
| accidents | `obstacleDetect` — Obstacle detection (m) | 50 to 300 | 150 / 150 / 150 / 150 | src/director.lua:457, src/director.lua:474, src/lang_en.lua:139, src/tips_en.lua:105 |
| accidents | `obstacleLevelDrop` — Level drop near an obstacle (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/director.lua:485, src/lang_en.lua:139, src/tips_en.lua:106 |
| accidents | `obstacleCautionMult` — Caution near an obstacle | 1 to 3 | 1.5 / 1.5 / 1.5 / 1.5 | src/director.lua:485, src/lang_en.lua:139, src/tips_en.lua:107 |
| accidents | `avoidOffset` — Avoidance offset | 0.3 to 0.9 | 0.6 / 0.6 / 0.6 / 0.6 | src/director.lua:493, src/lang_en.lua:47, src/lang_en.lua:139, src/tips_en.lua:108 |
| accidents | `contactRecovery` — Recovery after contact | boolean | true / true / true / true | src/director.lua:441, src/lang_en.lua:140, src/tips_en.lua:109 |
| accidents | `incidentStop` — Crashed AI stop | boolean | true / true / true / true | src/incidents.lua:186, src/lang_en.lua:140, src/tips_en.lua:110 |
| accidents | `incidentStopMin` — Minimum stop (s) | 1 to 15 | 3 / 3 / 3 / 3 | src/incidents.lua:190, src/lang_en.lua:140, src/tips_en.lua:111 |
| accidents | `incidentStopMax` — Maximum stop (s) | 1 to 30 | 8 / 8 / 8 / 8 | src/incidents.lua:190, src/lang_en.lua:140, src/tips_en.lua:112 |
| accidents | `rejoinGap` — Clear track behind to rejoin (m) | 30 to 300 | 120 / 120 / 120 / 120 | src/incidents.lua:98, src/lang_en.lua:140, src/tips_en.lua:113 |
| accidents | `yellowEnabled` — Yellow flags (incident zone) | boolean | true / true / true / true | src/incidents.lua:374, src/incidents.lua:432, src/lang_en.lua:47, src/lang_en.lua:141, src/tips_en.lua:114 |
| accidents | `yellowBefore` — Zone start before the incident (m) | 50 to 800 | 300 / 300 / 300 / 300 | src/incidents.lua:364, src/incidents.lua:379, src/incidents.lua:382, src/incidents.lua:437, src/incidents.lua:438, src/incidents.lua:446, src/incidents.lua:447, src/lang_en.lua:141, src/tips_en.lua:118 |
| accidents | `yellowAfter` — Zone end after the incident (m) | 0 to 300 | 50 / 50 / 50 / 50 | src/incidents.lua:379, src/incidents.lua:437, src/lang_en.lua:141, src/tips_en.lua:119 |
| accidents | `yellowHold` — Hold after clearing (s) | 0 to 60 | 10 / 10 / 10 / 10 | src/incidents.lua:177, src/lang_en.lua:141, src/penalties.lua:39, src/tips_en.lua:120 |
| accidents | `yellowDecel` — Approach deceleration (m/s²) | 2 to 10 | 5 / 5 / 5 / 5 | src/delta.lua:146, src/delta.lua:178, src/director.lua:407, src/engine.lua:618, src/incidents.lua:390, src/incidents.lua:429, src/lang_en.lua:141, src/tips_en.lua:121 |
| accidents | `zoneDeltaPct` — Double yellow: reference time slower by (%) | 5 to 200 | 15 / 15 / 15 / 15 | src/delta.lua:77, src/lang_en.lua:47, src/lang_en.lua:142, src/tips_en.lua:116 |
| accidents | `slowZoneKmh` — Double yellow: Slow Zone speed (km/h, 0 = delta time) | 0 to 150 | 0 / 0 / 0 / 0 | src/delta.lua:76, src/lang_en.lua:142, src/tips_en.lua:117 |
| accidents | `yellowSpeedKmh` — Double yellow: fallback speed, unknown pace (km/h) | 30 to 200 | 50 / 50 / 50 / 50 | src/delta.lua:77, src/incidents.lua:428, src/lang_en.lua:142, src/tips_en.lua:115 |
| accidents | `yellowHud` — AC native yellow flag on the HUD | boolean | false / false / false / false | src/incidents.lua:457, src/lang_en.lua:47, src/lang_en.lua:143, src/tips_en.lua:133 |
| accidents | `flagPanel` — ACAdvancedIA flag panel while driving | boolean | true / true / true / true | src/lang_en.lua:143, src/panel.lua:124, src/tips_en.lua:134 |
| accidents | `yellowMessage` — On-screen incident messages | boolean | true / true / true / true | src/engine.lua:509, src/engine.lua:512, src/engine.lua:525, src/incidents.lua:69, src/incidents.lua:229, src/incidents.lua:239, src/incidents.lua:247, src/incidents.lua:255, src/incidents.lua:267, src/incidents.lua:274, src/incidents.lua:310, src/incidents.lua:328, src/incidents.lua:334, src/incidents.lua:344, src/incidents.lua:447, src/lang_en.lua:143, src/tips_en.lua:135 |
| accidents | `deltaBeeps` — Delta: beeps | boolean | true / true / true / true | src/engine.lua:423, src/lang_en.lua:143, src/tips_en.lua:131 |
| accidents | `playerPenalties` — Player penalties under flags | boolean | false / true / true / true | src/lang_en.lua:47, src/lang_en.lua:144, src/penalties.lua:77, src/penalties.lua:78, src/tips_en.lua:129 |
| accidents | `deltaTolerance` — Delta: mini-sector tolerance (s) | 0 to 1 | 0.5 / 0.5 / 0.5 / 0.5 | src/delta.lua:125, src/lang_en.lua:144, src/tips_en.lua:130 |
| accidents | `penaltySeconds` — Penalty: throttle cut (s) | 2 to 15 | 5 / 5 / 5 / 5 | src/engine.lua:527, src/lang_en.lua:144, src/penalties.lua:80, src/penalties.lua:81, src/penalties.lua:85, src/penalties.lua:116, src/penalties.lua:126, src/penalties.lua:139, src/tips_en.lua:132 |
| accidents | `penaltyDisqualify` — Infringements allowed before disqualification | 1 to 20 | 5 / 5 / 5 / 5 | src/engine.lua:499, src/engine.lua:511, src/engine.lua:527, src/lang_en.lua:144, src/penalties.lua:53, src/penalties.lua:138, src/tips_en.lua:127 |
| accidents | `aiPenalties` — AI sanctions under flags | boolean | false / true / true / true | src/lang_en.lua:144, src/penalties.lua:149, src/tips_en.lua:128 |
| rules | `noMoveBraking` — No change of direction under braking | boolean | true / true / true / true | src/director.lua:433, src/lang_en.lua:46, src/lang_en.lua:145, src/tips_en.lua:137 |
| rules | `neutralization` — Neutralisation after a major incident | local, fcy, vsc, sc | local / local / local / local | src/engine.lua:57, src/incidents.lua:214, src/incidents.lua:338, src/lang_en.lua:145, src/tips_en.lua:138 |
| rules | `majorIncidentTime` — Major incident: car stopped on track (s) | 5 to 60 | 15 / 15 / 15 / 15 | src/engine.lua:56, src/engine.lua:57, src/incidents.lua:174, src/incidents.lua:224, src/lang_en.lua:145, src/tips_en.lua:139 |
| rules | `fcySpeedKmh` — FCY: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:85, src/delta.lua:88, src/delta.lua:90, src/incidents.lua:341, src/incidents.lua:405, src/lang_en.lua:145, src/tips_en.lua:140 |
| rules | `fcyDeltaPct` — FCY: reference time slower by (%) | 10 to 150 | 50 / 50 / 50 / 50 | src/delta.lua:88, src/delta.lua:90, src/incidents.lua:239, src/incidents.lua:405, src/lang_en.lua:145, src/panel.lua:145, src/tips_en.lua:141 |
| rules | `vscDeltaPct` — VSC: reference time slower by (%) | 10 to 80 | 30 / 30 / 30 / 30 | src/delta.lua:85, src/incidents.lua:239, src/incidents.lua:405, src/lang_en.lua:145, src/panel.lua:144, src/tips_en.lua:142 |
| rules | `neutralizationHold` — Minimum neutralisation time (s) | 10 to 180 | 30 / 30 / 30 / 30 | src/incidents.lua:226, src/incidents.lua:249, src/incidents.lua:341, src/lang_en.lua:146, src/tips_en.lua:143 |
| rules | `safetyCarSpeedKmh` — Safety Car speed (km/h) | 60 to 250 | 120 / 120 / 120 / 120 | src/delta.lua:145, src/incidents.lua:296, src/incidents.lua:358, src/incidents.lua:403, src/incidents.lua:406, src/lang_en.lua:146, src/tips_en.lua:144 |
| rules | `safetyCarEscalation` — Safety Car if the incident escalates | boolean | false / true / true / true | src/engine.lua:50, src/incidents.lua:222, src/incidents.lua:223, src/lang_en.lua:146, src/tips_en.lua:145 |
| rules | `redFlagEnabled` — Red flag on a serious accident (practice, qualifying, race) | boolean | true / true / true / true | src/engine.lua:51, src/incidents.lua:304, src/lang_en.lua:46, src/lang_en.lua:147, src/tips_en.lua:146 |
| rules | `redFlagCars` — Red flag: cars stopped on track | 2 to 10 | 3 / 3 / 3 / 3 | src/incidents.lua:305, src/lang_en.lua:147, src/tips_en.lua:147 |
| rules | `redFlagSpeedKmh` — Red flag: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:82, src/incidents.lua:307, src/incidents.lua:410, src/lang_en.lua:147, src/tips_en.lua:148 |
| rules | `redDeltaPct` — Red flag: reference time slower by (%) | 10 to 200 | 60 / 60 / 60 / 60 | src/delta.lua:82, src/incidents.lua:410, src/lang_en.lua:147, src/tips_en.lua:149 |
| rules | `redFlagHold` — Red flag: minimum suspension (s) | 20 to 600 | 60 / 60 / 60 / 60 | src/incidents.lua:307, src/incidents.lua:323, src/lang_en.lua:147, src/tips_en.lua:150 |
| rules | `redFlagWork` — Red flag: tyres changed in the pits (stop counts) | boolean | false / false / false / false | src/lang_en.lua:147, src/pits.lua:94, src/pits.lua:119, src/pits.lua:124, src/tips_en.lua:151 |
| rules | `mandatoryStops` — Mandatory stops in the race | 0 to 3 | 0 / 0 / 0 / 0 | src/engine.lua:566, src/engine.lua:569, src/hudinfo.lua:106, src/hudinfo.lua:107, src/hudinfo.lua:108, src/lang_en.lua:46, src/lang_en.lua:148, src/pits.lua:47, src/pits.lua:57, src/pits.lua:62, src/pits.lua:105, src/pits.lua:107, src/pits.lua:115, src/pits.lua:159, src/pits.lua:160, src/tips_en.lua:152 |
| rules | `pitWindowOpenPct` — Window opens (% of race) | 5 to 95 | 25 / 25 / 25 / 25 | src/lang_en.lua:148, src/pits.lua:53, src/tips_en.lua:153 |
| rules | `pitWindowClosePct` — Window closes (% of race) | 5 to 100 | 75 / 75 / 75 / 75 | src/lang_en.lua:148, src/pits.lua:53, src/tips_en.lua:154 |
| rules | `pitTyres` — New tyres at every stop (pit rules active) | boolean | true / true / true / true | src/lang_en.lua:148, src/pits.lua:119, src/tips_en.lua:155 |
| rules | `pitRepair` — Repairs at every stop in the race (bodywork, suspension, engine) | boolean | true / true / true / true | src/applier.lua:349, src/engine.lua:107, src/lang_en.lua:148, src/pits.lua:99, src/pits.lua:124, src/pits.lua:126, src/tips_en.lua:156 |
| rules | `pitCompoundChange` — Change dry compound (F1) | boolean | false / false / false / false | src/lang_en.lua:148, src/pits.lua:33, src/pits.lua:56, src/tips_en.lua:157 |
| rules | `minPitTime` — Minimum stop time (s, 0 = free) | 0 to 120 | 0 / 0 / 0 / 0 | src/lang_en.lua:149, src/pits.lua:47, src/pits.lua:118, src/tips_en.lua:158 |
| rules | `maxStintMin` — Maximum stint (min, 0 = free) | 0 to 240 | 0 / 0 / 0 / 0 | src/lang_en.lua:149, src/pits.lua:47, src/pits.lua:111, src/pits.lua:165, src/tips_en.lua:160 |
| rules | `pitFuel` — Fuel at enforced stops | refuel, plan, ac | refuel / refuel / refuel / refuel | src/lang_en.lua:149, src/pits.lua:172, src/tips_en.lua:159 |
| rules | `pitsClosed` — Pit lane closed under neutralisation | open, pitFcy, pitFcySc | open / open / open / open | src/engine.lua:562, src/incidents.lua:17, src/incidents.lua:28, src/incidents.lua:295, src/incidents.lua:298, src/lang_en.lua:149, src/tips_en.lua:161 |
| rules | `pitMessage` — Pit window opening message | boolean | true / true / true / true | src/lang_en.lua:149, src/pits.lua:59, src/pits.lua:69, src/tips_en.lua:162 |
| rules | `overtakeMode` — Overtake Mode (F1 2026, within one second at detection) | boolean | false / false / false / false | src/director.lua:776, src/lang_en.lua:46, src/lang_en.lua:150, src/tips_en.lua:163 |
| rules | `overtakeModeGap` — Overtake Mode: detection gap (s) | 0.3 to 2 | 1 / 1 / 1 / 1 | src/director.lua:778, src/lang_en.lua:150, src/tips_en.lua:164 |
| rules | `overtakeModeBoostPct` — Overtake Mode: level gain (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/director.lua:780, src/lang_en.lua:150, src/tips_en.lua:165 |
| rules | `drsAssist` — Player DRS: beep and panel | boolean | true / true / true / true | src/engine.lua:321, src/engine.lua:487, src/engine.lua:533, src/lang_en.lua:46, src/lang_en.lua:151, src/panel.lua:102, src/panel.lua:130, src/tips_en.lua:126 |
| rules | `rulesDrs` — DRS: racing rules (rain, flags, start, Safety Car, red flag) | boolean | false / true / true / true | src/engine.lua:434, src/lang_en.lua:151, src/tips_en.lua:123 |
| rules | `rulesDrsLaps` — DRS: leader laps before enabling (start, SC, red flag) | 0 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:458, src/lang_en.lua:151, src/tips_en.lua:124 |
| rules | `aiDrs` — AI DRS: opened in the zones | boolean | true / true / true / true | src/engine.lua:472, src/lang_en.lua:151, src/tips_en.lua:125 |
| rules | `drsBeepVolume` — Beeps (DRS and delta): volume (%) | 25 to 400 | 200 / 200 / 200 / 200 | src/engine.lua:321, src/engine.lua:427, src/engine.lua:533, src/lang_en.lua:151, src/tips_en.lua:122 |
| rules | `bopEnabled` — BoP: pace evened out within each class | boolean | false / false / false / false | src/classes.lua:42, src/director.lua:91, src/lang_en.lua:46, src/lang_en.lua:152, src/tips_en.lua:166 |
| rules | `bopStrengthPct` — BoP: maximum correction (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/classes.lua:45, src/lang_en.lua:152, src/tips_en.lua:167 |
| rules | `proAmEnabled` — Pro-Am driver ratings (Bronze to Platinum) | boolean | false / false / false / false | src/lang_en.lua:152, src/persona.lua:31, src/persona.lua:32, src/tips_en.lua:168 |
| rules | `predictableSlowClass` — Slower class: predictable line | boolean | false / false / false / false | src/director.lua:513, src/lang_en.lua:46, src/lang_en.lua:152, src/tips_en.lua:169 |
| endurance | `enduranceOverlay` — Endurance layer | boolean | false / false / false / false | src/director.lua:92, src/director.lua:381, src/director.lua:735, src/lang_en.lua:153, src/persona.lua:6, src/tips_en.lua:171 |
| endurance | `multiClass` — Multi-class | boolean | false / false / false / false | src/delta.lua:122, src/director.lua:63, src/director.lua:824, src/engine.lua:375, src/engine.lua:540, src/incidents.lua:371, src/lang_en.lua:153, src/tips_en.lua:172 |
| endurance | `classGapPct` — Gap between classes (%) | 3 to 25 | 8 / 8 / 8 / 8 | src/classes.lua:31, src/lang_en.lua:153, src/tips_en.lua:173 |
| endurance | `classYieldMargin` — Class speed advantage (km/h) | 1 to 15 | 4 / 4 / 4 / 4 | src/director.lua:285, src/director.lua:528, src/lang_en.lua:153, src/tips_en.lua:174 |
| endurance | `stintLevelSwing` — Variation between stints (%) | 0 to 8 | 3 / 3 / 3 / 3 | src/lang_en.lua:153, src/persona.lua:28, src/tips_en.lua:175 |
| endurance | `stintDegradationPct` — Degradation over a stint (%) | 0 to 5 | 1 / 1 / 1 / 1 | src/director.lua:93, src/lang_en.lua:153, src/tips_en.lua:176 |
| weather | `weatherAdaptation` — Adapt pace to the weather | boolean | true / true / true / true | src/director.lua:96, src/director.lua:303, src/lang_en.lua:154, src/tips_en.lua:178 |
| weather | `weatherTyresEnabled` — Manage dry and wet tyres | boolean | true / true / true / true | src/engine.lua:548, src/lang_en.lua:154, src/tips_en.lua:179, src/weather.lua:25 |
| weather | `weatherMessage` — On-screen message on a weather change | boolean | true / true / true / true | src/engine.lua:554, src/lang_en.lua:154, src/tips_en.lua:180 |
| weather | `rainGripBoostPct` — Rain compensation without wet tyres (%) | 0 to 30 | 15 / 15 / 15 / 15 | src/lang_en.lua:154, src/tips_en.lua:181, src/weather.lua:38 |
| traffic | `trafficGapSeconds` — Base gap (s) | 0.5 to 5 | 2.5 / 2.5 / 2.5 / 2.5 | src/lang_en.lua:155, src/tips_en.lua:183, src/traffic.lua:204 |
| traffic | `trafficDensityGain` — Distance added per AI (m) | 0.5 to 5 | 2.8 / 2.8 / 2.8 / 2.8 | src/lang_en.lua:155, src/tips_en.lua:184, src/traffic.lua:204 |
| traffic | `trafficVariation` — Gap variation (%) | 0 to 50 | 45 / 45 / 45 / 45 | src/lang_en.lua:155, src/tips_en.lua:185, src/traffic.lua:203 |
| traffic | `trafficMaxReduction` — Maximum speed reduction (%) | 2 to 20 | 14 / 14 / 14 / 14 | src/lang_en.lua:155, src/tips_en.lua:186, src/traffic.lua:214 |

## Adjustable global options

| Key | Default | Range | Consumers |
|---|---|---|---|
| `levelMode` | auto | auto, native, grip, none | src/applier.lua:715, src/applier.lua:722, src/caps.lua:4, src/caps.lua:41, src/caps.lua:42, src/lang_en.lua:60, src/tips_en.lua:202 |
| `useGripBoost` | false | boolean | src/applier.lua:722, src/caps.lua:42, src/tips_en.lua:203 |
| `gripPerLevelPct` | 0.004 | [0, 0.01] | src/applier.lua:722, src/lang_en.lua:124, src/tips_en.lua:214 |
| `useBrakeAssist` | true | boolean | src/applier.lua:703, src/applier.lua:729, src/director.lua:701, src/engine.lua:39, src/tips_en.lua:204 |
| `overrideAwareness` | false | boolean | src/applier.lua:710, src/tips_en.lua:205 |
| `occLatMin` | 0.3 | [0.1, 1] | src/lang_en.lua:124, src/perception.lua:46, src/perception.lua:47, src/perception.lua:48, src/tips_en.lua:210 |
| `occLatMax` | 5.5 | [2, 8] | src/director.lua:427, src/director.lua:493, src/director.lua:564, src/director.lua:593, src/director.lua:660, src/lang_en.lua:124, src/perception.lua:47, src/perception.lua:48, src/perception.lua:98, src/tips_en.lua:211 |
| `occMargin` | 6 | [2, 15] | src/lang_en.lua:124, src/perception.lua:43, src/tips_en.lua:212 |
| `occSpeedGain` | 0.8 | [0, 2] | src/lang_en.lua:124, src/perception.lua:43, src/tips_en.lua:213 |
| `seed` | 19731019 | [0, 2147483647] | src/director.lua:53, src/director.lua:324, src/director.lua:380, src/director.lua:615, src/director.lua:737, src/engine.lua:91, src/engine.lua:158, src/engine.lua:284, src/engine.lua:373, src/engine.lua:542, src/engine.lua:562, src/flash.lua:60, src/incidents.lua:119, src/incidents.lua:190, src/lang_en.lua:61, src/mistakes.lua:65, src/mistakes.lua:74, src/persona.lua:5, src/persona.lua:8, src/persona.lua:9, src/persona.lua:28, src/persona.lua:30, src/persona.lua:37, src/persona.lua:40, src/persona.lua:42, src/persona.lua:43, src/persona.lua:44, src/pits.lua:46, src/pits.lua:108, src/tips_en.lua:215, src/tips_en.lua:232, src/tips_en.lua:291, src/traffic.lua:64, src/traffic.lua:81, src/traffic.lua:115, src/traffic.lua:192, src/util.lua:18, src/util.lua:19, src/util.lua:32, src/weather.lua:9, src/weather.lua:11, src/weather.lua:14, src/weather.lua:28 |
| `debugLog` | false | boolean | src/director.lua:60, src/lang_en.lua:61, src/tips_en.lua:209 |

The section switches go through `C.on`/`C.effective` and are walked by the interface tests. `classPatterns` uses the `C.patterns` parser, `Classes.configure/update`, the eight dedicated rows and validated storage. The manual/automatic choice, the main button, panic, presets and the diagnostics tools are examined in AUDIT_V1.md.

## Functions examined

List taken from the AST of the 33 active files, including local and anonymous functions. The review, fixes and limits are in AUDIT_V1.md. This list does not mean 100% branch coverage.

| File | Line | Function |
|---|---|---|
| ACAdvancedIA.lua | 40 | `announce` |
| ACAdvancedIA.lua | 47 | `dirty` |
| ACAdvancedIA.lua | 55 | `(anonymous)` |
| ACAdvancedIA.lua | 66 | `writeJournal` |
| ACAdvancedIA.lua | 85 | `cancelProbe` |
| ACAdvancedIA.lua | 94 | `syncRestored` |
| ACAdvancedIA.lua | 104 | `anyOwned` |
| ACAdvancedIA.lua | 109 | `step` |
| ACAdvancedIA.lua | 115 | `stop` |
| ACAdvancedIA.lua | 121 | `saveRace` |
| ACAdvancedIA.lua | 127 | `release` |
| ACAdvancedIA.lua | 139 | `(anonymous)` |
| ACAdvancedIA.lua | 157 | `session` |
| ACAdvancedIA.lua | 162 | `update` |
| ACAdvancedIA.lua | 182 | `(anonymous)` |
| ACAdvancedIA.lua | 183 | `(anonymous)` |
| ACAdvancedIA.lua | 272 | `protect` |
| ACAdvancedIA.lua | 281 | `script.HUMANAI__UPDATE` |
| ACAdvancedIA.lua | 292 | `script.update` |
| ACAdvancedIA.lua | 293 | `script.HUMANAI__MENU` |
| ACAdvancedIA.lua | 296 | `protectUI` |
| ACAdvancedIA.lua | 304 | `script.HUMANAI__MAIN` |
| ACAdvancedIA.lua | 314 | `script.HUMANAI__FLAGS` |
| ACAdvancedIA.lua | 316 | `script.HUMANAI__HUD` |
| src/applier.lua | 13 | `note` |
| src/applier.lua | 16 | `callable` |
| src/applier.lua | 24 | `initClock` |
| src/applier.lua | 32 | `present` |
| src/applier.lua | 38 | `setBrake` |
| src/applier.lua | 43 | `setFlash` |
| src/applier.lua | 44 | `write` |
| src/applier.lua | 60 | `(anonymous)` |
| src/applier.lua | 64 | `M.new` |
| src/applier.lua | 73 | `(anonymous)` |
| src/applier.lua | 83 | `M.clock` |
| src/applier.lua | 93 | `M.access` |
| src/applier.lua | 100 | `M.openStore` |
| src/applier.lua | 127 | `M.savePreset` |
| src/applier.lua | 133 | `(anonymous)` |
| src/applier.lua | 141 | `M.deletePreset` |
| src/applier.lua | 143 | `(anonymous)` |
| src/applier.lua | 148 | `readRaceFlagsHidden` |
| src/applier.lua | 151 | `M.menu` |
| src/applier.lua | 168 | `M.compactWindow` |
| src/applier.lua | 172 | `(anonymous)` |
| src/applier.lua | 174 | `(anonymous)` |
| src/applier.lua | 179 | `M.baselines` |
| src/applier.lua | 185 | `M.dirty` |
| src/applier.lua | 186 | `M.rebase` |
| src/applier.lua | 195 | `M.save` |
| src/applier.lua | 198 | `(anonymous)` |
| src/applier.lua | 210 | `restoreRain` |
| src/applier.lua | 214 | `restoreSkin` |
| src/applier.lua | 218 | `(anonymous)` |
| src/applier.lua | 222 | `M.restore` |
| src/applier.lua | 272 | `send` |
| src/applier.lua | 280 | `field` |
| src/applier.lua | 285 | `claim` |
| src/applier.lua | 294 | `weather` |
| src/applier.lua | 321 | `tyreLabel` |
| src/applier.lua | 327 | `pitRequest` |
| src/applier.lua | 387 | `startDelay` |
| src/applier.lua | 397 | `place` |
| src/applier.lua | 413 | `hold` |
| src/applier.lua | 424 | `M.flag` |
| src/applier.lua | 432 | `flash` |
| src/applier.lua | 444 | `safetySkin` |
| src/applier.lua | 448 | `(anonymous)` |
| src/applier.lua | 450 | `(anonymous)` |
| src/applier.lua | 457 | `safety` |
| src/applier.lua | 465 | `(anonymous)` |
| src/applier.lua | 500 | `recover` |
| src/applier.lua | 510 | `M.releaseBlackFlag` |
| src/applier.lua | 517 | `M.penalty` |
| src/applier.lua | 531 | `disposeBeep` |
| src/applier.lua | 531 | `(anonymous)` |
| src/applier.lua | 532 | `M.beep` |
| src/applier.lua | 540 | `play` |
| src/applier.lua | 553 | `M.deltaBeep` |
| src/applier.lua | 560 | `(anonymous)` |
| src/applier.lua | 564 | `play` |
| src/applier.lua | 569 | `(anonymous)` |
| src/applier.lua | 574 | `M.drs` |
| src/applier.lua | 598 | `releaseDrs` |
| src/applier.lua | 605 | `M.sessionBox` |
| src/applier.lua | 606 | `M.screen` |
| src/applier.lua | 612 | `M.listenMessages` |
| src/applier.lua | 616 | `M.blockMessages` |
| src/applier.lua | 620 | `M.dispose` |
| src/applier.lua | 623 | `M.journalOpen` |
| src/applier.lua | 625 | `(anonymous)` |
| src/applier.lua | 641 | `M.clockText` |
| src/applier.lua | 646 | `M.journalWrite` |
| src/applier.lua | 650 | `(anonymous)` |
| src/applier.lua | 655 | `M.storeText` |
| src/applier.lua | 656 | `M.loadText` |
| src/applier.lua | 657 | `M.message` |
| src/applier.lua | 659 | `M.probeMessage` |
| src/applier.lua | 662 | `floodPath` |
| src/applier.lua | 667 | `M.floodRead` |
| src/applier.lua | 676 | `M.floodWrite` |
| src/applier.lua | 682 | `M.apply` |
| src/applier.lua | 745 | `M.register` |
| src/applier.lua | 749 | `M.unregister` |
| src/applier.lua | 751 | `(anonymous)` |
| src/applier.lua | 756 | `M.nextSession` |
| src/applier.lua | 777 | `M.clipboard` |
| src/applier.lua | 778 | `M.checkpoint` |
| src/applier.lua | 789 | `M.recover` |
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
| src/config.lua | 324 | `M.defaults` |
| src/config.lua | 333 | `M.sectionsChanged` |
| src/config.lua | 340 | `M.anySection` |
| src/config.lua | 344 | `choice` |
| src/config.lua | 345 | `M.patterns` |
| src/config.lua | 355 | `M.validate` |
| src/config.lua | 383 | `M.validateGlobals` |
| src/config.lua | 401 | `M.preset` |
| src/config.lua | 413 | `M.on` |
| src/config.lua | 414 | `M.any` |
| src/config.lua | 419 | `M.effective` |
| src/config.lua | 450 | `M.effectiveGlobals` |
| src/config.lua | 457 | `M.needsOffset` |
| src/config.lua | 460 | `equal` |
| src/config.lua | 473 | `M.legacyMatch` |
| src/config.lua | 498 | `M.upgradeObstacles` |
| src/config.lua | 509 | `M.migrateProfile` |
| src/config.lua | 557 | `M.migrate` |
| src/config.lua | 618 | `M.kept` |
| src/config.lua | 619 | `ruleValue` |
| src/config.lua | 620 | `M.restore` |
| src/config.lua | 629 | `applyValues` |
| src/config.lua | 633 | `M.weekendSwitch` |
| src/config.lua | 642 | `M.applyRules` |
| src/config.lua | 663 | `category13` |
| src/config.lua | 677 | `M.migrateRules` |
| src/config.lua | 687 | `M.closestRuleCategory` |
| src/config.lua | 696 | `M.ruleCategory` |
| src/config.lua | 708 | `M.autoProfile` |
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
| src/director.lua | 14 | `M.newState` |
| src/director.lua | 35 | `M.reset` |
| src/director.lua | 52 | `M.configure` |
| src/director.lua | 56 | `transition` |
| src/director.lua | 63 | `faster` |
| src/director.lua | 64 | `sideFree` |
| src/director.lua | 66 | `userSide` |
| src/director.lua | 67 | `fixedSide` |
| src/director.lua | 68 | `yieldSide` |
| src/director.lua | 75 | `passSide` |
| src/director.lua | 84 | `baseModifiers` |
| src/director.lua | 101 | `directionAllowed` |
| src/director.lua | 118 | `directionBudget` |
| src/director.lua | 128 | `wanted` |
| src/director.lua | 129 | `limitText` |
| src/director.lua | 138 | `M.reachable` |
| src/director.lua | 149 | `laneTarget` |
| src/director.lua | 158 | `laneHold` |
| src/director.lua | 184 | `M.lateral` |
| src/director.lua | 217 | `busy` |
| src/director.lua | 230 | `pace` |
| src/director.lua | 248 | `lapOrClass` |
| src/director.lua | 253 | `yieldTrigger` |
| src/director.lua | 352 | `M.trafficCap` |
| src/director.lua | 362 | `M.step` |
| src/engine.lua | 21 | `startReport` |
| src/engine.lua | 47 | `decisionTime` |
| src/engine.lua | 63 | `contacts` |
| src/engine.lua | 87 | `M.new` |
| src/engine.lua | 95 | `(anonymous)` |
| src/engine.lua | 97 | `(anonymous)` |
| src/engine.lua | 111 | `M.changed` |
| src/engine.lua | 112 | `M.select` |
| src/engine.lua | 115 | `M.reset` |
| src/engine.lua | 119 | `M.rebase` |
| src/engine.lua | 146 | `M.configure` |
| src/engine.lua | 163 | `drsBeep` |
| src/engine.lua | 169 | `drive` |
| src/engine.lua | 183 | `M.message` |
| src/engine.lua | 192 | `M.floodInit` |
| src/engine.lua | 201 | `flood` |
| src/engine.lua | 228 | `M.step` |
| src/flash.lua | 4 | `M.new` |
| src/flash.lua | 13 | `M.learn` |
| src/flash.lua | 14 | `M.sampleLearn` |
| src/flash.lua | 26 | `M.step` |
| src/flash.lua | 39 | `M.dispatch` |
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
| src/incidents.lua | 354 | `M.safety` |
| src/incidents.lua | 364 | `position` |
| src/incidents.lua | 369 | `M.cap` |
| src/incidents.lua | 416 | `M.player` |
| src/journal.lua | 3 | `M.new` |
| src/journal.lua | 5 | `M.collect` |
| src/journal.lua | 14 | `M.take` |
| src/journal.lua | 22 | `M.summary` |
| src/journal.lua | 45 | `c` |
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
| src/panel.lua | 12 | `M.new` |
| src/panel.lua | 16 | `blue` |
| src/panel.lua | 36 | `native` |
| src/panel.lua | 58 | `show` |
| src/panel.lua | 94 | `M.native` |
| src/panel.lua | 109 | `M.visible` |
| src/panel.lua | 115 | `M.infractions` |
| src/panel.lua | 122 | `M.notice` |
| src/panel.lua | 123 | `M.update` |
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
| src/presets.lua | 69 | `M.capture` |
| src/presets.lua | 75 | `M.encode` |
| src/presets.lua | 81 | `M.apply` |
| src/snapshot.lua | 4 | `hexByte` |
| src/snapshot.lua | 6 | `collidedWith` |
| src/snapshot.lua | 9 | `damageRead` |
| src/snapshot.lua | 16 | `M.new` |
| src/snapshot.lua | 27 | `vector` |
| src/snapshot.lua | 30 | `laneProbe` |
| src/snapshot.lua | 31 | `(anonymous)` |
| src/snapshot.lua | 34 | `readCar` |
| src/snapshot.lua | 112 | `simRead` |
| src/snapshot.lua | 130 | `raceRead` |
| src/snapshot.lua | 138 | `conflictingApp` |
| src/snapshot.lua | 145 | `tyres` |
| src/snapshot.lua | 169 | `M.read` |
| src/snapshot.lua | 188 | `(anonymous)` |
| src/snapshot.lua | 200 | `(anonymous)` |
| src/snapshot.lua | 236 | `M.zones` |
| src/snapshot.lua | 251 | `utf8Char` |
| src/snapshot.lua | 256 | `jsonName` |
| src/snapshot.lua | 276 | `carName` |
| src/snapshot.lua | 285 | `M.carDatabase` |
| src/snapshot.lua | 287 | `(anonymous)` |
| src/snapshot.lua | 291 | `(anonymous)` |
| src/snapshot.lua | 301 | `(anonymous)` |
| src/snapshot.lua | 304 | `menuVisible` |
| src/snapshot.lua | 305 | `M.menu` |
| src/traffic.lua | 5 | `M.new` |
| src/traffic.lua | 24 | `M.mode` |
| src/traffic.lua | 28 | `identity` |
| src/traffic.lua | 31 | `check` |
| src/traffic.lua | 44 | `plan` |
| src/traffic.lua | 64 | `(anonymous)` |
| src/traffic.lua | 121 | `M.exits` |
| src/traffic.lua | 174 | `M.update` |
| src/ui.lua | 20 | `wrap` |
| src/ui.lua | 22 | `number` |
| src/ui.lua | 26 | `shown` |
| src/ui.lua | 31 | `wrapAll` |
| src/ui.lua | 32 | `globalTips` |
| src/ui.lua | 50 | `ruleView` |
| src/ui.lua | 53 | `texts` |
| src/ui.lua | 69 | `same` |
| src/ui.lua | 69 | `(anonymous)` |
| src/ui.lua | 71 | `(anonymous)` |
| src/ui.lua | 77 | `M.new` |
| src/ui.lua | 101 | `text` |
| src/ui.lua | 104 | `mark` |
| src/ui.lua | 106 | `touch` |
| src/ui.lua | 109 | `presetTarget` |
| src/ui.lua | 116 | `loadBuiltin` |
| src/ui.lua | 129 | `builtinActive` |
| src/ui.lua | 144 | `carDatabase` |
| src/ui.lua | 161 | `input` |
| src/ui.lua | 168 | `heading` |
| src/ui.lua | 170 | `valueText` |
| src/ui.lua | 176 | `settingControl` |
| src/ui.lua | 205 | `ruleBlock` |
| src/ui.lua | 224 | `safetyBlock` |
| src/ui.lua | 259 | `patternBlock` |
| src/ui.lua | 302 | `globalBlock` |
| src/ui.lua | 338 | `statusLines` |
| src/ui.lua | 374 | `switches` |
| src/ui.lua | 382 | `overlayBlock` |
| src/ui.lua | 426 | `resetSection` |
| src/ui.lua | 439 | `sectionContent` |
| src/ui.lua | 445 | `flush` |
| src/ui.lua | 484 | `language` |
| src/ui.lua | 491 | `headerBar` |
| src/ui.lua | 521 | `profileButtons` |
| src/ui.lua | 532 | `homeTab` |
| src/ui.lua | 639 | `sectionPane` |
| src/ui.lua | 653 | `settingsTab` |
| src/ui.lua | 686 | `ruleRow` |
| src/ui.lua | 701 | `rulesTab` |
| src/ui.lua | 745 | `diagnosticTab` |
| src/ui.lua | 855 | `M.compactSize` |
| src/ui.lua | 856 | `M.main` |
| src/ui.lua | 889 | `faded` |
| src/ui.lua | 890 | `panelPalette` |
| src/ui.lua | 914 | `write` |
| src/ui.lua | 919 | `textWidth` |
| src/ui.lua | 924 | `fitSize` |
| src/ui.lua | 931 | `M.flagLayout` |
| src/ui.lua | 964 | `drsBadge` |
| src/ui.lua | 971 | `checker` |
| src/ui.lua | 975 | `diagonal` |
| src/ui.lua | 981 | `stripes` |
| src/ui.lua | 986 | `deltaText` |
| src/ui.lua | 996 | `deltaBox` |
| src/ui.lua | 1009 | `pillsWidth` |
| src/ui.lua | 1011 | `pillRow` |
| src/ui.lua | 1028 | `pill` |
| src/ui.lua | 1035 | `giveBackText` |
| src/ui.lua | 1039 | `blueText` |
| src/ui.lua | 1048 | `M.overlayParts` |
| src/ui.lua | 1067 | `M.overlayHeight` |
| src/ui.lua | 1076 | `strong` |
| src/ui.lua | 1082 | `sessionStrip` |
| src/ui.lua | 1105 | `M.flags` |
| src/ui.lua | 1200 | `nativeBox` |
| src/ui.lua | 1204 | `M.restoreNative` |
| src/ui.lua | 1205 | `screenSize` |
| src/ui.lua | 1208 | `hudContent` |
| src/ui.lua | 1243 | `M.hud` |
| src/ui.lua | 1258 | `(anonymous)` |
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
