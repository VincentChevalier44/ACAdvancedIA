-- Kit de dessin des fenêtres de réglage (même langage visuel que SuperHUD) : canevas virtuel de 1000 px de large mis à
-- l'échelle de la fenêtre, commandes dessinées (boutons, interrupteurs, curseurs), le bleu comme seule couleur d'état
-- actif, aide au survol (une seule infobulle par image, la plus précise l'emporte). Les zones qui défilent sont
-- découpées et suivent la molette ; aucun texte n'est reconstruit d'une image à l'autre quand rien ne change.
local W={}
-- active : dernier état allumé de chaque bouton et interrupteur dessiné (surbrillance vérifiable).
local f={ox=0,oy=0,s=1,w=1000,h=700,tip=nil,tipPriority=-1,boldDepth=0,clip=nil,id='aai',active={}}
local palette
function W.colors()
 if not palette then
  palette={blue=rgbm(0.20,0.59,1,1),light=rgbm(0.92,0.94,0.96,1),grey=rgbm(0.58,0.63,0.65,1),bg=rgbm(0.08,0.085,0.087,0.98),
   field=rgbm(0.15,0.16,0.17,1),hover=rgbm(0.22,0.25,0.28,1),line=rgbm(0.22,0.24,0.26,1),dark=rgbm(0.02,0.07,0.12,1),
   warn=rgbm(1,0.77,0.21,1),red=rgbm(0.86,0.18,0.20,1),green=rgbm(0.30,0.80,0.45,1),panel=rgbm(0.105,0.111,0.117,1),
   knob=rgbm(0.35,0.40,0.45,1),off=rgbm(0.29,0.32,0.34,1),fill=rgbm(0.20,0.59,1,0.25),idle=rgbm(0.20,0.59,1,0.12)}
 end
 return palette
end
-- Canevas : largeur virtuelle fixe, échelle tirée de la largeur (bornée), hauteur virtuelle déduite de la fenêtre.
function W.begin(id)
 local raw=ui.getCursor(); local space=ui.availableSpace()
 f.id=id; f.ox=raw.x; f.oy=raw.y
 f.s=math.max(0.5,math.min(space.x/1000,2))
 f.w=1000; f.h=math.max(400,space.y/f.s)
 f.tip=nil; f.tipPriority=-1; f.clip=nil
 ui.drawRectFilled(raw,vec2(raw.x+space.x,raw.y+space.y),W.colors().bg,0)
 return f
end
function W.frame() return f end
function W.point(x,y) return vec2(f.ox+x*f.s,f.oy+y*f.s) end
function W.rect(x,y,w,h,col,r)
 if w>0 and h>0 then ui.drawRectFilled(W.point(x,y),W.point(x+w,y+h),col,(r or 0)*f.s) end
end
function W.line(x,y,x2,y2,col,th) ui.drawLine(W.point(x,y),W.point(x2,y2),col,(th or 1)*f.s) end
function W.circle(x,y,r,col) ui.drawCircleFilled(W.point(x,y),r*f.s,col,20) end
function W.bold(on)
 if on then ui.pushDWriteFont('Segoe UI;Weight=Bold'); f.boldDepth=f.boldDepth+1
 elseif f.boldDepth>0 then ui.popDWriteFont(); f.boldDepth=f.boldDepth-1 end
end
function W.text(str,x,y,size,col,bold)
 if bold then W.bold(true) end
 ui.dwriteDrawText(str,(size or 13)*f.s,W.point(x,y),col or W.colors().light)
 if bold then W.bold(false) end
end
local function width(str,size) return ui.measureDWriteText(str,size*f.s).x/f.s end
W.width=width
-- Texte tronqué à la largeur donnée, terminé par « … » ; découpe mémorisée par texte, largeur et taille.
local cut={}
local cutCount=0
local function fitted(str,w,size)
 local key=str..'\1'..w..'\1'..size..'\1'..f.s
 local hit=cut[key]
 if hit then return hit end
 local out=str
 if width(str,size)>w then
  local chars={}
  for ch in str:gmatch('[%z\1-\127\194-\244][\128-\191]*') do chars[#chars+1]=ch end
  local lo,hi=0,#chars
  while lo<hi do
   local mid=math.floor((lo+hi+1)/2)
   if width(table.concat(chars,'',1,mid)..'…',size)<=w then lo=mid else hi=mid-1 end
  end
  out=table.concat(chars,'',1,lo)..'…'
 end
 cutCount=cutCount+1; if cutCount>2000 then cut={}; cutCount=0 end
 cut[key]=out
 return out
end
function W.cell(str,x,y,w,size,col,bold)
 if bold then W.bold(true) end
 W.text(fitted(str,w,size or 13),x,y,size,col)
 if bold then W.bold(false) end
end
-- Paragraphe coupé aux mots dans la largeur donnée ; renvoie la hauteur utilisée. Coupes mémorisées.
local wrapped={}
local wrappedCount=0
function W.lines(str,w,size)
 local key=str..'\1'..w..'\1'..size..'\1'..f.s
 local hit=wrapped[key]
 if hit then return hit end
 local out={}
 for paragraph in (str..'\n'):gmatch('([^\n]*)\n') do
  local line=''
  for word in paragraph:gmatch('%S+') do
   local candidate=line=='' and word or line..' '..word
   if line~='' and width(candidate,size)>w then out[#out+1]=line; line=word else line=candidate end
  end
  out[#out+1]=line
 end
 wrappedCount=wrappedCount+1; if wrappedCount>500 then wrapped={}; wrappedCount=0 end
 wrapped[key]=out
 return out
end
function W.paragraph(str,x,y,w,size,col)
 size=size or 12
 local list=W.lines(str,w,size)
 for i,line in ipairs(list) do W.text(line,x,y+(i-1)*size*1.45,size,col) end
 return #list*size*1.45
end
-- Aide au survol : la région la plus prioritaire sous la souris fournit l'infobulle de l'image.
local function inside(x,y,w,h)
 local m=ui.mouseLocalPos(); local a,b=W.point(x,y),W.point(x+w,y+h)
 if m.x<a.x or m.x>=b.x or m.y<a.y or m.y>=b.y then return false end
 local c=f.clip
 if c then local ca,cb=W.point(c[1],c[2]),W.point(c[1]+c[3],c[2]+c[4]); if m.y<ca.y or m.y>=cb.y or m.x<ca.x or m.x>=cb.x then return false end end
 return true
end
function W.help(text,x,y,w,h,priority)
 if text and text~='' and inside(x,y,w,h) and (priority or 2)>=f.tipPriority then f.tip=text; f.tipPriority=priority or 2 end
end
-- Zone cliquable : bouton invisible natif (identifiant stable, clic gauche), survol et clic droit.
function W.hit(id,x,y,w,h)
 ui.setCursor(W.point(x,y))
 local clicked=ui.invisibleButton('##aai_'..id,vec2(math.max(1,w*f.s),math.max(1,h*f.s)))
 local hovered=ui.itemHovered()
 return clicked==true,hovered==true,ui.itemActive()==true,hovered and ui.mouseClicked(1)==true
end
function W.button(id,label,x,y,w,h,active,tip,style)
 local c=W.colors()
 local clicked,hover,_,right=W.hit(id,x,y,w,h)
 f.active[id]=active==true
 local fill=style=='danger' and (active and c.red or hover and c.hover or c.field) or active and c.blue or hover and c.hover or c.field
 W.rect(x,y,w,h,fill,3)
 local size=h>=36 and 14 or h>=26 and 12 or 11
 local text=active and style~='danger' and c.dark or c.light
 W.bold(true)
 -- Libellé trop long (selon la langue) : police réduite jusqu'à 9 px avant de le couper (« … »).
 while size>9 and width(label,size)>w-12 do size=size-1 end
 local tw=math.min(width(label,size),w-12)
 W.text(fitted(label,w-12,size),x+(w-tw)/2,y+(h-size*1.25)/2,size,text)
 W.bold(false)
 W.help(tip,x,y,w,h,5)
 return clicked,right
end
-- Interrupteur en pastille, libellé à gauche.
function W.toggle(id,label,x,y,w,on,tip)
 local c=W.colors()
 local clicked,hover=W.hit(id,x,y,w,30)
 f.active[id]=on==true
 if hover then W.rect(x,y,w,30,c.hover,2) end
 W.cell(label,x+8,y+7,w-60,13,on and c.light or c.grey,true)
 W.rect(x+w-42,y+8,32,15,on and c.blue or c.off,8)
 W.circle(x+w-34+(on and 16 or 0),y+15.5,5,on and c.dark or c.grey)
 W.help(tip,x,y,w,30,5)
 return clicked
end
function W.pill(x,y,on)
 local c=W.colors()
 W.rect(x,y,32,15,on and c.blue or c.off,8)
 W.circle(x+8+(on and 16 or 0),y+7.5,5,on and c.dark or c.grey)
end
-- Curseur dessiné : glisser pour régler ; la valeur est arrondie au pas. Renvoie la nouvelle valeur ou nil.
function W.slider(id,x,y,w,value,lo,hi,step,label,tip)
 local c=W.colors()
 local _,hover,active,right=W.hit(id,x,y,w,22)
 local result
 if active and ui.mouseDown(0) then
  local mx=(ui.mouseLocalPos().x-f.ox)/f.s
  local t=math.max(0,math.min(1,(mx-x)/w))
  local v=lo+t*(hi-lo)
  if step and step>0 then v=lo+math.floor((v-lo)/step+0.5)*step end
  -- Extrémités atteintes exactement, même quand la plage n'est pas un multiple du pas.
  if t>=1 then v=hi elseif t<=0 then v=lo end
  v=math.max(lo,math.min(hi,v))
  if math.abs(v-value)>1e-9 then result=v end
 end
 local ratio=hi>lo and math.max(0,math.min(1,(value-lo)/(hi-lo))) or 0
 W.rect(x,y,w,22,c.field,2)
 W.rect(x,y,w*ratio,22,active and c.fill or c.idle,2)
 W.rect(x+w*ratio-2,y+2,4,18,(hover or active) and c.blue or c.knob,1)
 local size=11
 local tw=width(label,size)
 W.text(label,x+(w-tw)/2,y+4,size,c.light)
 W.help(tip,x,y,w,22,5)
 return result,right
end
-- Zone qui défile : contenu dessiné entre top et top+height, décalé de offset ; la molette au-dessus la fait défiler.
function W.scroll(state,key,x,y,w,h,content)
 local offset=state[key] or 0
 local maximum=math.max(0,content-h)
 if inside(x,y,w,h) then
  local wheel=ui.mouseWheel()
  if wheel~=0 then offset=offset-wheel*60 end
 end
 offset=math.max(0,math.min(maximum,offset)); state[key]=offset
 if maximum>0 then
  local c=W.colors(); local bar=math.max(30,h*h/content)
  W.rect(x+w-5,y,4,h,c.field,2); W.rect(x+w-5,y+(h-bar)*offset/maximum,4,bar,c.knob,2)
 end
 return offset
end
function W.clip(x,y,w,h)
 if x then ui.pushClipRect(W.point(x,y),W.point(x+w,y+h),true); f.clip={x,y,w,h}
 else ui.popClipRect(); f.clip=nil end
end
function W.visible(y,h)
 local c=f.clip
 return not c or y>=c[2] and y+h<=c[2]+c[4]
end
-- Fin d'image : infobulle unique, police rendue, curseur placé sous le canevas (aucune surface de défilement native).
function W.finish()
 while f.boldDepth>0 do W.bold(false) end
 if f.clip then W.clip() end
 if f.tip then ui.setTooltip(f.tip) end
 ui.setCursor(W.point(0,0))
end
-- Pas d'un réglage numérique : entier pour les clés entières, sinon 1, 2 ou 5 × 10^n proche du centième de la plage.
function W.step(lo,hi,integer)
 if integer then return 1 end
 local raw=(hi-lo)/100
 local power=10^math.floor(math.log10(raw))
 local unit=raw/power
 return (unit<1.5 and 1 or unit<3.5 and 2 or unit<7.5 and 5 or 10)*power
end
return W
