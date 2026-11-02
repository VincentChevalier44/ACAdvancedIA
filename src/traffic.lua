local C=require('src/config')
local U=require('src/util')
local K=C.K
local M={}
function M.new()
 local exits={session=-1,time=0,draws=0,count=0,kept=0,gap=0,at=0,mode='',placed=0,reported=true,planned=true,flooded=false,checked=0,trouble=0,maxSlip=0,checkReported=true,order={},releaseAt={},place={},checkAt={},id={},exited={}}
 for i=1,K.maxCars do exits.releaseAt[i]=-math.huge; exits.place[i]=-1; exits.checkAt[i]=-math.huge; exits.id[i]=''; exits.exited[i]=false end
 return {nextAt=0,count=0,connected=0,active=false,logged=-1,exits=exits}
end
-- Répartition des IA en début de session (Beta 1.26, demande du pilote), à partir de spawnMinCars IA à leur
-- emplacement, une fois par session (redémarrage compris) :
--  * 'track' : chaque IA est posée directement sur la trajectoire de l'IA, à intervalles réguliers sur tout le circuit
--    (longueur divisée par le nombre d'IA), dans un ordre tiré au sort, en laissant K.spreadPlayerGap m libres de
--    chaque côté du joueur ; défaut en journée circuit. Lancée à K.spreadSpeed km/h : jamais d'IA arrêtée en piste
--    (Beta 1.21).
--  * 'pits' : chaque IA attend son tour pour sortir des stands (Beta 1.22), attente native d'AC à l'emplacement
--    (cmd.startDelay), jamais de mise en état garé ; essais et qualifications : pitExitSpread s d'écart, toutes dehors
--    en K.pitExitMaxTotal s au plus (au plus le quart d'une session courte) ; journée circuit : écart proportionnel au
--    circuit (temps pour parcourir sa part de la longueur), toutes dehors en K.trackDayExitMaxTotal s au plus. Une IA
--    qui quitte son emplacement avant son tour (déplacée par le jeu) voit son attente annulée aussitôt.
--  * 'native' : départ laissé au jeu.
-- Journée circuit avec AI flood de CSP actif pour la session : les IA sont placées par CSP, rien n'est fait. Jamais en
-- course (départ sur la grille) ni en ligne.
function M.mode(profile,p)
 if profile~='J' and profile~='P' and profile~='Q' then return 'native' end
 return p.spawnMode or 'native'
end
local function identity(a) return a.identity or a.id end
-- Bilan du placement : K.spreadCheck s après l'arrivée, une IA roule normalement (en piste, au-dessus de
-- K.spreadTroubleKmh km/h, sans glissade) ou est en difficulté ; une ligne au journal quand toutes sont jugées.
local function check(x,frame,now,log)
 for i=1,frame.count do
  if x.checkAt[i]>-math.huge and now>=x.checkAt[i] then
   local a=frame.cars[i]; x.checkAt[i]=-math.huge; x.checked=x.checked+1
   local slip=a.valid and a.slip or 0; x.maxSlip=math.max(x.maxSlip,slip)
   local reason=not a.valid and 'absente' or (a.pit or a.inPitBox) and 'aux stands' or a.offtrack and 'hors piste' or a.kmh<K.spreadTroubleKmh and 'lente' or slip>K.slipDegrees and 'glissade' or nil
   if reason then
    x.trouble=x.trouble+1
    -- Beta 1.28 : chaque IA en difficulté nommée, avec la raison (les premières seulement).
    if x.trouble<=K.spreadTroubleLines then U.log(log,now,'WARN',string.format('repartition des IA: %s (%s) en difficulte apres le placement (%s, %.0f km/h, glissement %.0f deg)',a.name,a.id,reason,a.kmh,slip),i) end
   end
  end
 end
 if not x.checkReported and x.reported and x.checked>=x.placed and x.placed>0 then
  x.checkReported=true
  U.log(log,now,x.trouble==0 and 'INFO' or 'WARN',string.format('repartition des IA: %.0f s apres le placement, %d IA roulent normalement, %d en difficulte (glissement max %.0f deg)',K.spreadCheck,x.checked-x.trouble,x.trouble,x.maxSlip),-1)
 end
end
local function plan(x,frame,p,g,profile,now,log,flooded)
 local mode=M.mode(profile,p)
 local order=x.order; local n=0
 local eligible=mode=='track' or mode=='pits' and (profile=='J' or p.pitExitSpread>0)
 if eligible and frame.time<K.pitExitWindow and not frame.online and not (profile=='J' and flooded) then
  for i=1,frame.count do
   local a=frame.cars[i]
   -- Sur le circuit : IA encore aux stands ou au pas ; sorties étalées : IA arrêtée à son emplacement.
   local candidate=mode=='track' and (a.inPitBox or a.pit or a.kmh<K.spreadMaxKmh) or mode~='track' and a.inPitBox and a.kmh<1
   if a.valid and a.control and not a.player and not a.safetyCar and candidate then n=n+1; order[n]=i end
  end
 end
 for j=#order,n+1,-1 do order[j]=nil end
 local label=profile=='J' and 'journee circuit' or profile=='P' and 'essais' or 'qualifications'
 if eligible and profile=='J' and flooded and frame.time<K.pitExitWindow and not frame.online then
  x.flooded=true
  U.log(log,now,'INFO','repartition des IA (journee circuit): AI flood de CSP actif pour cette session, IA placees par CSP',-1)
 end
 if n<math.max(2,p.spawnMinCars or 2) then return end
 local salt=K.pitExitSalt+x.draws
 table.sort(order,function(u,v) return U.unit(g.seed,u,salt)<U.unit(g.seed,v,salt) end)
 local length=frame.length
 if mode=='track' then
  -- Une part des IA (spawnPitPct, tirée au sort) reste aux stands et en sort d'elle-même, comme une vraie journée
  -- circuit ; les autres sont posées.
  local kept=math.min(n-1,math.floor(n*(p.spawnPitPct or 0)/100+0.5))
  local placed=n-kept
  local player=frame.player>0 and frame.cars[frame.player] or nil
  local origin=player and player.valid and player.splineValid and player.spline or 0
  local keep=length>0 and math.min(K.spreadPlayerGap/length,0.25) or 0
  local span=1-2*keep
  -- Écarts (demande du pilote) : spawnGapVariation 0 = réguliers ; 100 = tirés au hasard comme dans un vrai trafic (loi
  -- exponentielle : quelques IA presque l'une derrière l'autre, d'autres à plusieurs centaines de mètres) ; jamais moins
  -- de K.spreadMinGap m entre deux IA. placed+1 intervalles, les deux extrêmes (demi-poids) bordant la zone du joueur.
  local variation=U.clamp((p.spawnGapVariation or 0)/100,0,1)
  local weights,total={},0
  for k=1,placed+1 do
   local w=(1-variation)+variation*(-math.log(1-U.unit(g.seed,k,salt+2)))
   if k==1 or k==placed+1 then w=w*0.5 end
   weights[k]=w; total=total+w
  end
  local positions,at={},0
  for k=1,placed do at=at+weights[k]; positions[k]=keep+span*at/total end
  local minimum=length>0 and K.spreadMinGap/length or 0
  for k=2,placed do positions[k]=math.max(positions[k],positions[k-1]+minimum) end
  positions[placed]=math.min(positions[placed],keep+span)
  for k=placed-1,1,-1 do positions[k]=math.min(positions[k],positions[k+1]-minimum) end
  local shortest,longest=math.huge,0
  for k=2,placed do local d=(positions[k]-positions[k-1])*length; shortest=math.min(shortest,d); longest=math.max(longest,d) end
  for rank=1,placed do
   local i=order[rank]
   x.place[i]=(origin+positions[rank])%1; x.id[i]=identity(frame.cars[i])
  end
  x.count=placed; x.kept=kept; x.gap=length*span/placed; x.shortest=placed>1 and shortest or 0; x.longest=longest
  x.mode='track'; x.placed=0; x.reported=false; x.checkReported=false
  U.log(log,now,'INFO',string.format('repartition des IA (%s): %d IA sur tout le circuit, %.0f m d ecart en moyenne (de %.0f a %.0f m), circuit %.1f km, %d laissees aux stands, %.0f m laisses libres de chaque cote du joueur',label,placed,x.gap,x.shortest,x.longest,length/1000,kept,K.spreadPlayerGap),-1)
  return
 end
 local gap
 if profile=='J' then
  gap=math.max(K.pitExitMinGap,math.min(length/n/K.trackDayExitSpeed,K.trackDayExitMaxTotal/(n-1+K.pitExitJitter)))
 else
  -- Beta 1.23 : toutes dehors en K.pitExitMaxTotal s au plus (au plus le quart d'une session courte) : avec beaucoup
  -- de voitures, l'écart diminue (jamais au-delà du réglage, jamais sous K.pitExitMinGap s).
  local cap=K.pitExitMaxTotal
  if frame.left>0 then cap=math.min(cap,frame.left*K.pitExitSessionShare) end
  gap=math.min(p.pitExitSpread,math.max(K.pitExitMinGap,cap/(n-1+K.pitExitJitter)))
 end
 local last=0
 for rank=1,n do
  local i=order[rank]; local a=frame.cars[i]
  local delay=(rank-1+K.pitExitJitter*U.unit(g.seed,i,salt+1))*gap
  x.releaseAt[i]=now+delay; x.id[i]=identity(a); last=math.max(last,delay)
 end
 x.count=n; x.gap=gap; x.mode='pits'
 U.log(log,now,'INFO',string.format('sorties des stands etalees (%s): %d IA, %.1f s d ecart, la derniere dans %.0f s',label,n,gap,last),-1)
end
function M.exits(t,frame,p,g,profile,now,commands,log,flooded)
 local x=t.exits
 if frame.session~=x.session or frame.time<x.time-1 then
  x.session=frame.session; x.draws=x.draws+1; x.count=0; x.kept=0; x.at=now; x.mode=''; x.flooded=false; x.reported=true
  x.checked=0; x.trouble=0; x.maxSlip=0; x.checkReported=true
  for i=1,K.maxCars do x.releaseAt[i]=-math.huge; x.place[i]=-1; x.checkAt[i]=-math.huge; x.id[i]=''; x.exited[i]=false end
  x.planned=false
 end
 -- Préparée une fois les IA chargées (aucune à la toute première image de certaines sessions), après
 -- K.spreadPlanDelay s de session ; jamais après K.pitExitWindow s.
 if not x.planned then
  local ai=0
  for i=1,frame.count do local a=frame.cars[i]; if a.valid and a.control and not a.player then ai=ai+1 end end
  if frame.time>=K.pitExitWindow then x.planned=true
  elseif ai>0 and frame.time>=K.spreadPlanDelay then x.planned=true; plan(x,frame,p,g,profile,now,log,flooded) end
 end
 x.time=frame.time
 local pending=0
 for i=1,frame.count do
  local cmd=commands[i]; cmd.startDelay=-1; cmd.place=-1
  -- Posée : en piste, à moins de K.spreadReached m de sa place (les indicateurs de stands d'AC ne sont pas fiables
  -- dans les premiers instants de la session). Abandon : fenêtre écoulée, ou IA déjà lancée en piste par elle-même.
  if x.place[i]>=0 then
   local a=frame.cars[i]
   local away=not a.pit and not a.inPitBox
   if not a.valid or identity(a)~=x.id[i] then x.place[i]=-1
   elseif away and a.splineValid and math.abs(((a.spline-x.place[i]+0.5)%1)-0.5)*frame.length<K.spreadReached then x.place[i]=-1; x.placed=x.placed+1; x.checkAt[i]=now+K.spreadCheck
   elseif frame.time>=K.spreadWindow or away and a.kmh>K.spreadMaxKmh then x.place[i]=-1
   else
    pending=pending+1
    if frame.time>=K.spreadDelay then cmd.place=x.place[i]; cmd.placeFor=x.draws..'|'..x.id[i] end
   end
  end
  if x.releaseAt[i]>-math.huge then
   local a=frame.cars[i]
   if not a.valid or identity(a)~=x.id[i] then x.releaseAt[i]=-math.huge
   elseif a.inPitBox then
    if not x.exited[i] and now<x.releaseAt[i] then cmd.startDelay=x.releaseAt[i]-now; cmd.startDelayFor=x.draws..'|'..x.id[i] end
   elseif not x.exited[i] then
    x.exited[i]=true
    local early=now<x.releaseAt[i]
    if early then cmd.startDelay=0; cmd.startDelayFor=x.draws..'|'..x.id[i]..'|0' end
    U.log(log,now,early and 'WARN' or 'INFO',string.format('sortie des stands: tour prevu a %.0f s, sortie a %.0f s%s, %s',x.releaseAt[i]-x.at,now-x.at,early and ' (attente annulee)' or '',a.name),i)
   end
  end
 end
 -- Bilan de la répartition sur le circuit : une ligne, quand toutes sont posées ou après K.spreadReport s.
 if not x.reported and (pending==0 or frame.time>=K.spreadDelay+K.spreadReport) then
  x.reported=true
  U.log(log,now,x.placed==x.count and 'INFO' or 'WARN',string.format('repartition des IA: %d IA posees en piste sur %d prevues%s',x.placed,x.count,pending>0 and string.format(', %d encore aux stands',pending) or ''),-1)
 end
 check(x,frame,now,log)
end
function M.update(t,frame,states,p,g,profile,now,log)
 local enabled=profile=='J' and p.section_traffic
 if not enabled and not t.active and now<t.nextAt then return end
 local count,connected=0,0
 for i=1,frame.count do
  local a=frame.cars[i]
  if a.valid and a.control and not a.player then
   connected=connected+1
   if not a.pit and not a.offtrack and a.splineValid then count=count+1 end
  end
 end
 if now<t.nextAt and count==t.count and enabled==t.active then return end
 t.nextAt=now+K.trafficPeriod; t.count=count; t.connected=connected; t.active=enabled
 local targets,targetCount=0,0
 for i=1,frame.count do
  local a,s=frame.cars[i],states[i]
  s.trafficLimit=K.unlimitedSpeed; s.trafficGap=math.huge; s.trafficTarget=0
  if enabled and count>1 and a.valid and a.control and not a.player and not a.pit and not a.offtrack and a.splineValid then
   local random=U.unit(g.seed,a.index,connected)
   -- Référence : plus haute vitesse en ligne droite depuis la dernière remise à zéro, jamais plafonnée ni en virage.
   if not s.trafficApplied and (a.corner or 1)>=p.cornerMin then s.trafficReference=math.max(s.trafficReference,a.kmh) end
   local leader,ahead
   for j=1,frame.count do
    local b=frame.cars[j]
    if j~=i and b.valid and b.control and not b.player and not b.pit and not b.offtrack and b.splineValid and a.lx*b.lx+a.lz*b.lz>K.sameDirection then
     local gap=((b.spline-a.spline)%1)*frame.length-(a.length+b.length)*0.5
     if gap<s.trafficGap then s.trafficGap=math.max(0,gap); leader=b; ahead=states[j] end
    end
   end
   local variation=1+(random-0.5)*2*p.trafficVariation/100
   local base=math.min(K.trafficMinGap+a.speed*p.trafficGapSeconds+connected*p.trafficDensityGain,frame.length/count*K.trafficDensityCapacity)
   s.trafficTarget=math.min(base*variation,frame.length/count*K.trafficMaxCapacity)
   targets=targets+s.trafficTarget; targetCount=targetCount+1
   -- Beta 1.26 : une IA nettement plus rapide en ligne droite que celle de devant n'est pas retenue : elle la rattrape
   -- et la dépasse (références connues des deux voitures).
   local faster=ahead and ahead.trafficReference>0 and s.trafficReference>ahead.trafficReference*(1+K.trafficFasterMargin)
   -- Impulsions décalées entre voitures, puis libération pour retrouver l'allure native.
   -- Jamais sous la vitesse du leader moins la réduction : une référence encore incomplète
   -- (sortie des stands, remise à zéro) ne retient pas l'IA sur une portion plus rapide.
   if leader and not faster and s.trafficGap<s.trafficTarget and a.kmh>=K.trafficArmSpeed and (now+random*K.trafficCycle)%K.trafficCycle<K.trafficEpisode then
    local reduction=p.trafficMaxReduction/100*U.clamp(1-s.trafficGap/math.max(1,s.trafficTarget),0,1)
    s.trafficLimit=math.max(K.trafficMinSpeed,math.max(s.trafficReference,leader.kmh)*(1-reduction))
   end
  else s.trafficReference=0; s.trafficApplied=false
  end
 end
 -- Écart visé, une fois par session (journal) : les réglages se lisent en mètres sur le circuit du moment.
 if log and targetCount>0 and t.logged~=frame.session and frame.time>=K.trafficLogDelay then
  t.logged=frame.session
  U.log(log,now,'INFO',string.format('espacement vise: %.0f m en moyenne (circuit %.1f km, %d IA en piste)',targets/targetCount,frame.length/1000,count),-1)
 end
end
return M
