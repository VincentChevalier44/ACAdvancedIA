-- Départ arrêté après un drapeau rouge (Beta 1.34) : décisions pures, aucune écriture (commandes lues par l'applicateur).
-- Après le tour de relance derrière la voiture de sécurité (ou sous VSC/FCY), chaque voiture en piste rejoint sa place
-- de grille en roulant, dans l'ordre du classement, places resserrées ; jamais de déplacement forcé (tours exacts).
-- - formation (« grid ») : allure plafonnée selon la distance à la place, freinage d'appoint sur les derniers mètres,
--   colonne de la place, puis retenue par impulsions du compteur d'arrêt natif ; une IA qui dépasse sa place est
--   retenue là où elle est (jamais de marche arrière) ; IA aux stands retenues à leur emplacement (départ depuis la
--   voie des stands) ;
-- - feux (« lights ») : grille complète (IA en place, joueur à sa place ou aux stands) ou délai maximal écoulé ; un feu
--   par K.lightStep s, puis extinction après un délai tiré de la graine (reproductible) ; faux départ du joueur
--   surveillé dès le premier feu (position de référence) ;
-- - départ (« go ») : toutes les retenues levées ensemble, IA réveillées, drapeau vert ; dépassement permis aussitôt
--   la ligne franchie (elle est juste devant la grille).
-- Nouvel incident pendant la formation ou les feux : départ annulé, retenues levées, les drapeaux jaunes habituels
-- prennent le relais (dépassement toujours interdit jusqu'à la ligne).
local U=require('src/util')
local K=require('src/config').K
local M={}
function M.new()
 return {phase='none',slots={},slotOf={},held={},pit={},order={},source='',since=0,lightsAt=0,outAt=0,goUntil=-math.huge,
  ref=0,refSet=false,jump=false,count=0,heldCount=0,nodes=nil,timedOut=false,woke=false}
end
local function clearCars(g) for i=1,K.maxCars do g.slotOf[i]=0; g.held[i]=false; g.pit[i]=false end end
function M.reset(g)
 g.phase='none'; g.source=''; g.since=0; g.lightsAt=0; g.outAt=0; g.goUntil=-math.huge; g.ref=0; g.refSet=false; g.jump=false
 g.count=0; g.heldCount=0; g.timedOut=false; clearCars(g)
end
function M.rebase(g,amount)
 g.since=g.since-amount; g.lightsAt=g.lightsAt-amount; g.outAt=g.outAt-amount
 if U.finite(g.goUntil) then g.goUntil=g.goUntil-amount end
end
-- Places de la grille : nœuds AC_START du circuit (lus par l'applicateur : abscisse sur la piste et position latérale
-- normalisée, +1 à droite) s'ils sont cohérents (devant la ligne, à moins de K.gridNodeRange m, chacun derrière le
-- précédent, sur la piste) ; sinon calculées : première place à K.gridFirst m de la ligne, K.gridPitch m entre deux
-- places, colonnes alternées. Renvoie la liste et sa source, ou nil sans longueur de piste.
function M.resolve(nodes,length,count,out)
 if not U.finite(length) or length<=0 or count<1 then return nil,'' end
 if type(nodes)=='table' and #nodes>=count then
  local good=true; local last=0
  for k=1,#nodes do
   local n=nodes[k]; local before=U.finite(n.spline) and U.spline(-n.spline)*length or -1
   if not (before>0 and before<=K.gridNodeRange and before>last and U.finite(n.lateral) and math.abs(n.lateral)<=1) then good=false; break end
   last=before
  end
  if good then return nodes,'AC_START' end
 end
 out=out or {}
 for k=1,count do
  local s=out[k] or {}; out[k]=s
  s.spline=((-(K.gridFirst+(k-1)*K.gridPitch))/length)%1; s.lateral=k%2==1 and -K.gridColumn or K.gridColumn
 end
 for k=#out,count+1,-1 do out[k]=nil end
 return out,'calculees'
end
-- Formation : places attribuées dans l'ordre du classement aux voitures en piste (voiture de sécurité et voitures
-- arrivées exclues) ; les voitures aux stands partent de la voie des stands.
function M.start(g,t,frame,now,log)
 clearCars(g)
 local order=g.order; local n=0
 for i=1,frame.count do
  local a=frame.cars[i]
  if a.valid and not a.finished and not a.safetyCar and (a.control or a.player) then
   if a.pit then g.pit[i]=true elseif a.splineValid then n=n+1; order[n]=i end
  end
 end
 for k=#order,n+1,-1 do order[k]=nil end
 table.sort(order,function(x,y)
  local px,py=frame.cars[x].position or 0,frame.cars[y].position or 0
  if px<1 then px=math.huge end; if py<1 then py=math.huge end
  if px~=py then return px<py end
  return x<y
 end)
 local slots,source=M.resolve(g.nodes,frame.length,n,g.slots)
 if not slots then return false end
 g.slots=slots; g.source=source
 for k=1,n do g.slotOf[order[k]]=k end
 g.phase='grid'; g.since=now; g.count=n; g.heldCount=0; g.jump=false; g.refSet=false; g.timedOut=false
 t.standing='grid'
 U.log(log,now,'INFO',string.format('grille: formation, %d voitures, %s',n,source=='AC_START' and string.format('%d places (AC_START)',#g.nodes) or 'places calculees'),-1)
 return true
end
-- Distance de la voiture à sa place (positive : place devant elle), en mètres.
local function gap(g,frame,i)
 local s=g.slots[g.slotOf[i]]
 return s and U.spline(s.spline-frame.cars[i].spline)*frame.length or 0
end
-- Commandes d'une IA pendant la formation et les feux : plafond d'allure (racine de 2·décélération·distance),
-- freinage d'appoint sur les derniers mètres, colonne de sa place à l'approche, retenue une fois en place (ou au-delà
-- de sa place : distance négative, jamais de marche arrière).
local function approach(g,frame,i,cmd,offsetSign,still)
 local a=frame.cars[i]; local d=gap(g,frame,i)
 if not g.held[i] and (still or d<=K.gridHoldDistance or a.kmh<K.gridStillKmh and d<=K.gridSlotRadius) then
  g.held[i]=true; g.heldCount=g.heldCount+1
 end
 cmd.speedLimit=math.min(cmd.speedLimit or K.unlimitedSpeed,g.held[i] and K.gridCrawlKmh or U.clamp(math.sqrt(2*K.gridApproachDecel*math.max(0,d-K.gridHoldDistance))*3.6,K.gridCrawlKmh,K.gridApproachKmh))
 if g.held[i] then cmd.stopHold=true
 elseif d<K.gridBrakeFrom and a.kmh>cmd.speedLimit+K.gridBrakeMargin then cmd.brake=math.max(cmd.brake or 0,U.clamp((a.kmh-cmd.speedLimit)/K.gridBrakeScale,K.gridBrakeMin,K.brakeMax)) end
 -- Colonne de la place (repère du SDK, +1 à droite) dans le repère latéral interne calibré.
 if d<K.gridColumnFrom then local lat=g.slots[g.slotOf[i]].lateral; cmd.offset=offsetSign<0 and -lat or lat end
end
-- Départ depuis la voie des stands : retenue à l'emplacement ; sortie de la voie des stands pendant la formation (ou
-- les feux), retenue là où elle rejoint la piste, au pas, jusqu'à l'extinction (jamais lancée sur la grille arrêtée).
local function pitStarter(a,cmd)
 if a.player or not a.valid then return end
 if a.pit then cmd.pitHold=true else cmd.stopHold=true; cmd.speedLimit=math.min(cmd.speedLimit or K.unlimitedSpeed,K.gridCrawlKmh) end
end
-- Levée de toutes les retenues : réveil des IA (impulsion d'une image), plus aucune commande de grille.
local function release(g,frame,commands)
 for i=1,frame.count do if g.slotOf[i]>0 or g.pit[i] then commands[i].gridWake=true; g.woke=true end end
 clearCars(g)
end
-- À chaque image tant qu'un départ arrêté est en cours. Renvoie 'jump' quand un faux départ du joueur est à sanctionner.
function M.step(g,t,frame,now,commands,offsetSign,seed,log)
 -- Réveil d'une seule image : effacé à l'image suivante (aucune boucle tant qu'il n'y en a pas eu).
 if g.woke then for i=1,K.maxCars do commands[i].gridWake=false end; g.woke=false end
 if t.standing=='none' then if g.phase~='none' then M.reset(g) end; return nil end
 if t.standing=='grid' and g.phase=='none' and not M.start(g,t,frame,now,log) then
  t.standing='none'; t.greenUntil=now+K.greenShow; U.log(log,now,'INFO','relance arretee indisponible (grille): depart lance',-1); return nil
 end
 local player=frame.player
 -- Nouvel incident pendant la formation ou les feux : départ annulé.
 if g.phase=='grid' or g.phase=='lights' then
  for i=1,frame.count do
   local c=t.cars[i]
   if c.incident and c.since>=g.since then
    U.log(log,now,'INFO','depart arrete annule: nouvel incident',i)
    release(g,frame,commands); M.reset(g); t.standing='none'; t.gridLit=0; return nil
   end
  end
 end
 if g.phase=='grid' then
  local timeout=now-g.since>=K.gridMax
  if timeout and not g.timedOut then g.timedOut=true; U.log(log,now,'INFO',string.format('grille: delai maximal, %d IA retenues sur place',g.count-g.heldCount-(player>0 and g.slotOf[player]>0 and 1 or 0)),-1) end
  for i=1,frame.count do
   local a=frame.cars[i]
   if g.slotOf[i]>0 and not a.player and a.valid and not a.pit then approach(g,frame,i,commands[i],offsetSign,timeout)
   elseif g.pit[i] then pitStarter(a,commands[i]) end
  end
  local placed=player==0 or g.slotOf[player]==0 or frame.cars[player].pit
   or math.abs(gap(g,frame,player))<=K.gridSlotRadius and frame.cars[player].kmh<K.gridStillKmh
  local ai=g.heldCount>=g.count-(player>0 and g.slotOf[player]>0 and 1 or 0)
  if placed and ai or timeout then
   g.phase='lights'; g.lightsAt=now; t.standing='lights'
   g.outAt=now+K.lightStep*K.gridLights+K.lightsOutMin+U.unit(seed or 0,t.reds or 0,9134)*(K.lightsOutMax-K.lightsOutMin)
   U.log(log,now,'INFO',string.format('feux: allumage (%d / %d IA en place)',g.heldCount,g.count-(player>0 and g.slotOf[player]>0 and 1 or 0)),-1)
  end
 end
 if g.phase=='lights' then
  -- Extinction : avant toute retenue de cette image (elles ne sont plus reposées).
  if now>=g.outAt then
   U.log(log,now,'INFO',string.format('feux eteints apres %.1f s: depart',now-g.lightsAt),-1)
   local jumped=g.jump
   release(g,frame,commands); g.phase='go'; g.goUntil=now+K.goShow; t.standing='go'; t.gridLit=0; t.greenUntil=now+K.greenShow
   if jumped then t.jumpUntil=now+K.jumpShow; return 'jump' end
   return nil
  end
  for i=1,frame.count do
   local a=frame.cars[i]
   if g.slotOf[i]>0 and not a.player and a.valid and not a.pit then approach(g,frame,i,commands[i],offsetSign,true)
   elseif g.pit[i] then pitStarter(a,commands[i]) end
  end
  t.gridLit=math.min(K.gridLights,1+math.floor((now-g.lightsAt)/K.lightStep))
  -- Faux départ : le joueur bouge de plus de K.jumpDistance m depuis le premier feu, ou dépasse K.jumpSpeed km/h.
  local a=player>0 and frame.cars[player] or nil
  if a and a.valid and not a.pit and a.splineValid and not g.jump then
   if not g.refSet then g.ref=a.spline; g.refSet=true end
   local moved=math.abs(U.spline(a.spline-g.ref))*frame.length
   if moved>K.jumpDistance or a.kmh>K.jumpSpeed then g.jump=true; U.log(log,now,'WARN',string.format('faux depart du joueur: %.1f m, %.0f km/h, %.1f s avant l extinction',moved,a.kmh,g.outAt-now),player) end
  end
 end
 if g.phase=='go' and now>=g.goUntil then g.phase='none'; t.standing='none' end
 -- Joueur : place et distance pour le panneau (arrondie à 10 m, textes refaits rarement).
 if g.phase=='grid' and player>0 then
  t.gridSlot=g.slotOf[player]; t.gridPit=frame.cars[player].pit==true
  t.gridGap=math.max(0,math.floor(gap(g,frame,player)/10+0.5)*10)
 end
 return nil
end
return M
