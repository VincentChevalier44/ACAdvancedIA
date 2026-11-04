# Release measurements

Released version: Beta 1.44. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **587/587**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **124 cases**, status True.
- Linter: 42 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 9882.1 to 11293.9 KiB; drift 1411.8 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **30.0 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.157 ms**, P99 **0.294 ms**, raw maximum **0.678 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **True**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.43: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. Both benches enable the same JIT compiler cache as the app in the game (since Beta 1.40; the `compilateur JIT` log line confirms that CSP accepts it).

| AI | Mean Beta 1.43 / Beta 1.44 (ms) | P99 Beta 1.43 / Beta 1.44 (ms) | Raw peak Beta 1.43 / Beta 1.44 (ms) |
|---|---|---|---|
| 9 | 0.054 / 0.057 | 0.145 / 0.136 | 0.979 / 0.421 |
| 30 | 0.265 / 0.261 | 0.692 / 0.516 | 7.103 / 1.645 |
| 60 | 0.644 / 0.640 | 1.466 / 1.111 | 12.956 / 2.649 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
