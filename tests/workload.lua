-- Charge commune aux mesures courtes et au soak : aucune copie du moteur.
local F=require('tests/fixture')
local M={}
function M.prepare(count)
 local e,f=F.scene('J',count+1)
 e.p.section_traffic=true; e.p.enduranceOverlay=true; e.p.multiClass=true
 f.length=math.pi*2000; f.commands=e.commands
 for i=1,f.count do
  local a=f.cars[i]; a.distance=(i-1)*f.length/f.count; a.pace=90+(i%4)*25
  a.tyresKnown=true; a.dryCompound=0; a.interCompound=i%3==0 and 1 or -1; a.wetCompound=i%3==0 and 2 or -1
  a.compoundIndex=0; a.nativeRainTyresKnown=true; a.nativeRainTyres=false
 end
 return e,f
end
function M.animate(f,t,dt)
 f.wet=(math.sin(t/3600)+1)*0.5
 f.rain=f.wet>0.5 and f.wet*0.25 or 0; f.water=f.wet*f.wet*0.1
 for i=1,f.count do
  local a=f.cars[i]
  a.kmh=math.min(a.pace*(1+0.04*math.sin(t/41+i)),f.commands[i].speedLimit); a.speed=a.kmh/3.6
  a.distance=a.distance+a.speed*dt; a.spline=(a.distance/f.length)%1; a.lap=math.floor(a.distance/f.length)
  local angle=a.spline*math.pi*2
  a.x=1000*math.sin(angle); a.z=1000*math.cos(angle); a.lx=math.cos(angle); a.lz=-math.sin(angle)
  a.yawRate=a.speed/1000; a.pit=i>1 and (t+i*23)%900<3
 end
end
return M
