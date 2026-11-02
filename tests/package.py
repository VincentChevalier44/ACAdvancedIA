"""Archive de distribution reproductible : seulement ce que le jeu charge (point d'entrée, manifeste, icône, modules,
sons, zones de circuit) et les notices du pilote. Le banc de tests et la documentation technique restent dans le
dossier de l'app (jamais chargés par le jeu) ; les paquets des versions précédentes sont retirés de dist."""
from pathlib import Path
import hashlib
import zipfile
from test_pdr import APP, VERSION

def main():
    names=['ACAdvancedIA.lua','manifest.ini','icon.png','README.md','COMPATIBILITY.md','CHANGELOG.md','LICENSE']
    files=[APP/name for name in names]
    for folder,patterns in [('src',['*.lua']),('tracks',['*.md','*.lua']),('sounds',['*.wav'])]:
        for pattern in patterns: files.extend((APP/folder).glob(pattern))
    files=sorted({p for p in files if p.is_file()})
    dist=APP/'dist'; dist.mkdir(exist_ok=True)
    output=dist/f'ACAdvancedIA-{VERSION.replace(" ","-")}.zip'
    for old in [*dist.glob('ACAdvancedIA-*.zip'),*dist.glob('ACAdvancedIA-*.sha256')]:
        if old.stem!=output.stem: old.unlink()
    with zipfile.ZipFile(output,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
        for path in files:
            archive.write(path,Path('apps/lua/ACAdvancedIA')/path.relative_to(APP))
    with zipfile.ZipFile(output) as archive:
        assert archive.testzip() is None
        assert not any('_vendor' in name or '/tests/' in name or '/docs/' in name for name in archive.namelist())
    digest=hashlib.sha256(output.read_bytes()).hexdigest()
    output.with_suffix('.sha256').write_text(digest+'  '+output.name+'\n',encoding='ascii')
    print(f'{output.name}: {len(files)} files, {output.stat().st_size} bytes, SHA256 {digest}')

if __name__=='__main__': main()
