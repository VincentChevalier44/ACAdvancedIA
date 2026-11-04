# Release measurements

Released version: Beta 1.48. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **625/625**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **129 cases**, status True.
- Linter: 45 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 9806.7 to 10866.9 KiB; drift 1060.2 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **14.6 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.176 ms**, P99 **0.337 ms**, raw maximum **1.031 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **False**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.47: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. Both benches enable the same JIT compiler cache as the app in the game (since Beta 1.40; the `compilateur JIT` log line confirms that CSP accepts it).

| AI | Mean Beta 1.47 / Beta 1.48 (ms) | P99 Beta 1.47 / Beta 1.48 (ms) | Raw peak Beta 1.47 / Beta 1.48 (ms) |
|---|---|---|---|
| 9 | 0.053 / 0.055 | 0.125 / 0.130 | 0.402 / 0.319 |
| 30 | 0.249 / 0.254 | 0.470 / 0.473 | 3.263 / 2.612 |
| 60 | 0.637 / 0.644 | 1.084 / 1.066 | 3.301 / 2.044 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Core raw peak <1 ms; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
