# Settings and functions inventory Beta 1.42

This inventory links every declared parameter to its consumers. A static reference shows a connection, not proof of a physical result. The `PARAMETER_BOUNDARY_ENGINE` tests and the two full walks through the interface complete this trace.

| Section | Parameter | Range | Default J / P / Q / C | Consumers |
|---|---|---|---|---|
| general | `levelPct` — Level (%) | 40 to 110 | 95 / 100 / 100 / 100 | src/director.lua:134, src/groups.lua:8, src/lang_en.lua:146, src/mistakes.lua:33, src/tips_en.lua:48 |
| general | `aggressionPct` — Aggression (%) | 0 to 100 | 55 / 45 / 45 / 80 | src/director.lua:135, src/director.lua:1083, src/groups.lua:8, src/lang_en.lua:146, src/tips_en.lua:49 |
| general | `caution` — Caution | 0.5 to 8 | 1.6 / 2.2 / 2.2 / 1.2 | src/applier.lua:10, src/applier.lua:92, src/applier.lua:298, src/applier.lua:304, src/applier.lua:327, src/applier.lua:1029, src/applier.lua:1037, src/applier.lua:1115, src/applier.lua:1135, src/caps.lua:2, src/director.lua:136, src/director.lua:138, src/director.lua:141, src/director.lua:143, src/director.lua:144, src/director.lua:640, src/director.lua:641, src/director.lua:682, src/director.lua:721, src/director.lua:754, src/director.lua:864, src/director.lua:875, src/director.lua:1025, src/director.lua:1026, src/director.lua:1028, src/director.lua:1029, src/director.lua:1047, src/director.lua:1067, src/director.lua:1083, src/director.lua:1086, src/director.lua:1088, src/director.lua:1134, src/director.lua:1150, src/director.lua:1153, src/engine.lua:127, src/engine.lua:175, src/engine.lua:559, src/engine.lua:614, src/groups.lua:8, src/lang_en.lua:77, src/lang_en.lua:80, src/lang_en.lua:146, src/lang_en.lua:180, src/lang_en.lua:279, src/lang_en.lua:280, src/lang_en.lua:309, src/tips_en.lua:50, src/tips_en.lua:51, src/tips_en.lua:54, src/tips_en.lua:106, src/tips_en.lua:141, src/tips_en.lua:215, src/tips_en.lua:222, src/tips_en.lua:276, src/tips_en.lua:283, src/tips_en.lua:295 |
| general | `brakeZonePct` — Emulated braking zone (%) | 50 to 150 | 100 / 100 / 100 / 100 | src/director.lua:1088, src/groups.lua:8, src/lang_en.lua:146, src/tips_en.lua:51 |
| general | `paceSpreadPct` — Level spread (%) | 0 to 20 | 8 / 3 / 3 / 2 | src/groups.lua:9, src/lang_en.lua:146, src/persona.lua:13, src/tips_en.lua:52 |
| general | `aggrSpreadPct` — Aggression spread (%) | 0 to 30 | 12 / 8 / 8 / 10 | src/groups.lua:9, src/lang_en.lua:146, src/persona.lua:14, src/tips_en.lua:53 |
| general | `cautSpreadPct` — Caution spread (%) | 0 to 30 | 12 / 8 / 8 / 8 | src/groups.lua:9, src/lang_en.lua:146, src/persona.lua:15, src/tips_en.lua:54 |
| general | `pitExitSpread` — Staggered pit exits, practice and qualifying (s per AI, 0 = free) | 0 to 30 | 0 / 10 / 10 / 0 | src/groups.lua:10, src/lang_en.lua:146, src/lang_en.lua:276, src/lang_en.lua:298, src/tips_en.lua:55, src/traffic.lua:17, src/traffic.lua:52, src/traffic.lua:115 |
| general | `spawnMode` — AI distribution at session start | native, pits, track | track / pits / pits / native | src/flood.lua:107, src/groups.lua:10, src/lang_en.lua:146, src/tips_en.lua:56, src/traffic.lua:26 |
| general | `spawnMinCars` — Spread from (AI) | 2 to 60 | 10 / 10 / 10 / 10 | src/engine.lua:269, src/flood.lua:108, src/groups.lua:10, src/lang_en.lua:146, src/tips_en.lua:59, src/traffic.lua:10, src/traffic.lua:67 |
| general | `spawnPitPct` — AI left in the pits at the start (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/groups.lua:10, src/lang_en.lua:146, src/tips_en.lua:57, src/traffic.lua:72, src/traffic.lua:74 |
| general | `spawnGapVariation` — Start gap variation (%) | 0 to 100 | 100 / 100 / 100 / 100 | src/groups.lua:10, src/lang_en.lua:146, src/tips_en.lua:58, src/traffic.lua:80, src/traffic.lua:83 |
| general | `floodRangeKm` — CSP AI flood range, below the threshold (km) | 1 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:254, src/engine.lua:269, src/engine.lua:270, src/groups.lua:10, src/lang_en.lua:146, src/tips_en.lua:60 |
| yield | `yieldEnabled` — Standard yielding | boolean | true / true / true / false | src/director.lua:362, src/director.lua:765, src/groups.lua:18, src/lang_en.lua:147, src/tips_en.lua:62 |
| yield | `yieldSide` — Yield side | left, right, auto | right / right / right / right | src/director.lua:115, src/director.lua:116, src/director.lua:123, src/director.lua:126, src/director.lua:405, src/director.lua:543, src/director.lua:723, src/groups.lua:18, src/lang_en.lua:147, src/lang_en.lua:277, src/persona.lua:23, src/tips_en.lua:63 |
| yield | `yieldOffset` — Yield offset | 0.2 to 0.95 | 0.65 / 0.8 / 0.8 / 0.6 | src/director.lua:748, src/groups.lua:18, src/lang_en.lua:147, src/tips_en.lua:64 |
| yield | `yieldDetectBehind` — Rear detection (m) | 30 to 400 | 100 / 200 / 200 / 80 | src/director.lua:369, src/groups.lua:18, src/lang_en.lua:147, src/tips_en.lua:65 |
| yield | `yieldBehindMargin` — Follower speed advantage (km/h) | 1 to 30 | 6 / 4 / 4 / 6 | src/director.lua:322, src/director.lua:366, src/director.lua:765, src/groups.lua:18, src/lang_en.lua:147, src/tips_en.lua:66 |
| yield | `yieldHorizon` — Rear horizon (s) | 3 to 30 | 10 / 12 / 12 / 8 | src/director.lua:367, src/groups.lua:18, src/lang_en.lua:147, src/tips_en.lua:67 |
| yield | `confirmTime` — Confirmation (s) | 0.1 to 2 | 0.6 / 0.4 / 0.4 / 0.5 | src/director.lua:386, src/director.lua:992, src/groups.lua:18, src/lang_en.lua:147, src/tips_en.lua:68 |
| yield | `yieldHoldMin` — Minimum hold (s) | 0.3 to 5 | 1 / 1 / 1 / 1 | src/director.lua:413, src/director.lua:766, src/director.lua:789, src/flash.lua:78, src/groups.lua:19, src/lang_en.lua:148, src/tips_en.lua:69 |
| yield | `yieldHoldAfterMin` — Hold after the pass, min. (s) | 0.2 to 6 | 0.8 / 0.6 / 0.6 / 0.8 | src/groups.lua:19, src/lang_en.lua:148, src/persona.lua:27, src/persona.lua:38, src/tips_en.lua:70 |
| yield | `yieldHoldAfterMax` — Hold after the pass, max. (s) | 0.2 to 6 | 2.2 / 1.6 / 1.6 / 1.8 | src/groups.lua:19, src/lang_en.lua:148, src/persona.lua:27, src/persona.lua:38, src/tips_en.lua:71 |
| yield | `yieldSlowdownPct` — Slowdown while yielding (%) | 0 to 20 | 6 / 8 / 8 / 6 | src/director.lua:753, src/director.lua:1091, src/groups.lua:20, src/lang_en.lua:148, src/tips_en.lua:72 |
| yield | `inviteSlowdownPct` — Extra slowdown to invite a pass (%) | 0 to 25 | 10 / 10 / 10 / 10 | src/director.lua:758, src/groups.lua:20, src/lang_en.lua:148, src/tips_en.lua:73 |
| yield | `yieldMaxHold` — Maximum yield duration (s) | 8 to 60 | 25 / 25 / 25 / 25 | src/director.lua:799, src/flash.lua:45, src/groups.lua:19, src/lang_en.lua:148, src/tips_en.lua:74 |
| yield | `pressureEnabled` — Reaction to pressure | boolean | true / true / true / false | src/director.lua:373, src/director.lua:382, src/groups.lua:21, src/lang_en.lua:149, src/tips_en.lua:75 |
| yield | `pressureGap` — Pressure distance (m) | 5 to 30 | 15 / 15 / 15 / 15 | src/director.lua:373, src/director.lua:376, src/groups.lua:21, src/lang_en.lua:149, src/tips_en.lua:76 |
| yield | `pressureTime` — Pressure duration (s) | 1 to 15 | 4 / 3 / 3 / 4 | src/director.lua:382, src/groups.lua:21, src/lang_en.lua:149, src/tips_en.lua:77 |
| blue | `blueFlagEnabled` — Blue flags | boolean | false / true / true / true | src/director.lua:312, src/director.lua:1184, src/engine.lua:45, src/groups.lua:22, src/lang_en.lua:150, src/panel.lua:20, src/tips_en.lua:79 |
| blue | `blueFlagRange` — Blue flag range (m) | 50 to 400 | 150 / 200 / 200 / 150 | src/director.lua:344, src/director.lua:1184, src/director.lua:1192, src/engine.lua:45, src/groups.lua:22, src/lang_en.lua:150, src/panel.lua:29, src/tips_en.lua:80 |
| blue | `blueFlagSide` — Side under blue flag | auto, left, right | auto / auto / auto / auto | src/director.lua:116, src/groups.lua:22, src/lang_en.lua:150, src/lang_en.lua:277, src/tips_en.lua:81 |
| flash | `flashMode` — Headlight flashes | never, lapped, always | always / always / always / lapped | src/director.lua:353, src/flash.lua:50, src/flash.lua:59, src/groups.lua:23, src/lang_en.lua:151, src/lang_en.lua:277, src/tips_en.lua:83 |
| flash | `flashRange` — Flash range (m) | 40 to 250 | 200 / 200 / 200 / 150 | src/director.lua:331, src/director.lua:337, src/director.lua:370, src/director.lua:623, src/director.lua:627, src/engine.lua:774, src/engine.lua:775, src/flash.lua:58, src/groups.lua:23, src/lang_en.lua:151, src/tips_en.lua:84 |
| flash | `flashMinAdvantage` — Speed advantage for a flash (km/h) | 3 to 40 | 12 / 8 / 8 / 15 | src/director.lua:1098, src/flash.lua:45, src/groups.lua:23, src/lang_en.lua:151, src/tips_en.lua:85 |
| flash | `flashCloseAdvantage` — Close-range advantage (km/h) | -10 to 15 | -5 / -5 / -5 / 6 | src/flash.lua:44, src/groups.lua:23, src/lang_en.lua:151, src/tips_en.lua:86 |
| flash | `flashRequestTTL` — Request lifetime (s) | 3 to 20 | 8 / 8 / 8 / 8 | src/director.lua:1107, src/flash.lua:73, src/flash.lua:74, src/groups.lua:23, src/lang_en.lua:151, src/tips_en.lua:87 |
| flash | `flashObliviousPct` — First flash missed (%) | 0 to 40 | 10 / 5 / 5 / 10 | src/flash.lua:70, src/groups.lua:24, src/lang_en.lua:151, src/tips_en.lua:88 |
| flash | `flashMaxReactors` — Cars reacting | 1 to 3 | 3 / 3 / 3 / 3 | src/flash.lua:67, src/groups.lua:24, src/lang_en.lua:151, src/tips_en.lua:89 |
| flash | `hornEnabled` — Horn counts as a flash | boolean | false / false / false / false | src/engine.lua:768, src/engine.lua:769, src/groups.lua:24, src/lang_en.lua:151, src/tips_en.lua:90 |
| flash | `aiFlashEnabled` — AI-to-AI headlight flashes | boolean | true / true / true / true | src/director.lua:1094, src/groups.lua:24, src/lang_en.lua:151, src/tips_en.lua:91 |
| overtake | `overtakeEnabled` — Overtaking | boolean | true / true / true / true | src/director.lua:919, src/director.lua:930, src/groups.lua:25, src/lang_en.lua:152, src/tips_en.lua:93 |
| overtake | `overtakeSide` — Overtaking side | opposite, auto, left, right | left / left / left / left | src/director.lua:123, src/director.lua:124, src/director.lua:543, src/director.lua:990, src/groups.lua:25, src/lang_en.lua:152, src/tips_en.lua:94 |
| overtake | `overtakeOffset` — Overtaking offset | 0.2 to 0.95 | 0.7 / 0.65 / 0.65 / 0.6 | src/director.lua:803, src/groups.lua:26, src/lang_en.lua:152, src/tips_en.lua:95 |
| overtake | `overtakeDetectAhead` — Forward detection (m) | 20 to 200 | 60 / 50 / 50 / 50 | src/director.lua:859, src/director.lua:944, src/director.lua:950, src/groups.lua:25, src/lang_en.lua:152, src/tips_en.lua:96 |
| overtake | `overtakeAheadMargin` — Speed advantage to overtake (km/h) | 1 to 30 | 8 / 10 / 10 / 3 | src/director.lua:937, src/groups.lua:25, src/lang_en.lua:152, src/tips_en.lua:97 |
| overtake | `overtakeHorizon` — Forward horizon (s) | 2 to 20 | 6 / 6 / 6 / 6 | src/director.lua:944, src/groups.lua:25, src/lang_en.lua:152, src/tips_en.lua:98 |
| overtake | `overtakeClearMargin` — Clearance after overtaking (m) | 8 to 40 | 18 / 20 / 20 / 10 | src/director.lua:857, src/director.lua:989, src/groups.lua:26, src/lang_en.lua:152, src/tips_en.lua:99 |
| overtake | `overtakeRestTime` — Pause after overtaking (s) | 0 to 10 | 2 / 3 / 3 / 1 | src/director.lua:863, src/groups.lua:26, src/lang_en.lua:152, src/tips_en.lua:100 |
| overtake | `overtakeChain` — Chain overtakes | boolean | true / false / false / true | src/director.lua:859, src/groups.lua:26, src/lang_en.lua:153, src/tips_en.lua:101 |
| overtake | `stuckTime` — Held-up confirmation (s) | 0.5 to 10 | 2 / 3 / 3 / 1.2 | src/director.lua:946, src/director.lua:1098, src/groups.lua:25, src/lang_en.lua:153, src/tips_en.lua:102 |
| overtake | `stuckPaceRatio` — Held-up pace threshold | 0.8 to 0.99 | 0.93 / 0.93 / 0.93 / 0.95 | src/director.lua:309, src/groups.lua:25, src/lang_en.lua:153, src/tips_en.lua:103 |
| overtake | `pullOutGapBase` — Pull-out distance (m) | 4 to 15 | 8 / 8 / 8 / 8 | src/director.lua:854, src/groups.lua:26, src/lang_en.lua:153, src/tips_en.lua:104 |
| overtake | `pullOutGapPerMps` — Pull-out gain (s) | 0 to 0.5 | 0.25 / 0.25 / 0.25 / 0.25 | src/director.lua:854, src/groups.lua:26, src/lang_en.lua:153, src/tips_en.lua:105 |
| overtake | `slipstreamEnabled` — Slipstream | boolean | true / true / true / true | src/director.lua:1022, src/director.lua:1028, src/groups.lua:26, src/lang_en.lua:153, src/tips_en.lua:106 |
| overtake | `defenseEnabled` — Defending | boolean | true / true / true / true | src/director.lua:891, src/groups.lua:27, src/lang_en.lua:153, src/tips_en.lua:107 |
| overtake | `defenseMaxOffset` — Maximum defending offset | 0.1 to 0.5 | 0.35 / 0.35 / 0.35 / 0.35 | src/director.lua:875, src/groups.lua:27, src/lang_en.lua:153, src/tips_en.lua:108 |
| overtake | `defenseCooldown` — Pause between defences (s) | 2 to 30 | 8 / 8 / 8 / 8 | src/director.lua:898, src/groups.lua:27, src/lang_en.lua:153, src/tips_en.lua:109 |
| overtake | `defenseTriggerGap` — Defending distance (m) | 5 to 25 | 12 / 12 / 12 / 12 | src/director.lua:891, src/groups.lua:27, src/lang_en.lua:153, src/tips_en.lua:110 |
| overtake | `towBreakEnabled` — Break the tow on straights | boolean | false / false / false / true | src/director.lua:518, src/director.lua:582, src/groups.lua:28, src/lang_en.lua:145, src/tips_en.lua:6 |
| overtake | `towBreakRange` — Tow to break: distance (m) | 10 to 60 | 30 / 30 / 30 / 30 | src/director.lua:512, src/director.lua:520, src/groups.lua:28, src/lang_en.lua:145, src/tips_en.lua:7 |
| overtake | `towBreakStraight` — Minimum straight (m) | 200 to 1500 | 400 / 400 / 400 / 400 | src/director.lua:511, src/director.lua:536, src/groups.lua:28, src/lang_en.lua:145, src/tips_en.lua:8 |
| overtake | `dirtyAirEnabled` — Dirty air behind a car | boolean | false / true / true / true | src/director.lua:491, src/groups.lua:28, src/lang_en.lua:145, src/tips_en.lua:9 |
| overtake | `dirtyAirGap` — Dirty air: distance (m) | 5 to 40 | 20 / 20 / 20 / 20 | src/director.lua:488, src/director.lua:492, src/director.lua:494, src/groups.lua:28, src/lang_en.lua:145, src/tips_en.lua:10 |
| overtake | `dirtyAirLiftPct` — Dirty air: throttle lift in corners (%) | 0 to 10 | 3 / 3 / 3 / 3 | src/director.lua:1136, src/director.lua:1138, src/groups.lua:28, src/lang_en.lua:145, src/lang_en.lua:276, src/tips_en.lua:11 |
| overtake | `finalLapsEnabled` — Last-laps urgency | boolean | false / false / false / true | src/director.lua:499, src/groups.lua:29, src/lang_en.lua:145, src/tips_en.lua:12 |
| overtake | `finalLaps` — Last laps concerned | 1 to 10 | 3 / 3 / 3 / 3 | src/director.lua:496, src/director.lua:504, src/director.lua:507, src/director.lua:655, src/groups.lua:29, src/lang_en.lua:145, src/tips_en.lua:13 |
| overtake | `finalAggressionPct` — Extra aggression (%) | 0 to 50 | 15 / 15 / 15 / 15 | src/director.lua:652, src/director.lua:655, src/groups.lua:29, src/lang_en.lua:145, src/lang_en.lua:276, src/tips_en.lua:14 |
| overtake | `finalDefensePct` — Stronger defence (%) | 0 to 100 | 40 / 40 / 40 / 40 | src/director.lua:655, src/director.lua:890, src/groups.lua:29, src/lang_en.lua:145, src/lang_en.lua:276, src/tips_en.lua:15 |
| lateral | `rampSpeed` — Lateral movement speed | 0.1 to 1 | 0.3 / 0.3 / 0.3 / 0.45 | src/director.lua:260, src/groups.lua:15, src/lang_en.lua:154, src/tips_en.lua:112 |
| lateral | `rampAccel` — Lateral acceleration | 0.5 to 4 | 1.5 / 1.5 / 1.5 / 2 | src/director.lua:262, src/groups.lua:15, src/lang_en.lua:154, src/tips_en.lua:113 |
| lateral | `lowPassTau` — Lateral smoothing (s) | 0.05 to 1 | 0.25 / 0.25 / 0.25 / 0.2 | src/director.lua:263, src/groups.lua:15, src/lang_en.lua:154, src/tips_en.lua:114 |
| lateral | `maxSideOffset` — Maximum offset | 0.3 to 0.95 | 0.85 / 0.85 / 0.85 / 0.8 | src/director.lua:194, src/director.lua:729, src/director.lua:748, src/director.lua:868, src/director.lua:875, src/groups.lua:16, src/lang_en.lua:154, src/tips_en.lua:115 |
| lateral | `cornerMin` — Straight threshold | 0 to 1 | 0.35 / 0.35 / 0.35 / 0.5 | src/director.lua:328, src/director.lua:403, src/director.lua:425, src/director.lua:492, src/director.lua:778, src/director.lua:872, src/director.lua:920, src/director.lua:929, src/director.lua:1011, src/director.lua:1095, src/director.lua:1118, src/director.lua:1133, src/director.lua:1164, src/groups.lua:16, src/lang_en.lua:154, src/tips_en.lua:116, src/traffic.lua:199 |
| lateral | `cornerYawRef` — Yaw rate reference (rad/s) | 0.2 to 1.2 | 0.5 / 0.5 / 0.5 / 0.5 | src/director.lua:578, src/groups.lua:16, src/lang_en.lua:154, src/tips_en.lua:117 |
| lateral | `lateralCooldown` — Pause between direction changes (s) | 0.3 to 5 | 1.2 / 1.2 / 1.2 / 1 | src/director.lua:159, src/director.lua:172, src/director.lua:483, src/groups.lua:16, src/lang_en.lua:154, src/tips_en.lua:118 |
| lateral | `emergencyReleaseFactor` — Release factor | 1 to 4 | 2 / 2 / 2 / 2 | src/director.lua:249, src/groups.lua:16, src/lang_en.lua:154, src/tips_en.lua:119 |
| human | `reactMin` — Minimum reaction (s) | 0.1 to 2 | 0.25 / 0.2 / 0.2 / 0.2 | src/groups.lua:11, src/lang_en.lua:155, src/persona.lua:10, src/tips_en.lua:121 |
| human | `reactMax` — Maximum reaction (s) | 0.1 to 2 | 0.9 / 0.6 / 0.6 / 0.6 | src/groups.lua:11, src/lang_en.lua:155, src/persona.lua:10, src/tips_en.lua:122 |
| human | `awMin` — Minimum awareness delay (s) | 0.2 to 5 | 0.6 / 0.4 / 0.4 / 0.4 | src/groups.lua:11, src/lang_en.lua:155, src/persona.lua:10, src/tips_en.lua:123 |
| human | `awMax` — Maximum awareness delay (s) | 0.2 to 5 | 2 / 1.2 / 1.2 / 1.2 | src/groups.lua:11, src/lang_en.lua:155, src/persona.lua:10, src/tips_en.lua:124 |
| human | `paceDriftPct` — Slow pace drift (%) | 0 to 6 | 2 / 1 / 1 / 1 | src/director.lua:133, src/groups.lua:12, src/lang_en.lua:155, src/tips_en.lua:125 |
| human | `personalLineJitter` — Line variation | 0 to 0.15 | 0.05 / 0.03 / 0.03 / 0.02 | src/director.lua:880, src/director.lua:885, src/groups.lua:12, src/lang_en.lua:155, src/tips_en.lua:126 |
| human | `lapseEnabled` — Brief lapses in focus | boolean | true / false / false / false | src/director.lua:1072, src/groups.lua:13, src/lang_en.lua:155, src/tips_en.lua:127 |
| human | `lapseIntervalMin` — Minimum interval (s) | 20 to 900 | 60 / 120 / 120 / 120 | src/groups.lua:13, src/lang_en.lua:156, src/persona.lua:24, src/persona.lua:45, src/tips_en.lua:128 |
| human | `lapseIntervalMax` — Maximum interval (s) | 20 to 900 | 300 / 600 / 600 / 600 | src/groups.lua:13, src/lang_en.lua:156, src/persona.lua:24, src/persona.lua:45, src/tips_en.lua:129 |
| human | `lapseDurMin` — Minimum duration (s) | 0.5 to 8 | 1.5 / 1 / 1 / 1 | src/groups.lua:13, src/lang_en.lua:156, src/persona.lua:25, src/persona.lua:46, src/tips_en.lua:130 |
| human | `lapseDurMax` — Maximum duration (s) | 0.5 to 8 | 3 / 2 / 2 / 2 | src/groups.lua:13, src/lang_en.lua:156, src/persona.lua:25, src/persona.lua:46, src/tips_en.lua:131 |
| human | `lapseDropMin` — Minimum pace loss (%) | 0 to 25 | 6 / 3 / 3 / 3 | src/groups.lua:13, src/lang_en.lua:156, src/persona.lua:26, src/persona.lua:47, src/tips_en.lua:132 |
| human | `lapseDropMax` — Maximum pace loss (%) | 0 to 25 | 12 / 7 / 7 / 7 | src/groups.lua:13, src/lang_en.lua:156, src/persona.lua:26, src/persona.lua:47, src/tips_en.lua:133 |
| human | `laneBiasEnabled` — Pace-based line | boolean | true / false / false / false | src/groups.lua:12, src/lang_en.lua:156, src/persona.lua:23, src/tips_en.lua:134 |
| human | `laneBiasMax` — Maximum line bias | 0 to 0.4 | 0.25 / 0.25 / 0.25 / 0.25 | src/groups.lua:12, src/lang_en.lua:156, src/persona.lua:23, src/tips_en.lua:135 |
| human | `mistakesEnabled` — AI driving mistakes (lock-ups, wheelspin) | boolean | true / true / true / true | src/groups.lua:14, src/lang_en.lua:157, src/lang_en.lua:298, src/mistakes.lua:54, src/tips_en.lua:136 |
| human | `mistakeRate` — Mistakes: rate (per hour per AI) | 0 to 6 | 1 / 0.5 / 0.5 / 0.5 | src/groups.lua:14, src/lang_en.lua:157, src/lang_en.lua:299, src/mistakes.lua:54, src/mistakes.lua:88, src/tips_en.lua:137 |
| start | `startDelay` — Start delay (s) | 0 to 30 | 0 / 0 / 0 / 1 | src/applier.lua:11, src/applier.lua:268, src/applier.lua:424, src/applier.lua:425, src/applier.lua:428, src/applier.lua:444, src/applier.lua:705, src/applier.lua:1009, src/applier.lua:1014, src/caps.lua:2, src/director.lua:645, src/director.lua:667, src/director.lua:685, src/director.lua:1015, src/director.lua:1064, src/director.lua:1065, src/engine.lua:127, src/engine.lua:449, src/engine.lua:453, src/engine.lua:457, src/engine.lua:470, src/groups.lua:17, src/lang_en.lua:158, src/lang_en.lua:279, src/mistakes.lua:57, src/tips_en.lua:139, src/traffic.lua:17, src/traffic.lua:145, src/traffic.lua:163, src/traffic.lua:167 |
| start | `startCautionMult` — Caution at the start | 1 to 3 | 1 / 1 / 1 / 1.3 | src/director.lua:1067, src/engine.lua:45, src/groups.lua:17, src/lang_en.lua:158, src/tips_en.lua:141 |
| start | `startAggrMult` — Aggression at the start | 0.2 to 1 | 1 / 1 / 1 / 0.8 | src/director.lua:1067, src/engine.lua:45, src/groups.lua:17, src/lang_en.lua:158, src/tips_en.lua:142 |
| start | `startRelax` — Settling time after the start (s) | 2 to 30 | 12 / 12 / 12 / 25 | src/director.lua:645, src/director.lua:1015, src/director.lua:1064, src/director.lua:1065, src/engine.lua:457, src/groups.lua:17, src/lang_en.lua:158, src/mistakes.lua:57, src/tips_en.lua:143 |
| start | `startLaneHold` — Hold the grid lane at the start | boolean | false / false / false / false | src/director.lua:1069, src/engine.lua:45, src/engine.lua:457, src/groups.lua:17, src/lang_en.lua:158, src/tips_en.lua:140 |
| accidents | `obstacleEnabled` — Avoid stopped or crashed cars | boolean | true / true / true / true | src/director.lua:685, src/groups.lua:31, src/lang_en.lua:159, src/tips_en.lua:145 |
| accidents | `obstacleSpeedKmh` — Obstacle speed (km/h) | 5 to 50 | 25 / 25 / 25 / 25 | src/director.lua:689, src/director.lua:694, src/director.lua:733, src/engine.lua:523, src/groups.lua:31, src/incidents.lua:154, src/incidents.lua:196, src/incidents.lua:206, src/incidents.lua:239, src/lang_en.lua:159, src/lights.lua:57, src/penalties.lua:39, src/tips_en.lua:146 |
| accidents | `obstacleDetect` — Obstacle detection (m) | 50 to 300 | 150 / 150 / 150 / 150 | src/director.lua:689, src/director.lua:710, src/groups.lua:31, src/lang_en.lua:159, src/tips_en.lua:147 |
| accidents | `obstacleLevelDrop` — Level drop near an obstacle (%) | 0 to 50 | 25 / 25 / 25 / 25 | src/director.lua:721, src/groups.lua:31, src/lang_en.lua:159, src/tips_en.lua:148 |
| accidents | `obstacleCautionMult` — Caution near an obstacle | 1 to 3 | 1.5 / 1.5 / 1.5 / 1.5 | src/director.lua:721, src/groups.lua:31, src/lang_en.lua:159, src/tips_en.lua:149 |
| accidents | `avoidOffset` — Avoidance offset | 0.3 to 0.9 | 0.6 / 0.6 / 0.6 / 0.6 | src/director.lua:729, src/groups.lua:32, src/lang_en.lua:159, src/tips_en.lua:150 |
| accidents | `contactRecovery` — Recovery after contact | boolean | true / true / true / true | src/director.lua:673, src/groups.lua:32, src/lang_en.lua:160, src/tips_en.lua:151 |
| accidents | `incidentStop` — Crashed AI stop | boolean | true / true / true / true | src/groups.lua:32, src/incidents.lua:237, src/lang_en.lua:160, src/tips_en.lua:152 |
| accidents | `incidentStopMin` — Minimum stop (s) | 1 to 15 | 3 / 3 / 3 / 3 | src/groups.lua:32, src/incidents.lua:241, src/lang_en.lua:160, src/tips_en.lua:153 |
| accidents | `incidentStopMax` — Maximum stop (s) | 1 to 30 | 8 / 8 / 8 / 8 | src/groups.lua:32, src/incidents.lua:241, src/lang_en.lua:160, src/tips_en.lua:154 |
| accidents | `rejoinGap` — Clear track behind to rejoin (m) | 30 to 300 | 120 / 120 / 120 / 120 | src/groups.lua:32, src/incidents.lua:142, src/lang_en.lua:160, src/tips_en.lua:155 |
| accidents | `yellowEnabled` — Yellow flags (incident zone) | boolean | true / true / true / true | src/groups.lua:33, src/incidents.lua:441, src/incidents.lua:499, src/lang_en.lua:161, src/lights.lua:49, src/tips_en.lua:156 |
| accidents | `yellowBefore` — Zone start before the incident (m) | 50 to 800 | 300 / 300 / 300 / 300 | src/groups.lua:33, src/incidents.lua:431, src/incidents.lua:446, src/incidents.lua:449, src/incidents.lua:504, src/incidents.lua:505, src/incidents.lua:513, src/incidents.lua:514, src/lang_en.lua:161, src/tips_en.lua:160 |
| accidents | `yellowAfter` — Zone end after the incident (m) | 0 to 300 | 50 / 50 / 50 / 50 | src/groups.lua:33, src/incidents.lua:446, src/incidents.lua:504, src/lang_en.lua:161, src/tips_en.lua:161 |
| accidents | `yellowHold` — Hold after clearing (s) | 0 to 60 | 10 / 10 / 10 / 10 | src/groups.lua:33, src/incidents.lua:228, src/lang_en.lua:161, src/penalties.lua:39, src/tips_en.lua:162 |
| accidents | `yellowDecel` — Approach deceleration (m/s²) | 2 to 10 | 5 / 5 / 5 / 5 | src/delta.lua:158, src/delta.lua:190, src/director.lua:612, src/engine.lua:917, src/groups.lua:33, src/incidents.lua:457, src/incidents.lua:496, src/lang_en.lua:161, src/sanctions.lua:491, src/tips_en.lua:163 |
| accidents | `zoneDeltaPct` — Double yellow: reference time slower by (%) | 5 to 200 | 15 / 15 / 15 / 15 | src/delta.lua:89, src/groups.lua:34, src/lang_en.lua:162, src/lang_en.lua:299, src/tips_en.lua:158 |
| accidents | `slowZoneKmh` — Double yellow: Slow Zone speed (km/h, 0 = delta time) | 0 to 150 | 0 / 0 / 0 / 0 | src/delta.lua:88, src/groups.lua:34, src/lang_en.lua:162, src/lang_en.lua:276, src/lang_en.lua:299, src/tips_en.lua:159 |
| accidents | `yellowSpeedKmh` — Double yellow: fallback speed, unknown pace (km/h) | 30 to 200 | 50 / 50 / 50 / 50 | src/delta.lua:89, src/groups.lua:34, src/incidents.lua:495, src/lang_en.lua:162, src/lang_en.lua:300, src/tips_en.lua:157 |
| accidents | `yellowHud` — AC native yellow flag on the HUD | boolean | false / false / false / false | src/groups.lua:35, src/incidents.lua:525, src/lang_en.lua:163, src/tips_en.lua:175 |
| accidents | `flagPanel` — ACAdvancedIA flag panel while driving | boolean | true / true / true / true | src/groups.lua:35, src/lang_en.lua:163, src/lang_en.lua:300, src/panel.lua:148, src/tips_en.lua:176 |
| accidents | `yellowMessage` — On-screen incident messages | boolean | true / true / true / true | src/engine.lua:739, src/engine.lua:744, src/engine.lua:759, src/groups.lua:35, src/incidents.lua:76, src/incidents.lua:94, src/incidents.lua:98, src/incidents.lua:280, src/incidents.lua:295, src/incidents.lua:303, src/incidents.lua:311, src/incidents.lua:329, src/incidents.lua:339, src/incidents.lua:376, src/incidents.lua:394, src/incidents.lua:400, src/incidents.lua:411, src/incidents.lua:514, src/lang_en.lua:163, src/tips_en.lua:177 |
| accidents | `deltaBeeps` — Delta: beeps | boolean | true / true / true / true | src/engine.lua:635, src/groups.lua:35, src/lang_en.lua:163, src/tips_en.lua:173 |
| accidents | `playerPenalties` — Player penalties under flags | boolean | false / true / true / true | src/engine.lua:879, src/groups.lua:36, src/lang_en.lua:164, src/penalties.lua:77, src/penalties.lua:78, src/tips_en.lua:171 |
| accidents | `deltaTolerance` — Delta: mini-sector tolerance (s) | 0 to 1 | 0.5 / 0.5 / 0.5 / 0.5 | src/delta.lua:137, src/groups.lua:36, src/lang_en.lua:164, src/tips_en.lua:172 |
| accidents | `penaltySeconds` — Penalty: throttle cut (s) | 2 to 15 | 5 / 5 / 5 / 5 | src/engine.lua:761, src/groups.lua:36, src/lang_en.lua:164, src/penalties.lua:80, src/penalties.lua:81, src/penalties.lua:83, src/penalties.lua:87, src/penalties.lua:118, src/penalties.lua:128, src/penalties.lua:145, src/tips_en.lua:174 |
| accidents | `penaltyDisqualify` — Offences allowed before disqualification | 1 to 20 | 5 / 5 / 5 / 5 | src/engine.lua:728, src/engine.lua:743, src/engine.lua:747, src/engine.lua:761, src/groups.lua:36, src/lang_en.lua:164, src/penalties.lua:53, src/penalties.lua:144, src/sanctions.lua:126, src/sanctions.lua:129, src/sanctions.lua:134, src/tips_en.lua:169 |
| accidents | `aiPenalties` — AI sanctions under flags | boolean | false / true / true / true | src/groups.lua:36, src/lang_en.lua:164, src/penalties.lua:155, src/tips_en.lua:170 |
| rules | `noMoveBraking` — No change of direction under braking | boolean | true / true / true / true | src/director.lua:665, src/groups.lua:56, src/lang_en.lua:165, src/tips_en.lua:179 |
| rules | `neutralization` — Neutralisation after a major incident | local, fcy, vsc, sc | local / local / local / local | src/engine.lua:63, src/groups.lua:56, src/incidents.lua:265, src/incidents.lua:404, src/lang_en.lua:165, src/tips_en.lua:180 |
| rules | `majorIncidentTime` — Major incident: car stopped on track (s) | 5 to 60 | 15 / 15 / 15 / 15 | src/engine.lua:62, src/engine.lua:63, src/groups.lua:56, src/incidents.lua:225, src/incidents.lua:275, src/lang_en.lua:165, src/tips_en.lua:181 |
| rules | `fcySpeedKmh` — FCY: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:97, src/delta.lua:100, src/delta.lua:102, src/groups.lua:57, src/incidents.lua:408, src/incidents.lua:472, src/lang_en.lua:165, src/lang_en.lua:301, src/tips_en.lua:182 |
| rules | `fcyDeltaPct` — FCY: reference time slower by (%) | 10 to 150 | 50 / 50 / 50 / 50 | src/delta.lua:100, src/delta.lua:102, src/groups.lua:57, src/incidents.lua:295, src/incidents.lua:472, src/lang_en.lua:165, src/lang_en.lua:301, src/panel.lua:175, src/tips_en.lua:183 |
| rules | `vscDeltaPct` — VSC: reference time slower by (%) | 10 to 80 | 30 / 30 / 30 / 30 | src/delta.lua:97, src/groups.lua:57, src/incidents.lua:295, src/incidents.lua:472, src/lang_en.lua:165, src/lang_en.lua:302, src/panel.lua:174, src/tips_en.lua:184 |
| rules | `neutralizationHold` — Minimum neutralisation time (s) | 10 to 180 | 30 / 30 / 30 / 30 | src/groups.lua:56, src/incidents.lua:277, src/incidents.lua:305, src/incidents.lua:408, src/lang_en.lua:166, src/tips_en.lua:185 |
| rules | `safetyCarSpeedKmh` — Safety Car speed (km/h) | 60 to 250 | 120 / 120 / 120 / 120 | src/delta.lua:157, src/groups.lua:66, src/incidents.lua:362, src/incidents.lua:425, src/incidents.lua:470, src/incidents.lua:473, src/lang_en.lua:166, src/tips_en.lua:186 |
| rules | `safetyCarEscalation` — Safety Car if the incident escalates | boolean | false / true / true / true | src/engine.lua:56, src/groups.lua:66, src/incidents.lua:273, src/incidents.lua:274, src/lang_en.lua:166, src/tips_en.lua:188 |
| rules | `restartOvertake` — Overtaking allowed after the restart | line, scIn | line / line / line / line | src/groups.lua:66, src/incidents.lua:98, src/incidents.lua:319, src/lang_en.lua:167, src/panel.lua:169, src/tips_en.lua:187 |
| rules | `redFlagEnabled` — Red flag on a serious accident (practice, qualifying, race) | boolean | true / true / true / true | src/engine.lua:57, src/groups.lua:58, src/incidents.lua:370, src/lang_en.lua:167, src/lang_en.lua:302, src/tips_en.lua:189 |
| rules | `redFlagCars` — Red flag: cars stopped on track | 2 to 10 | 3 / 3 / 3 / 3 | src/groups.lua:58, src/incidents.lua:371, src/lang_en.lua:167, src/lang_en.lua:302, src/tips_en.lua:190 |
| rules | `redFlagSpeedKmh` — Red flag: fallback speed, unknown pace (km/h) | 40 to 150 | 80 / 80 / 80 / 80 | src/delta.lua:94, src/groups.lua:58, src/incidents.lua:373, src/incidents.lua:477, src/lang_en.lua:167, src/lang_en.lua:303, src/tips_en.lua:191 |
| rules | `redDeltaPct` — Red flag: reference time slower by (%) | 10 to 200 | 60 / 60 / 60 / 60 | src/delta.lua:94, src/groups.lua:58, src/incidents.lua:477, src/lang_en.lua:167, src/lang_en.lua:303, src/tips_en.lua:192 |
| rules | `redFlagHold` — Red flag: minimum suspension (s) | 20 to 600 | 60 / 60 / 60 / 60 | src/groups.lua:58, src/incidents.lua:373, src/incidents.lua:389, src/lang_en.lua:167, src/lang_en.lua:303, src/tips_en.lua:193 |
| rules | `redFlagWork` — Red flag: tyres changed in the pits (stop counts) | boolean | false / false / false / false | src/groups.lua:58, src/lang_en.lua:167, src/lang_en.lua:304, src/pits.lua:106, src/pits.lua:138, src/pits.lua:143, src/strategy.lua:414, src/tips_en.lua:195 |
| rules | `redRestart` — Restart after a red flag | rolling, standing | rolling / rolling / rolling / rolling | src/groups.lua:55, src/groups.lua:58, src/incidents.lua:90, src/incidents.lua:287, src/lang_en.lua:167, src/panel.lua:168, src/tips_en.lua:194 |
| rules | `mandatoryStops` — Mandatory stops in the race | 0 to 3 | 0 / 0 / 0 / 0 | src/engine.lua:808, src/engine.lua:811, src/groups.lua:63, src/hudinfo.lua:110, src/hudinfo.lua:111, src/hudinfo.lua:112, src/lang_en.lua:168, src/pits.lua:52, src/pits.lua:62, src/pits.lua:67, src/pits.lua:118, src/pits.lua:120, src/pits.lua:134, src/pits.lua:181, src/pits.lua:182, src/strategy.lua:374, src/tips_en.lua:196 |
| rules | `pitWindowOpenPct` — Window opens (% of race) | 5 to 95 | 25 / 25 / 25 / 25 | src/groups.lua:63, src/lang_en.lua:168, src/pits.lua:58, src/tips_en.lua:197 |
| rules | `pitWindowClosePct` — Window closes (% of race) | 5 to 100 | 75 / 75 / 75 / 75 | src/groups.lua:63, src/lang_en.lua:168, src/pits.lua:58, src/tips_en.lua:198 |
| rules | `pitTyres` — New tyres at every stop (pit rules active) | boolean | true / true / true / true | src/groups.lua:64, src/lang_en.lua:168, src/lang_en.lua:307, src/pits.lua:138, src/strategy.lua:414, src/tips_en.lua:199 |
| rules | `pitRepair` — Repairs at every stop in the race (bodywork, suspension, engine) | boolean | true / true / true / true | src/applier.lua:386, src/engine.lua:127, src/engine.lua:866, src/groups.lua:64, src/lang_en.lua:168, src/lang_en.lua:307, src/pits.lua:112, src/pits.lua:143, src/pits.lua:145, src/sanctions.lua:7, src/sanctions.lua:422, src/tips_en.lua:200 |
| rules | `pitCompoundChange` — Change dry compound (F1) | boolean | false / false / false / false | src/groups.lua:64, src/lang_en.lua:168, src/pits.lua:38, src/pits.lua:61, src/tips_en.lua:201 |
| rules | `minPitTime` — Minimum stop time (s, 0 = free) | 0 to 120 | 0 / 0 / 0 / 0 | src/groups.lua:64, src/lang_en.lua:169, src/lang_en.lua:276, src/pits.lua:52, src/pits.lua:137, src/tips_en.lua:202 |
| rules | `maxStintMin` — Maximum stint (min, 0 = free) | 0 to 240 | 0 / 0 / 0 / 0 | src/groups.lua:64, src/lang_en.lua:169, src/lang_en.lua:276, src/pits.lua:52, src/pits.lua:129, src/pits.lua:187, src/tips_en.lua:204 |
| rules | `pitFuel` — Fuel at enforced stops | refuel, plan, ac | refuel / refuel / refuel / refuel | src/groups.lua:65, src/lang_en.lua:169, src/lang_en.lua:277, src/pits.lua:194, src/tips_en.lua:203 |
| rules | `pitsClosed` — Pit lane closed under neutralisation | open, pitFcy, pitFcySc | open / open / open / open | src/engine.lua:800, src/engine.lua:851, src/groups.lua:65, src/incidents.lua:20, src/incidents.lua:31, src/incidents.lua:361, src/incidents.lua:364, src/lang_en.lua:169, src/lang_en.lua:277, src/sanctions.lua:562, src/strategy.lua:286, src/strategy.lua:382, src/strategy.lua:401, src/tips_en.lua:205 |
| rules | `pitMessage` — Pit window opening message | boolean | true / true / true / true | src/groups.lua:63, src/lang_en.lua:169, src/lang_en.lua:306, src/pits.lua:64, src/pits.lua:74, src/tips_en.lua:206 |
| rules | `overtakeMode` — Overtake Mode (F1 2026, within one second at detection) | boolean | false / false / false / false | src/director.lua:1114, src/groups.lua:59, src/lang_en.lua:170, src/lang_en.lua:304, src/tips_en.lua:207 |
| rules | `overtakeModeGap` — Overtake Mode: detection gap (s) | 0.3 to 2 | 1 / 1 / 1 / 1 | src/director.lua:1116, src/groups.lua:59, src/lang_en.lua:170, src/lang_en.lua:304, src/tips_en.lua:208 |
| rules | `overtakeModeBoostPct` — Overtake Mode: level gain (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/director.lua:1118, src/groups.lua:59, src/lang_en.lua:170, src/lang_en.lua:305, src/tips_en.lua:209 |
| rules | `drsAssist` — Player DRS: beep and panel | boolean | true / true / true / true | src/engine.lua:478, src/engine.lua:699, src/engine.lua:767, src/groups.lua:60, src/lang_en.lua:171, src/panel.lua:121, src/panel.lua:154, src/tips_en.lua:168 |
| rules | `rulesDrs` — DRS: racing rules (rain, flags, start, Safety Car, red flag) | boolean | false / true / true / true | src/engine.lua:646, src/groups.lua:60, src/lang_en.lua:171, src/lang_en.lua:292, src/lang_en.lua:305, src/tips_en.lua:165 |
| rules | `rulesDrsLaps` — DRS: leader laps before enabling (start, SC, red flag) | 0 to 5 | 1 / 1 / 1 / 1 | src/engine.lua:670, src/groups.lua:60, src/lang_en.lua:171, src/lang_en.lua:305, src/tips_en.lua:166 |
| rules | `aiDrs` — AI DRS: opened in the zones | boolean | true / true / true / true | src/engine.lua:684, src/groups.lua:60, src/lang_en.lua:171, src/tips_en.lua:167 |
| rules | `drsBeepVolume` — Beeps (DRS and delta): volume (%) | 25 to 400 | 200 / 200 / 200 / 200 | src/engine.lua:478, src/engine.lua:639, src/engine.lua:767, src/groups.lua:60, src/lang_en.lua:171, src/lang_en.lua:306, src/tips_en.lua:164 |
| rules | `bopEnabled` — BoP: pace evened out within each class | boolean | false / false / false / false | src/classes.lua:42, src/director.lua:138, src/groups.lua:61, src/lang_en.lua:172, src/lang_en.lua:306, src/tips_en.lua:210 |
| rules | `bopStrengthPct` — BoP: maximum correction (%) | 0 to 5 | 2 / 2 / 2 / 2 | src/classes.lua:45, src/groups.lua:61, src/lang_en.lua:172, src/tips_en.lua:211 |
| rules | `proAmEnabled` — Pro-Am driver ratings (Bronze to Platinum) | boolean | false / false / false / false | src/groups.lua:61, src/lang_en.lua:172, src/persona.lua:31, src/persona.lua:32, src/tips_en.lua:212 |
| rules | `predictableSlowClass` — Slower class: predictable line | boolean | false / false / false / false | src/director.lua:749, src/groups.lua:62, src/lang_en.lua:172, src/tips_en.lua:213 |
| endurance | `enduranceOverlay` — Endurance layer | boolean | false / false / false / false | src/director.lua:139, src/director.lua:575, src/director.lua:1073, src/groups.lua:37, src/lang_en.lua:173, src/persona.lua:6, src/tips_en.lua:215 |
| endurance | `multiClass` — Multi-class | boolean | false / false / false / false | src/delta.lua:134, src/director.lua:90, src/director.lua:99, src/director.lua:1193, src/engine.lua:287, src/engine.lua:548, src/engine.lua:712, src/engine.lua:778, src/groups.lua:38, src/incidents.lua:438, src/lang_en.lua:173, src/sanctions.lua:206, src/sanctions.lua:466, src/tips_en.lua:216 |
| endurance | `classGapPct` — Gap between classes (%) | 3 to 25 | 8 / 8 / 8 / 8 | src/classes.lua:31, src/groups.lua:38, src/lang_en.lua:173, src/tips_en.lua:217 |
| endurance | `classYieldMargin` — Class speed advantage (km/h) | 1 to 15 | 4 / 4 / 4 / 4 | src/director.lua:348, src/director.lua:765, src/groups.lua:38, src/lang_en.lua:173, src/tips_en.lua:218 |
| endurance | `stintLevelSwing` — Variation between stints (%) | 0 to 8 | 3 / 3 / 3 / 3 | src/groups.lua:37, src/lang_en.lua:173, src/persona.lua:28, src/tips_en.lua:219 |
| endurance | `stintDegradationPct` — Degradation over a stint (%) | 0 to 5 | 1 / 1 / 1 / 1 | src/director.lua:140, src/groups.lua:37, src/lang_en.lua:173, src/tips_en.lua:220 |
| weather | `weatherAdaptation` — Adapt pace to the weather | boolean | true / true / true / true | src/director.lua:143, src/director.lua:369, src/groups.lua:39, src/lang_en.lua:174, src/tips_en.lua:222 |
| weather | `weatherTyresEnabled` — Manage dry and wet tyres | boolean | true / true / true / true | src/engine.lua:786, src/groups.lua:39, src/lang_en.lua:174, src/tips_en.lua:223, src/weather.lua:25 |
| weather | `weatherMessage` — On-screen message on a weather change | boolean | true / true / true / true | src/engine.lua:792, src/groups.lua:42, src/lang_en.lua:174, src/lang_en.lua:301, src/tips_en.lua:224 |
| weather | `rainGripBoostPct` — Rain compensation without wet tyres (%) | 0 to 30 | 15 / 15 / 15 / 15 | src/groups.lua:39, src/lang_en.lua:174, src/lang_en.lua:300, src/tips_en.lua:225, src/weather.lua:38 |
| weather | `outLapEnabled` — Out-lap: tyre warm-up | boolean | false / true / true / true | src/groups.lua:40, src/lang_en.lua:145, src/strategy.lua:216, src/strategy.lua:225, src/tips_en.lua:16 |
| weather | `outLapLevelPct` — Out-lap: level lowered by (%) | 0 to 15 | 7 / 7 / 7 / 7 | src/groups.lua:40, src/lang_en.lua:145, src/lang_en.lua:276, src/strategy.lua:205, src/strategy.lua:216, src/strategy.lua:219, src/strategy.lua:235, src/strategy.lua:454, src/tips_en.lua:17 |
| weather | `lockWearEnabled` — Lock-ups linked to tyre wear | boolean | false / true / true / true | src/groups.lua:41, src/lang_en.lua:145, src/mistakes.lua:75, src/mistakes.lua:103, src/tips_en.lua:18 |
| weather | `lockWearGain` — Lock-ups: gain at the end of a stint | 0 to 3 | 1.5 / 1.5 / 1.5 / 1.5 | src/groups.lua:41, src/lang_en.lua:145, src/lang_en.lua:276, src/mistakes.lua:50, src/tips_en.lua:19 |
| weather | `lockFlatSpotKm` — Flat spot: wear added per lock-up (km) | 0 to 5 | 1 / 1 / 1 / 1 | src/groups.lua:41, src/lang_en.lua:145, src/lang_en.lua:276, src/mistakes.lua:103, src/mistakes.lua:104, src/tips_en.lua:20 |
| lights | `lightsYellow` — Yellow · yellow flag, Safety Car, VSC, FCY | boolean | true / true / true / true | src/groups.lua:53, src/lang_en.lua:174, src/lang_en.lua:276, src/tips_en.lua:227 |
| lights | `lightsRed` — Red · red flag | boolean | true / true / true / true | src/groups.lua:53, src/lang_en.lua:174, src/lang_en.lua:276, src/lights.lua:110, src/tips_en.lua:228 |
| lights | `lightsBlue` — Blue · blue flag shown to you | boolean | true / true / true / true | src/groups.lua:53, src/lang_en.lua:174, src/lights.lua:126, src/tips_en.lua:229 |
| lights | `lightsWhite` — White · very slow vehicle ahead | boolean | true / true / true / true | src/groups.lua:53, src/lang_en.lua:174, src/lights.lua:124, src/tips_en.lua:230 |
| lights | `lightsOrange` — Orange · slippery track | boolean | true / true / true / true | src/groups.lua:53, src/lang_en.lua:174, src/lights.lua:125, src/tips_en.lua:231 |
| lights | `lightsGreen` — Green · end of zone, neutralisation and restart | boolean | true / true / true / true | src/groups.lua:53, src/lang_en.lua:174, src/lights.lua:94, src/lights.lua:120, src/tips_en.lua:232 |
| lights | `lightsGreenTime` — Green duration (s) | 0 to 15 | 5 / 5 / 5 / 5 | src/groups.lua:54, src/lang_en.lua:174, src/lang_en.lua:276, src/lights.lua:93, src/lights.lua:120, src/tips_en.lua:233 |
| lights | `lightsHold` — Delay before a less important colour (s) | 0.5 to 5 | 1.5 / 1.5 / 1.5 / 1.5 | ACAdvancedIA.lua:411, src/applier.lua:465, src/applier.lua:495, src/applier.lua:496, src/groups.lua:54, src/lang_en.lua:174, src/tips_en.lua:234 |
| strategy | `strategyEnabled` — Individual pit-stop strategy | boolean | false / false / false / true | src/groups.lua:44, src/lang_en.lua:145, src/strategy.lua:299, src/tips_en.lua:21 |
| strategy | `strategyTyreWearPct` — Tyre wear before stopping (%) | 30 to 95 | 75 / 75 / 75 / 75 | src/groups.lua:44, src/lang_en.lua:145, src/strategy.lua:123, src/strategy.lua:192, src/strategy.lua:197, src/tips_en.lua:22 |
| strategy | `strategyFuelMarginLaps` — Fuel margin (laps) | 0 to 3 | 1 / 1 / 1 / 1 | src/groups.lua:44, src/lang_en.lua:145, src/lang_en.lua:276, src/pits.lua:216, src/strategy.lua:131, src/tips_en.lua:23 |
| strategy | `strategyUndercut` — Undercut and overcut (reacting to rivals’ stops) | boolean | false / false / false / true | src/groups.lua:44, src/lang_en.lua:145, src/strategy.lua:358, src/strategy.lua:448, src/tips_en.lua:24 |
| strategy | `strategyRiskPct` — Average risk taking (%) | 0 to 100 | 50 / 50 / 50 / 50 | src/groups.lua:45, src/lang_en.lua:145, src/persona.lua:35, src/tips_en.lua:25 |
| strategy | `strategySpreadPct` — Spread between strategists (%) | 0 to 100 | 60 / 60 / 60 / 60 | src/groups.lua:45, src/lang_en.lua:145, src/persona.lua:35, src/tips_en.lua:26 |
| strategy | `failuresEnabled` — Progressive mechanical failures | boolean | false / false / false / true | src/groups.lua:46, src/lang_en.lua:145, src/strategy.lua:251, src/tips_en.lua:27 |
| strategy | `failureRate` — Failures: rate (per hour and per AI) | 0 to 2 | 0.05 / 0.05 / 0.05 / 0.05 | src/groups.lua:46, src/lang_en.lua:145, src/lang_en.lua:276, src/strategy.lua:251, src/strategy.lua:259, src/tips_en.lua:28 |
| strategy | `failureLossPct` — Failure: maximum pace loss (%) | 3 to 30 | 12 / 12 / 12 / 12 | src/groups.lua:46, src/lang_en.lua:145, src/strategy.lua:245, src/strategy.lua:264, src/tips_en.lua:29 |
| sanctions | `sanTrackLimits` — Track limits (at least three wheels off) | boolean | false / true / true / true | src/groups.lua:47, src/lang_en.lua:145, src/sanctions.lua:286, src/sanctions.lua:303, src/tips_en.lua:30 |
| sanctions | `sanTrackWarnings` — Warnings before a penalty (race) | 0 to 5 | 3 / 3 / 3 / 3 | src/groups.lua:47, src/lang_en.lua:145, src/lang_en.lua:276, src/sanctions.lua:236, src/sanctions.lua:237, src/sanctions.lua:238, src/sanctions.lua:239, src/tips_en.lua:31 |
| sanctions | `sanCutPenalty` — Corner cut with a time gain: throttle cut | boolean | false / false / false / true | src/groups.lua:47, src/lang_en.lua:145, src/sanctions.lua:297, src/sanctions.lua:321, src/tips_en.lua:32 |
| sanctions | `sanCutSeconds` — Throttle cut (s) | 2 to 15 | 5 / 5 / 5 / 5 | src/groups.lua:47, src/lang_en.lua:145, src/sanctions.lua:299, src/sanctions.lua:300, src/sanctions.lua:301, src/tips_en.lua:33 |
| sanctions | `sanJumpStart` — Jump start | boolean | false / false / false / true | src/groups.lua:48, src/lang_en.lua:145, src/sanctions.lua:97, src/sanctions.lua:567, src/tips_en.lua:34 |
| sanctions | `sanPitSpeed` — Pit-lane speeding | boolean | false / false / false / true | src/groups.lua:48, src/lang_en.lua:145, src/sanctions.lua:97, src/sanctions.lua:367, src/tips_en.lua:35 |
| sanctions | `sanPitExit` — Pit-exit line crossed | boolean | false / false / false / true | src/groups.lua:48, src/lang_en.lua:145, src/sanctions.lua:97, src/sanctions.lua:377, src/tips_en.lua:36 |
| sanctions | `sanProcedureKind` — Penalty for procedural offences | drive, stopgo, time | drive / drive / drive / drive | src/groups.lua:48, src/lang_en.lua:145, src/sanctions.lua:371, src/sanctions.lua:381, src/sanctions.lua:567, src/tips_en.lua:37 |
| sanctions | `sanWrongWay` — Wrong way: black flag | boolean | false / true / true / true | src/groups.lua:49, src/lang_en.lua:145, src/sanctions.lua:350, src/tips_en.lua:38 |
| sanctions | `sanWrongWaySeconds` — Wrong way tolerated (s) | 2 to 15 | 5 / 5 / 5 / 5 | src/groups.lua:49, src/lang_en.lua:145, src/sanctions.lua:350, src/tips_en.lua:39 |
| sanctions | `sanServeLaps` — Laps to serve a penalty (then black flag) | 1 to 5 | 3 / 3 / 3 / 3 | src/groups.lua:49, src/lang_en.lua:145, src/sanctions.lua:4, src/sanctions.lua:151, src/sanctions.lua:156, src/sanctions.lua:157, src/sanctions.lua:494, src/sanctions.lua:510, src/tips_en.lua:40 |
| sanctions | `sanStopGoSeconds` — Stop-and-go: stop (s) | 5 to 30 | 10 / 10 / 10 / 10 | src/groups.lua:50, src/lang_en.lua:145, src/sanctions.lua:142, src/sanctions.lua:156, src/sanctions.lua:158, src/sanctions.lua:429, src/sanctions.lua:430, src/tips_en.lua:41 |
| sanctions | `sanTimeSeconds` — Time penalty (s) | 1 to 30 | 5 / 5 / 5 / 5 | src/groups.lua:50, src/lang_en.lua:145, src/sanctions.lua:148, src/sanctions.lua:150, src/sanctions.lua:236, src/sanctions.lua:240, src/sanctions.lua:337, src/sanctions.lua:483, src/tips_en.lua:42 |
| sanctions | `sanUnservedTime` — Unserved penalty added to the result | boolean | false / false / false / true | src/groups.lua:50, src/lang_en.lua:145, src/sanctions.lua:152, src/sanctions.lua:652, src/tips_en.lua:43 |
| sanctions | `sanGiveBack` — Give the place back after an off-track overtake | boolean | false / false / false / true | src/groups.lua:50, src/lang_en.lua:145, src/sanctions.lua:278, src/sanctions.lua:439, src/tips_en.lua:44 |
| sanctions | `sanGiveBackSeconds` — Time to give the place back (s) | 5 to 30 | 15 / 15 / 15 / 15 | src/groups.lua:50, src/lang_en.lua:145, src/sanctions.lua:453, src/sanctions.lua:454, src/tips_en.lua:45 |
| sanctions | `sanMessages` — AI sanction notices on screen | boolean | false / true / true / true | src/groups.lua:51, src/lang_en.lua:145, src/sanctions.lua:106, src/tips_en.lua:46 |
| traffic | `trafficGapSeconds` — Base gap (s) | 0.5 to 5 | 2.5 / 2.5 / 2.5 / 2.5 | src/groups.lua:30, src/lang_en.lua:175, src/tips_en.lua:236, src/traffic.lua:209 |
| traffic | `trafficDensityGain` — Distance added per AI (m) | 0.5 to 5 | 2.8 / 2.8 / 2.8 / 2.8 | src/groups.lua:30, src/lang_en.lua:175, src/tips_en.lua:237, src/traffic.lua:209 |
| traffic | `trafficVariation` — Gap variation (%) | 0 to 50 | 45 / 45 / 45 / 45 | src/groups.lua:30, src/lang_en.lua:175, src/tips_en.lua:238, src/traffic.lua:208 |
| traffic | `trafficMaxReduction` — Maximum speed reduction (%) | 2 to 20 | 14 / 14 / 14 / 14 | src/groups.lua:30, src/lang_en.lua:175, src/tips_en.lua:239, src/traffic.lua:219 |

## Adjustable global options

| Key | Default | Range | Consumers |
|---|---|---|---|
| `levelMode` | auto | auto, native, grip, none | src/applier.lua:1032, src/applier.lua:1039, src/caps.lua:4, src/caps.lua:52, src/caps.lua:53, src/lang_en.lua:78, src/tips_en.lua:257 |
| `useGripBoost` | false | boolean | src/applier.lua:1039, src/caps.lua:53, src/tips_en.lua:258 |
| `gripPerLevelPct` | 0.004 | [0, 0.01] | src/applier.lua:1039, src/lang_en.lua:143, src/tips_en.lua:269 |
| `useBrakeAssist` | true | boolean | src/applier.lua:1017, src/applier.lua:1046, src/director.lua:1037, src/engine.lua:45, src/tips_en.lua:259 |
| `overrideAwareness` | false | boolean | src/applier.lua:1025, src/tips_en.lua:260 |
| `occLatMin` | 0.3 | [0.1, 1] | src/lang_en.lua:143, src/lang_en.lua:308, src/perception.lua:53, src/perception.lua:54, src/perception.lua:55, src/tips_en.lua:265 |
| `occLatMax` | 5.5 | [2, 8] | src/director.lua:639, src/director.lua:729, src/director.lua:817, src/director.lua:859, src/director.lua:992, src/lang_en.lua:143, src/lang_en.lua:308, src/perception.lua:42, src/perception.lua:47, src/perception.lua:54, src/perception.lua:55, src/perception.lua:107, src/tips_en.lua:266 |
| `occMargin` | 6 | [2, 15] | src/lang_en.lua:143, src/lang_en.lua:308, src/perception.lua:45, src/perception.lua:50, src/tips_en.lua:267 |
| `occSpeedGain` | 0.8 | [0, 2] | src/lang_en.lua:143, src/lang_en.lua:308, src/perception.lua:45, src/perception.lua:50, src/tips_en.lua:268 |
| `seed` | 19731019 | [0, 2147483647] | src/director.lua:68, src/director.lua:393, src/director.lua:538, src/director.lua:574, src/director.lua:897, src/director.lua:1075, src/engine.lua:101, src/engine.lua:181, src/engine.lua:437, src/engine.lua:536, src/engine.lua:780, src/engine.lua:800, src/engine.lua:871, src/flash.lua:70, src/grid.lua:166, src/grid.lua:198, src/incidents.lua:163, src/incidents.lua:241, src/lang_en.lua:79, src/mistakes.lua:88, src/mistakes.lua:97, src/persona.lua:5, src/persona.lua:8, src/persona.lua:9, src/persona.lua:28, src/persona.lua:30, src/persona.lua:40, src/persona.lua:43, src/persona.lua:45, src/persona.lua:46, src/persona.lua:47, src/pits.lua:51, src/pits.lua:121, src/strategy.lua:248, src/strategy.lua:259, src/strategy.lua:261, src/strategy.lua:263, src/strategy.lua:264, src/strategy.lua:265, src/strategy.lua:300, src/strategy.lua:334, src/tips_en.lua:270, src/tips_en.lua:290, src/tips_en.lua:356, src/traffic.lua:69, src/traffic.lua:86, src/traffic.lua:120, src/traffic.lua:197, src/util.lua:18, src/util.lua:19, src/util.lua:32, src/weather.lua:9, src/weather.lua:11, src/weather.lua:14, src/weather.lua:28 |
| `debugLog` | false | boolean | src/director.lua:87, src/director.lua:1140, src/lang_en.lua:79, src/tips_en.lua:264 |

The section switches go through `C.on`/`C.effective` and are walked by the interface tests. `classPatterns` uses the `C.patterns` parser, `Classes.configure/update`, the eight dedicated rows and validated storage. The manual/automatic choice, the main button, panic, presets and the diagnostics tools are examined in AUDIT_V1.md.

## Functions examined

List taken from the AST of the 42 active files, including local and anonymous functions. The review, fixes and limits are in AUDIT_V1.md. This list does not mean 100% branch coverage.

| File | Line | Function |
|---|---|---|
| ACAdvancedIA.lua | 11 | `(anonymous)` |
| ACAdvancedIA.lua | 16 | `none` |
| ACAdvancedIA.lua | 20 | `(anonymous)` |
| ACAdvancedIA.lua | 21 | `(anonymous)` |
| ACAdvancedIA.lua | 21 | `(anonymous)` |
| ACAdvancedIA.lua | 21 | `(anonymous)` |
| ACAdvancedIA.lua | 30 | `(anonymous)` |
| ACAdvancedIA.lua | 43 | `restartOnly` |
| ACAdvancedIA.lua | 44 | `script.update` |
| ACAdvancedIA.lua | 45 | `script.HUMANAI__UPDATE` |
| ACAdvancedIA.lua | 46 | `script.HUMANAI__MAIN` |
| ACAdvancedIA.lua | 47 | `script.HUMANAI__MENU` |
| ACAdvancedIA.lua | 48 | `script.HUMANAI__FLAGS` |
| ACAdvancedIA.lua | 49 | `script.HUMANAI__HUD` |
| ACAdvancedIA.lua | 98 | `announce` |
| ACAdvancedIA.lua | 110 | `dirty` |
| ACAdvancedIA.lua | 118 | `(anonymous)` |
| ACAdvancedIA.lua | 126 | `(anonymous)` |
| ACAdvancedIA.lua | 129 | `cspLog` |
| ACAdvancedIA.lua | 134 | `(anonymous)` |
| ACAdvancedIA.lua | 143 | `cspStep` |
| ACAdvancedIA.lua | 162 | `writeJournal` |
| ACAdvancedIA.lua | 174 | `cancelProbe` |
| ACAdvancedIA.lua | 175 | `syncRestored` |
| ACAdvancedIA.lua | 185 | `anyOwned` |
| ACAdvancedIA.lua | 190 | `step` |
| ACAdvancedIA.lua | 196 | `stop` |
| ACAdvancedIA.lua | 202 | `saveRace` |
| ACAdvancedIA.lua | 211 | `release` |
| ACAdvancedIA.lua | 229 | `updateLog` |
| ACAdvancedIA.lua | 233 | `(anonymous)` |
| ACAdvancedIA.lua | 248 | `startProbe` |
| ACAdvancedIA.lua | 249 | `(anonymous)` |
| ACAdvancedIA.lua | 277 | `session` |
| ACAdvancedIA.lua | 286 | `lightsCheck` |
| ACAdvancedIA.lua | 293 | `update` |
| ACAdvancedIA.lua | 319 | `(anonymous)` |
| ACAdvancedIA.lua | 320 | `(anonymous)` |
| ACAdvancedIA.lua | 424 | `updateTick` |
| ACAdvancedIA.lua | 444 | `protect` |
| ACAdvancedIA.lua | 460 | `script.HUMANAI__UPDATE` |
| ACAdvancedIA.lua | 483 | `script.update` |
| ACAdvancedIA.lua | 484 | `script.HUMANAI__MENU` |
| ACAdvancedIA.lua | 487 | `protectUI` |
| ACAdvancedIA.lua | 501 | `timedUI` |
| ACAdvancedIA.lua | 516 | `script.HUMANAI__MAIN` |
| ACAdvancedIA.lua | 528 | `script.HUMANAI__FLAGS` |
| ACAdvancedIA.lua | 530 | `script.HUMANAI__HUD` |
| src/applier.lua | 14 | `note` |
| src/applier.lua | 17 | `callable` |
| src/applier.lua | 25 | `nativeClock` |
| src/applier.lua | 32 | `(anonymous)` |
| src/applier.lua | 37 | `osClock` |
| src/applier.lua | 49 | `initClock` |
| src/applier.lua | 55 | `present` |
| src/applier.lua | 61 | `setBrake` |
| src/applier.lua | 66 | `setFlash` |
| src/applier.lua | 67 | `write` |
| src/applier.lua | 84 | `(anonymous)` |
| src/applier.lua | 88 | `M.new` |
| src/applier.lua | 97 | `(anonymous)` |
| src/applier.lua | 107 | `M.clock` |
| src/applier.lua | 119 | `M.access` |
| src/applier.lua | 126 | `M.openStore` |
| src/applier.lua | 153 | `M.savePreset` |
| src/applier.lua | 159 | `(anonymous)` |
| src/applier.lua | 167 | `M.deletePreset` |
| src/applier.lua | 169 | `(anonymous)` |
| src/applier.lua | 174 | `readOption` |
| src/applier.lua | 179 | `readRaceFlagsHidden` |
| src/applier.lua | 184 | `M.readFlagsHidden` |
| src/applier.lua | 188 | `M.menu` |
| src/applier.lua | 202 | `M.compactWindow` |
| src/applier.lua | 206 | `(anonymous)` |
| src/applier.lua | 208 | `(anonymous)` |
| src/applier.lua | 213 | `M.baselines` |
| src/applier.lua | 219 | `M.dirty` |
| src/applier.lua | 220 | `M.rebase` |
| src/applier.lua | 231 | `M.save` |
| src/applier.lua | 234 | `(anonymous)` |
| src/applier.lua | 246 | `restoreRain` |
| src/applier.lua | 250 | `restoreSkin` |
| src/applier.lua | 254 | `(anonymous)` |
| src/applier.lua | 258 | `M.restore` |
| src/applier.lua | 309 | `send` |
| src/applier.lua | 317 | `field` |
| src/applier.lua | 322 | `claim` |
| src/applier.lua | 331 | `weather` |
| src/applier.lua | 358 | `tyreLabel` |
| src/applier.lua | 364 | `pitRequest` |
| src/applier.lua | 424 | `startDelay` |
| src/applier.lua | 434 | `place` |
| src/applier.lua | 450 | `hold` |
| src/applier.lua | 467 | `flagText` |
| src/applier.lua | 472 | `unwritten` |
| src/applier.lua | 479 | `redHidden` |
| src/applier.lua | 490 | `nativeFree` |
| src/applier.lua | 491 | `M.flag` |
| src/applier.lua | 522 | `M.reportCaps` |
| src/applier.lua | 532 | `gridNode` |
| src/applier.lua | 539 | `M.gridNodes` |
| src/applier.lua | 555 | `folder` |
| src/applier.lua | 560 | `normalPath` |
| src/applier.lua | 568 | `inside` |
| src/applier.lua | 569 | `lightsLoad` |
| src/applier.lua | 574 | `lightsRead` |
| src/applier.lua | 636 | `M.trackLights` |
| src/applier.lua | 647 | `flash` |
| src/applier.lua | 659 | `safetySkin` |
| src/applier.lua | 663 | `(anonymous)` |
| src/applier.lua | 665 | `(anonymous)` |
| src/applier.lua | 672 | `safety` |
| src/applier.lua | 680 | `(anonymous)` |
| src/applier.lua | 716 | `recover` |
| src/applier.lua | 729 | `M.releaseBlackFlag` |
| src/applier.lua | 736 | `M.penalty` |
| src/applier.lua | 750 | `disposeBeep` |
| src/applier.lua | 750 | `(anonymous)` |
| src/applier.lua | 751 | `M.beep` |
| src/applier.lua | 759 | `play` |
| src/applier.lua | 772 | `M.deltaBeep` |
| src/applier.lua | 779 | `(anonymous)` |
| src/applier.lua | 783 | `play` |
| src/applier.lua | 788 | `(anonymous)` |
| src/applier.lua | 793 | `M.drs` |
| src/applier.lua | 817 | `releaseDrs` |
| src/applier.lua | 824 | `M.sessionBox` |
| src/applier.lua | 825 | `M.screen` |
| src/applier.lua | 831 | `M.listenMessages` |
| src/applier.lua | 835 | `M.blockMessages` |
| src/applier.lua | 839 | `M.dispose` |
| src/applier.lua | 845 | `scriptFolder` |
| src/applier.lua | 850 | `M.fontDir` |
| src/applier.lua | 852 | `(anonymous)` |
| src/applier.lua | 861 | `M.appFile` |
| src/applier.lua | 869 | `M.journalOpen` |
| src/applier.lua | 871 | `(anonymous)` |
| src/applier.lua | 887 | `M.clockText` |
| src/applier.lua | 892 | `M.journalWrite` |
| src/applier.lua | 896 | `(anonymous)` |
| src/applier.lua | 901 | `M.storeText` |
| src/applier.lua | 902 | `M.loadText` |
| src/applier.lua | 903 | `M.message` |
| src/applier.lua | 905 | `M.probeMessage` |
| src/applier.lua | 907 | `folderFile` |
| src/applier.lua | 914 | `floodPath` |
| src/applier.lua | 915 | `M.floodRead` |
| src/applier.lua | 926 | `M.floodLeftover` |
| src/applier.lua | 938 | `saveClean` |
| src/applier.lua | 948 | `M.floodWrite` |
| src/applier.lua | 952 | `fileText` |
| src/applier.lua | 959 | `removeFile` |
| src/applier.lua | 964 | `M.cspPort` |
| src/applier.lua | 969 | `(anonymous)` |
| src/applier.lua | 970 | `(anonymous)` |
| src/applier.lua | 971 | `(anonymous)` |
| src/applier.lua | 972 | `(anonymous)` |
| src/applier.lua | 973 | `(anonymous)` |
| src/applier.lua | 974 | `(anonymous)` |
| src/applier.lua | 975 | `(anonymous)` |
| src/applier.lua | 976 | `(anonymous)` |
| src/applier.lua | 983 | `M.watchGui` |
| src/applier.lua | 988 | `M.apply` |
| src/applier.lua | 1076 | `M.register` |
| src/applier.lua | 1080 | `M.unregister` |
| src/applier.lua | 1082 | `(anonymous)` |
| src/applier.lua | 1087 | `M.nextSession` |
| src/applier.lua | 1108 | `M.clipboard` |
| src/applier.lua | 1109 | `M.checkpoint` |
| src/applier.lua | 1120 | `M.recover` |
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
| src/config.lua | 73 | `M.hidden` |
| src/config.lua | 78 | `add` |
| src/config.lua | 84 | `n` |
| src/config.lua | 85 | `b` |
| src/config.lua | 86 | `e` |
| src/config.lua | 528 | `M.defaults` |
| src/config.lua | 539 | `M.sectionsChanged` |
| src/config.lua | 546 | `M.anySection` |
| src/config.lua | 550 | `choice` |
| src/config.lua | 551 | `M.patterns` |
| src/config.lua | 561 | `M.validate` |
| src/config.lua | 595 | `M.validateGlobals` |
| src/config.lua | 616 | `M.preset` |
| src/config.lua | 628 | `M.on` |
| src/config.lua | 629 | `M.any` |
| src/config.lua | 634 | `M.effective` |
| src/config.lua | 670 | `M.effectiveGlobals` |
| src/config.lua | 677 | `M.needsOffset` |
| src/config.lua | 680 | `equal` |
| src/config.lua | 696 | `M.legacyMatch` |
| src/config.lua | 721 | `M.upgradeObstacles` |
| src/config.lua | 732 | `M.migrateProfile` |
| src/config.lua | 794 | `M.migrate` |
| src/config.lua | 862 | `M.kept` |
| src/config.lua | 863 | `ruleValue` |
| src/config.lua | 864 | `M.restore` |
| src/config.lua | 873 | `applyValues` |
| src/config.lua | 877 | `M.weekendSwitch` |
| src/config.lua | 886 | `M.applyRules` |
| src/config.lua | 901 | `M.spreadRules` |
| src/config.lua | 915 | `M.mark` |
| src/config.lua | 919 | `M.setMark` |
| src/config.lua | 925 | `M.withRules` |
| src/config.lua | 936 | `category13` |
| src/config.lua | 950 | `M.migrateRules` |
| src/config.lua | 960 | `M.closestRuleCategory` |
| src/config.lua | 969 | `M.ruleCategory` |
| src/config.lua | 981 | `M.autoProfile` |
| src/cspgui.lua | 28 | `hidden` |
| src/cspgui.lua | 29 | `list` |
| src/cspgui.lua | 34 | `heldKeys` |
| src/cspgui.lua | 42 | `block` |
| src/cspgui.lua | 43 | `M.serialize` |
| src/cspgui.lua | 54 | `M.parse` |
| src/cspgui.lua | 63 | `read` |
| src/cspgui.lua | 80 | `M.new` |
| src/cspgui.lua | 84 | `note` |
| src/cspgui.lua | 86 | `M.take` |
| src/cspgui.lua | 87 | `session` |
| src/cspgui.lua | 92 | `M.start` |
| src/cspgui.lua | 110 | `M.reloaded` |
| src/cspgui.lua | 117 | `M.frozen` |
| src/cspgui.lua | 118 | `M.applied` |
| src/cspgui.lua | 120 | `M.pending` |
| src/cspgui.lua | 123 | `M.view` |
| src/cspgui.lua | 132 | `stop` |
| src/cspgui.lua | 135 | `M.step` |
| src/cspgui.lua | 209 | `M.release` |
| src/delta.lua | 10 | `accumulator` |
| src/delta.lua | 11 | `M.new` |
| src/delta.lua | 17 | `M.reset` |
| src/delta.lua | 21 | `M.rebase` |
| src/delta.lua | 26 | `bin` |
| src/delta.lua | 32 | `M.size` |
| src/delta.lua | 40 | `M.refresh` |
| src/delta.lua | 71 | `M.pace` |
| src/delta.lua | 79 | `M.reference` |
| src/delta.lua | 87 | `M.zoneReference` |
| src/delta.lua | 93 | `regime` |
| src/delta.lua | 106 | `sectors` |
| src/delta.lua | 109 | `advance` |
| src/delta.lua | 123 | `brakeFloor` |
| src/delta.lua | 124 | `zoneExists` |
| src/delta.lua | 129 | `M.update` |
| src/delta.lua | 198 | `M.penalized` |
| src/director.lua | 17 | `M.newState` |
| src/director.lua | 48 | `M.reset` |
| src/director.lua | 67 | `M.configure` |
| src/director.lua | 75 | `transition` |
| src/director.lua | 90 | `faster` |
| src/director.lua | 91 | `sideFree` |
| src/director.lua | 93 | `paceBin` |
| src/director.lua | 96 | `freeAt` |
| src/director.lua | 106 | `realAdvantage` |
| src/director.lua | 113 | `userSide` |
| src/director.lua | 114 | `fixedSide` |
| src/director.lua | 115 | `yieldSide` |
| src/director.lua | 122 | `passSide` |
| src/director.lua | 131 | `baseModifiers` |
| src/director.lua | 148 | `directionAllowed` |
| src/director.lua | 171 | `directionBudget` |
| src/director.lua | 181 | `wanted` |
| src/director.lua | 182 | `limitText` |
| src/director.lua | 191 | `M.reachable` |
| src/director.lua | 202 | `laneTarget` |
| src/director.lua | 211 | `laneHold` |
| src/director.lua | 237 | `M.lateral` |
| src/director.lua | 274 | `busy` |
| src/director.lua | 287 | `pace` |
| src/director.lua | 311 | `lapOrClass` |
| src/director.lua | 316 | `yieldTrigger` |
| src/director.lua | 423 | `M.trafficCap` |
| src/director.lua | 436 | `aeroMap` |
| src/director.lua | 451 | `straightBin` |
| src/director.lua | 452 | `aeroRuns` |
| src/director.lua | 469 | `lapsAhead` |
| src/director.lua | 475 | `rival` |
| src/director.lua | 482 | `directionRoom` |
| src/director.lua | 490 | `dirtyAir` |
| src/director.lua | 498 | `urgency` |
| src/director.lua | 517 | `towStart` |
| src/director.lua | 553 | `M.step` |
| src/engine.lua | 27 | `startReport` |
| src/engine.lua | 53 | `decisionTime` |
| src/engine.lua | 69 | `contacts` |
| src/engine.lua | 97 | `M.new` |
| src/engine.lua | 105 | `(anonymous)` |
| src/engine.lua | 107 | `(anonymous)` |
| src/engine.lua | 131 | `M.changed` |
| src/engine.lua | 132 | `M.select` |
| src/engine.lua | 135 | `M.reset` |
| src/engine.lua | 139 | `M.rebase` |
| src/engine.lua | 169 | `M.configure` |
| src/engine.lua | 186 | `drsBeep` |
| src/engine.lua | 192 | `drive` |
| src/engine.lua | 205 | `M.drawnByAC` |
| src/engine.lua | 213 | `M.message` |
| src/engine.lua | 236 | `M.floodInit` |
| src/engine.lua | 245 | `flood` |
| src/engine.lua | 282 | `slowReset` |
| src/engine.lua | 284 | `(anonymous)` |
| src/engine.lua | 286 | `slowCars` |
| src/engine.lua | 363 | `raceInfo` |
| src/engine.lua | 373 | `M.step` |
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
| src/flood.lua | 36 | `M.edit` |
| src/flood.lua | 69 | `M.truthy` |
| src/flood.lua | 71 | `M.state` |
| src/flood.lua | 78 | `round` |
| src/flood.lua | 80 | `M.values` |
| src/flood.lua | 88 | `M.backup` |
| src/flood.lua | 96 | `M.restore` |
| src/flood.lua | 106 | `M.decide` |
| src/grid.lua | 21 | `M.new` |
| src/grid.lua | 25 | `clearCars` |
| src/grid.lua | 26 | `clearPlayer` |
| src/grid.lua | 27 | `M.reset` |
| src/grid.lua | 32 | `M.rebase` |
| src/grid.lua | 39 | `byPosition` |
| src/grid.lua | 45 | `M.sortByPosition` |
| src/grid.lua | 55 | `M.resolve` |
| src/grid.lua | 83 | `M.start` |
| src/grid.lua | 104 | `gap` |
| src/grid.lua | 116 | `approach` |
| src/grid.lua | 129 | `pitStarter` |
| src/grid.lua | 135 | `release` |
| src/grid.lua | 150 | `expected` |
| src/grid.lua | 160 | `placedPlayer` |
| src/grid.lua | 166 | `M.step` |
| src/groups.lua | 70 | `M.build` |
| src/hudinfo.lua | 11 | `M.new` |
| src/hudinfo.lua | 18 | `M.lapTime` |
| src/hudinfo.lua | 24 | `M.clock` |
| src/hudinfo.lua | 30 | `reset` |
| src/hudinfo.lua | 37 | `M.message` |
| src/hudinfo.lua | 49 | `M.flood` |
| src/hudinfo.lua | 56 | `passes` |
| src/hudinfo.lua | 77 | `recap` |
| src/hudinfo.lua | 97 | `item` |
| src/hudinfo.lua | 102 | `strip` |
| src/hudinfo.lua | 119 | `M.update` |
| src/incidents.lua | 8 | `clearCar` |
| src/incidents.lua | 13 | `M.new` |
| src/incidents.lua | 28 | `M.reset` |
| src/incidents.lua | 36 | `M.rebase` |
| src/incidents.lua | 53 | `message` |
| src/incidents.lua | 59 | `note` |
| src/incidents.lua | 62 | `unavailable` |
| src/incidents.lua | 69 | `restart` |
| src/incidents.lua | 80 | `M.lightsOut` |
| src/incidents.lua | 89 | `standing` |
| src/incidents.lua | 98 | `restartRule` |
| src/incidents.lua | 101 | `leaderLap` |
| src/incidents.lua | 124 | `release` |
| src/incidents.lua | 135 | `traffic` |
| src/incidents.lua | 149 | `queued` |
| src/incidents.lua | 163 | `M.update` |
| src/incidents.lua | 421 | `M.safety` |
| src/incidents.lua | 431 | `position` |
| src/incidents.lua | 436 | `M.cap` |
| src/incidents.lua | 483 | `M.player` |
| src/journal.lua | 3 | `M.new` |
| src/journal.lua | 5 | `M.collect` |
| src/journal.lua | 14 | `M.take` |
| src/journal.lua | 22 | `M.summary` |
| src/journal.lua | 45 | `c` |
| src/lights.lua | 19 | `M.new` |
| src/lights.lua | 24 | `M.reset` |
| src/lights.lua | 30 | `M.rebase` |
| src/lights.lua | 40 | `slow` |
| src/lights.lua | 71 | `damage` |
| src/lights.lua | 87 | `green` |
| src/lights.lua | 102 | `M.decide` |
| src/lights.lua | 131 | `M.update` |
| src/lights.lua | 144 | `M.output` |
| src/lights.lua | 150 | `M.scan` |
| src/lights.lua | 154 | `close` |
| src/lights.lua | 187 | `M.equipped` |
| src/locale.lua | 12 | `copy` |
| src/locale.lua | 19 | `fill` |
| src/locale.lua | 25 | `texts` |
| src/locale.lua | 30 | `M.valid` |
| src/locale.lua | 32 | `M.set` |
| src/merge.lua | 14 | `car` |
| src/merge.lua | 15 | `M.new` |
| src/merge.lua | 20 | `M.reset` |
| src/merge.lua | 25 | `M.before` |
| src/merge.lua | 27 | `learn` |
| src/merge.lua | 41 | `arriving` |
| src/merge.lua | 58 | `M.update` |
| src/merge.lua | 102 | `M.idle` |
| src/mistakes.lua | 10 | `car` |
| src/mistakes.lua | 11 | `M.new` |
| src/mistakes.lua | 16 | `M.reset` |
| src/mistakes.lua | 20 | `M.rebase` |
| src/mistakes.lua | 32 | `risk` |
| src/mistakes.lua | 44 | `lockFactor` |
| src/mistakes.lua | 53 | `M.update` |
| src/panel.lua | 14 | `M.new` |
| src/panel.lua | 19 | `blue` |
| src/panel.lua | 40 | `native` |
| src/panel.lua | 65 | `show` |
| src/panel.lua | 113 | `M.native` |
| src/panel.lua | 129 | `M.visible` |
| src/panel.lua | 135 | `M.infractions` |
| src/panel.lua | 143 | `M.warn` |
| src/panel.lua | 145 | `M.notice` |
| src/panel.lua | 147 | `M.update` |
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
| src/penalties.lua | 140 | `M.giveBackLimit` |
| src/penalties.lua | 142 | `sanction` |
| src/penalties.lua | 154 | `M.ai` |
| src/penalties.lua | 222 | `M.serialize` |
| src/penalties.lua | 232 | `M.restore` |
| src/penalties.lua | 252 | `M.resume` |
| src/perception.lua | 5 | `M.new` |
| src/perception.lua | 14 | `M.relative` |
| src/perception.lua | 34 | `M.occupancy` |
| src/perception.lua | 61 | `M.prepare` |
| src/perception.lua | 73 | `M.refresh` |
| src/perception.lua | 96 | `M.find` |
| src/perception.lua | 100 | `M.corridor` |
| src/persona.lua | 5 | `M.fill` |
| src/persona.lua | 8 | `r` |
| src/persona.lua | 9 | `trait` |
| src/persona.lua | 43 | `M.nextLapse` |
| src/pits.lua | 5 | `clear` |
| src/pits.lua | 12 | `M.new` |
| src/pits.lua | 17 | `M.reset` |
| src/pits.lua | 21 | `M.rebase` |
| src/pits.lua | 26 | `M.progress` |
| src/pits.lua | 33 | `M.compound` |
| src/pits.lua | 45 | `M.repairTime` |
| src/pits.lua | 51 | `M.update` |
| src/pits.lua | 151 | `learn` |
| src/pits.lua | 171 | `lapsLeft` |
| src/pits.lua | 179 | `stintLaps` |
| src/pits.lua | 193 | `M.fuel` |
| src/pits.lua | 225 | `M.serialize` |
| src/pits.lua | 231 | `M.forget` |
| src/pits.lua | 232 | `M.restore` |
| src/presets.lua | 7 | `M.signature` |
| src/presets.lua | 16 | `M.layout` |
| src/presets.lua | 22 | `M.decode` |
| src/presets.lua | 73 | `M.capture` |
| src/presets.lua | 79 | `M.encode` |
| src/presets.lua | 85 | `M.apply` |
| src/remote.lua | 22 | `callable` |
| src/remote.lua | 23 | `folder` |
| src/remote.lua | 30 | `hex` |
| src/remote.lua | 33 | `(anonymous)` |
| src/remote.lua | 37 | `files` |
| src/remote.lua | 38 | `(anonymous)` |
| src/remote.lua | 46 | `folders` |
| src/remote.lua | 47 | `(anonymous)` |
| src/remote.lua | 54 | `rank` |
| src/remote.lua | 58 | `ordered` |
| src/remote.lua | 59 | `(anonymous)` |
| src/remote.lua | 63 | `parseList` |
| src/remote.lua | 75 | `lib` |
| src/remote.lua | 80 | `M.new` |
| src/remote.lua | 95 | `exists` |
| src/remote.lua | 96 | `load` |
| src/remote.lua | 97 | `save` |
| src/remote.lua | 104 | `delete` |
| src/remote.lua | 111 | `clock` |
| src/remote.lua | 114 | `watch` |
| src/remote.lua | 115 | `list` |
| src/remote.lua | 118 | `clear` |
| src/remote.lua | 126 | `copy` |
| src/remote.lua | 129 | `swap` |
| src/remote.lua | 137 | `listOf` |
| src/remote.lua | 138 | `complete` |
| src/remote.lua | 144 | `p.get` |
| src/remote.lua | 146 | `(anonymous)` |
| src/remote.lua | 151 | `p.json` |
| src/remote.lua | 152 | `p.sha256` |
| src/remote.lua | 153 | `p.entries` |
| src/remote.lua | 154 | `p.entry` |
| src/remote.lua | 155 | `p.installedVersion` |
| src/remote.lua | 157 | `p.sourceVersion` |
| src/remote.lua | 158 | `p.sourceComplete` |
| src/remote.lua | 159 | `p.sourceHas` |
| src/remote.lua | 164 | `p.markerFile` |
| src/remote.lua | 165 | `p.marker` |
| src/remote.lua | 167 | `p.mark` |
| src/remote.lua | 169 | `p.clearMarker` |
| src/remote.lua | 174 | `p.report` |
| src/remote.lua | 175 | `p.takeReport` |
| src/remote.lua | 182 | `p.boot` |
| src/remote.lua | 187 | `p.bootSet` |
| src/remote.lua | 188 | `p.bootClear` |
| src/remote.lua | 190 | `p.bootOk` |
| src/remote.lua | 191 | `p.failedNote` |
| src/remote.lua | 192 | `p.failed` |
| src/remote.lua | 193 | `p.clearFailed` |
| src/remote.lua | 195 | `p.log` |
| src/remote.lua | 196 | `p.open` |
| src/remote.lua | 199 | `p.stage` |
| src/remote.lua | 202 | `(anonymous)` |
| src/remote.lua | 216 | `p.snapshot` |
| src/remote.lua | 240 | `p.place` |
| src/remote.lua | 263 | `p.promote` |
| src/remote.lua | 289 | `empty` |
| src/remote.lua | 293 | `p.tidy` |
| src/remote.lua | 296 | `gone` |
| src/remote.lua | 306 | `(anonymous)` |
| src/remote.lua | 318 | `p.restart` |
| src/sanctions.lua | 20 | `car` |
| src/sanctions.lua | 37 | `clearCar` |
| src/sanctions.lua | 44 | `M.new` |
| src/sanctions.lua | 50 | `rebuild` |
| src/sanctions.lua | 57 | `M.reset` |
| src/sanctions.lua | 66 | `M.rebase` |
| src/sanctions.lua | 81 | `dropTransient` |
| src/sanctions.lua | 91 | `reasonText` |
| src/sanctions.lua | 98 | `event` |
| src/sanctions.lua | 105 | `notice` |
| src/sanctions.lua | 111 | `name` |
| src/sanctions.lua | 114 | `blackFlag` |
| src/sanctions.lua | 127 | `escalate` |
| src/sanctions.lua | 131 | `addTime` |
| src/sanctions.lua | 142 | `unservedSeconds` |
| src/sanctions.lua | 146 | `issue` |
| src/sanctions.lua | 164 | `lineBin` |
| src/sanctions.lua | 165 | `ignoredAt` |
| src/sanctions.lua | 166 | `lineIgnored` |
| src/sanctions.lua | 171 | `refund` |
| src/sanctions.lua | 186 | `lineSeen` |
| src/sanctions.lua | 200 | `cutGain` |
| src/sanctions.lua | 219 | `behind` |
| src/sanctions.lua | 233 | `strike` |
| src/sanctions.lua | 242 | `invalidate` |
| src/sanctions.lua | 255 | `progress` |
| src/sanctions.lua | 256 | `watchStart` |
| src/sanctions.lua | 269 | `appManoeuvre` |
| src/sanctions.lua | 272 | `trackLimits` |
| src/sanctions.lua | 318 | `throttle` |
| src/sanctions.lua | 343 | `wrongWay` |
| src/sanctions.lua | 356 | `pitLane` |
| src/sanctions.lua | 402 | `serve` |
| src/sanctions.lua | 437 | `giveBack` |
| src/sanctions.lua | 495 | `lap` |
| src/sanctions.lua | 515 | `resume` |
| src/sanctions.lua | 531 | `M.update` |
| src/sanctions.lua | 612 | `better` |
| src/sanctions.lua | 619 | `classify` |
| src/sanctions.lua | 627 | `(anonymous)` |
| src/sanctions.lua | 644 | `M.watch` |
| src/sanctions.lua | 664 | `M.position` |
| src/sanctions.lua | 666 | `M.serialize` |
| src/sanctions.lua | 677 | `M.restore` |
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
| src/snapshot.lua | 130 | `simRead` |
| src/snapshot.lua | 151 | `(anonymous)` |
| src/snapshot.lua | 155 | `raceRead` |
| src/snapshot.lua | 163 | `conflictingApp` |
| src/snapshot.lua | 172 | `wearRead` |
| src/snapshot.lua | 186 | `tyres` |
| src/snapshot.lua | 210 | `M.read` |
| src/snapshot.lua | 233 | `(anonymous)` |
| src/snapshot.lua | 245 | `(anonymous)` |
| src/snapshot.lua | 284 | `M.zones` |
| src/snapshot.lua | 299 | `utf8Char` |
| src/snapshot.lua | 304 | `jsonName` |
| src/snapshot.lua | 324 | `carName` |
| src/snapshot.lua | 335 | `M.carLoader` |
| src/snapshot.lua | 336 | `byName` |
| src/snapshot.lua | 337 | `M.carStep` |
| src/snapshot.lua | 339 | `(anonymous)` |
| src/snapshot.lua | 347 | `(anonymous)` |
| src/snapshot.lua | 368 | `menuVisible` |
| src/snapshot.lua | 369 | `M.menu` |
| src/strategy.lua | 16 | `car` |
| src/strategy.lua | 30 | `clear` |
| src/strategy.lua | 31 | `M.new` |
| src/strategy.lua | 38 | `M.reset` |
| src/strategy.lua | 46 | `M.forget` |
| src/strategy.lua | 47 | `M.rebase` |
| src/strategy.lua | 57 | `render` |
| src/strategy.lua | 64 | `rebuild` |
| src/strategy.lua | 71 | `event` |
| src/strategy.lua | 77 | `relang` |
| src/strategy.lua | 83 | `wearOf` |
| src/strategy.lua | 87 | `name` |
| src/strategy.lua | 92 | `wearUse` |
| src/strategy.lua | 93 | `probe` |
| src/strategy.lua | 110 | `lapsLeft` |
| src/strategy.lua | 120 | `plan` |
| src/strategy.lua | 166 | `eligible` |
| src/strategy.lua | 170 | `want` |
| src/strategy.lua | 180 | `rivals` |
| src/strategy.lua | 206 | `outLap` |
| src/strategy.lua | 248 | `failure` |
| src/strategy.lua | 292 | `M.update` |
| src/strategy.lua | 458 | `M.serialize` |
| src/strategy.lua | 465 | `M.restore` |
| src/traffic.lua | 5 | `M.new` |
| src/traffic.lua | 24 | `M.mode` |
| src/traffic.lua | 28 | `identity` |
| src/traffic.lua | 31 | `check` |
| src/traffic.lua | 49 | `plan` |
| src/traffic.lua | 69 | `(anonymous)` |
| src/traffic.lua | 126 | `M.exits` |
| src/traffic.lua | 179 | `M.update` |
| src/ui.lua | 23 | `idOf` |
| src/ui.lua | 32 | `fmt` |
| src/ui.lua | 40 | `wrap` |
| src/ui.lua | 42 | `number` |
| src/ui.lua | 46 | `shown` |
| src/ui.lua | 51 | `wrapAll` |
| src/ui.lua | 52 | `globalTips` |
| src/ui.lua | 72 | `ruleView` |
| src/ui.lua | 75 | `ruleCategoryOf` |
| src/ui.lua | 82 | `texts` |
| src/ui.lua | 101 | `same` |
| src/ui.lua | 101 | `(anonymous)` |
| src/ui.lua | 103 | `(anonymous)` |
| src/ui.lua | 115 | `M.new` |
| src/ui.lua | 135 | `(anonymous)` |
| src/ui.lua | 145 | `text` |
| src/ui.lua | 149 | `fontsOnce` |
| src/ui.lua | 153 | `mark` |
| src/ui.lua | 155 | `groupDigits` |
| src/ui.lua | 164 | `loadedHere` |
| src/ui.lua | 176 | `touch` |
| src/ui.lua | 179 | `presetTarget` |
| src/ui.lua | 188 | `loadBuiltin` |
| src/ui.lua | 205 | `builtinActive` |
| src/ui.lua | 229 | `carDatabase` |
| src/ui.lua | 256 | `input` |
| src/ui.lua | 281 | `valueText` |
| src/ui.lua | 289 | `intText` |
| src/ui.lua | 294 | `shortLabel` |
| src/ui.lua | 296 | `modified` |
| src/ui.lua | 301 | `segmentFits` |
| src/ui.lua | 314 | `toggleOpts` |
| src/ui.lua | 324 | `settingControl` |
| src/ui.lua | 398 | `hiddenNote` |
| src/ui.lua | 410 | `groupHeight` |
| src/ui.lua | 423 | `drawGroup` |
| src/ui.lua | 452 | `split` |
| src/ui.lua | 469 | `groupColumns` |
| src/ui.lua | 483 | `ruleBlock` |
| src/ui.lua | 533 | `safetyBlock` |
| src/ui.lua | 616 | `patternBlock` |
| src/ui.lua | 678 | `globalSwitch` |
| src/ui.lua | 685 | `globalChoice` |
| src/ui.lua | 693 | `globalSlider` |
| src/ui.lua | 711 | `choiceHead` |
| src/ui.lua | 719 | `globalBlock` |
| src/ui.lua | 773 | `statusLines` |
| src/ui.lua | 812 | `switchList` |
| src/ui.lua | 828 | `cspStatus` |
| src/ui.lua | 835 | `flagsNext` |
| src/ui.lua | 836 | `overlayBlock` |
| src/ui.lua | 893 | `lightsPhase` |
| src/ui.lua | 899 | `lightsStatus` |
| src/ui.lua | 919 | `legendRows` |
| src/ui.lua | 934 | `lightsLegend` |
| src/ui.lua | 964 | `activeFor` |
| src/ui.lua | 987 | `resetSection` |
| src/ui.lua | 1002 | `sectionsOn` |
| src/ui.lua | 1004 | `modifiedCount` |
| src/ui.lua | 1011 | `sectionContent` |
| src/ui.lua | 1041 | `language` |
| src/ui.lua | 1050 | `updateAct` |
| src/ui.lua | 1060 | `megabytes` |
| src/ui.lua | 1062 | `updateText` |
| src/ui.lua | 1095 | `updateBlock` |
| src/ui.lua | 1188 | `aiCars` |
| src/ui.lua | 1196 | `stateKey` |
| src/ui.lua | 1208 | `live` |
| src/ui.lua | 1211 | `sessionKind` |
| src/ui.lua | 1219 | `headerBar` |
| src/ui.lua | 1357 | `banner` |
| src/ui.lua | 1378 | `addWarning` |
| src/ui.lua | 1381 | `currentSignature` |
| src/ui.lua | 1387 | `entrySignature` |
| src/ui.lua | 1394 | `openTarget` |
| src/ui.lua | 1400 | `kpi` |
| src/ui.lua | 1412 | `homeTab` |
| src/ui.lua | 1680 | `sectionPane` |
| src/ui.lua | 1746 | `settingsTab` |
| src/ui.lua | 1799 | `ruleRow` |
| src/ui.lua | 1808 | `rulesTab` |
| src/ui.lua | 1873 | `raceRows` |
| src/ui.lua | 1881 | `aiRaceBlock` |
| src/ui.lua | 1892 | `diagnosticTab` |
| src/ui.lua | 2151 | `M.compactSize` |
| src/ui.lua | 2154 | `windowSetup` |
| src/ui.lua | 2174 | `lower` |
| src/ui.lua | 2194 | `drawWindow` |
| src/ui.lua | 2204 | `M.where` |
| src/ui.lua | 2209 | `M.main` |
| src/ui.lua | 2240 | `faded` |
| src/ui.lua | 2241 | `panelPalette` |
| src/ui.lua | 2271 | `box` |
| src/ui.lua | 2275 | `write` |
| src/ui.lua | 2285 | `font` |
| src/ui.lua | 2293 | `fontRelease` |
| src/ui.lua | 2296 | `textWidth` |
| src/ui.lua | 2312 | `fitSize` |
| src/ui.lua | 2321 | `rect4` |
| src/ui.lua | 2322 | `M.flagLayout` |
| src/ui.lua | 2358 | `quad` |
| src/ui.lua | 2363 | `cutBack` |
| src/ui.lua | 2370 | `drsBadge` |
| src/ui.lua | 2375 | `updateCode` |
| src/ui.lua | 2380 | `infractionText` |
| src/ui.lua | 2385 | `badge` |
| src/ui.lua | 2392 | `checker` |
| src/ui.lua | 2396 | `diagonal` |
| src/ui.lua | 2402 | `meatball` |
| src/ui.lua | 2408 | `stripes` |
| src/ui.lua | 2413 | `startLights` |
| src/ui.lua | 2421 | `deltaText` |
| src/ui.lua | 2431 | `deltaBox` |
| src/ui.lua | 2442 | `placeBox` |
| src/ui.lua | 2451 | `blueBox` |
| src/ui.lua | 2463 | `pillsWidth` |
| src/ui.lua | 2465 | `pillRow` |
| src/ui.lua | 2483 | `pill` |
| src/ui.lua | 2490 | `giveBackText` |
| src/ui.lua | 2494 | `blueText` |
| src/ui.lua | 2500 | `lightsCode` |
| src/ui.lua | 2507 | `placeText` |
| src/ui.lua | 2522 | `M.overlayParts` |
| src/ui.lua | 2545 | `M.overlayHeight` |
| src/ui.lua | 2555 | `sessionStrip` |
| src/ui.lua | 2599 | `flags` |
| src/ui.lua | 2714 | `M.flags` |
| src/ui.lua | 2722 | `nativeBox` |
| src/ui.lua | 2726 | `M.restoreNative` |
| src/ui.lua | 2727 | `screenSize` |
| src/ui.lua | 2730 | `hudContent` |
| src/ui.lua | 2765 | `M.hud` |
| src/ui.lua | 2784 | `(anonymous)` |
| src/update.lua | 40 | `M.version` |
| src/update.lua | 47 | `M.label` |
| src/update.lua | 49 | `M.newer` |
| src/update.lua | 55 | `str` |
| src/update.lua | 56 | `starts` |
| src/update.lua | 58 | `M.cut` |
| src/update.lua | 65 | `M.notes` |
| src/update.lua | 79 | `M.release` |
| src/update.lua | 101 | `M.digest` |
| src/update.lua | 109 | `safe` |
| src/update.lua | 119 | `M.content` |
| src/update.lua | 130 | `M.files` |
| src/update.lua | 137 | `M.requires` |
| src/update.lua | 153 | `M.manifestVersion` |
| src/update.lua | 158 | `M.stopped` |
| src/update.lua | 164 | `M.new` |
| src/update.lua | 169 | `event` |
| src/update.lua | 175 | `M.take` |
| src/update.lua | 182 | `M.busy` |
| src/update.lua | 189 | `fail` |
| src/update.lua | 195 | `parse` |
| src/update.lua | 204 | `M.parseReport` |
| src/update.lua | 216 | `bootCheck` |
| src/update.lua | 237 | `M.recover` |
| src/update.lua | 288 | `(anonymous)` |
| src/update.lua | 289 | `(anonymous)` |
| src/update.lua | 290 | `(anonymous)` |
| src/update.lua | 291 | `(anonymous)` |
| src/update.lua | 292 | `(anonymous)` |
| src/update.lua | 293 | `(anonymous)` |
| src/update.lua | 294 | `(anonymous)` |
| src/update.lua | 295 | `(anonymous)` |
| src/update.lua | 296 | `M.recoverText` |
| src/update.lua | 303 | `M.start` |
| src/update.lua | 334 | `M.tidy` |
| src/update.lua | 342 | `live` |
| src/update.lua | 344 | `M.check` |
| src/update.lua | 348 | `(anonymous)` |
| src/update.lua | 362 | `M.cancel` |
| src/update.lua | 370 | `place` |
| src/update.lua | 400 | `M.install` |
| src/update.lua | 412 | `(anonymous)` |
| src/update.lua | 417 | `(anonymous)` |
| src/update.lua | 425 | `(anonymous)` |
| src/update.lua | 428 | `(anonymous)` |
| src/update.lua | 441 | `M.rollback` |
| src/update.lua | 451 | `M.tick` |
| src/update.lua | 478 | `M.reported` |
| src/update.lua | 479 | `M.view` |
| src/update.lua | 498 | `M.fresh` |
| src/update.lua | 505 | `M.offered` |
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
| src/widgets.lua | 57 | `forget` |
| src/widgets.lua | 59 | `W.setFonts` |
| src/widgets.lua | 64 | `W.fonts` |
| src/widgets.lua | 67 | `use` |
| src/widgets.lua | 74 | `release` |
| src/widgets.lua | 76 | `level` |
| src/widgets.lua | 78 | `role` |
| src/widgets.lua | 82 | `W.upper` |
| src/widgets.lua | 92 | `vec` |
| src/widgets.lua | 98 | `W.point` |
| src/widgets.lua | 103 | `W.begin` |
| src/widgets.lua | 116 | `W.frame` |
| src/widgets.lua | 117 | `W.rect` |
| src/widgets.lua | 121 | `W.frameRect` |
| src/widgets.lua | 125 | `W.line` |
| src/widgets.lua | 126 | `W.circle` |
| src/widgets.lua | 128 | `canQuad` |
| src/widgets.lua | 133 | `W.quad` |
| src/widgets.lua | 142 | `W.tri` |
| src/widgets.lua | 149 | `W.para` |
| src/widgets.lua | 154 | `W.panel` |
| src/widgets.lua | 160 | `W.text` |
| src/widgets.lua | 164 | `count` |
| src/widgets.lua | 165 | `width` |
| src/widgets.lua | 176 | `fitted` |
| src/widgets.lua | 195 | `tail` |
| src/widgets.lua | 204 | `W.shrink` |
| src/widgets.lua | 208 | `W.cell` |
| src/widgets.lua | 210 | `W.right` |
| src/widgets.lua | 212 | `W.lines` |
| src/widgets.lua | 229 | `W.paragraph` |
| src/widgets.lua | 235 | `W.lineHeight` |
| src/widgets.lua | 237 | `inside` |
| src/widgets.lua | 247 | `W.help` |
| src/widgets.lua | 252 | `hashId` |
| src/widgets.lua | 256 | `W.hit` |
| src/widgets.lua | 265 | `W.mouseX` |
| src/widgets.lua | 267 | `W.marker` |
| src/widgets.lua | 272 | `bar` |
| src/widgets.lua | 276 | `W.heading` |
| src/widgets.lua | 290 | `W.label` |
| src/widgets.lua | 291 | `W.labelWidth` |
| src/widgets.lua | 294 | `W.titleFit` |
| src/widgets.lua | 303 | `buttonStyle` |
| src/widgets.lua | 315 | `W.button` |
| src/widgets.lua | 338 | `W.link` |
| src/widgets.lua | 345 | `W.linkWidth` |
| src/widgets.lua | 347 | `W.icon` |
| src/widgets.lua | 363 | `W.switchShape` |
| src/widgets.lua | 369 | `W.switch` |
| src/widgets.lua | 379 | `W.toggleHeight` |
| src/widgets.lua | 380 | `W.toggle` |
| src/widgets.lua | 398 | `chipStyle` |
| src/widgets.lua | 403 | `W.chipWidth` |
| src/widgets.lua | 404 | `W.chip` |
| src/widgets.lua | 409 | `W.chipRight` |
| src/widgets.lua | 411 | `W.dotChipWidth` |
| src/widgets.lua | 412 | `W.dotChip` |
| src/widgets.lua | 422 | `W.choiceIds` |
| src/widgets.lua | 428 | `W.segment` |
| src/widgets.lua | 468 | `W.segmentFits` |
| src/widgets.lua | 474 | `W.cycle` |
| src/widgets.lua | 487 | `W.tile` |
| src/widgets.lua | 506 | `W.row` |
| src/widgets.lua | 517 | `W.nav` |
| src/widgets.lua | 529 | `W.slider` |
| src/widgets.lua | 553 | `W.pm` |
| src/widgets.lua | 563 | `W.inputFrame` |
| src/widgets.lua | 570 | `W.message` |
| src/widgets.lua | 582 | `W.scroll` |
| src/widgets.lua | 608 | `W.clip` |
| src/widgets.lua | 615 | `W.visible` |
| src/widgets.lua | 621 | `tipColors` |
| src/widgets.lua | 632 | `W.finish` |
| src/widgets.lua | 644 | `W.step` |
| src/zones.lua | 6 | `M.parse` |
| src/zones.lua | 9 | `skip` |
| src/zones.lua | 17 | `token` |
| src/zones.lua | 18 | `value` |
| src/zones.lua | 67 | `M.at` |
| src/zones.lua | 77 | `M.export` |
