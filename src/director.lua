local U=require('src/util')
local C=require('src/config')
local P=require('src/perception')
local Persona=require('src/persona')
local Classes=require('src/classes')
local Zones=require('src/zones')
local Incidents=require('src/incidents')
local Penalties=require('src/penalties')
local Flash=require('src/flash')
local K=C.K
local abs,min,max=math.abs,math.min,math.max
local M={}
local yieldStates={YIELD_IN=true,YIELD_HOLD=true,YIELD_OUT=true}
local passStates={OVT_ARM=true,OVT_IN=true,OVT_HOLD=true,OVT_OUT=true}
function M.newState()
 local s={state='IDLE',reason='init',since=0,target=0,targetSide=0,offset=0,velocity=0,filtered=0,base=0,
  persona={},zone={noYield=false,noOvertake=false,maxOffset=1},pace={},paceCount=0,paceMean=0,paceRatio=0,paceRatioCount=0,freePace=0,class=2,classified=false,classCandidate=0,classCycles=0,
  manualClass=false,stint=0,stintStart=0,pitBefore=false,pitExitUntil=0,pitCautionUntil=0,pitGuardUntil=0,
  confirm=0,confirmLost=0,pendingAt=0,pendingUntil=0,pendingTarget=0,pressure=0,pressureLost=0,pressureTarget=0,passConfirm=0,passCandidate=0,passLost=0,targetLost=0,
  holdUntil=0,postPass=false,yieldStart=0,linger=0,ignoreTarget=0,ignoreUntil=0,stuck=0,blocked=0,passBlocked=0,abortSlow=0,clear=0,restUntil=0,
  followers={},followerSlow={},multiLeader=false,yieldDetection=0,yieldMargin=0,blockedYield=0,obstacleSlow=0,obstacleIdentity='',newDirectionLimit=false,
  nextPerception=0,defendUntil=0,defendCooldown=0,defendAttacker=0,defendLap=-1,defendUsed=false,
  straight=0,calmUntil=0,speedBefore=0,speedWindow=0,speedWindowStart=0,lastContact=0,
  lapseAt=0,lapseUntil=0,lapseCount=0,brakeDemand=0,radarBrake=0,startCare=0,radarLogAt=-math.huge,blueWait=0,blueYieldLogged=false,blueWaitLogged=false,slipTime=0,errorCount=0,errorUntil=0,excluded=false,
  direction=0,lastDirectionAt=-math.huge,directions={},directionStates={},directionSides={},directionIntended={},directionFrozen={},limitState='',limitSide=0,directionCount=0,directionHead=0,driveUntil=0,returning=false,trafficLimit=K.unlimitedSpeed,trafficGap=math.huge,trafficTarget=0,
  playerGap=math.huge,playerSa=0,lappedByPlayer=false,bluePending=false,gap=math.huge,sa=0,ttc=math.huge,spinHold=false,trafficReference=0,trafficApplied=false,
  alongside=false,passAlongside=false,aborts=0,previousIdentity='',fatigue=1,yellow=false,aiFlashAt=-math.huge,overtakeArmed=false,overtakeSpline=-1,yieldClass=false,bop=0,
  hazardRel={index=0,long=0,lat=0,gap=0,sa=0,ttc=math.huge,same=false,alongside=false},
  scanRel={index=0,long=0,lat=0,gap=0,sa=0,ttc=math.huge,same=false,alongside=false},avoidClear=0,invited=0,avoidSide=0,passStall=0,holdStall=0,holdLong=math.huge,
  lane=0,laneActive=false,laneLatched=false,laneSeen=-math.huge,laneMeters=0,laneAt=0,laneLogged=false,passedByPlayerAt=-math.huge,playerBehind=false}
 for j=1,K.paceBins do s.pace[j]=0 end
 for j=1,K.directionLimit do s.directions[j]=-math.huge; s.directionStates[j]=''; s.directionSides[j]=0 end
 for j=1,K.maxCars do s.followers[j]=false; s.followerSlow[j]=0 end
 return s
end
function M.reset(s,now,keepOffset,preserveErrors)
 s.state='IDLE'; s.reason='reset'; s.since=now; s.target=0; s.targetSide=0; s.confirm=0; s.confirmLost=0
 s.pendingAt=0; s.pendingUntil=0; s.pendingTarget=0; s.pressure=0; s.pressureLost=0; s.pressureTarget=0
 s.holdUntil=0; s.linger=0; s.stuck=0; s.blocked=0; s.passBlocked=0; s.invited=0; s.passStall=0; s.abortSlow=0; s.clear=0; s.passAlongside=false
 s.calmUntil=0; s.spinHold=false; s.postPass=false; s.alongside=false; s.velocity=0; s.filtered=keepOffset and s.offset or 0
 for j=1,K.maxCars do s.followers[j]=false; s.followerSlow[j]=0 end
 if not preserveErrors then s.errorUntil=0; s.excluded=false; s.errorCount=0 end
 s.direction=0; s.directionCount=0; s.directionHead=0; s.driveUntil=0; s.returning=keepOffset==true
 s.passConfirm=0; s.passCandidate=0; s.passLost=0; s.targetLost=0; s.holdStall=0; s.holdLong=math.huge
 s.lastDirectionAt=-math.huge; for j=1,K.directionLimit do s.directions[j]=-math.huge end
 s.defendUntil=0; s.defendCooldown=0; s.defendAttacker=0; s.defendLap=-1; s.defendUsed=false
 s.ignoreTarget=0; s.ignoreUntil=0; s.lapseUntil=0; s.bluePending=false; s.yieldBlue=false; s.urgent=false
 s.blockedYield=0; s.brakeDemand=0; s.radarBrake=0; s.speedWindowStart=now; s.speedWindow=0; s.cornerBefore=nil
 s.trafficReference=0; s.trafficApplied=false; s.yellow=false; s.overtakeArmed=false; s.overtakeSpline=-1; s.yieldClass=false
 if not keepOffset then s.offset=0 end
 s.lane=0; s.laneActive=false; s.laneLatched=false; s.laneMeters=0; s.laneLogged=false
end
function M.configure(s,g,profile,p,now)
 Persona.fill(s.persona,g.seed,s.slot or 0,profile,p,s.stint)
 s.lapseAt=now+s.persona.lapseInterval
end
local function transition(e,s,state,reason,now)
 if s.state==state then return end
 s.state=state; s.reason=reason; s.since=now
 local stats=e.stats; if stats then stats[reason]=(stats[reason] or 0)+1 end
 if e.runtimeG.debugLog then U.log(e.log,now,'DEBUG',state..':'..reason,s.slot) end
end
-- Classe plus rapide (numéro plus petit) : seulement entre deux voitures déjà classées.
local function faster(p,a,b) return p.multiClass and a.classified and b.classified and a.class<b.class end
local function sideFree(row,side) return side<0 and not row.left or side>0 and not row.right end
-- Côté de l'interface, convention SDK (+1 = droite), converti dans le repère latéral interne calibré.
local function userSide(side,g) return g.offsetSign<0 and -side or side end
local function fixedSide(value,fallback,g) return userSide(value=='left' and -1 or value=='right' and 1 or fallback,g) end
local function yieldSide(p,rel,ordinary,row,g)
 local value=ordinary and p.yieldSide or p.blueFlagSide
 if value~='auto' then return fixedSide(value,1,g) end
 local preferred=rel and rel.lat<0 and -1 or 1
 if sideFree(row,preferred) then return preferred end
 return -preferred
end
local function passSide(p,profile,s,front,row,other,g)
 if p.overtakeSide=='opposite' then return -fixedSide(p.yieldSide,1,g) end
 if p.overtakeSide=='left' or p.overtakeSide=='right' then return fixedSide(p.overtakeSide,1,g) end
 local preferred=front.lat>0 and 1 or front.lat<0 and -1 or (other.yawRate~=0 and U.sign(other.yawRate) or s.persona.personalSide)
 if profile~='C' then preferred=-fixedSide(p.yieldSide,1,g) end
 if sideFree(row,preferred) then return preferred end
 if sideFree(row,-preferred) then return -preferred end
 return s.persona.assertiveness>0.5 and 1 or -1
end
local function baseModifiers(s,p,now,a)
 local persona=s.persona
 local drift=p.paceDriftPct/100*(math.sin(now/persona.period*math.pi*2+persona.phase)+math.sin(now/persona.period2*math.pi*2-persona.phase))*0.5
 local level=(p.section_general and p.levelPct/100 or a.baseLevel or a.aiLevel)*(1+persona.levelSpread+drift)
 local aggression=(p.section_general and p.aggressionPct/100*K.maxAggression or a.baseAggression or a.aiAggression)*(1+persona.aggrSpread)
 local caution=(p.section_general and p.caution or K.defaultCaution)*(1+persona.cautSpread)
 -- Grades Pro-Am et BoP émulée : multiplicateurs neutres lorsque les règles correspondantes sont inactives.
 level=level*(persona.gradeLevel or 1)*(1+(p.bopEnabled and s.bop or 0)); caution=caution*(persona.gradeCaution or 1)
 if p.enduranceOverlay then
  level=level*(1+persona.stintSwing)*(1-p.stintDegradationPct/100*U.clamp((now-s.stintStart)/K.stintDuration,0,1))
  if now<s.pitCautionUntil then caution=caution*K.stintExitCaution end
 end
 if p.weatherAdaptation then level=level*(1-K.wetLevel*a.wet); caution=caution*(1+K.wetCaution*a.wet); aggression=aggression*(1-K.wetAggression*a.wet) end
 return level,aggression,caution
end
-- Changement de direction (PDR §7.5) = changement du côté visé : gauche, ligne, droite. Suivre un but qui varie du
-- même côté (écart réduit en virage, demande urgente) n'en est pas un : ni compté, ni retenu par le délai.
local function directionAllowed(s,desired,now,p,emergency,intended,frozen)
 local direction=desired>K.sideDeadband and 1 or desired<-K.sideDeadband and -1 or 0
 if direction==s.direction then return true end
 -- Évitement, récupération et relâchement d'urgence : jamais retenus ni comptés par le plafond (PDR §7.5).
 if emergency then s.direction=direction; s.lastDirectionAt=now; return true end
 if now-s.lastDirectionAt<p.lateralCooldown then return false end
 local active=0
 for j=1,K.directionLimit do if now-s.directions[j]<K.directionWindow then active=active+1 end end
 -- Avertissement une fois par déclenchement, pas à chaque refus pendant le repos.
 if active>=K.directionLimit then if now>=s.driveUntil then s.newDirectionLimit=true; s.limitState=s.state; s.limitSide=direction end; s.limitIntended=intended or desired; s.limitFrozen=frozen==true; s.driveUntil=now+K.directionRest; return false end
 s.directionHead=s.directionHead%K.directionLimit+1; s.directions[s.directionHead]=now; s.directionStates[s.directionHead]=s.state; s.directionSides[s.directionHead]=direction; s.directionCount=active+1
 s.directionIntended[s.directionHead]=intended or desired; s.directionFrozen[s.directionHead]=frozen==true
 s.direction=direction; s.lastDirectionAt=now
 return true
end
-- Changement de côté encore permis par le plafond (repos et délai écoulés, moins de six dans la minute) : une cession ou
-- un dépassement ne commence pas s'il serait aussitôt refusé.
local function directionBudget(s,now,p)
 if now<s.driveUntil or now-s.lastDirectionAt<p.lateralCooldown then return false end
 local active=0
 for j=1,K.directionLimit do if now-s.directions[j]<K.directionWindow then active=active+1 end end
 return active<K.directionLimit
end
-- Avertissement du plafond : changements de côté retenus dans la fenêtre (état, côté visé, âge), du plus ancien au plus
-- récent, puis le changement refusé ; la cause d'un déclenchement se lit dans le journal.
-- Cible voulue avant la borne de largeur, et cible figée sur le décalage du moment (freinage, voiture à côté) : un vrai
-- changement de côté se distingue d'une borne qui s'effondre dans un virage (diagnostic).
local function wanted(value,frozen) return value and string.format(' (voulu %+.2f%s)',value,frozen and ', fige' or '') or '' end
local function limitText(s,now)
 local parts={}
 for k=1,K.directionLimit do
  local j=(s.directionHead+k-1)%K.directionLimit+1
  if now-s.directions[j]<K.directionWindow then parts[#parts+1]=string.format('%s>%+d -%.0fs',s.directionStates[j],s.directionSides[j],now-s.directions[j])..wanted(s.directionIntended[j],s.directionFrozen[j]) end
 end
 return string.format('direction_limit: %s ; refuse %s>%+d',table.concat(parts,', '),s.limitState,s.limitSide)..wanted(s.limitIntended,s.limitFrozen)
end
M.limitText=limitText
function M.reachable(s,a,p,g,desired)
 if g.offsetSign==0 or not a.splineValid or not (a.leftWidth>0 and a.rightWidth>0) then return 0 end
 local usable=max(0,min(a.leftWidth,a.rightWidth)-a.width*0.5)
 local bound=min(p.maxSideOffset,s.zone.maxOffset,usable/max(a.leftWidth,a.rightWidth))
 return U.clamp(desired,-bound,bound)
end
-- Maintien de ligne au départ (course) : sur la grille, l'écart à la trajectoire est relevé une fois (première mesure
-- valide) et commandé tel quel, la voiture étant arrêtée, décalé de 0,3 m à l'opposé d'un voisin (jamais vers lui) ;
-- après le feu vert, il est tenu tant qu'une voiture roule à côté et pendant un freinage, puis rendu à la trajectoire
-- par la rampe ordinaire, qui ne va jamais vers un côté occupé (D14). Une voiture proche de la trajectoire ou sans
-- mesure ne retient rien.
local function laneTarget(s,a,row,g)
 local meters=s.laneMeters+(row.right and not row.left and -K.laneBias or row.left and not row.right and K.laneBias or 0)
 local width=meters*g.offsetSign>0 and a.rightWidth or a.leftWidth
 if width<=0 then return 0 end
 -- Borne du côté de la voiture : elle y est déjà ; la borne symétrique la ramènerait vers la trajectoire.
 -- Beta 1.25 : au plus K.laneMaxOffset du demi-côté (échelle mètres-décalage encore jamais vérifiée en jeu).
 local bound=min(s.zone.maxOffset,K.laneMaxOffset,max(0,width-a.width*0.5)/width)
 return U.clamp(meters/width,-bound,bound)
end
local function laneHold(e,s,a,row,g,frame,now,i)
 if not frame.started then
  if not s.laneLatched and a.splineLatValid then
   s.laneLatched=true; s.laneLogged=false
   s.laneMeters=g.offsetSign~=0 and abs(a.splineLat)>=K.laneMin and a.splineLat or 0
  end
  s.lane=s.laneMeters~=0 and laneTarget(s,a,row,g) or 0; s.laneSeen=now; s.laneActive=s.lane~=0
  if s.laneActive then s.offset=s.lane; s.filtered=s.lane; s.velocity=0 end
  return s.lane
 end
 if s.lane==0 then return 0 end
 s.laneActive=true
 if not s.laneLogged then
  s.laneLogged=true; s.laneAt=now
  U.log(e.log,now,'INFO',string.format('maintien de ligne: %s a %+.1f m de la trajectoire (decalage %+.2f)',a.name,s.laneMeters,s.lane),i)
 end
 if s.alongside then s.laneSeen=now end
 if now-s.laneSeen<K.laneRelease or a.brake>K.ruleBrake then
  local target=laneTarget(s,a,row,g); if target~=0 then s.lane=target end
  return s.lane
 end
 s.laneActive=false
 U.log(e.log,now,'INFO',string.format('maintien de ligne: %s rendu apres %.1f s, ecart mesure %+.1f m',a.name,now-s.laneAt,(a.splineLat or 0)-s.laneMeters),i)
 s.lane=0
 return 0
end
function M.lateral(s,desired,row,a,p,g,dt,now)
 local intended,frozen=desired,desired==s.offset
 if not s.laneActive then desired=M.reachable(s,a,p,g,desired) end
 local delta=desired-s.offset
 local blocked=delta<0 and row.left or delta>0 and row.right
 local factor=1; local emergency=false
 if blocked then
  s.blocked=s.blocked+dt; s.velocity=0; s.filtered=s.offset
  if s.blocked<K.blockedRelease then return s.offset end
  -- Recule seulement dans le côté libre, sans traverser la ligne centrale.
  local retreat=s.offset<0 and not row.right or s.offset>0 and not row.left
  if not retreat then return s.offset end
  desired=0; delta=desired-s.offset; factor=p.emergencyReleaseFactor; emergency=true
 else s.blocked=0 end
 if delta==0 then s.velocity=0; return s.offset end
 -- Plafond anti-zigzag (PDR §7.5) : seules les manœuvres comptent. La variation lente de la ligne en conduite libre
 -- et le retour à la ligne pendant le repos imposé ne sont pas des changements de direction.
 local maneuver=s.state~='DRIVE' and s.state~='IDLE'
 -- Beta 1.29 (bilan des journaux du 2 novembre : 1225 des 3780 changements notés, 38 %, venaient de la borne) : le côté
 -- compté est celui que vise la manœuvre, pas la cible bornée par la largeur ; dans un virage, la borne retombe presque
 -- à zéro et passait pour un retour à la ligne, puis un nouveau départ du même côté. Le repos de 20 s qui suivait
 -- coupait cessions et dépassements.
 if maneuver and not directionAllowed(s,emergency and desired or intended,now,p,emergency or s.state=='CALM' or s.state=='AVOID',intended,frozen) then s.velocity=0; s.filtered=s.offset; return s.offset end
 local rate=p.rampSpeed*U.clamp(K.lateralSpeedBase/max(a.kmh,K.lateralSpeedFloor),K.lateralRateMin,K.lateralRateMax)*factor
 local velocity=U.sign(delta)*rate
 s.velocity=U.approach(s.velocity,velocity,p.rampAccel*dt)
 s.filtered=U.ema(s.filtered,desired,dt,p.lowPassTau)
 local candidate=U.approach(s.offset,s.filtered,abs(s.velocity)*dt)
 local nextOffset=U.clamp(candidate,min(s.offset,desired),max(s.offset,desired))
 -- Dernière barrière, valable aussi pour les retours au centre et les dépassements annulés.
 if (nextOffset<s.offset and row.left) or (nextOffset>s.offset and row.right) then return s.offset end
 s.offset=nextOffset
 return s.offset
end
-- Joueur à la hauteur d'une autre voiture, ou qui en rattrape une dans sa file : son écart n'invite pas à passer
-- (une IA déjà passée qui s'éloigne ou roule à son allure n'empêche pas l'invitation de la suivante).
local busyRel={}
local function busy(frame,player,i)
 local a=frame.cars[player]
 for j=1,frame.count do
  local b=frame.cars[j]
  if j~=player and j~=i and b.valid and not b.pit then
   local r=P.relative(a,b,frame.length,busyRel)
   if r.same and (abs(r.long)<=(a.length+b.length)*0.5 or r.long>0 and r.gap<K.inviteClear and abs(r.lat)<=K.latPass and r.sa>=K.inviteSa) then return true end
  end
 end
 return false
end
-- fleet : allure médiane de la classe à chaque endroit (module delta), pour estimer l'allure libre là où l'IA n'a jamais
-- roulé seule (rythme relatif appris ailleurs, au moins K.paceRatioMin endroits).
local function pace(s,a,row,dt,p,fleet)
 local bin=min(K.paceBins,math.floor(a.spline*K.paceBins)+1)
 -- Allure habituelle apprise seulement en conduite libre : jamais sous drapeau jaune, neutralisation ou espacement.
 if s.state=='DRIVE' and row.free and s.lapseUntil<=0 and a.splineValid and not a.pit and not a.offtrack and not s.yellow and not s.trafficApplied then
  local old=s.pace[bin]
  if old==0 then s.paceCount=s.paceCount+1; s.paceMean=(s.paceMean*(s.paceCount-1)+a.speed)/s.paceCount; s.pace[bin]=a.speed
  else local v=old+(a.speed-old)*K.paceAlpha; s.pace[bin]=v; s.paceMean=s.paceMean+(v-old)/max(1,s.paceCount) end
  local median=fleet and fleet[bin] or 0
  if median>0 then
   local ratio=a.speed/median
   s.paceRatio=s.paceRatioCount>0 and s.paceRatio+(ratio-s.paceRatio)*K.paceRatioAlpha or ratio; s.paceRatioCount=s.paceRatioCount+1
  end
 end
 local free=s.pace[bin]
 if free==0 and fleet and s.paceRatioCount>=K.paceRatioMin and (fleet[bin] or 0)>0 then free=fleet[bin]*s.paceRatio end
 s.freePace=free
 if free>0 and a.speed<free*p.stuckPaceRatio then s.stuck=s.stuck+dt else s.stuck=0 end
end
local function lapOrClass(e,s,a,other,rel,p,profile)
 local laps=not C.solo(profile) and p.blueFlagEnabled and Classes.laps(a,other,rel,e.frame.length) or 0
 local upper=faster(p,e.states[other.slot],s)
 return laps,upper
end
local function yieldTrigger(e,s,a,row,p,profile,now,dt)
 local back=row.back>0 and row.neighbors[row.back] or nil
 -- Le voisin lent le plus proche ne doit pas masquer un leader ou un joueur rapide.
 local approaching
 for j=1,row.count do
  local r=row.neighbors[j]
  if r.long<0 and r.gap>=0 and abs(r.lat)<=K.latYield and not yieldStates[e.states[r.index].state] and r.sa>=p.yieldBehindMargin*K.nearYieldMargin
   and (not approaching or r.gap<approaching.gap) then approaching=r end
 end
 if approaching then back=approaching end
 local flash=e.flash.requests[a.slot]
 local activeFlash=flash.untilTime>now and now>=flash.readyAt
 if activeFlash and a.corner<p.cornerMin and not flash.extended then flash.untilTime=flash.cornerUntil; flash.extended=true end
 if activeFlash then
  local player=P.find(row,e.frame.player)
  if player and player.long<0 and player.gap<=p.flashRange then back=player end
 end
 local ai=e.flash.ai[a.slot]
 local aiFlash=not activeFlash and ai.untilTime>now and now>=ai.readyAt
 if aiFlash then
  local source=P.find(row,ai.source)
  if source and source.long<0 and source.gap>=0 and source.gap<=p.flashRange then back=source else aiFlash=false end
 end
 if not back or back.gap<0 then s.confirm=0; s.pendingAt=0; s.pendingTarget=0; s.bluePending=false; return nil end
 local other=e.frame.cars[back.index]
 local laps,upper=lapOrClass(e,s,a,other,back,p,profile)
 if yieldStates[e.states[other.slot].state] then s.pendingAt=0; return nil end
 if faster(p,s,e.states[other.slot]) and laps==0 then s.pendingAt=0; return nil end
 local blueRange=p.blueFlagRange*((laps>=2 or upper) and K.lapRangeMult or 1)
 -- Beta 1.24 : en course, voiture qui prend un tour collée derrière, à la même allure (retenue) : drapeau bleu aussi.
 -- En essais et qualifications, l'écart de tours ne dit que le temps passé en piste : il faut s'approcher.
 local blue=laps>0 and back.gap<=blueRange and (back.sa>=K.lapSpeed or profile=='C' and back.gap<=K.blueCloseGap and back.sa>=-K.blueSlack)
 local classYield=upper and back.sa>=p.classYieldMargin and (back.sa>=K.classFightSpeed or row.front==0 or row.neighbors[row.front].gap>K.followRange)
 -- Beta 1.29 : appel du joueur jugé tant que la demande vit (plus rapide, ou retenu juste derrière) : appelé de loin un
 -- peu trop lentement, il est compris dès que le joueur se rapproche.
 local currentAdvantage=Flash.advantage(p,back.gap,back.sa)
 local acceptedFlash=activeFlash and back.index==e.frame.player and currentAdvantage
 local permittedFlash=acceptedFlash and (profile~='C' or p.flashMode=='always' or blue or classYield)
 -- Appel d'une IA : en course, admis pour un tour ou une classe supérieure, même à vitesse égale (voiture bloquée).
 -- Dans une file (Beta 1.21) : collée à une voiture, une IA qui s'écarte et ralentit pour une voiture à peine plus rapide
 -- ne laisse passer personne et ralentit toute la file (train de voitures identiques en journée circuit). Cession
 -- ordinaire et appel de phares d'une IA comme la cession entre classes : piste libre devant, ou suiveur nettement plus
 -- rapide. L'appel de phares du joueur reste honoré.
 local clear=row.front==0 or row.neighbors[row.front].gap>K.followRange or back.sa>=K.classFightSpeed
 local aiAccepted=aiFlash and back.index==ai.source and (profile~='C' and clear or laps>0 or upper)
 if profile=='C' and not blue and not classYield and not permittedFlash and not aiAccepted then s.confirm=0; s.pendingAt=0; s.pendingTarget=0; s.bluePending=false; return nil end
 local ordinary=p.yieldEnabled and profile~='C' and clear
 if not ordinary and not blue and not classYield and not permittedFlash and not aiAccepted then return nil end
 if s.ignoreTarget==back.index and now<s.ignoreUntil then return nil end
 local margin=p.yieldBehindMargin*U.lerp(K.courtesyMin,K.courtesyMax,s.persona.courtesy)*U.lerp(K.gapMarginMin,1,back.gap/K.yieldMarginRange)
 local horizon=p.yieldHorizon
 if acceptedFlash then margin=margin*K.flashMargin; horizon=horizon*K.flashHorizon end
 local detection=max(p.yieldDetectBehind,min(K.detectMax,max(0,back.sa/3.6)*horizon))*(1+(p.weatherAdaptation and K.wetDetect*e.frame.wet or 0))
 if acceptedFlash then detection=max(detection,p.flashRange) end
 local c1=ordinary and back.gap<=detection and back.sa>=margin and back.ttc<=horizon
 local c2=ordinary and back.gap<=K.nearYield and back.sa>=K.nearYieldMargin*margin
 if p.pressureEnabled and back.gap<=p.pressureGap and abs(back.sa)<=K.pressureSa then
  if s.pressureTarget~=back.index then s.pressure=0; s.pressureTarget=back.index end
  s.pressure=s.pressure+dt; s.pressureLost=0
 elseif back.gap>p.pressureGap*K.pressureResetRange then
  s.pressureLost=s.pressureLost+dt; if s.pressureLost>K.pressureResetTime then s.pressure=0 end
 end
 local c3=ordinary and p.pressureEnabled and s.pressure>=p.pressureTime
 local c4=permittedFlash
 local c5=aiAccepted
 local trigger=c1 or c2 or c3 or c4 or c5 or blue or classYield
 local needed=blue and K.lapConfirm or classYield and p.confirmTime*K.classConfirm or (c4 or c5) and K.flashConfirm or p.confirmTime
 if activeFlash and not c4 then needed=needed*K.flashMargin end
 if trigger then
  s.confirmLost=0
  if s.pendingTarget~=back.index then s.confirm=0; s.pendingAt=0; s.pendingTarget=back.index end
  s.confirm=s.confirm+dt
  if s.confirm>=needed and s.pendingAt==0 then
   local reaction=s.persona.reaction+s.persona.awareness*U.unit(e.runtimeG.seed,a.slot,other.index+e.eventSalt)
   if c4 or c5 then reaction=U.clamp(s.persona.reaction*K.flashReact,K.flashReactionMin,K.flashReactionMax) elseif blue then reaction=reaction*K.lapReaction elseif classYield then reaction=reaction*K.classReaction end
   s.pendingAt=now+reaction; s.pendingUntil=now+K.pendingTTL
  end
 else
  s.confirmLost=s.confirmLost+dt
  if s.confirmLost>K.confirmReset then s.confirm=0; s.pendingAt=0; s.pendingTarget=0; s.bluePending=false end
 end
 if now>s.pendingUntil and s.pendingAt>0 then s.pendingAt=0; s.confirm=0 end
 if not trigger or s.pendingAt==0 or now<s.pendingAt then return nil end
 local corner=blue and K.lapCorner or classYield and K.classCorner or p.cornerMin
 if a.corner<corner then s.bluePending=blue; if blue then s.blueReason='virage' end; return nil end
 local side=yieldSide(p,back,profile~='C' and not blue,row,e.runtimeG)
 if not sideFree(row,side) then s.blockedYield=s.blockedYield+dt else s.blockedYield=0 end
 local blocked=s.zone.noYield and 'zone sans cession' or a.kmh<K.speedMinYield and 'trop lent' or not sideFree(row,side) and 'cote occupe' or not directionBudget(s,now,p) and 'trop de changements de trajectoire' or nil
 if blocked then if blue then s.blueReason=blocked end; return nil end
 s.target=back.index; s.targetSide=side; s.gap=back.gap; s.sa=back.sa; s.ttc=back.ttc
 s.yieldDetection=max(detection,blue and blueRange or 0); s.yieldMargin=margin
 for j=1,K.maxCars do s.followers[j]=false; s.followerSlow[j]=0 end
 s.followers[back.index]=true; s.multiLeader=false
 s.confirm=0; s.pendingAt=0; s.pendingTarget=0; s.bluePending=false; s.holdUntil=now+p.yieldHoldMin
 s.linger=0; s.postPass=false; s.yieldStart=now; s.yieldBlue=blue or classYield; s.urgent=c4 and flash.urgent
 s.yieldClass=(classYield or c5 and upper) and not blue
 if c5 then U.log(e.log,now,'INFO','cede sur appel de phares de '..other.name,a.slot) end
 if c4 then U.log(e.log,now,'INFO',string.format('cede sur appel de phares du joueur (%.0f m, %+.0f km/h)',back.gap,back.sa),a.slot) end
 return back
end
-- Réduction progressive depuis la vitesse actuelle, jamais sous la limite cible : après un freinage ou un virage,
-- l'IA réaccélère librement jusqu'à cette limite au lieu d'être retenue à sa vitesse du moment.
function M.trafficCap(cmd,s,a,p,profile,dt)
 local applied=profile=='J' and p.section_traffic and s.state=='DRIVE'
 local limit=applied and not s.alongside and a.corner>=p.cornerMin and s.trafficLimit or K.unlimitedSpeed
 if limit<K.unlimitedSpeed then
  local start=cmd.speedLimit<K.unlimitedSpeed and cmd.speedLimit or a.kmh
  cmd.speedLimit=U.approach(max(start,limit),limit,K.trafficDecelKmh*dt)
 elseif applied and cmd.speedLimit<a.kmh then cmd.speedLimit=U.approach(cmd.speedLimit,a.kmh,K.trafficAccelKmh*dt)
 else cmd.speedLimit=K.unlimitedSpeed end
 s.trafficApplied=cmd.speedLimit<K.unlimitedSpeed
end
function M.step(e,i,dt,now)
 local frame=e.frame; local a=frame.cars[i]; local s=e.states[i]; local cmd=e.commands[i]
 local p,g,profile=e.run,e.runtimeG,e.profile; local row=e.perception.rows[i]
 cmd.active=false; a.wet=frame.wet
 if a.player then return end -- État du joueur tenu par le moteur pour sa carte d'allure.
 if not a.valid or not a.control or a.pit or a.offtrack or a.finished or a.safetyCar or s.excluded or s.disqualified or now<s.errorUntil then
  if a.pit then s.pitBefore=true end
  cmd.yellowLimit=K.unlimitedSpeed; s.yellow=false
  transition(e,s,'IDLE','guard',now); return
 end
 local identity=a.identity or a.id
 if a.teleport or s.previousIdentity~=identity then
  M.reset(s,now,false); s.previousIdentity=identity; s.bop=0
  for j=1,K.paceBins do s.pace[j]=0 end
  s.paceCount=0; s.paceMean=0; s.paceRatio=0; s.paceRatioCount=0; s.freePace=0
 end
 if s.pitBefore then
  s.pitBefore=false; s.stint=s.stint+1; s.stintStart=now
  Persona.fill(s.persona,g.seed,i,profile,p,s.stint)
  s.pitExitUntil=now+(p.enduranceOverlay and K.stintExitDelay or K.pitExitDelay)
  s.pitCautionUntil=now+K.stintExitCautionTime; s.pitGuardUntil=now+K.pitGuardTime; M.reset(s,now,true)
 end
 a.corner=U.clamp(1-abs(a.yawRate or 0)/p.cornerYawRef,0,1)
 if s.returning and abs(s.offset-M.reachable(s,a,p,g,s.base))<K.centerEpsilon then s.returning=false end
 Zones.at(e.zones,a.spline,s.zone)
 if a.pitDistance and a.pitDistance<K.pitZone then s.zone.maxOffset=min(s.zone.maxOffset,K.pitOffsetMax) end
 if now>=s.nextPerception then P.refresh(e.perception,frame.cars,frame.count,i,frame.length,e.frames); s.nextPerception=now+K.perceptionPeriod end
 P.occupancy(frame.cars,frame.count,i,g,row)
 -- Drapeau jaune ou neutralisation : limite propre, composée avec l'espacement par l'applicateur, descente bornée.
 local cap,yellow=Incidents.cap(e.incidents,frame,i,p,e.delta,e.states,s.persona.deltaMargin)
 s.yellow=yellow
 -- Sous drapeau (zone jaune et son approche, neutralisation, drapeau rouge) : en file derrière la voiture de devant,
 -- sans la rattraper au-delà d'un léger rapprochement ; jamais derrière une voiture accidentée, arrêtée ou très lente,
 -- qu'il est permis de doubler. Évite qu'une IA rattrape et double celle qui freine la première pour la zone.
 if (yellow or e.incidents.neutral or e.incidents.red) and row.front>0 and row.neighbors[row.front].gap<K.scQueueGap then
  local front=row.neighbors[row.front]; local j=front.index
  -- Voiture qui doit rendre la place à celle-ci (IA ou joueur), qui purge une sanction, ou dont celle-ci reprend la
  -- place : jamais de file derrière elle.
  local owes=Penalties.mayPass(e.penalties,i,j,now,frame.player)
  if not owes and not Penalties.passable(frame.cars[j],e.incidents.cars[j],p,now) then
   cap=min(cap,max(K.trafficMinSpeed,frame.cars[j].kmh+max(0,front.gap-K.queueKeep)*K.queueClose))
  end
 end
 if cap<K.unlimitedSpeed then
  local start=cmd.yellowLimit<K.unlimitedSpeed and cmd.yellowLimit or a.kmh
  cmd.yellowLimit=U.approach(max(start,cap),cap,p.yellowDecel*3.6*dt)
 else cmd.yellowLimit=K.unlimitedSpeed end
 local front=row.front>0 and row.neighbors[row.front] or nil
 local back=row.back>0 and row.neighbors[row.back] or nil
 local target=P.find(row,s.target)
 -- Voiture accidentée hors du voisinage de même sens (tête-à-queue, contresens) : position relative directe.
 if not target and s.state=='AVOID' and s.target>0 and s.target<=frame.count and e.incidents.cars[s.target].incident then
  target=P.relative(a,frame.cars[s.target],frame.length,s.hazardRel)
 end
 local player=P.find(row,frame.player)
 local request=e.flash.requests[i]
 if request.untilTime>now and (not player or player.long>(a.length+frame.cars[frame.player].length)*0.5+K.passBuffer or player.gap>p.flashRange*K.lostRange) then request.untilTime=0 end
 local ai=e.flash.ai[i]
 if ai.untilTime>now then
  local source=P.find(row,ai.source)
  if not source or source.long>(a.length+frame.cars[ai.source].length)*0.5+K.passBuffer or source.gap>p.flashRange*K.lostRange then ai.untilTime=0 end
 end
 s.playerGap=player and player.gap or math.huge; s.playerSa=player and player.sa or 0
 -- Beta 1.29 (demande du pilote) : hors course, pas de bagarre avec le joueur. Juste doublée par lui (il passe de
 -- derrière à devant, tout près), l'IA ne cherche pas à le repasser pendant K.courtesyTime s ; tant qu'il est collé
 -- derrière, à côté, ou juste devant après l'avoir doublée, elle lâche de l'agressivité : l'IA native ne force plus.
 if player and player.long>0 and s.playerBehind and player.gap<=K.courtesyRange then s.passedByPlayerAt=now end
 s.playerBehind=player~=nil and player.long<=0
 local passedByPlayer=profile~='C' and player~=nil and player.long>0 and now-s.passedByPlayerAt<K.courtesyTime
 local courtesy=profile~='C' and player~=nil and player.gap<=K.courtesyRange and (player.long<=0 or passedByPlayer)
 s.lappedByPlayer=player and Classes.laps(a,frame.cars[frame.player],player,frame.length)>0 or false
 s.alongside=false
 for j=1,row.count do local r=row.neighbors[j]; if r.alongside and abs(r.lat)>=K.nearLine and abs(r.lat)<=g.occLatMax then s.alongside=true; break end end
 local level,aggression,caution=baseModifiers(s,p,now,a)
 if courtesy then aggression=aggression*K.courtesyAggression end
 local desired=0; local elapsed=now-e.startedAt
 cmd.active=true; cmd.brake=0
 local startPhase=profile=='C' and elapsed<p.startDelay+p.startRelax
 -- Règle sportive : aucun changement de trajectoire ne commence au freinage.
 local braking=p.noMoveBraking and a.brake>K.ruleBrake
 if s.spinHold and a.kmh>=K.calmExitSpeed then s.spinHold=false end
 if profile=='C' and (not frame.started or elapsed<p.startDelay) or now<s.pitExitUntil or s.spinHold then
  transition(e,s,'IDLE','start',now); s.confirm=0; s.pendingAt=0
 else
  if s.state=='IDLE' then transition(e,s,'DRIVE','ready',now) end
  if now-s.speedWindowStart>=K.contactWindow then
   local drop=s.speedWindow-a.kmh
   if p.contactRecovery and drop>=K.contactDrop and row.nearest<K.contactRange then
    s.calmUntil=now+K.calmTime; s.lastContact=now; transition(e,s,'CALM','contact',now)
   end
   s.speedWindow=a.kmh; s.speedWindowStart=now
  end
  if s.state=='CALM' then
   if now>=s.calmUntil then
    if a.kmh>=K.calmExitSpeed then transition(e,s,'DRIVE','calm_end',now) else transition(e,s,'IDLE','spun',now); s.spinHold=true end
   end
   level=level*K.calmLevel; aggression=aggression*K.calmAggression; caution=caution*K.calmCaution
  else
   local obstacle
   if p.obstacleEnabled and (profile~='C' or elapsed>=p.startDelay) then
    local jam=false
    for j=1,row.count do
     local r=row.neighbors[j]; local other=frame.cars[r.index]
     if r.long>0 and r.gap<p.obstacleDetect and abs(r.lat)<=K.latPass and (not other.player or other.kmh<=p.obstacleSpeedKmh) then
      local slow=other.kmh<p.obstacleSpeedKmh and other.stopped>=K.obstacleTime or other.stopped>=K.stoppedTime
      -- Bouchon : une voiture lente que l'on suit déjà au pas n'est pas un obstacle à contourner, sauf incident ;
      -- une voiture en travers l'est toujours.
      local approach=r.sa>=K.obstacleClosing or e.incidents.cars[r.index].incident
      if slow and not approach and other.slip<=K.slipDegrees then jam=true end
      if (other.slip>K.slipDegrees or slow and approach) and (not obstacle or r.gap<obstacle.gap) then obstacle=r end
     end
    end
    -- Journal : bouchon suivi sans évitement, compté une fois par épisode.
    if jam and not obstacle and not s.jamNoted then s.jamNoted=true; e.stats.jam=(e.stats.jam or 0)+1 elseif not jam then s.jamNoted=false end
    if not obstacle then
     local nearest,distance=0,math.huge
     for j=1,frame.count do
      local c=e.incidents.cars[j]
      if j~=i and c.incident and c.onTrack then
       local r=P.relative(a,frame.cars[j],frame.length,s.scanRel)
       if r.coherent and r.long>0 and r.gap<p.obstacleDetect and abs(r.lat)<=K.latPass and r.gap<distance then nearest=j; distance=r.gap end
      end
     end
     if nearest>0 then obstacle=P.relative(a,frame.cars[nearest],frame.length,s.hazardRel) end
    end
   end
   if obstacle then
    if s.state~='AVOID' or s.target~=obstacle.index then s.avoidClear=0; s.avoidSide=0 end
    s.target=obstacle.index; target=obstacle; transition(e,s,'AVOID','obstacle',now)
   end
   if s.state=='AVOID' then
    level=level*(1-p.obstacleLevelDrop/100); aggression=aggression*K.avoidAggression; caution=caution*p.obstacleCautionMult
    if target then
     local side=s.avoidSide~=0 and s.avoidSide or target.lat>0 and 1 or target.lat<0 and -1 or (a.leftWidth>a.rightWidth and userSide(-1,g) or a.rightWidth>a.leftWidth and userSide(1,g) or fixedSide(p.yieldSide,1,g))
     -- Obstacle qui glisse vers le côté retenu (tête-à-queue qui traverse la piste) : côté réévalué, jamais vers lui.
     if s.avoidSide~=0 and target.lat*side<-K.nearLine then side=-side; s.avoidSide=0 end
     -- Obstacle au milieu : l'un ou l'autre côté ; décalé : jamais vers lui.
     if s.avoidSide==0 and not sideFree(row,side) and abs(target.lat)<K.nearLine then side=-side end
     if sideFree(row,side) then s.avoidSide=side end
     if sideFree(row,side) and not s.zone.noOvertake and P.corridor(frame.cars,frame.count,i,side,target.gap,target.index,g.occLatMax) then desired=side*min(p.avoidOffset,p.maxSideOffset)
     else level=level*K.obstacleBlockedLevel; desired=s.offset end
     -- Cible repartie à vive allure, sans glisser ni être un incident, pendant une seconde : l'évitement s'achève.
     local other=frame.cars[target.index]
     local moving=not e.incidents.cars[target.index].incident and other.kmh>=p.obstacleSpeedKmh+K.avoidClearMargin and other.slip<=K.slipDegrees and other.stopped<K.obstacleTime
     s.avoidClear=moving and s.avoidClear+dt or 0
     if target.long<-K.obstacleClear or s.avoidClear>=K.avoidRecheck then transition(e,s,'DRIVE','obstacle_clear',now) end
    else transition(e,s,'DRIVE','obstacle_lost',now) end
   else
    if now<s.driveUntil then transition(e,s,'DRIVE','direction_limit',now)
    elseif not s.returning and not startPhase and not s.yellow and not braking and s.lapseUntil<=now and not s.alongside and (not yieldStates[s.state] or s.state=='YIELD_OUT') and yieldTrigger(e,s,a,row,p,profile,now,dt) then
     transition(e,s,'YIELD_IN','yield',now)
    -- Retour après dépassement : jamais de nouveau maintien (PDR §10.2.4) ; l'occupation retient le rabattement.
    -- En attente derrière la cible (OVT_ARM), une voiture à côté retient le déboîtement mais ne le saute pas.
    elseif s.alongside and passStates[s.state] and s.state~='OVT_OUT' and s.state~='OVT_ARM' then transition(e,s,'OVT_HOLD','alongside',now) end
    if yieldStates[s.state] then
     -- Sous drapeau jaune, laisser passer revient à se faire dépasser : la cession s'achève.
     if s.yellow and s.state~='YIELD_OUT' then transition(e,s,'YIELD_OUT','yellow',now) end
     local amp=K.cornerAmpMin+(1-K.cornerAmpMin)*a.corner
     desired=s.targetSide*min(p.maxSideOffset,p.yieldOffset*amp*(s.urgent and K.urgentAmp or 1))
     if p.predictableSlowClass and s.yieldClass then desired=s.base end
     if s.state=='YIELD_IN' and abs(s.offset-M.reachable(s,a,p,g,desired))<K.yieldReachedEpsilon then transition(e,s,'YIELD_HOLD','yield_position',now) end
     if s.state~='YIELD_OUT' then
      level=level*(1-(s.yieldBlue and K.blueSlowdown or p.yieldSlowdownPct/100)); aggression=aggression*K.yieldAggression
      if s.state=='YIELD_HOLD' then caution=caution*K.yieldHoldCaution end
     end
     if target and target.long<0 and target.gap<K.invitationGap then
      s.linger=s.linger+dt
      if s.linger>K.invitationTime or s.urgent then level=level*(1-p.inviteSlowdownPct/100*U.clamp((s.linger-K.invitationTime)/K.invitationRamp+(s.urgent and 1 or 0),0,1)) end
     end
     local remaining=0
     for j=1,row.count do
      local r=row.neighbors[j]; local other=frame.cars[r.index]
      if r.long<0 and r.gap>=0 and r.gap<=s.yieldDetection and abs(r.lat)<=K.latYield and not yieldStates[e.states[r.index].state] then
       local laps,upper=lapOrClass(e,s,a,other,r,p,profile)
       local qualifies=profile~='C' and p.yieldEnabled and r.sa>=p.yieldBehindMargin or laps>0 and r.sa>=K.lapSpeed or upper and r.sa>=p.classYieldMargin
       if qualifies and not s.followers[r.index] then s.followers[r.index]=true; s.holdUntil=max(s.holdUntil,now+p.yieldHoldMin); s.postPass=false end
      end
     end
     for j=1,frame.count do
      if s.followers[j] then
       local r=P.find(row,j)
       if r and r.long<0 and r.sa<K.lostSaRatio*s.yieldMargin and r.gap>K.slowLostGap then s.followerSlow[j]=s.followerSlow[j]+dt else s.followerSlow[j]=0 end
       local passed=r and r.long>(a.length+frame.cars[j].length)*0.5+K.passBuffer
       local lost=not r or r.gap>s.yieldDetection*K.lostRange or s.followerSlow[j]>K.slowLostTime
       if passed or lost then s.followers[j]=false else remaining=remaining+1 end
      end
     end
     if remaining>=2 and s.yieldBlue then s.multiLeader=true end
     if remaining==0 and s.state~='YIELD_OUT' then
      if not s.postPass then s.holdUntil=max(s.holdUntil,now+s.persona.holdAfter+(s.multiLeader and K.blueTrainHold or 0)); s.postPass=true end
      if now-s.yieldStart>=max(K.holdFloor,p.yieldHoldMin) and now>=s.holdUntil then transition(e,s,'YIELD_OUT','passed',now) end
     end
     if now-s.yieldStart>p.yieldMaxHold then s.ignoreTarget=s.target; s.ignoreUntil=now+K.ignoreFollower; transition(e,s,'YIELD_OUT','hold_limit',now) end
     if s.state=='YIELD_OUT' then desired=s.base; if abs(s.offset-M.reachable(s,a,p,g,s.base))<K.centerEpsilon then transition(e,s,'DRIVE','yield_end',now); s.target=0 end end
    elseif passStates[s.state] then
     if s.yellow and not s.alongside and s.state~='OVT_OUT' then transition(e,s,'OVT_OUT','abort_yellow',now) end
     desired=s.targetSide*p.overtakeOffset*(K.cornerAmpMin+(1-K.cornerAmpMin)*a.corner)
     if not target then
      -- Beta 1.26 : cible perdue de vue un instant (roues hors piste, choix des voisins) : manœuvre tenue sur son
      -- décalage K.targetLostGrace s avant l'abandon ; en préparation, retour à la ligne pendant K.abortSlowTime s.
      s.targetLost=s.targetLost+dt
      local arm=s.state=='OVT_ARM'
      local grace=arm and K.abortSlowTime or s.state~='OVT_OUT' and K.targetLostGrace or 0
      if s.targetLost>=grace then transition(e,s,'OVT_OUT','target_lost',now) else desired=arm and s.base or s.offset end
     else
      s.targetLost=0
      local alongside=target.alongside and s.state~='OVT_ARM'
      if alongside then s.passAlongside=true; s.holdStall=0; s.holdLong=math.huge; if s.state~='OVT_OUT' then transition(e,s,'OVT_HOLD','alongside',now) end; desired=s.offset end
      if s.state=='OVT_IN' and abs(s.offset-M.reachable(s,a,p,g,desired))<K.yieldReachedEpsilon then transition(e,s,'OVT_HOLD','pass_position',now) end
      if not alongside and s.state~='OVT_OUT' then
       local clear=P.corridor(frame.cars,frame.count,i,s.targetSide,K.corridorMin,s.target,g.occLatMax)
       -- Abandon avant le côte à côte seulement (PDR §10.2.4) : ensuite l'IA termine, sauf si la cible repasse devant
       -- et s'éloigne. « La cible s'échappe » ne vaut que pour une cible encore devant.
       s.abortSlow=target.long>0 and target.sa<0 and target.gap>K.abortGap and s.abortSlow+dt or 0
       s.passStall=s.state~='OVT_ARM' and target.long>0 and not s.passAlongside and target.sa<K.passStallSa and s.passStall+dt or 0
       if s.state=='OVT_ARM' and now-s.since>K.passArmMax then s.passStall=K.passStallTime+dt end
       s.passBlocked=not clear and not s.passAlongside and s.passBlocked+dt or 0
       -- Côte à côte achevé sans marge atteinte (cible repassée devant, ou juste derrière à la même allure) : retour au
       -- bout de quelques secondes sans progrès vers la marge ; un dépassement lent qui progresse n'est jamais coupé.
       if s.passAlongside then
        if target.long<s.holdLong-K.holdProgress then s.holdLong=target.long; s.holdStall=0 else s.holdStall=s.holdStall+dt end
       else s.holdStall=0; s.holdLong=math.huge end
       -- Suiveur beaucoup plus rapide : en course, seulement s'il prend un tour ou vient d'une classe plus rapide (on ne
       -- renonce pas à une attaque pour une voiture du même tour qui freine plus tard).
       local fastBack=not s.passAlongside and back and back.sa>=K.abortFollowerSpeed and back.gap<K.abortFollowerGap
        and (profile~='C' or Classes.laps(a,frame.cars[back.index],back,frame.length)>0 or faster(p,e.states[back.index],s))
       if s.passBlocked>K.abortBlocked or s.abortSlow>K.abortSlowTime or s.passStall>K.passStallTime or fastBack or s.holdStall>K.passHoldMax then
        s.aborts=s.aborts+1
        transition(e,s,'OVT_OUT',s.passBlocked>K.abortBlocked and 'abort_blocked' or s.abortSlow>K.abortSlowTime and 'abort_slow' or s.passStall>K.passStallTime and 'abort_stall' or fastBack and 'abort_follower' or 'hold_limit',now)
       end
      end
      if s.state=='OVT_ARM' then
       desired=s.base
       -- Déboîtement en ligne droite seulement (PDR §10.2.4).
       if target.gap<=U.clamp(p.pullOutGapBase+p.pullOutGapPerMps*a.speed,p.pullOutGapBase,K.pullOutMax) and a.corner>=K.passCornerC and not s.alongside and a.brake<K.passBrakeMax and not braking
        and -target.lat*s.targetSide<K.pullOutTargetLat then transition(e,s,'OVT_IN','pull_out',now) end
      end
      if target.long<-(a.length+frame.cars[target.index].length)*0.5-p.overtakeClearMargin then s.clear=s.clear+dt else s.clear=0 end
      if s.clear>=K.clearConfirm and s.state~='OVT_OUT' then
       if p.overtakeChain and front and front.index~=s.target and front.gap<p.overtakeDetectAhead and P.corridor(frame.cars,frame.count,i,s.targetSide,K.corridorMin,front.index,g.occLatMax) then s.target=front.index; s.clear=0; s.passStall=0; s.passAlongside=false; transition(e,s,'OVT_IN','chain',now)
       else transition(e,s,'OVT_OUT','clear',now) end
      end
     end
     if s.state=='OVT_OUT' then desired=s.base; if abs(s.offset-M.reachable(s,a,p,g,s.base))<K.centerEpsilon then s.restUntil=now+p.overtakeRestTime; s.target=0; transition(e,s,'DRIVE','pass_end',now) end end
     if s.state=='OVT_IN' or s.state=='OVT_HOLD' then aggression=aggression*K.passAggression; caution=min(caution,max(K.slipCautionMin,caution*K.passCaution)) end
    elseif s.state=='DEFEND' then
     desired=s.targetSide*min(p.defenseMaxOffset,p.maxSideOffset); aggression=aggression*K.defenseAggression; caution=caution*K.defenseCaution
     local req=e.flash.requests[i]
     if now>=s.defendUntil or s.alongside or s.yellow or a.brake>K.ruleBrake or req.untilTime>now or not back or not sideFree(row,s.targetSide) then transition(e,s,'DRIVE','defense_end',now) end
    else
     s.base=userSide(s.persona.laneBias,g)
     if row.nearest>K.jitterRange then s.base=s.base+(math.sin(now/s.persona.jitterPeriod*math.pi*2+s.persona.phase)+0.5*math.sin(now/s.persona.jitterPeriod2*math.pi*2-s.persona.phase))/1.5*p.personalLineJitter end
     s.base=U.clamp(s.base,-K.baseMax,K.baseMax); desired=s.base
     local defend=false
     -- Défense : jamais au freinage, quel que soit l'onglet Règles.
     if not s.returning and not startPhase and not s.yellow and a.brake<=K.ruleBrake and s.lapseUntil<=now and profile=='C' and p.defenseEnabled and back and back.gap<p.defenseTriggerGap and back.sa>0 and a.corner>=K.passCornerC and not s.alongside and now>=s.defendCooldown and directionBudget(s,now,p) and not s.defendUsed and e.flash.requests[i].untilTime<=now then
      local laps,upper=lapOrClass(e,s,a,frame.cars[back.index],back,p,profile)
      if laps==0 and not upper and (s.defendAttacker~=back.index or s.defendLap~=a.lap) then
       s.defendAttacker=back.index; s.defendLap=a.lap
       local probability=K.defenseChance+K.defenseAssert*s.persona.assertiveness
       local side=back.lat>0 and -1 or 1
       if U.unit(g.seed,i,a.lap+back.index)<probability and sideFree(row,side) then
        s.targetSide=side; s.defendUntil=now+K.defenseTime; s.defendCooldown=now+p.defenseCooldown; s.defendUsed=true
        transition(e,s,'DEFEND','attacker',now); defend=true
       end
      end
     end
     -- Joueur écarté au-delà de la file de l'IA (il n'est alors pas « la voiture devant ») : cible de l'invitation.
     local front=front
     if frame.player>0 and (not front or front.index~=frame.player) then
      local invitee=P.find(row,frame.player)
      if invitee and invitee.long>0 and invitee.gap<=K.inviteGap and abs(invitee.lat)>=K.inviteLat and abs(invitee.lat)<=K.inviteLatMax
       and (not front or invitee.gap<front.gap) then front=invitee end
     end
     local canPass=not s.returning and not startPhase and not s.yellow and not braking and s.lapseUntil<=now and p.overtakeEnabled and front and front.gap>=0 and now>=s.restUntil and directionBudget(s,now,p) and not s.zone.noOvertake and not s.alongside
      and a.kmh>=K.speedMinPass and a.corner>=(profile=='C' and K.passCornerC or p.cornerMin) and a.brake<K.passBrakeMax
     if canPass and not defend then
      local other=frame.cars[front.index]; local margin=p.overtakeAheadMargin*U.lerp(K.assertMin,K.assertMax,s.persona.assertiveness)*U.lerp(K.gapMarginMin,1,front.gap/K.passMarginRange)
      if faster(p,s,e.states[front.index]) then margin=margin*K.classMargin end
      local slowClass=faster(p,e.states[front.index],s)
      local lapped=not C.solo(profile) and Classes.laps(a,other,front,frame.length)>0
      local leaderRow=e.perception.rows[front.index]; local ahead=leaderRow and leaderRow.front>0 and leaderRow.neighbors[leaderRow.front]
      local fight=lapped and ahead and other.speed>0 and ahead.gap/other.speed<K.fightTime and abs(ahead.sa)<K.fightSpeed or false
      local advantage=profile=='C' and K.passAdvantageC or K.passAdvantageJ
      local trigger=front.gap<=p.overtakeDetectAhead and front.sa>=margin and front.ttc<=p.overtakeHorizon
      local stuck=s.stuck>=p.stuckTime*s.persona.patience
      trigger=trigger or (front.gap<=max(K.stuckGapMin,K.stuckGapTime*a.speed) and stuck)
      local free=s.freePace
      local potential=max(front.sa,stuck and (free-a.speed)*3.6 or 0)
      -- Invitation à passer, course comprise : le joueur juste devant, les deux voitures en ligne droite, s'écarte nettement
      -- de la trajectoire de l'IA qui le suit sans doubler lui-même, ou l'IA de devant lui cède la place. Aucune avance de
      -- vitesse exigée (l'IA native se cale sur la voiture de devant), dépassement direct du côté libéré.
      local otherState=e.states[front.index]
      local yieldingToMe=(otherState.state=='YIELD_IN' or otherState.state=='YIELD_HOLD') and otherState.target==i
      local invited=yieldingToMe or front.index==frame.player and abs(front.lat)>=K.inviteLat and front.gap<=K.inviteGap and front.sa>-K.inviteSa
       and abs(a.yawRate)<=K.inviteCurve*a.speed and abs(other.yawRate)<=K.inviteCurve*other.speed and not busy(frame,front.index,i)
      s.invited=invited and s.invited+dt or 0
      invited=s.invited>=K.inviteTime
      trigger=trigger or invited
      -- Beta 1.29 : hors course, pas de riposte sur le joueur qui vient de la doubler, sauf s'il ralentit nettement.
      if passedByPlayer and front.index==frame.player and not invited and front.sa<K.courtesyPassSa then trigger=false end
      if trigger and (potential>=advantage or invited) and not slowClass and not fight then
       if s.passCandidate~=front.index then s.passCandidate=front.index; s.passConfirm=0 end
       s.passConfirm=s.passConfirm+dt; s.passLost=0
       local side=invited and (front.lat>0 and 1 or -1) or passSide(p,profile,s,front,row,other,g)
       local req=U.clamp((front.gap+a.length+other.length+2*p.overtakeClearMargin)*a.speed/max(a.speed-other.speed,K.corridorSpeedMin),K.corridorMin,K.corridorMax)
       if p.overtakeSide=='auto' and yieldStates[otherState.state] and sideFree(row,-otherState.targetSide) then side=-otherState.targetSide end
       local yieldingSame=yieldStates[otherState.state] and otherState.targetSide==side
       if s.passConfirm>=p.confirmTime and sideFree(row,side) and not yieldingSame and P.corridor(frame.cars,frame.count,i,side,req,front.index,g.occLatMax) then
        s.target=front.index; s.targetSide=side; s.clear=0; s.abortSlow=0; s.passBlocked=0; s.passStall=0; s.passAlongside=false
        s.passConfirm=0; s.passCandidate=0
        if invited then s.ignoreTarget=front.index; s.ignoreUntil=now+K.inviteRespite end
        transition(e,s,profile=='C' and not invited and 'OVT_ARM' or 'OVT_IN',yieldingToMe and 'yielded' or invited and 'invited' or 'pass',now)
       end
      else
       s.passLost=s.passLost+dt; if s.passLost>K.confirmReset then s.passConfirm=0; s.passCandidate=0 end
      end
     elseif not canPass then s.invited=0; s.passLost=s.passLost+dt; if s.passLost>K.confirmReset then s.passConfirm=0; s.passCandidate=0 end
     end
    end
   end
  end
 end
 if a.corner<K.passCornerC then s.defendUsed=false end
 -- Départ de course (Beta 1.25) : à fond en ligne droite derrière la voiture de devant ; la prudence de départ ne vient
 -- qu'au freinage et en virage (premier virage), vite, et repart lentement (sortie du virage). Lancement : ligne droite
 -- pendant le départ, sans prudence de suivi ; seul un contact vraiment imminent fait freiner le radar.
 local starting=profile=='C' and frame.started and elapsed<p.startDelay+p.startRelax
 if starting then
  local wanted=(a.brake>K.ruleBrake or a.corner<K.startCorner) and 1 or 0
  s.startCare=U.approach(s.startCare,wanted,(wanted>s.startCare and K.startCareRise or K.startCareFall)*dt)
 else s.startCare=0 end
 local launch=starting and s.startCare<0.5
 local following=front and front.gap<K.followRange and not s.alongside and (p.section_general or p.section_overtake or s.state~='DRIVE')
 if not following or not p.slipstreamEnabled or a.corner<K.slipCorner or a.kmh<=K.slipSpeed then s.slipTime=0 end
 if following then
  if not launch then
   caution=caution*U.lerp(K.followCaution,1,(front.gap-K.followMinGap)/K.followGapRange)*s.persona.brakeMargin
   if front.ttc<K.followTTC then caution=caution*K.followTTCMult end
  end
  if p.slipstreamEnabled and a.corner>=K.slipCorner and a.kmh>K.slipSpeed then s.slipTime=s.slipTime+dt; if s.slipTime>K.slipTime then caution=min(caution,max(K.slipCautionMin,caution*K.slipCaution)) end else s.slipTime=0 end
  if profile=='C' and front.index==frame.player and front.gap<K.playerFollowGap then caution=caution*K.playerCaution end
 end
 -- Radar avant (Beta 1.24) : dès la grille et en toute session, une IA qui va heurter une voiture devant elle dans sa
 -- file (joueur ou IA, la plus proche du contact) lève d'abord le pied (prudence accrue à moins de K.radarWarnTTC s du
 -- contact), puis, contact imminent (moins de K.radarTTC s), ajoute un léger freinage dosé, monté et relâché
 -- progressivement, comme un pilote : jamais de coup de frein, jamais d'écart latéral ; le frein ne fait que s'ajouter.
 -- Une aspiration ou une approche lente n'est pas un contact imminent : rien n'y change.
 local radarTarget=0
 if g.useBrakeAssist then
  local close,closeTTC=nil,math.huge
  for j=1,row.count do
   local r=row.neighbors[j]; local other=frame.cars[r.index]
   if r.long>0 and r.sa/3.6>K.brakeClosing and abs(r.lat)<=(a.width+other.width)*0.5+K.radarLatMargin then
    local ttc=max(0,r.gap)/(r.sa/3.6)
    if ttc<closeTTC then close=r; closeTTC=ttc end
   end
  end
  if close then
   if closeTTC<K.radarWarnTTC and not launch then caution=caution*U.lerp(K.radarCaution,1,closeTTC/K.radarWarnTTC) end
   if closeTTC<(launch and K.radarLaunchTTC or K.radarTTC) then
    radarTarget=U.clamp(close.sa/3.6/K.brakeGain,K.radarMinBrake,K.radarBrakeMax)
    if launch and s.radarBrake==0 then e.startRadar=(e.startRadar or 0)+1 end
    if s.radarBrake==0 and (now>=s.radarLogAt or s.radarLogAt-now>K.radarLogPeriod) then
     s.radarLogAt=now+K.radarLogPeriod
     U.log(e.log,now,'INFO',string.format('radar avant: %s freine derriere %s (%.0f m, %.0f km/h plus vite)',a.name,frame.cars[close.index].name,close.gap,close.sa),i)
    end
   end
  end
 end
 s.radarBrake=U.approach(s.radarBrake,radarTarget,(radarTarget>s.radarBrake and K.radarApply or K.radarRelease)*dt)
 if s.radarBrake>0 then cmd.brake=max(cmd.brake,s.radarBrake) end
 -- Départ (course) : prudence et agressivité de départ dès la grille, pleines jusqu'à la fin de l'attente (premier virage
 -- compris), puis ramenées à la normale pendant la détente ; aucun déplacement commandé d'ici là.
 if profile=='C' and (not frame.started or elapsed<p.startDelay+p.startRelax) then
  local relax=frame.started and (elapsed-p.startDelay)/p.startRelax or 0
  local care=frame.started and s.startCare or 1
  caution=caution*U.lerp(U.lerp(1,p.startCautionMult,care),1,relax); aggression=aggression*U.lerp(U.lerp(1,p.startAggrMult,care),1,relax)
  s.laneActive=false
  if s.state~='AVOID' then desired=p.startLaneHold and laneHold(e,s,a,row,g,frame,now,i) or 0 end
 elseif s.lane~=0 or s.laneActive then s.lane=0; s.laneActive=false
 end
 local allowLapse=p.lapseEnabled and not s.alongside and s.state~='DEFEND' and s.state~='YIELD_IN' and s.state~='IDLE' and s.state~='CALM'
 s.fatigue=p.enduranceOverlay and now-s.lastContact>K.fatigueTime and K.fatigueGain or 1
 if now>=s.lapseAt and allowLapse then
  s.lapseCount=(s.lapseCount+1)%K.counterMax; Persona.nextLapse(s.persona,g.seed,i,s.lapseCount,p)
  s.lapseUntil=now+s.persona.lapseDuration; s.lapseAt=now+s.persona.lapseInterval/min(K.fatigueMax,s.fatigue)
 end
 if s.lapseUntil>now and allowLapse then
  local ramp=min((s.persona.lapseDuration-(s.lapseUntil-now))/K.lapseRamp,(s.lapseUntil-now)/K.lapseRamp,1)
  level=level*(1-s.persona.lapseDrop*max(0,ramp))
 elseif s.lapseUntil<=now then s.lapseUntil=0 end
 if s.bluePending then level=level*K.lapCornerLevel end
 if s.alongside and s.state~='AVOID' then aggression=p.section_general and p.aggressionPct/100*K.maxAggression or a.baseAggression or a.aiAggression; desired=s.offset; if passStates[s.state] then caution=caution*K.alongsideCaution end end
 -- Sortie des stands : prudence accrue derrière une voiture proche (joueur compris).
 local pitGuard=now<s.pitGuardUntil and front and front.gap<K.pitGuardGap
 if pitGuard then caution=caution*K.pitGuardCaution end
 if a.brake>K.brakeEmulationPedal or front and front.gap<K.brakeEmulationRange and front.sa/3.6>K.brakeEmulationClosing then
  caution=caution*(1+K.brakeEmulationGain*(p.brakeZonePct-100)/100)*s.persona.brakeMargin
 end
 if s.state~='DRIVE' then s.blockedYield=0 end
 if s.blockedYield>K.blockedYieldTime and back and back.gap<K.blockedYieldGap then level=level*(1-p.yieldSlowdownPct/100) end
 -- Appel de phares d'une IA réellement retenue sous son allure derrière la voiture de devant (en course : tour ou
 -- classe). Une classe rapide qui s'approche sans être gênée n'appelle pas : la lutte de la classe lente continue.
 if p.aiFlashEnabled and front and front.gap>=0 and not s.yellow and not startPhase and now-s.aiFlashAt>=K.aiFlashCooldown
  and a.kmh>K.flashSpeed and a.corner>=p.cornerMin and s.state~='IDLE' and s.state~='CALM' and s.state~='AVOID' then
  local other=frame.cars[front.index]; local otherState=e.states[front.index]
  local free=s.freePace
  local held=front.gap<K.aiFlashGap and s.stuck>=p.stuckTime and (free-other.speed)*3.6>=p.flashMinAdvantage
  local allowed=held and profile~='C'
  if held and profile=='C' then
   allowed=faster(p,s,otherState) or Classes.laps(other,a,P.relative(other,a,frame.length,s.scanRel),frame.length)>0
  end
  if allowed and other.control and not other.player and not yieldStates[otherState.state] then
   local request=e.flash.ai[front.index]
   s.aiFlashAt=now; cmd.flashEvent=(cmd.flashEvent%K.counterMax)+1; e.stats.flash=(e.stats.flash or 0)+1
   U.log(e.log,now,'INFO',string.format('appel de phares: %s -> %s',a.name,other.name),i)
   request.source=i; request.untilTime=now+p.flashRequestTTL
   request.readyAt=now+U.clamp(otherState.persona.reaction or K.neutralReaction,K.flashReactionMin,K.flashReactionMax)
  end
 end
 -- Overtake Mode (F1 2026) : à moins de l'écart choisi derrière la voiture de devant au point de détection (fin du
 -- tour), gain de niveau dans les lignes droites du tour suivant. Coupé sous drapeau, sous la pluie, et après le départ
 -- ou une reprise tant que le leader n'a pas atteint le point de détection.
 if profile=='C' and p.overtakeMode and not s.yellow and not startPhase and not e.weather.wet and e.drsRule.leader>=K.overtakeDetect then
  if s.overtakeSpline>=0 and s.overtakeSpline<K.overtakeDetect and a.spline>=K.overtakeDetect and a.spline-s.overtakeSpline<0.5 then
   s.overtakeArmed=front~=nil and a.speed>0 and front.gap/a.speed<=p.overtakeModeGap
  end
  if s.overtakeArmed and a.corner>=p.cornerMin then level=level*(1+p.overtakeModeBoostPct/100) end
 else s.overtakeArmed=false end
 s.overtakeSpline=a.splineValid and a.spline or -1
 if braking and s.state~='AVOID' and s.state~='CALM' then desired=s.offset end
 if s.zone.noYield and yieldStates[s.state] or s.zone.noOvertake and passStates[s.state] then desired=s.base end
 if a.corner<K.returnCornerMin and (s.state=='YIELD_OUT' or s.state=='OVT_OUT' or s.state=='DRIVE') then desired=s.offset end
 if s.state=='IDLE' then desired=s.laneActive and s.lane or 0; s.confirm=0; s.pendingAt=0 end
 if frame.length<=0 or not a.splineValid then desired=0 end
 -- Repos anti-zigzag : jamais au détriment d'un évitement ou d'une récupération en cours.
 if now<s.driveUntil and s.state~='AVOID' and s.state~='CALM' then desired=0; if s.state~='IDLE' then transition(e,s,'DRIVE','direction_limit',now) end end
 cmd.offset=M.lateral(s,desired,row,a,p,g,dt,now)
 if s.newDirectionLimit then s.newDirectionLimit=false; e.stats.limit=(e.stats.limit or 0)+1; U.log(e.log,now,'WARN',limitText(s,now),i) end
 local tau=s.state=='CALM' or s.state=='AVOID'
 tau=tau and K.fastModulatorTau or s.state=='YIELD_OUT' and K.yieldRecoveryTau or s.yieldBlue and yieldStates[s.state] and K.blueRecoveryTau or K.modulatorTau
 cmd.level=U.ema(cmd.level,U.clamp(level,K.minNativeLevel,1.1),dt,tau)
 cmd.aggression=U.ema(cmd.aggression,U.clamp(aggression,0,K.maxAggression),dt,tau)
 cmd.caution=U.ema(cmd.caution,U.clamp(caution,0.5,K.maxCaution),dt,tau)
 cmd.levelOwned=p.section_general or abs(cmd.level-(a.baseLevel or a.aiLevel))>=K.levelEpsilon
 cmd.aggressionOwned=p.section_general or abs(cmd.aggression-(a.baseAggression or a.aiAggression))>=K.aggrEpsilon
 cmd.cautionOwned=p.section_general or abs(cmd.caution-K.defaultCaution)>=K.cautionEpsilon
 M.trafficCap(cmd,s,a,p,profile,dt)
 -- Sortie des stands : une fois le limiteur levé, jamais de rattrapage brutal de la voiture de devant. Écart de
 -- vitesse permis de 7,5 à 15 km/h selon l'assurance, réduit avec la distance, négatif si elle est trop près.
 if pitGuard then
  local ahead=frame.cars[front.index].kmh
  local margin=K.pitGuardAllowance*U.lerp(0.5,1,s.persona.assertiveness)*U.clamp((front.gap-K.pitGuardMin)/(K.pitGuardGap-K.pitGuardMin),0,1)
  local cap=front.gap<K.pitGuardMin and ahead-K.pitGuardBack or ahead+margin
  cmd.speedLimit=math.min(cmd.speedLimit,math.max(math.min(K.trafficMinSpeed,ahead),cap))
 end
 s.brakeDemand=cmd.brake; s.cornerBefore=a.corner
 -- Journal des drapeaux bleus (Beta 1.24) : IA en retard d'un tour ou plus devant le joueur, à portée : une ligne quand
 -- elle le laisse passer, une autre si elle tarde (plus de K.blueLogTime s), avec la raison. Sous drapeau jaune,
 -- neutralisation ou drapeau rouge, céder est interdit : l'attente est suspendue, rien n'est noté.
 local flagged=s.yellow or e.incidents.neutral or e.incidents.red
 if flagged then
 elseif profile=='C' and p.blueFlagEnabled and s.lappedByPlayer and s.playerGap<=p.blueFlagRange and (s.playerSa>0 or s.playerGap<=K.blueCloseGap) then
  s.blueWait=s.blueWait+dt
  if yieldStates[s.state] and s.target==frame.player then
   if not s.blueYieldLogged then s.blueYieldLogged=true; U.log(e.log,now,'INFO',string.format('drapeau bleu: %s laisse passer le joueur apres %.1f s',a.name,s.blueWait),i) end
  elseif s.blueWait>=K.blueLogTime and not s.blueWaitLogged then
   s.blueWaitLogged=true
   U.log(e.log,now,'INFO',string.format('drapeau bleu: %s devant le joueur depuis %.0f s sans le laisser passer (%s, %.0f m, %+.0f km/h)',a.name,s.blueWait,s.blueReason or 'en attente',s.playerGap,s.playerSa),i)
  end
 elseif s.playerGap>p.blueFlagRange*2 or not s.lappedByPlayer then s.blueWait=0; s.blueYieldLogged=false; s.blueWaitLogged=false; s.blueReason=nil end
 pace(s,a,row,dt,p,e.delta.fleet[p.multiClass and s.class or 1])
 if front then s.gap=front.gap; s.sa=front.sa; s.ttc=front.ttc end
end
M.pace=pace
return M
