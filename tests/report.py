"""Factual report: open criteria are never turned into a pass."""
from pathlib import Path
import hashlib
import json
import platform
from test_pdr import APP, VERSION

def read(name):
    return json.loads((APP/'tests'/name).read_text(encoding='utf-8'))

def main():
    scenarios=read('results.json')
    integration=read('integration-results.json')
    soak=read('soak-results.json')
    assert soak.get('version')==VERSION, 'The soak of the current version must be finished before the report.'
    source=[APP/'ACAdvancedIA.lua',APP/'manifest.ini',*sorted((APP/'src').glob('*.lua'))]
    hashes={p.relative_to(APP).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in source}
    assert soak['sources']==hashes, 'Sources changed since the soak started.'
    previous=read('performance-previous-results.json')
    current=read('performance-current-results.json')
    assert current.get('version')==VERSION and previous.get('version')!=VERSION and not previous['profiling'] and not current['profiling']
    assert current['sources']=={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (APP/'src').glob('*.lua')}
    old_name=previous['version']
    comparison=[f'| AI | Mean {old_name} / {VERSION} (ms) | P99 {old_name} / {VERSION} (ms) | Raw peak {old_name} / {VERSION} (ms) |','|---|---|---|---|']
    for old,new in zip(previous['results'],current['results'],strict=True):
        assert old['ai']==new['ai'] and old['frames']==new['frames']==30000 and old['errors']==new['errors']==0
        comparison.append(f"| {new['ai']} | {old['meanMs']:.3f} / {new['meanMs']:.3f} | {old['p99Ms']:.3f} / {new['p99Ms']:.3f} | {old['peakMs']:.3f} / {new['peakMs']:.3f} |")
    lint=(APP/'tests/lint-results.txt').read_text(encoding='utf-8')
    result={
        'version':VERSION,'accepted':False,
        'soakScope':'Eight simulated hours of the core (track day, 40 AI, weather and spacing), then one hour of a race with racing rules (neutralisations, delta time, DRS, driving mistakes); SDK calls and interface simulated separately.',
        'scenarios':{'total':len(scenarios),'passed':sum(x['ok'] for x in scenarios.values()),'catalog':78,'fuzzSteps':10000},
        'integration':{'ok':integration['ok'],'cases':len(integration['cases'])},
        'lint':{'ok':'aucune globale' in lint,'runtimeFiles':len(source)-1},
        'soak':soak,
        'openCriteria':['Physical tests in the game and real CSP cost'],
        'platform':{'python':platform.python_version(),'system':platform.system(),'architecture':platform.machine()},
        'sources':hashes,
        'comparison':{'previous':previous,'current':current},
    }
    if not soak['meanCriterion']: result['openCriteria'].append('Core mean cost <0.3 ms')
    if not soak['peakCriterion']: result['openCriteria'].append('Core raw peak <1 ms')
    if not soak.get('memoryCriterion',True): result['openCriteria'].append('Total bench memory variation <256 KiB')
    (APP/'docs/RELEASE_STATUS.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    text=f'''# Release measurements

Released version: {result['version']}. All strict PDR criteria accepted: **no**, open points below. These results are not a guarantee of in-game FPS.

- Catalogue and checks: **{result['scenarios']['passed']}/{len(scenarios)}**, including the 78 PDR situations and the 10,000-step fuzz.
- Integration: **{result['integration']['cases']} cases**, status {integration['ok']}.
- Linter: {result['lint']['runtimeFiles']} files, status {result['lint']['ok']}.
- Soak: {soak['frames']:,} frames, {soak['simulatedHours']} simulated hours, {soak['ai']} AI, {soak['errors']} errors.
- Memory after collection: {soak['memoryMinKB']:.1f} to {soak['memoryMaxKB']:.1f} KiB; drift {soak['memoryDriftKB']:.1f} KiB after the bench warm-up phase.
- Strict bench memory criterion (<256 KiB over the whole window): **{soak.get('memoryCriterion',True)}**. Drift during the last hour: **{soak.get('memoryLastHourDriftKB',0):.1f} KiB**. The total variation is kept even when the last hour is more stable.
- Core at {soak['benchmarkAI']} AI: mean **{soak['meanMs']:.3f} ms**, P99 **{soak['p99Ms']:.3f} ms**, raw maximum **{soak['peakMs']:.3f} ms** over {soak['benchmarkFrames']:,} frames.
- Mean <0.3 ms: **{soak['meanCriterion']}**. Maximum <1 ms: **{soak['peakCriterion']}**.

The maximum is not filtered. This benchmark includes neither the real SDK nor the UI. The kinematic tests do not certify the physical driving.

Comparison with {old_name}: same load (track day, multi-class, weather), 30,000 frames measured after warm-up, independent VMs, no profiler, each version measured by its own bench on the same machine. The {VERSION} bench enables the same JIT compiler cache as the app in the game (the `compilateur JIT` log line confirms that CSP accepts it); the {old_name} bench did not.

{chr(10).join(comparison)}

Run-to-run variability (10 to 40%) forbids turning these figures into a guaranteed FPS gain. The separate benchmark and the one after the soak have different VM histories and are shown separately.

Integration also covers wet/dry compounds, pit stops, compensation without rain tyres and the priority of native rain handling. The real cost of CSP calls, the driving and the GPU/CPU FPS remain to be observed in the game. The native counter of the diagnostics includes the adapters but not the drawing of the windows.

Open criteria: {"; ".join(result['openCriteria'])}.

The exact source hashes and the structured results are in `RELEASE_STATUS.json`.
'''
    (APP/'docs/MESURES.md').write_text(text,encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k not in {'sources','comparison'}},ensure_ascii=False,indent=2))

if __name__=='__main__': main()
