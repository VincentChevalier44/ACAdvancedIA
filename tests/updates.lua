-- Mise à jour depuis GitHub (Beta 1.33) : logique pure avec un port imité (réponses synchrones, journal des appels),
-- puis le vrai port (src/remote.lua) sur une imitation de CSP (tests/updatefake.lua).
local Up=require('src/update')
local Remote=require('src/remote')
local Fake=require('tests/updatefake')
local tests={}
local SHA=string.rep('ab',32)
local function release(over)
 local r={tag_name='v1.34',name='Beta 1.34',draft=false,prerelease=false,html_url='https://github.com/VincentChevalier44/ACAdvancedIA/releases/tag/v1.34',
  published_at='2026-11-05T10:00:00Z',body='## Beta 1.34\r\n\r\n- **Panneaux** lumineux\n- `DRS`\n',
  assets={{name='ACAdvancedIA-Beta-1.34.zip',size=1000000,browser_download_url=Up.download..'v1.34/ACAdvancedIA-Beta-1.34.zip'},
   {name='ACAdvancedIA-Beta-1.34.sha256',size=100,browser_download_url=Up.download..'v1.34/ACAdvancedIA-Beta-1.34.sha256'}}}
 for k,v in pairs(over or {}) do r[k]=v end
 return r
end
local function entries() local t={}; for _,f in ipairs(Up.required) do t[#t+1]=Up.prefix..f end; t[#t+1]=Up.prefix..'src/'; return t end
-- Port imité : o.* règle les réponses, calls garde l'ordre des opérations.
local function port(o)
 o=o or {}
 local p={calls={},marked=o.marked,files={}}
 local function log(x) p.calls[#p.calls+1]=x end
 function p.get(url,_,cb)
  log('get '..url)
  if url==Up.api then cb(o.apiErr,o.apiStatus or 200,'api')
  elseif url:find('%.sha256$') then cb(o.shaErr,o.shaStatus or 200,o.shaText or (SHA..'  ACAdvancedIA-Beta-1.34.zip\n'))
  else cb(o.zipErr,o.zipStatus or 200,o.zipData or 'zipdata') end
 end
 function p.json() if o.json==nil then return release() end; return o.json or nil end
 function p.sha256() return o.hash or SHA end
 function p.entries() return o.entries or entries() end
 function p.entry() return o.manifest or '[ABOUT]\nVERSION=Beta 1.34\n' end
 function p.previous() return o.previous end
 function p.installedVersion() return o.installed end
 function p.marker() return p.marked end
 function p.mark(t) log('mark '..t); if o.markFails then return false end; p.marked=t; return true end
 function p.unmark() log('unmark'); p.marked=nil end
 function p.done(t) log('done '..t); p.report=t end
 function p.takeDone() local t=o.report; o.report=nil; return t end
 function p.backup(v,cb) log('backup '..v); cb(o.backupErr) end
 function p.extract(d,cb) log('extract '..tostring(d)); if d=='backup' then cb(o.restoreErr) else cb(o.extractErr) end end
 function p.restart() log('restart') end
 return p
end
local function find(calls,x) for i,c in ipairs(calls) do if c==x then return i end end end
local function ready(o) local u=Up.new('Beta 1.33'); local p=port(o); Up.start(u,p); Up.check(u,p,10); return u,p end
local function events(u) local out=Up.take(u,{}); local text={}; for i,e in ipairs(out) do text[i]=e[1]..' '..e[2] end; return table.concat(text,'\n') end

tests.UPDATE_VERSIONS=function()
 assert(table.concat(Up.version('Beta 1.33'),'.')=='1.33' and table.concat(Up.version('v1.33.2'),'.')=='1.33.2')
 assert(table.concat(Up.version('ACAdvancedIA-Beta-1.34.zip'),'.')=='1.34' and Up.version('Beta')==nil and Up.version(nil)==nil)
 assert(Up.newer('Beta 1.34','Beta 1.33') and Up.newer('v1.33.1','Beta 1.33') and Up.newer('Beta 1.40','Beta 1.39'))
 assert(not Up.newer('Beta 1.33','Beta 1.33') and not Up.newer('Beta 1.32','Beta 1.33') and not Up.newer('Beta 1.33','Beta 1.33.0'))
 assert(Up.newer('Beta 2.0','Beta 1.99') and not Up.newer('x','Beta 1.0') and not Up.newer('Beta 1.0','x'))
 assert(Up.label('v1.34')=='Beta 1.34' and Up.label('')==nil)
end
tests.UPDATE_RELEASE_PARSE=function()
 local r=Up.release(release())
 assert(r and r.version=='Beta 1.34' and r.zip.size==1000000 and r.published=='2026-11-05' and r.page:find('/tag/v1.34',1,true))
 assert(r.notes[1]=='Beta 1.34' and r.notes[2]=='' and r.notes[3]=='- Panneaux lumineux' and r.notes[4]=='- DRS' and #r.notes==4)
 -- Brouillon, préversion, sans paquet ou sans empreinte, autre nom, autre adresse, taille aberrante : refusés.
 assert(not Up.release(release({draft=true})) and not Up.release(release({prerelease=true})) and not Up.release(release({tag_name='latest'})))
 local a=release(); table.remove(a.assets,2); assert(not Up.release(a))
 a=release(); table.remove(a.assets,1); assert(not Up.release(a))
 a=release(); a.assets[1].name='ACAdvancedIA-Beta-1.35.zip'; assert(not Up.release(a))
 a=release(); a.assets[1].browser_download_url='https://example.com/ACAdvancedIA-Beta-1.34.zip'; assert(not Up.release(a))
 a=release(); a.assets[2].browser_download_url='https://example.com/ACAdvancedIA-Beta-1.34.sha256'; assert(not Up.release(a))
 a=release(); a.assets[1].size=0; assert(not Up.release(a))
 a=release(); a.assets[1].size=Up.sizeMax+1; assert(not Up.release(a))
 a=release(); a.html_url='https://evil.example/'; assert(Up.release(a).page==Up.page)
 assert(not Up.release(nil) and not Up.release('x'))
 local long=string.rep('x',500); local n=Up.notes(long..'\n'..string.rep('l\n',100))
 assert(#n[1]==Up.lineMax and #n==Up.notesMax)
end
tests.UPDATE_DIGEST_AND_CONTENT=function()
 assert(Up.digest(SHA..'  ACAdvancedIA-Beta-1.34.zip','ACAdvancedIA-Beta-1.34.zip')==SHA)
 assert(Up.digest(SHA:upper()..' *ACAdvancedIA-Beta-1.34.zip\r\n','ACAdvancedIA-Beta-1.34.zip')==SHA)
 assert(not Up.digest(SHA..'  autre.zip','ACAdvancedIA-Beta-1.34.zip') and not Up.digest('abc  ACAdvancedIA-Beta-1.34.zip','ACAdvancedIA-Beta-1.34.zip'))
 assert(not Up.digest(nil,'x'))
 assert(Up.content(entries()))
 local function with(x) local t=entries(); t[#t+1]=x; return t end
 assert(not Up.content(with('apps/lua/Autre/x.lua')) and not Up.content(with(Up.prefix..'../../evil.lua')))
 assert(not Up.content(with(Up.prefix..'src\\a.lua')) and not Up.content(with('C:/evil')) and not Up.content(with('/apps/lua/ACAdvancedIA/x')))
 -- Chaque fichier indispensable, dont le module de mise à jour lui-même.
 for i=1,#Up.required do local t=entries(); table.remove(t,i); assert(not Up.content(t),'required '..i) end
 assert(not Up.content({}) and not Up.content(nil))
 assert(Up.manifestVersion('[ABOUT]\r\nVERSION=Beta 1.34\r\n')=='Beta 1.34' and Up.manifestVersion('NAME=x')==nil and Up.manifestVersion(nil)==nil)
 -- Une autre clé qui finit par VERSION n'est jamais lue comme la version.
 assert(Up.manifestVersion('REQUIRED_VERSION=0.2.3\nVERSION=Beta 1.34')=='Beta 1.34' and Up.manifestVersion('REQUIRED_VERSION=0.2.3')==nil)
 assert(Up.stopped({paused=true}) and Up.stopped({menu=true}) and Up.stopped({},{pit=true}))
 assert(not Up.stopped({},{pit=false}) and not Up.stopped({}) and not Up.stopped(nil,{pit=true}))
end
tests.UPDATE_CHECK_STATES=function()
 local u=ready(); assert(u.phase=='available' and u.release.version=='Beta 1.34' and u.checkedAt==10 and Up.offered(u))
 assert(events(u):find('INFO mise a jour disponible: Beta 1.34 (publiee le 2026-11-05, 1000000 octets)',1,true))
 u=Up.new('Beta 1.34'); Up.check(u,port(),1); assert(u.phase=='current' and not Up.offered(u))
 u=Up.new('Beta 1.35'); Up.check(u,port(),1); assert(u.phase=='current')
 u=Up.new('Beta 1.33'); Up.check(u,port({apiStatus=404}),1); assert(u.phase=='none' and events(u):find('aucune version publiee',1,true))
 u=Up.new('Beta 1.33'); Up.check(u,port({apiStatus=403}),1); assert(u.phase=='failed' and u.error=='network' and u.status==403 and events(u):find('WARN mise a jour: echec reseau (statut 403)',1,true))
 u=Up.new('Beta 1.33'); Up.check(u,port({apiErr='timeout'}),1); assert(u.phase=='failed' and u.error=='network')
 u=Up.new('Beta 1.33'); Up.check(u,port({json=false}),1); assert(u.phase=='failed' and u.error=='format' and not Up.offered(u))
 -- Une vérification ou une installation en cours n'est jamais doublée.
 u=Up.new('Beta 1.33'); u.phase='downloading'; assert(not Up.check(u,port(),1) and u.phase=='downloading')
end
tests.UPDATE_INSTALL_ORDER=function()
 local u,p=ready()
 assert(Up.install(u,p,true))
 local c=p.calls
 local sha,zip,bk,mk,ex,un,dn,rs=find(c,'get '..u.release.sha.url),find(c,'get '..u.release.zip.url),find(c,'backup Beta 1.33'),find(c,'mark update Beta 1.33 -> Beta 1.34'),
  find(c,'extract zipdata'),find(c,'unmark'),find(c,'done update Beta 1.33 -> Beta 1.34'),find(c,'restart')
 assert(sha and zip and bk and mk and ex and un and dn and rs)
 assert(sha<zip and zip<bk and bk<mk and mk<ex and ex<un and un<dn and dn<rs)
 assert(u.phase=='restarting' and p.marked==nil and p.report=='update Beta 1.33 -> Beta 1.34')
 local log=events(u)
 for _,line in ipairs({'telechargement de la Beta 1.34','empreinte verifiee, sauvegarde de la Beta 1.33','installation de la Beta 1.34','Beta 1.34 installee, commandes des IA rendues a AC'}) do assert(log:find(line,1,true),line) end
end
tests.UPDATE_INSTALL_GUARDS=function()
 -- En conduite : rien n'est téléchargé ; le refus est journalisé.
 local u,p=ready(); assert(not Up.install(u,p,false) and u.phase=='failed' and u.error=='driving' and not find(p.calls,'get '..u.release.zip.url))
 assert(events(u):find('INFO mise a jour: refusee en conduite',1,true) and Up.offered(u))
 -- Déjà à jour, ou aucune version connue : bouton sans effet.
 u=Up.new('Beta 1.34'); p=port(); Up.check(u,p,1); assert(not Up.install(u,p,true) and #p.calls==1)
 u=Up.new('Beta 1.33'); assert(not Up.install(u,port(),true))
 -- Chaque échec avant l'extraction laisse la version installée intacte (ni sauvegarde écrasée, ni extraction, ni repère).
 local cases={{shaStatus=404,code='network'},{shaErr='timeout',code='network'},{shaText='bad',code='integrity'},{zipStatus=500,code='network'},
  {zipErr='reset',code='network'},{hash=string.rep('cd',32),code='integrity'},{entries={'apps/lua/Autre/x'},code='content'},
  {manifest='VERSION=Beta 1.33',code='content'},{backupErr='write',code='write'},{markFails=true,code='write'}}
 for i,o in ipairs(cases) do
  u,p=ready(o); Up.take(u,{}); Up.install(u,p,true)
  assert(u.phase=='failed' and u.error==o.code,'case '..i..' '..tostring(u.error))
  assert(not find(p.calls,'extract zipdata') and not find(p.calls,'restart') and p.marked==nil,'case '..i)
  if o.code~='write' then assert(not find(p.calls,'backup Beta 1.33'),'case '..i) end
  if o.code=='integrity' or o.code=='content' or o.code=='write' then assert(events(u):find('version actuelle conservee',1,true),'case '..i) end
 end
end
tests.UPDATE_EXTRACT_FAILURE_RESTORES=function()
 local u,p=ready({extractErr='disk'}); Up.install(u,p,true)
 assert(u.phase=='failed' and u.error=='write' and not find(p.calls,'restart'))
 local ex,rb,un=find(p.calls,'extract zipdata'),find(p.calls,'extract backup'),find(p.calls,'unmark')
 assert(ex and rb and un and ex<rb and rb<un and p.marked==nil)
 -- Sauvegarde non remise en place : repère gardé, reprise au lancement suivant.
 u,p=ready({extractErr='disk',restoreErr='disk'}); Up.take(u,{}); Up.install(u,p,true)
 assert(u.phase=='failed' and p.marked=='update Beta 1.33 -> Beta 1.34' and events(u):find('ERROR mise a jour: sauvegarde non remise en place',1,true))
end
tests.UPDATE_CANCEL=function()
 -- Annulation pendant le téléchargement : la réponse arrivée ensuite est ignorée.
 local u=Up.new('Beta 1.33'); local p=port(); Up.check(u,p,1)
 local pending
 p.get=function(url,_,cb) p.calls[#p.calls+1]='get '..url; pending=cb end
 Up.install(u,p,true); assert(u.phase=='downloading')
 Up.cancel(u); assert(u.phase=='available')
 pending(nil,200,SHA..'  ACAdvancedIA-Beta-1.34.zip'); assert(u.phase=='available' and #p.calls==2)
end
tests.UPDATE_START_RECOVERY=function()
 -- Repère d'installation au lancement, manifeste encore à l'ancienne version : sauvegarde remise en place, redémarrage.
 local u=Up.new('Beta 1.34'); local p=port({marked='update Beta 1.33 -> Beta 1.34',installed='Beta 1.33',previous='Beta 1.33'})
 assert(Up.start(u,p)==true and find(p.calls,'extract backup') and find(p.calls,'restart') and p.marked==nil)
 assert(p.report=='recovered Beta 1.33 -> Beta 1.34' and Up.view(u,true)=='interrupted')
 -- Manifeste déjà à la version visée (extraction allée au bout, seul le repère restait) : rien n'est remis en place.
 u=Up.new('Beta 1.34'); p=port({marked='update Beta 1.33 -> Beta 1.34',installed='Beta 1.34',previous='Beta 1.33'})
 assert(Up.start(u,p)==false and not find(p.calls,'extract backup') and p.marked==nil and u.updated.kind=='update' and Up.view(u,true)=='success')
 -- Reprise impossible : signalée, repère gardé (nouvel essai au lancement suivant).
 u=Up.new('Beta 1.34'); p=port({marked='update Beta 1.33 -> Beta 1.34',installed='Beta 1.33',restoreErr='disk',previous='Beta 1.33'})
 assert(Up.start(u,p)==true and u.phase=='failed' and u.error=='write' and p.marked=='update Beta 1.33 -> Beta 1.34' and not find(p.calls,'restart'))
 assert(events(u):find('reprise impossible',1,true))
 -- Repère illisible : sauvegarde remise en place quand même.
 u=Up.new('Beta 1.34'); p=port({marked='???',installed='Beta 1.34',previous='Beta 1.33'}); assert(Up.start(u,p)==true and find(p.calls,'extract backup'))
 -- Lancement normal : compte rendu lu une seule fois, version précédente proposée.
 u=Up.new('Beta 1.34'); p=port({report='update Beta 1.33 -> Beta 1.34',previous='Beta 1.33'})
 assert(Up.start(u,p)==false and u.updated.kind=='update' and u.updated.from=='Beta 1.33' and u.updated.to=='Beta 1.34' and u.previous=='Beta 1.33')
 assert(events(u):find('mise a jour reussie: Beta 1.33 -> Beta 1.34',1,true))
 local again=Up.new('Beta 1.34'); assert(Up.start(again,p)==false and again.updated==nil)
 -- Sauvegarde de la version installée elle-même (après un retour arrière) : rien à proposer.
 u=Up.new('Beta 1.33'); Up.start(u,port({previous='Beta 1.33'})); assert(u.previous==nil)
end
tests.UPDATE_ROLLBACK=function()
 local u=Up.new('Beta 1.34'); local p=port({previous='Beta 1.33'}); Up.start(u,p)
 assert(not Up.rollback(u,p,false) and u.error=='driving' and not find(p.calls,'extract backup'))
 u=Up.new('Beta 1.34'); p=port({previous='Beta 1.33'}); Up.start(u,p)
 assert(Up.rollback(u,p,true) and u.phase=='restarting')
 local mk,ex,un,dn,rs=find(p.calls,'mark rollback Beta 1.34 -> Beta 1.33'),find(p.calls,'extract backup'),find(p.calls,'unmark'),find(p.calls,'done rollback Beta 1.34 -> Beta 1.33'),find(p.calls,'restart')
 assert(mk and ex and un and dn and rs and mk<ex and ex<un and un<dn and dn<rs)
 -- Retour en échec : repère gardé, la sauvegarde sera remise en place au prochain lancement.
 u=Up.new('Beta 1.34'); p=port({previous='Beta 1.33',restoreErr='disk'}); Up.start(u,p)
 Up.rollback(u,p,true); assert(u.phase=='failed' and u.error=='write' and p.marked=='rollback Beta 1.34 -> Beta 1.33' and not find(p.calls,'restart'))
 -- Sans sauvegarde : bouton sans effet.
 u=Up.new('Beta 1.34'); p=port(); Up.start(u,p); assert(not Up.rollback(u,p,true) and #p.calls==0)
end
tests.UPDATE_VIEW_STATES=function()
 local V=Up.view
 local u=Up.new('Beta 1.33'); assert(V(u,true)=='unchecked')
 local p=port(); Up.check(u,p,1); assert(V(u,true)=='available' and V(u,false)=='driving')
 u=Up.new('Beta 1.33'); p=port(); Up.check(u,p,1); Up.install(u,p,false); assert(V(u,false)=='driving' and V(u,true)=='available')
 u=Up.new('Beta 1.34'); Up.check(u,port(),1); assert(V(u,true)=='uptodate')
 u=Up.new('Beta 1.33'); Up.check(u,port({apiStatus=404}),1); assert(V(u,true)=='none')
 for err,view in pairs({network='errNet',format='errFormat',integrity='errHash',content='errHash',write='errWrite'}) do
  u=Up.new('Beta 1.33'); u.phase='failed'; u.error=err; assert(V(u,true)==view,err)
 end
 for phase,view in pairs({checking='checking',downloading='downloading',verifying='verifying',saving='installing',installing='installing'}) do
  u=Up.new('Beta 1.33'); u.phase=phase; assert(V(u,true)==view,phase)
 end
 u,p=ready(); Up.install(u,p,true); assert(V(u,true)=='done')
 u=Up.new('Beta 1.34'); p=port({previous='Beta 1.33'}); Up.start(u,p); Up.rollback(u,p,true); assert(V(u,true)=='rolledback')
 -- Après le redémarrage : compte rendu affiché même si la vérification du lancement a déjà répondu.
 for report,view in pairs({['update Beta 1.33 -> Beta 1.34']='success',['rollback Beta 1.34 -> Beta 1.33']='rolledback',['recovered Beta 1.33 -> Beta 1.34']='interrupted'}) do
  u=Up.new('Beta 1.34'); p=port({report=report}); Up.start(u,p); assert(V(u,true)==view,report)
  Up.check(u,p,1); assert(V(u,true)==view,report)
 end
 -- Compte rendu illisible : ignoré.
 u=Up.new('Beta 1.34'); Up.start(u,port({report='n importe quoi'})); assert(u.updated==nil and V(u,true)=='unchecked')
end
tests.UPDATE_EVENTS_BOUNDED=function()
 local u=Up.new('Beta 1.33')
 for _=1,Up.eventsMax+10 do Up.cancel(u); u.phase='downloading'; Up.cancel(u) end
 local out=Up.take(u,{}); assert(#out==Up.eventsMax and #u.events==0 and out[1][2]=='mise a jour: telechargement annule')
end
-- Vrai port sans CSP (bancs de mesure, tests sans imitation) : inerte, rien n'est demandé, lu ni écrit.
tests.UPDATE_REMOTE_INERT=function()
 assert(rawget(_G,'web')==nil)
 local released=0; local p=Remote.new(function() released=released+1 end)
 assert(p.ready==false and p.marker()==nil and p.previous()==nil and p.installedVersion()==nil and p.takeDone()==nil and p.mark('x')==false)
 local err; p.get('https://x',nil,function(e) err=e end); assert(err=='unavailable')
 local e2; p.backup('Beta 1.33',function(e) e2=e end); assert(e2=='write')
 local e3; p.extract('data',function(e) e3=e end); assert(e3=='write')
 p.restart(); assert(released==1)
 local u=Up.new('Beta 1.33'); assert(Up.start(u,p)==false and u.phase=='idle' and #u.events==0)
 -- Dossier de l'app connu mais sans web ni JSON (ancien CSP) : inerte aussi, sans erreur.
 local folders,getFolder=ac.FolderID,ac.getFolder
 ac.FolderID={ScriptOrigin=1024}; ac.getFolder=function() return 'app' end
 local ok,err=pcall(function() local q=Remote.new(function() end); assert(q.app=='app' and q.ready==false and q.marker()==nil and q.previous()==nil) end)
 ac.FolderID,ac.getFolder=folders,getFolder; assert(ok,err)
end
-- Installation de bout en bout : sauvegarde (sans le dossier backup/), fichiers changés seulement, manifeste en
-- dernier, repère levé, compte rendu, journal versé et IA rendues avant le redémarrage ; puis retour arrière.
tests.UPDATE_REMOTE_END_TO_END=function()
 local f=Fake.install({root='app'})
 local ok,err=pcall(function()
  f.app('Beta 1.33',{['backup/old.txt']='old',['tracks/spa.lua']='zones'})
  f.release('Beta 1.34')
  local order={}
  f.onRestart=function() order[#order+1]='restartApp' end
  local p=Remote.new(function() order[#order+1]='release' end)
  assert(p.ready and p.app=='app' and p.installedVersion()=='Beta 1.33')
  local u=Up.new('Beta 1.33'); assert(Up.start(u,p)==false)
  Up.check(u,p,0); assert(u.phase=='available' and u.release.notes[3]=='- Nouveau point')
  assert(Up.install(u,p,true) and u.phase=='restarting','install: '..tostring(u.error))
  local files=f.files
  -- Sauvegarde : toute la version installée, jamais le dossier backup/.
  local backup=f.zips[files['app/backup/previous.zip']]
  assert(backup and backup[Fake.prefix..'ACAdvancedIA.lua']=='main Beta 1.33' and backup[Fake.prefix..'tracks/spa.lua']=='zones' and backup[Fake.prefix..'backup/old.txt']==nil)
  assert(files['app/backup/previous.txt']=='Beta 1.33' and files['app/backup/previous.zip.tmp']==nil)
  -- Fichiers changés en place, nouveau fichier ajouté, fichier identique jamais déplacé, manifeste en dernier.
  assert(files['app/ACAdvancedIA.lua']=='main Beta 1.34' and files['app/src/ui.lua']=='ui Beta 1.34' and files['app/src/new.lua']=='new Beta 1.34')
  assert(files['app/sounds/beep.wav']=='wav' and not f.find('move sounds/beep.wav') and files['app/tracks/spa.lua']=='zones')
  assert(f.last('move ')==f.find('move manifest.ini') and Up.manifestVersion(files['app/manifest.ini'])=='Beta 1.34')
  -- Repère levé, compte rendu écrit, dépôt vidé.
  assert(files['app/backup/installing.txt']==nil and files['app/backup/updated.txt']=='update Beta 1.33 -> Beta 1.34')
  for path in pairs(files) do assert(not path:find('app/backup/next/',1,true),'staging left: '..path) end
  assert(order[1]=='release' and order[2]=='restartApp' and #order==2 and f.restarts==1)
  -- Lancement suivant : compte rendu, version précédente proposée, retour arrière.
  local p2=Remote.new(function() order[#order+1]='release' end)
  local u2=Up.new('Beta 1.34'); assert(Up.start(u2,p2)==false and u2.updated.kind=='update' and u2.previous=='Beta 1.33' and files['app/backup/updated.txt']==nil)
  assert(Up.rollback(u2,p2,true) and u2.phase=='restarting')
  assert(files['app/ACAdvancedIA.lua']=='main Beta 1.33' and files['app/src/ui.lua']=='ui Beta 1.33' and Up.manifestVersion(files['app/manifest.ini'])=='Beta 1.33')
  assert(files['app/backup/updated.txt']=='rollback Beta 1.34 -> Beta 1.33' and files['app/backup/installing.txt']==nil and f.restarts==2)
  -- Page de la version : seulement une adresse https.
  p.open(u.release.page); p.open('file:///c:/x'); assert(#f.opened==1 and f.opened[1]==u.release.page)
 end)
 f.restore(); assert(ok,err)
end
-- Échecs du vrai port : la version installée reste intacte (ou remise en place), sans repère qui traîne.
tests.UPDATE_REMOTE_FAILURES=function()
 local function attempt(options,setup)
  local f=Fake.install({root='app'})
  local ok,err=pcall(function()
   f.app('Beta 1.33'); f.release('Beta 1.34',options)
   if setup then setup(f) end
   local p=Remote.new(function() end)
   local u=Up.new('Beta 1.33'); Up.start(u,p); Up.check(u,p,0); Up.install(u,p,true)
   f.result={u=u,files=f.files}
  end)
  f.restore(); assert(ok,err)
  return f.result.u,f.result.files,f
 end
 local function intact(files) return files['app/ACAdvancedIA.lua']=='main Beta 1.33' and files['app/src/ui.lua']=='ui Beta 1.33' and Up.manifestVersion(files['app/manifest.ini'])=='Beta 1.33' and files['app/backup/installing.txt']==nil end
 -- Empreinte différente : rien n'est sauvegardé ni écrit.
 local u,files=attempt({actual=string.rep('cd',32)}); assert(u.error=='integrity' and intact(files) and files['app/backup/previous.zip']==nil)
 -- Chemin hors du dossier de l'app dans le paquet : refusé avant toute écriture.
 u,files=attempt({entries={['apps/lua/ACAdvancedIA/../../evil.lua']='x'}}); assert(u.error=='content' and intact(files) and files['app/backup/previous.zip']==nil)
 -- Paquet sans le module de mise à jour : refusé.
 u,files=attempt({entries={[Fake.prefix..'src/remote.lua']=false}}); assert(u.error=='content' and intact(files))
 -- Sauvegarde impossible : rien d'autre n'est tenté.
 u,files=attempt(nil,function(f) f.failZip=true end); assert(u.error=='write' and intact(files) and files['app/backup/previous.zip']==nil)
 -- Déplacement refusé en cours de mise en place : la sauvegarde est remise en place aussitôt.
 local f
 u,files,f=attempt(nil,function(x) x.failMove='next/apps/lua/ACAdvancedIA/src/ui.lua' end)
 assert(u.error=='write' and intact(files) and files['app/src/new.lua']=='new Beta 1.34' and f.restarts==0,'restored after a failed move')
 -- Extraction refusée : version intacte.
 u,files,f=attempt(nil,function(x) x.failExtract=true end); assert(u.error=='write' and files['app/ACAdvancedIA.lua']=='main Beta 1.33' and f.restarts==0)
end
-- Reprise au lancement par le vrai port : repère présent, manifeste encore ancien -> sauvegarde remise en place ;
-- manifeste déjà à la version visée -> seul le repère est levé.
tests.UPDATE_REMOTE_RECOVERY=function()
 local f=Fake.install({root='app'})
 local ok,err=pcall(function()
  f.app('Beta 1.33')
  f.files['app/backup/previous.zip']=f.zip({[Fake.prefix..'manifest.ini']='VERSION=Beta 1.33',[Fake.prefix..'ACAdvancedIA.lua']='main Beta 1.33',
   [Fake.prefix..'src/update.lua']='update Beta 1.33',[Fake.prefix..'src/remote.lua']='remote Beta 1.33',[Fake.prefix..'src/ui.lua']='ui Beta 1.33'})
  f.files['app/backup/previous.txt']='Beta 1.33'
  -- Extraction interrompue : fichiers mêlés, manifeste encore à la 1.33.
  f.files['app/ACAdvancedIA.lua']='main Beta 1.34'; f.files['app/backup/installing.txt']='update Beta 1.33 -> Beta 1.34'
  local p=Remote.new(function() end)
  local u=Up.new('Beta 1.34')
  assert(Up.start(u,p)==true and f.files['app/ACAdvancedIA.lua']=='main Beta 1.33' and f.files['app/backup/installing.txt']==nil and f.restarts==1)
  assert(f.files['app/backup/updated.txt']=='recovered Beta 1.33 -> Beta 1.34')
  -- Seul le repère restait : rien n'est remis en place.
  f.files['app/manifest.ini']='VERSION=Beta 1.34'; f.files['app/ACAdvancedIA.lua']='main Beta 1.34'; f.files['app/backup/installing.txt']='update Beta 1.33 -> Beta 1.34'
  f.files['app/backup/updated.txt']=nil
  local u2=Up.new('Beta 1.34')
  assert(Up.start(u2,p)==false and f.files['app/ACAdvancedIA.lua']=='main Beta 1.34' and f.files['app/backup/installing.txt']==nil and f.restarts==1 and u2.updated.kind=='update')
 end)
 f.restore(); assert(ok,err)
end
return tests
