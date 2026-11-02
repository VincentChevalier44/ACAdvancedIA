-- Mise à jour depuis GitHub (Beta 1.33) : logique pure, sans réseau ni fichiers. Le port (src/remote.lua en jeu, une
-- imitation dans les tests) fait les requêtes, l'empreinte, les zips, la sauvegarde et le redémarrage.
-- Ordre d'une installation : dernière version publiée -> empreinte puis paquet -> SHA-256 -> contenu du paquet (chemins,
-- fichiers indispensables, version du manifeste) -> sauvegarde de la version installée -> repère « installation en
-- cours » -> extraction (manifeste en dernier) -> repère levé -> compte rendu -> commandes des IA rendues à AC ->
-- redémarrage de l'app. Toute erreur avant l'extraction laisse la version installée intacte ; une extraction en échec
-- remet aussitôt la sauvegarde en place ; une extraction interrompue (plantage, coupure) est reprise au lancement
-- suivant : terminée si le manifeste porte déjà la version visée, sinon la sauvegarde est remise en place.
-- Événements du journal (u.events) : textes prêts, versés au journal de session par le script principal.
local M={}
M.repo='VincentChevalier44/ACAdvancedIA'
M.api='https://api.github.com/repos/'..M.repo..'/releases/latest'
M.page='https://github.com/'..M.repo..'/releases'
M.download='https://github.com/'..M.repo..'/releases/download/'
M.prefix='apps/lua/ACAdvancedIA/'
M.required={'manifest.ini','ACAdvancedIA.lua','src/update.lua','src/remote.lua'}
M.headers={['User-Agent']='ACAdvancedIA',['Accept']='application/vnd.github+json'}
M.notesMax=40
M.lineMax=200
M.sizeMax=16*1024*1024
M.eventsMax=32
-- Numéro de version : 'Beta 1.33', 'v1.33', 'ACAdvancedIA-Beta-1.33.zip' -> {1,33} ; nil sans numéro.
function M.version(text)
 if type(text)~='string' then return nil end
 local s=text:match('(%d+%.%d+[%.%d]*)') or text:match('(%d+)')
 if not s then return nil end
 local out={}; for n in s:gmatch('%d+') do out[#out+1]=tonumber(n) end
 return out
end
function M.label(text) local v=M.version(text); return v and 'Beta '..table.concat(v,'.') or nil end
-- a plus récente que b (versions illisibles : jamais).
function M.newer(a,b)
 local x,y=M.version(a),M.version(b)
 if not x or not y then return false end
 for i=1,math.max(#x,#y) do local p,q=x[i] or 0,y[i] or 0; if p~=q then return p>q end end
 return false
end
local function str(v) return type(v)=='string' and v or nil end
local function starts(s,p) return type(s)=='string' and s:sub(1,#p)==p end
-- Notes de version : texte du changelog publié, balises Markdown simples retirées, lignes et longueur bornées.
function M.notes(body)
 local out={}
 if type(body)~='string' then return out end
 for line in (body:gsub('\r','')..'\n'):gmatch('([^\n]*)\n') do
  line=line:gsub('^%s*#+%s*',''):gsub('%*%*',''):gsub('`',''):gsub('%s+$','')
  if #line>M.lineMax then line=line:sub(1,M.lineMax-3)..'...' end
  if line~='' or (#out>0 and out[#out]~='') then out[#out+1]=line end
  if #out>=M.notesMax then break end
 end
 while #out>0 and out[#out]=='' do out[#out]=nil end
 return out
end
-- Dernière version publiée (réponse de l'API GitHub décodée). Le paquet et son empreinte doivent porter le numéro de la
-- version et venir des téléchargements du dépôt : aucune autre adresse n'est suivie.
function M.release(data)
 if type(data)~='table' or data.draft==true or data.prerelease==true then return nil,'format' end
 local tag=str(data.tag_name); local version=M.label(tag)
 if not version then return nil,'format' end
 local number=table.concat(M.version(tag),'.')
 local zipName='ACAdvancedIA-Beta-'..number..'.zip'
 local r={version=version,tag=tag,notes=M.notes(data.body),published=str(data.published_at) and data.published_at:sub(1,10) or '',
  page=starts(data.html_url,M.page) and data.html_url or M.page}
 if type(data.assets)=='table' then
  for _,asset in ipairs(data.assets) do
   local name=type(asset)=='table' and str(asset.name); local url=type(asset)=='table' and str(asset.browser_download_url)
   if name and url and starts(url,M.download) then
    if name==zipName then r.zip={name=name,url=url,size=tonumber(asset.size) or 0}
    elseif name==zipName..'.sha256' or name=='ACAdvancedIA-Beta-'..number..'.sha256' then r.sha={name=name,url=url} end
   end
  end
 end
 if not r.zip or not r.sha then return nil,'format' end
 if r.zip.size<=0 or r.zip.size>M.sizeMax then return nil,'format' end
 return r
end
-- Fichier d'empreinte « <64 hexadécimaux>  <nom du paquet> » (sha256sum).
function M.digest(text,zipName)
 if type(text)~='string' then return nil end
 local hash,name=text:match('^%s*(%x+)%s+%*?([^%s]+)')
 if not hash or #hash~=64 or name~=zipName then return nil end
 return hash:lower()
end
-- Contenu du paquet : tout sous apps/lua/ACAdvancedIA/, sans remontée de dossier ni chemin absolu, avec les fichiers
-- indispensables (dont le module de mise à jour lui-même : une version sans lui ne pourrait plus se mettre à jour).
function M.content(entries)
 if type(entries)~='table' or #entries==0 then return false end
 local seen={}
 for _,name in ipairs(entries) do
  if type(name)~='string' or not starts(name,M.prefix) or name:find('..',1,true) or name:find('\\',1,true) or name:find(':',1,true) then return false end
  seen[name]=true
 end
 for _,file in ipairs(M.required) do if not seen[M.prefix..file] then return false end end
 return true
end
-- Version écrite dans un manifeste (clé VERSION en début de ligne, jamais une autre clé qui finirait par VERSION).
function M.manifestVersion(text)
 if type(text)~='string' then return nil end
 return M.label(('\n'..text):match('\n[ \t]*VERSION[ \t]*=[ \t]*([^\r\n]+)'))
end
-- À l'arrêt seulement : pause, menu d'AC ou voiture du joueur aux stands.
function M.stopped(frame,player) return frame~=nil and (frame.paused==true or frame.menu==true or player~=nil and player.pit==true) end

function M.new(installed)
 return {phase='idle',installed=installed,error='',status=0,release=nil,checkedAt=nil,cancelled=false,previous=nil,updated=nil,serial=0,
  recovering=false,after='',events={}}
end
-- Événement du journal : niveau et texte ; les plus anciens sont oubliés au-delà de M.eventsMax non versés.
local function event(u,level,text)
 local list=u.events
 if #list>=M.eventsMax then table.remove(list,1) end
 list[#list+1]={level,text}
end
-- Événements à verser au journal, dans l'ordre ; la liste est vidée.
function M.take(u,out)
 local list=u.events
 for i=1,#list do out[#out+1]=list[i]; list[i]=nil end
 return out
end
local busy={checking=true,downloading=true,verifying=true,saving=true,installing=true,restarting=true,rollingback=true}
function M.busy(u) return busy[u.phase]==true end
local failures={network='echec reseau',format='version publiee illisible ou incomplete',integrity='empreinte SHA-256 differente',
 content='contenu du paquet refuse',write='ecriture impossible',driving='refusee en conduite (disponible a l arret : stands, pause ou menu)'}
local function fail(u,code,status)
 u.phase='failed'; u.error=code; u.status=status or 0; u.serial=u.serial+1
 event(u,code=='driving' and 'INFO' or 'WARN','mise a jour: '..failures[code]..((status or 0)>0 and ' (statut '..status..')' or '')..(code~='driving' and code~='network' and code~='format' and ', version actuelle conservee' or ''))
end
-- Repère d'une opération en cours : « update A -> B » ou « rollback A -> B ».
local function parse(text)
 if type(text)~='string' then return nil end
 local kind,from,to=text:match('^(%a+) (.-) %-> (.+)$')
 if kind~='update' and kind~='rollback' and kind~='recovered' then return nil end
 return kind,from,to
end
-- Au lancement : reprise d'une installation interrompue, puis compte rendu de la dernière opération. Renvoie true si
-- l'app doit attendre sans piloter (sauvegarde en cours de remise en place, redémarrage à suivre, ou fichiers mêlés).
function M.start(u,port)
 -- Sauvegarde de la version installée elle-même (après un retour arrière) : rien à proposer.
 u.previous=M.label(port.previous()); if u.previous==u.installed then u.previous=nil end
 local marker=port.marker()
 if marker then
  local kind,from,to=parse(marker)
  -- Extraction terminée (manifeste extrait en dernier, déjà à la version visée) : seul le repère restait.
  if kind and to and port.installedVersion()==to then
   port.unmark(); u.updated={kind=kind,from=from,to=to}; u.serial=u.serial+1
   event(u,'INFO','mise a jour: operation terminee au lancement precedent ('..from..' -> '..to..')')
   return false
  end
  u.phase='rollingback'; u.error=''; u.recovering=true
  event(u,'WARN','mise a jour: installation interrompue ('..marker..'), sauvegarde remise en place')
  port.extract('backup',function(err)
   if err then fail(u,'write'); event(u,'ERROR','mise a jour: reprise impossible, reinstallez l app depuis GitHub'); return end
   port.unmark(); port.done('recovered '..(from or '?')..' -> '..(to or '?')); u.phase='restarting'; u.after='recovered'; u.serial=u.serial+1
   event(u,'INFO','mise a jour: sauvegarde remise en place, redemarrage de l app'); port.restart()
  end)
  return true
 end
 local kind,from,to=parse(port.takeDone())
 if kind then
  u.updated={kind=kind,from=from,to=to}; u.serial=u.serial+1
  event(u,'INFO',kind=='update' and 'mise a jour reussie: '..from..' -> '..to or kind=='rollback' and 'retour arriere termine: '..from..' -> '..to
   or 'installation interrompue rattrapee: '..from..' -> '..to..' annulee')
 end
 return false
end
function M.check(u,port,now)
 if M.busy(u) then return false end
 u.phase='checking'; u.error=''; u.status=0
 port.get(M.api,M.headers,function(err,status,body)
  if u.phase~='checking' then return end
  u.checkedAt=now
  if err or not status then fail(u,'network'); return end
  if status==404 then u.phase='none'; u.serial=u.serial+1; event(u,'INFO','mise a jour: aucune version publiee sur GitHub'); return end
  if status~=200 then fail(u,'network',status); return end
  local r=M.release(port.json(body))
  if not r then fail(u,'format'); return end
  u.release=r; u.phase=M.newer(r.version,u.installed) and 'available' or 'current'; u.serial=u.serial+1
  event(u,'INFO',u.phase=='available' and 'mise a jour disponible: '..r.version..' (publiee le '..r.published..', '..r.zip.size..' octets)' or 'mise a jour: '..u.installed..' est la derniere version')
 end)
 return true
end
function M.cancel(u) if u.phase=='downloading' then u.cancelled=true; u.phase='available'; event(u,'INFO','mise a jour: telechargement annule') end end
-- Installation (un clic) : seulement à l'arrêt et avec une version plus récente connue.
function M.install(u,port,stopped)
 local r=u.release
 if M.busy(u) or not r or not M.newer(r.version,u.installed) then return false end
 if not stopped then fail(u,'driving'); return false end
 u.phase='downloading'; u.error=''; u.cancelled=false
 event(u,'INFO','mise a jour: telechargement de la '..r.version)
 port.get(r.sha.url,nil,function(err,status,text)
  if u.phase~='downloading' or u.cancelled then return end
  local expected=not err and status==200 and M.digest(text,r.zip.name)
  if not expected then fail(u,(err or status~=200) and 'network' or 'integrity',status~=200 and status or 0); return end
  port.get(r.zip.url,nil,function(err2,status2,data)
   if u.phase~='downloading' or u.cancelled then return end
   if err2 or status2~=200 or type(data)~='string' then fail(u,'network',status2~=200 and status2 or 0); return end
   u.phase='verifying'
   if port.sha256(data)~=expected then fail(u,'integrity'); return end
   if not M.content(port.entries(data)) or M.manifestVersion(port.entry(data,M.prefix..'manifest.ini'))~=r.version then fail(u,'content'); return end
   u.phase='saving'
   event(u,'INFO','mise a jour: empreinte verifiee, sauvegarde de la '..u.installed)
   port.backup(u.installed,function(err3)
    if err3 then fail(u,'write'); return end
    local mark='update '..u.installed..' -> '..r.version
    if not port.mark(mark) then fail(u,'write'); return end
    u.phase='installing'
    event(u,'INFO','mise a jour: installation de la '..r.version)
    port.extract(data,function(err4)
     if err4 then
      -- Extraction en échec : la sauvegarde est remise en place tout de suite.
      fail(u,'write')
      port.extract('backup',function(err5)
       if err5 then event(u,'ERROR','mise a jour: sauvegarde non remise en place, reprise au prochain lancement') else port.unmark() end
      end)
      return
     end
     port.unmark(); port.done(mark)
     u.phase='restarting'; u.after='update'; u.serial=u.serial+1
     event(u,'INFO','mise a jour: '..r.version..' installee, commandes des IA rendues a AC et redemarrage de l app')
     port.restart()
    end)
   end)
  end)
 end)
 return true
end
-- Retour à la version sauvegardée (celle d'avant la dernière mise à jour).
function M.rollback(u,port,stopped)
 if M.busy(u) or not u.previous then return false end
 if not stopped then fail(u,'driving'); return false end
 u.phase='rollingback'; u.error=''
 local mark='rollback '..u.installed..' -> '..u.previous
 if not port.mark(mark) then fail(u,'write'); return false end
 event(u,'INFO','mise a jour: retour a la '..u.previous)
 port.extract('backup',function(err)
  -- Repère gardé : la sauvegarde (la version visée) sera remise en place au prochain lancement.
  if err then fail(u,'write'); return end
  port.unmark(); port.done(mark)
  u.phase='restarting'; u.after='rollback'; u.serial=u.serial+1
  event(u,'INFO','mise a jour: '..u.previous..' retablie, commandes des IA rendues a AC et redemarrage de l app')
  port.restart()
 end)
 return true
end
-- État affiché : noms de la maquette (uptodate, checking, available, driving, downloading, verifying, installing, done,
-- rolledback, none, interrupted, success, errNet, errHash, errWrite), plus unchecked (vérification au lancement coupée,
-- pas encore vérifié) et errFormat (version publiée incomplète ou illisible).
local errorViews={network='errNet',format='errFormat',integrity='errHash',content='errHash',write='errWrite'}
local reportViews={update='success',rollback='rolledback',recovered='interrupted'}
function M.view(u,stopped)
 local phase=u.phase
 if u.updated and (phase=='idle' or phase=='current' or phase=='checking') then return reportViews[u.updated.kind] end
 if phase=='failed' then
  if u.error=='driving' then return stopped and 'available' or 'driving' end
  return errorViews[u.error] or 'errNet'
 end
 if phase=='available' then return stopped and 'available' or 'driving' end
 if phase=='restarting' then return u.after=='rollback' and 'rolledback' or u.after=='recovered' and 'interrupted' or 'done' end
 if phase=='rollingback' then return u.recovering and 'interrupted' or 'rolledback' end
 if phase=='saving' then return 'installing' end
 if phase=='current' then return 'uptodate' end
 if phase=='idle' then return 'unchecked' end
 return phase
end
-- Une version plus récente est connue (bouton de l'en-tête, alerte de l'accueil, information de l'overlay).
function M.offered(u) return u.release~=nil and M.newer(u.release.version,u.installed) and (u.phase=='available' or u.phase=='failed' and u.error~='format') end
return M
