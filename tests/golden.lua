-- Empreinte exacte des sorties du moteur sur un scénario fixe (journée circuit chargée, ou course réglée avec
-- neutralisations, erreurs et DRS) : un nettoyage du code doit la laisser identique ; tout écart est un changement de
-- comportement. Le texte des messages du journal n'entre pas dans l'empreinte (seuls leur nombre et leur préfixe).
local W=require('tests/workload')
local E=require('src/engine')
local function build(mode,count)
 local e,f=W.prepare(count); local dt=1/60
 if mode=='rules' then
  e.g.autoProfile=false; E.select(e,'C')
  local rp=e.profiles.C; rp.neutralization='fcy'; rp.mistakesEnabled=true; rp.mistakeRate=6; rp.rulesDrs=true; rp.aiDrs=true; E.changed(e)
  for i=1,f.count do f.cars[i].drsPresent=true end
 end
 local animate
 if mode=='rules' then
  animate=function()
   local t=e.time; W.animate(f,t,dt); f.leaderLaps=math.floor(t/120)
   if t%600<60 then local a=f.cars[2+math.floor(t/600)%(f.count-1)]; a.distance=a.distance-a.speed*dt; a.kmh=0; a.speed=0; a.spline=(a.distance/f.length)%1 end
   for i=1,f.count do local a=f.cars[i]; a.drsAvailable=a.spline%0.5<0.1; a.brake=a.spline%0.25<0.02 and 1 or 0; a.gas=1-a.brake end; f.wet=0; f.rain=0; f.water=0
  end
 else
  animate=function() W.animate(f,e.time,dt) end
 end
 return e,f,dt,animate
end
return function(mode,count,frames,every)
 local ffi=require('ffi'); local bit=require('bit')
 local u=ffi.new('union { double d; uint32_t w[2]; }')
 local h=0x12345678
 local function mix(x) h=bit.tobit(bit.bxor(bit.rol(h,5),x)*0x01000193) end
 local ids={}; local nextId=0
 local function num(v)
  local t=type(v)
  if t=='number' then u.d=v; mix(u.w[0]); mix(u.w[1])
  elseif t=='boolean' then mix(v and 1 or 2)
  elseif v==nil then mix(3)
  elseif t=='string' then local id=ids[v]; if not id then nextId=nextId+1; id=nextId; ids[v]=id end; mix(1000+id)
  else mix(4) end
 end
 local e,f,dt,animate=build(mode,count)
 local cf={'active','offset','level','aggression','caution','brake','speedLimit','yellowLimit','drsBlock','drsWant','mistakeId','stopHold','rulePit','pitHold'}
 local sf={'state','reason','offset','target','yellow','class','paceCount','stuck','trafficLimit','alongside'}
 local out={}
 for fr=1,frames do
  animate(); num(E.step(e,f,dt))
  for i=1,f.count do
   local c=e.commands[i]; for k=1,#cf do num(c[cf[k]]) end
   local s=e.states[i]; for k=1,#sf do num(s[sf[k]]) end
   local r=e.perception.rows[i]; num(r.left); num(r.right); num(r.nearest); num(r.count)
  end
  num(e.delta.value); num(e.delta.kind); num(e.delta.infraction); num(e.panel.kind)
  num(e.incidents.neutral); num(e.incidents.zoneCount); num(e.penalties.count); num(e.log.serial); num(e.errors); num(e.activeCount)
  local msg=e.log.count>0 and e.log[e.log.head] and e.log[e.log.head].message or ''
  num((msg:match('^[^:]*')))
  if fr%every==0 then out[#out+1]=string.format('%d:%08x',fr,bit.band(h,0xffffffff)) end
 end
 local st={}; for k,v in pairs(e.stats) do st[#st+1]=k..'='..v end; table.sort(st)
 return string.format('%s %d IA %d images, erreurs %d\n  stats %s\n  empreintes %s',mode,count,frames,e.errors,table.concat(st,','),table.concat(out,' '))
end
