# Release measurements

Released version: Beta 1.36. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **444/444**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **113 cases**, status True.
- Linter: 38 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 7679.7 to 8697.9 KiB; drift 1018.2 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **18.2 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.137 ms**, P99 **0.308 ms**, raw maximum **0.608 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **True**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.35: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. The Beta 1.36 bench enables the same JIT compiler cache as the app in the game (the `compilateur JIT` log line confirms that CSP accepts it); the Beta 1.35 bench did not.

| AI | Mean Beta 1.35 / Beta 1.36 (ms) | P99 Beta 1.35 / Beta 1.36 (ms) | Raw peak Beta 1.35 / Beta 1.36 (ms) |
|---|---|---|---|
| 9 | 0.043 / 0.046 | 0.121 / 0.134 | 1.625 / 2.304 |
| 30 | 0.208 / 0.208 | 0.477 / 0.501 | 5.562 / 5.183 |
| 60 | 0.569 / 0.549 | 1.175 / 1.222 | 3.689 / 3.744 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
