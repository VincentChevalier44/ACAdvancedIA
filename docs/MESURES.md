# Release measurements

Released version: Beta 1.47. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **621/621**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **127 cases**, status True.
- Linter: 45 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 10199.7 to 11309.2 KiB; drift 1109.5 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **14.7 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.157 ms**, P99 **0.291 ms**, raw maximum **0.952 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **True**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.46: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. Both benches enable the same JIT compiler cache as the app in the game (since Beta 1.40; the `compilateur JIT` log line confirms that CSP accepts it).

| AI | Mean Beta 1.46 / Beta 1.47 (ms) | P99 Beta 1.46 / Beta 1.47 (ms) | Raw peak Beta 1.46 / Beta 1.47 (ms) |
|---|---|---|---|
| 9 | 0.053 / 0.057 | 0.137 / 0.140 | 0.552 / 0.375 |
| 30 | 0.232 / 0.257 | 0.442 / 0.474 | 1.094 / 1.035 |
| 60 | 0.595 / 0.667 | 1.003 / 1.160 | 1.824 / 4.709 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
