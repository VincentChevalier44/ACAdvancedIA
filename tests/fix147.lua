-- Beta 1.47 : défauts relevés dans les journaux du 4 novembre (départs de Monza et de Spa en chaîne de chocs, déport en
-- défense vers le joueur sur un tour de sortie, boucles de dépassement, seuil d'usure jamais atteint, cessions inutiles
-- en essais, avertissement de limites de piste pour une voiture poussée, drapeau bleu, journal). Reproduits par
-- Engine.step avec les chiffres des journaux. Chargé par tests/extended.lua.
local F=require('tests/fixture')
local E=require('src/engine')
local C=require('src/config')
local A=require('src/applier')
local K=C.K
local tests={}
local function count(e,text) local n=0; for k=1,e.log.limit do local r=e.log[k]; if r and r.message and r.message:find(text,1,true) then n=n+1 end end return n end
local function learned(e,first,last,speed)
 for i=first,last do local s=e.states[i]; s.paceCount=e.delta.bins; for b=1,e.delta.bins do s.pace[b]=speed end end
end
-- Départ de course : n voitures en file (le joueur loin derrière), 6 m d'écart, accélération commune, accordéon de
-- ±20 km/h (relevé : rapprochements de +50 km/h, temps avant contact 1,0 à 1,3 s), rotation passagère de 0,07 rad/s en ligne droite (0,15 s toutes les
-- 1,3 s), frein imposé par l'app relu dans la pédale (écho de CSP). Renvoie le compte des freinages radar pendant
-- seconds s, le frein le plus fort imposé, et la plus forte part de prudence de départ (startCare).
local function pack(n,seconds,topKmh,brakeAt)
 local e,f=F.scene('C',n+1); C.preset('Course','C',e.profiles.C); E.changed(e); F.tick(e,f,1/60)
 f.length=20000; e.startedAt=e.time
 F.place(f,1,-5000,0)
 for k=2,n+1 do F.place(f,k,1000-(k-2)*(6+4.4),60); e.states[k].nextPerception=0 end
 local onsets,maxBrake,maxCare=0,0,0
 local before={}
 local t=0
 for _=1,math.floor(seconds*60) do
  t=t+1/60
  local v=math.min(topKmh or 280,60+25*t)
  for k=2,n+1 do
   local a=f.cars[k]
   a.kmh=v+20*math.sin(t*1.5+k); a.speed=a.kmh/3.6
   a.yawRate=((t*60+k*7)%78)<9 and 0.07 or 0
   -- Écho : la pédale lue est le maximum du frein natif et du frein imposé par l'app.
   a.brake=math.max(e.commands[k].brake or 0,brakeAt and k==2 and t>=brakeAt and 0.8 or 0)
  end
  F.tick(e,f,1/60,true)
  for k=2,n+1 do
   local s=e.states[k]
   if (s.radarBrake or 0)>0 and not before[k] then onsets=onsets+1 end
   before[k]=(s.radarBrake or 0)>0
   maxBrake=math.max(maxBrake,e.commands[k].brake or 0)
   maxCare=math.max(maxCare,s.startCare or 0)
  end
 end
 return onsets,maxBrake,maxCare,e,f
end
-- Monza : 900 m à fond avant le Rettifilo ; aucun freinage du pilote : le lancement tient malgré les rotations
-- passagères et l'écho du frein de l'app ; voitures collées les unes aux autres : le radar lève le pied sans freiner
-- (Beta 1.45 sur cette scène : 28 freinages radar jusqu'à 0,45, lancement perdu).
tests.START_LAUNCH_HELD_147=function()
 local onsets,maxBrake,maxCare=pack(16,10)
 assert(maxCare<0.5,'launch held on the straight despite yaw blips and the brake echo (care '..maxCare..')')
 assert(maxBrake<=K.radarStartBrakeMax+1e-9,'start: app brake capped before the first braking zone ('..maxBrake..')')
 assert(onsets<=5,'radar brakings in the first 10 s divided by at least 5 (1.45: 28; now '..onsets..')')
end
-- Le premier vrai freinage (celui de tête) arrête le lancement de la voiture qui freine et, K.startAnticipate s avant ce
-- point, celui des voitures qui suivent ; jamais de retour au lancement ensuite. Spa : La Source à 250 m, 140 km/h.
tests.START_PACK_ANTICIPATE_147=function()
 local _,_,_,e,f=pack(6,5,140,3)
 local lead=e.states[2]
 assert(lead.startBraked and lead.startCare>=0.5,'the leader braking for the first corner: launch over')
 assert(e.startPackSpline~=nil,'pack braking point recorded')
 -- Voiture juste derrière (moins de K.startAnticipate s du point) : prudente sans avoir freiné elle-même, et gardée
 -- prudente une fois le point passé.
 local near=e.states[3]
 assert(near.startBraked and near.startCare>=0.5 and f.cars[3].brake<=K.ruleBrake,'follower close to the braking point: careful before braking ('..near.startCare..')')
 -- Fin du freinage du meneur : le lancement ne revient pas.
 f.cars[2].brake=0; for _=1,120 do f.cars[2].brake=0; F.tick(e,f,1/60,true) end
 assert(lead.startCare>=0.5,'no return to launch after a real brake')
end
-- Radar au départ : contact imminent (moins de K.radarLaunchTTC s), voiture collée derrière : lever de pied, aucun
-- frein ; sans suiveur : frein plafonné à K.radarStartBrakeMax (au lieu de K.radarBrakeMax).
tests.START_RADAR_LIFT_147=function()
 local function scene(follower)
  local e,f=F.scene('C',4); C.preset('Course','C',e.profiles.C); E.changed(e); F.tick(e,f,1/60)
  e.startedAt=e.time; F.place(f,1,-5000,0)
  F.place(f,2,0,200); F.place(f,3,5+4.4,140); F.place(f,4,follower and -(8+4.4) or -3000,200)
  e.states[2].nextPerception=0
  local brake,lift=0,1
  for _=1,30 do F.tick(e,f,1/60); brake=math.max(brake,e.commands[2].brake); lift=math.min(lift,e.commands[2].throttleLimit or 1) end
  return brake,lift,e
 end
 local b1,l1,e1=scene(true)
 assert(b1==0 and l1<=K.radarStartLift+1e-9,'car close behind: throttle lift, no brake ('..b1..', '..l1..')')
 assert(e1.startLift>=1 and (e1.startRadar or 0)==0,'lift counted for the start summary, not as a radar braking')
 local b2=scene(false)
 assert(b2>0 and b2<=K.radarStartBrakeMax+1e-9,'nobody behind: light brake, capped ('..b2..')')
end
-- Défense (Monza, 15:50 : déport vers le joueur arrivé à gauche, +51 km/h, virage à droite, tour de sortie) : seulement
-- contre un suiveur nettement d'un côté, pas beaucoup plus rapide, en vraie ligne droite, hors tour de sortie et hors
-- garde des stands ; chaque défense au journal.
tests.DEFENSE_GUARDS_147=function()
 local function defended(lat,sa,setup,player)
  for lap=1,25 do
   local e,f=F.scene('C',3); e.p.personalLineJitter=0; E.changed(e); F.tick(e,f,1/60)
   local s=e.states[2]; s.persona.assertiveness=1
   for i=1,3 do f.cars[i].lap=lap end
   -- Suiveur : une IA (3), ou le joueur (1 ; une IA bien plus rapide appelle de phares, ce qui coupe déjà la défense).
   if player then F.place(f,3,-5000,100); F.place(f,2,0,150); F.place(f,1,-8-4.4,150+sa,lat)
   else F.place(f,1,-5000,100); F.place(f,2,0,150); F.place(f,3,-8-4.4,150+sa,lat) end
   s.nextPerception=0
   if setup then setup(e,f,s) end
   for _=1,60 do F.tick(e,f,1/60); if setup then setup(e,f,s) end; if s.state=='DEFEND' then return true,e end end
  end
  return false
 end
 local ok,e=defended(0.8,8)
 assert(ok,'clear lateral offset, small speed difference: defence possible')
 assert(count(e,'defense: Driver_2 couvre Driver_3')==1,'defence logged')
 assert(not defended(0.2,8),'attacker almost in line: no defence (side decided by a ~0 offset)')
 assert(defended(0.8,8,nil,true),'the player close behind, small speed difference: defence possible')
 -- Joueur 51 km/h plus rapide (Monza) : pas de défense (déjà par l'occupation latérale, qui compte 0,8 s d'écart de
 -- vitesse ; la borne de vitesse de la 1.47 la double).
 assert(not defended(0.8,51,nil,true),'the player 51 km/h faster (Monza), contact in 0.6 s: no defence')
 assert(not defended(0.8,8,function(e,f,s) e.strategy.cars[2].outLap=true end),'out-lap: no defence')
 assert(not defended(0.8,8,function(e,f,s) s.pitGuardUntil=e.time+5 end),'pit guard: no defence')
 assert(not defended(0.8,8,function(e,f,s) f.cars[2].yawRate=0.07 end),'gentle corner: no defence')
end
-- Garde de vitesse de la défense : suiveur IA nettement d'un côté, 30 km/h plus rapide, contact en une seconde : pas
-- de défense, même quand l'occupation latérale (neutralisée ici) ne la couperait pas ; 8 km/h : permise.
tests.DEFENSE_SPEED_GUARD_147=function()
 local function defended(sa)
  for lap=1,25 do
   local e,f=F.scene('C',3); e.p.personalLineJitter=0; E.changed(e); F.tick(e,f,1/60)
   e.g.occMargin=0; e.g.occSpeedGain=0
   local s=e.states[2]; s.persona.assertiveness=1
   for i=1,3 do f.cars[i].lap=lap end
   F.place(f,1,-5000,100); F.place(f,2,0,150); F.place(f,3,-8-4.4,150+sa,0.8)
   s.nextPerception=0
   for _=1,60 do F.tick(e,f,1/60); if s.state=='DEFEND' then return true end end
  end
  return false
 end
 assert(defended(8),'small speed difference: defence possible')
 assert(not defended(30),'30 km/h faster, contact in about 1 s: no defence')
end
-- Boucles (Spa 11:17-11:25 : 13 tentatives d'Agnese sur Kostka en 10 min) : paire ignorée après « cible plus rapide » :
-- plus de dépassement sur simple rapprochement sans vraie avance ici ; avec une vraie avance, permis.
tests.PASS_IGNORE_CLOSING_147=function()
 local function engaged(advantage)
  local e,f=F.scene('J',3); e.p.personalLineJitter=0; E.changed(e); F.tick(e,f,0.2)
  learned(e,2,2,(advantage and 260 or 200)/3.6); learned(e,3,3,200/3.6)
  local s=e.states[2]; s.passIgnore=3; s.passIgnoreUntil=e.time+100
  F.front(e,f,25,20)
  for _=1,4*60 do F.tick(e,f,1/60); if F.passing(s.state) then return true end end
  return false
 end
 assert(not engaged(false),'ignored pair, no real advantage: no pass on closing alone')
 assert(engaged(true),'ignored pair with a real advantage here: pass allowed')
end
-- Usure (relevée en jeu à 1 à 1,4 % par tour) : nouveau seuil par défaut 30 %, minimum 10 % ; migration : un profil
-- resté à 75 % passe à 30 %, une valeur réglée reste.
tests.TYRE_WEAR_THRESHOLD_147=function()
 local schema; for _,x in ipairs(C.schema) do if x.key=='strategyTyreWearPct' then schema=x end end
 assert(schema.min==10 and schema.defaults.C==30,'default 30 %, minimum 10 %')
 local function migrated(value)
  local set={}; for _,x in ipairs(C.profiles) do set[x]=C.validate(x,C.defaults(x)) end
  set.C.strategyTyreWearPct=value
  local g=C.validateGlobals(C.globalDefaults); g.dataRevision=19; g.presetsUsed=true
  C.migrate(g,set); assert(g.dataRevision==C.dataRevision)
  return set.C.strategyTyreWearPct
 end
 assert(migrated(75)==30,'old default moves to the new one')
 assert(migrated(50)==50,'a tuned value stays')
end
-- Undercut aussi sur l'arrêt obligatoire encore dû (fenêtre ouverte), plan de la stratégie à 0 arrêt.
tests.MANDATORY_UNDERCUT_147=function()
 local e,f=F.scene('C',4); local rp=e.profiles.C
 rp.strategyEnabled=true; rp.strategyUndercut=true; rp.mandatoryStops=1; rp.pitWindowOpenPct=0; rp.pitWindowClosePct=100; E.changed(e)
 f.sessionLaps=30; f.leaderLaps=10; f.timedRace=false; f.sessionMinutes=0; f.started=true
 for i=1,f.count do f.cars[i].lap=10 end
 e.strategy.wearTrust='trusted'
 F.place(f,1,-5000,100); F.place(f,2,0,200); F.place(f,3,20,200); F.place(f,4,5000,200)
 e.states[2].persona.strategyRisk=0.95
 for i=2,3 do local a=f.cars[i]; a.wearKnown=true; a.tyreWear={0.02,0.02,0.02,0.02}; a.tyreKm={5,5,5,5}; a.tyreTemp={90,90,90,90}; a.tyreOptimum={90,90,90,90}; a.fuel=100; a.maxFuel=110; a.fuelPerLap=1 end
 F.tick(e,f,0.2); e.states[2].persona.strategyRisk=0.95; F.tick(e,f,K.strategyRetry+0.5)
 -- Plan revu au tour suivant (fenêtre ouverte).
 for i=1,f.count do f.cars[i].lap=11 end; f.leaderLaps=11; F.tick(e,f,0.5)
 local c=e.strategy.cars[2]
 assert(e.pits.opened and e.pits.cars[2].windowStops==0,'mandatory stop still due, window open')
 assert(c.planned and c.stops==0,'no strategy stop of its own')
 assert(c.wanted and c.cause=='undercut' or c.reaction,'bold strategist undercuts on its mandatory stop')
end
-- Limites de piste : sortie juste après un contact (voiture poussée dehors) : aucun avertissement.
tests.TRACK_LIMITS_AFTER_CONTACT_147=function()
 local e,f=F.scene('C',4); F.tick(e,f,0.1)
 local function off(contact)
  if contact then f.cars[2].collidedWith=3; F.tick(e,f,1/60); f.cars[2].collidedWith=-1 end
  f.cars[2].wheelsOut=4; f.cars[2].offtrack=true; F.tick(e,f,0.5)
  f.cars[2].wheelsOut=0; f.cars[2].offtrack=false; F.tick(e,f,K.sanStrikeGap)
 end
 off(true)
 assert(count(e,'limites de piste IA: Driver_2 avertissement')==0,'pushed off by a contact: no warning')
 F.tick(e,f,K.sanContactGrace+1); off(false)
 assert(count(e,'limites de piste IA: Driver_2 avertissement')==1,'an ordinary exit still warned')
end
-- Sortie des stands : décalage remis à zéro, aucun retour depuis une valeur d'avant l'arrêt.
tests.PIT_EXIT_OFFSET_147=function()
 local e,f=F.scene('C',3); F.tick(e,f,0.1)
 local s=e.states[2]; s.offset=0.6; s.filtered=0.6; s.pitBefore=true
 F.tick(e,f,1/60)
 assert(s.offset==0 and not s.returning,'offset reset at the pit exit ('..s.offset..')')
end
-- Cession inutile hors course : suiveur qui ne se rapproche plus, oubliée au bout de K.followerStallTimeOff s.
tests.YIELD_STALL_PRACTICE_147=function()
 local function kept(profile)
  local e,f=F.scene(profile,3); e.p.personalLineJitter=0; F.tick(e,f,0.2)
  local s=e.states[2]
  F.place(f,2,0,150); F.place(f,3,-12-4.4,150)
  s.state='YIELD_HOLD'; s.target=3; s.targetSide=1; s.yieldOrdinary=true; s.yieldStart=e.time; s.holdUntil=e.time
  s.followers[3]=true; s.yieldDetection=80; s.yieldMargin=10; s.nextPerception=0
  F.tick(e,f,K.followerStallTimeOff+0.5)
  return s.followers[3]==true
 end
 assert(not kept('P'),'practice: unused yield given up sooner')
end
-- Journal : « carburant demande » seulement quand la demande change d'au moins K.fuelLogStep L.
tests.FUEL_LOG_STEP_147=function()
 require('tests/host').create(true); local e,f=F.scene('C'); local a=A.new(); assert(A.access(a))
 local lines=0; a.note=function(level,text) if text:find('carburant demande',1,true) then lines=lines+1 end end
 for _,cmd in ipairs(e.commands) do cmd.active=false; cmd.fuelTarget=-1; cmd.fuelSet=-1 end
 local car=f.cars[2]; car.fuel=30; car.inPitBox=false
 local cmd=e.commands[2]; cmd.fuelLaps=6
 for k,liters in ipairs({33,32,31,30,28}) do cmd.fuelTarget=liters; A.apply(a,f,e.commands,e.g,10+k) end
 assert(lines==2,'logged at 33 L and 28 L only ('..lines..')')
end
-- Options de CSP (Beta 1.47, demande du pilote : cases cochées dans Content Manager tant que l'app est installée et
-- active) : port imité (fichiers en mémoire, mémoire de la partie, état appliqué par CSP).
local function cspPort(files,applied)
 local p={ready=true,mem=nil,writes=0,applied=applied or {}}
 p.read=function() local t=files.gui; if t==nil then return '',false end return t,true end
 p.write=function(text) p.writes=p.writes+1; files.gui=text; return true end
 p.remove=function() p.writes=p.writes+1; files.gui=nil; return true end
 p.loadState=function() return files.state or '' end
 p.saveState=function(text) if text=='' then files.state=nil else files.state=text end return true end
 p.loadSession=function() return p.mem end
 p.saveSession=function(text) p.mem=text end
 p.loaded=function(key) return p.applied[key] end
 return p
end
local function cspGlobals() return {enabled=true,overlayMessages=true,overlayBlockMessages=true,cspHideMessages=true,cspHideFlags=true,cspMessagesLost=false} end
local CSP_ORIGINAL='[NEW_UI]\r\nUI_SCALE=1.05\r\n\r\n[HIDE]\r\nHIDE_RACE_FLAGS=0\r\n'
-- Premier lancement : les deux options cochées ; fermeture du jeu, déchargement de l'app, relance, plantage : laissées
-- cochées (rien de réécrit) ; interrupteurs coupés ensuite : fichier d'origine rendu à l'octet près.
tests.CSP_TICKED_FOR_GOOD_147=function()
 local G=require('src/cspgui')
 local files={gui=CSP_ORIGINAL}; local p=cspPort(files)
 local g,prof,w=cspGlobals(),{flagPanel=true},{}
 local c=G.new(); G.start(c,p); G.step(c,p,G.want(g,prof,false,w),0)
 local ticked='[NEW_UI]\r\nUI_SCALE=1.05\r\n\r\n[HIDE]\r\nHIDE_RACE_FLAGS=1\r\nHIDE_SYSTEM_MESSAGES=1\r\n'
 assert(files.gui==ticked and p.writes==1,'first launch: both ticked: '..tostring(files.gui))
 -- Fermeture du jeu (déchargement de l'app) : laissées cochées, valeurs d'origine gardées.
 G.release(c,p,5); assert(files.gui==ticked and files.state~=nil and p.writes==1,'game exit: left ticked')
 -- Partie suivante (ou après un plantage : même état) : CSP les a appliquées au lancement ; rien de réécrit.
 local q=cspPort(files,{HIDE_SYSTEM_MESSAGES=true,HIDE_RACE_FLAGS=true})
 local d=G.new(); G.start(d,q); assert(d.owned.HIDE_SYSTEM_MESSAGES==false and d.owned.HIDE_RACE_FLAGS=='0','originals resumed from the state file')
 G.step(d,q,G.want(g,prof,false,w),0); G.step(d,q,G.want(g,prof,false,w),1); assert(q.writes==0 and files.gui==ticked,'next launch: nothing rewritten')
 G.release(d,q,2); assert(files.gui==ticked and q.writes==0,'released again: still ticked')
 -- Interrupteurs coupés : chaque option rendue, puis le fichier d'origine à l'octet près.
 local r=G.new(); local s=cspPort(files,{HIDE_SYSTEM_MESSAGES=true,HIDE_RACE_FLAGS=true}); G.start(r,s); G.step(r,s,G.want(g,prof,false,w),0)
 g.cspHideMessages=false; G.step(r,s,G.want(g,prof,false,w),1)
 assert(files.gui=='[NEW_UI]\r\nUI_SCALE=1.05\r\n\r\n[HIDE]\r\nHIDE_RACE_FLAGS=1\r\n' and s.writes==1,'messages switch off: messages given back only')
 g.cspHideFlags=false; G.step(r,s,G.want(g,prof,false,w),2)
 assert(files.gui==CSP_ORIGINAL and files.state==nil and s.writes==2,'both switches off: original file byte for byte')
end
-- L'état suit les réglages de l'app : app coupée (bouton APP), panneau de drapeaux de l'app décoché, messages plus
-- repris par l'overlay, témoin des messages perdu : valeurs d'origine rendues ; panique : rien ne change ; option réglée
-- par le pilote : jamais touchée ; retour à une version d'avant la Beta 1.40 : rendues.
tests.CSP_FOLLOWS_SETTINGS_147=function()
 local G=require('src/cspgui')
 local function scene()
  local files={gui=CSP_ORIGINAL}; local p=cspPort(files); local g,prof,w=cspGlobals(),{flagPanel=true},{}
  local c=G.new(); G.start(c,p)
  local function step(now,panic) G.step(c,p,G.want(g,prof,panic,w),now) end
  step(0); assert(files.gui:find('HIDE_SYSTEM_MESSAGES=1',1,true) and files.gui:find('HIDE_RACE_FLAGS=1',1,true))
  return files,p,g,prof,step,c
 end
 local function has(files,key) return files.gui~=nil and files.gui:find(key..'=1',1,true)~=nil end
 assert(G.want(cspGlobals(),{flagPanel=true},true,{})==nil and G.want(cspGlobals(),nil,false,{})==nil,'panic or no profile: hold')
 -- Panique : ni rendu ni nouvelle écriture, dans un sens comme dans l'autre.
 local files,p,g,prof,step=scene()
 step(1,true); step(2,true); assert(has(files,'HIDE_SYSTEM_MESSAGES') and has(files,'HIDE_RACE_FLAGS') and p.writes==1,'panic: left as is')
 step(3,false); assert(p.writes==1,'panic over: nothing written')
 local f0={gui=CSP_ORIGINAL}; local p0=cspPort(f0); local c0=G.new(); G.start(c0,p0); G.step(c0,p0,G.want(cspGlobals(),{flagPanel=true},true,{}),0)
 assert(f0.gui==CSP_ORIGINAL and p0.writes==0,'panic at launch: nothing written')
 -- App coupée : valeurs d'origine ; rallumée : cochées.
 g.enabled=false; step(4); assert(files.gui==CSP_ORIGINAL,'app switched off: originals back')
 g.enabled=true; step(5); assert(has(files,'HIDE_SYSTEM_MESSAGES') and has(files,'HIDE_RACE_FLAGS'),'app on again: ticked')
 -- Panneau de drapeaux de l'app décoché dans le profil en cours : drapeaux d'AC rendus, messages gardés.
 prof.flagPanel=false; step(6)
 assert(not has(files,'HIDE_RACE_FLAGS') and files.gui:find('HIDE_RACE_FLAGS=0',1,true) and has(files,'HIDE_SYSTEM_MESSAGES'),'flag panel off: AC flags back')
 prof.flagPanel=true; step(7); assert(has(files,'HIDE_RACE_FLAGS'),'flag panel on: hidden again')
 -- Messages plus repris (ou plus masqués) par l'overlay : messages d'AC rendus, drapeaux gardés.
 g.overlayBlockMessages=false; step(8); assert(not has(files,'HIDE_SYSTEM_MESSAGES') and has(files,'HIDE_RACE_FLAGS'),'messages takeover off: AC messages back')
 g.overlayBlockMessages=true; g.overlayMessages=false; step(9); assert(not has(files,'HIDE_SYSTEM_MESSAGES'),'overlay messages off: AC messages back')
 g.overlayMessages=true; step(10); assert(has(files,'HIDE_SYSTEM_MESSAGES'))
 -- Témoin : messages perdus par l'overlay : option rendue.
 g.cspMessagesLost=true; step(11); assert(not has(files,'HIDE_SYSTEM_MESSAGES') and has(files,'HIDE_RACE_FLAGS'),'probe fallback: messages given back')
 -- Retour à une version d'avant la Beta 1.40 : rendues au déchargement.
 local f2,p2,_,_,_,c2=scene(); G.release(c2,p2,1,true); assert(f2.gui==CSP_ORIGINAL and f2.state==nil,'rollback: originals back')
 -- Option cochée par le pilote lui-même : jamais tenue, laissée telle quelle même panneau de drapeaux décoché.
 local f3={gui='[HIDE]\nHIDE_RACE_FLAGS=1\n'}; local p3=cspPort(f3); local g3,prof3,w3=cspGlobals(),{flagPanel=true},{}
 local c3=G.new(); G.start(c3,p3); G.step(c3,p3,G.want(g3,prof3,false,w3),0)
 assert(c3.owned.HIDE_RACE_FLAGS==nil and c3.owned.HIDE_SYSTEM_MESSAGES==false,'driver s own option never held')
 prof3.flagPanel=false; G.step(c3,p3,G.want(g3,prof3,false,w3),1); assert(f3.gui:find('HIDE_RACE_FLAGS=1',1,true),'driver s own option untouched')
end
return tests
