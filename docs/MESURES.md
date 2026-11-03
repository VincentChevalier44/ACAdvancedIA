# Release measurements

Released version: Beta 1.37. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **448/448**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **115 cases**, status True.
- Linter: 38 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 8130.0 to 9315.2 KiB; drift 1185.2 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **29.9 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.140 ms**, P99 **0.296 ms**, raw maximum **0.827 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **True**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.36: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. The Beta 1.37 bench enables the same JIT compiler cache as the app in the game (the `compilateur JIT` log line confirms that CSP accepts it); the Beta 1.36 bench did not.

| AI | Mean Beta 1.36 / Beta 1.37 (ms) | P99 Beta 1.36 / Beta 1.37 (ms) | Raw peak Beta 1.36 / Beta 1.37 (ms) |
|---|---|---|---|
| 9 | 0.050 / 0.042 | 0.146 / 0.118 | 1.807 / 0.444 |
| 30 | 0.234 / 0.205 | 0.500 / 0.462 | 6.508 / 1.668 |
| 60 | 0.630 / 0.528 | 1.335 / 1.116 | 15.135 / 5.644 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
