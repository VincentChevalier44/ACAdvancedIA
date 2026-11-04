"""Empreinte de référence de la course complète de la Beta 1.42 (tests/race142.lua) : stratégie, sanctions, aspiration,
pneus et pannes joués ensemble. Comparer deux versions : lancer ce script dans chacune puis comparer les fichiers
golden142-results.txt."""
from test_pdr import runtime, APP

def main():
    lua = runtime()
    run = lua.execute("return require('tests/race142')")
    summary = run()[0]
    (APP / 'tests' / 'golden142-results.txt').write_text(summary + '\n', encoding='utf-8')
    print(summary)

if __name__ == '__main__':
    main()
