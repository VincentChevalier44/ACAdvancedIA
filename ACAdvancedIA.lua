local Snapshot=require('src/snapshot')
local Applier=require('src/applier')
local Engine=require('src/engine')
local Director=require('src/director')
local Caps=require('src/caps')
local Calibration=require('src/calibration')
local Zones=require('src/zones')
local UI=require('src/ui')
local U=require('src/util')
local Config=require('src/config')
local Lang=require('src/lang')
local Pits=require('src/pits')
local Penalties=require('src/penalties')
local Journal=require('src/journal')
local Locale=require('src/locale')
local Lights=require('src/lights')
local K=Config.K
-- Cache des traces du compilateur JIT agrandi (machine virtuelle de l'app) : avec les 1 000 traces et 512 Ko de code
-- machine par défaut, le moteur vide et recompile tout son code toutes les une à deux minutes (pics d'image). Sans
-- effet sur les décisions ; ignoré si la bibliothèque jit n'est pas exposée.
local jitlib=rawget(_G,'jit')
local jitTuned=type(jitlib)=='table' and type(jitlib.opt)=='table' and type(jitlib.opt.start)=='function' and pcall(jitlib.opt.start,'maxtrace=8000','maxmcode=16384')==true
local previous=rawget(_G,'HUMANAI')
if previous and type(previous.release)=='function' then pcall(previous.release) end
local host=Applier.new()
local globals,profiles=Applier.openStore(host)
-- Langue de l'interface choisie avant de préparer les textes de la fenêtre de réglages.
Locale.set(globals.language)
local engine=Engine.new(globals,profiles)
-- Voitures pilotées en un seul appel protégé seulement avec le cache agrandi (avec le cache par défaut, le code compilé
-- plus volumineux le saturerait plus vite).
engine.batchCars=jitTuned
local frame=Snapshot.new()
local calibration=Calibration.new()
local initialized=false
local released=false
local loadedTrack=''
local lastCheckpoint=0
local shownMessage=0
-- Messages à l'écran : drapeaux, neutralisations, météo ; un seul affichage par événement.
local function announce()
 local t=engine.incidents
 if t.messageId==shownMessage then return end
 shownMessage=t.messageId
 local m=Lang.messages[t.messageKind]
 if m then Applier.message(m[1],t.messageText~='' and string.format(m[2],t.messageText) or string.format(m[2],t.messageValue,t.messageExtra)) end
end
local function dirty()
 Applier.dirty(host,engine.time)
 if host.menuVisible then Applier.save(host,globals,profiles,engine.time,frame.replay,true) end
end
-- Messages d'AC (Beta 1.25) : écoute et masquage optionnel, annulés au déchargement.
local messageListener,messageBlock=nil,nil
local messages
local panel=UI.new(engine,host,calibration,dirty)
messageListener=Applier.listenMessages(function(title,description,kind,time) if not released then pcall(Engine.message,engine,title,description,kind,time) end end)
host.note=engine.note
-- AI flood de CSP (Beta 1.26) : état chargé par CSP au lancement ; le moteur écrit ensuite le réglage voulu.
do local user,system,writable=Applier.floodRead(); Engine.floodInit(engine,user,system,writable); engine.floodWrite=Applier.floodWrite end
if host.storageErrors>0 then U.log(engine.log,0,'WARN','invalid_storage:'..host.storageErrors,-1) end
U.log(engine.log,0,'INFO',jitTuned and 'compilateur JIT: cache agrandi (8000 traces, 16 Mo), voitures pilotees en un seul appel protege' or 'compilateur JIT: options indisponibles, voitures pilotees une par une',-1)
if host.upgraded and #host.upgraded>0 then U.log(engine.log,0,'INFO','profils mis a jour vers les prereglages '..Config.release..': '..table.concat(host.upgraded,', '),-1) end
if host.signsRestored then U.log(engine.log,0,'INFO','sens lateral retabli: -1 / -1 (convention AC, mesure sur cette installation jusqu a la Beta 1.8 ; la mesure le confirmera)',-1) end
if host.firstInstall then U.log(engine.log,0,'INFO','premiere installation: prereglages recommandes et regles de base (essais, qualifications, course)',-1) end
local journal=Journal.new()
-- Journal de session sur disque : lignes nouvelles toutes les deux secondes, résumé chaque minute, capacités perdues.
local function writeJournal(force)
 if not globals.journal then return end
 if not host.journalTried then
  host.journalTried=true
  if Applier.journalOpen(host) then Applier.journalWrite(host,'=== ACAdvancedIA '..Config.release..' : lancement '..Applier.clockText()..' ===\n') end
 end
 if not host.journalPath or not force and engine.time<journal.flushAt then return end
 journal.flushAt=engine.time+K.journalPeriod
 for _,name in ipairs(Caps.names) do
  local reason=host.caps[name].reason
  if journal.caps[name]~=reason then
   if reason=='failures' then U.log(engine.log,engine.time,'WARN','capacite CSP desactivee apres trois echecs: '..name,-1) end
   journal.caps[name]=reason
  end
 end
 if engine.time>=journal.summaryAt then journal.summaryAt=engine.time+K.journalSummary; U.log(engine.log,engine.time,'INFO',Journal.summary(engine),-1) end
 Journal.collect(journal,engine.log,Applier.clockText())
 Applier.journalWrite(host,Journal.take(journal))
end
local function cancelProbe()
 local index=host.caps.probeIndex
 if index==0 or not host.allowed or frame.online or frame.replay or frame.paused then return end
 local a=frame.cars[index]
 if a and a.valid and host.caps.probeID~=(a.identity or a.id) then host.caps.probeIndex=0; host.caps.probeDone=false; return end
 if a and a.valid and a.control and not a.player and not a.pit and not a.offtrack then
  if Caps.restoreCall(host.caps,'level',a.index,host.caps.probeOriginal) then host.caps.probeIndex=0; host.caps.probeDone=true end
 end
end
local function syncRestored()
 for i=1,K.maxCars do
  local state=host.cars[i]
  if state.justRestored then
   Director.reset(engine.states[i],engine.time,false,true); engine.commands[i].active=false; engine.commands[i].offset=0
   state.justRestored=false
  end
 end
end
-- Une voiture au moins garde une commande de l'app à rendre.
local function anyOwned()
 for i=1,K.maxCars do if host.cars[i].owned then return true end end
 return false
end
-- Chaque étape de la restitution est protégée : une erreur dans l'une n'empêche jamais les suivantes.
local function step(fn,...)
 local ok,err=pcall(fn,...)
 if not ok then host.errors=host.errors+1; U.log(engine.log,engine.time,'ERROR','stop:'..tostring(err):sub(1,200),-1) end
end
-- keepParked : fin de session, voitures garées (voiture de sécurité, réserves, IA disqualifiées) laissées à leur stand
-- jusqu'à la session suivante ; jamais au déchargement.
local function stop(final,keepParked)
 if host.allowed then step(cancelProbe); step(Calibration.cancel,calibration,frame,host.caps,globals) end
 step(Applier.restore,host,frame,false,engine.time,final,keepParked); step(syncRestored); step(Applier.checkpoint,host,frame)
end
-- Arrêts et sanctions de la course : sauvegardés une seconde au plus après un changement, et au déchargement.
local lastRaceSave=0
local function saveRace(force)
 if not force and engine.time-lastRaceSave<K.saveDelay then return end
 lastRaceSave=engine.time
 if engine.pits.dirty then engine.pits.dirty=false; Applier.storeText('humanai:pits',Pits.serialize(engine.pits,frame.session)) end
 if engine.penalties.dirty then engine.penalties.dirty=false; Applier.storeText('humanai:penalties',Penalties.serialize(engine.penalties,frame,frame.session)) end
end
local function release()
 if released then return end
 -- Aucune image ne suivra : restitution complète, y compris en pause ou en replay.
 released=true; Snapshot.read(frame,K.dtMax,engine.time); pcall(saveRace,true); Applier.access(host); stop(true); Applier.unregister(host)
 -- Overlay en jeu (Beta 1.25) : case de session d'AC et messages d'origine rendus, écoute des messages close.
 pcall(UI.restoreNative,panel); pcall(messages,false); Applier.dispose(messageListener); messageListener=nil
 pcall(writeJournal,true); Applier.journalWrite(host,'=== fin : '..Applier.clockText()..' ===\n')
end
-- Messages d'AC (Beta 1.25) : repris sur l'overlay ; leur affichage d'origine est masqué (Beta 1.26 : par défaut). Un
-- message témoin, envoyé dès le premier masquage, doit encore arriver à l'écoute : sinon (masquage qui couperait
-- aussi l'overlay), le masquage est levé jusqu'au prochain lancement et le journal le dit.
local probe,unblockable=nil,false
messages=function(block)
 if unblockable then block=false end
 if block and not messageBlock then
  messageBlock=Applier.blockMessages() or false
  if messageBlock and probe==nil then engine.probeSeen=false; probe=Config.K.probeFrames; Applier.probeMessage(Config.K.messageProbe) end
 elseif not block and messageBlock~=nil then Applier.dispose(messageBlock); messageBlock=nil end
 if probe then
  if engine.probeSeen then
   probe=false; U.log(engine.log,engine.time or 0,'INFO','messages d AC: affichage d origine masque, messages repris sur l overlay',-1)
  else
   probe=probe-1
   if probe<=0 then
    probe=false; unblockable=true; Applier.dispose(messageBlock); messageBlock=nil
    U.log(engine.log,engine.time or 0,'WARN','messages d AC: les messages masques n arrivent plus a l overlay, masquage leve jusqu au prochain lancement',-1)
   end
  end
 end
end
local function session()
 if released then return end
 Engine.reset(engine,engine.time,true); engine.session=-1; calibration.attempted=false; Pits.forget(engine.pits); engine.penalties.pending=nil
 host.session=nil -- Un redémarrage garde le même indice : les écritures suivies sont resynchronisées.
end
local function update(dt)
 if released then return end
 local valid=U.finite(dt) and dt>0 and dt<=K.dtMax
 local quiet=not globals.enabled
 if not quiet then
  quiet=true; for _,p in pairs(profiles) do if Config.any(p) then quiet=false; break end end
 end
 if quiet then
  if calibration.index>0 or host.caps.probeIndex>0 or host.flagOverride then quiet=false end
  for i=1,K.maxCars do if host.cars[i].owned then quiet=false; break end end
 end
 local read=Snapshot.read(frame,valid and dt or K.dtMax,engine.time,quiet)
 -- Drapeau du joueur imposé par l'app elle-même : le panneau ne le prend pas pour un drapeau natif.
 frame.flagOwned=host.flagOverride
 if read then Applier.menu(host,frame.menu) else Applier.menu(host,Snapshot.menu()) end
 if not initialized then
  -- Session courante connue avant la récupération : un rechargement n'est pas un changement de session.
  initialized=true; host.session=frame.session; Applier.recover(host,frame)
  Pits.restore(engine.pits,Applier.loadText('humanai:pits'),frame.session)
  Penalties.restore(engine.penalties,Applier.loadText('humanai:penalties'),frame.session)
  Applier.register(host,function() local ok=pcall(release); if not ok then host.errors=host.errors+1 end end,
   function() local ok=pcall(session); if not ok then host.errors=host.errors+1 end end)
 end
 Applier.baselines(host,frame)
 local ready=Engine.step(engine,frame,dt)
 if engine.settingsChanged then engine.settingsChanged=false; dirty() end
 writeJournal(false)
 if engine.rebaseDelta>0 then
  Applier.rebase(host,engine.rebaseDelta); calibration.startAt=calibration.startAt-engine.rebaseDelta
  frame.metaAt=frame.metaAt-engine.rebaseDelta; frame.playerDamageAt=frame.playerDamageAt-engine.rebaseDelta
  lastCheckpoint=lastCheckpoint-engine.rebaseDelta; lastRaceSave=lastRaceSave-engine.rebaseDelta
  journal.flushAt=journal.flushAt-engine.rebaseDelta; journal.summaryAt=journal.summaryAt-engine.rebaseDelta
 end
 if host.session~=frame.session then Applier.nextSession(host,frame) end
 if not valid or frame.online or frame.replay or frame.paused then return end
 if not ready and not engine.recalibrateRequested and calibration.index==0 and host.caps.probeIndex==0 then
  -- Drapeau natif imposé rendu à AC même sans voiture suivie (app désactivée, onglets décochés, rechargement).
  if not anyOwned() then
   if host.flagOverride and Applier.access(host) then Applier.flag(host,frame,false) end
   -- DRS coupé par les règles (aucune voiture suivie pour autant) : rendu à toutes les voitures, joueur compris.
   if (host.drsAny or host.drsRelease) and Applier.access(host) then Applier.drs(host,frame,nil,engine.time); Applier.checkpoint(host,frame) end
   -- App désactivée : drapeau noir levé, la disqualification du joueur avec.
   if not globals.enabled and host.blackFlag and Applier.access(host) then
    Applier.releaseBlackFlag(host); if not host.blackFlag then engine.penalties.disqualified=false; engine.penalties.kind='slow' end
   end
   Applier.save(host,globals,profiles,engine.time,frame.replay); return
  end
 end
 local access=Applier.access(host)
 if not access then engine.guard='access'; return end
 if engine.recalibrateRequested then
  stop()
  if calibration.index>0 or anyOwned() then calibration.phase='waiting_reset'; return end
  globals.offsetSign=0; globals.sideSign=0; calibration.attempted=false; calibration.phase='waiting'
  engine.recalibrateRequested=false; Engine.reset(engine,engine.time,false); dirty()
 end
 if not ready then stop(false,engine.guard=='finished'); Applier.save(host,globals,profiles,engine.time,frame.replay); return end
 for i=1,frame.count do
  local state=engine.states[i]
  frame.cars[i].calibrationBlocked=state.state~='DRIVE' or state.excluded or engine.commands[i].active~=true
 end
 if loadedTrack~=frame.track then
  loadedTrack=frame.track; engine.zones={}; engine.zoneStart=-1; local data=Snapshot.zones(frame.track)
  -- Beta 1.32 : panneaux lumineux du circuit cherchés dans sa configuration (et drapeaux d'AC masqués relus).
  local lights=Applier.trackLights(host,frame.track)
  U.log(engine.log,engine.time,'INFO',lights==true and 'panneaux lumineux du circuit: detectes ('..host.trackLightsSource..')' or lights==false and 'panneaux lumineux du circuit: non detectes' or 'panneaux lumineux du circuit: configuration illisible',-1)
  if data then
   local zones,err=Zones.parse(data)
   if zones then engine.zones=zones; U.log(engine.log,engine.time,'INFO','zones_loaded',-1)
   else U.log(engine.log,engine.time,'WARN','zones_rejected:'..err,-1) end
  end
 end
 Applier.restore(host,frame,true,engine.time)
 syncRestored()
 local probeBefore=host.caps.probeIndex
 if Config.on(engine.p,'general') then Caps.probe(host.caps,frame,engine.time,engine.runtimeG)
 else cancelProbe(); Caps.mode(host.caps,engine.runtimeG) end
 if probeBefore==0 and host.caps.probeIndex>0 then
  local index=host.caps.probeIndex; local s=host.cars[index]; local car=frame.cars[index]
  if not s.owned then s.owned=true; s.id=car.identity or car.id; s.originalLevel=host.caps.probeOriginal; s.originalAggression=car.aiAggression end
  s.level=K.probeLevel; host.recoveryDirty=true; Applier.checkpoint(host,frame)
 elseif probeBefore>0 and host.caps.probeIndex==0 then
  -- Fin de sonde : le niveau d'origine vient d'être réécrit ; le suivi d'écriture le reflète.
  local s=host.cars[probeBefore]
  if s.owned and s.level~=nil then s.level=host.caps.probeOriginal; s.levelAt=engine.time end
 end
 local signBefore=globals.offsetSign
 if Config.needsOffset(engine.run) then Calibration.step(calibration,frame,host.caps,globals,engine.time)
 elseif calibration.index>0 then stop() end
 if signBefore~=globals.offsetSign and globals.offsetSign~=0 then U.log(engine.log,engine.time,'INFO',string.format('sens lateral mesure: %d / %d',globals.offsetSign,globals.sideSign),-1) end
 if signBefore~=globals.offsetSign or engine.settingsChanged then engine.settingsChanged=false; dirty() end
 if calibration.index>0 then
  local index=calibration.index; engine.commands[index].active=false
  local s=host.cars[index]; local car=frame.cars[index]
  if not s.owned then s.owned=true; s.id=car.identity or car.id; s.originalLevel=car.aiLevel; s.originalAggression=car.aiAggression end
  s.offset=K.calibrationOffset
  s.offsetReset=false
  if engine.time==calibration.startAt then host.recoveryDirty=true; Applier.checkpoint(host,frame) end
 end
 Config.effectiveGlobals(globals,engine.p,engine.runtimeG)
 host.calibrationIndex=calibration.index
 Applier.apply(host,frame,engine.commands,engine.runtimeG,engine.time)
 -- Drapeau du joueur : panneaux lumineux du circuit (option, circuit équipé) ; sinon jaune natif du HUD sur demande.
 local lightsOn=globals.trackLights==true and host.trackLights==true
 local flagValue,flagReason=Lights.output(engine.lights,engine.incidents,lightsOn,host.raceFlagsHidden)
 Applier.flag(host,frame,flagValue,flagReason,lightsOn and engine.time or nil)
 Applier.penalty(host,frame,engine.penalties)
 Applier.beep(host,frame,engine.drs)
 Applier.deltaBeep(host,frame,engine.deltaBeep)
 Applier.drs(host,frame,engine.commands,engine.time)
 announce()
 local periodic=engine.time-lastCheckpoint>=K.saveDelay
 if host.recoveryDirty or periodic then lastCheckpoint=engine.time; Applier.checkpoint(host,frame,periodic) end
 saveRace(false)
 Applier.save(host,globals,profiles,engine.time,frame.replay)
end
local function protect(fn,arg)
 local ok,err=pcall(fn,arg)
 if not ok then
  engine.errors=engine.errors+1; engine.panic=true
  U.log(engine.log,engine.time,'ERROR',tostring(err):sub(1,256),-1)
  pcall(stop)
 end
end
HUMANAI={engine=engine,host=host,release=release}
function script.HUMANAI__UPDATE(dt)
 local before=Applier.clock(host)
 protect(update,dt)
 local after=before and Applier.clock(host)
 if after then
  local cost=math.max(0,after-before)*1000
  engine.maxFrame=math.max(engine.maxFrame,cost)
  engine.meanFrame=engine.meanFrame+(cost-engine.meanFrame)/math.max(1,math.min(engine.frames,K.performanceWindow))
 end
end
-- Un seul point d'entrée par image, actif aussi lorsque le setup est ouvert.
function script.update(dt) script.HUMANAI__UPDATE(dt) end
function script.HUMANAI__MENU() if not released then Applier.menu(host,Snapshot.menu()) end end
-- Fenêtres de réglage : une erreur d'affichage est journalisée (une fois par message) sans arrêter le moteur.
local lastUIError=''
local function protectUI(fn,arg)
 local ok,err=pcall(fn,arg)
 if not ok then
  host.errors=host.errors+1
  local text=tostring(err):sub(1,200)
  if text~=lastUIError then lastUIError=text; U.log(engine.log,engine.time,'ERROR','ui:'..text,-1) end
 end
end
function script.HUMANAI__MAIN()
 script.HUMANAI__MENU()
 if host.menuVisible then
  -- Une seule fois : fenêtre ramenée à la taille compacte (Beta 1.14), puis la taille du pilote est respectée.
  if not globals.windowCompacted and Applier.compactWindow(host,UI.compactSize()) then globals.windowCompacted=true; dirty() end
  protectUI(UI.main,panel)
 end
end
-- Panneau de drapeaux : protégé comme les autres fenêtres ; une erreur d'affichage est journalisée une fois et
-- n'arrête jamais le moteur.
function script.HUMANAI__FLAGS() if not released then protectUI(UI.flags,panel) end end
-- Overlay en jeu (Beta 1.25, rappel IN_GAME) : fenêtre transparente dessinée par l'app, comme SuperHUD.
function script.HUMANAI__HUD()
 if released then return end
 protectUI(UI.hud,panel)
 pcall(messages,globals.overlayMessages and globals.overlayBlockMessages and globals.enabled)
end
