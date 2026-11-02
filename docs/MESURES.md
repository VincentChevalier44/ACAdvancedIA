# Release measurements

Released version: Beta 1.27. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **374/374**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **90 cases**, status True.
- Linter: 33 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 7620.5 to 8429.0 KiB; drift 808.6 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **20.9 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.145 ms**, P99 **0.333 ms**, raw maximum **6.309 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **False**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.26: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. The Beta 1.27 bench enables the same JIT compiler cache as the app in the game (the `compilateur JIT` log line confirms that CSP accepts it); the Beta 1.26 bench did not.

| AI | Mean Beta 1.26 / Beta 1.27 (ms) | P99 Beta 1.26 / Beta 1.27 (ms) | Raw peak Beta 1.26 / Beta 1.27 (ms) |
|---|---|---|---|
| 9 | 0.044 / 0.040 | 0.119 / 0.103 | 2.006 / 0.439 |
| 30 | 0.208 / 0.199 | 0.479 / 0.449 | 10.934 / 3.317 |
| 60 | 0.571 / 0.527 | 1.308 / 1.026 | 10.640 / 7.016 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Core raw peak <1 ms; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
