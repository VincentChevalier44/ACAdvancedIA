# Release measurements

Released version: Beta 1.42. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **560/560**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **123 cases**, status True.
- Linter: 42 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 8363.7 to 9438.2 KiB; drift 1074.5 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **49.4 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.165 ms**, P99 **0.294 ms**, raw maximum **0.739 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **True**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.41: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. Both benches enable the same JIT compiler cache as the app in the game (since Beta 1.40; the `compilateur JIT` log line confirms that CSP accepts it).

| AI | Mean Beta 1.41 / Beta 1.42 (ms) | P99 Beta 1.41 / Beta 1.42 (ms) | Raw peak Beta 1.41 / Beta 1.42 (ms) |
|---|---|---|---|
| 9 | 0.046 / 0.049 | 0.110 / 0.120 | 0.322 / 0.446 |
| 30 | 0.209 / 0.217 | 0.366 / 0.389 | 0.903 / 0.955 |
| 60 | 0.549 / 0.556 | 0.932 / 0.910 | 1.529 / 1.570 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
