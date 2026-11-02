"""Empreintes de référence (tests/golden.lua) : journée circuit 30 IA, course réglée 30 et 60 IA. Comparer deux
versions : lancer ce script dans chacune puis comparer les fichiers golden-results.txt. Un nettoyage de code doit
laisser les empreintes identiques."""
from test_pdr import runtime, APP

SCENARIOS = [('track', 30, 20000, 5000), ('rules', 30, 40000, 10000), ('rules', 60, 12000, 3000)]

def main():
    lua = runtime()
    run = lua.execute((APP / 'tests/golden.lua').read_text(encoding='utf-8'))
    lines = [run(*scenario) for scenario in SCENARIOS]
    (APP / 'tests' / 'golden-results.txt').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print('\n'.join(lines))

if __name__ == '__main__':
    main()
