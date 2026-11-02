local U=require('src/util')
local K=require('src/config').K
local M={}
-- Grammaire de données seulement : return { {from=...,to=...,...}, ... }.
-- Aucun environnement Lua ni exécution de texte utilisateur.
function M.parse(text)
 if type(text)~='string' or #text>K.maxZoneBytes then return nil,'size' end
 local pos,len=1,#text
 local function skip()
  while pos<=len do
   local a,b=text:find('^%s+',pos)
   if a then pos=b+1 elseif text:sub(pos,pos+1)=='--' then
    local e=text:find('\n',pos+2,true); pos=e and e+1 or len+1
   else break end
  end
 end
 local function token(s) skip(); if text:sub(pos,pos+#s-1)==s then pos=pos+#s; return true end return false end
 local function value()
  skip(); local c=text:sub(pos,pos)
  if c=='"' or c=="'" then
   pos=pos+1; local start=pos
   while pos<=len and text:sub(pos,pos)~=c do
    if text:sub(pos,pos)=='\\' or text:byte(pos)<32 then return nil end
    pos=pos+1
   end
   if pos>len or pos-start>256 then return nil end
   local s=text:sub(start,pos-1); pos=pos+1; return s
  end
  if token('true') then return true end
  if token('false') then return false end
  skip(); local a,b=text:find('^[%+%-]?%d*%.?%d+[eE]?[%+%-]?%d*',pos)
  if not a then return nil end
  local n=tonumber(text:sub(a,b)); pos=b+1
  if not U.finite(n) then return nil end
  return n
 end
 token('return')
 if not token('{') then return nil,'syntax' end
 local wrapped=token('zones')
 if wrapped and (not token('=') or not token('{')) then return nil,'wrapper' end
 local out={}
 while true do
  if token('}') then break end
  if #out>=K.maxZones or not token('{') then return nil,'count' end
  local zone={noYield=false,noOvertake=false,maxOffset=1,note=''}; local seen={}
  while not token('}') do
   skip(); local a,b=text:find('^[%a_][%w_]*',pos)
   if not a then return nil,'key' end
   local key=text:sub(a,b); pos=b+1
   if not ({from=true,to=true,noYield=true,noOvertake=true,maxOffset=true,note=true})[key] or seen[key] or not token('=') then return nil,'key' end
   local v=value(); if v==nil then return nil,'value' end
   if key=='from' or key=='to' or key=='maxOffset' then
    if not U.finite(v) or v<0 or v>1 then return nil,'range' end
   elseif key=='note' then if type(v)~='string' then return nil,'type' end
   elseif type(v)~='boolean' then return nil,'type' end
   zone[key]=v; seen[key]=true
   if not token(',') and not token(';') then skip(); if text:sub(pos,pos)~='}' then return nil,'separator' end end
  end
  if not seen.from or not seen.to then return nil,'endpoints' end
  out[#out+1]=zone
  if not token(',') and not token(';') then skip(); if text:sub(pos,pos)~='}' then return nil,'separator' end end
 end
 if wrapped and not token('}') then return nil,'wrapper' end
 skip(); if pos<=len then return nil,'trailing' end
 return out
end
function M.at(zones,progress,out)
 out.noYield=false; out.noOvertake=false; out.maxOffset=1
 for i=1,#zones do
  local z=zones[i]
  if (z.from<=z.to and progress>=z.from and progress<=z.to) or (z.from>z.to and (progress>=z.from or progress<=z.to)) then
   out.noYield=out.noYield or z.noYield; out.noOvertake=out.noOvertake or z.noOvertake; out.maxOffset=math.min(out.maxOffset,z.maxOffset)
  end
 end
 return out
end
function M.export(zones)
 local lines={'return { zones = {'}
 for i=1,math.min(#zones,K.maxZones) do
  local z=zones[i]
  lines[#lines+1]=string.format('  { from=%.6f, to=%.6f, noYield=%s, noOvertake=%s, maxOffset=%.3f, note="%s" },',z.from,z.to,tostring(z.noYield),tostring(z.noOvertake),z.maxOffset,(z.note or ''):gsub('["\\%c]',''))
 end
 lines[#lines+1]='} }'; return table.concat(lines,'\n')
end
return M
