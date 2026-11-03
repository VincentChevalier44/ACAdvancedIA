# Release measurements

Released version: Beta 1.35. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **439/439**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **109 cases**, status True.
- Linter: 38 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 8762.3 to 9809.3 KiB; drift 1047.0 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **24.9 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.134 ms**, P99 **0.266 ms**, raw maximum **0.523 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **True**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.34: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. The Beta 1.35 bench enables the same JIT compiler cache as the app in the game (the `compilateur JIT` log line confirms that CSP accepts it); the Beta 1.34 bench did not.

| AI | Mean Beta 1.34 / Beta 1.35 (ms) | P99 Beta 1.34 / Beta 1.35 (ms) | Raw peak Beta 1.34 / Beta 1.35 (ms) |
|---|---|---|---|
| 9 | 0.048 / 0.041 | 0.117 / 0.106 | 0.344 / 0.359 |
| 30 | 0.231 / 0.197 | 0.466 / 0.413 | 1.045 / 0.934 |
| 60 | 0.594 / 0.511 | 1.151 / 1.012 | 1.793 / 1.478 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
