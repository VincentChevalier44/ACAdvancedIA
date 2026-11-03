local U=require('src/util')
local C=require('src/config')
local Director=require('src/director')
local Perception=require('src/perception')
local Flash=require('src/flash')
local Classes=require('src/classes')
local Traffic=require('src/traffic')
local Weather=require('src/weather')
local Incidents=require('src/incidents')
local Pits=require('src/pits')
local Panel=require('src/panel')
local Penalties=require('src/penalties')
local Delta=require('src/delta')
local Mistakes=require('src/mistakes')
local HudInfo=require('src/hudinfo')
local Flood=require('src/flood')
local Lights=require('src/lights')
local Grid=require('src/grid')
local K=C.K
local M={}
-- Journal du départ (Beta 1.24) : maintien de ligne (IA mesurées, décalées de la trajectoire) et pneus de chaque IA,
-- pour vérifier en jeu le premier virage et les gommes montées.
local function startReport(e,frame,now)
 local n,measured,offset,held,sides=0,0,0,0,0; local tyres,order={},{}
 e.startRadar=0; e.startSpeedLogged=false
 for i=1,frame.count do
  local a=frame.cars[i]
  if a.valid and a.control and not a.player and not a.safetyCar then
   n=n+1
   if a.splineLatValid then measured=measured+1 end
   if (e.states[i].laneMeters or 0)~=0 then offset=offset+1 end
   if (e.states[i].lane or 0)~=0 then held=held+1 end
   if (a.leftWidth or 0)>0 and (a.rightWidth or 0)>0 then sides=sides+1 end
   local index=a.compoundIndex or -1
   local key=index..' '..((a.tyreNames and a.tyreNames[index] or '?')..' '..(a.tyreLongNames and a.tyreLongNames[index] or ''))
   if not tyres[key] then tyres[key]=0; order[#order+1]=key end
   tyres[key]=tyres[key]+1
  end
 end
 U.log(e.log,now,'INFO',string.format('depart: maintien de ligne %s, %d IA, trajectoire mesuree %d, decalees %d, maintenues %d, largeur connue %d, signe %d ; prudence x%.2f, agressivite x%.2f ; drapeaux bleus %s (%.0f m) ; radar avant %s',
  e.run.startLaneHold and 'actif' or 'coupe',n,measured,offset,held,sides,e.runtimeG.offsetSign or 0,e.run.startCautionMult,e.run.startAggrMult,e.run.blueFlagEnabled and 'actifs' or 'coupes',e.run.blueFlagRange,e.runtimeG.useBrakeAssist and 'actif' or 'coupe'),-1)
 local parts={}; for _,key in ipairs(order) do parts[#parts+1]=tyres[key]..' x '..key end
 U.log(e.log,now,'INFO','pneus au depart: '..(#parts>0 and table.concat(parts,', ') or 'inconnus'),-1)
end
-- Délai laissé à la direction de course avant l'évacuation d'une IA immobile en pleine piste (Beta 1.24), pour ne
-- jamais court-circuiter les règles : incident majeur puis neutralisation choisie (VSC, FCY, voiture de sécurité),
-- escalade en voiture de sécurité ou drapeau rouge (plusieurs voitures en cause en piste), neutralisation en cours.
-- 0 : aucune règle ne peut découler de cette voiture (seule en piste sous drapeau jaune local), évacuation rapide.
local function decisionTime(e,neutral)
 local p,t=e.run,e.incidents
 local race=e.profile=='C'
 local escalation=race and p.safetyCarEscalation and t.safety>0 and not t.safetyFailed
 local red=(race or e.profile=='P' or e.profile=='Q') and p.redFlagEnabled
 local several=t.onTrack>=2
 local delay=0
 -- Délais de la Beta 1.23 : fenêtre du drapeau rouge (5 s d'arrêt simultané) et de l'escalade.
 if neutral or several and (red or escalation) then delay=K.neutralRecoverTime end
 -- Incident majeur déclaré à majorIncidentTime s : la neutralisation (ou l'escalade) a le temps d'être décidée.
 if race and p.neutralization~='local' or (neutral or several) and escalation then delay=math.max(delay,p.majorIncidentTime+K.ruleDecision) end
 return delay
end
-- Journal des contacts entre voitures (Beta 1.24) : qui touche qui et comment, une fois par paire toutes les
-- K.contactLogPeriod s, pour régler le radar sur des faits. Au plus K.contactLogBudget lignes par seconde entre IA
-- (un carambolage ne noie pas les lignes d'incident) ; un contact avec le joueur est toujours noté.
local function contacts(e,frame,now)
 local second=math.floor(now)
 if e.contactSecond~=second then e.contactSecond=second; e.contactCount=0 end
 for i=1,frame.count do
  local a=frame.cars[i]; local j=a.collidedWith or -1
  if a.valid and j>=1 and j<=frame.count and j~=i and frame.cars[j].valid then
   local key=i<j and i*K.maxCars+j or j*K.maxCars+i
   local next=e.contacts[key]
   local b=frame.cars[j]
   if (not next or now>=next or next-now>K.contactLogPeriod) and (a.player or b.player or e.contactCount<K.contactLogBudget) then
    e.contacts[key]=now+K.contactLogPeriod
    if not a.player and not b.player then e.contactCount=e.contactCount+1 end
    local rel=Perception.relative(a,b,frame.length,e.contactRel)
    local text
    if math.abs(rel.lat)>=(a.width+b.width)*0.5 then text=string.format('contact: %s et %s se touchent sur le cote',a.name,b.name)
    elseif rel.long>0 then text=string.format('contact: %s touche l arriere de %s',a.name,b.name)
    else text=string.format('contact: %s touche l arriere de %s',b.name,a.name) end
    U.log(e.log,now,'INFO',string.format('%s (%.0f km/h d ecart)',text,math.abs(a.kmh-b.kmh)),i)
   end
  end
 end
end
-- Message à l'écran de chaque pénalité du joueur.
local penaltyMessages={delta='penaltyDelta',pass='penaltyPass',red='penaltyRed',stop='penaltyStop',jump='penaltyJump'}
function M.new(g,profiles)
 local initial=g.autoProfile and 'J' or g.manualProfile
 local e={g=g,profiles=profiles,profile=initial,p=profiles[initial],states={},commands={},perception=Perception.new(),
  flash=Flash.new(),classes=Classes.new(),traffic=Traffic.new(),weather=Weather.new(),incidents=Incidents.new(),pits=Pits.new(),panel=Panel.new(),penalties=Penalties.new(),delta=Delta.new(),mistakes=Mistakes.new(),deltaBeep={beepId=0,volume=1,nextAt=0},drsRule={restart=false,started=false,seen=false,travel={},last={},leader=0,reason=''},drs={was=false,beepId=0,volume=1},run={},runtimeG={},zones={},frame=nil,time=0,startedAt=0,session=-1,sessionType=-1,
  configured='',seed=-1,revision=0,configuredRevision=-1,eventSalt=0,wasStarted=false,
  log=U.newLog(K.logLines,K.logRate,K.logDedup),errors=0,frames=0,activeCount=0,maxFrame=0,meanFrame=0,
  guard='init',panic=false,returning=false,pitSpline=-1,zoneStart=-1,
  flood={user='',system=nil,writable=false,loaded=false,minLength=K.floodMinLength,at=0},probeSeen=false}
 e.announce=function(kind,value,extra) Incidents.message(e.incidents,kind,value,extra) end
 -- Événements des modules purs vers le journal circulaire (et le journal de session sur disque).
 e.note=function(level,message,index) U.log(e.log,e.time,level,message,index) end
 -- Compteurs d'événements de la minute écoulée, relevés et remis à zéro par le résumé du journal.
 e.stats={}
 -- Informations de l'overlay (Beta 1.25), lues par le panneau.
 e.hud=HudInfo.new(); e.panel.info=e.hud
 -- Panneaux lumineux du circuit et signaux FIA du joueur (Beta 1.32) ; dernier véhicule lent annoncé au journal.
 e.lights=Lights.new(); e.slowLogged=0
 -- Départ arrêté après un drapeau rouge (Beta 1.34) : places de grille, formation, feux ; capacités vues par le
 -- script principal (retenue, allure, décalage).
 e.grid=Grid.new(); e.gridCaps=false
 -- Contacts déjà notés (Beta 1.24) : prochaine ligne permise par paire de voitures.
 e.contacts={}; e.contactRel={}; e.contactSecond=-1; e.contactCount=0
 e.incidents.note=e.note; e.pits.note=e.note
 for i=1,K.maxCars do
  local s=Director.newState(); s.slot=i; e.states[i]=s
  e.commands[i]={active=false,offset=0,level=1,aggression=0.5,caution=1,brake=0,speedLimit=K.unlimitedSpeed,yellowLimit=K.unlimitedSpeed,stopHold=false,recover=false,flashEvent=0,rulePit=false,pitHold=false,pitCompound=-1,pitVisit=0,scPark=false,scSpeed=K.unlimitedSpeed,mistakeId=0,mistakeKind='',mistakeCause='',mistakeTime=0,mistakeSeverity=1,fuelTarget=-1,fuelLaps=0,fuelSet=-1,pitRepair=false,startDelay=-1,startDelayFor=''}
 end
 return e
end
function M.changed(e) e.revision=(e.revision+1)%K.counterMax end
function M.select(e,profile)
 if e.profiles[profile] then e.profile=profile; e.p=e.profiles[profile]; e.g.manualProfile=profile; e.g.autoProfile=false; M.changed(e) end
end
function M.reset(e,now,keepOffset)
 for i=1,K.maxCars do Director.reset(e.states[i],now,keepOffset,true); e.commands[i].active=false end
 e.pitSpline=-1; e.eventSalt=(e.eventSalt+1)%K.counterMax; e.returning=keepOffset
end
function M.rebase(e,amount)
 e.time=e.time-amount; e.startedAt=e.startedAt-amount; if e.launchAt then e.launchAt=e.launchAt-amount end; if e.jumpGoAt then e.jumpGoAt=e.jumpGoAt-amount end; e.panel.at=e.panel.at-amount; Penalties.rebase(e.penalties,amount); Delta.rebase(e.delta,amount); Mistakes.rebase(e.mistakes,amount); e.deltaBeep.nextAt=e.deltaBeep.nextAt-amount
 if e.panel.noticeUntil>-math.huge then e.panel.noticeUntil=e.panel.noticeUntil-amount end
 if e.panel.warnUntil>-math.huge then e.panel.warnUntil=e.panel.warnUntil-amount end
 Lights.rebase(e.lights,amount); Grid.rebase(e.grid,amount)
 if e.slowLoggedAt then e.slowLoggedAt=e.slowLoggedAt-amount end
 if e.panel.changedAt>-math.huge then e.panel.changedAt=e.panel.changedAt-amount end
 e.classes.nextAt=e.classes.nextAt-amount; e.classes.bopAt=e.classes.bopAt-amount
 e.traffic.nextAt=e.traffic.nextAt-amount
 e.weather.pendingAt=e.weather.pendingAt-amount
 Incidents.rebase(e.incidents,amount); Pits.rebase(e.pits,amount)
 for i=1,K.maxCars do
  local s=e.states[i]
  for _,key in ipairs(C.timerFields) do if U.finite(s[key]) then s[key]=s[key]-amount end end
  for _,key in ipairs(C.optionalTimerFields) do if s[key]>0 then s[key]=s[key]-amount end end
  for j=1,K.directionLimit do if U.finite(s.directions[j]) then s.directions[j]=s.directions[j]-amount end end
  local r=e.flash.requests[i]; r.untilTime=r.untilTime-amount; r.readyAt=r.readyAt-amount; r.cornerUntil=r.cornerUntil-amount
  local q=e.flash.ai[i]; q.untilTime=q.untilTime-amount; q.readyAt=q.readyAt-amount
  if U.finite(r.lastSeen) then r.lastSeen=r.lastSeen-amount end
 end
 local f=e.flash
 f.onAt=f.onAt-amount
 if f.learnUntil>0 then f.learnUntil=f.learnUntil-amount end
 if U.finite(f.lastEdge) then f.lastEdge=f.lastEdge-amount end
 if U.finite(f.lastPulse) then f.lastPulse=f.lastPulse-amount end
 if U.finite(f.lastEvent) then f.lastEvent=f.lastEvent-amount end
 if U.finite(f.eventTime) then f.eventTime=f.eventTime-amount end
 for i=1,K.logLines do if U.finite(e.log[i].time) then e.log[i].time=e.log[i].time-amount end end
 e.log.second=-1; e.rebaseDelta=amount
end
function M.configure(e)
 e.p=e.profiles[e.profile]
 C.effective(e.profile,e.p,e.run); C.effectiveGlobals(e.g,e.p,e.runtimeG)
 for i=1,K.maxCars do
  Director.configure(e.states[i],e.runtimeG,e.profile,e.run,e.time); e.states[i].nextPerception=e.time+(i%10)*K.perceptionPeriod/10
  local car=e.frame and e.frame.cars[i]
  if car and not e.p.section_general then e.commands[i].level=car.baseLevel or car.aiLevel; e.commands[i].aggression=car.baseAggression or car.aiAggression; e.commands[i].caution=K.defaultCaution end
 end
 local previous=e.flash; e.flash=Flash.new()
 -- Un apprentissage des phares en cours survit à un changement de réglage.
 if previous.learnUntil>0 then e.flash.learnUntil=previous.learnUntil; e.flash.scores=previous.scores; e.flash.last=previous.last end
 Classes.configure(e.classes,e.run); e.classes.nextAt=0; e.traffic.nextAt=0
 e.configured=e.profile; e.seed=e.g.seed; e.configuredRevision=e.revision
end
-- Pilotage des voitures first à last, chacune protégée par l'appel de l'appelant : carAt désigne la voiture fautive.
local carAt=0
-- DRS du joueur : bip au moment où il devient disponible (écriture sonore par l'applicateur) ; jamais sous drapeau.
local function drsBeep(e,frame,flagged,assist,volume)
 local driver=frame.player>0 and frame.cars[frame.player] or nil
 local available=assist and driver and driver.valid and driver.drsPresent and driver.drsAvailable and not flagged or false
 if available and not e.drs.was then e.drs.beepId=e.drs.beepId%K.counterMax+1; e.drs.volume=volume/100 end
 e.drs.was=available
end
local function drive(e,first,last,dt,now)
 for i=first,last do
  carAt=i
  local s=e.states[i]
  if s.excluded or now<s.errorUntil then e.commands[i].active=false
  else
   Director.step(e,i,dt,now)
   s.errorCount=0
   if e.commands[i].active then e.activeCount=e.activeCount+1 end
  end
 end
end
-- Message d'AC (ac.onMessage, Beta 1.25) : repris sur la ligne de session de l'overlay ; chaque titre noté une fois par
-- session au journal (pour savoir lesquels masquer ensuite).
function M.message(e,title,description,kind,time)
 -- Message témoin du masquage (Beta 1.26) : seulement noté, jamais affiché.
 if title==K.messageProbe then e.probeSeen=true; return end
 if not e.g.overlayMessages then return end
 if HudInfo.message(e.hud,title,description,kind,time,e.time or 0) then
  U.log(e.log,e.time or 0,'INFO',string.format('message d AC: %s%s%s',tostring(title or ''),(description or '')~='' and ' : ' or '',tostring(description or '')),-1)
 end
end
-- AI flood de CSP (Beta 1.26) : état lu au lancement (CSP le charge alors), puis réglage géré en journée circuit.
function M.floodInit(e,user,system,writable)
 local f=e.flood
 f.user=type(user)=='string' and user or ''; f.system=system; f.writable=writable==true; f.at=0
 f.loaded,f.minLength=Flood.state(f.user,system)
 U.log(e.log,0,'INFO',string.format('AI flood de CSP au lancement: %s (circuits d au moins %.1f km)%s',f.loaded and 'actif' or 'inactif',f.minLength/1000,f.writable and '' or ', reglage non modifiable par l app'),-1)
end
-- Journée circuit : réglage écrit selon la répartition choisie et le nombre d'IA (Flood.decide). CSP le lit au
-- lancement : la session en cours garde l'état chargé (e.flood.loaded) ; chaque écriture est annoncée sur l'overlay
-- et au journal. Réglage d'origine sauvegardé avant la première écriture (g.floodBackup), rendu en mode natif.
local function flood(e,frame,now)
 local f=e.flood
 if e.profile~='J' or not f.writable or frame.online or now<f.at then return end
 f.at=now+K.floodPeriod
 local count=0
 for i=1,frame.count do local a=frame.cars[i]; if a.valid and a.control and not a.player and not a.safetyCar then count=count+1 end end
 if count==0 then return end
 local decision=Flood.decide(e.run,count)
 if decision=='restore' and e.g.floodBackup=='' then return end
 local values=decision=='restore' and Flood.restore(e.g.floodBackup) or Flood.values(decision=='on',e.run.floodRangeKm)
 local text=Flood.edit(f.user,Flood.section,values)
 if text==f.user then
  if decision=='restore' then e.g.floodBackup=''; e.settingsChanged=true end
  return
 end
 local backup=e.g.floodBackup=='' and decision~='restore' and Flood.backup(f.user) or nil
 if not (e.floodWrite and e.floodWrite(text)) then
  f.writable=false
  U.log(e.log,now,'WARN','AI flood de CSP: ecriture du reglage impossible (cfg/extension/new_behaviour.ini)',-1)
  return
 end
 f.user=text
 if backup then e.g.floodBackup=backup elseif decision=='restore' then e.g.floodBackup='' end
 e.settingsChanged=true
 U.log(e.log,now,'INFO',string.format('AI flood de CSP: %s (%d IA, seuil %d, portee %.1f km), effet au prochain lancement',decision=='off' and 'desactive' or decision=='on' and 'active' or 'reglage d origine rendu',count,e.run.spawnMinCars or 0,e.run.floodRangeKm or 1),-1)
 HudInfo.flood(e.hud,decision,count,e.run.floodRangeKm or 1,now)
end
-- IA anormalement lente (Beta 1.28, diagnostic seulement) : en piste, hors stands et zone jaune, en conduite, en
-- cession ou en dépassement (jamais en évitement ni au calme après un incident), plus lente que K.slowRatio fois l'allure de sa classe à cet endroit (allure apprise), avec une
-- voiture derrière à moins de K.slowFollowGap m, pendant K.slowLogTime s : une ligne au journal (cause probable :
-- limite de l'app, dégâts, stands), puis une à la fin de l'épisode. Rien n'est commandé.
local slowStates={DRIVE=true,YIELD_IN=true,YIELD_HOLD=true,YIELD_OUT=true,OVT_ARM=true,OVT_IN=true,OVT_HOLD=true,OVT_OUT=true,DEFEND=true}
local function slowCars(e,frame,now,dt)
 local multi=e.run.multiClass==true
 for i=1,frame.count do
  local a=frame.cars[i]; local s=e.states[i]; local cmd=e.commands[i]
  if a.teleport then s.slowTeleportAt=now end
  local behind,expected=0,0
  if a.valid and a.control and not a.player and not a.safetyCar and not a.pit and not a.inPitBox and not a.offtrack and a.splineValid
   and not s.yellow and slowStates[s.state] and now-(s.slowTeleportAt or -math.huge)>=K.slowSettle then
   local fleet=e.delta.fleet[multi and s.class or 1]
   expected=fleet and fleet[Delta.bin(a.spline)] or 0
   if expected*3.6>=K.slowMinPaceKmh and a.kmh>=K.slowMinKmh and a.speed<expected*K.slowRatio then
    local row=e.perception.rows[i]
    for j=1,row.count do local r=row.neighbors[j]; if r.long<0 and r.gap<K.slowFollowGap then behind=behind+1 end end
   end
  end
  if behind>0 then
   s.slowFor=(s.slowFor or 0)+dt; s.slowCalm=0; a.watchDamage=s.slowFor>=K.slowLogTime*0.5
   if not s.slowLogged and s.slowFor>=K.slowLogTime then
    s.slowLogged=true
    local cap=math.min(cmd.speedLimit or K.unlimitedSpeed,cmd.yellowLimit or K.unlimitedSpeed,cmd.scSpeed or K.unlimitedSpeed)
    local capText=cap<K.unlimitedSpeed and string.format('%.0f km/h',cap) or 'aucune'
    U.log(e.log,now,'WARN',string.format('IA anormalement lente: %s (%s) a %.0f km/h depuis %.0f s, allure de sa classe ici %.0f km/h, %d voiture(s) derriere a moins de %.0f m | etat %s, commande app %s, limite de vitesse app %s, niveau %.2f, degats carrosserie %.0f, suspension %.2f, moteur %.0f, boite %.2f',
     a.name,a.id,a.kmh,s.slowFor,expected*3.6,behind,K.slowFollowGap,s.state,cmd.active and 'oui' or 'non',capText,cmd.level or 0,a.damageBody or 0,a.damageSuspension or 0,a.engineLife or 0,a.damageGearbox or 0),i)
   end
  elseif (s.slowFor or 0)>0 then
   s.slowCalm=(s.slowCalm or 0)+dt
   if s.slowCalm>=K.slowEnd then
    if s.slowLogged then U.log(e.log,now,'INFO',string.format('IA anormalement lente: %s roule de nouveau normalement apres %.0f s',a.name,s.slowFor),i) end
    s.slowFor=0; s.slowCalm=0; s.slowLogged=false; a.watchDamage=false
   end
  end
 end
end
function M.step(e,frame,dt)
 e.frame=frame
 e.rebaseDelta=0
 if not U.finite(dt) or dt<=0 or dt>K.dtMax then
  e.guard='dt'; for i=1,K.maxCars do local s=e.states[i]; s.velocity=0; s.filtered=s.offset; e.commands[i].active=false end
  return false
 end
 if not frame.paused and not frame.replay then e.time=e.time+dt end
 if e.time>K.timeWrap then M.rebase(e,K.timeWrap) end
 local now=e.time
 -- DRS du joueur : disponibilité décidée par AC (zones et points de détection), notée à chaque changement.
 local me=frame.player>0 and frame.cars[frame.player] or nil
 local drsNow=me and me.valid and me.drsPresent and (me.drsAvailable and 1 or 0) or -1
 if drsNow~=e.playerDrs then
  if drsNow>=0 then U.log(e.log,now,'INFO',drsNow==1 and 'DRS joueur: disponible (AC)' or 'DRS joueur: indisponible (AC)',frame.player) end
  e.playerDrs=drsNow
 end
 if e.session~=frame.session or e.sessionType~=frame.type then
  e.session=frame.session; e.sessionType=frame.type
  M.reset(e,now,true); e.wasStarted=frame.started; e.startedAt=frame.started and now-frame.time or now; e.launchAt=nil; e.jumpDue=false
  e.classes.nextAt=0; e.flash=Flash.new()
  e.weather=Weather.new(); Incidents.reset(e.incidents); Pits.reset(e.pits,now); Penalties.reset(e.penalties); Delta.reset(e.delta); Mistakes.reset(e.mistakes); Lights.reset(e.lights); Grid.reset(e.grid); e.slowLogged=0; e.panel.warnPending=false; e.panel.warnUntil=-math.huge; e.drsRule={restart=false,started=false,seen=false,travel={},last={},leader=0,reason=''}
  e.configuredRevision=-1
  for i=1,K.maxCars do
   local s=e.states[i]; s.stint=0; s.stintStart=now; s.class=2; s.classified=false; s.classCandidate=0; s.classCycles=0
   s.paceCount=0; s.paceMean=0; s.paceRatio=0; s.paceRatioCount=0; s.freePace=0; s.lastContact=now
   s.excluded=false; s.disqualified=false; s.errorUntil=0; s.errorCount=0; s.pitBefore=false; s.pitExitUntil=0; s.pitCautionUntil=0; s.pitGuardUntil=0; s.obstacleSlow=0
   for j=1,K.paceBins do s.pace[j]=0 end
  end
 end
 if e.g.autoProfile then e.profile=C.autoProfile(frame)
 elseif not e.g.autoProfile then e.profile=e.g.manualProfile end
 local newProfile=e.loggedSession~=e.session or e.loggedProfile~=e.profile
 if newProfile then
  if e.loggedSession~=e.session then
   U.log(e.log,now,'INFO',string.format('session: indice %d, type CSP %d, type race.ini %d%s, circuit %s, voitures %d, longueur %.0f m',
    frame.session,frame.type,frame.configType,frame.configTrackDay and ' (Track Day)' or '',frame.track,frame.count,frame.length),-1)
  end
  U.log(e.log,now,'INFO','profil: '..e.profile..(e.g.autoProfile and ' (automatique)' or ' (manuel)'),-1)
  e.loggedSession=e.session; e.loggedProfile=e.profile
 end
 local selected=e.profiles[e.profile]
 -- Profil Hotlap : aucun préréglage recommandé (sessions sans IA), il reste neutre.
 if e.g.presetsUsed and selected and not selected.configured and not C.anySection(selected) and C.recommended[e.profile] then
  -- Profil jamais réglé : son préréglage intégré recommandé, une seule fois. Un profil déjà réglé n'est jamais modifié.
  local name=C.recommended[e.profile]
  -- Beta 1.29 : règles de championnat du week-end gardées (copiées par le préréglage d'une autre session).
  local rules=e.keptWeekendRules or {}; e.keptWeekendRules=rules
  local weekend=not C.solo(e.profile)
  if weekend then for _,s in ipairs(C.ruleSchema) do rules[s.key]=selected[s.key] end end
  -- Beta 1.29 (demande du pilote) : appliqué tout seul, il n'est pas noté comme chargé par le pilote.
  C.preset(name,e.profile,selected)
  if weekend then for _,s in ipairs(C.ruleSchema) do selected[s.key]=rules[s.key] end; C.validate(e.profile,selected,selected) end
  e.settingsChanged=true; M.changed(e); U.log(e.log,now,'INFO','preset_auto:'..name,-1)
 end
 -- Réglages réels de la session dans le journal : onglets cochés du profil et jeu de règles.
 if newProfile and selected then
  local tabs={}; for _,group in ipairs(C.sections) do if C.on(selected,group) then tabs[#tabs+1]=group end end
  U.log(e.log,now,'INFO','onglets: '..(#tabs>0 and table.concat(tabs,',') or 'aucun')..' ; regles: '..(C.on(selected,'rules') and (C.ruleCategory(e.profile,selected,C.switchKeys) or 'personnalisees') or 'decochees'),-1)
  -- Sens latéral (Beta 1.25) : sans lui, aucun déplacement latéral n'est écrit (cession, dépassement, évitement).
  U.log(e.log,now,'INFO',string.format('sens lateral: %d / %d%s',e.g.offsetSign,e.g.sideSign,e.g.offsetSign==0 and ' (en attente de mesure, aucun deplacement lateral)' or ''),-1)
 end
 if e.configured~=e.profile or e.seed~=e.g.seed or e.configuredRevision~=e.revision then
  M.reset(e,now,true); M.configure(e)
 end
 C.effective(e.profile,e.p,e.run); C.effectiveGlobals(e.g,e.p,e.runtimeG)
 if e.returning then
  local settled=true
  for i=1,frame.count do if math.abs(e.states[i].offset-e.states[i].base)>K.offsetEpsilon then settled=false; break end end
  e.returning=not settled
 end
 if frame.started and not e.wasStarted then e.startedAt=now; e.launchAt=nil; if e.profile=='C' then startReport(e,frame,now) end end
 -- Mesure du départ (Beta 1.25) : vitesse moyenne du peloton à la fin de l'attente de départ et freinages du radar
 -- pendant le lancement, pour comparer les départs d'une version à l'autre.
 if e.startSpeedLogged==false and frame.started and now-e.startedAt>=e.run.startDelay then
  e.startSpeedLogged=true
  local sum,n=0,0
  for i=1,frame.count do local a=frame.cars[i]; if a.valid and a.control and not a.player and not a.safetyCar and not a.pit then sum=sum+a.kmh; n=n+1 end end
  U.log(e.log,now,'INFO',string.format('depart: peloton a %.0f km/h en moyenne apres %.0f s, %d freinage(s) du radar au lancement',n>0 and sum/n or 0,e.run.startDelay,e.startRadar or 0),-1)
 end
 e.wasStarted=frame.started
 -- Maintien de ligne au départ : écart à la trajectoire lu dans l'instantané suivant, pendant le départ seulement.
 frame.laneWanted=e.profile=='C' and e.run.startLaneHold==true and (not frame.started or now-math.max(e.startedAt,e.launchAt or -math.huge)<e.run.startDelay+e.run.startRelax)
 -- Informations de l'overlay (Beta 1.25) : à chaque image, même app à l'arrêt ou session finie ; récapitulatif de
 -- course noté une fois au journal.
 HudInfo.update(e.hud,frame,e,now)
 if e.hud.recapNew then
  e.hud.recapNew=false
  U.log(e.log,now,'INFO','fin de course: '..table.concat(e.hud.recap,' | '),frame.player)
 end
 local reason=not e.g.enabled and 'disabled' or frame.online and 'online' or frame.replay and 'replay' or frame.paused and 'paused'
  or frame.finished and 'finished' or frame.length<=0 and 'spline' or e.panic and 'panic' or not C.any(e.p) and 'nosections' or 'ready'
 e.guard=reason
 if reason~='ready' then
  for i=1,K.maxCars do local cmd=e.commands[i]; cmd.active=false; cmd.stopHold=false; cmd.rulePit=false; cmd.pitHold=false; cmd.pitCompound=-1; cmd.fuelTarget=-1; cmd.fuelSet=-1; cmd.scPark=false; cmd.scSpeed=K.unlimitedSpeed; cmd.recover=false; cmd.drsBlock=false; cmd.startDelay=-1 end
  -- App à l'arrêt : le panneau reprend encore les drapeaux d'AC (leur affichage d'origine est masqué dans CSP).
  e.incidents.playerFlag=false; e.incidents.playerYellow=false
  -- Pause : valeur des panneaux gardée (l'applicateur n'écrit rien en pause) ; sinon rendue à AC et recalculée dès la
  -- reprise (jamais un quart de seconde rendu à AC à chaque sortie de pause, Beta 1.35).
  if reason~='paused' then e.lights.value=K.flagNone; e.lights.reason=''; e.lights.at=-math.huge end; Panel.native(e.panel,frame,now,e.p,e.profile)
  -- Aucun onglet coché (hotlap, journée circuit sans commande) : le bip du DRS du joueur reste actif ; app coupée,
  -- panique, pause : aucun bip.
  if reason=='nosections' then drsBeep(e,frame,frame.flag==K.flagCaution and not frame.flagOwned,e.p.drsAssist~=false,e.p.drsBeepVolume or 100) else e.drs.was=false end
  return false
 end
 e.frames=(e.frames+1)%K.counterMax; e.activeCount=0
 flood(e,frame,now)
 Traffic.update(e.traffic,frame,e.states,e.run,e.runtimeG,e.profile,now,e.log)
 Traffic.exits(e.traffic,frame,e.run,e.runtimeG,e.profile,now,e.commands,e.log,e.flood.loaded and frame.length>=e.flood.minLength)
 contacts(e,frame,now)
 for i=1,frame.count do
  local a=frame.cars[i]; local state=e.states[i]
  if state.obstacleIdentity~=(a.identity or a.id) then state.obstacleSlow=0; a.stopped=0; state.obstacleIdentity=a.identity or a.id end
  if a.valid and not a.pit and a.kmh<e.run.obstacleSpeedKmh then state.obstacleSlow=math.min(K.stoppedTime+K.dtMax,math.max(state.obstacleSlow,a.stopped)+dt)
  else state.obstacleSlow=0 end
  a.stopped=state.obstacleSlow
  if a.pit and a.splineValid then e.pitSpline=a.spline end
  a.pitDistance=e.pitSpline>=0 and math.abs(U.spline(a.spline-e.pitSpline))*frame.length or math.huge
 end
 -- Voiture de sécurité : modèle choisi, présent sur la grille et piloté par l'IA ; garée aux stands dans toutes les
 -- sessions, déployée seulement en course quand les règles la prévoient.
 local model=e.g.safetyCarModel; local safety,matches,preferred,ais=0,0,0,0
 -- Toutes les IA de ce modèle sont mises de côté (grille « Manuel » de Content Manager : adversaires tirés au sort
 -- parmi les candidats) : celle à la livrée de voiture de sécurité (sinon la première, habillée de cette livrée) sert
 -- de voiture de sécurité, les autres restent garées aux stands dans toutes les sessions et ne courent jamais.
 for i=1,frame.count do
  local a=frame.cars[i]
  if a.valid and a.control and not a.player then ais=ais+1 end
  local reserved=model~='' and a.valid and a.control and not a.player and a.id==model
  if reserved then matches=matches+1; if safety==0 then safety=i end; if preferred==0 and a.skinSafety then preferred=i end end
  a.safetyCar=reserved
 end
 if preferred>0 then safety=preferred end
 -- Course monotype (le joueur roule ce modèle, ou toutes les IA) : aucune concurrente retirée ; seule une voiture à la
 -- livrée de voiture de sécurité le devient, sinon aucune (repli FCY).
 local player=frame.player>0 and frame.cars[frame.player] or nil
 -- Modèle par défaut jamais choisi par le pilote (Ferrari 458 Italia Stage 3, Beta 1.19), courant comme IA : porté par
 -- plusieurs voitures, ce sont des concurrentes ; seule une voiture à la livrée de voiture de sécurité le devient.
 local shared=model~='' and matches>=2 and not e.g.safetyCarPicked
 local oneMake=model~='' and (player~=nil and player.id==model or matches>=2 and matches>=ais or shared)
 if oneMake then
  safety=preferred
  for i=1,frame.count do frame.cars[i].safetyCar=i==safety end
 end
 local state=matches..(oneMake and 'm' or '')..safety
 if state~=e.safetyState then
  e.safetyState=state; e.safetyAmbiguous=matches>1 and not oneMake; e.safetyOneMake=oneMake
  if oneMake then U.log(e.log,now,'WARN',string.format('voiture de securite: modele %s = modele de la grille (%s), %s',model,shared and string.format('modele par defaut porte par %d voitures',matches) or 'monotype',safety>0 and 'seule la voiture a livree de securite est retiree' or 'aucune voiture retiree (repli FCY)'),-1)
  elseif matches>1 then U.log(e.log,now,'WARN',string.format('voiture de securite: modele %s porte par %d voitures, %s deployee, %d garees',model,matches,preferred>0 and 'celle a livree de securite' or 'la premiere',matches-1),-1) end
 end
 e.incidents.safety=safety
 -- Incidents dès l'envol du départ : une grille arrêtée n'est pas une zone jaune, un accrochage au premier virage oui.
 local ready=frame.started and not (e.profile=='C' and now-e.startedAt<K.gridGrace)
 e.incidents.playerExcluded=e.penalties.disqualified
 -- Départ arrêté (Beta 1.34) : retenue, plafond d'allure et décalage disponibles, sens latéral mesuré, longueur de piste
 -- connue ; sinon la relance reste un départ lancé (raison au journal).
 e.incidents.gridReady=e.gridCaps==true and e.g.offsetSign~=0 and frame.length>0
 e.incidents.gridWhy=e.gridCaps~=true and 'capacites' or e.g.offsetSign==0 and 'sens lateral non mesure' or frame.length<=0 and 'circuit' or ''
 Incidents.update(e.incidents,frame,e.run,e.profile,now,dt,ready,e.runtimeG.seed)
 -- Allure de référence de la flotte (temps delta), quelques endroits par image.
 Delta.refresh(e.delta,frame,e.states,e.run.multiClass==true)
 slowCars(e,frame,now,dt)
 -- Beta 1.31 : contexte d'un tête-à-queue d'IA (ce que l'app lui commandait juste avant) et vrais dépassements (deux
 -- voitures à moins de K.realPassGap m qui échangent leur place), avec ou sans manœuvre de l'app, et IA passées devant
 -- le joueur : ce que l'app change se mesure en jeu.
 local stats=e.stats
 for i=1,frame.count do
  local a=frame.cars[i]; local s=e.states[i]; local c=e.incidents.cars[i]
  if c.incident and c.since==now and not a.player and c.spin>=K.spinTime then
   local cmd=e.commands[i]
   U.log(e.log,now,'INFO',string.format('tete-a-queue, contexte: %s | etat %s depuis %.1f s, derniere manoeuvre %s, decalage %+.2f, prudence %.2f (base %.2f), agressivite %.2f (base %.2f), niveau %.2f, aspiration %s, frein app %.2f',
    a.name,s.state,now-s.since,U.finite(s.maneuverAt) and string.format('il y a %.1f s',now-s.maneuverAt) or 'aucune',cmd.offset or 0,cmd.caution or 0,s.baseCaution or 0,cmd.aggression or 0,s.baseAggression or 0,cmd.level or 0,
    (s.slipTime or 0)>K.slipTime and 'oui' or 'non',s.appBrake or 0),i)
  end
  if a.valid and not a.player and not a.pit then
   local row=e.perception.rows[i]
   if s.frontWas>0 then
    -- Position relative directe (abscisse sur la piste), sans parcourir les voisins à chaque image.
    local other=frame.cars[s.frontWas]
    local ahead=other and other.valid and other.splineValid and a.splineValid and U.spline(other.spline-a.spline)*frame.length or nil
    if ahead and ahead<0 and -ahead<=K.realPassGap and not other.pit then
     if other.player then stats.passedPlayer=(stats.passedPlayer or 0)+1
     else
      stats.realPass=(stats.realPass or 0)+1
      if s.lastPassTarget==s.frontWas and now-s.lastPassAt<K.realPassWindow then stats.realPassApp=(stats.realPassApp or 0)+1 end
     end
     s.frontWas=0
    elseif not ahead or math.abs(ahead)>K.realPassGap*2 then s.frontWas=0 end
   end
   local front=row.front>0 and row.neighbors[row.front] or nil
   if front and front.gap<=K.realPassGap then
    -- Voisins relevés par intermittence : la voiture n'est retenue que si elle est encore devant (position directe).
    local o=frame.cars[front.index]
    if o and o.splineValid and a.splineValid and U.spline(o.spline-a.spline)*frame.length>0 then s.frontWas=front.index end
   end
  else s.frontWas=0 end
 end
 local player=frame.player>0 and frame.cars[frame.player] or nil
 if player then
  local learned=Flash.sampleLearn(e.flash,player,now)
  if learned~=nil then e.g.flashField=learned; e.settingsChanged=true end
  local state=e.states[frame.player]
  if now>=state.nextPerception then Perception.refresh(e.perception,frame.cars,frame.count,frame.player,frame.length,e.frames); state.nextPerception=now+K.perceptionPeriod end
  local row=e.perception.rows[frame.player]
  state.state='DRIVE'
  if not (e.incidents.neutral or e.incidents.red or e.incidents.playerZone) then Director.pace(state,player,row,dt,e.run) end
 end
 -- Une voiture par appel protégé, ou toutes en un seul (cache JIT agrandi : le compilateur trace alors Director.step) ;
 -- une erreur isole la voiture fautive et le pilotage reprend à la suivante, dans le même ordre.
 local first=1
 while first<=frame.count do
  local last=e.batchCars and frame.count or first
  local ok,err=pcall(drive,e,first,last,dt,now)
  if ok then first=last+1
  else
   local i=carAt; first=i+1
   local s=e.states[i]
   e.errors=math.min(K.counterMax,e.errors+1); s.errorCount=math.min(K.carErrorMax,s.errorCount+1); s.errorUntil=now+K.carErrorTime; s.excluded=s.errorCount>=K.carErrorMax
   s.state='IDLE'; s.velocity=0; s.filtered=s.offset
   local row=e.perception.rows[i]; pcall(Perception.occupancy,frame.cars,frame.count,i,e.runtimeG,row)
   local reset=(s.offset>0 and not row.left) or (s.offset<0 and not row.right) or s.offset==0
   if reset then s.offset=0; s.filtered=0 end
   local cmd=e.commands[i]; local car=frame.cars[i]
   cmd.active=true; cmd.offset=s.offset; cmd.level=car.baseLevel or car.aiLevel; cmd.aggression=car.baseAggression or car.aiAggression; cmd.caution=K.defaultCaution; cmd.brake=0; cmd.speedLimit=K.unlimitedSpeed; cmd.yellowLimit=K.unlimitedSpeed
   U.log(e.log,now,'ERROR',tostring(err):sub(1,256),i)
  end
 end
 for i=frame.count+1,K.maxCars do e.commands[i].active=false; e.states[i].state='IDLE' end
 for i=1,K.maxCars do e.commands[i].stopHold=i<=frame.count and e.incidents.cars[i].holding end
 -- Erreurs de pilotage des IA (blocage des roues, patinage) : décision, journal ; écriture par l'applicateur.
 local slips=Mistakes.update(e.mistakes,e,frame,e.run,e.profile,now)
 if slips then
  for _,i in ipairs(slips) do
   local cmd=e.commands[i]
   U.log(e.log,now,'INFO',string.format('erreur de pilotage: %s (%.1f s, %s), %s',cmd.mistakeKind=='brake' and 'blocage des roues au freinage' or 'patinage en sortie de virage',cmd.mistakeTime,cmd.mistakeCause,frame.cars[i].name),i)
  end
 end
 Incidents.player(e.incidents,frame,e.run,now)
 -- Temps delta du joueur (neutralisation, drapeau rouge, double drapeau jaune) ; file derrière la voiture de sécurité.
 local queued=false
 if player then local row=e.perception.rows[frame.player]; queued=row.front>0 and row.neighbors[row.front].gap<K.scQueueGap end
 Delta.update(e.delta,frame,e.run,e.incidents,e.states,now,dt,queued)
 -- Bips du temps delta : de plus en plus rapprochés près de zéro, très rapides en négatif.
 local dv=e.delta.value; local beep=e.deltaBeep; local interval=nil
 if dv and e.run.deltaBeeps then
  interval=dv<0 and K.deltaBeepNegative or dv<K.deltaBeepNear and K.deltaBeepFast or dv<K.deltaBeepMid and K.deltaBeepMedium or dv<K.deltaBeepFar and K.deltaBeepSlow or nil
 end
 if not interval then beep.nextAt=now
 elseif now>=beep.nextAt then beep.beepId=beep.beepId%K.counterMax+1; beep.volume=e.run.drsBeepVolume/100; beep.nextAt=now+interval
 elseif beep.nextAt>now+interval then beep.nextAt=now+interval end
 -- DRS (règles de course, comme la direction de course en F1) : coupé pour toutes les voitures sous la pluie, sous
 -- drapeau (neutralisation, drapeau rouge, zone jaune de la voiture) et, en course, pendant les premiers tours du leader
 -- après le départ, une voiture de sécurité ou un drapeau rouge (jamais après une VSC ou une FCY). Jamais en journée
 -- circuit.
 local dr=e.drsRule
 local rules=e.run.rulesDrs and not C.solo(e.profile)
 -- Tours mesurés par l'app (déplacement réel sur la piste, sauts écartés) depuis le départ et depuis chaque reprise :
 -- le compteur de tours du jeu n'est pas utilisé (grille avant la ligne de départ). App chargée en pleine course déjà
 -- lancée : pas d'attente.
 local restart=false
 local inc=e.incidents
 if inc.red or inc.neutral and (inc.neutralMode=='sc' or inc.relaunch) then dr.restart=true
 elseif dr.restart and not inc.neutral then dr.restart=false; restart=true end
 if frame.started and not dr.started or restart then
  local late=not restart and not dr.seen and frame.time>=K.drsLateLoad
  for i=1,K.maxCars do dr.travel[i]=late and K.drsLapsMax or 0; dr.last[i]=-1 end
 end
 dr.started=frame.started; dr.seen=true
 local leader=0
 for i=1,frame.count do
  local a=frame.cars[i]
  if frame.started and a.valid and a.splineValid and not a.pit then
   local last=dr.last[i] or -1
   if last>=0 then local ds=U.spline(a.spline-last); if ds>=0 and ds*frame.length<=K.deltaJump then dr.travel[i]=(dr.travel[i] or 0)+ds end end
   dr.last[i]=a.spline
   if (dr.travel[i] or 0)>leader then leader=dr.travel[i] end
  else dr.last[i]=-1 end
 end
 dr.leader=leader
 local laps=e.profile=='C' and math.max(0,math.ceil(e.run.rulesDrsLaps-leader-1e-9)) or 0
 local drsReason=not rules and '' or e.weather.wet and 'wet' or (e.incidents.neutral or e.incidents.red) and 'flag' or laps>0 and 'laps' or ''
 for i=1,frame.count do
  local a=frame.cars[i]
  -- Drapeau jaune de la voiture : zone de l'app, ou drapeau jaune natif d'AC montré au joueur.
  local own=rules and (a.player and (e.incidents.playerZone or frame.flag==K.flagCaution and not frame.flagOwned) or not a.player and e.states[i].yellow)
  local cmd=e.commands[i]
  cmd.drsBlock=rules and a.valid and a.drsPresent and (drsReason~='' or own) or false
  -- DRS des IA : ouvert quand il est disponible (coupé par les règles, il ne l'est jamais), en ligne droite et hors
  -- freinage ; refermé au freinage. Ouvertures comptées (toutes, et celles demandées par l'app).
  local s=e.states[i]; local want=nil
  if not a.player and a.valid and a.control and a.drsPresent then
   if a.drsActive and not s.drsWas then e.stats.drsOpen=(e.stats.drsOpen or 0)+1 end
   s.drsWas=a.drsActive
   if e.run.aiDrs and not cmd.drsBlock then
    if a.drsActive then if a.brake>=K.drsAiBrake then want=false end
    elseif a.drsAvailable and a.brake<K.drsAiBrake and (a.corner or 1)>=K.drsAiCorner and a.kmh>=K.drsAiKmh then want=true end
   end
   if want and not s.drsAsked then s.drsAsked=true; e.stats.drsAsk=(e.stats.drsAsk or 0)+1 end
   if not a.drsAvailable then s.drsAsked=false end
  end
  cmd.drsWant=want
 end
 e.incidents.drsReason=drsReason=='' and rules and player and e.incidents.playerZone and 'flag' or drsReason
 e.incidents.drsLapsLeft=laps
 if dr.reason=='laps' and drsReason=='' then
  U.log(e.log,now,'INFO',string.format('DRS autorise: %.2f tour(s) mesure(s) du leader (compteur du jeu : %d)',leader,frame.leaderLaps),-1)
 end
 dr.reason=drsReason
 if player and player.drsPresent and e.run.drsAssist and rules and e.profile=='C' and drsReason~=dr.announced then
  local kind=drsReason=='laps' and 'drsLaps' or drsReason=='wet' and 'drsWet' or drsReason=='' and dr.announced~=nil and 'drsOn' or nil
  if kind then Incidents.message(e.incidents,kind,laps) end
  -- Annonce retenue seulement si le message a été affiché (un drapeau vert de la même image l'emporte) ; sinon retentée.
  local t=e.incidents
  if not kind or t.messageKind==kind and t.messageFrame==t.frameId then dr.announced=drsReason end
 end
 -- Beta 1.32 : véhicule lent devant le joueur (drapeau blanc), dégâts du joueur (drapeau noir à disque orange), valeur
 -- des panneaux lumineux du circuit ; place à rendre (avertissement).
 local l=e.lights
 local penaltyType=frame.player>0 and (frame.cars[frame.player].penaltyType or 0) or 0
 l.playerDisqualified=e.penalties.disqualified==true or penaltyType==K.penaltyBlackFlag
 l.playerPenalty=penaltyType>0
 if Lights.update(l,e.incidents,frame,e.run,e.profile,e.delta,e.states,e.run.multiClass==true,now) then
  U.log(e.log,now,'INFO',string.format('voiture du joueur endommagee: suspension %.2f, moteur %.0f, boite %.2f, carrosserie %.0f km/h, pneu eclate %s',
   frame.playerSuspension,frame.playerEngine,frame.playerGearbox,frame.playerBody,frame.playerBlown and 'oui' or 'non'),frame.player)
 end
 -- Une ligne par véhicule lent, pas plus d'une toutes les K.slowLogGap s (journée circuit chargée).
 if l.slowSlot>0 and l.slowSlot~=e.slowLogged and (e.slowLogged==0 or now-(e.slowLoggedAt or -math.huge)>=K.slowLogGap) then
  e.slowLoggedAt=now
  U.log(e.log,now,'INFO',string.format('vehicule lent devant le joueur: %s a %.0f km/h, %.0f m devant',frame.cars[l.slowSlot].name,l.slowKmh,l.slowGap),l.slowSlot)
 end
 e.slowLogged=l.slowSlot
 e.panel.giveBackDue=e.penalties.giveBack>0 and not e.penalties.disqualified
 Panel.update(e.panel,e.incidents,frame,e.run,e.profile,now,l)
 -- Pénalités du joueur sous drapeau jaune : journal, message à l'écran et ligne du panneau ; écriture par l'applicateur.
 Penalties.resume(e.penalties,frame)
 local penalty=Penalties.update(e.penalties,frame,e.run,e.profile,e.incidents,now,dt,e.delta)
 e.panel.passed=e.penalties.passedUnder
 Panel.infractions(e.panel,e.penalties.count,e.run.penaltyDisqualify)
 if penalty then
  local seconds=e.penalties.seconds
  local t=e.penalties; local detail
  if penalty=='delta' then detail=string.format('delta negatif (%s, %.2f s au mini-secteur)',t.deltaKind,t.deltaValue)
  elseif penalty=='pass' then detail=string.format('depassement sous drapeau jaune (%s)',t.passed>0 and frame.cars[t.passed].name or '?')
  elseif penalty=='red' then detail='pas dans la voie des stands a la reprise apres drapeau rouge'
  elseif penalty=='jump' then detail='faux depart (depart arrete)'
  else detail='arret obligatoire non effectue dans la fenetre' end
  if t.kind=='dq' then
   U.log(e.log,now,'WARN',string.format('disqualification du joueur: drapeau noir apres %d infractions, derniere : %s',t.count,detail),frame.player)
   if e.run.yellowMessage then Incidents.message(e.incidents,'penaltyDq',t.count) end; Panel.notice(e.panel,'dq',t.count,now)
   -- Beta 1.32 : disqualifié, l'avertissement n'a plus lieu d'être.
   e.panel.warnPending=false; e.panel.warnUntil=-math.huge
  else
   U.log(e.log,now,'WARN',string.format('penalite du joueur: %s, coupure des gaz %.0f s (infraction %d / %d)',detail,seconds,t.count,e.run.penaltyDisqualify),frame.player)
   if e.run.yellowMessage then Incidents.message(e.incidents,penaltyMessages[penalty],seconds) end
   Panel.notice(e.panel,penalty,seconds,now)
   -- Beta 1.32 : dernière infraction tolérée, la suivante disqualifie : avertissement (drapeau noir et blanc).
   if t.count>=e.run.penaltyDisqualify then Panel.warn(e.panel); U.log(e.log,now,'INFO','avertissement du joueur: prochaine infraction, disqualification',frame.player) end
  end
 end
 -- Sanctions des IA sous drapeau jaune : journal, message à l'écran pour une disqualification.
 local sanctioned=Penalties.ai(e.penalties,frame,e.run,e.profile,e.incidents,e.states,e.perception.rows,now)
 if sanctioned then
  local ai=e.penalties.ai
  for _,i in ipairs(sanctioned) do
   local other=frame.cars[ai.passed[i]]
   if ai.dq[i] then
    e.states[i].disqualified=true
    U.log(e.log,now,'WARN',string.format('IA disqualifiee: %s, %d depassements sous drapeau jaune (dernier : %s)',frame.cars[i].name,ai.count[i],other.name),i)
    if e.run.yellowMessage then Incidents.message(e.incidents,'aiDq',0,0,frame.cars[i].name) end
   else
    U.log(e.log,now,'WARN',string.format('sanction IA: %s a double %s sous drapeau jaune (infraction %d / %d), pied leve %.0f s',frame.cars[i].name,other.name,ai.count[i],e.run.penaltyDisqualify,e.run.penaltySeconds),i)
   end
  end
 end
 -- Bip du DRS : jamais sous drapeau (le DRS y est interdit) ; il retentit à la fin du drapeau si la zone est encore active.
 local flagged=e.incidents.red or e.incidents.neutral or e.incidents.playerZone or frame.flag==K.flagCaution and not frame.flagOwned
 drsBeep(e,frame,flagged or (e.incidents.drsReason or '')~='',e.run.drsAssist,e.run.drsBeepVolume)
 if player and e.p.section_flash and (e.g.flashField~='' or e.run.hornEnabled) then
  local signal=player[e.g.flashField]==true or e.run.hornEnabled and player.hornActive
  if Flash.step(e.flash,signal,now) then
   local reacted=Flash.dispatch(e.flash,frame.cars,frame.count,frame.player,e.perception,e.states,e.run,e.runtimeG,e.profile,now)
   -- Beta 1.29 : chaque appel du joueur au journal (IA visées, la plus proche, appel vu et compris).
   local f=e.flash
   U.log(e.log,now,'INFO',f.ranked>0 and string.format('appel de phares du joueur: %d IA visee(s) a moins de %.0f m, la plus proche a %.0f m (%+.0f km/h), vu par %d, compris par %d',f.ranked,e.run.flashRange,f.nearestGap,f.nearestSa,reacted,f.heard)
    or string.format('appel de phares du joueur: aucune IA visee devant a moins de %.0f m',e.run.flashRange),frame.player)
  end
 end
 if e.run.multiClass then Classes.update(e.classes,frame.cars,e.states,frame.count,e.run,now) end
 Classes.balance(e.classes,frame.cars,e.states,frame.count,e.run,now)
 Weather.step(e.weather,frame,e.commands,e.run,now,e.states,e.runtimeG.seed)
 -- Journal : météo lue au lancement de chaque session et à chaque changement de profil, avec la gestion des pneus
 -- du profil en cours (diagnostic des pneus pluie au sec).
 local reported=frame.session..e.profile
 if e.weather.reported~=reported then
  e.weather.reported=reported
  local managed=e.run.weatherTyresEnabled and 'oui' or not C.on(e.p,'weather') and 'non (onglet Meteo decoche)' or 'non (option pneus decochee)'
  U.log(e.log,now,'INFO',string.format('meteo au lancement: %s (humidite %.2f, pluie %.2f, eau %.2f), profil %s, pneus geres par l app: %s',
   e.weather.wet and 'pluie' or 'sec',frame.wet or 0,frame.rain or 0,frame.water or 0,e.profile,managed),-1)
 end
 if e.weather.changedAt==now then
  U.log(e.log,now,'INFO',e.weather.wet and 'meteo: piste humide' or 'meteo: piste seche',-1)
  if e.run.weatherMessage then Incidents.message(e.incidents,e.weather.wet and 'wet' or 'dry') end
  -- Piste glissante (drapeau à bandes jaunes et rouges) au passage du sec à la pluie, jamais au lancement (ni dans les
  -- premières secondes de la session, le temps que la météo lue se stabilise).
  if e.weather.wet and frame.time>=K.slipperyGrace then e.incidents.slipperyUntil=now+K.slipperyShow end
 end
 local red=e.incidents.red
 -- Course devenue mouillée : la règle des deux composés secs (F1) ne s'applique plus.
 if e.weather.wet and e.profile=='C' and frame.started then e.pits.wetRace=true end
 Pits.update(e.pits,frame,e.commands,e.run,e.profile,now,e.runtimeG.seed,e.announce,red,e.penalties.ai.dq,e.incidents.pitsClosed)
 -- Arrêts obligatoires du joueur : rappel sur le panneau à l'ouverture et vers la fin de la fenêtre ; arrêt manqué
 -- à la fermeture : pénalité, dès que possible (une fenêtre qui se ferme à 100 % de la course ne se ferme jamais).
 local due=0
 if player and e.pits.state=='open' then due=math.max(0,e.run.mandatoryStops-e.pits.cars[frame.player].windowStops) end
 e.incidents.playerPitDue=due
 e.incidents.playerPitRemind=due>0 and (now-e.pits.openedAt<K.pitRemindTime or e.pits.position>=e.pits.close-(e.pits.close-e.pits.open)*K.pitRemindLate)
 if e.pits.justClosed and player and e.pits.cars[frame.player].windowStops<e.run.mandatoryStops then e.penalties.stopPending=true end
 -- Drapeau rouge : toutes les IA rentrent aux stands et y restent. Dépannage d'une IA immobile en piste jusqu'à son
 -- stand : sous drapeau rouge, sous neutralisation, ou bloquée longtemps (commissaires), jamais le joueur.
 local neutral=e.incidents.neutral
 local decide=decisionTime(e,neutral)
 for i=1,frame.count do
  local a=frame.cars[i]; local cmd=e.commands[i]
  cmd.recover=false
  if a.valid and a.control and not a.player and not a.finished and not a.safetyCar then
   if red then cmd.rulePit=not a.inPitBox; cmd.pitHold=a.inPitBox==true
   -- Reprise : chaque IA attend son tour pour quitter son emplacement (ordre du classement).
   -- Sortie des stands échelonnée après un drapeau rouge (relance de course, reprise d'essais ou de qualifications).
   elseif now<e.incidents.releaseAt[i] then cmd.pitHold=a.inPitBox==true end
   local c=e.incidents.cars[i]; local still=c.still
   -- Beta 1.29 : incident hors piste, temps passé sans avancer (une voiture qui patine dans un bac à sable n'est jamais
   -- à l'arrêt assez longtemps) ; drapeau rouge, neutralisation et pleine piste gardent l'immobilisation.
   local stalled=c.incident and not c.onTrack and math.max(still,c.stuckFor or 0) or still
   -- Beta 1.24 : en pleine piste, jamais avant la décision de la direction de course (decisionTime) ; sinon après
   -- K.trackRecoverTime s (20 avant). Hors piste (aucune règle n'en découle) après K.stuckRecoverTime s (90 avant),
   -- jamais pendant sa retenue. Cassée (suspension, moteur ou boîte hors d'usage) : dès K.brokenRecoverTime s, en
   -- piste au plus tôt à la décision de la direction de course.
   local wait=c.onTrack and decide or 0
   local neutralStuck=c.incident and neutral and still>=math.max(K.neutralRecoverTime,wait)
   local trackStuck=c.incident and c.onTrack and not c.holding and e.run.section_accidents and still>=math.max(K.trackRecoverTime,wait)
   local stuck=c.incident and not c.holding and e.run.section_accidents and stalled>=math.max(K.stuckRecoverTime,wait)
   local broken=c.incident and e.run.section_accidents and stalled>=math.max(K.brokenRecoverTime,wait) and ((a.damageSuspension or 0)>=K.brokenSuspension or (a.engineLife or K.engineLifeNew)<=K.brokenEngine or (a.damageGearbox or 0)>=K.brokenGearbox)
   cmd.recover=not a.pit and (red and still>=K.redRecoverTime or neutralStuck or trackStuck or broken or stuck)
   cmd.recoverReason=red and 'drapeau rouge' or neutralStuck and 'neutralisation' or broken and 'cassee' or trackStuck and 'en piste' or 'bloquee'
   cmd.recoverStill=(red or neutralStuck or trackStuck) and still or stalled
  end
 end
 -- Départ arrêté (Beta 1.34) : formation, feux, départ, après les commandes des stands (retenues à l'emplacement
 -- gardées) ; un faux départ du joueur est une infraction comme une autre (sanction à l'image suivante).
 local launched=Grid.step(e.grid,e.incidents,frame,now,e.commands,e.g.offsetSign,e.runtimeG.seed,e.log,e.states,e.penalties.ai.dq)
 if launched then
  -- Beta 1.35 : protections et prudence de départ de la course aussi à l'extinction d'un départ arrêté.
  e.launchAt=now
  -- Beta 1.36 : départ arrêté, dépassement permis dès l'extinction (la règle « jusqu'à la ligne » reste aux départs lancés).
  Incidents.lightsOut(e.incidents)
  if launched=='jump' then
   local a=frame.player>0 and frame.cars[frame.player] or nil
   if e.run.playerPenalties and not C.solo(e.profile) and a then e.incidents.jumpUntil=now+K.jumpShow; e.jumpDue=true; e.jumpGoAt=now; e.jumpLap=a.lap or 0
   else U.log(e.log,now,'INFO','faux depart du joueur: sans sanction (penalites du joueur desactivees)',frame.player) end
  end
 end
 -- Faux départ : sanction servie une fois le joueur passé la ligne et à K.jumpServeDistance m (jamais à l'arrêt sur la
 -- grille au milieu des voitures qui partent) ; au plus tard K.jumpServeMax s après l'extinction, mais seulement en roulant
-- ou la ligne passée (Beta 1.36 : jamais à l'arrêt sur la grille, même après un calage).
 if e.jumpDue then
  local a=frame.player>0 and frame.cars[frame.player] or nil
  if not a or not a.valid then e.jumpDue=false
  elseif (a.lap or 0)>e.jumpLap and a.spline*frame.length>=K.jumpServeDistance or now-e.jumpGoAt>=K.jumpServeMax and ((a.lap or 0)>e.jumpLap or a.kmh>K.gridStillKmh) then e.jumpDue=false; e.penalties.jumpPending=true end
 end
 -- Formation de la grille et feux : aucun arrêt aux stands demandé (la voie des stands longe la grille).
 if e.incidents.standing=='grid' or e.incidents.standing=='lights' then
  for i=1,frame.count do local cmd=e.commands[i]; if not frame.cars[i].pit then cmd.rulePit=false; cmd.weatherPit=false end end
 end
 -- Carburant des arrêts forcés, une fois toutes les demandes d'arrêt connues (règles, météo, drapeau rouge).
 Pits.fuel(e.pits,frame,e.commands,e.run,e.profile,now,red)
 for i=1,K.maxCars do local cmd=e.commands[i]; cmd.scPark=false; cmd.scSpeed=K.unlimitedSpeed; cmd.parkReason='sc'; cmd.scRelease=false end
 Incidents.safety(e.incidents,e.commands,e.run)
 -- Voitures de réserve du modèle de la voiture de sécurité : garées aux stands dans toutes les sessions.
 for i=1,frame.count do if frame.cars[i].safetyCar and i~=e.incidents.safety then local cmd=e.commands[i]; cmd.scPark=true; cmd.parkReason='spare' end end
 for i=1,K.maxCars do e.commands[i].scSkin=false end
 local sc=e.incidents.safety>0 and frame.cars[e.incidents.safety]
 if sc and sc.skinKnown and not sc.skinSafety then e.commands[e.incidents.safety].scSkin=true end
 -- IA sanctionnées : pied levé quelques secondes ; disqualifiée, ramenée à son stand et garée jusqu'à la fin.
 local ai=e.penalties.ai
 for i=1,frame.count do
  local cmd=e.commands[i]
  if ai.dq[i] then cmd.scPark=true; cmd.parkReason='dq'; e.states[i].disqualified=true
  -- Pied levé progressif : jamais de freinage brusque devant la voiture tout juste doublée.
  elseif now<(ai.slowUntil[i] or 0) then cmd.yellowLimit=math.min(cmd.yellowLimit,math.max(ai.slowKmh[i],ai.slowFrom[i]-K.aiPenaltyDecel*3.6*(now-ai.slowAt[i]))) end
  -- Place à rendre (dépassement pendant la transition) : levée de pied franche (décélération d'approche) sous l'allure
  -- de la voiture doublée, pour la laisser repasser avant l'échéance.
  local back=ai.giveBack[i] or 0
  if back>0 and not ai.dq[i] then
   if not ai.giveFrom[i] then ai.giveFrom[i]=frame.cars[i].kmh; ai.giveAt[i]=now end
   local target=math.max(K.trafficMinSpeed,frame.cars[back].kmh-K.giveBackDrop)
   cmd.yellowLimit=math.min(cmd.yellowLimit,math.max(target,ai.giveFrom[i]-e.run.yellowDecel*3.6*(now-ai.giveAt[i])))
  else ai.giveFrom[i]=nil; ai.giveAt[i]=nil end
 end
 return true
end
return M
