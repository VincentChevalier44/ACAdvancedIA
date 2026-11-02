-- Erreurs de pilotage des IA : blocage des roues au freinage ou patinage en sortie de virage, déclenchés par les
-- fonctions natives de CSP. Fréquence réglée (par heure et par IA), plus forte pour un pilote moins fort, fatigué,
-- distrait (perte de concentration en cours) ou sous la pluie. Jamais sous drapeau ni quelques minutes après une
-- neutralisation, au départ, en sortie des stands, côte à côte, près du joueur, ni deux fois de suite pour la même IA.
-- Décisions pures : l'applicateur écrit, une fois par décision.
local U=require('src/util')
local K=require('src/config').K
local abs,max=math.abs,math.max
local M={}
local function car() return {armedUntil=-math.huge,nextCheck=0,lastAt=-math.huge,cause=''} end
function M.new()
 local t={cars={},lastAt=-math.huge,calmUntil=-math.huge,counter=0}
 for i=1,K.maxCars do t.cars[i]=car() end
 return t
end
function M.reset(t)
 for i=1,K.maxCars do t.cars[i]=car() end
 t.lastAt=-math.huge; t.calmUntil=-math.huge
end
function M.rebase(t,amount)
 if U.finite(t.lastAt) then t.lastAt=t.lastAt-amount end
 if U.finite(t.calmUntil) then t.calmUntil=t.calmUntil-amount end
 for i=1,K.maxCars do
  local c=t.cars[i]
  if U.finite(c.armedUntil) then c.armedUntil=c.armedUntil-amount end
  if U.finite(c.lastAt) then c.lastAt=c.lastAt-amount end
  c.nextCheck=c.nextCheck-amount
 end
end
-- Risque du pilote : niveau (réglé, écart du pilote, grade Pro-Am), fatigue, perte de concentration, pluie. Cause
-- principale retenue pour le journal.
local function risk(s,p,frame,now)
 local skill=p.levelPct/100*(1+s.persona.levelSpread)*(s.persona.gradeLevel or 1)
 local r=U.clamp(1+(1-skill)*K.mistakeSkill,K.mistakeSkillMin,K.mistakeSkillMax)
 local fatigue=s.fatigue or 1
 local lapse=s.lapseUntil>now
 local wet=U.clamp(max(frame.wet or 0,frame.rain or 0),0,1)
 r=r*fatigue*(lapse and K.mistakeLapse or 1)*(1+K.mistakeWet*wet)
 local cause=lapse and 'inattention' or fatigue>1 and 'fatigue' or wet>=K.mistakeWetCause and 'pluie' or skill<K.mistakeWeak and 'pilote moins fort' or 'erreur isolee'
 return r,cause
end
-- Renvoie les IA dont l'erreur vient d'être décidée (commande mistakeId incrémentée), sinon nil.
function M.update(t,e,frame,p,profile,now)
 if not (p.mistakesEnabled and p.section_human) or p.mistakeRate<=0 then return nil end
 local inc=e.incidents
 if inc.neutral or inc.red then t.calmUntil=now+K.mistakeCalm; return nil end
 if now<t.calmUntil or profile=='C' and now-e.startedAt<math.max(p.startDelay+p.startRelax,K.mistakeStartMin) then return nil end
 local player=frame.player>0 and frame.cars[frame.player] or nil
 local near=player and player.valid and not player.pit and player.splineValid and frame.length>0
 local events=nil
 for i=1,frame.count do
  local a=frame.cars[i]; local s=e.states[i]; local c=t.cars[i]; local cmd=e.commands[i]
  local eligible=a.valid and a.control and not a.player and not a.pit and not a.offtrack and not a.finished and not a.safetyCar
   and cmd.active and s.state~='IDLE' and s.state~='CALM' and s.state~='AVOID' and not s.yellow and not s.alongside and not s.disqualified
   and now>=s.pitExitUntil and now>=(e.penalties.ai.slowUntil[i] or 0) and a.kmh>=K.mistakeMinKmh and a.splineValid
  -- Jamais à quelques dizaines de mètres du joueur, devant comme derrière : une erreur ne doit pas le percuter.
  if eligible and near and abs(U.spline(a.spline-player.spline))*frame.length<=K.mistakePlayerGap then eligible=false end
  if not eligible then c.armedUntil=-math.huge
  else
   if now>=c.nextCheck then
    c.nextCheck=now+K.mistakeCheck
    if c.armedUntil<now and now-c.lastAt>=K.mistakeCooldown then
     local r,cause=risk(s,p,frame,now)
     t.counter=t.counter%K.counterMax+1
     if U.unit(e.runtimeG.seed,i,K.mistakeSalt+t.counter)<p.mistakeRate/3600*K.mistakeCheck*r then c.armedUntil=now+K.mistakeArm; c.cause=cause end
    end
   end
   -- Armée : l'erreur survient au prochain gros freinage ou à la prochaine réaccélération en sortie de virage.
   if c.armedUntil>=now and now-t.lastAt>=K.mistakeGap then
    local kind
    if a.brake>=K.mistakeBrakePedal and a.kmh>=K.mistakeBrakeKmh then kind='brake'
    elseif a.gas>=K.mistakeGasPedal and (a.corner or 1)<K.mistakeCorner and a.kmh<=K.mistakeTractionKmh then kind='traction' end
    if kind then
     local u=U.unit(e.runtimeG.seed,i,K.mistakeSalt+K.counterMax-t.counter)
     cmd.mistakeId=cmd.mistakeId%K.counterMax+1; cmd.mistakeKind=kind; cmd.mistakeCause=c.cause
     cmd.mistakeTime=kind=='brake' and U.lerp(K.mistakeBrakeMin,K.mistakeBrakeMax,u) or U.lerp(K.mistakeTractionMin,K.mistakeTractionMax,u)
     cmd.mistakeSeverity=K.mistakeSeverity
     c.armedUntil=-math.huge; c.lastAt=now; t.lastAt=now
     events=events or {}; events[#events+1]=i
    end
   end
  end
 end
 return events
end
return M
