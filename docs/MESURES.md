# Release measurements

Released version: Beta 1.39. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **449/449**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **121 cases**, status True.
- Linter: 38 files, status True.
- Soak: 1,728,000 frames, 8 simulated hours, 40 AI, 0 errors.
- Memory after collection: 8297.8 to 9436.9 KiB; drift 1139.1 KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **False**. Drift during the last hour: **19.8 KiB**. The total variation is kept even when the last hour is more stable.
- Core at 30 AI: mean **0.158 ms**, P99 **0.333 ms**, raw maximum **1.496 ms** over 30,000 frames.
- Mean <0.3 ms: **True**. Maximum <1 ms: **False**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with Beta 1.38: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. The Beta 1.39 bench enables the same JIT compiler cache as the app in the game (the `compilateur JIT` log line confirms that CSP accepts it); the Beta 1.38 bench did not.

| AI | Mean Beta 1.38 / Beta 1.39 (ms) | P99 Beta 1.38 / Beta 1.39 (ms) | Raw peak Beta 1.38 / Beta 1.39 (ms) |
|---|---|---|---|
| 9 | 0.048 / 0.049 | 0.128 / 0.153 | 2.299 / 0.995 |
| 30 | 0.238 / 0.220 | 0.511 / 0.542 | 2.965 / 5.330 |
| 60 | 0.629 / 0.593 | 1.271 / 1.392 | 6.625 / 21.634 |

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: Physical tests in the game and real CSP cost; Core raw peak <1 ms; Total bench memory variation <256 KiB.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
