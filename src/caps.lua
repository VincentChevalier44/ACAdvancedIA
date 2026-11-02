local K=require('src/config').K
local M={names={'level','aggression','caution','offset','grip','brake','speed','rain','tyres','pit','stop','flag','flash','park','teleport','penalty','drs','drsActive','brakeMistake','tractionMistake','fuel','fuelSet','startDelay','awake','position','velocity','repairBody','repairSuspension','repairEngine'}}
function M.new(port)
 local c={port=port,native110=false,levelMode='none',probeIndex=0,probeID='',probeAt=0,probeOriginal=1,probeDone=false}
 for _,name in ipairs(M.names) do local available=port.present(name); c[name]={available=available,failures=0,reason=available and 'present' or 'missing'} end
 return c
end
function M.call(c,name,index,value,extra,force)
 local cap=c[name]
 if not cap.available and not (force and cap.reason=='failures') then return false end
 local ok=c.port.write(name,index,value,extra)
 if ok then cap.failures=0; cap.reason='ready'; cap.available=true; return true end
 cap.failures=cap.failures+1
 if cap.failures>=K.capabilityFailures then cap.available=false; cap.reason='failures' end
 return false
end
-- Restitution : tentée même après une série d'échecs ; une écriture réussie remet la capacité en service.
function M.restoreCall(c,name,index,value,extra) return M.call(c,name,index,value,extra,true) end
function M.probe(c,frame,now,g)
 if frame.online or frame.replay or frame.paused then return end
 if c.probeIndex>0 then
  local a=frame.cars[c.probeIndex]
  if a and a.valid and c.probeID~=(a.identity or a.id) then c.probeIndex=0; c.probeDone=false; return end
  if not a or not a.valid or not a.control or a.pit or a.offtrack or frame.online or frame.replay then return end
  if now<c.probeAt then return end
  c.native110=a.aiLevel>=K.probeLevel-K.probeTolerance
  if M.restoreCall(c,'level',a.index,c.probeOriginal) then c.probeIndex=0; c.probeDone=true end
 elseif not c.probeDone and c.level.available then
  for i=1,frame.count do
   local a=frame.cars[i]
   if a.valid and a.control and not a.pit and not a.offtrack and not a.finished and not a.calibrationBlocked then
    c.probeOriginal=a.aiLevel
    if M.call(c,'level',a.index,a.aiLevel) and M.call(c,'level',a.index,K.probeLevel) then c.probeIndex=i; c.probeID=a.identity or a.id; c.probeAt=now+K.probeDelay end
    break
   end
  end
 end
 M.mode(c,g)
end
function M.mode(c,g)
 local desired=g.levelMode
 c.levelMode=c.native110 and (desired=='auto' or desired=='native') and 'native' or ((desired=='auto' or desired=='grip') and g.useGripBoost and c.grip.available and 'grip' or 'none')
end
return M
