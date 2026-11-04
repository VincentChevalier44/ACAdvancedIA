-- Beta 1.42, fusion : défauts trouvés par la scène de course de bout en bout (tests/race142.lua) et scène elle-même.
-- Chargé par tests/extended.lua.
local F=require('tests/fixture')
local E=require('src/engine')
local C=require('src/config')
local K=C.K
local tests={}
local function logged(e,text) local n=0; for k=1,e.log.limit do local r=e.log[k]; if r and r.message and r.message:find(text,1,true) then n=n+1 end end return n end
local function race(count,laps,lap,settings)
 local e,f=F.scene('C',count or 4)
 -- Beta 1.47 : seuil d'usure de la 1.42 (75 %) gardé pour ces tests (nouveau défaut : 30 %, testé à part).
 e.profiles.C.strategyTyreWearPct=75; e.run.strategyTyreWearPct=75
 f.sessionLaps=laps or 20; f.leaderLaps=lap or 2; f.timedRace=false; f.sessionMinutes=0; f.started=true
 for i=1,f.count do f.cars[i].lap=lap or 2 end
 -- Relecture 1.42 : échelle de l'usure supposée vérifiée en jeu (sa vérification est testée à part, FIXSA_WEAR_TRUST_142).
 e.strategy.wearTrust='trusted'
 if settings then for k,v in pairs(settings) do e.p[k]=v end; E.changed(e) end
 F.tick(e,f,1/60)
 return e,f
end
local function worn(a,w) a.wearKnown=true; a.tyreWear={w,w,w,w}; a.tyreKm={10,10,10,10}; a.tyreTemp={90,90,90,90}; a.tyreOptimum={90,90,90,90} end
-- Fin de course : pas d'arrêt pour quelques tours au-delà du seuil d'usure, ni pour une marge de carburant quand la
-- réserve couvre l'arrivée ; arrêt gardé quand les pneus ou le carburant ne tiennent vraiment pas.
tests.STRATEGY_142_FINAL_STINT=function()
 local function plan(laps,lap,wear,fuel)
  local e,f=race(3,laps,lap)
  local a=f.cars[2]; e.states[2].persona.strategyRisk=0.5; worn(a,wear)
  if fuel then a.fuel=fuel; a.maxFuel=100; a.fuelPerLap=4 end
  local c=e.strategy.cars[2]; c.lap=lap-1; c.lapWear=wear-0.1; c.wearRate=0.1; c.wearLaps=3
  F.tick(e,f,0.2); F.tick(e,f,K.strategyRetry+0.2)
  return c,e
 end
 local c,e=plan(20,16,0.45); assert(c.planned and c.stops==0 and not e.commands[2].rulePit,'4 laps left, 85 % at the flag: no stop')
 c,e=plan(20,12,0.45); assert(c.planned and c.stops==1,'8 laps left: tyres do not last, stop kept')
 c,e=plan(12,11,0.2,11.2); assert(c.planned and c.stops==0 and not e.commands[2].rulePit,'1 lap left, fuel for 2.8 laps: no fuel stop')
 c,e=plan(12,9,0.2,11.2); assert(c.planned and c.stops==1,'3 laps left, fuel for 2.8 laps: fuel stop kept')
end
-- Réactions aux rivaux : jamais à l'entrée aux stands d'un rival qui purge une pénalité, garé (disqualifié) ou sur
-- panne ; couverture seulement avec des pneus entamés.
tests.STRATEGY_142_RIVAL_REASONS=function()
 local function cover(setup,wear)
  local e,f=race(4,30,10)
  F.place(f,2,0,150); F.place(f,3,-60,150); f.cars[2].lap=10; f.cars[3].lap=9
  local a=f.cars[2]; worn(a,wear or 0.3); e.states[2].persona.strategyRisk=0.3
  local c=e.strategy.cars[2]; c.lap=10; c.lapWear=wear or 0.3; c.wearRate=0.1; c.wearLaps=3; c.planned=true; c.stops=1; c.nextLap=12
  e.states[2].nextPerception=0; e.states[3].nextPerception=0; F.tick(e,f,0.2)
  if setup then setup(e,f) end
  f.cars[3].pit=true; F.tick(e,f,0.2)
  return c.wanted and c.cause=='cover'
 end
 assert(cover(),'precondition: covering an ordinary stop')
 assert(not cover(function(e) local sj=e.sanctions.cars[3]; sj.pending='drive'; sj.asked=true end),'no reaction to a penalty pass')
 assert(not cover(function(e) e.penalties.ai.dq[3]=true end),'no reaction to a disqualified car')
 assert(not cover(function(e) e.strategy.cars[3].failState=1 end),'no reaction to a failure stop')
 assert(not cover(nil,0.1),'fresh tyres: no cover')
end
-- Rythme relatif borné : flotte encore lente (départ arrêté) ; jamais un rapport au-delà des bornes, donc jamais une
-- IA normale prise pour une IA anormalement lente.
tests.PACE_RATIO_BOUNDED_142=function()
 local e,f=race(3,20,2)
 local s=e.states[2]; local fleet=e.delta.fleet[1]
 if not fleet then fleet={}; for b=1,e.delta.bins do fleet[b]=0 end; e.delta.fleet[1]=fleet end
 for b=1,e.delta.bins do fleet[b]=12 end
 F.place(f,2,0,190); F.place(f,3,5000,100)
 for _=1,30 do e.states[2].nextPerception=0; F.tick(e,f,1,true) end
 assert(s.longRatioTime>0 and s.longRatio<=K.paceRatioHigh+1e-9,'ratio bounded: '..s.longRatio)
end
-- Scène de course complète : chaque nouveauté jouée au moins une fois, sans erreur ni infraction aux sécurités (vérifiées
-- à chaque image par la scène elle-même).
tests.RACE_SCENE_142=function()
 local _,_,count=require('tests/race142')()
 local need={['strategie: ']=5,['tour de sortie: ']=1,['usure: ']=1,['panne: ']=1,['reparee aux stands']=1,['faux depart']=2,
  ['sanction IA purgee: ']=1,['stands IA: ']=1,['coupure des gaz 5 s']=1,['drapeau noir (contresens)']=1,['drapeau noir (penalite non purgee)']=1,
  ['passage de penalite a l emplacement']=1,['aspiration: ']=1,['fin de course: ']=1,['classement corrige']=1}
 for text,n in pairs(need) do assert(count(text)>=n,text..': '..count(text)) end
end
return tests
