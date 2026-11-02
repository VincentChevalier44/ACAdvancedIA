-- Imitation de CSP pour la mise à jour (Beta 1.33) : web.get, JSON.parse, empreinte, zips et fichiers en mémoire sous
-- le dossier de l'app (f.root) ; tout autre chemin va aux fonctions d'origine. f.restore() remet tout en place.
-- Réponses web synchrones (f.hold : gardées dans f.pending, rendues par f.flush()). Échecs choisis : f.failZip,
-- f.failExtract, f.failMove (motif du chemin), f.failSave (motif du chemin).
local M={}
M.prefix='apps/lua/ACAdvancedIA/'
function M.install(o)
 o=o or {}
 local f={files=o.files or {},zips={},count=0,calls={},responses={},json={},sha={},restarts=0,opened={},root=o.root or 'app',saved={},pending={}}
 local function log(x) f.calls[#f.calls+1]=x end
 local function keep(t,k) f.saved[#f.saved+1]={t,k,t[k]} end
 local root=f.root..'/'
 local function under(path) return type(path)=='string' and (path==f.root or path:sub(1,#root)==root) end
 local function rel(path) return path:sub(#root+1) end
 function f.zip(entries) f.count=f.count+1; local id='ZIP#'..f.count; f.zips[id]=entries; return id end
 local function zipOf(source) return f.zips[source] or f.zips[f.files[source] or ''] end
 -- Globales de CSP absentes du banc : posées sans passer par le garde des globales.
 f.web,f.JSON=rawget(_G,'web'),rawget(_G,'JSON')
 rawset(_G,'web',{get=function(url,headers,cb)
  assert(type(url)=='string' and type(cb)=='function' and (headers==nil or type(headers)=='table'))
  log('get '..url)
  local function answer() local r=f.responses[url] or {status=404,body=''}; cb(r.err,r.err==nil and {status=r.status,body=r.body} or nil) end
  if f.hold then f.pending[#f.pending+1]=answer else answer() end
 end})
 rawset(_G,'JSON',{parse=function(text) local t=f.json[text]; if t==nil then error('json') end; return t end})
 function f.flush() local list=f.pending; f.pending={}; for _,fn in ipairs(list) do fn() end end
 keep(ac,'checksumSHA256'); keep(ac,'restartApp'); keep(ac,'getFolder'); keep(ac,'FolderID')
 ac.checksumSHA256=function(data) return f.sha[data] or string.rep('0',64) end
 ac.restartApp=function() log('restartApp'); f.restarts=f.restarts+1; if f.onRestart then f.onRestart() end end
 local folders=ac.FolderID or {}; local getFolder=ac.getFolder
 ac.FolderID=setmetatable({ScriptOrigin=folders.ScriptOrigin or 1024},{__index=folders})
 ac.getFolder=function(id) if id==ac.FolderID.ScriptOrigin then return f.root end; return getFolder and getFolder(id) or nil end
 keep(os,'openURL'); os.openURL=function(url) f.opened[#f.opened+1]=url end
 for _,name in ipairs({'load','save','fileExists','deleteFile','move','createDir','createFileDir','scanDir','scanZip','loadFromZip','createZipAsync','extractFromZipAsync'}) do keep(io,name) end
 local orig={}; for _,s in ipairs(f.saved) do if s[1]==io then orig[s[2]]=s[3] end end
 io.load=function(path,...) if under(path) then return f.files[path] end; return orig.load(path,...) end
 io.save=function(path,data,...)
  if under(path) then if f.failSave and path:find(f.failSave,1,true) then return false end; f.files[path]=data; log('save '..rel(path)); return true end
  return orig.save(path,data,...)
 end
 io.fileExists=function(path) if under(path) then return f.files[path]~=nil end; return orig.fileExists(path) end
 io.deleteFile=function(path) if under(path) then f.files[path]=nil; return true end; return orig.deleteFile(path) end
 io.move=function(a,b,replace,...)
  if under(a) then
   assert(under(b),'move outside the app folder: '..tostring(b))
   if f.failMove and a:find(f.failMove,1,true) then return false end
   if f.files[b]~=nil and not replace then return false end
   f.files[b]=f.files[a]; f.files[a]=nil; log('move '..rel(b)); return true
  end
  return orig.move(a,b,replace,...)
 end
 io.createDir=function(path) if under(path) then return true end; return orig.createDir and orig.createDir(path) end
 io.createFileDir=function(path) if under(path) then return true end; return orig.createFileDir and orig.createFileDir(path) end
 io.scanDir=function(dir,mask,cb,...)
  if not under(dir) then return orig.scanDir(dir,mask,cb,...) end
  local prefix=dir..'/'; local seen={}; local names={}
  for path in pairs(f.files) do
   if path:sub(1,#prefix)==prefix then
    local rest=path:sub(#prefix+1); local name=rest:match('^[^/]+'); local folder=rest:find('/',1,true)~=nil
    if not seen[name] then seen[name]=folder; names[#names+1]=name elseif folder then seen[name]=true end
   end
  end
  table.sort(names)
  for _,name in ipairs(names) do cb(name,{isDirectory=seen[name]==true}) end
 end
 io.scanZip=function(source) local z=zipOf(source); if not z then return nil end; local list={}; for name in pairs(z) do list[#list+1]=name end; table.sort(list); return list end
 io.loadFromZip=function(source,name) local z=zipOf(source); return z and z[name] or nil end
 io.createZipAsync=function(filename,entries,cb)
  assert(under(filename),'zip outside the app folder')
  if f.failZip then cb('zip'); return end
  local z={}
  for name,e in pairs(entries) do
   assert(name:sub(1,#M.prefix)==M.prefix and not name:find('/backup/',1,true),'backup entry: '..name)
   z[name]=type(e)=='table' and (e.filename and f.files[e.filename] or e.data) or e
  end
  f.files[filename]=f.zip(z); log('zip '..rel(filename)); cb(nil)
 end
 io.extractFromZipAsync=function(source,dest,filter,cb)
  assert(under(dest),'extraction outside the app folder: '..tostring(dest))
  local z=zipOf(source)
  if not z or f.failExtract then cb('disk'); return end
  if type(filter)=='table' and filter.crucial and z[filter.crucial]==nil then cb('crucial'); return end
  for name,content in pairs(z) do f.files[dest..'/'..name]=content end
  log('extract '..(under(source) and rel(source) or 'download')); cb(nil)
 end
 function f.restore()
  for i=#f.saved,1,-1 do local s=f.saved[i]; s[1][s[2]]=s[3] end
  rawset(_G,'web',f.web); rawset(_G,'JSON',f.JSON)
 end
 -- Fichiers de l'app installée (version, contenu des fichiers) et paquet publié (zip, empreinte, réponses).
 function f.app(version,extra)
  f.files[root..'manifest.ini']='[ABOUT]\nNAME=ACAdvancedIA\nREQUIRED_VERSION=0.1\nVERSION='..version..'\n'
  f.files[root..'ACAdvancedIA.lua']='main '..version; f.files[root..'src/update.lua']='update '..version
  f.files[root..'src/remote.lua']='remote '..version; f.files[root..'src/ui.lua']='ui '..version; f.files[root..'sounds/beep.wav']='wav'
  for k,v in pairs(extra or {}) do f.files[root..k]=v end
 end
 function f.release(version,options)
  options=options or {}
  local number=version:match('[%d%.]+$')
  local entries={[M.prefix..'manifest.ini']='[ABOUT]\nVERSION='..version..'\n',[M.prefix..'ACAdvancedIA.lua']='main '..version,
   [M.prefix..'src/update.lua']='update '..version,[M.prefix..'src/remote.lua']='remote '..version,[M.prefix..'src/ui.lua']='ui '..version,
   [M.prefix..'src/new.lua']='new '..version,[M.prefix..'sounds/beep.wav']='wav'}
  for k,v in pairs(options.entries or {}) do entries[k]=v or nil end
  local id=f.zip(entries); local hash=options.hash or string.rep('ab',32)
  f.sha[id]=options.actual or hash
  local base='https://github.com/VincentChevalier44/ACAdvancedIA/releases/download/v'..number..'/'
  local name='ACAdvancedIA-Beta-'..number
  f.json['release '..version]={tag_name='v'..number,draft=false,prerelease=false,published_at='2026-11-05T10:00:00Z',
   html_url='https://github.com/VincentChevalier44/ACAdvancedIA/releases/tag/v'..number,body='## Beta '..number..'\n\n- **Nouveau** point\n- Second point\n',
   assets={{name=name..'.zip',size=options.size or 1000000,browser_download_url=base..name..'.zip'},{name=name..'.sha256',size=90,browser_download_url=base..name..'.sha256'}}}
  f.responses['https://api.github.com/repos/VincentChevalier44/ACAdvancedIA/releases/latest']={status=options.apiStatus or 200,body='release '..version,err=options.apiErr}
  f.responses[base..name..'.sha256']={status=200,body=hash..'  '..name..'.zip\n'}
  f.responses[base..name..'.zip']={status=options.zipStatus or 200,body=id,err=options.zipErr}
  return id
 end
 function f.find(x) for i,c in ipairs(f.calls) do if c==x then return i end end end
 function f.last(prefix) local at; for i,c in ipairs(f.calls) do if c:sub(1,#prefix)==prefix then at=i end end; return at end
 return f
end
return M
