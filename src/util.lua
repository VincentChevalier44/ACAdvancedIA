local bit = require('bit')
local M = {}
local abs, min, max = math.abs, math.min, math.max
function M.finite(x) return type(x)=='number' and x==x and abs(x)<math.huge end
function M.clamp(x,a,b) return min(b,max(a,x)) end
function M.number(x,a,b,d) if not M.finite(x) then return d end return M.clamp(x,a,b) end
function M.lerp(a,b,t) return a+(b-a)*M.clamp(t,0,1) end
function M.sign(x) return x>0 and 1 or x<0 and -1 or 0 end
function M.wrap(x) return (x+math.pi)%(2*math.pi)-math.pi end
function M.spline(x) return (x+0.5)%1-0.5 end
function M.approach(x,y,d) return x+M.clamp(y-x,-d,d) end
function M.ema(x,y,dt,tau) return x+(y-x)*(1-math.exp(-dt/max(0.001,tau))) end
-- Multiplication exacte modulo 2^32, sans perte de précision des doubles.
function M.imul(a,b)
  local al,bl=bit.band(a,65535),bit.band(b,65535)
  return bit.tobit(al*bl+bit.lshift(bit.rshift(a,16)*bl+bit.rshift(b,16)*al,16))
end
function M.hash(seed,index,salt)
  local x=bit.bxor(seed,M.imul(index+1,0x9e3779b9),M.imul(salt+1,0x85ebca6b))
  x=M.imul(bit.bxor(x,bit.rshift(x,16)),0x85ebca6b)
  x=M.imul(bit.bxor(x,bit.rshift(x,13)),0xc2b2ae35)
  return bit.bxor(x,bit.rshift(x,16))
end
function M.random(state)
  state=bit.tobit(state+0x6d2b79f5)
  local t=M.imul(bit.bxor(state,bit.rshift(state,15)),bit.bor(state,1))
  t=bit.bxor(t,t+M.imul(bit.bxor(t,bit.rshift(t,7)),bit.bor(t,61)))
  t=bit.bxor(t,bit.rshift(t,14))
  if t<0 then t=t+4294967296 end
  return state,t/4294967296
end
function M.unit(seed,index,salt) local _,v=M.random(M.hash(seed,index,salt)); return v end
function M.newLog(limit,rate,dedup)
  local q={head=0,count=0,second=-1,rateCount=0,limit=limit,rate=rate,dedup=dedup,serial=0}
  for i=1,limit do q[i]={time=-math.huge,level='',message='',index=-1,serial=0} end
  return q
end
function M.log(q,t,level,message,index)
  for n=0,q.count-1 do
    local row=q[(q.head-n-1)%q.limit+1]
    if t-row.time>q.dedup then break end
    if row.level==level and row.message==message and row.index==index then return end
  end
  local s=math.floor(t)
  if q.second~=s then q.second=s; q.rateCount=0 end
  if q.rateCount>=q.rate then return end
  q.rateCount=q.rateCount+1; q.head=q.head%q.limit+1; q.count=min(q.limit,q.count+1)
  -- Numéro croissant : le journal sur disque reprend chaque ligne une seule fois.
  q.serial=q.serial+1
  local r=q[q.head]; r.time=t; r.level=level; r.message=message; r.index=index or -1; r.serial=q.serial
end
-- Découpe un texte en lignes d'au plus width octets, mots entiers, paragraphes conservés. Nom distinct de M.wrap,
-- qui ramène un angle dans [-π, π[ (lecture du cap et du glissement des voitures).
function M.wrapText(source,width)
 local out={}
 for paragraph in (source..'\n'):gmatch('(.-)\n') do
  local line=''
  for word in paragraph:gmatch('%S+') do
   if line~='' and #line+1+#word>width then out[#out+1]=line; line=word else line=line=='' and word or line..' '..word end
  end
  out[#out+1]=line
 end
 return table.concat(out,'\n')
end
return M
