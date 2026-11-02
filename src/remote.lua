-- Port de la mise à jour (Beta 1.33) : réseau, empreinte, zips et fichiers de CSP, seulement dans ce module.
-- Toutes les écritures restent dans le dossier de l'app : sauvegarde et dépôt sous backup/ (un zip, jamais un dossier
-- copié qu'AC prendrait pour une seconde app), paquet extrait d'abord dans backup/next, puis chaque fichier changé
-- déplacé à sa place, le manifeste en dernier (sa version dit qu'une installation est allée au bout).
-- Sans les fonctions de CSP (tests, banc de mesure), le port est inerte : rien n'est lu, écrit ni demandé.
local Update=require('src/update')
local M={}
local function callable(f) return type(f)=='function' end
local function folder(id)
 if not ac or not callable(ac.getFolder) or not ac.FolderID or not ac.FolderID[id] then return nil end
 local ok,path=pcall(ac.getFolder,ac.FolderID[id])
 if not ok or type(path)~='string' or path=='' then return nil end
 return (path:gsub('\\','/'):gsub('/+$',''))
end
-- Empreinte en hexadécimal minuscule (CSP la rend en texte ; 32 octets bruts acceptés aussi).
local function hex(s)
 if type(s)~='string' then return nil end
 if #s==64 and s:match('^%x+$') then return s:lower() end
 if #s==32 then return (s:gsub('.',function(c) return string.format('%02x',c:byte()) end)) end
 return nil
end
-- Fichiers d'un dossier, chemins relatifs avec « / », sans le dossier de sauvegarde à la racine.
local function files(dir,rel,out)
 io.scanDir(dir,'*',function(name,attr)
  local path=rel=='' and name or rel..'/'..name
  if attr and attr.isDirectory then
   if path~='backup' then files(dir..'/'..name,path,out) end
  else out[#out+1]=path end
 end)
 return out
end
-- Bibliothèques de CSP lues sans erreur quand elles manquent (tests, ancien CSP).
local function lib(name) local t=rawget(_G,name); return type(t)=='table' and t or nil end
local needed={'get','load','save','fileExists','deleteFile','move','createDir','createFileDir','scanDir','scanZip','loadFromZip','createZipAsync','extractFromZipAsync'}
-- onRelease : journal versé et commandes des IA rendues à AC (fourni par le script principal), avant ac.restartApp.
function M.new(onRelease)
 local p={ready=false}
 local web,JSON=lib('web'),lib('JSON')
 local app=folder('ScriptOrigin')
 local ready=app~=nil and type(io)=='table' and web~=nil and callable(web.get) and JSON~=nil and callable(JSON.parse)
  and type(ac)=='table' and callable(ac.checksumSHA256) and callable(ac.restartApp)
 if ready then for _,name in ipairs(needed) do if name~='get' and not callable(io[name]) then ready=false end end end
 p.ready=ready; p.app=app
 local dir=app and app..'/backup'
 local zip=dir and dir..'/previous.zip'; local version=dir and dir..'/previous.txt'
 local marker=dir and dir..'/installing.txt'; local report=dir and dir..'/updated.txt'; local staging=dir and dir..'/next'
 local function exists(f) if not ready or not f then return false end; local ok,r=pcall(io.fileExists,f); return ok and r==true end
 local function load(f) if not exists(f) then return nil end; local ok,t=pcall(io.load,f); return ok and type(t)=='string' and t or nil end
 local function save(f,t) if not ready or not f then return false end; pcall(io.createFileDir,f); local ok,r=pcall(io.save,f,t,true); return ok and r~=false end
 local function delete(f) if exists(f) then pcall(io.deleteFile,f) end end
 function p.get(url,headers,cb)
  if not ready then cb('unavailable',nil,nil); return end
  local ok=pcall(web.get,url,headers or {},function(err,response)
   if err and err~='' then cb(tostring(err),nil,nil) else cb(nil,response and tonumber(response.status),response and response.body) end
  end)
  if not ok then cb('web',nil,nil) end
 end
 function p.json(text) if not ready or type(text)~='string' then return nil end; local ok,t=pcall(JSON.parse,text); return ok and type(t)=='table' and t or nil end
 function p.sha256(data) if not ready then return nil end; local ok,h=pcall(ac.checksumSHA256,data); return ok and hex(h) or nil end
 function p.entries(data) if not ready then return nil end; local ok,list=pcall(io.scanZip,data); return ok and type(list)=='table' and list or nil end
 function p.entry(data,name) if not ready then return nil end; local ok,t=pcall(io.loadFromZip,data,name); return ok and type(t)=='string' and t or nil end
 function p.previous() return exists(zip) and load(version) or nil end
 function p.installedVersion() return app and Update.manifestVersion(load(app..'/manifest.ini')) or nil end
 function p.marker() return load(marker) end
 function p.mark(text) return save(marker,text) end
 function p.unmark() delete(marker) end
 function p.done(text) save(report,text) end
 function p.takeDone() local t=load(report); delete(report); return t end
 function p.open(url) if os and callable(os.openURL) and type(url)=='string' and url:sub(1,8)=='https://' then pcall(os.openURL,url) end end
 -- Sauvegarde de la version installée : zip temporaire, puis renommé (une sauvegarde est complète ou absente).
 function p.backup(installed,cb)
  if not ready then cb('write'); return end
  pcall(io.createDir,dir)
  local ok,list=pcall(files,app,'',{})
  if not ok or type(list)~='table' or #list==0 then cb('write'); return end
  local entries={}
  for _,rel in ipairs(list) do entries[Update.prefix..rel]={filename=app..'/'..rel} end
  local tmp=zip..'.tmp'; delete(tmp)
  local started=pcall(io.createZipAsync,tmp,entries,function(err)
   if err and err~='' then delete(tmp); cb('write'); return end
   local moved,result=pcall(io.move,tmp,zip,true)
   if not moved or result==false or not exists(zip) or not save(version,installed) then cb('write'); return end
   cb(nil)
  end)
  if not started then cb('write') end
 end
 -- Dépôt vidé (fichiers d'une extraction précédente).
 local function clear()
  local ok,list=pcall(files,staging,'',{})
  if ok then for _,rel in ipairs(list) do pcall(io.deleteFile,staging..'/'..rel) end end
 end
 -- Fichiers déposés mis à leur place : seulement ceux qui changent, le manifeste en dernier.
 local function place()
  local root=staging..'/'..Update.prefix:gsub('/$','')
  local ok,list=pcall(files,root,'',{})
  if not ok or type(list)~='table' then return false end
  local manifest=false
  for _,rel in ipairs(list) do
   if rel=='manifest.ini' then manifest=true
   elseif load(root..'/'..rel)~=load(app..'/'..rel) then
    pcall(io.createFileDir,app..'/'..rel)
    local moved,result=pcall(io.move,root..'/'..rel,app..'/'..rel,true)
    if not moved or result==false then return false end
   end
  end
  if not manifest then return false end
  local moved,result=pcall(io.move,root..'/manifest.ini',app..'/manifest.ini',true)
  return moved and result~=false
 end
 -- Paquet téléchargé ou sauvegarde ('backup', contrôlée comme un paquet) : extrait dans le dépôt, puis mis en place.
 function p.extract(data,cb)
  if not ready then cb('write'); return end
  local source=data
  if data=='backup' then
   if not exists(zip) then cb('write'); return end
   source=zip
   if not Update.content(p.entries(zip)) then cb('content'); return end
  end
  pcall(io.createDir,staging); clear()
  local started=pcall(io.extractFromZipAsync,source,staging,{crucial=Update.prefix..'manifest.ini'},function(err)
   if err and err~='' then cb(tostring(err)); return end
   if not place() then cb('move'); return end
   clear(); cb(nil)
  end)
  if not started then cb('write') end
 end
 function p.restart()
  if callable(onRelease) then pcall(onRelease) end
  if ready then pcall(ac.restartApp) end
 end
 return p
end
return M
