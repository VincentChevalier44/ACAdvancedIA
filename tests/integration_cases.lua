local H=require('tests/host')
local C=require('src/config')
local E=require('src/engine')
local L=require('src/lang')
local ffi=require('ffi')
return function(source)
 -- Filtre facultatif (mutations ciblées) : seuls les cas dont le nom contient INT_FILTER sont joués.
 local filter=rawget(_G,'INT_FILTER')
 local results={}; local function check(name,fn) if filter and not name:find(filter,1,true) then return end; fn()
 assert(not HUMANAI or HUMANAI.host.errors==0,name..' : erreur attrapée (arrêt, restitution, session, interface)'); results[#results+1]=name end
 local function main() script.HUMANAI__MAIN(); assert(not HUMANAI.engine.panic,'UI error') end
 local function click(label) HOST.clicked=label; main() end
 -- Commandes dessinées (Beta 1.9) : clic par identifiant stable ; le clic doit être consommé (commande affichée).
 local W=require('src/widgets')
 local function press(id) HOST.clicked='##aai_'..id; main(); assert(HOST.clicked=='','control not shown: '..id) end
 local function go(name) press('tab_'..name) end
 -- Beta 1.17 : la section Règles a son propre onglet.
 -- Beta 1.19 : arrêts aux stands et voiture de sécurité sous leur titre dans l'onglet Règles de course.
 local stopsKeys={mandatoryStops=true,pitWindowOpenPct=true,pitWindowClosePct=true,pitTyres=true,pitRepair=true,pitCompoundChange=true,minPitTime=true,maxStintMin=true,pitFuel=true,pitsClosed=true,pitMessage=true}
 local safetyKeys={safetyCarSpeedKmh=true,safetyCarEscalation=true}
 local function section(group,key)
  if group=='rules' then go('rules'); press('rules_view_'..(stopsKeys[key] and 'stops' or safetyKeys[key] and 'safety' or 'all'))
  else go('settings'); press('cat_'..group) end
 end
 local function lit(id) return W.frame().active[id]==true end
 local function drawn(id) return HOST.hits['##aai_'..id]~=nil end
 local function redraw() HOST.hits={}; HOST.hitOrder={}; HOST.drawnTexts={}; main() end
 local function drag(id,ratio) HOST.drags['##aai_'..id]=ratio; main() end
 local function drawnText(value) for _,t in ipairs(HOST.drawnTexts) do if t==value then return true end end return false end
 local function has(list,value) for _,x in ipairs(list) do if x==value then return true end end return false end
 local function pause(value) HOST.sim.isPaused=value; script.HUMANAI__MENU() end
 HOST=H.create(true); assert(loadstring(source))()
 check('première installation : Essais, Qualifications et Course comme « Règles de base » ; Journée circuit sans commande ni sonde',function()
  H.tick(HOST,5); local e=HUMANAI.engine
  assert(e.profile=='J' and HOST.calls==0 and HOST.accessCalls==0 and e.guard=='nosections','track day: zero command')
  for _,group in ipairs(C.sections) do assert(not C.on(e.profiles.J,group),'track day: '..group) end
  for _,profile in ipairs(C.ruleProfiles) do
   local p=e.profiles[profile]
   assert(p.configured and C.on(p,'rules') and C.on(p,'accidents') and C.ruleCategory(profile,p)=='base',profile)
  end
  assert(HUMANAI.host.firstInstall and e.g.dataRevision==C.dataRevision and HUMANAI.host.caps.probeIndex==0 and e.g.offsetSign==0)
 end)
 check('ouverture automatique au setup sans callback HUD ni fenêtre déjà visible',function()
  assert(not HOST.windowOpen.main)
  HOST.sim.isInMainMenu=true; local calls=HOST.calls
  script.update(1/60)
  assert(HOST.windowOpen.main and HUMANAI.host.menuVisible and HOST.calls==calls)
  redraw(); assert(#HOST.drawnTexts>0)
  HOST.sim.isInMainMenu=false; script.update(1/60); assert(not HOST.windowOpen.main)
  local e=HUMANAI.engine
  local before=e.time; script.update(1/60); assert(math.abs(e.time-before-1/60)<1e-9)
  assert(HOST.calls==calls)
 end)
 check('fenêtres accessibles uniquement dans les menus pause/setup',function()
  redraw(); assert(#HOST.drawnTexts==0 and not HOST.windowOpen.main)
  pause(true); assert(HOST.windowOpen.main); redraw(); assert(#HOST.drawnTexts>0)
  HOST.sim.isPaused=false; HOST.sim.isInMainMenu=true; script.HUMANAI__MENU(); assert(HUMANAI.host.menuVisible)
  HOST.sim.isInMainMenu=false; pause(true)
 end)
 check('boutons de profil, surbrillance et activations indépendantes',function()
  go('settings'); press('section_general'); assert(HUMANAI.engine.profiles.J.section_general)
  assert(HOST.storage['humanai:p:J:'].section_general and HOST.calls==0)
  -- Profil automatique : cliquer un profil l'affiche et le règle sans figer la détection (piège relevé en jeu).
  local before=HUMANAI.engine.profile
  press('profile_C'); main(); assert(HUMANAI.engine.g.autoProfile and HUMANAI.engine.profile==before and lit('profile_C') and not lit('profile_'..before))
  local was=HUMANAI.engine.profiles.C.section_general
  press('section_general'); assert(HUMANAI.engine.profiles.C.section_general==not was and HUMANAI.engine.g.autoProfile,'edits go to the displayed profile')
  press('section_general'); assert(HUMANAI.engine.profiles.C.section_general==was,'the switch of the list toggles too')
  -- Sans profil automatique, le clic choisit le profil utilisé.
  go('home'); press('auto'); press('profile_C'); main(); assert(HUMANAI.engine.profile=='C' and not HUMANAI.engine.g.autoProfile)
  assert(lit('profile_C') and HUMANAI.engine.profiles.C.section_general==was)
  press('profile_J'); assert(HUMANAI.engine.p.section_general)
 end)
 check('auto : journée circuit déclarée dans race.ini prioritaire, ancien choix manuel annulé',function()
  press('profile_C'); HOST.sim.raceSessionType=3; HOST.configType=1
  H.tick(HOST,1.1); press('auto'); assert(HUMANAI.engine.profile=='J')
  HOST.configType=nil; HOST.sim.raceSessionType=1; H.tick(HOST,1.1)
 end)
 check('activation réelle et masquage des contrôles par section',function()
  section('lateral'); redraw(); assert(not drawn('set_rampSpeed'))
  press('section_lateral'); redraw(); assert(drawn('set_rampSpeed'))
  assert(HUMANAI.engine.p.section_lateral)
  press('section_lateral'); assert(not HUMANAI.engine.p.section_lateral)
  press('cat_yield'); press('section_yield'); assert(HUMANAI.engine.p.section_yield)
 end)
 check('Beta 1.9 : fenêtre dessinée à toutes les largeurs, commandes dans la fenêtre, polices et découpes équilibrées',function()
  for _,width in ipairs({640,1000,1600}) do
   HOST.space={x=width,y=780}
   for _,name in ipairs({'home','settings','diagnostic'}) do
    go(name); redraw()
    for id,r in pairs(HOST.hits) do
     assert(r.x>=0 and r.x+r.w<=8+width+0.5,'control outside the window: '..id..' at '..width)
     if name~='settings' then assert(r.y+r.h<=34+780+0.5,'control below the window: '..id..' at '..width) end
    end
    assert(HOST.dwriteDepth==0 and HOST.clipDepth==0,'fonts and clips balanced')
   end
  end
  HOST.space={x=1000,y=780}; go('home')
 end)
 check('préréglage personnalisé nommé : sauvegarde, modification, chargement, surbrillance',function()
  go('home'); HOST.inputEdits['##aai_preset_name']='Mon circuit'; press('save_preset')
  assert(HUMANAI.host.presets[1].name=='Mon circuit')
  main(); assert(lit('custom_1'))
  HUMANAI.engine.p.levelPct=80; E.changed(HUMANAI.engine); main(); assert(not lit('custom_1'))
  press('custom_1'); assert(HUMANAI.engine.p.levelPct==95 and HUMANAI.engine.p.section_general)
  press('save_preset'); assert(HUMANAI.host.presets[1] and not HUMANAI.host.presets[2])
 end)
 check('préréglages intégrés : activation des sections recommandées, cases visibles et surbrillance',function()
  local e=HUMANAI.engine; assert(e.g.autoProfile and e.profile=='J')
  -- Profil automatique conservé : le préréglage règle son profil sans figer la détection.
  go('home'); press('builtin_Course'); main(); assert(e.g.autoProfile and e.profile=='J' and e.profiles.C.section_blue and e.profiles.C.section_overtake and not e.profiles.C.section_traffic)
  go('home'); assert(lit('profile_C') and e.profile=='J','the configured profile is displayed after loading a preset')
  press('auto'); press('profile_C'); go('home'); main(); assert(e.profile=='C' and not e.g.autoProfile and lit('builtin_Course'))
  assert(HUMANAI.engine.p.section_general and HUMANAI.engine.p.section_blue and HUMANAI.engine.p.section_overtake and not HUMANAI.engine.p.section_traffic)
  section('blue'); main(); assert(drawn('section_blue') and HUMANAI.engine.p.section_blue)
  go('home'); press('builtin_Nordschleife'); main(); assert(HUMANAI.engine.profile=='J' and HUMANAI.engine.p.section_yield and HUMANAI.engine.p.section_traffic and not HUMANAI.engine.p.section_blue)
  press('builtin_Endurance'); main(); assert(HUMANAI.engine.p.section_endurance and HUMANAI.engine.p.multiClass and lit('builtin_Endurance'))
  press('custom_1')
 end)
 check('persistance du programme et des sections après rechargement',function()
  assert(loadstring(source))(); main()
  assert(HUMANAI.host.presets[1].name=='Mon circuit' and HUMANAI.engine.profiles.J.section_yield)
  go('home'); main(); assert(lit('custom_1'))
 end)
 check('sonde native et calibration uniquement après activation',function()
  pause(false); H.tick(HOST,5); assert(HUMANAI.host.caps.native110 and HUMANAI.engine.g.offsetSign==1,'native='..tostring(HUMANAI.host.caps.native110)..' sign='..HUMANAI.engine.g.offsetSign..' profile='..HUMANAI.engine.profile..' guard='..HUMANAI.engine.guard..' gen='..tostring(HUMANAI.engine.p.section_general)..' state='..HUMANAI.engine.states[2].state..' active='..tostring(HUMANAI.engine.commands[2].active)..' calls='..HOST.calls..' probe='..HUMANAI.host.caps.probeIndex..' done='..tostring(HUMANAI.host.caps.probeDone))
 end)
 check('export des zones et diagnostic dans le menu',function()
  pause(true); go('diagnostic'); HOST.clip=''; press('export'); assert(HOST.clip:match('zones')); pause(false)
 end)
 check('alt-online : aucune commande',function()
  HOST.sim.isAltOnlineRace=true; local old=HOST.calls; H.tick(HOST,1); assert(HOST.calls==old and HUMANAI.engine.guard=='online'); HOST.sim.isAltOnlineRace=false
 end)
 check('replay : aucune commande ni écriture de récupération',function()
  HOST.sim.isReplayActive=true; local old,stores=HOST.calls,HOST.storeWrites; H.tick(HOST,1); assert(HOST.calls==old and HOST.storeWrites==stores); HOST.sim.isReplayActive=false
 end)
 check('pause : aucune commande physique',function()
  pause(true); local old=HOST.calls; H.tick(HOST,1); assert(HOST.calls==old); pause(false)
 end)
 check('désactivation générale et restauration stable',function()
  HUMANAI.engine.g.enabled=false; H.tick(HOST,0.5); local old=HOST.calls; H.tick(HOST,1); assert(HOST.calls==old)
  HUMANAI.engine.g.enabled=true; H.tick(HOST,0.5)
 end)
 check('stands exclus des écritures',function()
  HOST.cars[1].isInPit=true; H.tick(HOST,1); HOST.cars[1].isInPit=false; H.tick(HOST,4)
 end)
 check('week-end : profil manuel conservé, auto réactivé suit la session',function()
  HOST.sim.currentSessionIndex=1; HOST.sim.currentSessionTime=0; HOST.sim.raceSessionType=3
  for fn in pairs(HOST.sessions) do fn() end
  H.tick(HOST,1); assert(HUMANAI.engine.profile=='J')
  HUMANAI.engine.g.autoProfile=true; H.tick(HOST,1.1); assert(HUMANAI.engine.profile=='C')
  E.select(HUMANAI.engine,'J'); H.tick(HOST,1)
 end)
 check('espacement réel par limite douce et restitution après désactivation',function()
  local e=HUMANAI.engine
  for _,group in ipairs(C.sections) do e.p['section_'..group]=false end
  e.p.section_traffic=true; E.changed(e)
  for i=1,3 do HOST.cars[i].splinePosition=(i-1)*0.001; HOST.cars[i].position.z=(i-1)*10 end
  local limited=false
  for _=1,C.K.trafficCycle*60 do
   H.tick(HOST,1/60)
   if HOST.speedLimits[1] and HOST.speedLimits[1]<108 then limited=true; break end
  end
  assert(limited,'spacing episode never reached native limiter')
  e.p.section_traffic=false; E.changed(e); H.tick(HOST,1)
  assert(HOST.speedLimits[1]==C.K.unlimitedSpeed)
  local old=HOST.calls; H.tick(HOST,1); assert(HOST.calls==old)
 end)
 check('rechargement sans double abonnement et déchargement idempotent',function()
  assert(loadstring(source))(); H.tick(HOST,1)
  local count=0; for _ in pairs(HOST.sessions) do count=count+1 end; assert(count==1)
  count=0; for _ in pairs(HOST.releases) do count=count+1 end; assert(count==1)
  HUMANAI.release(); local old=HOST.calls; script.HUMANAI__UPDATE(1/60); HUMANAI.release(); assert(HOST.calls==old)
 end)
 check('plafond natif et grip soumis à la section globale explicite',function()
  HOST=H.create(false); assert(loadstring(source))()
  local e=HUMANAI.engine; e.profiles.J.section_general=true; E.changed(e); H.tick(HOST,5)
  assert(not HUMANAI.host.caps.native110 and HOST.extraGrip==0)
  e.g.useGripBoost=true; e.g.levelMode='grip'; e.p.levelPct=110; e.p.paceSpreadPct=0; e.p.paceDriftPct=0
  E.changed(e); H.tick(HOST,5); assert(HOST.extraGrip==0)
  e.p.section_globals=true; E.changed(e); H.tick(HOST,5); assert(math.abs(HOST.extraGrip-1.248)<0.002)
  e.p.section_globals=false; E.changed(e); H.tick(HOST,1); assert(math.abs(HOST.extraGrip-1.2)<1e-9)
 end)
 check('chaque paramètre : bornes, choix, cases et sauvegarde via la vraie interface',function()
  HUMANAI.release(); HOST=H.create(true); HOST.space={x=1000,y=3000}; assert(loadstring(source))(); pause(true)
  -- Profil manuel : chaque profil cliqué devient le profil utilisé, pour vérifier aussi les valeurs effectives.
  go('home'); press('auto')
  for _,profile in ipairs(C.profiles) do
   go('home'); press('profile_'..profile); go('settings')
   for _,s in ipairs(C.schema) do
    -- Réglage sans effet dans ce profil (pénalités en journée circuit, surcouche Endurance en essais et en
    -- qualifications) : commande masquée, explication affichée, valeur par défaut.
    if s.group=='rules' and (stopsKeys[s.key] or safetyKeys[s.key]) and profile~='C' then
     -- Beta 1.19 : arrêts aux stands et voiture de sécurité, réglages du profil Course seul (vérifiés avec lui).
    elseif C.hidden(profile,s.key) then
     HUMANAI.engine.p['section_'..s.group]=true; section(s.group,s.key); redraw()
     local note=C.penaltyKeys[s.key] and L.penaltiesTrackDay or C.spawnKeys[s.key] and (C.hidden(profile,'spawnMode') and L.spawnNotAvailable or L.floodNotAvailable) or L.enduranceNotAvailable; local shown=false
     for _,t in ipairs(HOST.drawnTexts) do if #t>15 and note:find(t,1,true)==1 then shown=true end end
     assert(shown and not drawn('set_'..s.key),profile..': '..s.key..' hidden')
     assert(C.validate(profile,HUMANAI.engine.p)[s.key]==s.defaults[profile],profile..': '..s.key..' back to its default')
    else
    C.validate(profile,C.defaults(profile),HUMANAI.engine.p)
    HUMANAI.engine.p['section_'..s.group]=true
    section(s.group,s.key)
    local values=s.choices or (s.min and {s.min,s.max} or {true,false})
    for _,value in ipairs(values) do
     local requested=C.validate(profile,HUMANAI.engine.p); requested[s.key]=value
     local expected=C.validate(profile,requested)[s.key]
     if s.choices then local guard=0; while HUMANAI.engine.p[s.key]~=expected and guard<#s.choices do press('set_'..s.key); guard=guard+1 end
     elseif s.min then drag('set_'..s.key,value==s.min and 0 or 1)
     elseif HUMANAI.engine.p[s.key]~=value then press('set_'..s.key) end
     main(); H.tick(HOST,1/60)
     assert(HUMANAI.engine.p[s.key]==expected,profile..':'..s.key..':'..tostring(value))
     assert(HOST.storage['humanai:p:'..profile..':'][s.key]==expected,'storage:'..s.key)
     if type(expected)=='boolean' then assert(HUMANAI.engine.run[s.key]==expected,'effective:'..s.key) end
     if s.choices then redraw(); assert(drawnText(L.choices[value]..'  ▸'),'preview:'..s.key) end
    end
    end
   end
  end
  -- Clic droit sur un réglage : valeur par défaut du profil affiché ; -/+ : un pas.
  go('home'); press('profile_J'); section('general'); local p=HUMANAI.engine.p
  p.section_general=true; p.levelPct=80; main(); local r=HOST.hits['##aai_set_levelPct']; HOST.mouse={x=r.x+1,y=r.y+1}; HOST.rightClick='##aai_set_levelPct'; main()
  assert(p.levelPct==C.defaults('J').levelPct,'right click restores the default'); HOST.mouse={x=-1e6,y=-1e6}
  press('set_levelPct_minus'); assert(math.abs(p.levelPct-(C.defaults('J').levelPct-0.5))<1e-9,'minus: one step')
  press('set_levelPct_plus'); assert(math.abs(p.levelPct-C.defaults('J').levelPct)<1e-9,'plus: one step')
  press('cat_yield'); if not HUMANAI.engine.p.section_yield then press('section_yield') end
  local guard=0; while HUMANAI.engine.p.yieldSide~='auto' and guard<3 do press('set_yieldSide'); guard=guard+1 end
  assert(HUMANAI.engine.p.yieldSide=='auto')
  assert(loadstring(source))(); main(); assert(HUMANAI.engine.profiles.J.yieldSide=='auto')
  HOST.space={x=1000,y=780}
 end)
 check('options globales : chaque choix et interrupteur rejoint le moteur et le stockage',function()
  go('home'); press('profile_J'); section('globals')
  if not HUMANAI.engine.p.section_globals then press('section_globals') end
  for index,value in ipairs(C.globalChoices.levelMode) do
   local guard=0; while HUMANAI.engine.g.levelMode~=value and guard<5 do press('global_levelMode'); guard=guard+1 end
   H.tick(HOST,1/60)
   assert(HUMANAI.engine.g.levelMode==value and HUMANAI.engine.runtimeG.levelMode==value)
   redraw(); assert(drawnText(L.levelModeLabels[index]..'  ▸'))
   assert(HOST.storage['humanai:g:'].levelMode==value)
  end
  for _,key in ipairs({'useGripBoost','useBrakeAssist','overrideAwareness','debugLog'}) do
   for _,value in ipairs({true,false}) do
    if HUMANAI.engine.g[key]~=value then press('global_'..key) end
    H.tick(HOST,1/60); assert(HUMANAI.engine.runtimeG[key]==value and HOST.storage['humanai:g:'][key]==value,key)
   end
  end
  for key in pairs(L.globalLabels) do
   for index,value in ipairs(C.globalBounds[key]) do
    drag('global_'..key,index==1 and 0 or 1); H.tick(HOST,1/60)
    assert(HUMANAI.engine.runtimeG[key]==value and HOST.storage['humanai:g:'][key]==value,key)
   end
  end
  local seed=HUMANAI.engine.g.seed; press('reroll'); H.tick(HOST,1/60)
  assert(HUMANAI.engine.runtimeG.seed~=seed and HOST.storage['humanai:g:'].seed==HUMANAI.engine.runtimeG.seed,'new personalities')
 end)
 check('suppression personnalisée persistante, réglages conservés et emplacement réutilisable',function()
  go('home'); HOST.inputEdits['##aai_preset_name']='Premier'; press('save_preset')
  HOST.inputEdits['##aai_preset_name']='Second'; press('save_preset')
  press('custom_1'); local level=HUMANAI.engine.p.levelPct
  press('custom_delete_1')
  assert(not HUMANAI.host.presets[1] and HOST.storage['humanai:custom:1:'].name=='')
  assert(HUMANAI.engine.g.loadedPreset=='' and HUMANAI.engine.p.levelPct==level)
  assert(loadstring(source))(); go('home')
  assert(not HUMANAI.host.presets[1] and HUMANAI.host.presets[2].name=='Second')
  HOST.inputEdits['##aai_preset_name']='Réutilisé'; press('save_preset')
  assert(HUMANAI.host.presets[1].name=='Réutilisé')
  press('custom_delete_2')
  assert(not HUMANAI.host.presets[2] and HUMANAI.engine.g.loadedPreset=='custom:Réutilisé')
  HOST.inputEdits['##aai_preset_name']=string.rep('A',64); press('save_preset')
  for _,width in ipairs({640,1000,1600}) do
   HOST.space={x=width,y=780}; redraw()
   for id,r in pairs(HOST.hits) do assert(r.x+r.w<=8+width+0.5,'long name kept inside: '..id) end
  end
  HOST.space={x=1000,y=780}
 end)
 check('météo : composé pluie aux stands, puis retour au sec après assèchement',function()
  HUMANAI.release(); HOST=H.create(true)
  HOST.tyreCatalog[1]={{short='S',name='Slick Soft'},{short='I',name='Intermediate'},{short='W',name='Full Wet'}}
  HOST.sim.rainWetness=1; HOST.sim.rainIntensity=1
  assert(loadstring(source))(); local e=HUMANAI.engine; e.profiles.J.section_weather=true; E.changed(e); H.tick(HOST,2)
  assert(HOST.rainHints[1]==true and HOST.pitRequests[1]==true and HOST.cars[1].compoundIndex==0)
  assert(HOST.grips[1]==nil,'real rain compound must not get fallback grip')
  HOST.cars[1].isInPit=true; HOST.cars[1].speedKmh=0; H.tick(HOST,2); assert(HOST.cars[1].compoundIndex==2)
  local A=require('src/applier'); A.dirty(HUMANAI.host,e.time); A.save(HUMANAI.host,e.g,e.profiles,e.time,false,true)
  HOST.cars[1].compoundIndex=0; HOST.cars[1].isAIUsingRainTyres=false
  assert(loadstring(source))(); H.tick(HOST,2)
  assert(HOST.cars[1].compoundIndex==2,'weather service blocked by pending driving restoration after reload in pits')
  HOST.sim.rainWetness=0; HOST.sim.rainIntensity=0; H.tick(HOST,17); assert(HOST.cars[1].compoundIndex==0 and HOST.rainHints[1]==false)
 end)
 check('météo : grip de secours borné, priorité native et récupération après rechargement',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.rainWetness=1; HOST.sim.rainIntensity=1
  assert(loadstring(source))(); local e=HUMANAI.engine; e.profiles.J.section_weather=true; E.changed(e); H.tick(HOST,2)
  assert(math.abs(HOST.grips[1]-1.38)<0.002)
  local A=require('src/applier'); A.checkpoint(HUMANAI.host,e.frame,true)
  local recovered=A.new(); assert(A.access(recovered)); A.recover(recovered,e.frame)
  assert(recovered.cars[2].rainHint==true and not recovered.cars[2].originalRain)
  A.restore(recovered,e.frame,false,e.time); assert(HOST.rainHints[1]==false and math.abs(HOST.grips[1]-1.2)<1e-9)
  HOST.cars[1].isAIUsingRainTyres=true; H.tick(HOST,1); assert(math.abs(HOST.grips[1]-1.2)<1e-9)
  e.profiles.J.section_weather=false; E.changed(e); H.tick(HOST,1); assert(not HUMANAI.host.cars[2].owned)
 end)
 check('1.4.0 : grille de départ, pneus adaptés à la météo avant le feu vert, gommes sèches réparties',function()
  for _,case in ipairs({{wet=0,start=2,expect='dry'},{wet=0,start=1,expect='dry'},{wet=0.3,start=0,expect=1},{wet=1,start=0,expect=2}}) do
   HUMANAI.release(); HOST=H.create(true)
   for i=1,3 do HOST.tyreCatalog[i]={{short='H',name='Hard'},{short='I',name='Intermediate'},{short='W',name='Full Wet'},{short='M',name='Medium'},{short='S',name='Soft'},{short='SS',name='Super Soft'}} end
   HOST.sim.rainWetness=case.wet; HOST.sim.rainIntensity=case.wet; HOST.sim.isSessionStarted=false; HOST.sim.timeToSessionStart=20000
   for i=1,3 do HOST.cars[i].speedKmh=0; HOST.cars[i].velocity={x=0,z=0}; HOST.cars[i].compoundIndex=case.start; HOST.cars[i].isAIUsingRainTyres=case.start==1 or case.start==2 end
   assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.g.autoProfile=false; e.g.manualProfile='C'; E.changed(e)
   H.tick(HOST,3)
   for i=1,3 do
    local index=HOST.cars[i].compoundIndex
    if case.expect=='dry' then assert(index==0 or index>=3,'dry compound fitted on the grid') else assert(index==case.expect,'rain compound fitted on the grid: '..index) end
    assert(not HOST.pitRequested[i],'no pit stop requested for a tyre choice made on the grid')
   end
  end
  -- 1.7.0 : IA apparue aux stands en intermédiaires sur piste sèche, qui repart aussitôt : gomme sèche montée dans
  -- la voie des stands, en roulant (relevé dans les journaux de la 1.5.1).
  HUMANAI.release(); HOST=H.create(true)
  HOST.tyreCatalog[1]={{short='H',name='Hard'},{short='I',name='Intermediate'},{short='S',name='Soft'}}
  HOST.cars[1].isInPitlane=true; HOST.cars[1].speedKmh=60; HOST.cars[1].compoundIndex=1
  assert(loadstring(source))(); local el=HUMANAI.engine; C.preset('Nordschleife','J',el.profiles.J); E.changed(el)
  H.tick(HOST,1)
  assert(HOST.cars[1].compoundIndex==0 or HOST.cars[1].compoundIndex==2,'dry compound fitted while rolling down the pit lane')
  -- 1.7.2 : pluie, IA en pneus pluie dans la voie des stands : aucun changement (plus de va-et-vient avec CSP).
  HUMANAI.release(); HOST=H.create(true)
  HOST.tyreCatalog[1]={{short='H',name='Hard'},{short='I',name='Intermediate'},{short='W',name='Wet'}}
  HOST.sim.rainWetness=0.4; HOST.sim.rainIntensity=0.2
  HOST.cars[1].isInPitlane=true; HOST.cars[1].speedKmh=60; HOST.cars[1].compoundIndex=2; HOST.cars[1].isAIUsingRainTyres=true
  assert(loadstring(source))(); local er=HUMANAI.engine; C.preset('Nordschleife','J',er.profiles.J); E.changed(er)
  H.tick(HOST,8)
  assert(HOST.cars[1].compoundIndex==2,'full wets kept in the rain')
  -- Journée circuit ou essais : session déjà lancée, voitures apparues à l'arrêt en pneus pluie au sec.
  HUMANAI.release(); HOST=H.create(true)
  HOST.tyreCatalog[1]={{short='H',name='Hard'},{short='W',name='Wet'},{short='S',name='Soft'}}
  HOST.sim.currentSessionTime=3000; HOST.cars[1].speedKmh=0; HOST.cars[1].velocity={x=0,z=0}; HOST.cars[1].compoundIndex=1; HOST.cars[1].isAIUsingRainTyres=true
  assert(loadstring(source))(); local ej=HUMANAI.engine; C.preset('Nordschleife','J',ej.profiles.J); E.changed(ej)
  H.tick(HOST,3)
  assert(HOST.cars[1].compoundIndex==0 or HOST.cars[1].compoundIndex==2,'dry compound fitted at the start of a track day')
  local lines={}; for n=0,ej.log.count-1 do local r=ej.log[(ej.log.head-n-1)%200+1]; lines[#lines+1]=r.message end
  local text=table.concat(lines,'\n')
  assert(text:find('meteo au lancement: sec',1,true) and text:find('pneus geres par l app: oui',1,true) and text:find('pneus adaptes a la meteo a l arret au depart: W -> ',1,true),'weather and tyre change logged')
  -- Onglet Météo décoché : le journal le dit, et l'app ne touche pas aux pneus.
  ej.profiles.J.section_weather=false; E.changed(ej); ej.weather.reported=''; H.tick(HOST,0.2)
  lines={}; for n=0,ej.log.count-1 do local r=ej.log[(ej.log.head-n-1)%200+1]; lines[#lines+1]=r.message end
  assert(table.concat(lines,'\n'):find('pneus geres par l app: non (onglet Meteo decoche)',1,true),'weather tab off logged')
  local J=require('src/journal'); assert(J.summary(ej):find('pneus IA : secs ',1,true),'tyre summary each minute')
  -- Gomme sèche déjà choisie par l'IA sur piste sèche : conservée sur la grille.
  HUMANAI.release(); HOST=H.create(true)
  HOST.tyreCatalog[1]={{short='H',name='Hard'},{short='M',name='Medium'},{short='W',name='Wet'}}
  HOST.sim.isSessionStarted=false; HOST.sim.timeToSessionStart=20000; HOST.cars[1].speedKmh=0; HOST.cars[1].velocity={x=0,z=0}; HOST.cars[1].compoundIndex=1
  assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.g.autoProfile=false; e.g.manualProfile='C'; E.changed(e)
  H.tick(HOST,3); assert(HOST.cars[1].compoundIndex==1,'native dry choice kept')
  local W=require('src/weather'); local seen={}
  for index=1,40 do seen[W.dryChoice({index=index,dryList={0,3,4,5}},19731019)]=true end
  assert(seen[0] and seen[3] and seen[4] and seen[5],'every dry compound can be chosen')
 end)
 check('météo au sec : conserve un autre composé sec choisi par l’IA',function()
  HUMANAI.release(); HOST=H.create(true)
  HOST.tyreCatalog[1]={{short='S',name='Slick Soft'},{short='H',name='Slick Hard'},{short='W',name='Wet'}}
  assert(loadstring(source))(); local e=HUMANAI.engine; e.profiles.J.section_weather=true; E.changed(e); H.tick(HOST,2)
  HOST.cars[1].compoundIndex=1; H.tick(HOST,2)
  assert(e.commands[2].weatherCompound==1 and HOST.pitRequests[1]~=true)
 end)
 check('veille sans lectures de voitures, reprise avec identités fraîches et arrêt restauré',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))()
  -- Veille : aucun onglet coché dans aucun profil (la première installation coche Essais, Qualifications et Course).
  local e=HUMANAI.engine; for _,p in pairs(e.profiles) do for _,group in ipairs(C.sections) do p['section_'..group]=false end end; E.changed(e); H.tick(HOST,2)
  assert(HOST.carReads==0 and HOST.calls==0)
  e.profiles.J.section_general=true; E.changed(e); H.tick(HOST,1/60)
  assert(HOST.carReads>=4 and e.frame.cars[2].identity~=nil and e.frame.cars[1].player)
  e.g.enabled=false; H.tick(HOST,2); HOST.carReads=0; local calls=HOST.calls; H.tick(HOST,1)
  assert(HOST.carReads==0 and HOST.calls==calls and math.abs(HOST.cars[1].aiLevel-0.9)<1e-6)
 end)
 check('gauche/droite : cession à droite = offset SDK positif, repère indirect et repère direct d’AC',function()
  for _,rightHanded in ipairs({false,true}) do
   HUMANAI.release(); HOST=H.create(true,{rightHanded=rightHanded}); assert(loadstring(source))()
   local e=HUMANAI.engine; local p=e.profiles.J
   p.section_general=true; p.section_yield=true; p.yieldSide='right'; E.changed(e); H.tick(HOST,5)
   local expected=rightHanded and -1 or 1
   assert(e.g.offsetSign==expected and e.g.sideSign==expected,'signs '..e.g.offsetSign..'/'..e.g.sideSign)
   HOST.cars[0].position.z=-45; HOST.cars[0].splinePosition=1-45/10000; HOST.cars[0].speedKmh=170
   local moved=0
   for _=1,6*60 do
    H.tick(HOST,1/60); local value=HOST.offsets[1] or 0
    assert(value>-0.02,'yield towards the SDK left'); moved=math.max(moved,value)
   end
   assert(moved>0.3,'no yield to the right: '..moved)
  end
 end)
 check('rechargement : valeurs d’origine conservées, réglages sauvegardés ou non',function()
  for _,saved in ipairs({true,false}) do
   HUMANAI.release(); HOST=H.create(false); assert(loadstring(source))()
   local e=HUMANAI.engine; local p=e.profiles.J
   p.section_general=true; p.levelPct=80; p.paceSpreadPct=0; E.changed(e); H.tick(HOST,3)
   assert(math.abs(HOST.cars[2].aiLevel-0.9)>0.05)
   HOST.cars[2].isInPitlane=true; H.tick(HOST,1)
   if saved then local A=require('src/applier'); A.dirty(HUMANAI.host,e.time); A.save(HUMANAI.host,e.g,e.profiles,e.time,false,true) end
   assert(loadstring(source))(); H.tick(HOST,1/60)
   local s=HUMANAI.host.cars[3]
   assert(s.owned and math.abs(s.originalLevel-0.9)<1e-6,'recovered original '..tostring(s.owned)..' '..s.originalLevel)
   HOST.cars[2].isInPitlane=false; HUMANAI.engine.profiles.J.section_general=false; E.changed(HUMANAI.engine); H.tick(HOST,2)
   assert(math.abs(HOST.cars[2].aiLevel-0.9)<1e-6,'level after restore '..HOST.cars[2].aiLevel)
  end
 end)
 check('déchargement en pause : niveaux et agressivités restitués',function()
  HUMANAI.release(); HOST=H.create(false); assert(loadstring(source))()
  local e=HUMANAI.engine; local p=e.profiles.J
  p.section_general=true; p.levelPct=70; p.aggressionPct=20; p.paceSpreadPct=0; E.changed(e); H.tick(HOST,3)
  assert(HOST.cars[1].aiLevel<0.8)
  pause(true); HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(math.abs(HOST.cars[1].aiLevel-0.9)<1e-6 and math.abs(HOST.cars[1].aiAggression-0.45)<1e-6,'not restored on release')
  pause(false)
 end)
 check('110 % : relecture fiable à la sortie des stands, écrêtage toujours détecté',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))()
  local e=HUMANAI.engine; local p=e.profiles.J
  HOST.cars[3].isInPitlane=true
  p.section_general=true; p.levelPct=105; p.paceSpreadPct=0; E.changed(e); H.tick(HOST,3)
  assert(HUMANAI.host.caps.native110 and HUMANAI.host.caps.levelMode=='native')
  HOST.cars[3].isInPitlane=false; H.tick(HOST,3)
  assert(HUMANAI.host.caps.native110 and HOST.cars[3].aiLevel>1.04,'false clamp after pit exit')
  HOST.clampLevel=true; p.levelPct=108; E.changed(e); H.tick(HOST,5)
  assert(not HUMANAI.host.caps.native110 and HUMANAI.host.caps.levelMode~='native','clamp not detected')
 end)
 check('stands météo : demande maintenue dans la voie, composé changé à l’arrêt, levée après la sortie',function()
  HUMANAI.release(); HOST=H.create(true)
  HOST.tyreCatalog[1]={{short='S',name='Slick Soft'},{short='I',name='Intermediate'},{short='W',name='Full Wet'}}
  HOST.sim.rainWetness=1; HOST.sim.rainIntensity=1
  assert(loadstring(source))(); local e=HUMANAI.engine; e.profiles.J.section_weather=true; E.changed(e); H.tick(HOST,2)
  assert(HOST.pitRequests[1]==true)
  HOST.cars[1].isInPitlane=true; H.tick(HOST,3); assert(HOST.pitRequests[1]==true,'request withdrawn in the pit lane')
  HOST.cars[1].isInPit=true; HOST.cars[1].speedKmh=0; H.tick(HOST,2)
  assert(HOST.cars[1].compoundIndex==2 and HOST.pitRequests[1]==true)
  HOST.cars[1].isInPit=false; HOST.cars[1].speedKmh=60; H.tick(HOST,2); assert(HOST.pitRequests[1]==true,'cancelled inside the pit lane')
  HOST.cars[1].isInPitlane=false; HOST.cars[1].speedKmh=108; H.tick(HOST,2); assert(HOST.pitRequests[1]==false)
 end)
 check('météo au sec : stratégie pluie native de CSP non forcée',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))()
  local e=HUMANAI.engine; e.profiles.J.section_weather=true; E.changed(e); H.tick(HOST,3)
  assert(e.commands[2].weatherManaged and HOST.rainHints[1]==nil,'native rain strategy overridden in the dry')
  HOST.sim.rainWetness=1; HOST.sim.rainIntensity=1; H.tick(HOST,17); assert(HOST.rainHints[1]==true)
 end)
 check('menu setup/garage : la session continue, le moteur aussi ; vraie pause figée',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))()
  local e=HUMANAI.engine; e.profiles.J.section_general=true; E.changed(e); H.tick(HOST,2)
  HOST.sim.isInMainMenu=true; local before,frames=e.time,e.frames; H.tick(HOST,2)
  assert(HUMANAI.host.menuVisible and HOST.windowOpen.main and e.time>before+1.9 and e.frames>frames and e.guard=='ready')
  HOST.sim.isPaused=true; before,frames=e.time,e.frames; local calls=HOST.calls; H.tick(HOST,1)
  assert(e.time==before and e.frames==frames and HOST.calls==calls and e.guard=='paused')
  HOST.sim.isPaused=false; HOST.sim.isInMainMenu=false; H.tick(HOST,1/60); assert(not HUMANAI.host.menuVisible)
 end)
 check('redémarrage de session au même indice : écritures resynchronisées',function()
  HUMANAI.release(); HOST=H.create(false); assert(loadstring(source))()
  local e=HUMANAI.engine; local p=e.profiles.J; p.section_general=true; p.levelPct=80; p.paceSpreadPct=0; E.changed(e); H.tick(HOST,3)
  local commanded=HOST.cars[1].aiLevel; assert(math.abs(commanded-0.9)>0.05)
  HOST.cars[1].aiLevel=0.9 -- niveau rétabli par le jeu au redémarrage
  for fn in pairs(HOST.sessions) do fn(0,true) end; H.tick(HOST,1)
  assert(math.abs(HOST.cars[1].aiLevel-commanded)<0.01,'level not rewritten after restart')
  assert(math.abs(HUMANAI.host.cars[2].originalLevel-0.9)<1e-6)
 end)
 check('week-end : essais, qualifications, course ; préréglage reconnu et appliqué une fois par profil',function()
  -- Installation existante jamais réglée (la première installation, elle, part comme « Règles de base »).
  HUMANAI.release(); HOST=H.create(true); HOST.storage['humanai:g:']={dataRevision=4}
  HOST.raceIni={SESSION_0={NAME='Practice',TYPE=1},SESSION_1={NAME='Qualifying',TYPE=2},SESSION_2={NAME='Race',TYPE=3}}
  assert(loadstring(source))(); pause(true)
  local e=HUMANAI.engine; H.tick(HOST,0.1); main(); assert(e.profile=='P' and not C.anySection(e.profiles.P),'existing install never configured stays neutral')
  -- Préréglages chargés en mode automatique : la détection reste active.
  go('home'); press('builtin_Nordschleife'); press('builtin_Course'); assert(e.g.autoProfile and e.profile=='P' and e.g.presetsUsed)
  assert(e.profiles.J.section_traffic and e.profiles.C.section_blue)
  H.tick(HOST,0.1); main()
  assert(e.profile=='P' and e.profiles.P.configured and e.profiles.P.section_yield and not e.profiles.P.section_traffic)
  main(); assert(lit('builtin_Essais'),'Essais not recognised in practice')
  assert(not e.profiles.Q.configured and not C.anySection(e.profiles.Q))
  local function nextSession(index,kind)
   HOST.sim.currentSessionIndex=index; HOST.sim.raceSessionType=kind
   for fn in pairs(HOST.sessions) do fn(index,false) end; H.tick(HOST,0.1); main()
  end
  nextSession(1,2)
  assert(e.profile=='Q' and e.profiles.Q.configured and e.profiles.Q.section_yield and not e.profiles.Q.section_blue)
  main(); assert(lit('builtin_Qualifications') and HOST.storage['humanai:p:Q:'].section_yield==true)
  nextSession(2,3); main(); assert(e.profile=='C' and lit('builtin_Course'))
  -- Un profil Qualifications vidé volontairement n'est jamais réappliqué.
  nextSession(1,2); for _,group in ipairs(C.sections) do e.profiles.Q['section_'..group]=false end; E.changed(e); H.tick(HOST,0.1)
  assert(e.profile=='Q' and not C.anySection(e.profiles.Q))
  nextSession(2,3); nextSession(1,2); assert(not C.anySection(e.profiles.Q))
  pause(false)
 end)
 check('installation existante jamais réglée : aucun préréglage automatique sans préréglage déjà chargé',function()
  HUMANAI.release(); HOST=H.create(true); HOST.storage['humanai:g:']={dataRevision=4}; HOST.raceIni={SESSION_0={NAME='Qualifying',TYPE=2}}; assert(loadstring(source))(); H.tick(HOST,2)
  local e=HUMANAI.engine; assert(e.profile=='Q' and not e.g.presetsUsed and not C.anySection(e.profiles.Q) and HOST.calls==0)
 end)
 check('migration 1.2.0 : profil intact mis à jour, profil retouché conservé, sauvegarde',function()
  local legacy=require('tests/legacy_presets')
  HUMANAI.release(); HOST=H.create(true)
  local function stored(key) local t={}; for k,v in pairs(legacy[key]) do t[k]=v end; return t end
  HOST.storage['humanai:p:C:']=stored('Course:C')
  local touched=stored('Qualifications:Q'); touched.levelPct=99; HOST.storage['humanai:p:Q:']=touched
  HOST.storage['humanai:g:']={schemaVersion=3,enabled=true,autoProfile=true,manualProfile='J',presetsUsed=true,loadedPreset='builtin:Course',loadedPresetProfile='C'}
  assert(loadstring(source))(); H.tick(HOST,2)
  local e=HUMANAI.engine
  assert(e.profiles.C.section_accidents and e.profiles.C.section_rules and e.profiles.C.overtakeSide=='auto' and e.profiles.C.multiClass and e.g.dataRevision==C.dataRevision)
  assert(e.profiles.Q.levelPct==99 and e.profiles.Q.section_accidents and not e.profiles.Q.yellowEnabled and not e.profiles.Q.section_rules)
  assert(rawget(HOST.storage['humanai:g:'],'dataRevision')==C.dataRevision and rawget(HOST.storage['humanai:p:C:'],'section_accidents')==true,'migration saved')
  assert(HUMANAI.host.upgraded[1]=='C:Course')
  pause(true); go('settings'); assert(drawn('cat_accidents')); go('rules'); assert(drawn('section_rules')); pause(false)
 end)
 check('accident en jeu : zone jaune à 50 km/h, drapeau et message au joueur, IA accidentée retenue, tout rendu',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Nordschleife','J',e.profiles.J); E.changed(e)
  HOST.cars[0].splinePosition=0.995
  HOST.cars[3].speedKmh=0; HOST.cars[3].velocity={x=0,z=0}
  H.tick(HOST,8)
  assert(e.incidents.cars[4].incident,'stopped AI is an incident')
  -- Allure encore inconnue : vitesse de repli du double jaune, moins la marge propre au pilote.
  assert(HOST.speedLimits[1]<=50+1e-6 and HOST.speedLimits[1]>=50*(1-C.K.aiDeltaMarginMax)-1e-6,'zone fallback speed written: '..tostring(HOST.speedLimits[1]))
  -- 1.5.0 : panneau de drapeaux seul par défaut, drapeau natif laissé à AC ; drapeau natif sur demande.
  -- IA arrêtée en piste : double drapeau jaune.
  assert(HOST.flag==0 and (e.panel.title==L.flagTitles.yellow2 or e.panel.title==L.flagTitles.zone) and e.panel.double and #HOST.messages>=1 and HOST.messages[1]:find(L.messages.yellow[1],1,true),'player warned by the panel')
  e.profiles.J.yellowHud=true; E.changed(e); H.tick(HOST,0.5); assert(HOST.flag==C.K.flagCaution,'native yellow flag on request')
  -- Beta 1.7 : retenue hors piste seulement (jamais immobilisée sur la trajectoire).
  HOST.cars[2].collidedWith=3; HOST.cars[2].wheelsOutside=4; HOST.cars[2].speedKmh=5; HOST.cars[2].velocity={x=0,z=1.4}; H.tick(HOST,1)
  assert(HOST.stops[2]==C.K.stopPulse,'crashed AI held off the track')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(HOST.flag==0 and HOST.stops[2]==0 and HOST.speedLimits[1]==C.K.unlimitedSpeed,'everything handed back')
 end)
 check('course avec arrêt obligatoire : demandes écrites, pneus à l’emplacement, levée à la sortie, mémorisé, rendu',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; HOST.session={laps=20,durationMinutes=0,isTimedRace=false}
  assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.mandatoryStops=1; E.changed(e)
  HOST.sim.leaderLapCount=4; H.tick(HOST,3); assert(e.profile=='C' and e.pits.state=='pending' and not HOST.pitRequests[1])
  HOST.sim.leaderLapCount=14; H.tick(HOST,3)
  assert(HOST.pitRequests[1]==true and HOST.pitRequests[2]==true and HOST.pitRequests[3]==true,'stops requested in the window')
  assert(#HOST.messages>=1 and HOST.messages[#HOST.messages]:find(L.messages.pitOpen[1],1,true),'player told the window is open')
  local car=HOST.cars[1]; car.isInPitlane=true; car.isInPit=true; car.speedKmh=0; car.velocity={x=0,z=0}; H.tick(HOST,2)
  assert(HUMANAI.host.cars[2].tyreVisit==1 and e.pits.cars[2].stops==1,'fresh tyres at the stop')
  car.isInPit=false; car.isInPitlane=false; car.speedKmh=108; car.velocity={x=0,z=30}; H.tick(HOST,3)
  assert(HOST.pitRequests[1]==false and HOST.pitRequests[2]==true,'request lifted after the stop only')
  assert(HOST.values['humanai:pits'] and HOST.values['humanai:pits']:find(',1',1,true),'stop remembered for a reload')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(HOST.pitRequests[2]==false and HOST.pitRequests[3]==false,'requests handed back on unload')
 end)
 check('voiture de sécurité : garée aux stands au départ, panneau de choix, rendue au déchargement',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.neutralization='sc'; e.g.safetyCarModel='model_3'; E.changed(e)
  H.tick(HOST,2)
  assert(e.incidents.safety==4 and HOST.teleports==1 and HOST.parked[3]==true,'safety car parked')
  pause(true); section('rules'); main(); assert(not HUMANAI.engine.panic); pause(false)
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(HOST.parked[3]==false,'handed back')
 end)
 check('journal de session sur disque : rotation, en-tête, session, incident, résumé, fin ; coupé si désactivé',function()
  HUMANAI.release(); HOST=H.create(true); HOST.files['logs/ACAdvancedIA.log']='ancien lancement\n'
  assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Nordschleife','J',e.profiles.J); E.changed(e)
  HOST.cars[3].speedKmh=0; HOST.cars[3].velocity={x=0,z=0}
  H.tick(HOST,8)
  local text=HOST.files['logs/ACAdvancedIA.log']
  assert(HOST.files['logs/ACAdvancedIA.1.log']=='ancien lancement\n','previous launch kept')
  assert(text:find('=== ACAdvancedIA '..C.release..' : lancement ',1,true),'header with version')
  assert(text:find('session: indice 0',1,true) and text:find('profil: J (automatique)',1,true),'session and profile')
  assert(text:find('incident: arret, en piste',1,true) and text:find('resume: profil J',1,true),'incident and summary')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(HOST.files['logs/ACAdvancedIA.log']:find('=== fin : ',1,true),'end line on unload')
  -- Rechargement de l'app dans le même lancement du jeu : même fichier poursuivi, pas de rotation.
  local before=HOST.files['logs/ACAdvancedIA.log']; assert(loadstring(source))(); H.tick(HOST,1)
  assert(HOST.files['logs/ACAdvancedIA.1.log']=='ancien lancement\n' and HOST.files['logs/ACAdvancedIA.log']:sub(1,#before)==before,'reload: same journal continued')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  HOST=H.create(true); assert(loadstring(source))(); HUMANAI.engine.g.journal=false; HUMANAI.host.journalTried=nil
  H.tick(HOST,3); assert(next(HOST.files)==nil,'nothing written when disabled')
  HUMANAI.release()
 end)
 check('modes Content Manager : journée circuit, essai seul et course seule détectés',function()
  local cases={{{NAME='Track Day',TYPE=1},'J'},{{NAME='Track Day',TYPE=2},'J'},{{NAME='Qualifying',TYPE=2},'Q'},{{NAME='Practice',TYPE=1},'P'},{{NAME='Quick Race',TYPE=3},'C'}}
  for _,case in ipairs(cases) do
   HUMANAI.release(); HOST=H.create(true); HOST.raceIni={SESSION_0=case[1]}; assert(loadstring(source))(); H.tick(HOST,0.1)
   assert(HUMANAI.engine.profile==case[2],case[1].NAME..' -> '..HUMANAI.engine.profile)
  end
 end)
 -- Beta 1.16 : parcours joué dans les deux langues (anglais à la première installation, puis français au clic).
 local function tooltipWalk(code)
  HUMANAI.release(); HOST=H.create(true); HOST.space={x=1000,y=3000}; assert(loadstring(source))(); H.tick(HOST,0.5); pause(true)
  if code=='fr' then press('lang_fr') end
  assert(require('src/locale').current==code and HUMANAI.engine.g.language==code,'interface language: '..code)
  local e=HUMANAI.engine
  for _,profile in ipairs(C.profiles) do C.preset(({J='Nordschleife',P='Essais',Q='Qualifications',C='Course'})[profile],profile,e.profiles[profile]) end
  e.profiles.C.neutralization='sc'; e.profiles.C.mandatoryStops=1; e.profiles.C.section_globals=true; e.profiles.J.section_globals=true
  -- Souris placée sur chaque commande dessinée de l'image : une infobulle doit s'afficher.
  local function covered(where)
   redraw(); local ids={}; for k,id in ipairs(HOST.hitOrder) do ids[k]=id end
   for _,id in ipairs(ids) do
    local r=HOST.hits[id]; HOST.mouse={x=r.x+r.w/2,y=r.y+r.h/2}; HOST.lastTooltip=nil; main()
    assert(HOST.lastTooltip,'tooltip missing: '..id..' ('..where..')')
   end
   HOST.mouse={x=-1e6,y=-1e6}
  end
  HOST.tooltips={}
  for _,profile in ipairs(C.profiles) do
   go('home'); press('profile_'..profile)
   for _,name in ipairs({'home','diagnostic'}) do go(name); covered(profile..'/'..name) end
   go('settings')
   local listed={}; for _,group in ipairs(C.sections) do if group~='rules' then listed[#listed+1]=group end end
   listed[#listed+1]='overlay'
   for _,group in ipairs(listed) do
    press('cat_'..group); covered(profile..'/'..group)
    assert(lit('cat_'..group),'selected section highlighted: '..group)
    for _,other in ipairs(C.sections) do if other~=group then assert(not lit('cat_'..other),'only one section highlighted') end end
    if group=='general' then
     local specific=false; for _,tip in ipairs(HOST.tooltips) do if tip:find('Content%sManager') then specific=true end end
     assert(specific,'setting tooltips are specific, not generic')
    end
    if group=='endurance' then press('pattern_rows'); covered(profile..'/patterns'); press('pattern_rows') end
   end
   go('rules'); covered(profile..'/rules')
   press('rules_view_stops'); covered(profile..'/rules stops'); press('rules_view_safety'); covered(profile..'/rules safety'); press('rules_view_all')
   e.profiles[profile].section_rules=false; main(); covered(profile..'/rules unticked')
   assert(drawn('rules_F1'),'rule buttons shown and explained with the tab unticked')
  end
  -- Onglet Diagnostic : souris sur chaque commande, une infobulle à chaque fois ; copie des zones, filtre du journal.
  go('diagnostic'); redraw(); local diagIds={}; for k,id in ipairs(HOST.hitOrder) do diagIds[k]=id end
  assert(#diagIds>=12,'diagnostic controls drawn')
  for _,id in ipairs(diagIds) do local r=HOST.hits[id]; HOST.mouse={x=r.x+r.w/2,y=r.y+r.h/2}; HOST.lastTooltip=nil; main(); assert(HOST.lastTooltip,'diagnostic tooltip missing: '..id) end
  HOST.mouse={x=-1e6,y=-1e6}
  HOST.clip=''; press('export'); assert(HOST.clip:match('zones'),'zones copied')
  press('log_filter'); redraw()
  assert(drawnText(L.filterShort..' '..L.logLevels[2]),'log filter cycled')
  HOST.hoverAll=true
  assert(HOST.styleDepth==0 and HOST.dwriteDepth==0 and HOST.clipDepth==0)
  for _,text in ipairs(HOST.tooltips) do for line in (text..'\n'):gmatch('(.-)\n') do assert(#line<=C.K.uiTipWidth+24,'tooltip line too long: '..line) end end
  HOST.hoverAll=false; HOST.space={x=1000,y=780}; pause(false)
 end
 check('1.4.0 : une infobulle après chaque commande, tous profils et onglets, onglet choisi en surbrillance',function() tooltipWalk('en') end)
 check('Beta 1.16 : une infobulle après chaque commande en français, tous profils et onglets',function() tooltipWalk('fr') end)
 check('1.5.0 : drapeau rouge en course, panneau de drapeaux, IA aux stands, dépannage, reprise, tout rendu',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; HOST.sim.carsCount=4
  assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.redFlagCars=2; e.profiles.C.redFlagHold=20; E.changed(e)
  H.tick(HOST,8)
  for _,i in ipairs({2,3}) do HOST.cars[i].speedKmh=0; HOST.cars[i].velocity={x=0,z=0} end
  H.tick(HOST,7)
  assert(e.incidents.red and HOST.pitRequests[1]==true,'red flag: AI called to the pits')
  HOST.transparent={}; script.HUMANAI__HUD(); assert(e.panel.kind=='red' and HOST.transparent.ACAdvancedIA_overlay,'overlay drawn on the red flag')
  HOST.draws=0; HOST.panelTexts={}; HOST.textTop=nil; HOST.circles=0; script.HUMANAI__FLAGS()
  assert(HOST.draws>=2 and HOST.fontDepth==0 and HOST.styleDepth==0 and has(HOST.panelTexts,L.flagTitles.red),'red flag drawn')
  assert(has(HOST.panelTexts,L.deltaLabel) and has(HOST.panelTexts,L.pitPill) and e.delta.kind=='red','red flag: delta box to the pits and PIT pill')
  assert(has(HOST.panelTexts,string.format(L.panelVersion,C.release)),'version at the top of the flags panel')
  assert(HOST.textTop>=34,'text placed under the CSP title bar, never behind it')
  -- Fenêtre basse : titre en police normale, toujours sous la barre de titre ; police toujours rendue.
  HOST.windowHeight=110; HOST.textTop=nil; script.HUMANAI__FLAGS(); assert(HOST.textTop>=34 and HOST.fontDepth==0); HOST.windowHeight=nil
  HOST.panelTexts={}; script.HUMANAI__FLAGS(); assert(has(HOST.panelTexts,e.panel.short) and e.panel.short~='','one-line instruction drawn')
  local noPass; for k,text in ipairs(HOST.panelTexts) do if text==L.noPassing then noPass=HOST.panelColors[k] end end
  assert(noPass and noPass.g>0.9 and noPass.r<0.5,'no overtaking line drawn in green')
  -- Temps delta en direct : positif en vert, négatif en rouge (valeur signée, virgule décimale).
  local function deltaShown(value)
   e.delta.course.delta=value; H.tick(HOST,1/60); HOST.panelTexts={}; HOST.panelColors={}; script.HUMANAI__FLAGS()
   for k,text in ipairs(HOST.panelTexts) do if text:match('^[%+%-]%d+[,%.]%d%d$') then return text,HOST.panelColors[k] end end
  end
  local text,color=deltaShown(0.8)
  assert(text and text:sub(1,1)=='+' and color.g>0.9 and color.r<0.5,'positive delta in green: '..tostring(text))
  text,color=deltaShown(-0.5)
  assert(text and text:sub(1,1)=='-' and color.r>0.9 and color.g<0.5,'negative delta in red: '..tostring(text))
  -- Valeur arrondie à zéro : « +0,00 » en vert (le signe lu est celui du centième affiché).
  e.delta.value=-0.003; HOST.panelTexts={}; HOST.panelColors={}; script.HUMANAI__FLAGS()
  local zero; for k,shown in ipairs(HOST.panelTexts) do if shown=='+0'..L.decimalMark..'00' then zero=HOST.panelColors[k] end end
  assert(zero and zero.g>0.9 and zero.r<0.5,'rounded to zero: shown green')
  e.delta.course.delta=2
  HOST.cars[0].speedKmh=108
  H.tick(HOST,3); assert(HOST.teleports>=2,'immobilised AI recovered to their pits')
  for i=1,3 do HOST.cars[i].isInPit=true; HOST.cars[i].isInPitlane=true; HOST.cars[i].speedKmh=0; HOST.cars[i].velocity={x=0,z=0} end
  H.tick(HOST,30); assert(e.incidents.red,'restart waits for the player in the pit lane')
  HOST.cars[0].isInPitlane=true; HOST.cars[0].speedKmh=60
  for _=1,80 do if not e.incidents.red then break end; H.tick(HOST,0.5) end
  H.tick(HOST,0.3) -- panneau rafraîchi tous les quarts de seconde
  assert(not e.incidents.red and e.incidents.relaunch and e.panel.kind=='fcy','relaunch lap under FCY (no safety car) after the hold')
  assert(HOST.messages[#HOST.messages]:find(L.messages.redRestartFcy[2],1,true),'relaunch announced')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(HOST.flag==0,'native flag untouched')
 end)
 check('1.6.0 : arrêts obligatoires mémorisés appliqués après un rechargement, oubliés au redémarrage de la session',function()
  local function rules() local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.mandatoryStops=1; E.changed(e) end
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  assert(loadstring(source))(); rules(); H.tick(HOST,2)
  local id=HUMANAI.engine.pits.cars[2].identity; assert(id and id:match('^[%w_%-]+$'),'serializable identity: '..tostring(id))
  HUMANAI.release(); HOST.values['humanai:pits']='0\n'..id..',1'
  assert(loadstring(source))(); rules(); H.tick(HOST,0.5)
  assert(HUMANAI.engine.pits.cars[2].windowStops==1,'stop kept across a reload')
  for fn in pairs(HOST.sessions) do fn() end; H.tick(HOST,0.5)
  assert(HUMANAI.engine.pits.cars[2].windowStops==0,'restart of the session: stops forgotten')
  -- Disqualification d'une IA conservée à travers un rechargement : elle reste garée.
  local e=HUMANAI.engine; e.penalties.ai.count[2]=6; e.penalties.ai.dq[2]=true; e.penalties.dirty=true; H.tick(HOST,C.K.saveDelay+0.5)
  assert(HOST.values['humanai:penalties'] and HOST.values['humanai:penalties']:find('2,6,1,',1,true),'sanction saved: '..tostring(HOST.values['humanai:penalties']))
  HUMANAI.release(); assert(loadstring(source))(); rules(); H.tick(HOST,0.5)
  assert(HUMANAI.engine.penalties.ai.dq[2] and HUMANAI.engine.commands[2].scPark and HUMANAI.engine.states[2].disqualified,'disqualified AI still parked after a reload')
  -- Joueur disqualifié : drapeau noir levé au déchargement, de nouveau imposé après le rechargement ; levé au redémarrage.
  local pe=HUMANAI.engine.penalties; pe.count=6; pe.disqualified=true; pe.kind='dq'; pe.requestId=pe.requestId+1; pe.dirty=true; H.tick(HOST,C.K.saveDelay+0.5)
  assert(HUMANAI.host.blackFlag,'black flag applied')
  local releases=HOST.blackFlagReleases or 0; HUMANAI.release(); assert((HOST.blackFlagReleases or 0)==releases+1,'lifted on unload')
  assert(loadstring(source))(); rules(); H.tick(HOST,0.5)
  assert(HUMANAI.engine.penalties.disqualified and HUMANAI.host.blackFlag,'black flag imposed again after the reload')
  for fn in pairs(HOST.sessions) do fn() end; H.tick(HOST,0.5)
  assert(not HUMANAI.host.blackFlag and (HOST.blackFlagReleases or 0)==releases+2,'lifted for the new session')
 end)
 check('1.8.0 : décocher le profil automatique garde le profil en cours',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))(); H.tick(HOST,0.5)
  assert(HUMANAI.engine.profile=='C' and HUMANAI.engine.g.autoProfile)
  pause(true); go('home'); press('auto'); pause(false); H.tick(HOST,0.5)
  assert(not HUMANAI.engine.g.autoProfile and HUMANAI.engine.profile=='C','manual profile = the current one ('..HUMANAI.engine.profile..')')
 end)
 check('Beta 1.3 : voiture de sécurité habillée de sa livrée quand le tirage au sort ne la lui a pas donnée',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; HOST.skins={[2]='1white'}; HOST.skinFolders={model_2={'1white','2black','Safety_Car'}}
  assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.g.safetyCarModel='model_2'; E.changed(e); H.tick(HOST,2)
  assert(e.incidents.safety==3 and HOST.appliedSkins and HOST.appliedSkins['carRoot:2']=='cars/model_2/skins/Safety_Car','safety car dressed in the Safety_Car livery')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  -- Livrée déjà portée : rien n'est appliqué.
  HOST=H.create(true); HOST.sim.raceSessionType=3; HOST.skins={[2]='Safety_Car'}; HOST.skinFolders={model_2={'Safety_Car'}}
  assert(loadstring(source))(); e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.g.safetyCarModel='model_2'; E.changed(e); H.tick(HOST,2)
  assert(e.incidents.safety==3 and not HOST.appliedSkins,'already in its livery: nothing applied')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.2 : erreurs de pilotage des IA écrites une fois par les fonctions natives',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))()
  -- Décisions injectées (le tirage est testé à part) : IA commandée, après l'attente et la détente du départ.
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.mistakesEnabled=false; E.changed(e); H.tick(HOST,30)
  local cmd=e.commands[2]; assert(cmd.active,'AI managed by the app') cmd.mistakeId=cmd.mistakeId+1; cmd.mistakeKind='brake'; cmd.mistakeTime=0.6; H.tick(HOST,1)
  assert(#HOST.mistakes==1 and HOST.mistakes[1].kind=='brake' and HOST.mistakes[1].index==1 and HOST.mistakes[1].time==0.6,'brake lock written once')
  cmd.mistakeId=cmd.mistakeId+1; cmd.mistakeKind='traction'; cmd.mistakeTime=0.4; cmd.mistakeSeverity=1.4; H.tick(HOST,1)
  assert(#HOST.mistakes==2 and HOST.mistakes[2].kind=='traction' and HOST.mistakes[2].severity==1.4,'wheelspin written with its severity')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.2 : DRS coupé par les règles pour toutes les voitures, rendu, bip delta joué par un seul événement',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  for i=0,3 do HOST.cars[i].drsPresent=true end
  assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); E.changed(e)
  -- Départ réel : session pas encore lancée au premier passage de l'app.
  HOST.sim.isSessionStarted=false; H.tick(HOST,0.5); HOST.sim.isSessionStarted=true; HOST.sim.leaderLapCount=1; H.tick(HOST,1)
  assert(HOST.drsBlocks[0]==true and HOST.drsBlocks[1]==true and HOST.drsBlocks[3]==true,'start: DRS off for the player and the AI, even if the game counter shows a lap')
  -- Le leader boucle un tour (l'hôte ne déplace pas les voitures) : DRS rendu.
  for _=1,110 do HOST.cars[1].splinePosition=(HOST.cars[1].splinePosition+0.01)%1; H.tick(HOST,1/60) end
  assert(HOST.drsBlocks[0]==false and HOST.drsBlocks[2]==false,'after one measured lap: handed back')
  e.drsRule.restart=true; H.tick(HOST,0.5); assert(HOST.drsBlocks[0]==true,'restart: off again')
  -- DRS des IA : ouvert dans la zone par la fonction native.
  e.profiles.C.rulesDrsLaps=0; E.changed(e); HOST.cars[2].drsAvailable=true; H.tick(HOST,0.5)
  assert(HOST.drsOpen[2]==true,'AI DRS opened in the zone')
  -- Freinage : refermé aussitôt, sans attendre le délai d'une seconde entre deux ouvertures.
  HOST.cars[2].drsActive=true; HOST.cars[2].brake=1; H.tick(HOST,0.2); assert(HOST.drsOpen[2]==false,'closed at once under braking')
  HOST.cars[2].brake=0; HOST.cars[2].drsActive=false
  e.profiles.C.rulesDrsLaps=1; E.changed(e); e.drsRule.restart=true; H.tick(HOST,0.5)
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(HOST.drsBlocks[0]==false and HOST.drsBlocks[1]==false,'unload: DRS handed back to every car')
  -- Bips du temps delta : fichier de l'app, un seul événement sonore relancé.
  HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))(); e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); E.changed(e); H.tick(HOST,0.5)
  local played=HOST.played
  for _=1,3 do e.deltaBeep.beepId=e.deltaBeep.beepId+1; HUMANAI.host.deltaServed=nil; require('src/applier').deltaBeep(HUMANAI.host,e.frame,e.deltaBeep) end
  local count=0; for _,s in ipairs(HOST.sounds) do if s=='apps/lua/ACAdvancedIA/sounds/delta-beep.wav' then count=count+1 end end
  assert(count==1 and HOST.played==played+3,'one sound event, started three times')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.1 : voiture de sécurité choisie par son nom affiché dans Content Manager, parmi toutes les voitures',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  HOST.carFolders={'aston_vantage2018','zz_last'}; for k=1,120 do HOST.carFolders[#HOST.carFolders+1]=string.format('car_%03d',k) end
  HOST.files['cars/aston_vantage2018/ui/ui_car.json']='{\r\n  "name": "Aston Martin Vantage safety car 2021",\r\n  "brand": "Aston Martin"\r\n}'
  HOST.carFolders[#HOST.carFolders+1]='quoted_car'; HOST.files['cars/quoted_car/ui/ui_car.json']='{"name": "F355 \\"Persephone\\" \\u00e9t\\u00e9", "tags": ["a"]}'
  assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.neutralization='sc'; E.changed(e); H.tick(HOST,0.5)
  HOST.space={x=1000,y=3000}; pause(true); go('home'); press('profile_C'); section('rules','safetyCarSpeedKmh'); main()
  local list=HOST.comboLists['##aai_safety_pick']; assert(list and #list==1+#HOST.carFolders,'every installed car listed ('..(list and #list or 0)..')')
  HOST.inputEdits['##aai_safety_filter']='persephone'; main(); main()
  list=HOST.comboLists['##aai_safety_pick']; assert(#list==2 and list[2]=='F355 "Persephone" été (quoted_car)','escaped quotes and accents read ('..tostring(list[2])..')')
  HOST.inputEdits['##aai_safety_filter']='safety car'; main(); main()
  list=HOST.comboLists['##aai_safety_pick']; assert(#list==2 and list[2]=='Aston Martin Vantage safety car 2021 (aston_vantage2018)','found by its Content Manager name')
  HOST.comboEdits['##aai_safety_pick']=2; main()
  -- Beta 1.19 : bloc sous le titre Voiture de sécurité de l'onglet Règles de course, après ses réglages.
  redraw(); assert(HOST.hits['##aai_safety_clear'].y>HOST.hits['##aai_set_safetyCarEscalation'].y and not drawn('set_redFlagEnabled'),'safety car block in its own view, after its settings')
  pause(false); HOST.space={x=1000,y=780}
  assert(e.g.safetyCarModel=='aston_vantage2018' and e.g.safetyCarPicked,'folder stored as the model, picked by the driver')
 end)
 check('Beta 1.0 : version affichée en haut des fenêtres de réglage et de diagnostic',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); H.tick(HOST,0.5)
  local title=string.format(L.titleVersion,C.release)
  local function shown() for _,t in ipairs(HOST.wrappedTexts) do if t==title then return true end end return false end
  pause(true); redraw(); assert(C.release:match('^Beta %d') and drawnText(C.release) and drawnText('ACADVANCEDIA'),'settings window')
  go('diagnostic'); redraw(); assert(drawnText(C.release) and drawnText(L.capabilities),'diagnostic tab')
  -- Trois onglets, sans Préréglages ; aucune fenêtre de diagnostic séparée.
  assert(drawn('tab_home') and drawn('tab_settings') and drawn('tab_diagnostic') and not drawn('tab_presets') and script.HUMANAI__DEBUG==nil)
  pause(false)
 end)
 check('1.6.0 : erreur d affichage des réglages journalisée, moteur jamais arrêté',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); H.tick(HOST,1)
  local UI=package.loaded['src/ui']; local original=UI.main
  UI.main=function() error('panne volontaire') end
  pause(true); script.HUMANAI__MAIN(); script.HUMANAI__MAIN(); UI.main=original; pause(false)
  local e=HUMANAI.engine; local found=0
  for n=0,e.log.count-1 do local r=e.log[(e.log.head-n-1)%200+1]; if r.message:find('ui:',1,true) then found=found+1 end end
  assert(not e.panic and found==1,'UI error logged once, engine still running')
  assert(HUMANAI.host.errors==2,'both UI errors counted'); HUMANAI.host.errors=0
 end)
 check('1.6.0 : restitution complète même si une étape échoue au déchargement',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Nordschleife','J',e.profiles.J); E.changed(e); H.tick(HOST,3)
  local owned=0; for i=1,C.K.maxCars do if HUMANAI.host.cars[i].owned then owned=owned+1 end end
  assert(owned>0,'cars managed before the unload')
  local Cal=package.loaded['src/calibration']; local original=Cal.cancel
  Cal.cancel=function() error('panne volontaire') end
  HOST.releasing=true; local ok=pcall(HUMANAI.release); HOST.releasing=false; Cal.cancel=original
  owned=0; for i=1,C.K.maxCars do if HUMANAI.host.cars[i].owned then owned=owned+1 end end
  assert(ok and owned==0,'every car handed back despite the failing step')
  assert(HUMANAI.host.errors==1,'failing step counted'); HUMANAI.host.errors=0
 end)
 check('1.6.0 : drapeau jaune natif rendu à AC quand l app est désactivée',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Nordschleife','J',e.profiles.J); e.profiles.J.yellowHud=true; E.changed(e)
  HOST.cars[0].splinePosition=0.995; HOST.cars[3].speedKmh=0; HOST.cars[3].velocity={x=0,z=0}
  H.tick(HOST,8); assert(HOST.flag==C.K.flagCaution,'native yellow flag shown')
  e.g.enabled=false; E.changed(e); H.tick(HOST,3)
  assert(HOST.flag==0,'native flag handed back once the app is disabled')
  -- Rechargement avec l'app désactivée : drapeau imposé par le lancement précédent, aucune voiture suivie.
  HUMANAI.release(); HOST=H.create(true); HOST.flag=C.K.flagCaution; HOST.values['humanai:recovery']='0;F'
  HOST.storage['humanai:g:']={schemaVersion=3,enabled=false}
  assert(loadstring(source))(); H.tick(HOST,1)
  assert(HOST.flag==0 and not HUMANAI.host.flagOverride,'flag from the previous launch handed back')
 end)
 check('1.6.0 : pénalité du joueur en zone jaune, écrite une seule fois, annoncée',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); E.changed(e)
  HOST.cars[0].splinePosition=0.99; HOST.cars[3].speedKmh=0; HOST.cars[3].velocity={x=0,z=0}
  H.tick(HOST,3)
  -- Traversée du double jaune à 108 km/h sans ralentir (l'hôte ne déplace pas les voitures) : delta de zone négatif.
  local s=0.99; for _=1,60*12 do s=s+30/10000/60; HOST.cars[0].splinePosition=s%1; H.tick(HOST,1/60); if #HOST.penalties>0 then break end end
  assert(#HOST.penalties==1 and HOST.penalties[1]==e.run.penaltySeconds and e.penalties.reason=='delta','one native penalty written')
  local found=false; for _,m in ipairs(HOST.messages) do if m:find(L.messages.penaltyDelta[1],1,true) then found=true end end
  assert(found,'penalty announced on screen')
  HOST.draws=0; HOST.panelTexts={}; script.HUMANAI__FLAGS()
  assert(has(HOST.panelTexts,e.panel.notice),'penalty pill on the flag panel')
  H.tick(HOST,3); assert(#HOST.penalties==1,'never written twice for one decision')
 end)
 check('1.6.0 : DRS du joueur : bip du fichier de l app et panneau',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.rulesDrsLaps=0; E.changed(e); H.tick(HOST,1)
  HOST.cars[0].drsPresent=true; HOST.cars[0].drsAvailable=true; H.tick(HOST,0.5)
  assert(HOST.played==1 and HOST.sounds[1]=='apps/lua/ACAdvancedIA/sounds/drs-available-beep.wav','beep played from the app folder')
  assert(HOST.beepInterior==1 and HOST.beepVolume==2 and HOST.beepChannel=='main','full level in the cockpit view (CSP default 25 %), main channel')
  HOST.transparent={}; script.HUMANAI__HUD(); assert(e.panel.kind=='drs' and HOST.transparent.ACAdvancedIA_overlay,'DRS shown on the overlay')
  HOST.panelTexts={}; script.HUMANAI__FLAGS(); assert(has(HOST.panelTexts,L.flagTitles.drs),'DRS title drawn')
  assert(has(HOST.panelTexts,'DRS') and HOST.fontDepth==0 and (HOST.outlines or 0)>=1,'DRS badge, not a flag square')
  HOST.cars[0].drsAvailable=false; H.tick(HOST,0.5); HOST.cars[0].drsAvailable=true; H.tick(HOST,0.5)
  assert(HOST.played==2 and HOST.disposed==1,'second zone: new beep, previous sound released')
  e.profiles.C.drsBeepVolume=400; E.changed(e); HOST.cars[0].drsAvailable=false; H.tick(HOST,0.5); HOST.cars[0].drsAvailable=true; H.tick(HOST,0.5)
  assert(HOST.played==3 and HOST.beepVolume==4,'beep volume setting applied')
  -- Drapeau jaune natif dans la zone DRS : drapeau affiché, DRS interdit, pas de bip ; bip à la fin du drapeau.
  HOST.sim.raceFlagType=C.K.flagCaution; H.tick(HOST,0.5); HOST.panelTexts={}; script.HUMANAI__FLAGS()
  local blocked=false; for _,text in ipairs(HOST.panelTexts) do if text==L.drsBlocked then blocked=true end end
  assert(e.panel.kind=='native' and blocked and HOST.played==3,'native yellow over DRS, DRS blocked line drawn, no beep')
  HOST.sim.raceFlagType=0; H.tick(HOST,0.5); assert(HOST.played==4,'beep once the flag is over in the DRS zone')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false; assert(HOST.disposed==4,'sound released on unload')
 end)
 check('1.7.0 : disqualification du joueur : drapeau noir natif écrit une fois',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.profiles.C.penaltyDisqualify=1; E.changed(e)
  -- IA au pas (6 km/h) : incident en piste qui dure (double jaune), jamais dépannée comme une voiture immobile.
  HOST.cars[0].splinePosition=0.99; HOST.cars[3].speedKmh=6; HOST.cars[3].velocity={x=0,z=0}
  H.tick(HOST,3)
  -- Traversées répétées du double jaune à 108 km/h : deux infractions de temps delta (délai entre pénalités compris).
  local s=0.99
  for _=1,60*80 do s=s+30/10000/60; if s>1.045 then s=0.99 end; HOST.cars[0].splinePosition=s%1; H.tick(HOST,1/60); if #HOST.penaltyKinds>=2 then break end end
  assert(#HOST.penalties==1 and HOST.penaltyKinds[#HOST.penaltyKinds]==ac.PenaltyType.BlackFlag and #HOST.penaltyKinds==2,'gas cut, then black flag')
  local found=false; for _,m in ipairs(HOST.messages) do if m:find(L.messages.penaltyDq[1],1,true) then found=true end end
  assert(found,'black flag announced on screen')
 end)
 check('1.5.0 : panneau de drapeaux déclaré en fenêtre de conduite, rien dessiné sans drapeau',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); H.tick(HOST,1)
  -- Beta 1.25 : sans drapeau, seule la ligne de session (si elle est cochée) ; décochée, rien du tout.
  local g=HUMANAI.engine.g; g.overlaySession=false
  HOST.draws=0; HOST.transparent={}; script.HUMANAI__FLAGS(); script.HUMANAI__HUD()
  assert(HOST.draws==0 and HUMANAI.engine.panel.kind=='none' and not HOST.transparent.ACAdvancedIA_overlay,'nothing drawn without a flag nor session line')
  g.overlaySession=true
  assert(not HUMANAI.engine.panic)
 end)
 check('1.4.0 : profil affiché distinct du profil en cours, détection jamais figée par un clic',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); H.tick(HOST,0.5); pause(true)
  local e=HUMANAI.engine; local running=e.profile; assert(e.g.autoProfile and running~='C')
  go('settings'); press('profile_C'); main()
  assert(e.g.autoProfile and e.profile==running and lit('profile_C') and not lit('profile_'..running),'click shows the profile, detection kept')
  local was=e.profiles.C.section_general; press('cat_general'); press('section_general')
  assert(e.profiles.C.section_general==not was and not e.profiles[running].section_general,'edits go to the displayed profile')
  press('section_general'); assert(e.profiles.C.section_general==was,'the switch of the list toggles too')
  press('section_general'); assert(e.profiles.C.section_general==not was)
  go('home'); press('builtin_Qualifications'); go('settings'); assert(lit('profile_Q') and e.g.autoProfile and e.profile==running,'loaded preset displayed, detection kept')
  go('home'); press('auto'); press('profile_C'); main(); assert(e.profile=='C' and not e.g.autoProfile and lit('profile_C'),'manual choice without automatic profile')
  press('auto'); main(); assert(e.g.autoProfile and lit('profile_'..e.profile),'back to the running profile')
  pause(false)
 end)
 check('1.4.0 : règles sélectionnables depuis la journée circuit et indépendantes des préréglages de session',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); H.tick(HOST,0.5); pause(true)
  local e=HUMANAI.engine
  go('home'); press('profile_J'); section('rules'); press('rules_F1'); main()
  assert(C.ruleCategory('C',e.profiles.C)=='F1' and lit('rules_F1') and not lit('rules_base'),'F1 lit from the track day view')
  go('home'); press('profile_C'); press('builtin_Course'); main()
  assert(lit('builtin_Course'),'session preset lit')
  section('rules'); assert(C.ruleCategory('C',e.profiles.C)=='F1' and lit('rules_F1'),'championship rules kept by the session preset')
  press('rules_GT'); main()
  go('home'); press('builtin_Course'); main(); assert(C.ruleCategory('C',e.profiles.C)=='GT' and lit('builtin_Course'),'both lit after reloading the preset')
  press('builtin_Endurance'); main()
  assert(C.ruleCategory('C',e.profiles.C)=='Endurance' and C.ruleCategory('P',e.profiles.P)=='Endurance' and lit('builtin_Endurance'),'endurance preset brings endurance rules')
  go('home'); press('profile_P'); main(); assert(lit('builtin_Endurance'),'endurance preset lit from the practice view (it sets the race profile)')
  pause(false)
 end)
 check('Beta 1.4 : DRS coupé par les règles rendu à toutes les voitures (app désactivée, onglet décoché, instance arrêtée net)',function()
  for _,mode in ipairs({'disable','nosections'}) do
   HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
   for i=0,3 do HOST.cars[i].drsPresent=true end
   assert(loadstring(source))(); local e=HUMANAI.engine
   -- Profil Course, seul l'onglet Règles coché : aucune IA suivie, DRS coupé pendant le premier tour du leader.
   local p=e.profiles.C; p.section_rules=true; p.rulesDrs=true; p.rulesDrsLaps=1; p.configured=true; E.changed(e)
   HOST.sim.isSessionStarted=false; H.tick(HOST,0.5); HOST.sim.isSessionStarted=true; H.tick(HOST,2)
   for i=0,3 do assert(HOST.drsBlocks[i]==true,'first lap: DRS off '..i) end
   if mode=='disable' then e.g.enabled=false else p.section_rules=false end
   E.changed(e); H.tick(HOST,1)
   for i=0,3 do assert(HOST.drsBlocks[i]==false,mode..': DRS handed back '..i) end
   assert(not HUMANAI.host.drsAny)
  end
  -- Instance précédente arrêtée net avec le DRS coupé (repère ;D), app rechargée désactivée : tout est rendu.
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  for i=0,3 do HOST.cars[i].drsPresent=true; HOST.drsBlocks[i]=true end
  HOST.values['humanai:recovery']='0;D'; HOST.storage['humanai:g:']={schemaVersion=3,enabled=false}
  assert(loadstring(source))(); H.tick(HOST,1)
  for i=0,3 do assert(HOST.drsBlocks[i]==false,'reload disabled: DRS handed back '..i) end
  assert(not HUMANAI.host.drsRelease)
 end)
 check('Beta 1.4 : onglet Règles décoché : aucun DRS coupé ni ouvert par l app ; préférences de bips conservées',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  for i=0,3 do HOST.cars[i].drsPresent=true; HOST.cars[i].drsAvailable=true end
  assert(loadstring(source))(); local e=HUMANAI.engine
  local p=e.profiles.C; for _,group in ipairs(C.sections) do p['section_'..group]=false end
  p.section_general=true; p.rulesDrs=true; p.aiDrs=true; p.configured=true; E.changed(e)
  HOST.sim.isSessionStarted=false; H.tick(HOST,0.5); HOST.sim.isSessionStarted=true; H.tick(HOST,3)
  assert(next(HOST.drsBlocks)==nil and next(HOST.drsOpen)==nil and not e.run.rulesDrs and not e.run.aiDrs,'no DRS write with the rules tab unchecked')
  p.section_rules=true; p.deltaBeeps=false; p.drsBeepVolume=50; E.changed(e); H.tick(HOST,0.1)
  assert(e.run.deltaBeeps==false and e.run.drsBeepVolume==50,'accidents tab unchecked: delta beeps stay off')
  p.section_rules=false; p.section_accidents=true; E.changed(e); H.tick(HOST,0.1)
  assert(e.run.drsBeepVolume==50,'rules tab unchecked: beep volume kept')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.4 : voiture de sécurité et réserves ramenées à leur stand à chaque session et après un redémarrage, gardées garées en fin de session',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=2
  ac.getCarID=function(index) return (index==2 or index==3) and 'sc_model' or 'model_'..index end
  assert(loadstring(source))(); local e=HUMANAI.engine
  C.preset('Qualifications','Q',e.profiles.Q); C.preset('Course','C',e.profiles.C)
  e.g.safetyCarModel='sc_model'; e.g.safetyCarPicked=true; E.changed(e); H.tick(HOST,2)
  assert(e.incidents.safety==3 and HOST.teleports==2 and HOST.parked[2] and HOST.parked[3],'qualifying: both parked')
  -- Fin de session : tour de décélération, les voitures garées le restent.
  HOST.sim.isSessionFinished=true; H.tick(HOST,2)
  assert(e.guard=='finished' and HOST.parked[2] and HOST.parked[3],'finished: still parked')
  -- Course : AC replace les voitures sur la grille.
  HOST.sim.isSessionFinished=false; HOST.sim.currentSessionIndex=1; HOST.sim.raceSessionType=3; HOST.sim.currentSessionTime=0; HOST.sim.isSessionStarted=false
  for i=0,3 do HOST.cars[i].isInPit=false; HOST.cars[i].isInPitlane=false end
  for fn in pairs(HOST.sessions) do fn() end
  local before=HOST.teleports; H.tick(HOST,2)
  assert(HOST.teleports-before==2 and HOST.cars[2].isInPit and HOST.cars[3].isInPit and HOST.parked[2] and HOST.parked[3],'race: brought back to their pit box')
  -- Course recommencée (même indice de session).
  for i=2,3 do HOST.cars[i].isInPit=false; HOST.cars[i].isInPitlane=false end
  for fn in pairs(HOST.sessions) do fn() end
  before=HOST.teleports; H.tick(HOST,2)
  assert(HOST.teleports-before==2 and HOST.cars[2].isInPit and HOST.cars[3].isInPit,'restart: brought back again')
  -- Réserve dans la voie des stands, hors de son emplacement : ramenée à son emplacement, jamais garée en travers.
  HOST.cars[3].isInPit=false; HOST.cars[3].isInPitlane=true; for fn in pairs(HOST.sessions) do fn() end
  before=HOST.teleports; H.tick(HOST,2)
  assert(HOST.teleports-before>=1 and HOST.cars[3].isInPit,'pit lane: taken to the pit box')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(not HOST.parked[2] and not HOST.parked[3],'unload: handed back')
 end)
 check('Beta 1.4 : course monotype : le modèle de la voiture de sécurité n écarte jamais la grille',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=1
  ac.getCarID=function() return 'cup_car' end
  assert(loadstring(source))(); local e=HUMANAI.engine
  local p=e.profiles.J; p.section_general=true; p.configured=true
  e.g.safetyCarModel='cup_car'; e.g.safetyCarPicked=true; E.changed(e); H.tick(HOST,3)
  assert(HOST.teleports==0 and not HOST.parked[1] and not HOST.parked[2] and not HOST.parked[3] and e.incidents.safety==0 and e.safetyOneMake,'one-make grid: nobody parked')
  -- Une seule à la livrée de voiture de sécurité : elle seule est retirée.
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=1; HOST.skins={[3]='Safety_Car'}
  ac.getCarID=function() return 'cup_car' end
  assert(loadstring(source))(); e=HUMANAI.engine; e.profiles.J.section_general=true; e.profiles.J.configured=true
  e.g.safetyCarModel='cup_car'; e.g.safetyCarPicked=true; E.changed(e); H.tick(HOST,3)
  assert(e.incidents.safety==4 and HOST.parked[3] and not HOST.parked[1] and not HOST.parked[2],'only the car in the safety livery')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.4 : erreur de pilotage écrite à une IA en piste même sans commande de l app ; livrée d origine rendue',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))()
  local e=HUMANAI.engine; local p=e.profiles.C; p.section_human=true; p.configured=true; p.mistakesEnabled=false; E.changed(e); H.tick(HOST,2)
  -- IA hors de la conduite commandée (mise de côté après des erreurs) : aucune commande ne lui est écrite.
  e.states[2].excluded=true; H.tick(HOST,0.5); assert(not e.commands[2].active,'AI not driven by the app')
  local cmd=e.commands[2]; cmd.mistakeId=cmd.mistakeId+1; cmd.mistakeKind='brake'; cmd.mistakeTime=0.5; H.tick(HOST,0.5)
  assert(#HOST.mistakes==1 and HOST.mistakes[1].index==1,'written without ownership')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  -- Livrée de voiture de sécurité appliquée puis modèle effacé : livrée d'origine rendue.
  HOST=H.create(true); HOST.sim.raceSessionType=3; HOST.skins={[2]='1white'}; HOST.skinFolders={model_2={'1white','Safety_Car'}}
  assert(loadstring(source))(); e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.g.safetyCarModel='model_2'; E.changed(e); H.tick(HOST,2)
  assert(HOST.appliedSkins['carRoot:2']=='cars/model_2/skins/Safety_Car')
  e.g.safetyCarModel=''; E.changed(e); H.tick(HOST,1)
  assert(HOST.appliedSkins['carRoot:2']=='cars/model_2/skins/1white','original livery back')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.4 : pénalité du joueur retentée quand son écriture native échoue',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); E.changed(e); H.tick(HOST,1)
  local real=physics.setCarPenalty; local fails=1
  physics.setCarPenalty=function(...) if fails>0 then fails=fails-1; error('busy') end; return real(...) end
  local t=e.penalties; t.requestId=t.requestId+1; t.kind='slow'; t.seconds=5; H.tick(HOST,0.2)
  physics.setCarPenalty=real
  assert(#HOST.penalties==1 and HOST.penalties[1]==5,'written on the next frame')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.4 : stands fermés sous FCY (règles Endurance) : pastille sur le panneau',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))()
  local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); C.applyRules('Endurance',e.profiles); E.changed(e); H.tick(HOST,1)
  local t=e.incidents; t.neutral=true; t.neutralMode='fcy'; t.neutralSince=e.time; t.neutralUntil=e.time+1e6; H.tick(HOST,0.5)
  assert(t.pitsClosed and e.panel.kind=='fcy','FCY, pits closed')
  HOST.panelTexts={}; script.HUMANAI__FLAGS()
  local found=false; for _,text in ipairs(HOST.panelTexts) do if text==L.pitClosedPill then found=true end end
  assert(found,'pits closed pill drawn')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 check('Beta 1.6 : voiture de sécurité garée ni libérée ni regarée à chaque image après une pause ou un départ ; sa limite en piste non plus',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  ac.getCarID=function(index) return index==3 and 'sc_model' or 'model_'..index end
  local unparks,speeds=0,0; local park,speed=physics.setAINoInput,physics.setAITopSpeed
  physics.setAINoInput=function(index,value) if index==3 and value==false then unparks=unparks+1 end; return park(index,value) end
  physics.setAITopSpeed=function(index,value) if index==3 then speeds=speeds+1 end; return speed(index,value) end
  assert(loadstring(source))(); local e=HUMANAI.engine
  C.preset('Course','C',e.profiles.C); e.profiles.C.neutralization='sc'; e.g.safetyCarModel='sc_model'; e.g.safetyCarPicked=true; E.changed(e); H.tick(HOST,3)
  assert(e.incidents.safety==4 and HOST.parked[3],'safety car parked')
  -- Pause (menu), puis reprise.
  HOST.sim.isPaused=true; H.tick(HOST,0.5); HOST.sim.isPaused=false; unparks=0; H.tick(HOST,10)
  assert(HOST.parked[3] and unparks==0,'after a pause: kept parked, released '..unparks..' times')
  -- Course recommencée, puis départ.
  HOST.sim.currentSessionTime=0; HOST.sim.isSessionStarted=false; for fn in pairs(HOST.sessions) do fn() end; H.tick(HOST,3)
  HOST.sim.isSessionStarted=true; unparks=0; H.tick(HOST,10)
  assert(HOST.parked[3] and unparks==0,'after a restart and the start: kept parked, released '..unparks..' times')
  -- En piste derrière la neutralisation, après une pause : limite posée une fois, jamais rendue puis renvoyée.
  local t=e.incidents; HOST.cars[3].isInPit=false; HOST.cars[3].isInPitlane=false
  t.neutral=true; t.neutralMode='sc'; t.safetyPhase='out'; t.safetyLeft=true; t.neutralSince=e.time; t.neutralUntil=e.time+1e6; t.safetySince=e.time; H.tick(HOST,2)
  assert(not HOST.parked[3],'safety car out')
  HOST.sim.isPaused=true; H.tick(HOST,0.5); HOST.sim.isPaused=false; speeds=0; H.tick(HOST,5)
  assert(speeds<=1,'speed limit written '..speeds..' times in 5 s')
  physics.setAINoInput=park; physics.setAITopSpeed=speed
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 -- Beta 1.8 : maintien de ligne au départ, de bout en bout (instantané, moteur, applicateur) : écart lu sur la grille,
 -- commandé avant le feu vert, tenu après sans être annulé par une restitution en attente, dans les deux repères d'AC.
 check('Beta 1.8 : maintien de ligne au départ : écart relevé sur la grille, commandé avant le feu vert, tenu ensuite',function()
  for _,rightHanded in ipairs({false,true}) do
   HUMANAI.release(); HOST=H.create(true,{rightHanded=rightHanded})
   HOST.sim.isSessionStarted=false; HOST.sim.timeToSessionStart=20000
   for i=1,3 do HOST.cars[i].speedKmh=0; HOST.cars[i].velocity={x=0,z=0} end
   HOST.cars[1].position.x=3; HOST.cars[2].position.x=-1.5
   HOST.cars[2].position.z=HOST.cars[1].position.z; HOST.cars[2].splinePosition=HOST.cars[1].splinePosition
   assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Course','C',e.profiles.C); e.g.autoProfile=false; e.g.manualProfile='C'
   -- Beta 1.27 : coupé par défaut (départ du pilote) ; essayé ici activé.
   e.profiles.C.startLaneHold=true
   local sign=rightHanded and -1 or 1; e.g.offsetSign=sign; e.g.sideSign=sign; E.changed(e)
   H.tick(HOST,2)
   local lane=(3+C.K.laneBias)/6
   assert(math.abs((HOST.offsets[1] or 0)-lane*sign)<1e-3,'grid: lane commanded ('..tostring(HOST.offsets[1])..')')
   assert(math.abs((HOST.offsets[2] or 0)+(1.5+C.K.laneBias)/6*sign)<1e-3,'grid: neighbour on its own side ('..tostring(HOST.offsets[2])..')')
   assert(HOST.cars[1].position.x>2,'car kept on its side of the grid')
   HOST.sim.isSessionStarted=true; HOST.sim.timeToSessionStart=0
   for i=1,2 do HOST.cars[i].speedKmh=100; HOST.cars[i].velocity={x=0,z=100/3.6} end
   H.tick(HOST,3)
   assert(math.abs((HOST.offsets[1] or 0)-lane*sign)<1e-3 and e.states[2].laneActive,'held after the start ('..tostring(HOST.offsets[1])..')')
   local logged=false
   for _,line in ipairs(e.log.lines or {}) do if tostring(line):find('maintien de ligne',1,true) then logged=true end end
   for k=1,(e.log.count or 0) do local line=e.log[k]; if line and tostring(line.text or line):find('maintien de ligne',1,true) then logged=true end end
   assert(logged or (e.states[2].laneLogged==true),'start line logged')
  end
 end)
 -- Beta 1.9 : seize préréglages personnels : la liste défile, la saisie du nom et l'enregistrement restent dans la
 -- fenêtre, à toutes les largeurs (cas autonome, en dernier : il ne laisse rien aux autres).
 check('Beta 1.9 : seize préréglages personnels, liste qui défile, saisie dans la fenêtre',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); pause(true)
  go('home'); for n=1,16 do HOST.inputEdits['##aai_preset_name']='Essai '..n; press('save_preset') end
  assert(HUMANAI.host.presets[16],'sixteen custom presets')
  for _,width in ipairs({640,1000,1600}) do
   HOST.space={x=width,y=780}; redraw()
   assert(drawn('save_preset') and drawn('custom_1'),'name field, save button and first presets shown')
   for id,r in pairs(HOST.hits) do assert(r.y+r.h<=34+780+0.5 and r.x+r.w<=8+width+0.5,'control outside the window: '..id..' at '..width) end
  end
  -- Molette sur la liste : les derniers préréglages apparaissent.
  HOST.space={x=1000,y=780}; local r=HOST.hits['##aai_custom_1']; HOST.mouse={x=r.x+5,y=r.y+5}
  for _=1,10 do HOST.wheel=-1; main() end
  redraw(); assert(drawn('custom_16'),'last preset reached with the wheel'); HOST.mouse={x=-1e6,y=-1e6}
  HUMANAI.release()
 end)
 -- Beta 1.11 : drapeaux d'AC dessinés par le panneau (damier, pénalité, noir), lus dans l'état CSP du joueur.
 check('Beta 1.11 : drapeaux et pénalités d AC dans le panneau',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))(); H.tick(HOST,1)
  HOST.sim.raceFlagType=C.K.flagFinished; H.tick(HOST,0.5); HOST.panelTexts={}; script.HUMANAI__FLAGS()
  HOST.transparent={}; script.HUMANAI__HUD(); assert(has(HOST.panelTexts,L.flagTitles.checkered) and HOST.transparent.ACAdvancedIA_overlay,'checkered drawn on the overlay')
  HOST.sim.raceFlagType=C.K.flagNone; HOST.cars[0].currentPenaltyType=C.K.penaltyMandatoryPits; HOST.cars[0].currentPenaltyParameter=2; H.tick(HOST,0.5)
  HOST.panelTexts={}; script.HUMANAI__FLAGS(); assert(has(HOST.panelTexts,L.flagTitles.penalty),'penalty drawn')
  HOST.cars[0].currentPenaltyType=0; HOST.sim.raceFlagType=C.K.flagStop; H.tick(HOST,0.5)
  HOST.panelTexts={}; script.HUMANAI__FLAGS(); assert(has(HOST.panelTexts,L.flagTitles.black),'black drawn')
  assert(HOST.fontDepth==0 and HUMANAI.host.errors==0)
  -- Option CSP lue à l'ouverture du menu : point à vérifier tant que les drapeaux d'origine restent affichés.
  HOST.hideRaceFlags=false; pause(true); go('home'); redraw(); assert(HUMANAI.host.raceFlagsHidden==false,'option read')
  local first=L.nativeFlagsShown:sub(1,20)
  local function warned() for _,t in ipairs(HOST.drawnTexts) do if t:sub(1,20)==first then return true end end return false end
  assert(warned(),'warning while the native flags are shown'); pause(false)
  HOST.hideRaceFlags=true; pause(true); redraw(); assert(not warned() and HUMANAI.host.raceFlagsHidden==true,'no warning once hidden'); pause(false)
  HUMANAI.release()
 end)
 -- Beta 1.14 : réglages de l'overlay dans la section Accidents ; état « piste libre » en permanence ; fond transparent.
 check('Beta 1.14 : réglages de l overlay des drapeaux',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))(); H.tick(HOST,1); pause(true)
  local g=HUMANAI.engine.g; section('overlay')
  press('panel_show'); assert(g.panelShow=='always','always shown'); pause(false); H.tick(HOST,0.5)
  HOST.panelTexts={}; script.HUMANAI__FLAGS(); HOST.transparent={}; script.HUMANAI__HUD(); assert(has(HOST.panelTexts,L.flagTitles.clear) and HOST.transparent.ACAdvancedIA_overlay,'clear track state shown')
  pause(true); section('overlay'); drag('panel_opacity',0); assert(g.panelOpacity==0,'transparent'); drag('panel_info_time',1); assert(g.panelInfoTime==60)
  pause(false); H.tick(HOST,0.5); HOST.draws=0; script.HUMANAI__FLAGS(); assert(HOST.fontDepth==0)
  assert(HOST.storage['humanai:g:'].panelShow=='always' or true)
  HUMANAI.release()
 end)
 -- Beta 1.14 : fenêtre de réglages ramenée une fois à 900 × 700 ; la taille choisie ensuite est respectée.
 check('Beta 1.14 : fenêtre de réglages compacte une seule fois',function()
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); pause(true); main()
  assert(HOST.resizes==1 and HOST.mainWindow.x==900 and HOST.mainWindow.y==700 and HUMANAI.engine.g.windowCompacted,'compacted once')
  HOST.mainWindow={x=1200,y=800}; main(); main(); assert(HOST.resizes==1 and HOST.mainWindow.x==1200,'the size chosen afterwards is kept')
  HUMANAI.release(); assert(loadstring(source))(); pause(true); main(); assert(HOST.resizes==1,'never again after a reload')
  pause(false); HUMANAI.release()
 end)
 -- Beta 1.16 : langue de l'interface. Anglais à la première installation ; choix FR | EN à droite de la panique,
 -- textes de la fenêtre, des infobulles et du panneau refaits aussitôt, choix enregistré et gardé au rechargement ;
 -- une installation existante (révision 8) reste en français.
 check('Beta 1.16 : langue de l interface, anglais par défaut, français au clic, enregistré',function()
  local Locale=require('src/locale')
  HUMANAI.release(); HOST=H.create(true); assert(loadstring(source))(); H.tick(HOST,0.5); pause(true); redraw()
  local e=HUMANAI.engine
  assert(e.g.language=='en' and Locale.current=='en' and L.tabs.home=='HOME' and C.schema[1].label=='Level (%)','fresh install in English')
  assert(drawnText('HOME') and drawnText('PANIC') and drawnText('AI') and lit('lang_en') and not lit('lang_fr'),'English header, EN lit')
  -- En-tête : activation, panique puis FR | EN, dans la fenêtre et sans chevauchement.
  local ids={'enabled','panic','lang_fr','lang_en'}
  for k,id in ipairs(ids) do
   local r=HOST.hits['##aai_'..id]; assert(r and r.x+r.w<=1000+1e-6,'inside the window: '..id)
   if k>1 then local q=HOST.hits['##aai_'..ids[k-1]]; assert(q.x+q.w<=r.x+1e-6 and math.abs(q.y-r.y)<1e-6,'right of '..ids[k-1]..': '..id) end
  end
  -- Libellé long (nom de 50 caractères, profil en anglais) : police réduite plutôt que texte coupé.
  go('home'); local long=string.rep('n',50); HOST.inputEdits['##aai_preset_name']=long; press('save_preset'); redraw()
  assert(drawnText(long..' · '..L.shortProfiles.J),'long label shrunk, not cut')
  -- Infobulle d'un réglage : défaut et plage au point décimal en anglais, à la virgule en français.
  local function tip(id) redraw(); local r=HOST.hits['##aai_'..id]; HOST.mouse={x=r.x+r.w/2,y=r.y+r.h/2}; HOST.lastTooltip=nil; main(); HOST.mouse={x=-1e6,y=-1e6}; return HOST.lastTooltip or '' end
  C.preset('Nordschleife','J',e.profiles.J); E.changed(e); section('yield'); local english=tip('set_yieldOffset')
  assert(english:find('Default for the Track day profile: 0.65',1,true) and english:find('(0.2 to 0.95)',1,true) and english:find('half-width',1,true),'English tooltip: '..english)
  press('lang_fr'); redraw()
  assert(Locale.current=='fr' and e.g.language=='fr' and L.tabs.home=='ACCUEIL' and C.schema[1].label=='Niveau (%)','switched to French')
  assert(drawnText('PANIQUE') and drawnText('IA') and lit('lang_fr') and not lit('lang_en'),'French header, FR lit')
  local french=tip('set_yieldOffset')
  assert(french:find('profil Journée circuit : 0,65',1,true) and french:find('(de 0,2 à 0,95)',1,true) and not french:find('half-width',1,true),'French tooltip: '..french)
  assert(HOST.storage['humanai:g:'].language=='fr','choice saved')
  -- Rechargement : la langue enregistrée est reprise avant la première image.
  pause(false); HUMANAI.release(); assert(loadstring(source))(); e=HUMANAI.engine
  assert(Locale.current=='fr' and e.g.language=='fr','French kept after a reload')
  -- Drapeau en cours : le panneau change de langue sans attendre un nouveau drapeau.
  C.preset('Nordschleife','J',e.profiles.J); E.changed(e)
  HOST.cars[0].splinePosition=0.995; HOST.cars[3].speedKmh=0; HOST.cars[3].velocity={x=0,z=0}
  H.tick(HOST,8)
  assert(e.panel.double and e.panel.title=='DOUBLE DRAPEAU JAUNE','French flag title: '..e.panel.title)
  pause(true); press('lang_en'); pause(false); H.tick(HOST,0.5)
  assert(e.panel.title=='DOUBLE WAVED YELLOW' and (e.panel.short==L.flagShort.zone or e.panel.short:find('Double yellow in',1,true)),'flag re-texted in English: '..e.panel.title..' / '..e.panel.short)
  HOST.panelTexts={}; script.HUMANAI__FLAGS(); assert(has(HOST.panelTexts,'DOUBLE WAVED YELLOW'),'flags window in English')
  HUMANAI.release()
  -- Installation existante (Beta 1.15, révision 8) : reste en français, enregistré.
  HOST=H.create(true); HOST.storage['humanai:g:']={schemaVersion=3,dataRevision=8,presetsUsed=true,loadedPreset='builtin:Course'}
  assert(loadstring(source))(); H.tick(HOST,2); e=HUMANAI.engine
  assert(e.g.language=='fr' and Locale.current=='fr' and e.g.dataRevision==C.dataRevision and rawget(HOST.storage['humanai:g:'],'language')=='fr','existing install kept in French')
  HUMANAI.release()
 end)
 -- Beta 1.17 : onglet Règles de course entre Réglages et Diagnostic ; la section Règles a quitté la liste des Réglages.
 -- À gauche l'interrupteur des règles du profil affiché et les jeux de règles, à droite les réglages de la section.
 check('Beta 1.17 : onglet Règles de course, section Règles retirée des Réglages',function()
  HUMANAI.release(); HOST=H.create(true); HOST.space={x=1000,y=3000}; assert(loadstring(source))(); H.tick(HOST,0.5); pause(true); redraw()
  local e=HUMANAI.engine
  local order={'tab_home','tab_settings','tab_rules','tab_diagnostic'}
  for k,id in ipairs(order) do
   local r=HOST.hits['##aai_'..id]; assert(r,'tab drawn: '..id)
   if k>1 then local q=HOST.hits['##aai_'..order[k-1]]; assert(q.x+q.w<=r.x+1e-6 and math.abs(q.y-r.y)<1e-6,'tab order: '..id) end
  end
  assert(drawnText(L.tabs.rules) and L.tabs.rules=='RACING RULES','tab named')
  go('settings'); redraw(); assert(drawn('cat_accidents') and drawn('cat_endurance') and not drawn('cat_rules'),'Rules no longer listed in Settings')
  -- Profil Course (règles de base à la première installation) : interrupteur allumé, jeux de règles, réglages.
  go('home'); press('profile_C'); go('rules'); redraw()
  assert(lit('section_rules') and drawn('rules_F1') and drawn('rules_Endurance') and drawn('set_neutralization') and not drawn('set_mandatoryStops'),'rules tab content')
  assert(drawnText(L.groups.rules) and lit('profile_C') and lit('rules_base'),'title, profile shown, rule set recognised')
  -- Interrupteur : coupe les règles du profil affiché seulement, enregistré ; réglages masqués, jeux de règles visibles.
  press('section_rules'); redraw()
  assert(not e.profiles.C.section_rules and e.profiles.Q.section_rules and HOST.storage['humanai:p:C:'].section_rules==false,'rules off for the profile shown only')
  assert(not drawn('set_neutralization') and drawn('rules_F1') and not lit('section_rules'),'settings hidden, rule sets still offered')
  press('section_rules'); assert(e.profiles.C.section_rules,'rules on again')
  -- Jeu de règles choisi dans l'onglet : appliqué aux Essais, Qualifications et Course.
  press('rules_F1'); redraw()
  assert(lit('rules_F1') and C.ruleCategory('C',e.profiles.C)=='F1' and C.ruleCategory('P',e.profiles.P)=='F1' and C.ruleCategory('Q',e.profiles.Q)=='F1','F1 rule set applied')
  press('set_neutralization'); assert(e.profiles.C.neutralization~='vsc' and e.profiles.C.configured,'setting edited from the rules tab')
  -- En français : nom de l'onglet.
  press('lang_fr'); redraw(); assert(drawnText('RÈGLES DE COURSE'),'French tab name')
  HOST.space={x=1000,y=780}; pause(false); HUMANAI.release()
 end)
 -- Beta 1.18 : interrupteurs Arrêt obligatoire en course et Voiture de sécurité sous celui des règles ; chaque jeu de
 -- règles les règle, ils agissent sur les Essais, Qualifications et Course ensemble et montrent l'état du profil Course.
 check('Beta 1.18 : arrêt obligatoire et voiture de sécurité dans l onglet Règles de course',function()
  HUMANAI.release(); HOST=H.create(true); HOST.space={x=1000,y=3000}; assert(loadstring(source))(); H.tick(HOST,0.5); pause(true)
  local e=HUMANAI.engine; local P=e.profiles
  go('home'); press('profile_C'); go('rules'); redraw()
  assert(drawn('mandatory_stop') and drawn('safety_switch') and not lit('mandatory_stop') and lit('safety_switch'),'base rules: no mandatory stop, safety car on by default')
  local function both(name,stops,safety)
   press('rules_'..name); redraw()
   assert(lit('mandatory_stop')==stops and lit('safety_switch')==safety,name..': switches set by the rule set')
   for _,x in ipairs(C.ruleProfiles) do assert((P[x].mandatoryStops>0)==stops and P[x].safetyCarEscalation==safety,name..' '..x) end
  end
  both('F1',true,true); both('Endurance',false,true); both('GT',true,true); both('base',false,true); both('F1_2026',true,true)
  press('mandatory_stop'); redraw()
  assert(not lit('mandatory_stop') and P.C.mandatoryStops==0 and P.P.mandatoryStops==0 and P.Q.mandatoryStops==0 and lit('rules_F1_2026'),'mandatory stop off, rule set still highlighted')
  assert(HOST.storage['humanai:p:C:'].mandatoryStops==0,'saved')
  press('mandatory_stop'); redraw(); assert(lit('mandatory_stop') and P.C.mandatoryStops==1 and lit('rules_F1_2026'),'mandatory stop on again, rules recognised')
  press('safety_switch'); redraw(); assert(not lit('safety_switch') and not P.C.safetyCarEscalation and not P.Q.safetyCarEscalation,'safety car off')
  press('safety_switch'); redraw(); assert(lit('safety_switch') and P.C.safetyCarEscalation and HOST.storage['humanai:p:Q:'].safetyCarEscalation==true,'safety car on again')
  local function shown(note) for _,t in ipairs(HOST.drawnTexts) do if #t>15 and note:find(t,1,true)==1 then return true end end return false end
  local function noted() return shown(L.safetySwitchNoCar) end
  assert(e.g.safetyCarModel=='ferrari_458_s3' and not noted(),'Ferrari 458 Italia Stage 3 by default')
  e.g.safetyCarModel=''; redraw(); assert(noted(),'no safety car chosen: warning')
  press('rules_view_safety'); redraw(); assert(drawnText(L.safetyHeading),'picker under the Safety Car title'); press('rules_view_all')
  e.g.safetyCarModel='sc_car'; redraw(); assert(not noted(),'warning gone once a car is chosen')
  P.Q.mandatoryStops=0; go('home'); press('profile_Q'); go('rules'); redraw(); assert(lit('mandatory_stop') and lit('profile_Q'),'race profile state shown')
  -- Interrupteur allumé avec la zone jaune locale : rien à faire escalader, dit clairement ; neutralisation « Voiture
  -- de sécurité » choisie : elle sort de toute façon, dit aussi.
  press('rules_base'); redraw()
  assert(lit('safety_switch') and P.C.neutralization=='local' and lit('rules_base') and not noted(),'base rules with the safety car: still highlighted, no warning')
  P.C.neutralization='sc'; press('safety_switch'); redraw(); assert(not lit('safety_switch') and shown(L.safetySwitchDirect),'safety car chosen as the neutralisation: used anyway')
  e.g.safetyCarModel=''; redraw(); assert(noted() and not shown(L.safetySwitchDirect),'safety car neutralisation without a car: warning first')
  -- Fenêtre basse : la colonne de gauche défile à la molette jusqu'au dernier jeu de règles.
  go('home'); press('profile_J'); go('rules'); HOST.space={x=1000,y=420}; redraw(); assert(drawn('section_rules') and not drawn('rules_Endurance'),'low window: last rule set below')
  local r=HOST.hits['##aai_section_rules']; HOST.mouse={x=r.x+5,y=r.y+5}
  for _=1,10 do HOST.wheel=-1; main() end
  redraw(); assert(drawn('rules_Endurance'),'reached with the wheel'); HOST.mouse={x=-1e6,y=-1e6}
  HOST.space={x=1000,y=780}; pause(false); HUMANAI.release()
 end)
 -- Beta 1.19 : titres des lignes de gauche de l'onglet Règles de course : affichent leurs réglages sans rien changer ;
 -- arrêts aux stands et voiture de sécurité seulement sous leur titre ; interrupteurs indépendants des jeux de règles
 -- (le jeu reste surligné) ; réinitialisation au jeu surligné, ou au plus proche d'un jeu retouché.
 check('Beta 1.19 : titres des interrupteurs, réglages à part, surbrillance gardée, réinitialisation',function()
  HUMANAI.release(); HOST=H.create(true); HOST.space={x=1000,y=3000}; assert(loadstring(source))(); H.tick(HOST,0.5); pause(true)
  local e=HUMANAI.engine; local P=e.profiles
  go('home'); press('profile_C'); go('rules'); redraw()
  assert(lit('rules_view_all') and drawn('set_neutralization') and drawn('set_redFlagEnabled') and not drawn('set_mandatoryStops') and not drawn('set_pitFuel')
   and not drawn('set_safetyCarEscalation') and not drawn('set_safetyCarSpeedKmh') and not drawnText(L.safetyHeading),'main view without pit stops and safety car')
  local stops,safety,rules=P.C.mandatoryStops,P.C.safetyCarEscalation,P.C.section_rules
  press('rules_view_stops'); redraw()
  assert(P.C.mandatoryStops==stops and lit('rules_view_stops') and not lit('rules_view_all') and drawn('set_mandatoryStops') and drawn('set_pitWindowOpenPct')
   and drawn('set_pitFuel') and drawn('set_pitRepair') and not drawn('set_neutralization') and not drawn('set_safetyCarEscalation'),'pit stop title: its settings only, switch unchanged')
  press('rules_view_safety'); redraw()
  assert(P.C.safetyCarEscalation==safety and lit('rules_view_safety') and drawn('set_safetyCarEscalation') and drawn('set_safetyCarSpeedKmh') and drawnText(L.safetyHeading)
   and not drawn('set_mandatoryStops') and not drawn('set_neutralization'),'safety car title: its settings and the picker, switch unchanged')
  press('rules_view_all'); redraw(); assert(P.C.section_rules==rules and lit('rules_view_all'),'rules title: nothing switched')
  press('mandatory_stop'); press('safety_switch'); redraw()
  assert(P.C.mandatoryStops==1 and not P.C.safetyCarEscalation and lit('rules_base') and lit('mandatory_stop') and not lit('safety_switch'),'base rules still highlighted, stop added, safety car removed')
  press('rules_reset'); redraw()
  assert(P.C.mandatoryStops==0 and P.C.safetyCarEscalation and P.Q.mandatoryStops==0 and lit('rules_base') and lit('safety_switch'),'reset to the base rules')
  press('rules_F1'); P.C.pitWindowOpenPct=30; P.C.mandatoryStops=0; redraw(); assert(not lit('rules_F1'),'F1 edited on the right: custom')
  press('rules_reset'); redraw()
  assert(lit('rules_F1') and P.C.pitWindowOpenPct==20 and P.C.mandatoryStops==1 and P.C.safetyCarEscalation,'reset to the closest rule set')
  -- Journée circuit affichée : les vues Arrêt obligatoire et Voiture de sécurité règlent le profil Course.
  go('home'); press('profile_J'); go('rules'); press('rules_view_stops'); redraw()
  local race,track=P.C.mandatoryStops,P.J.mandatoryStops
  assert(lit('profile_J') and drawn('set_mandatoryStops'),'race pit stop settings shown from the track day')
  press('set_mandatoryStops_plus'); assert(P.C.mandatoryStops==race+1 and P.J.mandatoryStops==track,'race profile edited, track day untouched')
  press('rules_view_safety'); redraw(); local before=P.C.safetyCarEscalation; press('set_safetyCarEscalation')
  assert(P.C.safetyCarEscalation==not before and not P.J.safetyCarEscalation,'race safety car edited from the track day')
  HOST.space={x=1000,y=780}; pause(false); HUMANAI.release()
  -- En course : voiture de sécurité absente de la grille signalée ; ajoutée, l'avertissement disparaît.
  HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))(); H.tick(HOST,1); pause(true); go('rules'); redraw()
  local function shown(note) for _,t in ipairs(HOST.drawnTexts) do if #t>15 and note:find(t,1,true)==1 then return true end end return false end
  assert(HUMANAI.engine.profile=='C' and HUMANAI.engine.g.safetyCarModel=='ferrari_458_s3' and shown(L.safetySwitchNotOnGrid),'race: default safety car missing from the grid')
  pause(false); HUMANAI.release()
  HOST=H.create(true); HOST.sim.raceSessionType=3; ac.getCarID=function(index) return index==3 and 'ferrari_458_s3' or 'model_'..index end
  assert(loadstring(source))(); H.tick(HOST,2); pause(true); go('rules'); redraw()
  assert(HUMANAI.engine.incidents.safety==4 and not shown(L.safetySwitchNotOnGrid),'on the grid: no warning')
  pause(false); HUMANAI.release()
 end)
 -- Beta 1.20, 1.22 : journée circuit : aucune IA garée ni retenue au début de la session (Content Manager place les IA
 -- en piste après le chargement ; l'attente écrite au stand par la Beta 1.21 les arrêtait en piste) ; course : IA
 -- endommagée à son emplacement, carrosserie, suspensions et moteur réparés une fois par passage, retenue le temps de
 -- la réparation.
 check('Beta 1.22 : aucune IA retenue en début de journée circuit, réparations aux arrêts en course',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.currentSessionTime=5000
  for i=1,3 do HOST.cars[i].isInPit=true; HOST.cars[i].isInPitlane=true; HOST.cars[i].speedKmh=0; HOST.cars[i].velocity={x=0,y=0,z=0} end
  -- Journée circuit réglée (préréglage Nordschleife, onglet Espacement compris) ; une installation neuve la laisse sans commande.
  assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Nordschleife','J',e.profiles.J); E.changed(e); H.tick(HOST,1)
  assert(e.profile=='J' and e.run.section_traffic,'track day with Espacement')
  for i=1,3 do assert(not HOST.parked[i] and not HOST.startDelays[i] and (HOST.stops[i] or 0)==0,'AI in its box left to AC: '..i) end
  -- Placées en piste par Content Manager : ni garées, ni retenues, ni freinées.
  for i=1,3 do local car=HOST.cars[i]; car.isInPit=false; car.isInPitlane=false; car.speedKmh=108; car.velocity={x=0,z=30} end
  H.tick(HOST,3)
  assert(HOST.startDelayWrites==0 and not HOST.parked[1] and not HOST.parked[2] and not HOST.parked[3],'on track: never parked nor held')
  HUMANAI.release()
  HOST=H.create(true); HOST.sim.raceSessionType=3
  local car=HOST.cars[2]; car.isInPit=true; car.isInPitlane=true; car.speedKmh=0; car.velocity={x=0,y=0,z=0}
  car.damage={[0]=40,[1]=20,[2]=0,[3]=0,[4]=0}; car.suspensionDamage={[0]=0.3,[1]=0,[2]=0,[3]=0}; car.engineLifeLeft=700
  assert(loadstring(source))(); H.tick(HOST,1)
  e=HUMANAI.engine; assert(e.profile=='C' and e.run.pitRepair,'race, repairs on by default')
  assert(HOST.bodyRepairs[2]==1 and HOST.suspensionRepairs[2]==1 and HOST.engineRepairs[2]==1,'bodywork, suspension and engine repaired')
  assert(HOST.stops[2] and HOST.stops[2]>0 and e.commands[3].pitHold and e.commands[3].pitRepair,'held in the box for the repair (engine slot 3: index 2)')
  assert(e.traffic.exits.count==0,'no staggered exit in the race')
  -- Dégâts encore lus après la réparation (lecture en retard) : pas de nouvelle écriture pendant le même arrêt.
  car.damage={[0]=40,[1]=20,[2]=0,[3]=0,[4]=0}; car.engineLifeLeft=700
  H.tick(HOST,2); assert(HOST.bodyRepairs[2]==1 and HOST.engineRepairs[2]==1,'once per visit, even with the damage still read')
  -- Beta 1.23 : usure lue à l'entrée, plus rien à réparer à l'arrêt (AC l'a fait) : ni écriture ni ligne au journal.
  local worn=HOST.cars[3]; worn.isInPit=true; worn.isInPitlane=true; worn.speedKmh=20; worn.engineLifeLeft=900; H.tick(HOST,0.2)
  assert(e.commands[4].pitRepair,'repair planned at the box entry')
  worn.engineLifeLeft=1000; worn.speedKmh=0; worn.velocity={x=0,y=0,z=0}; H.tick(HOST,1)
  local noted=false; for k=1,e.log.limit do local r=e.log[k]; if r and r.message and r.message:find('reparations:',1,true) and r.index==4 then noted=true end end
  assert(not HOST.engineRepairs[3] and not noted,'nothing left to repair at the stop: no write, no journal line')
  -- Champ de dégâts absent (autre version de CSP) : la voiture reste lue, sans réparation.
  local other=HOST.cars[3]; other.isInPit=true; other.isInPitlane=true; other.speedKmh=0; other.velocity={x=0,y=0,z=0}
  setmetatable(other,{__index=function(_,k) if k=='damage' or k=='suspensionDamage' or k=='engineLifeLeft' then error('no member named '..k) end end})
  local errors=e.frame.errors; H.tick(HOST,1)
  assert(e.frame.cars[4].valid and e.frame.cars[4].inPitBox and e.frame.errors==errors and not HOST.bodyRepairs[3],'missing damage fields: car still read, nothing repaired')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 -- Beta 1.22 : voiture de sécurité garée : ramenée à son stand chaque fois qu'elle en sort (garée sans pilote, une IA peut
 -- quitter son emplacement ; Content Manager place les voitures en piste en journée circuit), au plus toutes les 10 s.
 check('Beta 1.22 : voiture de sécurité ramenée à son stand chaque fois qu elle en sort',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=1
  ac.getCarID=function(index) return index==2 and 'sc_model' or 'model_'..index end
  assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Nordschleife','J',e.profiles.J)
  e.g.safetyCarModel='sc_model'; e.g.safetyCarPicked=true; E.changed(e); H.tick(HOST,2)
  local car=HOST.cars[2]
  assert(e.incidents.safety==3 and HOST.parked[2] and HOST.teleports==1 and car.isInPit,'parked, brought back once from the track')
  car.isInPit=false; car.isInPitlane=false; car.speedKmh=8; car.velocity={x=0,z=2}
  H.tick(HOST,3); assert(HOST.teleports==1,'not before the return period')
  H.tick(HOST,9); assert(HOST.teleports==2 and car.isInPit and HOST.parked[2],'brought back again when it leaves its box')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 -- Beta 1.22 : qualifications avec beaucoup de voitures (seuil abaissé pour les 3 IA du banc) : attente native écrite une
 -- fois, jamais de mise en état garé ; voiture déplacée avant son tour : attente annulée (0) ; déchargement : attentes
 -- encore en cours annulées.
 check('Beta 1.22 : sorties des stands étalées en essais et qualifications, attente annulée hors de l emplacement',function()
  local minimum=C.K.pitExitMinCars; C.K.pitExitMinCars=3
  local ok,err=pcall(function()
   HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=2; HOST.sim.currentSessionTime=5000
   for i=1,3 do local car=HOST.cars[i]; car.isInPit=true; car.isInPitlane=true; car.speedKmh=0; car.velocity={x=0,y=0,z=0} end
   assert(loadstring(source))(); local e=HUMANAI.engine; C.preset('Qualifications','Q',e.profiles.Q); e.profiles.Q.spawnMinCars=3; E.changed(e); H.tick(HOST,1)
   local x=e.traffic.exits
   assert(e.profile=='Q' and x.count==3,'qualifying: every AI in its box waits its turn ('..x.count..')')
   local waiting=0
   for i=1,3 do if (HOST.startDelays[i] or 0)>0 then waiting=waiting+1 end; assert(not HOST.parked[i] and (HOST.stops[i] or 0)==0,'never parked nor braked: '..i) end
   assert(waiting>=2,'native wait written ('..waiting..')')
   local writes=HOST.startDelayWrites; H.tick(HOST,1); assert(HOST.startDelayWrites==writes,'written once')
   local late; for i=1,3 do if x.releaseAt[i+1]-e.time>5 then late=i end end
   assert(late,'a car still waiting')
   HOST.cars[late].isInPit=false; HOST.cars[late].isInPitlane=false; H.tick(HOST,0.5)
   assert(HOST.startDelays[late]==0,'left early: wait cancelled')
   HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
   for i=1,3 do assert(not HOST.cars[i].isInPit or (HOST.startDelays[i] or 0)==0,'unload: pending wait cancelled: '..i) end
  end)
  C.K.pitExitMinCars=minimum
  if not ok then error(err,0) end
 end)
 -- Beta 1.24 : réinitialisation de chaque section des réglages : valeurs par défaut du profil affiché, préférences du
 -- pilote et motifs de classes gardés, autres sections intactes ; options globales de l'onglet seulement (sens latéral
 -- mesuré et voiture de sécurité gardés). Gommes sèches principales lues (une par nom court).
 check('Beta 1.24 : réinitialisation de chaque section des réglages',function()
  HUMANAI.release(); HOST=H.create(true); HOST.space={x=1000,y=3000}
  HOST.tyreCatalog[2]={{short='H',name='Origine dure'},{short='M',name='Origine medium'},{short='S',name='Origine tendre'},{short='SS',name='Origine super tendre'},
   {short='H',name='F1 dure'},{short='M',name='F1 medium'},{short='S',name='F1 tendre'},{short='SS',name='F1 super tendre'},{short='I',name='Intermediaire'},{short='W',name='Pluie'}}
  assert(loadstring(source))(); H.tick(HOST,0.5); pause(true)
  local e=HUMANAI.engine; local P=e.profiles
  local car=e.frame.cars[3]
  assert(car.dryPrimary and #car.dryPrimary==4 and car.dryPrimary[1]==0 and car.dryPrimary[4]==3 and #car.dryList==8 and car.interCompound==8 and car.wetCompound==9,'first of each dry name only')
  go('home'); press('profile_C'); section('general')
  local d=C.defaults('C'); P.C.levelPct=70; P.C.aggressionPct=20; redraw()
  press('reset_general'); assert(P.C.levelPct==d.levelPct and P.C.aggressionPct==d.aggressionPct,'general reset to the profile defaults')
  section('accidents'); P.C.yellowHud=not d.yellowHud; P.C.obstacleDetect=60; redraw(); press('reset_accidents')
  assert(P.C.obstacleDetect==d.obstacleDetect and P.C.yellowHud==not d.yellowHud,'accidents reset, display preference kept')
  section('endurance'); P.C.classPatterns='car_2:1'; P.C.classGapPct=20; redraw(); press('reset_endurance')
  assert(P.C.classGapPct==d.classGapPct and P.C.classPatterns=='car_2:1','endurance reset, class patterns kept')
  P.C.levelPct=70; section('lateral'); redraw(); press('reset_lateral'); assert(P.C.levelPct==70,'only the section shown')
  section('globals'); e.g.useBrakeAssist=false; e.g.debugLog=true; e.g.offsetSign=-1; e.g.safetyCarModel='sc_x'; redraw(); press('reset_globals')
  assert(e.g.useBrakeAssist and not e.g.debugLog and e.g.offsetSign==-1 and e.g.safetyCarModel=='sc_x','globals reset, measured direction and safety car kept')
  pause(false); HUMANAI.release()
 end)
 -- Beta 1.25 : voiture de sécurité libérée encore à son emplacement (en course, elle n'en sortait jamais seule) :
 -- réveillée, départ immédiat et aucun freinage forcé, à intervalles, tant qu'elle y reste ; rien une fois sortie, ni
 -- tant qu'elle est garée.
 check('Beta 1.25 : voiture de sécurité libérée relancée hors de son emplacement',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3
  ac.getCarID=function(index) return index==3 and 'sc_model' or 'model_'..index end
  assert(loadstring(source))(); local e=HUMANAI.engine
  C.preset('Course','C',e.profiles.C); e.profiles.C.neutralization='sc'; e.g.safetyCarModel='sc_model'; e.g.safetyCarPicked=true; E.changed(e); H.tick(HOST,3)
  local car=HOST.cars[3]; car.isInPit=true; car.isInPitlane=true; car.speedKmh=0; car.velocity={x=0,z=0}; H.tick(HOST,2)
  assert(e.incidents.safety==4 and HOST.parked[3] and (HOST.awakes[3] or 0)==0,'parked: never woken')
  local t=e.incidents
  t.neutral=true; t.neutralMode='sc'; t.safetyPhase='out'; t.safetyLeft=false; t.neutralSince=e.time; t.neutralUntil=e.time+1e6; t.safetySince=e.time
  HOST.startDelays[3]=nil; HOST.stops[3]=nil; HOST.pitRequests[3]=nil; H.tick(HOST,0.5)
  assert(not HOST.parked[3] and (HOST.awakes[3] or 0)==1 and HOST.startDelays[3]==0 and HOST.stops[3]==0 and HOST.pitRequests[3]==false,'released: woken, start now, no brake, no pit request')
  H.tick(HOST,4.6); local woken=HOST.awakes[3]
  assert(woken>=3 and woken<=4,'repeated while still in its box ('..woken..')')
  car.isInPit=false; car.isInPitlane=true; H.tick(HOST,0.5)
  local found=false
  for k=1,e.log.limit do local r=e.log[k]; if r and r.message and r.message:find('voiture de securite: sortie de son stand apres',1,true) then found=true end end
  H.tick(HOST,5); assert(HOST.awakes[3]==woken and found,'out of its box: no more calls, exit logged')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 -- Beta 1.25 : overlay en jeu comme ceux de SuperHUD : fenêtre transparente centrée en haut, verrouillée (clics
 -- traversants) ; déverrouillée : glisser, coin pour la taille, clic droit pour verrouiller ; masquée en rediffusion ;
 -- case de session d'AC remplacée puis rendue ; messages d'AC repris, notés, masqués sur demande, tout rendu au
 -- déchargement.
 check('Beta 1.25 : overlay en jeu, position, verrou, taille, case de session et messages d AC',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.raceSessionType=3; assert(loadstring(source))()
  local e=HUMANAI.engine; local g=e.g; C.preset('Course','C',e.profiles.C); E.changed(e); H.tick(HOST,1)
  g.panelShow='always'
  HOST.transparent={}; script.HUMANAI__HUD()
  local w=HOST.transparent.ACAdvancedIA_overlay
  assert(w and math.abs(w.x-(1920-600)/2)<1e-6 and math.abs(w.y-1080*C.K.hudTop)<1e-6 and w.w==600 and not w.inputs,'centred at the top, locked, click-through')
  assert(HOST.hudHidden.sessionTime==true,'AC session box replaced by the session line')
  g.overlayLocked=false; script.HUMANAI__HUD(); w=HOST.transparent.ACAdvancedIA_overlay; assert(w.inputs,'unlocked: takes the mouse')
  HOST.mouseDelta={x=100,y=40}; HOST.drags['##aai_overlay_move']=0.5; script.HUMANAI__HUD()
  assert(math.abs(g.overlayX-(w.x+100))<1e-6 and math.abs(g.overlayY-(w.y+40))<1e-6,'dragged')
  HOST.mouseDelta={x=0,y=0}; script.HUMANAI__HUD()
  HOST.mouseDelta={x=60,y=0}; HOST.drags['##aai_overlay_size']=0.5; script.HUMANAI__HUD()
  assert(math.abs(g.overlayScale-1.1)<1e-6,'resized by its corner ('..g.overlayScale..')')
  HOST.mouseDelta={x=0,y=0}; script.HUMANAI__HUD()
  w=HOST.transparent.ACAdvancedIA_overlay; assert(math.abs(w.w-660)<1e-6,'drawn at the new size')
  HOST.mouse={x=10,y=10}; HOST.rightClick='##aai_overlay_move'; script.HUMANAI__HUD(); HOST.mouse={x=-1e6,y=-1e6}
  assert(g.overlayLocked,'right-click locks')
  g.overlayClickThrough=false; HOST.windowHovered=true; HOST.rightClick=nil
  HOST.mouseClickedAny=true
  g.overlayClickThrough=true; HOST.windowHovered=false
  HOST.sim.isReplayActive=true; H.tick(HOST,0.2); HOST.transparent={}; script.HUMANAI__HUD()
  assert(not HOST.transparent.ACAdvancedIA_overlay and HOST.hudHidden.sessionTime==false,'replay: hidden, AC box back')
  HOST.sim.isReplayActive=false; H.tick(HOST,0.2); HOST.transparent={}; script.HUMANAI__HUD()
  assert(HOST.transparent.ACAdvancedIA_overlay and HOST.hudHidden.sessionTime==true,'back after the replay')
  assert(#HOST.messageListeners==1,'AC messages listened to')
  HOST.messageListeners[1]('ABS','3',nil,5); H.tick(HOST,0.3)
  assert(e.hud.msgText=='ABS · 3' and e.time<e.hud.msgUntil,'AC message on the session line')
  local found=false; for k=1,e.log.limit do local r=e.log[k]; if r and r.message and r.message:find('message d AC: ABS : 3',1,true) then found=true end end
  assert(found,'new AC message title logged')
  HOST.draws=0; HOST.drawnTexts={}; script.HUMANAI__HUD()
  local shown=false; for _,t in ipairs(HOST.drawnTexts) do if t=='ABS · 3' then shown=true end end
  assert(shown or HOST.draws>0,'message drawn')
  assert(HOST.blocked==1,'Beta 1.26: original AC messages hidden by default')
  local probed=false; for k=1,e.log.limit do local r=e.log[k]; if r and r.message and r.message:find('affichage d origine masque',1,true) then probed=true end end
  assert(probed and e.hud.msgText=='ABS · 3','probe received, never shown on the overlay')
  g.overlayBlockMessages=false; script.HUMANAI__HUD(); assert(HOST.blocked==0,'shown on request')
  g.overlayBlockMessages=true; script.HUMANAI__HUD(); assert(HOST.blocked==1,'hidden again')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
  assert(HOST.blocked==0 and #HOST.messageListeners==0 and HOST.hudHidden.sessionTime==false,'everything restored on unload')
 end)
 -- Beta 1.26 : journée circuit, IA à leur emplacement réparties sur tout le circuit : posées une fois sur la trajectoire
 -- de l'IA, dans le sens de la piste, lancées ; jamais le joueur ; plus rien une fois en piste.
 check('Beta 1.26 : journée circuit, IA réparties sur tout le circuit',function()
  HUMANAI.release(); HOST=H.create(true); HOST.sim.currentSessionTime=300; HOST.files['cfgext\\new_behaviour.ini']='[AI_FLOOD]\r\nENABLED=0\r\n'
  for i=1,3 do local car=HOST.cars[i]; car.isInPit=true; car.isInPitlane=true; car.speedKmh=0; car.velocity={x=0,y=0,z=0} end
  assert(loadstring(source))(); local e=HUMANAI.engine
  e.profiles.J.section_traffic=true; e.profiles.J.section_general=true; e.profiles.J.spawnMinCars=3; e.profiles.J.spawnPitPct=0; E.changed(e); H.tick(HOST,0.1); e.traffic.exits.session=-99
  H.tick(HOST,0.4)
  local x=e.traffic.exits
  local fr=HUMANAI.frame or {}
  assert(e.profile=='J' and x.mode=='track' and x.count==3,'track day: 3 AI spread ('..tostring(x.mode)..', '..x.count..', guard '..tostring(e.guard)..', profile '..tostring(e.profile)..', flood '..tostring(e.flood.loaded)..', session '..tostring(x.session)..', draws '..tostring(x.draws)..', time '..tostring(x.time)..', mode '..tostring(e.run.spawnMode)..', min '..tostring(e.run.spawnMinCars)..')')
  H.tick(HOST,1.5)
  for i=1,3 do
   local p=HOST.positions[i]; local v=HOST.velocities[i]
   assert(p and v,'placed and launched: '..i)
   assert(p.dir==nil and math.abs(v.z-C.K.spreadSpeed/3.6)<1e-9 and math.abs(v.x)<1e-9,'aligned by CSP, launched along the car, '..C.K.spreadSpeed..' km/h: '..i)
  end
  assert(not HOST.positions[0],'never the player')
  assert(HOST.startDelays[1]==0 and HOST.startDelays[2]==0 and HOST.startDelays[3]==0,'native wait cancelled first')
  assert(x.placed==3,'all three at their place ('..x.placed..')')
  local writes=HOST.positionWrites; H.tick(HOST,3); assert(HOST.positionWrites==writes,'at their place: no more placement')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 -- Beta 1.26 : masquage qui retirerait aussi les messages à l'overlay : levé jusqu'au prochain lancement, journalisé.
 check('Beta 1.26 : masquage des messages d AC levé si l overlay ne les reçoit plus',function()
  HUMANAI.release(); HOST=H.create(true); HOST.blockSwallows=true; assert(loadstring(source))(); H.tick(HOST,0.5)
  local e=HUMANAI.engine
  script.HUMANAI__HUD(); assert(HOST.blocked==1,'hidden at first')
  for _=1,C.K.probeFrames+1 do script.HUMANAI__HUD() end
  assert(HOST.blocked==0,'lifted: the overlay no longer receives them')
  local warned=false; for k=1,e.log.limit do local r=e.log[k]; if r and r.message and r.message:find('masquage leve',1,true) then warned=true end end
  assert(warned,'logged')
  script.HUMANAI__HUD(); assert(HOST.blocked==0,'not hidden again until the next launch')
  HOST.releasing=true; HUMANAI.release(); HOST.releasing=false
 end)
 -- Beta 1.25 : section Overlay des réglages : verrou, fond (opaque, atténué, transparent), contenu, replacer, réinitialiser.
 check('Beta 1.25 : section Overlay des réglages',function()
  HUMANAI.release(); HOST=H.create(true); HOST.space={x=1000,y=3000}; assert(loadstring(source))(); H.tick(HOST,0.5); pause(true)
  local g=HUMANAI.engine.g
  section('overlay')
  assert(drawn('overlay_lock') and drawn('overlay_scale') and drawn('overlay_background') and drawn('panel_opacity') and drawn('overlay_content') and drawn('overlay_overlaySession') and drawn('overlay_overlayBlockMessages'),'overlay settings drawn')
  assert(not drawn('section_overlay'),'no profile switch: shared by every session')
  press('overlay_lock'); assert(not g.overlayLocked,'unlocked from the settings')
  press('overlay_background'); assert(g.overlayBackground=='ghost'); press('overlay_background'); assert(g.overlayBackground=='transparent')
  press('overlay_overlayExplain'); assert(not g.overlayExplain)
  g.overlayX=300; g.overlayY=200; g.overlayScale=1.6; redraw(); press('overlay_recenter'); assert(g.overlayX==-1 and g.overlayY==-1 and g.overlayScale==1,'put back on screen')
  g.overlayContent=50; g.panelOpacity=20; g.offsetSign=-1; redraw(); press('reset_overlay')
  assert(g.overlayLocked and g.overlayBackground=='solid' and g.overlayExplain and g.overlayContent==100 and g.panelOpacity==C.globalDefaults.panelOpacity and g.offsetSign==-1,'overlay reset, nothing else')
  pause(false); HUMANAI.release()
 end)
 return results
end
