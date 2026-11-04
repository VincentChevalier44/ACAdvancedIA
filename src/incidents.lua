-- Incidents de piste, drapeaux jaunes et neutralisations : décisions pures. Lecture dans snapshot, écritures dans applier.
local U=require('src/util')
local K=require('src/config').K
local Delta=require('src/delta')
local Grid=require('src/grid')
local min,max=math.min,math.max
local M={}
local function clearCar(c)
 c.incident=false; c.dismissed=false; c.since=0; c.spline=0; c.onTrack=false; c.clearedAt=-math.huge; c.wrong=0; c.spin=0; c.contact=false; c.lastSpline=-1; c.calm=0
 c.still=0; c.halt=0; c.moved=false; c.fresh=true; c.slow=0; c.counted=false; c.lastCrash=-math.huge; c.window=0; c.windowStart=-math.huge; c.crashAt=-math.huge; c.holding=false; c.holdUntil=0; c.holdMax=0; c.announced=false
 c.restart=false; c.restartLast=0; c.stuckFor=0; c.anchorX=math.huge; c.anchorZ=math.huge
end
function M.new()
 local t={cars={},zones={},zoneCount=0,activeCount=0,holdCount=0,neutral=false,neutralMode='local',neutralSince=0,neutralUntil=0,
  safety=0,safetyPhase='none',safetySince=0,safetyStill=0,safetyFailed=false,safetyLeft=false,started=0,held=0,onTrack=0,red=false,redSince=0,redCancelled=false,reds=0,redTotal=0,redInPits=0,
  greenUntil=-math.huge,playerZone=false,playerInside=false,playerToZone=0,playerLead=0,playerNoPass=false,playerZoneSlot=0,suppressed={queue=0,spawn=0,crawl=0},playerDistance=0,freshOnTrack=0,redEnd=-math.huge,redMax=0,neutralEnd=-math.huge,frameId=0,messagePriority=0,messageFrame=-1,
  playerFlag=false,playerYellow=false,playerZoneDouble=false,slipperyUntil=-math.huge,messageId=0,messageKind='',messageValue=0,messageExtra=0,messageText='',
  standing='none',gridReady=false,gridWhy='',gridLit=0,gridSlot=0,gridGap=0,gridPit=false,gridPlaced=false,gridPassed=false,jumpUntil=-math.huge,
  relaunchLeader=0,relaunchSpline=0,relaunchTravel=0,relaunchSpanUntil=-math.huge,
  relaunch=false,escalated=false,ending=false,endingUntil=0,restart=false,restartSince=0,playerRestart=false,pitsClosed=false,releaseAt={}}
 for i=1,K.maxCars do
  t.releaseAt[i]=-math.huge
  local c={identity=''}; clearCar(c); c.crashes=0; t.cars[i]=c
  t.zones[i]={slot=0,spline=0,onTrack=false}
 end
 return t
end
function M.reset(t)
 for i=1,K.maxCars do clearCar(t.cars[i]) end
 t.zoneCount=0; t.activeCount=0; t.holdCount=0; t.neutral=false; t.neutralUntil=0; t.playerFlag=false; t.playerYellow=false; t.safetyPhase='none'; t.red=false; t.onTrack=0; t.playerZone=false; t.playerInside=false; t.slipperyUntil=-math.huge
 t.safetyStill=0; t.safetyFailed=false; t.safetyLeft=false; t.escalated=false; t.relaunch=false; t.ending=false; t.restart=false; t.playerRestart=false; t.pitsClosed=false
 for i=1,K.maxCars do t.releaseAt[i]=-math.huge end
 t.standing='none'; t.gridLit=0; t.jumpUntil=-math.huge; t.gridPlaced=false; t.gridPassed=false
 t.relaunchLeader=0; t.relaunchTravel=0; t.relaunchSpanUntil=-math.huge
end
function M.rebase(t,amount)
 t.neutralSince=t.neutralSince-amount; t.neutralUntil=t.neutralUntil-amount; t.safetySince=t.safetySince-amount; t.redSince=t.redSince-amount
 if U.finite(t.redEnd) then t.redEnd=t.redEnd-amount end
 if U.finite(t.neutralEnd) then t.neutralEnd=t.neutralEnd-amount end
 if U.finite(t.greenUntil) then t.greenUntil=t.greenUntil-amount end
 if U.finite(t.slipperyUntil) then t.slipperyUntil=t.slipperyUntil-amount end
 t.endingUntil=t.endingUntil-amount; t.restartSince=t.restartSince-amount
 if U.finite(t.jumpUntil) then t.jumpUntil=t.jumpUntil-amount end
 if U.finite(t.relaunchSpanUntil) then t.relaunchSpanUntil=t.relaunchSpanUntil-amount end
 for i=1,K.maxCars do
  local c=t.cars[i]
  for _,key in ipairs({'since','clearedAt','windowStart','crashAt','holdUntil','holdMax','lastCrash','holdStart'}) do if U.finite(c[key]) then c[key]=c[key]-amount end end
  if U.finite(t.releaseAt[i]) then t.releaseAt[i]=t.releaseAt[i]-amount end
 end
end
-- Un seul message affiché par image : le plus important l'emporte (rouge, neutralisation, vert, jaune, stands, météo).
local priorities={penaltyDq=5,aiDq=4,aiBlackFlag=4,aiSanction=2,penaltyDelta=5,penaltyPass=5,penaltyRed=5,penaltyStop=5,red=5,redSession=5,sessionResume=3,redRestartSc=4,standing=4,penaltyJump=5,redRestartVsc=4,redRestartFcy=4,sc=4,fcy=4,vsc=4,vscEnd=4,scIn=3,green=3,restart=3,yellow=2,pitOpen=1,pitOpenCsp=1,wet=1,dry=1,drsLaps=1,drsOn=1,drsWet=1}
local function message(t,kind,value,extra,text)
 local priority=priorities[kind] or 0
 if t.messageFrame==t.frameId and priority<t.messagePriority then return end
 t.messageId=t.messageId%K.counterMax+1; t.messageKind=kind; t.messageValue=value or 0; t.messageExtra=extra or 0; t.messageText=text or ''
 t.messageFrame=t.frameId; t.messagePriority=priority
end
local function note(t,level,text,index) if t.note then t.note(level,text,index) end end
-- Voiture de sécurité indisponible (immobilisée en piste, ou jamais sortie de la voie des stands) : ramenée à son stand,
-- la neutralisation continue en FCY.
local function unavailable(t,text)
 t.safetyStill=0; t.safetyPhase='parked'; note(t,'WARN',text,t.safety)
 if t.neutral and t.neutralMode=='sc' then t.safetyFailed=true; t.neutralMode='fcy'; note(t,'INFO','neutralisation: fcy (voiture de securite indisponible)',-1) end
end
M.message=message
-- Reprise derrière la voiture de sécurité (et après le tour de relance d'un drapeau rouge) : dépassement interdit pour
-- chaque voiture en piste jusqu'à son passage de la ligne.
local function restart(t,frame,now,p)
 t.restart=false; t.restartSince=now
 for i=1,frame.count do
  local a=frame.cars[i]; local c=t.cars[i]
  c.restart=a.valid and not a.pit and not a.finished and a.splineValid; c.restartLast=a.spline
  t.restart=t.restart or c.restart
 end
 if p.yellowMessage then message(t,'restart') end
end
-- Extinction des feux d'un départ arrêté (Beta 1.36) : dépassement permis aussitôt pour toutes les voitures, joueur
-- compris, comme à un vrai départ arrêté ; la règle « jusqu'à la ligne » ne vaut que pour un départ lancé.
function M.lightsOut(t)
 if not t.restart then return end
 for i=1,#t.cars do t.cars[i].restart=false end
 t.restart=false; t.playerRestart=false
 note(t,'INFO','reprise: depassement permis a l extinction des feux',-1)
end
-- Fin du tour de relance d'un drapeau rouge en course (Beta 1.34) : départ arrêté si les règles le demandent et que
-- tout est prêt (t.gridReady, décidé par le moteur : capacités, sens latéral, piste), sinon départ lancé (raison au
-- journal). Dépassement interdit jusqu'à la ligne, juste devant la grille.
local function standing(t,frame,now,p,profile)
 if profile~='C' or p.redRestart~='standing' then return false end
 if not t.gridReady then note(t,'INFO','relance arretee indisponible ('..(t.gridWhy~='' and t.gridWhy or '?')..'): depart lance',-1); return false end
 t.standing='grid'; t.gridLit=0; note(t,'INFO','relance: depart arrete (SS)',-1)
 restart(t,frame,now,p)
 if p.yellowMessage then message(t,'standing') end
 return true
end
-- Dépassement après une relance (Beta 1.34) : à la ligne de contrôle (défaut), ou dès le drapeau vert.
local function restartRule(t,frame,now,p) if p.restartOvertake=='scIn' then if p.yellowMessage then message(t,'green') end else restart(t,frame,now,p) end end
-- Meneur du tour de relance (Beta 1.35) : la mieux classée des voitures en piste, suivie une fois toutes les IA
-- sorties des stands ; distance parcourue vers l'avant cumulée. Vrai quand elle a bouclé son tour.
local function leaderLap(t,frame,now)
 if now<t.relaunchSpanUntil or frame.length<=0 then return false end
 local i=t.relaunchLeader; local a=i>0 and frame.cars[i] or nil
 if not a or not a.valid or a.pit or a.finished or not a.splineValid then
  i=0; local best=math.huge
  for j=1,frame.count do
   local b=frame.cars[j]
   if b.valid and not b.pit and not b.finished and not b.safetyCar and b.splineValid and (b.control or b.player) then
    local pos=(b.position or 0)>=1 and b.position or math.huge
    if i==0 or pos<best then best=pos; i=j end
   end
  end
  t.relaunchLeader=i
  if i>0 then t.relaunchSpline=frame.cars[i].spline end
  return false
 end
 local step=U.spline(a.spline-t.relaunchSpline); t.relaunchSpline=a.spline
 if step>0 then t.relaunchTravel=t.relaunchTravel+step end
 return t.relaunchTravel>=K.relaunchTravel and ((-a.spline)%1)*frame.length<=K.gridFormFrom
end
-- Sortie des stands après un drapeau rouge : ordre du classement de la course (sinon ordre de la grille), une IA toutes
-- les deux secondes après un court délai ; la voiture de sécurité sort la première. Renvoie la durée de la sortie.
local order={}
local function release(t,frame,now)
 local n=0
 for i=1,frame.count do
  local a=frame.cars[i]; t.releaseAt[i]=now
  if a.valid and a.control and not a.player and not a.safetyCar then n=n+1; order[n]=i end
 end
 Grid.sortByPosition(order,n,frame.cars)
 for rank=1,n do t.releaseAt[order[rank]]=now+K.redReleaseFirst+(rank-1)*K.redReleaseGap end
 return K.redReleaseFirst+n*K.redReleaseGap
end
-- Une voiture lancée arrive derrière : l'IA arrêtée attend avant de repartir.
local function traffic(frame,i,p)
 local a=frame.cars[i]; local length=frame.length
 if length<=0 or not a.splineValid then return false end
 for j=1,frame.count do
  local b=frame.cars[j]
  if j~=i and b.valid and not b.pit and b.splineValid and b.kmh>=K.rejoinSpeed then
   local behind=U.spline(a.spline-b.spline)*length
   if behind>0 and behind<p.rejoinGap then return true end
  end
 end
 return false
end
-- File d'attente : une voiture lente juste devant (même sens de piste) ; la voiture de derrière attend, ce n'est pas
-- un incident. Seule la voiture de tête de file l'est.
local function queued(frame,i,p)
 local a=frame.cars[i]; local length=frame.length
 if length<=0 then return false end
 for j=1,frame.count do
  local b=frame.cars[j]
  if j~=i and b.valid and not b.pit and b.splineValid and b.kmh<p.obstacleSpeedKmh+5 and a.lx*b.lx+a.lz*b.lz>K.sameDirection then
   local ahead=U.spline(b.spline-a.spline)*length
   if ahead>0 and ahead<K.queueGap then return true end
  end
 end
 return false
end
-- ready : session lancée, hors grille de départ. Une voiture arrêtée, en tête-à-queue ou à contresens est un incident ;
-- hors piste depuis longtemps, elle est considérée comme dégagée par les commissaires.
function M.update(t,frame,p,profile,now,dt,ready,seed)
 t.frameId=(t.frameId+1)%K.counterMax
 t.zoneCount=0; t.activeCount=0; t.holdCount=0; t.onTrack=0; t.freshOnTrack=0
 local major=false
 -- Escalade vers la voiture de sécurité : incidents majeurs en même temps, immobilisation la plus longue.
 local majors,longest=0,0
 -- Départ arrêté en cours (Beta 1.34) : une voiture qui s'arrête à sa place n'est pas un incident.
 local gridStop=t.standing~='none'
 for i=1,frame.count do
  local a=frame.cars[i]; local c=t.cars[i]
  local identity=a.identity or a.id
  if c.identity~=identity or a.teleport then clearCar(c); c.identity=identity end
  if a.valid and a.splineValid and not a.pit then
   if c.lastSpline>=0 and a.kmh>=K.wrongWaySpeed and U.spline(a.spline-c.lastSpline)<0 then c.wrong=min(K.wrongWayTime*2,c.wrong+dt) else c.wrong=max(0,c.wrong-dt) end
   c.lastSpline=a.spline
  else c.lastSpline=-1; c.wrong=0 end
  if a.valid and a.slip>K.slipDegrees and a.kmh>=K.spinSpeed then c.spin=min(K.spinTime*2,c.spin+dt) else c.spin=max(0,c.spin-dt) end
  local eligible=ready and a.valid and not a.pit and not a.finished and a.splineValid and not a.safetyCar
  -- Voiture réellement arrêtée (drapeau rouge, incident majeur) : un tête-à-queue qui roule encore n'en est pas une.
  if eligible and a.kmh<K.redStopSpeed then c.still=c.still+dt else c.still=0 end
  -- Beta 1.29 (séance d'essais du pilote) : voiture qui n'avance plus (bac à sable : elle patine, avance et recule sur
  -- place, au-delà du seuil d'arrêt par moments) : temps passé sans s'éloigner de plus de K.stuckRadius m.
  if ready and a.valid and not a.pit and not a.finished and not a.safetyCar then
   if (a.x-c.anchorX)^2+(a.z-c.anchorZ)^2>K.stuckRadius^2 then c.anchorX=a.x; c.anchorZ=a.z; c.stuckFor=0 else c.stuckFor=c.stuckFor+dt end
  else c.stuckFor=0; c.anchorX=math.huge; c.anchorZ=math.huge end
  -- Arrêt : voiture presque arrêtée (moins de 10 km/h, pas un bouchon qui avance au pas) qui roulait déjà (pas un départ
  -- arrêté en début de session ni une sortie des stands) et qui n'attend pas simplement derrière une autre voiture
  -- lente, sauf si elle vient de heurter quelque chose. Une voiture découverte plus tard dans la session (rechargement de
  -- l'app) est supposée avoir roulé.
  if c.fresh then c.fresh=false; c.moved=frame.time>=K.spawnWindow end
  if a.pit or not a.valid then c.moved=false elseif a.kmh>=K.rejoinSpeed then c.moved=true end
  if eligible and c.moved and a.kmh<K.incidentStopSpeed and (now-c.lastCrash<=K.crashWindow or not gridStop and not queued(frame,i,p)) then c.halt=c.halt+dt else c.halt=0 end
  -- Journal : voitures lentes que les règles d'arrêt écartent (départ ou sortie des stands, voiture au pas, file).
  if eligible and a.kmh<p.obstacleSpeedKmh then c.slow=c.slow+dt else c.slow=0; c.counted=false end
  if c.slow>=K.obstacleTime and c.halt==0 and not c.counted then
   c.counted=true; local reason=not c.moved and 'spawn' or a.kmh>=K.incidentStopSpeed and 'crawl' or 'queue'
   t.suppressed[reason]=t.suppressed[reason]+1
  end
  local raw=eligible and (c.halt>=K.obstacleTime or c.spin>=K.spinTime or c.wrong>=K.wrongWayTime)
  if raw then c.calm=0 else c.calm=c.calm+dt end
  -- Fin confirmée après quelques secondes de conduite normale : une glissade qui se stabilise reste un seul incident,
  -- et le délai d'incident majeur n'est pas remis à zéro.
  -- Une voiture encore lente après un tête-à-queue reste le même incident jusqu'à ce qu'elle reparte.
  local incident=raw or eligible and c.incident and (c.calm<K.incidentClear or a.kmh<p.obstacleSpeedKmh)
  if not incident or not a.offtrack then c.dismissed=false end
  if incident and not c.incident then
   c.since=now; c.announced=false
   if not c.dismissed then
    t.started=t.started+1
    note(t,'INFO',string.format('incident: %s, %s, %.0f m, %.0f km/h, %s',c.halt>=K.obstacleTime and 'arret' or c.spin>=K.spinTime and 'tete-a-queue' or 'contresens',
     a.offtrack and 'hors piste' or 'en piste',a.spline*frame.length,a.kmh,a.name),i)
   end
  end
  if incident and (c.dismissed or a.offtrack and now-c.since>K.incidentMaxAge) then
   if not c.dismissed then note(t,'INFO','incident ecarte: hors piste depuis plus de '..K.incidentMaxAge..' s',i) end
   c.dismissed=true; incident=false
  end
  if incident then
   c.spline=a.spline; c.onTrack=not a.offtrack; t.activeCount=t.activeCount+1
   if c.onTrack and not a.player then t.onTrack=t.onTrack+1; if c.since>t.redEnd and c.still>=K.redStopTime then t.freshOnTrack=t.freshOnTrack+1 end end
   -- Incident majeur : voiture immobile en piste (pas une voiture qui roule au pas), apparue depuis la dernière
   -- neutralisation levée au délai maximal.
   if c.onTrack and c.still>=p.majorIncidentTime and c.since>t.neutralEnd then major=true; majors=majors+1; longest=max(longest,c.still) end
  elseif c.incident then c.clearedAt=now; note(t,'INFO',string.format('incident termine apres %.1f s',now-c.since),i) end
  c.incident=incident
  if incident or now-c.clearedAt<p.yellowHold then
   t.zoneCount=t.zoneCount+1; local z=t.zones[t.zoneCount]; z.slot=i; z.spline=c.spline; z.onTrack=c.onTrack
  end
  -- Accident d'une IA : forte décélération avec contact, sortie de piste ou tête-à-queue, puis quasi-arrêt.
  c.contact=c.contact or a.collided or a.offtrack or a.slip>K.slipDegrees
  if now-c.windowStart>=K.contactWindow then
   if c.window-a.kmh>=K.contactDrop and c.contact then c.crashAt=now; c.lastCrash=now end
   c.window=a.kmh; c.windowStart=now; c.contact=false
  end
  local candidate=p.incidentStop and ready and a.valid and a.control and not a.player and not a.pit and not a.finished and not a.safetyCar
  -- Retenue hors piste seulement : en piste, l'IA repart aussitôt, jamais immobilisée sur la trajectoire.
  if candidate and not c.holding and a.offtrack and now-c.crashAt<=K.crashSettle and a.kmh<p.obstacleSpeedKmh then
   c.crashes=(c.crashes+1)%K.counterMax; c.holding=true; c.crashAt=-math.huge
   c.holdUntil=now+U.lerp(p.incidentStopMin,p.incidentStopMax,U.unit(seed,i,K.crashSalt+c.crashes)); c.holdMax=c.holdUntil+K.rejoinWaitMax
   c.holdStart=now; t.held=t.held+1; note(t,'INFO',string.format('IA accidentee arretee %.1f s, %s',c.holdUntil-now,a.name),i)
  end
  -- Libérée : un choc relevé pendant la retenue (fin de glissade) appartient au même accident, jamais une nouvelle
  -- retenue aussitôt.
  if c.holding and (not candidate or now>=c.holdMax or now>=c.holdUntil and not traffic(frame,i,p)) then
   c.holding=false; c.crashAt=-math.huge
   note(t,'INFO',string.format('IA accidentee repart apres %.1f s (%s)',now-(c.holdStart or now),not candidate and 'retenue annulee' or now>=c.holdMax and 'attente maximale' or 'piste libre'),i)
  end
  if c.holding then t.holdCount=t.holdCount+1 end
 end
 for i=frame.count+1,K.maxCars do local c=t.cars[i]; c.incident=false; c.holding=false end
 -- Voiture de sécurité immobilisée en piste pendant son intervention : ramenée à son stand ; la neutralisation se
 -- poursuit en FCY (jamais un peloton bloqué derrière elle).
 if not t.neutral then t.safetyFailed=false; t.escalated=false end
 local sc=t.safety>0 and frame.cars[t.safety] or nil
 if sc and (t.safetyPhase=='out' or t.safetyPhase=='in' or t.safetyPhase=='parking') and sc.valid and not sc.pit and sc.kmh<K.redStopSpeed then t.safetyStill=t.safetyStill+dt else t.safetyStill=0 end
 if t.safetyStill>=K.scStuckTime then unavailable(t,'voiture de securite immobilisee en piste: ramenee a son stand') end
 -- Libérée, elle n'est annoncée « rentre ce tour » qu'une fois sortie de la voie des stands ; encore dedans longtemps
 -- après, elle est indisponible.
 if sc and t.safetyPhase=='out' and not t.safetyLeft then
  if sc.valid and not sc.pit then t.safetyLeft=true; note(t,'INFO',string.format('voiture de securite: en piste apres %.0f s',now-t.safetySince),t.safety)
  elseif now-t.safetySince>=K.scExitMax then unavailable(t,'voiture de securite restee dans la voie des stands: ramenee a son stand') end
 end
 local mode=profile=='C' and p.neutralization or 'local'
 -- Voiture de sécurité absente de la grille (ou indisponible pendant cette neutralisation) : Full Course Yellow.
 if mode=='sc' and (t.safety==0 or t.safetyFailed) then mode='fcy' end
 -- Voiture de sécurité en escalade (Beta 1.18) : une VSC ou une FCY en cours devient une intervention de la voiture de
 -- sécurité quand l'incident s'aggrave (plusieurs voitures immobilisées en piste, ou dépannage long), comme le décide
 -- la direction de course ; elle le reste tant que les règles le permettent (FCY si elle devient indisponible). Zone
 -- jaune locale seule (règles de base, Beta 1.19) : la voiture de sécurité sort directement.
 if t.neutral and t.escalated then
  if profile=='C' and p.safetyCarEscalation then mode=t.safetyFailed and 'fcy' or 'sc' else t.escalated=false end
 elseif (t.neutral and not t.relaunch and mode==t.neutralMode and (mode=='vsc' or mode=='fcy') or not t.neutral and mode=='local' and profile=='C') and not t.red and p.safetyCarEscalation
  and t.safety>0 and not t.safetyFailed and (majors>=K.scEscalateCars or longest>=p.majorIncidentTime+K.scEscalateTime) then
  local from=t.neutral and mode or 'local'
  t.escalated=true; t.neutral=true; t.relaunch=false; t.neutralMode='sc'; mode='sc'; t.ending=false; t.neutralSince=now; t.neutralUntil=max(t.neutralUntil,now+p.neutralizationHold)
  t.safetyPhase='call'; t.safetySince=now; t.safetyLeft=false
  note(t,'INFO',string.format('neutralisation: sc (escalade apres %s, %d voiture(s) immobilisee(s) en piste, %.0f s au plus)',from,majors,longest),-1)
  if p.yellowMessage then message(t,'sc') end
 end
 -- Tour de relance d'un drapeau rouge : neutralisation propre, quelles que soient les règles du profil.
 local relaunch=t.neutral and t.relaunch
 -- Beta 1.35 (relecture) : sous VSC ou FCY, le tour de relance d'un départ arrêté finit quand le meneur boucle son tour
 -- (à K.gridFormFrom m de la ligne, au moins K.relaunchTravel tour parcouru depuis la sortie des stands), jamais sur un
 -- délai : la grille se serait formée n'importe où sur le circuit, des voitures retenues en pleine piste.
 local formLap=relaunch and t.neutralMode~='sc' and profile=='C' and p.redRestart=='standing'
 local lapDone=formLap and leaderLap(t,frame,now)
 if mode~='local' and major and not t.red and not (t.neutral and now-t.neutralSince>=K.neutralMax) then
  if not t.neutral then
   t.neutral=true; t.neutralMode=mode; t.neutralSince=now; t.relaunch=false; t.ending=false
   -- Voiture de sécurité appelée : peloton d'abord sous FCY, elle reste garée le temps qu'il ralentisse.
   if mode=='sc' then t.safetyPhase='call'; t.safetySince=now end
   note(t,'INFO','neutralisation: '..mode,-1)
   if p.yellowMessage then message(t,mode,mode=='vsc' and p.vscDeltaPct or p.fcyDeltaPct) end
  elseif t.ending then
   -- Nouvel incident pendant la fin de VSC : la VSC continue.
   t.ending=false; note(t,'INFO','fin de VSC annulee: nouvel incident',-1)
  end
  -- Nouvel incident pendant le tour de rentrée : la voiture de sécurité reste en piste.
  if t.neutral and t.safetyPhase=='in' then
   t.safetyPhase='out'; t.safetySince=now; note(t,'INFO','voiture de securite: reste en piste',t.safety)
   if p.yellowMessage then message(t,'sc') end
  end
  t.neutralUntil=max(t.neutralUntil,now+p.neutralizationHold)
 elseif t.neutral and t.neutralMode=='sc' and t.safety>0 and (mode=='sc' or relaunch) and (t.safetyPhase=='out' or t.safetyPhase=='in') and now-t.neutralSince<K.neutralMax then
  -- Incident dégagé : la voiture de sécurité rentre ce tour ; drapeau vert quand elle entre dans la voie des stands,
  -- dépassement interdit jusqu'à la ligne.
  local car=frame.cars[t.safety]
  if t.safetyPhase=='out' and t.safetyLeft and now>=t.neutralUntil and now-t.safetySince>=K.scMinOut then
   t.safetyPhase='in'; t.safetySince=now; note(t,'INFO','voiture de securite: rentre ce tour',t.safety); if p.yellowMessage then message(t,'scIn') end
  end
  if t.safetyPhase=='in' and (car.pit or now-t.safetySince>=K.scInMax) then
   local relaunched=t.relaunch
   t.neutral=false; t.relaunch=false; t.safetyPhase='parking'
   if relaunched and standing(t,frame,now,p,profile) then
    note(t,'INFO',car.pit and 'voiture de securite aux stands: formation de la grille' or 'voiture de securite non rentree, delai depasse: formation de la grille',t.safety)
   else
    t.greenUntil=now+K.greenShow; note(t,'INFO',(car.pit and 'drapeau vert: voiture de securite aux stands' or 'drapeau vert: voiture de securite non rentree, delai depasse')..(p.restartOvertake=='scIn' and ', depassement permis' or ''),t.safety)
    restartRule(t,frame,now,p)
   end
  end
 elseif t.neutral and (not relaunch and (mode=='local' or mode~=t.neutralMode) or (formLap and lapDone or not formLap and now>=t.neutralUntil) or now-t.neutralSince>=K.neutralMax) then
  local forced=now-t.neutralSince>=K.neutralMax or not relaunch and (mode=='local' or mode~=t.neutralMode)
  -- Fin de VSC (F1) : « VSC ENDING », drapeau vert quelques secondes plus tard, delta toujours jugé ; levée immédiate
  -- si les règles changent ou au délai maximal.
  if t.neutralMode=='vsc' and not forced and not t.ending and not formLap then
   t.ending=true; t.endingUntil=now+K.vscEnding; note(t,'INFO','fin de VSC annoncee',-1)
   if p.yellowMessage then message(t,'vscEnd') end
  elseif forced or not t.ending or now>=t.endingUntil then
   -- Délai maximal : les incidents encore en piste ne relancent pas de neutralisation sans fin.
   if now-t.neutralSince>=K.neutralMax then t.neutralEnd=now; note(t,'INFO','neutralisation levee: delai maximal',-1) end
   t.neutral=false; t.ending=false; if t.safetyPhase=='call' or t.safetyPhase=='out' or t.safetyPhase=='in' then t.safetyPhase='parking' end
   if relaunch and not forced and standing(t,frame,now,p,profile) then t.relaunch=false; note(t,'INFO','fin du tour de relance: formation de la grille',-1)
   else
    t.greenUntil=now+K.greenShow; note(t,'INFO','drapeau vert: fin de neutralisation',-1)
    -- Tour de relance terminé : dépassement interdit jusqu'à la ligne (ou dès le vert, Beta 1.34) ; fin de FCY ou de
    -- VSC : on court aussitôt.
    if relaunch then t.relaunch=false; restartRule(t,frame,now,p) elseif p.yellowMessage then message(t,'green') end
   end
  end
 end
 -- Reprise : une voiture qui franchit la ligne retrouve le droit de dépasser (délai maximal de sécurité).
 if t.restart then
  local any=false
  for i=1,frame.count do
   local a=frame.cars[i]; local c=t.cars[i]
   if c.restart then
    if not a.valid or a.pit or a.finished or not a.splineValid or now-t.restartSince>=K.restartMax then c.restart=false
    else
     if c.restartLast>0.5 and a.spline<0.5 and U.spline(a.spline-c.restartLast)>=0 then c.restart=false end
     c.restartLast=a.spline
    end
   end
   any=any or c.restart
  end
  t.restart=any
  if not any then note(t,'INFO','reprise: toutes les voitures ont franchi la ligne',-1) end
 end
 -- Entrée des stands fermée (règles GT et Endurance) : sous FCY, et pendant les premiers tours de voiture de sécurité.
 local closure=profile=='C' and t.neutral and p.pitsClosed or 'open'
 local scLap=frame.length/(p.safetyCarSpeedKmh/3.6)
 local closed=closure~='open' and (t.neutralMode=='fcy' or closure=='pitFcySc' and t.neutralMode=='sc' and now-t.neutralSince<K.scClosedLaps*scLap)
 if closed~=t.pitsClosed then t.pitsClosed=closed; note(t,'INFO',closed and 'stands fermes: neutralisation' or 'stands rouverts',-1) end
 -- Drapeau rouge (essais, qualifications, course) : accident grave, plusieurs voitures immobilisées en piste en même
 -- temps, joueur exclu.
 -- Course suspendue : neutralisation levée, toutes les IA rentrent aux stands et y restent ; drapeau vert une fois
 -- toutes les IA rentrées, la piste dégagée et l'interruption minimale écoulée. Délai maximal tiré du circuit : un
 -- tour et quart à la vitesse de retour, la voie des stands et l'interruption minimale (5 à 30 minutes).
 local redAllowed=(profile=='C' or profile=='P' or profile=='Q') and p.redFlagEnabled
 if redAllowed and not t.red and t.freshOnTrack>=p.redFlagCars then
  t.red=true; t.redSince=now; t.reds=(t.reds+1)%K.counterMax; t.redCancelled=false; t.standing='none'; t.gridLit=0
  t.redMax=U.clamp(p.redFlagHold+K.redLapFactor*frame.length/(p.redFlagSpeedKmh/3.6)+K.redPitMargin,K.redFlagMax,K.redFlagMaxCap)
  note(t,'INFO',string.format('drapeau rouge: %d voitures immobilisees en piste',t.onTrack),-1)
  if t.neutral then t.neutral=false; if t.safetyPhase=='call' or t.safetyPhase=='out' or t.safetyPhase=='in' then t.safetyPhase='parking' end end
  if p.yellowMessage then message(t,profile=='C' and 'red' or 'redSession') end
 end
 if t.red then
  local total,inPits=0,0
  for i=1,frame.count do
   local a=frame.cars[i]
   if a.valid and a.control and not a.player and not a.finished and not a.safetyCar then total=total+1; if a.pit then inPits=inPits+1 end end
  end
  t.redTotal=total; t.redInPits=inPits
  -- Joueur aussi dans la voie des stands, sauf arrivé ou disqualifié ; au plus jusqu'au délai maximal.
  local player=frame.player>0 and frame.cars[frame.player] or nil
  t.redPlayerIn=not player or not player.valid or player.pit or player.finished or t.playerExcluded==true
  local elapsed=now-t.redSince
  if not redAllowed or inPits>=total and t.onTrack==0 and t.redPlayerIn and elapsed>=p.redFlagHold or elapsed>=t.redMax then
   t.red=false; t.redEnd=now; t.redCancelled=not redAllowed
   if not redAllowed then
    -- Annulé (règles décochées) : personne n'avait à attendre dans la voie des stands.
    t.greenUntil=now+K.greenShow; note(t,'INFO','drapeau rouge leve: regles inactives',-1)
    if p.yellowMessage then message(t,'green') end
   elseif profile~='C' then
    -- Essais et qualifications : session reprise au drapeau vert, sans tour de relance ; les IA quittent les stands
    -- l'une après l'autre (pas de bouchon à la sortie).
    release(t,frame,now); t.greenUntil=now+K.greenShow
    note(t,'INFO',string.format('reprise apres drapeau rouge%s: session relancee',elapsed>=t.redMax and ' (delai maximal)' or ''),-1)
    if p.yellowMessage then message(t,'sessionResume') end
   else
    -- Reprise réelle (F1, WEC, GT) : IA libérées des stands dans l'ordre du classement, tour de relance derrière la
    -- voiture de sécurité (sans elle : sous VSC ou FCY), dépassement interdit, puis jusqu'à la ligne.
    local relaunchMode=t.safety>0 and not t.safetyFailed and 'sc' or p.neutralization=='vsc' and 'vsc' or 'fcy'
    local span=release(t,frame,now)
    t.relaunchSpanUntil=now+span; t.relaunchLeader=0; t.relaunchTravel=0
    t.neutral=true; t.relaunch=true; t.ending=false; t.neutralMode=relaunchMode; t.neutralSince=now
    t.neutralUntil=now+span+(relaunchMode=='sc' and p.neutralizationHold or frame.length/(p.fcySpeedKmh/3.6))
    if relaunchMode=='sc' then t.safetyPhase='out'; t.safetySince=now; t.safetyLeft=false end
    note(t,'INFO',string.format('reprise apres drapeau rouge%s: tour de relance sous %s',elapsed>=t.redMax and ' (delai maximal)' or '',relaunchMode),-1)
    if p.yellowMessage then message(t,relaunchMode=='sc' and 'redRestartSc' or relaunchMode=='vsc' and 'redRestartVsc' or 'redRestartFcy') end
   end
  end
 end
 -- Sortie après le temps d'appel, que l'incident soit encore en piste ou non.
 if t.neutral and t.safetyPhase=='call' and now-t.safetySince>=K.scCallTime then t.safetyPhase='out'; t.safetySince=now; t.safetyLeft=false; note(t,'INFO','voiture de securite: liberee',t.safety) end
 if t.safety>0 and (t.safetyPhase=='none' or t.safetyPhase=='parking' and frame.cars[t.safety].inPitBox) then t.safetyPhase='parked' end
 if t.safety==0 then t.safetyPhase='none' end
end
-- Commandes de la voiture de sécurité : garée sans pilote, libérée à vitesse limitée, rappelée aux stands.
function M.safety(t,commands,p)
 if t.safety==0 then return end
 local cmd=commands[t.safety]
 cmd.scPark=t.safetyPhase=='parked' or t.safetyPhase=='call'
 cmd.scSpeed=(t.safetyPhase=='out' or t.safetyPhase=='in' or t.safetyPhase=='parking') and p.safetyCarSpeedKmh or K.unlimitedSpeed
 cmd.rulePit=t.safetyPhase=='in' or t.safetyPhase=='parking'
 -- Libérée (Beta 1.25) : l'applicateur la fait sortir de son emplacement.
 cmd.scRelease=t.safetyPhase=='out'
end
-- Position de la voiture depuis le début de la zone jaune de l'incident (négative avant la zone).
local function position(a,zone,length,p) return U.spline(a.spline-zone.spline)*length+p.yellowBefore end
-- Limite de vitesse (km/h) et régime de drapeau jaune de la voiture i (IA) : la même référence que le temps delta du
-- joueur (son allure libre, sinon celle de sa classe, plus lente du pourcentage du régime ; vitesse de repli si
-- aucune n'est connue), moins une petite marge propre au pilote : les IA restent dans le vert.
-- Double jaune (incident en piste) : delta de zone ; simple jaune (hors piste) : allure un peu réduite.
function M.cap(t,frame,i,p,d,states,margin)
 local a=frame.cars[i]; local cap=K.unlimitedSpeed; local yellow=false; local length=frame.length
 local multi=p.multiClass==true
 local slow=(1-(margin or 0))*3.6
 local b=Delta.bin(a.spline,d.bins)
 if p.yellowEnabled and length>0 and a.splineValid then
  for z=1,t.zoneCount do
   local zone=t.zones[z]
   if zone.slot~=i then
    local at=position(a,zone,length,p)
    if at>=-K.yellowApproach and at<=p.yellowBefore+p.yellowAfter then
     -- Double jaune : delta de zone (ou Slow Zone à vitesse fixe) ; simple jaune : allure un peu réduite. Approche :
     -- référence au début de la zone.
     local rb=at>=0 and b or Delta.bin(zone.spline-p.yellowBefore/length,d.bins)
     local v
     if zone.onTrack then v=Delta.zoneReference(d,states,i,rb,multi,p) else v=Delta.reference(d,states,i,rb,multi,K.singleYellowPct,0) end
     if at>=0 then
      if v>0 then cap=min(cap,v*slow) end
      yellow=true
     else
      -- Approche : freinage jusqu'à la référence au début de la zone, à la décélération d'approche.
      if v>0 then cap=min(cap,math.sqrt(v*v+2*p.yellowDecel*(-at))*slow) end
      if -at<K.yellowNoPass then yellow=true end
     end
    end
   end
  end
 end
 if t.neutral then
  yellow=true
  -- Voiture de sécurité appelée ou encore dans la voie des stands : delta FCY, jamais plus vite qu'elle moins une
  -- marge (elle rejoint un peloton déjà ralenti) ; en piste : son allure plus un rattrapage, puis la file (directeur).
  local merging=t.neutralMode=='sc' and (t.safetyPhase=='call' or t.safety>0 and frame.cars[t.safety].pit)
  local target
  if t.neutralMode=='sc' and not merging then target=p.safetyCarSpeedKmh+K.scCatchUp
  else
   target=Delta.reference(d,states,i,b,multi,t.neutralMode=='vsc' and p.vscDeltaPct or p.fcyDeltaPct,p.fcySpeedKmh)*slow
   if merging then target=min(target,p.safetyCarSpeedKmh-K.scMergeMargin) end
  end
  cap=min(cap,max(K.trafficMinSpeed,target))
 end
 if t.red then yellow=true; cap=min(cap,max(K.trafficMinSpeed,Delta.reference(d,states,i,b,multi,p.redDeltaPct,p.redFlagSpeedKmh)*slow)) end
 -- Reprise : dépassement interdit jusqu'à la ligne (file derrière la voiture de devant), sans limite de vitesse.
 if t.restart and t.cars[i].restart then yellow=true end
 return cap,yellow
end
-- Drapeau jaune affiché au joueur dans une zone, à son approche ou sous neutralisation ; annonce unique par incident.
function M.player(t,frame,p,now)
 local i=frame.player
 if i==0 then t.playerFlag=false; t.playerYellow=false; t.playerZone=false; t.playerInside=false; t.playerRestart=false; return false end
 t.playerRestart=t.restart and t.cars[i].restart
 local a=frame.cars[i]; local flag=t.neutral or t.red
 -- Zone jaune devant le joueur (panneau) : distance à l'incident le plus proche ; vert bref à la sortie de zone.
 local inZone,distance,inside,toZone,noPass=false,math.huge,false,math.huge,false
 -- Double jaune (incident en piste) : zone où le joueur se trouve, sinon la plus proche devant lui.
 local insideDouble,nearDouble,nearest=false,false,math.huge
 t.playerZoneSlot=0
 -- Panneau d'approche avancé selon la vitesse du joueur : temps de réaction et freinage jusqu'à la limite à la
 -- décélération d'approche (150 à 800 m) ; jamais raccourci pendant l'approche d'une même zone (freinage).
 local v,vy=a.speed or 0,p.yellowSpeedKmh/3.6
 local lead=U.clamp(v*K.flagLeadTime+max(0,v*v-vy*vy)/(2*p.yellowDecel),K.playerFlagLead,K.playerFlagLeadMax)
 if t.playerZone then lead=max(lead,t.playerLead) end
 -- Voie des stands : pas de zone jaune pour le joueur (rien n'y est jugé).
 if p.yellowEnabled and frame.length>0 and a.splineValid and not a.pit then
  for z=1,t.zoneCount do
   local zone=t.zones[z]
   if zone.slot~=i then
    local at=position(a,zone,frame.length,p)
    if at>=-lead and at<=p.yellowBefore+p.yellowAfter then
     flag=true; inZone=true; distance=min(distance,max(0,p.yellowBefore-at)); toZone=min(toZone,max(0,-at))
     -- Dépassement interdit à l'approche, à la même distance que pour les IA.
     if at>=-K.yellowNoPass then noPass=true end
     -- Dans la zone elle-même (pas seulement à son approche) : vitesse limitée pour le joueur aussi.
     if at>=0 then inside=true; t.playerZoneSlot=zone.slot; insideDouble=insideDouble or zone.onTrack
     elseif -at<nearest then nearest=-at; nearDouble=zone.onTrack end
     local c=t.cars[zone.slot]
     if c.incident and not c.announced then
      c.announced=true; note(t,'INFO',string.format('drapeau jaune au joueur: incident a %.0f m',math.max(0,p.yellowBefore-at)),zone.slot)
      if p.yellowMessage then message(t,'yellow',math.max(0,p.yellowBefore-at)) end
     end
    end
   end
  end
 end
 if t.playerZone and not inZone then t.greenUntil=max(t.greenUntil,now+K.greenZoneShow) end
 t.playerZone=inZone; t.playerInside=inside; t.playerDistance=inZone and distance or 0; t.playerToZone=inZone and toZone or 0
 t.playerLead=inZone and lead or 0; t.playerNoPass=noPass
 t.playerZoneDouble=inZone and (inside and insideDouble or not inside and nearDouble)
 -- Beta 1.32 : drapeau jaune du joueur pour les panneaux lumineux du circuit ; le HUD natif seulement sur demande.
 t.playerYellow=flag; t.playerFlag=flag and p.yellowHud
 return t.playerFlag
end
return M
