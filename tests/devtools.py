"""Outils de développement (hors jeu) : édition qui conserve les fins de ligne, comparaison d'arborescences,
sauvegarde et installation jeu fermé.

  python devtools.py tree <dossier A> <dossier B>
  python devtools.py install <dossier préparé> <copie de référence de l'app installée> <version installée> <nouvelle version>

L'installation refuse si Assetto Corsa tourne, sauvegarde l'app et les réglages dans _ACAdvancedIA_archives, copie
les fichiers changés, puis vérifie la copie."""
import hashlib
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

GAME = Path('D:/SteamLibrary/steamapps/common/assettocorsa')
LIVE = GAME / 'apps/lua/ACAdvancedIA'
ARCHIVES = GAME / '_ACAdvancedIA_archives'
SETTINGS = Path.home() / 'Documents/Assetto Corsa/cfg/extension/state/lua/app'
SKIP = {'__pycache__'}


def edit(path, old, new, count=1):
    """Remplace old par new (exactement count fois), en gardant le style de fin de ligne du fichier."""
    raw = Path(path).read_bytes().decode('utf-8')
    crlf = '\r\n' in raw
    if crlf:
        old = old.replace('\r\n', '\n').replace('\n', '\r\n')
        new = new.replace('\r\n', '\n').replace('\n', '\r\n')
    found = raw.count(old)
    if found != count:
        raise SystemExit(f'{path}: {found} occurrence(s) au lieu de {count} : {old[:80]!r}')
    Path(path).write_bytes(raw.replace(old, new).encode('utf-8'))


def files(root):
    root = Path(root)
    out = {}
    for p in root.rglob('*'):
        if p.is_file() and not SKIP & set(p.relative_to(root).parts):
            out[p.relative_to(root).as_posix()] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def tree(a, b, quiet=False):
    fa, fb = files(a), files(b)
    diffs = sorted(k for k in fa.keys() | fb.keys() if fa.get(k) != fb.get(k))
    if not quiet:
        for k in diffs:
            print(('MODIFIE ' if k in fa and k in fb else 'SEUL A ' if k in fa else 'SEUL B ') + k)
        print(f'{len(fa)} | {len(fb)} fichiers ; différences : {len(diffs)}')
    return diffs


def running():
    out = subprocess.run(['tasklist', '/FI', 'IMAGENAME eq acs.exe'], capture_output=True, text=True).stdout
    return 'acs.exe' in out.lower()


def install(stage, baseline, current, new):
    if running():
        raise SystemExit('ARRET : jeu ouvert')
    # L'app installée doit être celle dont la version préparée est partie : un fichier ajouté depuis serait retiré.
    if tree(baseline, LIVE, quiet=True):
        tree(baseline, LIVE)
        raise SystemExit('ARRET : l app installée a changé depuis la copie de référence')
    ARCHIVES.mkdir(exist_ok=True)
    app_zip = ARCHIVES / f'ACAdvancedIA-{current}-sauvegarde-avant-{new}.zip'
    set_zip = ARCHIVES / f'ACAdvancedIA-reglages-{current}-avant-{new}.zip'
    for target, root, names in ((app_zip, LIVE, None), (set_zip, SETTINGS, ('ACAdvancedIA.ini', 'ACAdvancedIA.ini.bak'))):
        with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as z:
            paths = [root / n for n in names] if names else [p for p in root.rglob('*') if p.is_file()]
            for p in paths:
                if p.exists():
                    z.write(p, Path('ACAdvancedIA') / p.relative_to(root) if not names else p.name)
        with zipfile.ZipFile(target) as z:
            if z.testzip() is not None:
                raise SystemExit(f'ARRET : archive illisible {target}')
    print(f'sauvegardes : {app_zip.name}, {set_zip.name}')
    if running():
        raise SystemExit('ARRET : jeu ouvert avant la copie')
    diffs = tree(stage, LIVE, quiet=True)
    for rel in diffs:
        src, dst = Path(stage) / rel, LIVE / rel
        if src.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            print('COPIE ' + rel)
        elif dst.exists():
            dst.unlink()
            print('RETIRE ' + rel)
    left = tree(stage, LIVE, quiet=True)
    print('vérification après copie : ' + ('OK' if not left else f'{len(left)} différence(s)'))
    if left:
        raise SystemExit(1)


if __name__ == '__main__':
    if sys.argv[1] == 'tree':
        sys.exit(1 if tree(sys.argv[2], sys.argv[3]) else 0)
    if sys.argv[1] == 'install':
        install(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
