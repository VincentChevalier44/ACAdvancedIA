"""Traceable inventory of settings and functions, without claiming to prove CSP physics."""
import hashlib
import json
import re
from test_pdr import APP, runtime, VERSION
from luaparser import ast
from luaparser.astnodes import Function, LocalFunction, Method, AnonymousFunction


def main():
    lua = runtime()
    config = lua.eval("require('src/config')")
    english = lua.eval("require('src/lang_en')")
    files = [APP/'ACAdvancedIA.lua', *sorted((APP/'src').glob('*.lua'))]
    sources = {p: p.read_text(encoding='utf-8') for p in files}
    functions = []
    for path, source in sources.items():
        for node in ast.walk(ast.parse(source)):
            if isinstance(node, (Function, LocalFunction, Method, AnonymousFunction)):
                name = ast.to_lua_source(node.name).strip() if hasattr(node, 'name') else '(anonymous)'
                functions.append({'file': path.relative_to(APP).as_posix(),
                                  'line': node._first_token.line, 'name': name})

    def consumers(key):
        found = []
        for path, source in sources.items():
            if path.name in {'config.lua', 'ui.lua', 'lang.lua', 'presets.lua', 'tips.lua'}:
                continue
            for line, text in enumerate(source.splitlines(), 1):
                if re.search(r'\b'+re.escape(key)+r'\b', text):
                    found.append(f'{path.relative_to(APP).as_posix()}:{line}')
        return found

    rows = []
    for s in config['schema'].values():
        key = s['key']
        refs = consumers(key)
        assert refs, f'No runtime consumer for {key}'
        choices = list(s['choices'].values()) if s['choices'] else None
        defaults = {p: s['defaults'][p] for p in ['J', 'P', 'Q', 'C']}
        label = english['labels'][key] if english['labels'] and english['labels'][key] else s['label']
        rows.append({'key': key, 'label': label, 'group': s['group'],
                     'min': s['min'], 'max': s['max'], 'choices': choices,
                     'defaults': defaults, 'consumers': refs})
    assert len({r['key'] for r in rows}) == len(rows)
    global_keys = ['levelMode', 'useGripBoost', 'gripPerLevelPct', 'useBrakeAssist', 'overrideAwareness',
                   'occLatMin', 'occLatMax', 'occMargin', 'occSpeedGain', 'seed', 'debugLog']
    globals_rows = []
    for key in global_keys:
        refs = consumers(key)
        assert refs, f'No runtime consumer for global {key}'
        bounds = config['globalBounds'][key]
        choices = config['globalChoices'][key]
        globals_rows.append({'key': key, 'default': config['globalDefaults'][key],
                             'bounds': list(bounds.values()) if bounds else None,
                             'choices': list(choices.values()) if choices else None, 'consumers': refs})
    result = {'version': VERSION, 'scope': 'Static inventory + UI/storage checks and engine bounds; no physical certification.',
              'globalParameters': globals_rows,
              'parameters': rows, 'functions': sorted(functions, key=lambda r: (r['file'], r['line'])),
              'sources': {p.relative_to(APP).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}}
    (APP/'docs/PARAMETER_AUDIT.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
    lines = [f'# Settings and functions inventory {VERSION}', '',
             'This inventory links every declared parameter to its consumers. A static reference shows a connection, not proof of a physical result. The `PARAMETER_BOUNDARY_ENGINE` tests and the two full walks through the interface complete this trace.', '',
             '| Section | Parameter | Range | Default J / P / Q / C | Consumers |',
             '|---|---|---|---|---|']
    def show(value):
        return str(value).lower() if isinstance(value, bool) else str(value)
    for r in rows:
        domain = ', '.join(r['choices']) if r['choices'] else (f"{r['min']} to {r['max']}" if r['min'] is not None else 'boolean')
        defaults = ' / '.join(show(r['defaults'][p]) for p in ['J', 'P', 'Q', 'C'])
        lines.append(f"| {r['group']} | `{r['key']}` — {r['label']} | {domain} | {defaults} | {', '.join(r['consumers'])} |")
    lines += ['', '## Adjustable global options', '',
              '| Key | Default | Range | Consumers |', '|---|---|---|---|']
    for r in globals_rows:
        domain = ', '.join(r['choices']) if r['choices'] else (str(r['bounds']) if r['bounds'] else 'boolean')
        lines.append(f"| `{r['key']}` | {show(r['default'])} | {domain} | {', '.join(r['consumers'])} |")
    lines += ['', 'The section switches go through `C.on`/`C.effective` and are walked by the interface tests. `classPatterns` uses the `C.patterns` parser, `Classes.configure/update`, the eight dedicated rows and validated storage. The manual/automatic choice, the main button, panic, presets and the diagnostics tools are examined in AUDIT_V1.md.', '',
              '## Functions examined', '',
              f'List taken from the AST of the {len(files)} active files, including local and anonymous functions. The review, fixes and limits are in AUDIT_V1.md. This list does not mean 100% branch coverage.', '',
              '| File | Line | Function |', '|---|---|---|']
    for row in result['functions']:
        lines.append(f"| {row['file']} | {row['line']} | `{row['name']}` |")
    (APP/'docs/PARAMETER_AUDIT.md').write_text('\n'.join(lines)+'\n', encoding='utf-8')
    print(f"{len(rows)} profile + {len(globals_rows)} global parameters with runtime consumers; {len(functions)} functions inventoried; {len(files)} runtime files")


if __name__ == '__main__':
    main()
