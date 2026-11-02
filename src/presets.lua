local C=require('src/config')
local K=C.K
local M={globalKeys=C.globalRuntimeKeys}
-- Réglages apparus avec la Beta 1.2 (temps delta, DRS par les règles, erreurs de pilotage).
local keys12={'zoneDeltaPct','fcyDeltaPct','vscDeltaPct','redDeltaPct','deltaTolerance','deltaBeeps','rulesDrs','rulesDrsLaps','aiDrs','mistakesEnabled','mistakeRate'}
-- skip : clés ignorées (règles de championnat pour reconnaître un préréglage de session).
function M.signature(profile,p,g,values,skip)
 values=values or {}; local count=1; values[count]=profile
 for _,s in ipairs(C.schema) do if not (skip and skip[s.key]) then count=count+1; values[count]=tostring(p[s.key]) end end
 for _,group in ipairs(C.sections) do count=count+1; values[count]=tostring(p['section_'..group]) end
 count=count+1; values[count]=skip and skip.classPatterns and '' or p.classPatterns
 for _,key in ipairs(M.globalKeys) do count=count+1; values[count]=tostring(g[key]) end
 for i=#values,count+1,-1 do values[i]=nil end
 return table.concat(values,'|')
end
function M.layout()
 local out={name='',profile='J',schemaVersion=C.version,revision=0}
 for key,value in pairs(C.defaults('J')) do out['p_'..key]=value end
 for _,key in ipairs(M.globalKeys) do out['g_'..key]=C.globalDefaults[key] end
 return out
end
function M.decode(store)
 if type(store.name)~='string' or #store.name==0 or #store.name>K.presetNameBytes or store.name:find('%c') then return nil end
 if (tonumber(store.schemaVersion) or 0)>C.version then return nil end
 local profile=store.profile
 if profile~='J' and profile~='P' and profile~='Q' and profile~='C' and profile~='H' then return nil end
 local p,g={},{}
 for key in pairs(C.defaults(profile)) do p[key]=store['p_'..key] end
 for key,value in pairs(C.globalDefaults) do g[key]=value end
 for _,key in ipairs(M.globalKeys) do
  local value=store['g_'..key]
  if key=='debugLog' and value==nil then value=false end -- Programmes antérieurs à rc.4.
  g[key]=value
 end
 local revision=tonumber(store.revision) or 0
 -- Préréglage antérieur à la Beta 1.24 : radar avant activé, comme le nouveau défaut.
 if revision<12 and g.useBrakeAssist==false then g.useBrakeAssist=true end
 if revision<1 then C.upgradeObstacles(p) end
 -- L'ancienne plage 4–6 produisait déjà au plus trois réactions.
 if type(p.flashMaxReactors)=='number' and p.flashMaxReactors>3 and p.flashMaxReactors<=6 then p.flashMaxReactors=3 end
 -- Préréglage antérieur à la 1.5.0 : panneau de drapeaux seul, choix du pilote ; le drapeau jaune natif n'est plus imposé.
 if revision<2 then p.yellowHud=false end
 -- Préréglage antérieur à la 1.8.0 : pénalités absentes avant la 1.6.0, lues avec les valeurs de la journée circuit
 -- (désactivées) ; en essais, qualifications et course, elles reprennent le défaut du profil.
 if revision<3 and not C.solo(profile) and p.playerPenalties==false and p.aiPenalties==false then
  local defaults=C.defaults(profile); p.playerPenalties=defaults.playerPenalties; p.aiPenalties=defaults.aiPenalties
 end
 -- Valeur invalide remplacée par le défaut (PDR §15) : le préréglage reste chargé, l'anomalie est comptée.
 local checked,errors=C.validate(profile,p)
 if revision<4 then
  -- Préréglage des Beta 1.0 et 1.1 (révision 3 jusqu'à la Beta 1.3) : ses clés de la Beta 1.2, absentes, ont été lues
  -- avec les valeurs de la journée circuit (DRS par les règles et erreurs de pilotage coupés) ; toutes à ces valeurs,
  -- elles prennent le défaut du profil. Puis jeux de règles réels de la Beta 1.4.
  if not C.solo(profile) then
   local track=C.defaults('J'); track.mistakesEnabled=false; track.mistakeRate=0.5; local absent=true -- valeurs de la Beta 1.2, figées
   for _,key in ipairs(keys12) do if checked[key]~=track[key] then absent=false; break end end
   if absent then local defaults=C.defaults(profile); for _,key in ipairs(keys12) do checked[key]=defaults[key] end end
  end
  C.migrateRules(profile,checked)
 end
 -- Préréglages enregistrés avant la Beta 1.12 : migrations par profil des révisions 5 à 7 (révision 4 jusqu'à la
 -- Beta 1.8, 6 jusqu'à la Beta 1.11).
 -- Révisions 8 (Beta 1.12 à 1.17), 9 (Beta 1.18) et 10 (Beta 1.19) : restent la voiture de sécurité activée par
 -- défaut et l'espacement élargi (révisions 10 à 12 des données).
 if revision<12 then C.migrateProfile(profile,checked,revision<8 and math.max(4,math.min(revision,7)) or revision+1,true)
 -- Beta 1.29 : préréglage des Beta 1.24 à 1.28 (révision 12) : appels de phares restés aux anciens défauts.
 elseif revision<13 then C.migrateProfile(profile,checked,16,true) end
 local globals,globalErrors=C.validateGlobals(g)
 return {name=store.name,profile=profile,p=checked,g=globals},errors+globalErrors
end
function M.capture(name,profile,p,g)
 if type(name)~='string' then return nil,'name' end
 name=name:gsub('^%s+',''):gsub('%s+$','')
 if name=='' or #name>K.presetNameBytes or name:find('%c') then return nil,'name' end
 return {name=name,profile=profile,p=C.validate(profile,p),g=C.validateGlobals(g)}
end
function M.encode(entry)
 local out=M.layout(); out.name=entry.name; out.profile=entry.profile; out.revision=13
 for key,value in pairs(entry.p) do out['p_'..key]=value end
 for _,key in ipairs(M.globalKeys) do out['g_'..key]=entry.g[key] end
 return out
end
function M.apply(entry,profiles,g)
 C.validate(entry.profile,entry.p,profiles[entry.profile])
 for _,key in ipairs(M.globalKeys) do g[key]=entry.g[key] end
 return entry.profile
end
return M
