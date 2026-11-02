local W=require('tests/workload')
local E=require('src/engine')
local K=require('src/config').K
local prepare,animate=W.prepare,W.animate
-- Même cache du compilateur JIT que l'app en jeu (fichier d'entrée) ; voitures pilotées comme en jeu.
local jitTuned=pcall(require('jit').opt.start,'maxtrace=8000','maxmcode=16384')
return function(clock,progress)
 local e,f=prepare(40); local dt=1/60; local frames=8*3600*60; e.batchCars=jitTuned
 local started=clock(); local stableMin,stableMax=math.huge,0; local lateMin,lateMax=math.huge,0
 for block=1,frames/6000 do
  for _=1,6000 do animate(f,e.time,dt); E.step(e,f,dt); assert(e.errors==0) end
  collectgarbage('collect'); local memory=collectgarbage('count')
  if block>5 then stableMin=math.min(stableMin,memory); stableMax=math.max(stableMax,memory) end
  if block>frames/6000-36 then lateMin=math.min(lateMin,memory); lateMax=math.max(lateMax,memory) end
  if progress and block%20==0 then progress(block*6000,frames,memory) end
 end
 local elapsed=clock()-started
 local memoryCriterion=stableMax-stableMin<256
 local b,bf=prepare(30); local mean,peak,sum=0,0,0; b.batchCars=jitTuned
 for _=1,1000 do animate(bf,b.time,dt); E.step(b,bf,dt) end
 local samples={}
 for sample=1,30000 do
  animate(bf,b.time,dt)
  local before=clock(); E.step(b,bf,dt); local cost=(clock()-before)*1000
  sum=sum+cost; peak=math.max(peak,cost); samples[sample]=cost
 end
 mean=sum/#samples; table.sort(samples)
 -- Course réglée (Beta 1.2) : profil Course, FCY, temps delta du joueur, règles du DRS et DRS des IA, erreurs de
 -- pilotage ; une voiture s'arrête une minute toutes les dix minutes ; le leader boucle un tour toutes les deux.
 local r,rf=prepare(30); r.batchCars=jitTuned; r.g.autoProfile=false; E.select(r,'C')
 local rp=r.profiles.C; rp.neutralization='fcy'; rp.mistakesEnabled=true; rp.mistakeRate=6; rp.rulesDrs=true; rp.aiDrs=true; E.changed(r)
 for i=1,rf.count do rf.cars[i].drsPresent=true end
 local rulesFrames=3600*60; local rulesMin,rulesMax,rulesSum,rulesPeak,neutral,was=math.huge,0,0,0,0,false
 for frame=1,rulesFrames do
  local t=r.time; animate(rf,t,dt); rf.leaderLaps=math.floor(t/120)
  if t%600<60 then local a=rf.cars[2+math.floor(t/600)%(rf.count-1)]; a.distance=a.distance-a.speed*dt; a.kmh=0; a.speed=0; a.spline=(a.distance/rf.length)%1 end
  for i=1,rf.count do local a=rf.cars[i]; a.drsAvailable=a.spline%0.5<0.1; a.brake=a.spline%0.25<0.02 and 1 or 0; a.gas=1-a.brake end; rf.wet=0; rf.rain=0; rf.water=0
  local before=clock(); E.step(r,rf,dt); local cost=(clock()-before)*1000; rulesSum=rulesSum+cost; rulesPeak=math.max(rulesPeak,cost)
  assert(r.errors==0)
  if r.incidents.neutral and not was then neutral=neutral+1 end; was=r.incidents.neutral
  if frame%6000==0 then collectgarbage('collect'); local memory=collectgarbage('count'); if frame>30000 then rulesMin=math.min(rulesMin,memory); rulesMax=math.max(rulesMax,memory) end end
 end
 return {ok=memoryCriterion and mean<0.3 and peak<1,frames=frames,simulatedHours=8,ai=40,seconds=elapsed,meanSoakMs=elapsed*1000/frames,
  memoryMinKB=stableMin,memoryMaxKB=stableMax,memoryDriftKB=stableMax-stableMin,
  memoryCriterion=memoryCriterion,memoryLastHourDriftKB=lateMax-lateMin,
  benchmarkAI=30,benchmarkFrames=#samples,meanMs=mean,peakMs=peak,p99Ms=samples[29700],
  meanCriterion=mean<0.3,peakCriterion=peak<1,errors=e.errors,states=#e.states,paceBins=#e.states[2].pace,
  maxLog=e.log.count,maxDirections=K.directionLimit,
  rulesFrames=rulesFrames,rulesMeanMs=rulesSum/rulesFrames,rulesPeakMs=rulesPeak,rulesNeutralisations=neutral,rulesMemoryDriftKB=rulesMax-rulesMin,
  rulesMemoryMinKB=rulesMin,rulesMemoryMaxKB=rulesMax,rulesErrors=r.errors}
end
