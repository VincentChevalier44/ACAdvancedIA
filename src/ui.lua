local C=require('src/config')
local L=require('src/lang')
local U=require('src/util')
local Flash=require('src/flash')
local Zones=require('src/zones')
local Engine=require('src/engine')
local Caps=require('src/caps')
local Adapter=require('src/applier')
local callable=Adapter.callable
local Presets=require('src/presets')
local Panel=require('src/panel')
local Snapshot=require('src/snapshot')
local T=require('src/tips')
local W=require('src/widgets')
local Locale=require('src/locale')
local K=C.K
local M={}
-- Infobulles préparées une seule fois par langue : lignes coupées à la main (setTooltip ne coupe pas les lignes),
-- séparateur décimal de la langue, valeur par défaut du profil ; aucun texte n'est construit pendant le dessin.
local function wrap(source) return U.wrapText(source,K.uiTipWidth) end
M.wrap=wrap
local function number(value)
 local text=string.format('%.3f',value):gsub('0+$',''):gsub('%.$','')
 return (text:gsub('%.',L.decimalMark))
end
local function shown(s,value)
 if s.choices then return L.choices[value] or tostring(value) end
 if type(value)=='boolean' then return value and L.tipOn or L.tipOff end
 return number(value)
end
local function wrapAll(source) local out={}; for key,text in pairs(source) do out[key]=wrap(text) end; return out end
local function globalTips()
 local out={}
 for key,text in pairs(T.globals) do
  local default=C.globalDefaults[key]; local bounds=C.globalBounds[key]; local value
  if key=='levelMode' then for j,x in ipairs(C.globalChoices.levelMode) do if x==default then value=L.levelModeLabels[j] end end
  elseif type(default)=='boolean' then value=default and L.tipOn or L.tipOff
  elseif type(default)=='string' then value=L.choices[default] or default
  else value=number(default)..(bounds and string.format(L.tipRange,number(bounds[1]),number(bounds[2])) or '') end
  out[key]=wrap(text..'\n\n'..string.format(L.tipGlobalDefault,value))
 end
 return out
end
-- Vues de l'onglet Règles de course (Beta 1.19) : les arrêts aux stands et la voiture de sécurité n'apparaissent que
-- sous le titre de leur interrupteur ; « Règles de course actives » montre tout le reste des règles.
local ruleViews={stops={mandatoryStops=true,pitWindowOpenPct=true,pitWindowClosePct=true,pitTyres=true,pitRepair=true,pitCompoundChange=true,minPitTime=true,maxStintMin=true,pitFuel=true,pitsClosed=true,pitMessage=true},
 safety={safetyCarSpeedKmh=true,safetyCarEscalation=true}}
-- Interrupteurs indépendants des jeux de règles (Beta 1.19) : le jeu choisi reste surligné quand on les change.
local switchKeys={mandatoryStops=true,safetyCarEscalation=true}
local function ruleView(key) for name,keys in pairs(ruleViews) do if keys[key] then return name end end return 'all' end
-- Textes de la fenêtre dans la langue en cours (Beta 1.16) : infobulles, libellés des choix, des motifs et des
-- préréglages intégrés ; refaits au changement de langue, avec les textes mémorisés du panneau de drapeaux.
local function texts(v)
 v.tips={ui=wrapAll(T.ui),tabs=wrapAll(T.tabs),sections=wrapAll(T.sections),profiles=wrapAll(T.profiles),presets=wrapAll(T.presets),rules=wrapAll(T.rules)}
 v.globalTips=globalTips(); v.customTips={}
 for i=1,K.maxPatterns do local r=v.patternRows[i]; r.label=L.patternRow..i; r.classLabel=L.classRow..i end
 for _,controls in pairs(v.controls) do
  for _,control in ipairs(controls) do
   local s=control.schema
   control.id=s.label..'###setting_'..s.key
   local body=wrap(T.settings[s.key] or s.label)
   local range=s.min and string.format(L.tipRange,number(s.min),number(s.max)) or ''
   for _,p in ipairs(C.profiles) do control.hint[p]=body..'\n\n'..wrap(string.format(L.tipDefault,L.profiles[p],shown(s,s.defaults[p]))..range) end
   if s.choices then for j,x in ipairs(s.choices) do control.labels[j]=L.choices[x] or x end end
  end
 end
 v.descriptions={}; for _,group in ipairs(C.sections) do v.descriptions[group]=T.tabs[group] or '' end
 v.descriptions.overlay=T.tabs.overlay or ''
 local function same(profile) return function() return profile end end
 v.builtinList={{L.presetJ,'Nordschleife','J',same('J')},{L.presetP,'Essais','P',same('P')},{L.presetQ,'Qualifications','Q',same('Q')},{L.presetC,'Course','C',same('C')},
  {L.presetE,'Endurance','E',function(view) return (view=='Q' or view=='P') and 'C' or view=='H' and 'J' or view end}}
 v.builtinNames={Nordschleife=L.presetJ,Essais=L.presetP,Qualifications=L.presetQ,Course=L.presetC,Endurance=L.presetE}
 -- Textes mémorisés (préréglage chargé, liste des voitures, version, delta, pastilles, message) : refaits à la
 -- prochaine image.
 v.loadedFor=nil; v.carFilterBuilt=nil; v.panelVersion=nil; v.deltaHundredths=nil; v.giveBackName=nil; v.blueTenths=nil; v.presetMessage=''
end
function M.new(e,host,calibration,dirty)
 local v={e=e,host=host,calibration=calibration,dirty=dirty,open={},controls={},logFilter=1,patternInvalid=false,category='general',keptRules={},
  patternRows={},patternFragments={},patternSource=false,patternProfile='',presetName='',presetMessage='',derived={},signatureValues={},builtinSignatures={},
  builtinConfigs={Nordschleife={J=C.preset('Nordschleife','J',{})},Essais={P=C.preset('Essais','P',{})},Qualifications={Q=C.preset('Qualifications','Q',{})},Course={C=C.preset('Course','C',{})},Endurance={J=C.preset('Endurance','J',{}),C=C.preset('Endurance','C',{})}}}
 for i=1,K.maxPatterns do v.patternRows[i]={pattern='',class=1} end
 for _,s in ipairs(C.schema) do
  local control={schema=s,labels={},hint={}}
  local controls=v.controls[s.group]
  if not controls then controls={}; v.controls[s.group]=controls end
  if s.min then control.step=W.step(s.min,s.max,C.integerKeys[s.key]) end
  controls[#controls+1]=control
 end
 v.tab='home'; v.statusLines={}; v.warnings={}; v.scrolls={}; v.contentHeights={}; v.loadedName=''; v.debugRows={}; v.customActive={}
 v.rulesView='all'; v.ruleLists={all={},stops={},safety={}}
 for _,control in ipairs(v.controls.rules) do local list=v.ruleLists[ruleView(control.schema.key)]; list[#list+1]=control end
 texts(v)
 -- Commandes dessinées : fonctions de dessin et de saisie de CSP requises ; sinon un message remplace la fenêtre.
 v.drawable=true
 for _,name in ipairs({'invisibleButton','itemHovered','itemActive','mouseClicked','mouseDown','mouseLocalPos','mouseWheel','dwriteDrawText','measureDWriteText',
  'pushDWriteFont','popDWriteFont','drawRectFilled','drawLine','drawCircleFilled','pushClipRect','popClipRect','setCursor','getCursor','availableSpace','inputText','setNextItemWidth'}) do
  if not callable(ui[name]) then v.drawable=false end
 end
 return v
end
local function text(value)
 if callable(ui.textWrapped) then ui.textWrapped(value) else ui.text(value) end
end
local function mark(v) Engine.changed(v.e); v.dirty() end
-- Un profil modifié à la main est réglé : aucun préréglage automatique ne le remplacera.
local function touch(v,p) p.configured=true; mark(v) end
local globalSliders={'occLatMin','occLatMax','occMargin','occSpeedGain','gripPerLevelPct'}
-- Profil automatique conservé : le préréglage règle son profil, la détection choisit toujours la session.
local function presetTarget(v,profile)
 if not v.e.g.autoProfile then Engine.select(v.e,profile) end
 v.view=profile; v.viewFor=v.e.profile
 v.presetMessage=v.e.profile~=profile and string.format(L.presetAppliedTo,L.profiles[profile]) or ''
end
-- Les règles de championnat forment un axe indépendant : un préréglage de session les conserve. Endurance
-- multi-classes en course y ajoute les règles Endurance (FCY, Slow Zone, BoP, Pro-Am) pour tout le week-end.
local function loadBuiltin(v,name,profile)
 local e=v.e; local p=e.profiles[profile]; local kept=v.keptRules
 for key in pairs(C.keptKeySet) do kept[key]=C.kept(profile,key) and p[key] or nil end
 C.preset(name,profile,p)
 for key,value in pairs(kept) do p[key]=value end
 C.validate(profile,p,p)
 if name=='Endurance' and profile=='C' then C.applyRules('Endurance',e.profiles) end
 presetTarget(v,profile); v.presetName=''
 e.g.loadedPreset='builtin:'..name; e.g.presetsUsed=true; mark(v)
end
-- Allumé quand le profil visé par le bouton porte ce préréglage (règles de championnat, préférences du pilote et
-- motifs de classes exclus), quel que soit le profil affiché ; seul le profil affiché est annoncé comme reconnu.
local noGlobals={}
local function builtinActive(v,name,profile,label)
 local e=v.e
 local candidate=v.builtinConfigs[name][profile]
 -- Les deux signatures finissent par les mêmes réglages globaux : comparées sans eux ; celle du préréglage intégré
 -- (jamais modifié) est calculée une seule fois.
 local active=false
 if candidate~=nil then
  local key=name..'|'..profile; local expected=v.builtinSignatures[key]
  if not expected then expected=Presets.signature(profile,candidate,noGlobals,v.signatureValues,C.keptKeySet); v.builtinSignatures[key]=expected end
  active=Presets.signature(profile,e.profiles[profile],noGlobals,v.signatureValues,C.keptKeySet)==expected
 end
 if active and profile==v.view then v.activePreset=label end
 return active
end
-- Base des voitures (dossiers content/cars), lue une fois à la demande.
local function carDatabase(v)
 if not v.carList then
  v.carList=Snapshot.carDatabase(); v.carNames={}
  for _,car in ipairs(v.carList) do v.carNames[car.id]=car.label end
 end
 return v.carList
end
-- Fenêtre de réglages : en-tête (état, activation, panique), onglets Accueil, Réglages, Préréglages et Diagnostic.
-- Les commandes sont dessinées (kit src/widgets) ; seules les saisies de texte et la liste des voitures restent natives.
-- Beta 1.17 : les règles de course ont leur propre onglet, entre Réglages et Diagnostic ; la section Règles a quitté la
-- liste de l'onglet Réglages.
local tabs={'home','settings','rules','diagnostic'}
local sidebar={{'drive','general','human','lateral','start'},{'traffic','yield','blue','flash','overtake','traffic'},
 {'race','accidents','endurance','weather'},{'advanced','globals','overlay'}}
-- Choix de la langue (Beta 1.16) : codes affichés, identiques dans les deux langues.
local languageLabels={fr='FR',en='EN'}
-- Saisie de texte native placée dans le canevas (seulement si entièrement visible dans la zone qui défile).
local function input(id,x,y,w,value,tip)
 if not W.visible(y,26) then return value,false end
 ui.setCursor(W.point(x,y)); ui.setNextItemWidth(w*W.frame().s)
 local result,changed=ui.inputText('##aai_'..id,value)
 W.help(tip,x,y,w,26,5)
 return result,changed
end
local function heading(label,x,y) W.text(label,x,y,11,W.colors().grey,true) end
-- Valeur affichée d'un réglage numérique : virgule décimale, entiers sans décimale.
local function valueText(s,value)
 if C.integerKeys[s.key] then return string.format('%.0f',value) end
 return number(value)
end
-- Une commande de réglage (libellé, puis curseur avec -/+, interrupteur ou choix) dans une colonne de 330 px.
-- Clic droit : valeur par défaut du profil affiché.
local function settingControl(v,control,view,p,x,y)
 local c=W.colors(); local s=control.schema; local tip=control.hint[view]
 W.cell(s.label,x,y+2,330,12,c.grey,true)
 W.help(tip,x,y,330,48,4)
 local value,changed,reset=p[s.key],false,false
 if s.min then
  local step=control.step
  local result,right=W.slider('set_'..s.key,x,y+22,270,value,s.min,s.max,step,valueText(s,value),tip)
  if result then value=result; changed=true end
  reset=right
  local minus=W.button('set_'..s.key..'_minus','−',x+276,y+22,26,22,false,tip)
  local plus=W.button('set_'..s.key..'_plus','+',x+304,y+22,26,22,false,tip)
  if minus then value=math.max(s.min,value-step); changed=true elseif plus then value=math.min(s.max,value+step); changed=true end
  if changed and C.integerKeys[s.key] then value=math.floor(value+0.5) end
 elseif s.choices then
  local at=1; for i,x0 in ipairs(s.choices) do if x0==value then at=i; break end end
  local clicked,right=W.button('set_'..s.key,control.labels[at]..'  ▸',x,y+22,330,24,false,tip)
  if clicked then value=s.choices[at%#s.choices+1]; changed=true end
  reset=right
 else
  local clicked,right=W.button('set_'..s.key,value and L.on or L.off,x,y+22,330,24,value==true,tip)
  if clicked then value=not value; changed=true end
  reset=right
 end
 if reset then value=s.defaults[view]; changed=value~=p[s.key] end
 if changed then p[s.key]=value; C.validate(view,p,p); touch(v,p) end
end
-- Bloc des règles de championnat (colonne de gauche de l'onglet Règles de course) : boutons des catégories, les uns
-- sous les autres (appliquées aux Essais, Qualifications et Course), puis l'état.
local function ruleBlock(v,e,p,x,y,w)
 local c=W.colors()
 local target=C.solo(v.view) and 'C' or v.view
 local category=C.ruleCategory(target,e.profiles[target],switchKeys)
 heading(L.ruleSetsHeading,x,y); y=y+20
 y=y+W.paragraph(L.rulePresets,x,y,w,12,c.grey)+6
 for _,name in ipairs(C.ruleCategories) do
  if W.visible(y,30) and W.button('rules_'..name,L.ruleNames[name],x,y,w,30,category==name,v.tips.rules[name]) then
   C.applyRules(name,e.profiles); v.presetMessage=string.format(L.ruleApplied,L.ruleNames[name]); mark(v)
  end
  y=y+36
 end
 local notes={category and L.ruleActive..L.ruleNames[category] or L.ruleCustom}
 if C.solo(v.view) then notes[#notes+1]=L.ruleJ elseif not C.on(p,'rules') then notes[#notes+1]=L.ruleTabOff end
 notes[#notes+1]=L.ruleRaceOnly
 for _,note in ipairs(notes) do y=y+6+W.paragraph(note,x,y+6,w,12,c.grey) end
 return y+6
end
-- Voiture de sécurité : modèle choisi, état sur la grille, saisie du dossier, filtre et liste de la base des voitures.
local function safetyBlock(v,e,x,y)
 local c=W.colors(); local g=e.g
 local list=carDatabase(v)
 heading(L.safetyHeading,x,y); y=y+20
 local status=L.safetyCar..(g.safetyCarModel~='' and (v.carNames[g.safetyCarModel] or g.safetyCarModel) or L.safetyNone)
 if g.safetyCarModel~='' then
  status=status..' — '..(e.incidents.safety>0 and L.safetyFound..L.safetyPhases[e.incidents.safetyPhase] or L.safetyMissing)
  if e.safetyAmbiguous then status=status..'\n'..L.safetyAmbiguous end
  if e.safetyOneMake then status=status..'\n'..L.safetyOneMake end
 end
 y=y+W.paragraph(status,x,y,670,12,c.light)+4
 y=y+W.paragraph(L.safetyHelp,x,y,670,12,c.grey)+6
 W.text(L.safetyModel,x,y+5,12,c.grey); local value,changed=input('safety_model',x+230,y,300,g.safetyCarModel,v.tips.ui.safetyModel)
 if changed and type(value)=='string' and #value<=K.metadataLength and value:match('^[%w_%-%.]*$') then g.safetyCarModel=value; g.safetyCarPicked=true; v.dirty() end
 if g.safetyCarModel~='' and W.visible(y,26) and W.button('safety_clear',L.safetyClearShort,x+540,y,130,26,false,v.tips.ui.safetyClear) then g.safetyCarModel=''; v.dirty() end
 y=y+34
 W.text(L.safetyFilter,x,y+5,12,c.grey); v.carFilter=input('safety_filter',x+230,y,300,v.carFilter or '',v.tips.ui.safetyFilter) or ''
 y=y+34
 -- Liste filtrée par une partie du nom affiché ou du dossier, refaite seulement quand le filtre change.
 local filter=v.carFilter:lower(); local labels=v.carLabels or {}; local ids=v.carIds or {}; v.carLabels=labels; v.carIds=ids
 if v.carFilterBuilt~=filter or labels[1]==nil then
  v.carFilterBuilt=filter; labels[1]=L.safetyPickPrompt; local n=1
  for _,car in ipairs(list) do if filter=='' or car.key:find(filter,1,true) then n=n+1; labels[n]=car.label; ids[n]=car.id end end
  for j=#labels,n+1,-1 do labels[j]=nil; ids[j]=nil end
 end
 if #labels>1 and callable(ui.combo) and W.visible(y,26) then
  ui.setCursor(W.point(x+230,y)); ui.setNextItemWidth(300*W.frame().s)
  local selected,picked=ui.combo('##aai_safety_pick',1,0,labels)
  W.help(v.tips.ui.safetyPick,x+230,y,300,26,5)
  W.text(L.safetyPick,x,y+5,12,c.grey)
  if picked and selected and selected>1 and ids[selected] then g.safetyCarModel=ids[selected]; g.safetyCarPicked=true; v.dirty() end
 end
 return y+36
end
-- Motifs de classes : saisie libre, ou les huit associations motif → classe.
local function patternBlock(v,p,x,y)
 local c=W.colors()
 heading(L.patternsHeading,x,y); y=y+20
 W.text(L.patterns,x,y+5,12,c.grey)
 local value,changed=input('patterns',x+300,y,370,p.classPatterns,v.tips.ui.patterns)
 if changed then local _,valid=C.patterns(value); v.patternInvalid=not valid; if valid then p.classPatterns=value; touch(v,p) end end
 y=y+32
 if v.patternInvalid then W.text(L.patternInvalid,x,y,12,c.warn); y=y+20 end
 if W.visible(y,30) and W.toggle('pattern_rows',L.patternRows,x,y,330,v.open.patternRows==true,v.tips.ui.patternRows) then v.open.patternRows=not v.open.patternRows end
 y=y+38
 if not v.open.patternRows then return y end
 if v.patternSource~=p.classPatterns or v.patternProfile~=v.view then
  local rows=C.patterns(p.classPatterns)
  for i=1,K.maxPatterns do local r=v.patternRows[i]; r.pattern=rows[i] and rows[i].pattern or ''; r.class=rows[i] and rows[i].class or 1 end
  v.patternSource=p.classPatterns; v.patternProfile=v.view
 end
 local edited=false
 for i=1,K.maxPatterns do
  local row=v.patternRows[i]
  W.text(row.label,x,y+5,12,c.grey)
  local text,textChanged=input('pattern_'..i,x+90,y,300,row.pattern,v.tips.ui.patternRow)
  if textChanged then row.pattern=text; edited=true end
  if W.visible(y,26) and W.button('pattern_class_'..i,row.classLabel..row.class..'  ▸',x+400,y,150,26,false,v.tips.ui.classRow) then
   row.class=row.class%K.classPatternClassMax+1; edited=true
  end
  y=y+32
 end
 if edited then
  local count=0; local valid=true
  for i=1,K.maxPatterns do
   local r=v.patternRows[i]
   if r.pattern~='' then
    if #r.pattern>K.maxPatternLength or not r.pattern:match('^[%w_%-]+$') then valid=false end
    count=count+1; v.patternFragments[count]=r.pattern..':'..r.class
   end
  end
  for i=#v.patternFragments,count+1,-1 do v.patternFragments[i]=nil end
  v.patternInvalid=not valid
  if valid then p.classPatterns=table.concat(v.patternFragments,','); v.patternSource=p.classPatterns; p.configured=true; Engine.changed(v.e); v.dirty() end
 end
 return y+6
end
-- Options globales (toutes les sessions).
local function globalBlock(v,e,x,y)
 local c=W.colors(); local g=e.g; local tips=v.globalTips
 y=y+W.paragraph(L.globalHelp,x,y,670,12,c.grey)+8
 local items={{'levelMode'},{'useGripBoost',L.grip},{'useBrakeAssist',L.brake},{'overrideAwareness',L.awareness},{'debugLog',L.debugLog}}
 for i,item in ipairs(items) do
  local cx=x+((i-1)%2)*340; local cy=y+math.floor((i-1)/2)*56
  local key=item[1]
  if W.visible(cy,48) then
   if key=='levelMode' then
    W.cell(L.levelRequested,cx,cy+2,330,12,c.grey,true); W.help(tips.levelMode,cx,cy,330,48,4)
    local at=1; for j,x0 in ipairs(C.globalChoices.levelMode) do if x0==g.levelMode then at=j end end
    if W.button('global_levelMode',L.levelModeLabels[at]..'  ▸',cx,cy+22,330,24,false,tips.levelMode) then g.levelMode=C.globalChoices.levelMode[at%#C.globalChoices.levelMode+1]; v.dirty() end
   else
    W.cell(item[2],cx,cy+2,330,12,c.grey,true); W.help(tips[key],cx,cy,330,48,4)
    if W.button('global_'..key,g[key] and L.on or L.off,cx,cy+22,330,24,g[key]==true,tips[key]) then g[key]=not g[key]; v.dirty() end
   end
  end
 end
 y=y+math.ceil(#items/2)*56
 for i,key in ipairs(globalSliders) do
  local bounds=C.globalBounds[key]; local cx=x+((i-1)%2)*340; local cy=y+math.floor((i-1)/2)*56
  if W.visible(cy,48) then
   W.cell(L.globalLabels[key],cx,cy+2,330,12,c.grey,true); W.help(tips[key],cx,cy,330,48,4)
   local step=W.step(bounds[1],bounds[2])
   local result=W.slider('global_'..key,cx,cy+22,330,g[key],bounds[1],bounds[2],step,number(g[key]),tips[key])
   if result then g[key]=result; C.validateGlobals(g,g); v.dirty() end
  end
 end
 y=y+math.ceil(#globalSliders/2)*56
 if W.visible(y,48) then
  W.cell(L.seed..' : '..string.format('%.0f',g.seed),x,y+2,330,12,c.grey,true); W.help(tips.seed,x,y,330,48,4)
  if W.button('reroll',L.reroll,x,y+22,330,24,false,v.tips.ui.reroll) then g.seed=math.floor(U.unit(g.seed,1,1)*2147483647); mark(v) end
 end
 return y+56
end
-- État de la section (trafic, météo, accidents, arrêts) au-dessus de ses réglages.
local function statusLines(v,e,group,view,p,out)
 if group=='traffic' then
  out[#out+1]=string.format(L.trafficStats,e.traffic.connected,e.traffic.count)
  if view~='J' then out[#out+1]=L.trafficOnlyJ end
  if not v.host.caps.speed.available then out[#out+1]=L.trafficUnavailable end
 elseif group=='weather' and e.frame then
  local wet,known,fallback=0,0,0
  for i=1,e.frame.count do local a=e.frame.cars[i]
   if a.valid and a.control and not a.player then
    if a.tyresKnown then known=known+1 end
    if a.nativeRainTyres then wet=wet+1 end
    if e.commands[i].weatherManaged and (e.commands[i].weatherGrip or 1)>1 then fallback=fallback+1 end
   end
  end
  out[#out+1]=string.format(L.weatherStatus,e.frame.wet*100,wet,fallback,known)
 elseif group=='accidents' then
  local t=e.incidents
  out[#out+1]=string.format(L.accidentStatus,t.activeCount,t.zoneCount,t.holdCount,L.neutralNames[t.neutral and t.neutralMode or 'none'])
  if t.red then out[#out+1]=string.format(L.redStatus,t.redInPits,t.redTotal) end
 elseif group=='rules' and v.rulesView=='stops' and view=='C' and p.mandatoryStops>0 then
  local pits=e.pits
  out[#out+1]=string.format(L.pitStatus,L.pitStates[pits.state],pits.csp and L.pitSourceCsp or L.pitSourceRules,pits.done,pits.total)
  if pits.progress<0 and not pits.csp then out[#out+1]=L.pitProgressUnknown end
 end
 return out
end
-- Contenu défilant de la section choisie : état, blocs propres (règles, voiture de sécurité, motifs, options
-- globales), puis les réglages sur deux colonnes ; les intertitres coupent les colonnes.
-- Overlay des drapeaux : réglages communs à toutes les sessions (opacité, affichage, durée des informations).
-- Réglages de l'overlay en jeu (Beta 1.25, comme SuperHUD) : verrou et position, taille, fond (opaque, atténué,
-- transparent) et opacités, affichage, contenu, affichages d'Assetto Corsa repris.
local overlayContentKeys={'overlaySession','overlayExplain','overlayRecap'}
local overlayNativeKeys={'overlayNativeBox','overlayMessages','overlayBlockMessages','overlayClickThrough','overlayHideReplay','overlayHidePits'}
local overlayResetKeys={'overlayX','overlayY','overlayScale','overlayLocked','overlayBackground','overlayContent','panelOpacity','panelShow','panelInfoTime',
 'overlaySession','overlayExplain','overlayRecap','overlayNativeBox','overlayMessages','overlayBlockMessages','overlayClickThrough','overlayHideReplay','overlayHidePits'}
local backgroundOrder={solid='ghost',ghost='transparent',transparent='solid'}
local function switches(v,g,keys,x,y)
 local tips=v.globalTips
 for k,key in ipairs(keys) do
  local cx=x+((k-1)%2)*340; local cy=y+math.floor((k-1)/2)*36
  if W.visible(cy,30) and W.toggle('overlay_'..key,L.overlaySwitches[key],cx,cy,330,g[key],tips[key]) then g[key]=not g[key]; v.dirty() end
 end
 return y+math.ceil(#keys/2)*36
end
local function overlayBlock(v,e,x,y)
 local c=W.colors(); local g=e.g; local tips=v.globalTips
 heading(L.overlayPlacement,x,y); W.line(x,y+17,x+670,y+17,c.line); y=y+24
 if W.visible(y,30) then
  if W.button('overlay_lock',g.overlayLocked and L.overlayUnlock or L.overlayLock,x,y,330,28,not g.overlayLocked,tips.overlayLocked) then g.overlayLocked=not g.overlayLocked; v.dirty() end
  if W.button('overlay_recenter',L.overlayRecenter,x+340,y,330,28,false,v.tips.ui.overlayRecenter) then g.overlayX=-1; g.overlayY=-1; g.overlayScale=1; v.dirty() end
 end
 y=y+36
 if not g.overlayLocked then y=y+W.paragraph(L.overlayHint,x,y,670,12,c.blue)+6 end
 if W.visible(y,48) then
  W.cell(L.overlayScale,x,y+2,330,12,c.grey,true); W.help(tips.overlayScale,x,y,330,48,4)
  local result=W.slider('overlay_scale',x,y+22,330,g.overlayScale,0.5,2.5,0.05,(string.format('%.2fx',g.overlayScale):gsub('%.',L.decimalMark)),tips.overlayScale)
  if result then g.overlayScale=result; C.validateGlobals(g,g); v.dirty() end
  W.cell(L.overlayBackground,x+340,y+2,330,12,c.grey,true); W.help(tips.overlayBackground,x+340,y,330,48,4)
  if W.button('overlay_background',L.backgrounds[g.overlayBackground]..'  ▸',x+340,y+22,330,24,g.overlayBackground~='solid',tips.overlayBackground) then g.overlayBackground=backgroundOrder[g.overlayBackground] or 'solid'; v.dirty() end
 end
 y=y+56
 y=y+8; heading(L.overlayLook,x,y); W.line(x,y+17,x+670,y+17,c.line); y=y+24
 if W.visible(y,48) then
  W.cell(L.overlayOpacity,x,y+2,330,12,c.grey,true); W.help(tips.panelOpacity,x,y,330,48,4)
  local result=W.slider('panel_opacity',x,y+22,330,g.panelOpacity,0,100,5,string.format(L.percentValue,g.panelOpacity),tips.panelOpacity)
  if result then g.panelOpacity=result; C.validateGlobals(g,g); v.dirty() end
  W.cell(L.overlayShow,x+340,y+2,330,12,c.grey,true); W.help(tips.panelShow,x+340,y,330,48,4)
  if W.button('panel_show',L.choices[g.panelShow]..'  ▸',x+340,y+22,330,24,g.panelShow=='always',tips.panelShow) then g.panelShow=g.panelShow=='always' and 'info' or 'always'; v.dirty() end
 end
 y=y+56
 if W.visible(y,48) then
  W.cell(L.overlayInfoTime,x,y+2,330,12,c.grey,true); W.help(tips.panelInfoTime,x,y,330,48,4)
  local result=W.slider('panel_info_time',x,y+22,330,g.panelInfoTime,0,60,1,g.panelInfoTime>0 and string.format('%.0f s',g.panelInfoTime) or L.overlayInfoAlways,tips.panelInfoTime)
  if result then g.panelInfoTime=result; C.validateGlobals(g,g); v.dirty() end
  W.cell(L.overlayContent,x+340,y+2,330,12,c.grey,true); W.help(tips.overlayContent,x+340,y,330,48,4)
  local content=W.slider('overlay_content',x+340,y+22,330,g.overlayContent,30,100,5,string.format(L.percentValue,g.overlayContent),tips.overlayContent)
  if content then g.overlayContent=content; C.validateGlobals(g,g); v.dirty() end
 end
 y=y+56
 y=y+8; heading(L.overlayContents,x,y); W.line(x,y+17,x+670,y+17,c.line); y=y+24
 y=switches(v,g,overlayContentKeys,x,y)
 y=y+8; heading(L.overlayNative,x,y); W.line(x,y+17,x+670,y+17,c.line); y=y+24
 return switches(v,g,overlayNativeKeys,x,y)
end
-- Réinitialisation d'une section (Beta 1.24) : valeurs par défaut du profil affiché, comme le clic droit sur un réglage ;
-- préférences du pilote, motifs de classes et réglages fixés par le jeu de règles gardés. Options globales : seulement
-- celles de l'onglet, jamais le sens latéral mesuré, la graine, la langue ni la voiture de sécurité.
local globalResetKeys={'levelMode','useGripBoost','useBrakeAssist','overrideAwareness','debugLog','occLatMin','occLatMax','occMargin','occSpeedGain','gripPerLevelPct'}
local function resetSection(v,e,group,view,p)
 if group=='globals' then
  for _,key in ipairs(globalResetKeys) do e.g[key]=C.globalDefaults[key] end
  v.presetMessage=string.format(L.sectionResetDone,L.categories.globals); mark(v); return
 end
 if group=='overlay' then
  for _,key in ipairs(overlayResetKeys) do e.g[key]=C.globalDefaults[key] end
  v.presetMessage=L.overlayResetDone; mark(v); return
 end
 local defaults=C.defaults(view)
 for _,s in ipairs(C.schema) do if s.group==group and not C.kept(view,s.key) then p[s.key]=defaults[s.key] end end
 C.validate(view,p,p); v.presetMessage=string.format(L.sectionResetDone,L.categories[group]); touch(v,p)
end
local function sectionContent(v,e,group,view,p,x,top)
 local c=W.colors(); local y=top; local column=0
 if group~='rules' then
  if W.visible(y,26) and W.button('reset_'..group,L.sectionReset,x+410,y,260,26,false,v.tips.ui.sectionReset) then resetSection(v,e,group,view,p) end
  y=y+34
 end
 local function flush() if column==1 then y=y+56; column=0 end end
 local status=statusLines(v,e,group,view,p,v.statusLines)
 for i=#status,1,-1 do y=y+W.paragraph(status[i],x,y,670,12,c.blue)+2; status[i]=nil end
 if group=='overlay' then return overlayBlock(v,e,x,y+4)-top end
 if group~='globals' and not C.on(p,group) then
  y=y+6+W.paragraph(group=='rules' and L.rulesOff or L.sectionOff,x,y+6,670,12,c.warn)
  return y-top
 end
 if group=='globals' then
  if C.on(p,'globals') then y=globalBlock(v,e,x,y+4) else y=y+6+W.paragraph(L.sectionOff,x,y+6,670,12,c.warn) end
  return y-top
 end
 -- Voiture de sécurité : juste après les règles communes (choix de la neutralisation), avant le drapeau rouge.
 -- Voiture de sécurité (Beta 1.19) : choix du modèle dans sa vue de l'onglet Règles de course, après ses réglages.
 local safety=group=='rules' and v.rulesView=='safety'
 for _,control in ipairs(group=='rules' and v.ruleLists[v.rulesView] or v.controls[group]) do
  local s=control.schema
  local header=group=='rules' and L.ruleHeaders[s.key] or group=='accidents' and L.accidentHeaders[s.key]
  if header then
   flush()
   y=y+8; heading(header,x,y); W.line(x,y+17,x+670,y+17,c.line); y=y+24
  end
  if C.hidden(view,s.key) then
   if header then flush(); y=y+W.paragraph(L.penaltiesTrackDay,x,y,670,12,c.grey)+6
   elseif s.key=='enduranceOverlay' then flush(); y=y+W.paragraph(L.enduranceNotAvailable,x,y,670,12,c.grey)+6
   elseif s.key=='spawnMode' then flush(); y=y+W.paragraph(L.spawnNotAvailable,x,y,670,12,c.grey)+6
   elseif s.key=='floodRangeKm' and not C.hidden(view,'spawnMode') then flush(); y=y+W.paragraph(L.floodNotAvailable,x,y,670,12,c.grey)+6 end
  else
   local cx=x+column*340
   if W.visible(y,48) then settingControl(v,control,view,p,cx,y) end
   column=column+1; if column==2 then column=0; y=y+56 end
  end
 end
 flush()
 if safety then y=safetyBlock(v,e,x,y+10) end
 if group=='endurance' then y=patternBlock(v,p,x,y+10) end
 return y-top
end
-- Langue de l'interface : textes de la fenêtre et du panneau de drapeaux refaits aussitôt ; choix enregistré.
local function language(v,code)
 local e=v.e
 e.g.language=code
 Locale.set(code); texts(v)
 local panel=e.panel; panel.key=''; panel.infractions=-1; panel.drsLaps=-1; panel.at=-math.huge
 v.dirty()
end
local function headerBar(v,e)
 local c=W.colors()
 W.text('ACADVANCEDIA',22,10,26,c.light,true)
 W.rect(244,16,30,19,c.blue,2); W.text(L.aiBadge,251,18,10,c.dark,true)
 W.text(C.release,284,20,11,c.grey)
 local ready=e.guard=='ready'
 -- État resserré (Beta 1.16) : activation, panique puis choix de la langue sur la droite.
 W.cell((ready and L.active or L.inactive)..' · '..L.profiles[e.profile],380,9,250,16,ready and c.blue or c.warn,true)
 W.cell(L.guards[e.guard] or e.guard,380,31,250,11,c.grey)
 W.help(v.tips.ui.status,380,8,250,40,3)
 if W.button('enabled',e.g.enabled and L.enabledOn or L.enabledOff,640,10,126,30,e.g.enabled,v.tips.ui.enabled) then e.g.enabled=not e.g.enabled; v.dirty() end
 local panic=e.panic
 if W.button('panic',panic and L.resumeShort or L.panicShort,774,10,122,30,panic,panic and v.tips.ui.resume or v.tips.ui.panic,'danger') then
  e.panic=not e.panic; if not e.panic then Engine.reset(e,e.time,true) end
 end
 for i,code in ipairs(Locale.codes) do
  if W.button('lang_'..code,languageLabels[code],904+(i-1)*38,10,36,30,Locale.current==code,v.tips.ui.language) and Locale.current~=code then language(v,code) end
 end
 for i,tab in ipairs(tabs) do
  local x=22+(i-1)*180
  local clicked=W.hit('tab_'..tab,x,48,160,32)
  W.text(L.tabs[tab],x+14,56,13,v.tab==tab and c.light or c.grey,true)
  if v.tab==tab then W.rect(x,79,160,2,c.blue) end
  W.help(v.tips.ui['tab_'..tab],x,48,160,32,3)
  if clicked then v.tab=tab end
 end
 W.line(16,84,984,84,c.line)
end
-- Choix du profil affiché (réglé) : avec le profil automatique, le clic affiche sans figer la détection ; sans lui, il
-- choisit le profil utilisé.
local function profileButtons(v,e,x,y,w,h,short)
 for at,profile in ipairs(C.profiles) do
  local bx=x+(at-1)*(w+8)
  if W.button('profile_'..profile,short and L.shortProfiles[profile] or L.profiles[profile],bx,y,w,h,v.view==profile,v.tips.profiles[profile]) then
   if e.g.autoProfile then v.view=profile; v.viewFor=e.profile else Engine.select(e,profile); v.view=profile; v.viewFor=profile; v.dirty() end
  end
 end
end
-- Accueil (Beta 1.10, sans onglet Préréglages) : à gauche ce que l'on règle (profil, session, préréglages intégrés,
-- restauration), à droite ce qui se passe (état, points à vérifier) puis les préréglages personnels. La page défile
-- d'un bloc à la molette ; toute commande hors de la zone visible n'est ni dessinée ni cliquable.
local function homeTab(v,e,host)
 local c=W.colors(); local view=v.view; local p=e.profiles[view]
 local top=92; local height=W.frame().h-top-8
 local offset=W.scroll(v.scrolls,'home',16,top,968,height,v.contentHeights.home or 0)
 W.clip(16,top,968,height)
 -- Préréglage actif (intégré ou personnel), connu avant le dessin : une seule ligne d'état, sous les intégrés.
 v.activePreset=nil
 for _,item in ipairs(v.builtinList) do builtinActive(v,item[2],item[4](view),item[1]) end
 local custom=v.customActive
 for i=1,K.maxPresets do
  local entry=host.presets[i]
  custom[i]=entry~=nil and view==entry.profile and Presets.signature(view,p,e.g,v.signatureValues)==Presets.signature(entry.profile,entry.p,entry.g,v.signatureValues)
  if custom[i] and not v.activePreset then v.activePreset=entry.name end
 end
 -- Colonne de gauche.
 local x=22; local y=top+8-offset
 heading(L.profileHeading,x,y)
 if W.visible(y+22,40) then profileButtons(v,e,x,y+22,86,40,true) end
 y=y+72
 if W.visible(y,30) and W.toggle('auto',L.auto,x,y,464,e.g.autoProfile,v.tips.ui.auto) then
  e.g.autoProfile=not e.g.autoProfile
  if e.g.autoProfile and e.frame then e.profile=C.autoProfile(e.frame); e.p=e.profiles[e.profile] end
  if not e.g.autoProfile then e.g.manualProfile=e.profile end
  v.viewFor=nil; mark(v)
 end
 y=y+40
 if view~=e.profile then y=y+W.paragraph(string.format(L.viewing,L.profiles[view],L.profiles[e.profile]),x,y,464,12,c.grey)+6 end
 heading(L.sessionHeading,x,y+8); y=y+30
 if e.frame then
  local declared=e.frame.configType>=1
  local kind=declared and e.frame.configType or e.frame.type
  local label=declared and e.frame.configTrackDay and L.trackDaySession or L.sessionTypes[kind] or L.sessionTypes[0]
  y=y+W.paragraph(string.format(L.sessionDetected,label,declared and L.sourceRace or L.sourceCSP,L.profiles[C.autoProfile(e.frame)])..(e.g.autoProfile and '' or L.manualOverride),x,y,464,13,c.light)+6
 end
 heading(L.builtinHeading,x,y+10); y=y+32
 for k,item in ipairs(v.builtinList) do
  local label,name,target=item[1],item[2],item[4](view)
  local bx=x+((k-1)%2)*236; local by=y+math.floor((k-1)/2)*40
  if W.visible(by,34) and W.button('builtin_'..name,label,bx,by,228,34,builtinActive(v,name,target,label),v.tips.presets[item[3]]) then loadBuiltin(v,name,target) end
 end
 y=y+math.ceil(#v.builtinList/2)*40+4
 if v.activePreset then y=y+W.paragraph(L.activePreset..v.activePreset,x,y,464,13,c.blue)+8
 elseif e.g.loadedPreset~='' then y=y+W.paragraph(L.loadedPreset..v.loadedName..L.presetModified,x,y,464,12,c.grey)+8
 else y=y+W.paragraph(L.noActivePreset,x,y,464,12,c.grey)+8 end
 if W.visible(y,32) and W.button('restore',L.restoreShort..L.profiles[view],x,y,464,32,false,v.tips.ui.restore) then C.restore(view,p); touch(v,p) end
 local left=y+40
 -- Colonne de droite.
 x=520; y=top+8-offset
 heading(L.stateHeading,x,y); y=y+22
 local t=e.incidents
 y=y+W.paragraph(string.format(L.homeCars,e.activeCount),x,y,458,13,c.light)+4
 y=y+W.paragraph(string.format(L.homeIncidents,t.activeCount,t.zoneCount,L.neutralNames[t.neutral and t.neutralMode or 'none']),x,y,458,13,c.light)+4
 y=y+10; heading(L.warningsHeading,x,y); y=y+22
 local warnings=v.warnings; for i=#warnings,1,-1 do warnings[i]=nil end
 if e.frame and e.frame.conflict~='' then warnings[#warnings+1]=L.conflict..e.frame.conflict end
 if e.g.offsetSign==0 and C.needsOffset(C.effective(view,p,v.derived)) then warnings[#warnings+1]=L.unavailableSigns end
 if e.frame and e.frame.left>K.enduranceSuggestionSeconds and not p.enduranceOverlay and view~='Q' and view~='P' and view~='H' then warnings[#warnings+1]=L.enduranceSuggestion end
 if C.any(p) and not C.on(p,'weather') then warnings[#warnings+1]=L.weatherOff end
 if host.raceFlagsHidden==false then warnings[#warnings+1]=L.nativeFlagsShown end
 if p.configured and not C.on(p,'accidents') and not C.on(p,'rules') then warnings[#warnings+1]=L.newTabsOff end
 if host.upgraded and #host.upgraded>0 then warnings[#warnings+1]=L.upgraded..table.concat(host.upgraded,', ') end
 if #warnings==0 then y=y+W.paragraph(L.noWarnings,x,y,458,12,c.grey)+4 end
 for _,w in ipairs(warnings) do W.rect(x,y+3,3,12,c.warn,1); y=y+W.paragraph(w,x+10,y,448,12,c.warn)+6 end
 -- Préréglages personnels : nom et enregistrement en tête, puis la bibliothèque.
 y=y+14; heading(L.customPresets,x,y); y=y+22
 v.presetName=input('preset_name',x,y,330,v.presetName,v.tips.ui.presetName) or v.presetName
 if W.visible(y,26) and W.button('save_preset',L.savePresetShort,x+338,y,120,26,false,v.tips.ui.savePreset) then
  local entry=Presets.capture(v.presetName,view,p,e.g)
  if not entry then v.presetMessage=L.invalidPresetName
  elseif Adapter.savePreset(host,entry) then
   e.g.loadedPreset='custom:'..entry.name; e.g.presetsUsed=true; v.presetMessage=L.presetSaved; v.dirty()
  else v.presetMessage=L.presetSaveFailed end
 end
 y=y+32
 y=y+W.paragraph(string.format(L.presetTargetNote,L.profiles[view]),x,y,458,12,c.grey)+6
 if v.presetMessage~='' then y=y+W.paragraph(v.presetMessage,x,y,458,12,c.blue)+6 end
 local any=false
 for i=1,K.maxPresets do
  local entry=host.presets[i]
  if entry then
   any=true
   local id='custom:'..entry.name
   local tip=v.customTips[entry.name..'|'..entry.profile]
   if not tip then tip=wrap(string.format(L.tipCustom,entry.name,L.profiles[entry.profile] or entry.profile)..'\n\n'..T.ui.customPreset); v.customTips[entry.name..'|'..entry.profile]=tip end
   if W.visible(y,32) then
    if W.button('custom_'..i,entry.name..' · '..L.shortProfiles[entry.profile],x,y,330,32,custom[i],tip) then
     local profile=Presets.apply(entry,e.profiles,e.g); e.profiles[profile].configured=true; presetTarget(v,profile)
     e.g.loadedPreset=id; e.g.presetsUsed=true; mark(v)
     v.presetName=entry.name
    end
    if W.button('custom_delete_'..i,L.deletePreset,x+338,y,120,32,false,v.tips.ui.deletePreset,'danger') then
     if Adapter.deletePreset(host,i) then
      if e.g.loadedPreset==id then e.g.loadedPreset='' end
      if v.presetName==entry.name then v.presetName='' end
      v.presetMessage=L.presetDeleted..entry.name; v.dirty()
     else v.presetMessage=L.presetDeleteFailed end
    end
   end
   y=y+38
  end
 end
 if not any then y=y+W.paragraph(L.noCustomPresets,x,y,458,12,c.grey)+8 end
 W.clip(); v.contentHeights.home=math.max(left,y)+offset-top+8
end
-- Partie droite des onglets Réglages et Règles de course : titre de la section, choix du profil affiché, description,
-- puis ses réglages qui défilent à la molette.
-- title, description, key : titre, description et défilement propres à une vue (onglet Règles de course).
local function sectionPane(v,e,group,view,p,title,description,key)
 local c=W.colors()
 W.line(290,96,290,W.frame().h-10,c.line)
 W.cell(title or L.groups[group] or L.globals,308,98,284,22,c.light,true)
 profileButtons(v,e,600,98,70,24,true)
 local dy=W.paragraph(description or v.descriptions[group],308,130,670,12,c.grey)
 local top=math.max(160,142+dy)
 local height=W.frame().h-top-12
 key=key or group..view
 local offset=W.scroll(v.scrolls,key,300,top,684,height,v.contentHeights[key] or 0)
 W.clip(300,top,684,height)
 v.contentHeights[key]=sectionContent(v,e,group,view,p,308,top-offset+4)+20
 W.clip()
end
local function settingsTab(v,e)
 local c=W.colors(); local view=v.view; local p=e.profiles[view]
 local y=96
 for _,block in ipairs(sidebar) do
  heading(L.sidebar[block[1]],22,y); y=y+20
  for i=2,#block do
   local group=block[i]
   local selected=v.category==group
   local clicked,hover=W.hit('cat_'..group,16,y,208,31)
   W.frame().active['cat_'..group]=selected
   if selected or hover then W.rect(16,y,264,31,c.field,2) end
   if selected then W.rect(16,y+4,2,23,c.blue,1) end
   W.cell(L.categories[group],28,y+8,190,13,selected and c.light or c.grey,true)
   W.help(v.tips.tabs[group],16,y,208,31,3)
   local toggled=false
   if group~='overlay' then
    local on=C.on(p,group)
    toggled=W.hit('section_'..group,232,y+3,44,26)
    W.pill(238,y+8,on)
    W.help(v.tips.sections[group],232,y+3,44,26,5)
    if toggled then p['section_'..group]=not on; touch(v,p) end
   end
   if clicked and not toggled then v.category=group end
   y=y+33
  end
  y=y+8
 end
 sectionPane(v,e,v.category,view,p)
end
-- Onglet Règles de course (Beta 1.17) : à gauche l'interrupteur des règles du profil affiché et les jeux de règles de
-- championnat ; à droite les réglages de la section Règles, présentés comme dans l'onglet Réglages.
-- Ligne de la colonne de gauche (Beta 1.19), comme la liste de l'onglet Réglages : le titre affiche ses réglages à
-- droite (surligné), seule la pastille change l'état. Renvoie le clic sur le titre, puis sur la pastille.
local function ruleRow(v,name,switch,label,y,on,tip,switchTip)
 local c=W.colors(); local id='rules_view_'..name; local selected=v.rulesView==name
 if not W.visible(y,31) then return false,false end
 local clicked,hover=W.hit(id,16,y,208,31)
 W.frame().active[id]=selected; W.frame().active[switch]=on
 if selected or hover then W.rect(16,y,264,31,c.field,2) end
 if selected then W.rect(16,y+4,2,23,c.blue,1) end
 W.cell(label,28,y+8,196,13,selected and c.light or c.grey,true)
 W.help(tip,16,y,208,31,3)
 local toggled=W.hit(switch,232,y+3,44,26)
 W.pill(238,y+8,on)
 W.help(switchTip,232,y+3,44,26,5)
 return clicked,toggled
end
-- Colonne de gauche à la molette (Beta 1.18) : interrupteurs, notes et jeux de règles dépassent une fenêtre basse.
local function rulesTab(v,e)
 local c=W.colors(); local view=v.view; local p=e.profiles[view]
 local top=96; local height=W.frame().h-top-10
 local offset=W.scroll(v.scrolls,'rules_left',16,top,270,height,v.contentHeights.rulesLeft or 0)
 W.clip(16,top,270,height)
 local y=top-offset
 local on=C.on(p,'rules')
 local shown,toggled=ruleRow(v,'all','section_rules',L.rulesToggle,y,on,v.tips.ui.rulesViewAll,v.tips.sections.rules)
 if toggled then p.section_rules=not on; touch(v,p) elseif shown then v.rulesView='all' end
 -- Arrêt obligatoire et voiture de sécurité (Beta 1.18) : état du profil Course (ils n'agissent qu'en course), réglés
 -- ensemble pour les Essais, Qualifications et Course ; chaque jeu de règles les règle aussi.
 local race=e.profiles.C
 local stops=race.mandatoryStops>0
 shown,toggled=ruleRow(v,'stops','mandatory_stop',L.mandatorySwitch,y+33,stops,v.tips.ui.rulesViewStops,v.tips.ui.mandatoryStop)
 if toggled then C.weekendSwitch(e.profiles,'mandatoryStops',not stops); mark(v) elseif shown then v.rulesView='stops' end
 local safety=race.safetyCarEscalation==true
 shown,toggled=ruleRow(v,'safety','safety_switch',L.safetySwitch,y+66,safety,v.tips.ui.rulesViewSafety,v.tips.ui.safetySwitch)
 if toggled then C.weekendSwitch(e.profiles,'safetyCarEscalation',not safety); mark(v) elseif shown then v.rulesView='safety' end
 y=y+106
 -- Ce que fera la voiture de sécurité en course : aucune voiture choisie alors qu'elle servirait (repli VSC ou FCY,
 -- prioritaire), neutralisation « Voiture de sécurité » choisie (elle sort de toute façon).
 -- En course, voiture choisie absente de la grille : la VSC ou la FCY continue (Beta 1.19).
 local used=race.neutralization=='sc' or race.safetyCarEscalation
 local note=used and e.g.safetyCarModel=='' and L.safetySwitchNoCar or used and e.profile=='C' and e.frame and e.incidents.safety==0 and L.safetySwitchNotOnGrid or race.neutralization=='sc' and L.safetySwitchDirect
 if note then y=y+W.paragraph(note,22,y,252,12,c.warn)+10 end
 y=ruleBlock(v,e,p,22,y,252)
 -- Réinitialisation (Beta 1.19) : valeurs du jeu de règles surligné, ou du plus proche s'il a été retouché à droite,
 -- interrupteurs compris ; préférences du pilote gardées, comme avec les boutons des jeux de règles.
 if W.visible(y,32) and W.button('rules_reset',L.rulesReset,22,y,252,32,false,v.tips.ui.rulesReset) then
  local target=C.solo(view) and 'C' or view
  local name=C.closestRuleCategory(target,e.profiles[target],switchKeys)
  C.applyRules(name,e.profiles); v.presetMessage=string.format(L.ruleApplied,L.ruleNames[name]); mark(v)
 end
 y=y+42
 W.clip(); v.contentHeights.rulesLeft=y+offset-top
 -- Arrêts aux stands et voiture de sécurité : réglages du profil Course, le seul où ils agissent (comme leurs
 -- interrupteurs) ; le reste des règles : profil affiché.
 local rv=v.rulesView
 if rv=='all' then sectionPane(v,e,'rules',view,p,nil,nil,'rules'..view..rv)
 else sectionPane(v,e,'rules','C',race,rv=='stops' and L.mandatorySwitch or L.safetySwitch,rv=='stops' and L.stopsDescription or L.safetyDescription,'rules'..rv) end
end
-- Diagnostic (Beta 1.10 : l'ancienne fenêtre détaillée fusionnée dans l'onglet) : à gauche les commandes en tête
-- (calibration, appels de phares, zones, journal) puis les capacités CSP et les fonctions IA exposées ; à droite le tableau des IA pilotées, les performances et
-- le journal circulaire filtrable. Chaque zone défile à la molette.
local function diagnosticTab(v,e,host)
 local c=W.colors(); local frame=e.frame
 local top=96; local bottom=W.frame().h-10
 -- Colonne de gauche.
 local x=22
 local height=bottom-top
 local offset=W.scroll(v.scrolls,'diag_left',16,top,460,height,v.contentHeights.diagLeft or 0)
 W.clip(16,top,460,height)
 local y=top-offset
 if frame then y=y+W.paragraph(L.patch..frame.patch..' · '..L.track..frame.track..' · '..string.format(L.trackLength,frame.length),x,y,440,11,c.grey)+8 end
 heading(L.signs,x,y); y=y+20
 y=y+W.paragraph(L.calibration[v.calibration.phase]..' — '..L.signValue..e.g.offsetSign..' / '..e.g.sideSign,x,y,440,12,c.light)+6
 if W.visible(y,28) and W.button('calibrate',L.calibrate,x,y,440,28,false,v.tips.ui.calibrate) then e.recalibrateRequested=true end
 y=y+40
 heading(L.flash,x,y); y=y+20
 y=y+W.paragraph(L.field..(e.g.flashField~='' and e.g.flashField or L.unlearned)..' — '..L.event..e.flash.eventId..' / '..e.flash.eventCount,x,y,440,12,c.light)+6
 if W.visible(y,28) and W.button('learn',L.learn,x,y,440,28,e.flash.learnUntil>e.time,v.tips.ui.learn) then Flash.learn(e.flash,e.time) end
 y=y+32
 if e.flash.learnUntil>e.time then y=y+W.paragraph(L.learning,x,y,440,12,c.blue)+4 end
 y=y+8; heading(L.zones,x,y); y=y+20
 if W.visible(y,28) and frame then
  if W.button('mark_start',L.markStart,x,y,140,28,e.zoneStart>=0,v.tips.ui.markStart) and frame.player>0 then e.zoneStart=frame.cars[frame.player].spline end
  if W.button('mark_end',L.markEnd,x+148,y,170,28,false,v.tips.ui.markEnd) and e.zoneStart>=0 and frame.player>0 and #e.zones<K.maxZones then
   e.zones[#e.zones+1]={from=e.zoneStart,to=frame.cars[frame.player].spline,noYield=true,noOvertake=true,maxOffset=K.pitOffsetMax,note=''}; e.zoneStart=-1
  end
  if W.button('export',L.exportShort,x+326,y,114,28,false,v.tips.ui.export) then host.clipboard(Zones.export(e.zones)) end
 end
 y=y+34
 W.text(L.zoneCount..#e.zones,x,y,12,c.light); if W.visible(y,16) then W.help(v.tips.ui.zoneCount,x,y,440,16,4) end; y=y+26
 heading(L.journalHeading,x,y); y=y+20
 if W.visible(y,30) and W.toggle('journal',L.journal,x,y,440,e.g.journal,v.tips.ui.journal) then e.g.journal=not e.g.journal; v.dirty() end
 y=y+36
 y=y+W.paragraph(host.journalPath and string.format(L.journalPath,host.journalPath,host.journalBytes or 0) or L.journalOff,x,y,440,11,c.grey)+10
 heading(L.capabilities,x,y); y=y+20
 for _,name in ipairs(Caps.names) do
  local cap=host.caps[name]
  W.cell(L[name..'Label'] or L[name],x,y,230,12,c.grey)
  W.cell(L.capStates[cap.reason],x+240,y,200,12,cap.reason=='missing' and c.warn or cap.reason=='failures' and c.red or c.light)
  y=y+18
 end
 y=y+W.paragraph(L.levelMode..(host.caps.probeDone and L.choices[host.caps.levelMode] or L.probe),x,y+4,440,12,c.light)+4
 y=y+W.paragraph(L.brakeEmulation,x,y,440,11,c.grey)+2
 y=y+W.paragraph(L.gripUnits,x,y,440,11,c.grey)+10
 if W.visible(y,30) and W.toggle('api_list',L.apiList,x,y,440,v.open.apiList==true,v.tips.ui.apiList) then v.open.apiList=not v.open.apiList end
 y=y+36
 if v.open.apiList then for _,name in ipairs(host.aiFunctions) do W.text(name,x,y,11,c.grey); y=y+16 end end
 W.clip(); v.contentHeights.diagLeft=y+offset-top+10
 W.line(486,top,486,bottom,c.line)
 -- Colonne de droite : IA pilotées.
 x=500
 heading(L.carsHeading,x,top)
 local cols={{L.colCar,0,150},{L.colState,152,108},{L.colOffset,262,48},{L.colNAP,312,100},{L.colGap,414,64}}
 for _,col in ipairs(cols) do W.cell(col[1],x+col[2],top+20,col[3],10,c.grey,true) end
 local tableTop=top+38; local tableHeight=math.max(100,(bottom-top)*0.42)
 local tableOffset=W.scroll(v.scrolls,'diag_cars',x-4,tableTop,486,tableHeight,v.contentHeights.diagCars or 0)
 W.clip(x-4,tableTop,486,tableHeight)
 y=tableTop-tableOffset
 local rows=v.debugRows
 if frame then
  for i=1,frame.count do
   local a,s,cmd=frame.cars[i],e.states[i],e.commands[i]
   if a.control then
    if W.visible(y,16) then
     local row=rows[i]; if not row then row={}; rows[i]=row end
     -- Textes refaits seulement quand les valeurs affichées (arrondies) changent : aucune chaîne neuve à chaque image.
     local off=math.floor(cmd.offset*100+0.5); local lv=math.floor(cmd.level*100+0.5); local ag=math.floor(cmd.aggression*100+0.5)
     local ca=math.floor(cmd.caution*10+0.5); local gp=s.gap<math.huge and math.floor(s.gap+0.5) or -1
     if row.id~=a.index or row.name~=a.name or row.off~=off or row.lv~=lv or row.ag~=ag or row.ca~=ca or row.gp~=gp then
      row.id=a.index; row.name=a.name; row.off=off; row.lv=lv; row.ag=ag; row.ca=ca; row.gp=gp
      row.car=string.format('%02d %s',a.index,a.name~='' and a.name or a.id)
      row.offset=string.format('%+.2f',off/100)
      row.nap=string.format('%.2f / %.2f / %.1f',lv/100,ag/100,ca/10)
      row.gap=gp>=0 and string.format('%d m',gp) or '—'
     end
     W.cell(row.car,x,y,150,11,c.light)
     W.cell(L.states[s.state] or s.state,x+152,y,108,11,s.state=='DRIVE' and c.grey or c.blue)
     W.cell(row.offset,x+262,y,48,11,c.light)
     W.cell(row.nap,x+312,y,100,11,c.light)
     W.cell(row.gap,x+414,y,64,11,c.light)
     W.help(L.reasons[s.reason] or s.reason,x,y,478,16,3)
    end
    y=y+17
   end
  end
 end
 W.clip(); v.contentHeights.diagCars=y+tableOffset-tableTop
 y=tableTop+tableHeight+10
 heading(L.performance,x,y); y=y+20
 y=y+W.paragraph(host.timer and string.format(L.timings,e.meanFrame,e.maxFrame) or L.runtimeTiming,x,y,478,11,c.light)+2
 y=y+W.paragraph(string.format(L.stats,e.activeCount,e.errors,host.errors,host.rejected+(frame and frame.invalid or 0)),x,y,478,11,c.light)+8
 heading(L.logs,x,y)
 if W.button('log_filter',L.filterShort..' '..L.logLevels[v.logFilter],x+330,y-6,148,24,v.logFilter>1,v.tips.ui.filter) then v.logFilter=v.logFilter%#L.logLevels+1 end
 y=y+24
 local logTop=y; local logHeight=math.max(60,bottom-logTop)
 local logOffset=W.scroll(v.scrolls,'diag_log',x-4,logTop,486,logHeight,v.contentHeights.diagLog or 0)
 W.clip(x-4,logTop,486,logHeight)
 y=logTop-logOffset
 for n=0,e.log.count-1 do
  local r=e.log[(e.log.head-n-1)%K.logLines+1]
  if v.logFilter==1 or r.level==L.logLevels[v.logFilter] then
   if W.visible(y,15) then
    if r.shownText==nil or r.shownSerial~=r.serial then r.shownSerial=r.serial; r.shownText=string.format('%.1f %s [%d] %s',r.time,r.level,r.index,r.message) end
    W.cell(r.shownText,x,y,478,10,r.level=='ERROR' and c.red or r.level=='WARN' and c.warn or c.grey)
   end
   y=y+15
  end
 end
 W.clip(); v.contentHeights.diagLog=y+logOffset-logTop
end
-- Taille compacte de la fenêtre de réglages (Beta 1.14), pour l'applicateur.
function M.compactSize() return vec2(K.compactWidth,K.compactHeight) end
function M.main(v)
 local e,host=v.e,v.host
 if not v.drawable then
  text(string.format(L.titleVersion,C.release)); text(L.cspTooOld)
  return
 end
 -- Profil affiché (consulté, réglé) distinct du profil en cours : retour au profil en cours à chaque changement de
 -- session, ou à chaque image sans le profil automatique.
 if not e.g.autoProfile or v.viewFor~=e.profile then v.view=e.profile; v.viewFor=e.profile end
 if e.g.loadedPreset~=v.loadedFor then
  v.loadedFor=e.g.loadedPreset
  local kind,name=e.g.loadedPreset:match('^([^:]+):(.*)$')
  if kind=='builtin' then name=v.builtinNames[name] or name end
  v.loadedName=name or e.g.loadedPreset
 end
 W.begin('main')
 headerBar(v,e)
 if v.tab=='home' then homeTab(v,e,host)
 elseif v.tab=='settings' then settingsTab(v,e)
 elseif v.tab=='rules' then rulesTab(v,e)
 else diagnosticTab(v,e,host) end
 W.finish()
end
-- Panneau de drapeaux (fenêtre de conduite) : rien sans drapeau ; couleurs et disponibilité du dessin vérifiées une
-- fois, sans dessin possible le texte seul s'affiche.
-- Panneau de drapeaux en conduite, lisible d'un coup d'œil : bandeau de la couleur du drapeau et version en haut ;
-- drapeau à gauche (couleur et sigle, badge pour le DRS, bandes pour la piste glissante) ; consigne au centre (titre
-- en grand, détail) ; à droite le temps delta en grand, vert quand il est positif (assez lent), rouge clignotant quand
-- il est négatif ; en bas, pastilles d'état (pénalité, place à rendre, stands, écart au drapeau bleu, dépassement,
-- DRS). Rouge et bleu clignotent, comme les voyants d'un volant ; un nouveau drapeau aussi, quelques secondes. Texte
-- TrueType à la taille voulue (DWrite) ; sans lui, texte simple.
local panelColors,panelAlpha
-- alpha : opacité du contenu (Beta 1.25) ; palette refaite seulement quand elle change.
local function faded(col,alpha) return rgbm(col.r,col.g,col.b,(col.mult or col.m or 1)*alpha) end
local function panelPalette(alpha)
 alpha=alpha or 1
 if panelColors==nil or panelColors and panelAlpha~=alpha then
  panelColors=false; panelAlpha=alpha
  local values={red={0.86,0.1,0.1,1},yellow={1,0.82,0.05,1},blue={0.12,0.38,0.95,1},green={0.1,0.68,0.22,1},pit={0.85,0.85,0.85,1},
   back={0.08,0.085,0.087,0.86},ink={0,0,0,1},over={1,0.3,0.25,1},amber={1,0.68,0.1,1},
   under={0.35,0.95,0.4,1},overBack={0.55,0.04,0.04,0.92},amberBack={0.5,0.3,0.02,0.92}}
  local out={}
  for key,c in pairs(values) do local ok,color=pcall(rgbm,c[1],c[2],c[3],c[4]*alpha); if not ok then return false end; out[key]=color end
  if pcall(vec2,0,0) and callable(ui.drawRectFilled) and callable(ui.windowSize) and callable(ui.getCursor)
   and (callable(ui.dwriteDrawTextClipped) or callable(ui.drawText)) then
   -- Teintes neutres communes aux fenêtres (une seule palette) ; seules les couleurs des drapeaux sont propres au panneau.
   local w=W.colors(); out.text=faded(w.light,alpha); out.dim=faded(w.grey,alpha); out.pillBack=faded(w.field,alpha); out.drsBack=faded(w.panel,alpha)
   out.accent=faded(w.blue,alpha); panelColors=out
  end
 end
 return panelColors
end
local flagColors={lap='pit',red='red',sc='yellow',scIn='yellow',fcy='yellow',vsc='yellow',vscEnd='yellow',restart='green',yellow='yellow',zone='yellow',zone1='yellow',native='yellow',blue='blue',green='green',pit='pit',slippery='yellow',black='ink',penalty='ink',checkered='ink',white='pit'}
-- Sigle inscrit dans le drapeau (rouge, bleu et vert parlent d'eux-mêmes) ; double jaune : « !! ».
local flagCodes={sc='SC',scIn='SC',fcy='FCY',vsc='VSC',vscEnd='VSC',yellow='!',zone='!!',zone1='!',native='!',pit='P'}
-- Alignements DWrite (ui.Alignment) : début, centre, fin.
local START,CENTER,FINISH=-1,0,1
-- Texte dans un cadre {x1,y1,x2,y2}, aligné, éventuellement replié ; sans DWrite : texte simple en haut à gauche.
local function write(text,size,r,color,align,wrap)
 if callable(ui.dwriteDrawTextClipped) then
  ui.dwriteDrawTextClipped(text,size,vec2(r[1],r[2]),vec2(r[3],r[4]),align,wrap and START or CENTER,wrap==true,color)
 else ui.drawText(text,vec2(r[1],r[2]),color) end
end
local function textWidth(text,size)
 if callable(ui.measureDWriteText) then local ok,s=pcall(ui.measureDWriteText,text,size); if ok and s and s.x then return s.x end end
 return #text*size*0.55
end
-- Plus grande taille (au plus size) qui fait tenir le texte sur une ligne de la largeur donnée.
local function fitSize(text,size,width)
 local w=textWidth(text,size)
 return w>width and math.max(10,size*width/w) or size
end
-- Disposition du bandeau (pure, testée) : une bande à hauteur de fenêtre (drapeau, titre et consigne courte sur une
-- ligne, delta à droite), la version en petit dans le coin haut droit ; la ligne des pastilles n'est réservée que si
-- elles existent. Jamais de chevauchement, de 360 × 80 (taille minimale) à 900 × 220, quel que soit le haut du contenu.
function M.flagLayout(w,h,top,delta,pills)
 local pad,gap,bar=6,10,4
 local l={}
 local pillH=pills and U.clamp((h-top)*0.24,14,22) or 0
 local bandBottom=h-(pills and pillH+6 or 2)
 local bandH=math.max(20,bandBottom-top)
 l.accent={0,top,bar,h}
 l.version={w-pad-70,top+1,w-pad,top+11}
 local side=U.clamp(bandH-10,16,w*0.16)
 local fy=top+(bandH-side)*0.5
 l.flag={bar+pad,fy,bar+pad+side,fy+side}
 local textX=l.flag[3]+gap; local right=w-pad
 -- Delta à droite, sous la version, sa largeur suivant la hauteur disponible ; trop bas pour être lisible, aucun.
 if delta then
  local boxH=math.min(bandH-14,58)
  if boxH>=2*K.deltaBoxMin then
   local boxW=U.clamp(boxH*1.9,70,w*0.26)
   local by=top+12+(bandH-12-boxH)*0.5
   l.delta={right-boxW,by,right,by+boxH}; right=right-boxW-gap
  end
 end
 if pills then l.pills={bar+pad,h-pillH-2,w-pad,h-2} end
 -- Sans delta, le titre s'arrête avant la version (même hauteur) ; la consigne, dessous, va jusqu'au bord.
 local titleH=U.clamp(bandH*0.5,13,40)
 local ty=top+math.max(2,(bandH-titleH-math.max(11,bandH*0.32))*0.5)
 l.title={textX,ty,l.delta and right or math.min(right,l.version[1]-gap),ty+titleH}
 l.fontTitle=math.max(12,titleH*0.82)
 local detailH=U.clamp(bandH*0.32,11,22)
 if bandBottom-l.title[4]>=detailH*0.8 then l.detail={textX,l.title[4],right,math.min(bandBottom,l.title[4]+detailH)}; l.fontDetail=U.clamp(detailH*0.82,10,17) end
 l.fontPill=math.max(K.pillFontMin,pillH*0.62)
 return l
end
-- Badge DRS (jamais un drapeau) : cadre et « DRS » blancs quand il est disponible ; effacé dès que l'aileron s'ouvre.
local function drsBadge(colors,f)
 local p1,p2=vec2(f[1],f[2]),vec2(f[3],f[4])
 ui.drawRectFilled(p1,p2,colors.drsBack,6)
 if callable(ui.drawRect) then ui.drawRect(p1,p2,colors.text,6,nil,3) end
 write('DRS',(f[3]-f[1])*0.36,f,colors.text,CENTER)
end
-- Damier quatre sur quatre (arrivée) ; drapeau de pénalité noir et blanc en diagonale, comme celui d'AC.
local function checker(colors,f)
 local w=(f[3]-f[1])/4; local h=(f[4]-f[2])/4
 for i=0,3 do for j=0,3 do ui.drawRectFilled(vec2(f[1]+i*w,f[2]+j*h),vec2(f[1]+(i+1)*w,f[2]+(j+1)*h),(i+j)%2==0 and colors.text or colors.ink,0) end end
end
local function diagonal(colors,f)
 ui.drawRectFilled(vec2(f[1],f[2]),vec2(f[3],f[4]),colors.ink,5)
 if callable(ui.drawTriangleFilled) then ui.drawTriangleFilled(vec2(f[3],f[2]),vec2(f[3],f[4]),vec2(f[1],f[4]),colors.text)
 else ui.drawRectFilled(vec2((f[1]+f[3])*0.5,(f[2]+f[4])*0.5),vec2(f[3],f[4]),colors.text,0) end
end
-- Drapeau à bandes jaunes et rouges verticales (piste glissante).
local function stripes(colors,f)
 local n=K.slipperyStripes; local w=(f[3]-f[1])/n
 for k=0,n-1 do ui.drawRectFilled(vec2(f[1]+k*w,f[2]),vec2(f[1]+(k+1)*w,f[4]),k%2==0 and colors.yellow or colors.red,0) end
end
-- Texte du delta au centième, virgule décimale, signe toujours affiché ; refait seulement quand la valeur change.
local function deltaText(v,value)
 local hundredths=math.floor(value*100+0.5)
 if hundredths~=v.deltaHundredths then
  v.deltaHundredths=hundredths
  v.deltaText=(string.format('%+.2f',hundredths/100):gsub('%.',L.decimalMark))
  v.deltaPill=string.format(L.deltaPill,v.deltaText)
 end
 return v.deltaText
end
-- Grand cadre du temps delta : vert positif, rouge négatif (fond clignotant).
local function deltaBox(v,colors,r,value,blink)
 -- Signe lu sur la valeur affichée (au centième) : « +0,00 » n'est jamais rouge.
 local negative=math.floor(value*100+0.5)<0
 ui.drawRectFilled(vec2(r[1],r[2]),vec2(r[3],r[4]),negative and blink and colors.overBack or colors.pillBack,5)
 if callable(ui.drawRect) then ui.drawRect(vec2(r[1],r[2]),vec2(r[3],r[4]),negative and colors.over or colors.under,5,nil,2) end
 local h=r[4]-r[2]
 write(L.deltaLabel,h*0.16,{r[1],r[2]+2,r[3],r[2]+h*0.26},colors.dim,CENTER)
 local text=deltaText(v,value)
 write(text,math.min(h*0.5,fitSize(text,h*0.5,(r[3]-r[1])*0.92)),{r[1],r[2]+h*0.22,r[3],r[4]-2},negative and colors.over or colors.under,CENTER)
end
-- Pastilles d'état, de gauche à droite (la plus urgente d'abord) : texte réduit pour qu'elles tiennent sur la ligne,
-- jamais sous une taille lisible ; à défaut, les moins urgentes cèdent leur place.
-- Largeur totale des n premières pastilles (fonction du module : aucune fermeture créée à chaque image).
local function pillsWidth(list,n,size) local sum=0; for k=1,n do sum=sum+textWidth(list[k].text,size)+size*1.4+6 end; return sum end
-- blink : moitié des alternances ; une pastille urgente y prend le fond du bandeau (clignotement).
local function pillRow(row,font,list,count,blink,back)
 local width=row[3]-row[1]
 local need=pillsWidth(list,count,font)
 if need>width then font=math.max(K.pillFontMin,font*width/need) end
 while count>1 and pillsWidth(list,count,font)>width do count=count-1 end
 local x=row[1]
 for k=1,count do
  local item=list[k]; local w=math.min(textWidth(item.text,font)+font*1.4,row[3]-x)
  if w<font*2 then break end
  local p1,p2=vec2(x,row[2]),vec2(x+w,row[4])
  local fill=item.blink and not blink and back or item.fill
  if fill then ui.drawRectFilled(p1,p2,fill,5) end
  if item.edge and callable(ui.drawRect) then ui.drawRect(p1,p2,item.edge,5,nil,1.5) end
  write(item.text,font,{x,row[2],x+w,row[4]},item.color,CENTER)
  x=x+w+6
 end
end
local function pill(v,count,text,color,fill,edge,blinking)
 count=count+1; local item=v.pillItems[count]
 if not item then item={}; v.pillItems[count]=item end
 item.text=text; item.color=color; item.fill=fill; item.edge=edge; item.blink=blinking==true
 return count
end
-- Textes des pastilles qui changent (secondes restantes, écart) : refaits seulement quand la valeur affichée change.
local function giveBackText(v,name,seconds)
 if name~=v.giveBackName or seconds~=v.giveBackSeconds then v.giveBackName=name; v.giveBackSeconds=seconds; v.giveBackText=string.format(L.giveBack,name,seconds) end
 return v.giveBackText
end
local function blueText(v,gap)
 local tenths=math.floor(gap*10+0.5)
 if tenths~=v.blueTenths then v.blueTenths=tenths; v.blueText=string.format(L.blueGap,(string.format('%.1f',tenths/10):gsub('%.',L.decimalMark))) end
 return v.blueText
end
-- Parties de l'overlay (Beta 1.25), en unités de référence (K.hudWidth de large) : ligne de session en haut, bandeau du
-- drapeau, explication ou récapitulatif de course, pastilles. Table réutilisée ; nil : rien à afficher. force : overlay
-- déverrouillé, toujours visible pour être placé.
local parts={}
function M.overlayParts(v,force)
 local e=v.e; local g=e.g; local panel=e.panel; local now=e.time; local hud=e.hud
 local idle=not Panel.visible(panel,g,now)
 parts.idle=idle
 parts.message=g.overlayMessages and hud~=nil and now<hud.msgUntil
 parts.strip=g.overlaySession and hud~=nil and hud.stripCount>0 or parts.message
 parts.band=not idle or g.panelShow=='always' or force==true
 if not parts.band and not parts.strip then return nil end
 parts.recap=parts.band and not idle and panel.finish and g.overlayRecap and hud~=nil and #hud.recap>1
 parts.lines=parts.recap and #hud.recap-1 or parts.band and not idle and g.overlayExplain and panel.explain~='' and 2 or 0
 parts.notice=now<panel.noticeUntil
 parts.giveBack=e.penalties.giveBack>0 and e.frame and e.frame.cars[e.penalties.giveBack] or nil
 parts.pitCall=not idle and panel.kind=='red' and panel.redPit==false
 parts.blueGap=not idle and panel.kind=='blue' and panel.blueGap or nil
 parts.closed=e.incidents.pitsClosed and panel.kind~='red'
 parts.pills=parts.band and (not idle and (panel.noPass or panel.drsBlocked) or parts.notice or parts.giveBack~=nil or parts.pitCall or parts.blueGap~=nil or parts.closed) and true or false
 return parts
end
-- Hauteur de l'overlay en unités de référence.
function M.overlayHeight(p)
 local h=K.hudPad
 if p.strip then h=h+K.hudStripH end
 if p.band then h=h+K.hudBandH end
 if p.lines>0 then h=h+p.lines*K.hudExplainLine+6 end
 if p.pills then h=h+K.hudPillH+4 end
 return h
end
local bold=nil
local function strong(on)
 if bold==nil then bold=callable(ui.pushDWriteFont) and callable(ui.popDWriteFont) and callable(ui.dwriteDrawTextClipped) end
 if bold then if on then ui.pushDWriteFont('Segoe UI;Weight=Bold') else ui.popDWriteFont() end end
end
-- Ligne de session (SuperHUD, bandeau) : libellé discret, valeur en gras, de gauche à droite tant qu'il y a la place ;
-- message d'AC à droite (en rouge s'il signale une faute).
local function sessionStrip(v,colors,e,p,y,w,u)
 local hud=e.hud; local pad=K.hudPad*u; local h=K.hudStripH*u
 ui.drawRectFilled(vec2(pad,y+2*u),vec2(w-pad,y+h-2*u),v.stripColor,4*u)
 local x=pad+8*u; local limit=w-pad-8*u
 if p.message then
  local size=11*u; local mw=math.min(textWidth(hud.msgText,size),(limit-x)*0.6)
  write(hud.msgText,size,{limit-mw,y,limit,y+h},hud.msgIllegal and colors.over or colors.accent,FINISH)
  limit=limit-mw-14*u
 end
 if not e.g.overlaySession then return end
 local ls,vs=9*u,13*u
 for k=1,hud.stripCount do
  local it=hud.strip[k]
  local lw=textWidth(it.label,ls); local vw=textWidth(it.value,vs)
  if x+lw+4*u+vw>limit then break end
  write(it.label,ls,{x,y,x+lw+2,y+h},colors.dim,START)
  strong(true); write(it.value,vs,{x+lw+4*u,y,x+lw+4*u+vw+2,y+h},it.warn and colors.amber or colors.text,START); strong(false)
  x=x+lw+4*u+vw+16*u
 end
end
-- Contenu de l'overlay (Beta 1.25, comme les overlays de SuperHUD) : fond arrondi à l'opacité réglée (opaque, atténué
-- ou transparent), ligne de session, bandeau du drapeau (drapeau, titre, consigne, delta), explication de ce qui se
-- passe ou récapitulatif de course, pastilles ; tout à l'échelle de la largeur. Renvoie la hauteur dessinée (pixels).
function M.flags(v,force)
 local e=v.e; local panel=e.panel; local g=e.g; local now=e.time
 local p=M.overlayParts(v,force)
 if not p then return 0 end
 local alpha=(g.overlayContent or 100)/100
 local colors=panelPalette(alpha)
 if not colors then ui.text(p.idle and L.flagTitles.clear or panel.title); ui.text(p.idle and '' or panel.short); return 0 end
 v.pillItems=v.pillItems or {}
 local size=ui.windowSize(); local start=ui.getCursor()
 local w=size.x; local u=w/K.hudWidth; local top=math.max(0,start.y)
 local idle=p.idle; local kind=idle and 'clear' or panel.kind
 local delta=e.delta.value
 -- Fond : opacité réglée, atténuée ou nulle ; couleurs refaites seulement quand elles changent.
 local mode=g.overlayBackground
 local bgAlpha=mode=='transparent' and 0 or g.panelOpacity/100*(mode=='ghost' and K.hudGhost or 1)
 if v.backAlpha~=bgAlpha or v.stripAlpha~=alpha then
  v.backAlpha=bgAlpha; v.stripAlpha=alpha
  v.backColor=rgbm(0.075,0.079,0.082,0.96*bgAlpha); v.stripColor=rgbm(0,0,0,0.55*math.max(bgAlpha,0.5)*alpha)
 end
 local back=v.backColor
 local height=M.overlayHeight(p)*u
 if bgAlpha>0 then ui.drawRectFilled(vec2(0,top),vec2(w,top+height),back,5*u) end
 local y=top+K.hudPad*0.5*u
 if p.strip then sessionStrip(v,colors,e,p,y,w,u); y=y+K.hudStripH*u end
 if not p.band then v.drawnHeight=height; return height end
 local bandTop=y
 local boxed=delta~=nil
 local l=M.flagLayout(w,y+K.hudBandH*u,y,boxed,false)
 -- Clignotement à 2 Hz : rouge et bleu tout le temps, tout nouveau drapeau quelques secondes.
 local blink=(now*2)%1<0.5
 local flashing=not idle and (kind=='red' or kind=='blue' or now-panel.changedAt<K.flagBlinkTime)
 local flagColor=kind=='drs' and colors.text or kind=='clear' and colors.dim or colors[flagColors[kind] or 'yellow']
 local shown=flashing and not blink and back or flagColor
 local dark=kind=='black' or kind=='penalty' or kind=='checkered'
 local accent=dark and (flashing and not blink and back or colors.text) or shown
 if not v.panelVersion then v.panelVersion=string.format(L.panelVersion,C.release) end
 write(v.panelVersion,9*u,l.version,colors.dim,FINISH)
 local f=l.flag
 if kind=='clear' then if callable(ui.drawRect) then ui.drawRect(vec2(f[1],f[2]),vec2(f[3],f[4]),colors.dim,5*u,nil,2) end
 elseif kind=='drs' then drsBadge(colors,f)
 elseif kind=='slippery' then stripes(colors,f)
 elseif kind=='checkered' then checker(colors,f)
 elseif kind=='penalty' then diagonal(colors,f)
 elseif kind=='black' then
  ui.drawRectFilled(vec2(f[1],f[2]),vec2(f[3],f[4]),colors.ink,5*u)
  if callable(ui.drawRect) then ui.drawRect(vec2(f[1],f[2]),vec2(f[3],f[4]),accent,5*u,nil,2) end
 else
  ui.drawRectFilled(vec2(f[1],f[2]),vec2(f[3],f[4]),shown,5*u)
  local code=kind=='lap' and panel.lapCode or kind=='yellow' and panel.double and '!!' or flagCodes[kind]
  if code and code~='' then write(code,(f[3]-f[1])*(#code>2 and 0.34 or #code>1 and 0.44 or 0.6),f,(kind=='red' or kind=='blue') and colors.text or colors.ink,CENTER) end
 end
 if delta and l.delta then deltaBox(v,colors,l.delta,delta,blink) elseif delta then deltaText(v,delta) end
 local title=idle and L.flagTitles.clear or panel.title; local short=idle and L.flagShort.clear or panel.short
 strong(true); write(title,fitSize(title,l.fontTitle,l.title[3]-l.title[1]),l.title,idle and colors.dim or colors.text,START); strong(false)
 if l.detail then write(short,fitSize(short,l.fontDetail,l.detail[3]-l.detail[1]),l.detail,panel.finish and colors.text or colors.dim,START) end
 y=bandTop+K.hudBandH*u
 -- Explication de ce qui se passe, ou récapitulatif de course (une ligne par élément), alignées sur le titre.
 if p.lines>0 then
  local x1=l.title[1]; local right=w-K.hudPad*u; local lineH=K.hudExplainLine*u
  if p.recap then
   local hud=e.hud
   for k=2,#hud.recap do write(hud.recap[k],12*u,{x1,y,right,y+lineH},k==2 and colors.text or colors.dim,START); y=y+lineH end
  else
   write(panel.explain,11.5*u,{x1,y,right,y+2*lineH},colors.dim,START,true); y=y+2*lineH
  end
  y=y+6*u
 end
 if p.pills then
  local row={l.flag[1],y,w-K.hudPad*u,y+K.hudPillH*u}
  local count=0
  if p.notice then count=pill(v,count,panel.notice,colors.text,colors.overBack,colors.text,true) end
  local giveBack=p.giveBack
  if giveBack then count=pill(v,count,giveBackText(v,giveBack.name~='' and giveBack.name or giveBack.id,math.max(0,math.ceil(e.penalties.giveBackUntil-now))),colors.text,colors.amberBack,colors.amber,true) end
  if delta and not l.delta then
   local late=math.floor(delta*100+0.5)<0
   count=pill(v,count,v.deltaPill,late and colors.over or colors.under,colors.pillBack,late and colors.over or colors.under,late)
  end
  if p.pitCall then count=pill(v,count,L.pitPill,colors.ink,colors.text,nil,true) end
  if p.blueGap then count=pill(v,count,blueText(v,p.blueGap),colors.text,colors.blue,nil,false) end
  if p.closed then count=pill(v,count,L.pitClosedPill,colors.ink,colors.amber,nil,false) end
  if panel.noPass and not idle then
   if panel.passed then count=pill(v,count,panel.passBad,colors.text,colors.overBack,nil,true)
   else count=pill(v,count,panel.passOk,colors.under,colors.pillBack,colors.under,false) end
  end
  if panel.drsBlocked and not idle then count=pill(v,count,panel.drsText,colors.over,colors.pillBack,colors.over,false) end
  pillRow(row,math.max(K.pillFontMin,K.hudPillH*u*0.58),v.pillItems,count,blink,back)
  y=y+K.hudPillH*u+4*u
 end
 -- Bande d'accent à gauche (couleur du drapeau), du bandeau jusqu'en bas.
 ui.drawRectFilled(vec2(0,bandTop),vec2(4*u,math.max(bandTop+1,top+height-2*u)),accent,2*u)
 v.drawnHeight=height
 return height
end
-- Case de session d'AC (tour, temps restant, RACE OVER), masquée tant que la ligne de session de l'overlay la
-- remplace ; rendue dès que ce n'est plus le cas (réglage coupé, overlay masqué, déchargement).
local function nativeBox(v,hide)
 if v.sessionBoxHidden==hide then return end
 if Adapter.sessionBox(hide) then v.sessionBoxHidden=hide end
end
function M.restoreNative(v) if v.sessionBoxHidden then nativeBox(v,false) end end
local function screenSize() return Adapter.screen() or vec2(1920,1080) end
-- Contenu de la fenêtre transparente, puis, déverrouillée : glisser pour déplacer, coin bas droit pour la taille,
-- clic droit pour verrouiller (comme SuperHUD) ; verrouillée sans clics traversants : clic droit pour déverrouiller.
local function hudContent(v)
 local g=v.e.g
 M.flags(v,not g.overlayLocked)
 local w,h=v.hudW,v.hudH
 if not g.overlayLocked then
  local hw=K.hudHandle*g.overlayScale
  ui.setCursor(vec2(0,0)); ui.invisibleButton('##aai_overlay_move',vec2(w,math.max(1,h-hw)))
  local moving=ui.itemActive()
  local lock=ui.itemHovered() and ui.mouseClicked(1)
  ui.setCursor(vec2(0,math.max(0,h-hw))); ui.invisibleButton('##aai_overlay_move2',vec2(math.max(1,w-hw),hw))
  moving=moving or ui.itemActive()
  lock=lock or ui.itemHovered() and ui.mouseClicked(1)
  ui.setCursor(vec2(math.max(0,w-hw),math.max(0,h-hw))); ui.invisibleButton('##aai_overlay_size',vec2(hw,hw))
  local sizing=ui.itemActive()
  if moving or sizing then
   local d=ui.mouseDelta()
   if moving then g.overlayX=v.hudX+d.x; g.overlayY=v.hudY+d.y end
   if sizing then
    local k=math.abs(d.x)>=math.abs(d.y) and d.x/w or d.y/h
    local bounds=C.globalBounds.overlayScale
    g.overlayScale=U.clamp(g.overlayScale*(1+k),bounds[1],bounds[2]); g.overlayX=v.hudX; g.overlayY=v.hudY
   end
   v.hudMoved=true
  elseif v.hudMoved then v.hudMoved=false; C.validateGlobals(g,g); v.dirty() end
  if lock then g.overlayLocked=true; v.dirty() end
  -- Décor déverrouillé : cadre et poignée de taille dans la couleur active des réglages.
  local c=W.colors()
  if callable(ui.drawRect) then ui.drawRect(vec2(0,0),vec2(w,h),c.blue,5*g.overlayScale,nil,1.5) end
  if callable(ui.drawTriangleFilled) then ui.drawTriangleFilled(vec2(w,h-hw),vec2(w,h),vec2(w-hw,h),c.blue) end
  write(L.hudUnlocked,9*g.overlayScale,{0,h-hw,math.max(1,w-hw-4),h},c.blue,FINISH)
 elseif callable(ui.windowHovered) and ui.windowHovered() and ui.mouseClicked(1) then g.overlayLocked=false; v.dirty() end
end
-- Overlay en jeu (Beta 1.25), comme ceux de SuperHUD : fenêtre transparente dessinée par l'app (rappel IN_GAME du
-- manifeste), à la position et à l'échelle réglées (position automatique : centrée, en haut), gardée dans l'écran ;
-- masquée en rediffusion ou aux stands si réglé. Clics traversants une fois verrouillée (réglage).
function M.hud(v)
 local e=v.e; local g=e.g
 if not callable(ui.transparentWindow) then nativeBox(v,false); return end
 local frame=e.frame; local player=frame and frame.player>0 and frame.cars[frame.player] or nil
 local hidden=not frame or frame.replay and g.overlayHideReplay or g.overlayHidePits and player~=nil and player.pit
 local unlocked=not g.overlayLocked
 local p=not hidden and M.overlayParts(v,unlocked) or nil
 nativeBox(v,not hidden and g.overlayNativeBox and g.overlaySession)
 if not p then return end
 local s=g.overlayScale; local w=K.hudWidth*s; local h=M.overlayHeight(p)*s
 local screen=screenSize()
 local x=g.overlayX>=0 and g.overlayX or (screen.x-w)*0.5
 local y=g.overlayY>=0 and g.overlayY or screen.y*K.hudTop
 x=U.clamp(x,0,math.max(0,screen.x-w)); y=U.clamp(y,0,math.max(0,screen.y-h))
 v.hudX=x; v.hudY=y; v.hudW=w; v.hudH=h
 if not v.hudDraw then v.hudDraw=function() hudContent(v) end end
 ui.transparentWindow('ACAdvancedIA_overlay',vec2(x,y),vec2(w,h),true,unlocked or not g.overlayClickThrough,v.hudDraw)
end
return M
