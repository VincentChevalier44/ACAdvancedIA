-- Informations de l'overlay en jeu (Beta 1.25), décisions pures, aucun dessin : passage de la ligne (tour, dernier et
-- meilleur tour), ligne de session (position, tours ou temps restant, meilleur tour, carburant, arrêt obligatoire),
-- messages d'AC repris, récapitulatif de course du joueur (place au départ et à l'arrivée, meilleur tour comparé à
-- tout le plateau, dépassements en piste). Textes refaits seulement quand leur valeur affichée change.
local U=require('src/util')
local C=require('src/config')
local L=require('src/lang')
local K=C.K
local M={}
function M.new()
 return {session=-1,lap=-1,lapUntil=-math.huge,lapTitle='',lapDetail='',lapCode='',lapSerial=0,best=0,
  msgTitle='',msgDetail='',msgText='',msgIllegal=false,msgUntil=-math.huge,msgCount=0,seen={},
  started=false,grid=0,finished=false,dnf=false,dq=false,final=0,passes=0,lost=0,rel={},at=-math.huge,cars=0,
  fieldBest=0,fieldBestName='',recap={},recapSerial=0,recapNew=false,strip={},stripCount=0,stripAt=-math.huge,stripKey=''}
end
-- Temps au tour « 2:01,456 » (séparateur décimal de la langue) ; 0 ou moins : aucun.
function M.lapTime(seconds)
 if not seconds or seconds<=0 then return '' end
 local m=math.floor(seconds/60); local s=seconds-m*60
 return (string.format('%d:%06.3f',m,s):gsub('%.',L.decimalMark))
end
-- Temps restant « 12:34 » (ou « 1:02:03 » au-delà d'une heure).
function M.clock(seconds)
 seconds=math.max(0,math.floor(seconds or 0))
 local h=math.floor(seconds/3600); local m=math.floor(seconds%3600/60); local s=seconds%60
 if h>0 then return string.format('%d:%02d:%02d',h,m,s) end
 return string.format('%d:%02d',m,s)
end
local function reset(h,session)
 h.session=session; h.lap=-1; h.lapUntil=-math.huge; h.best=0; h.seen={}; h.msgUntil=-math.huge
 h.started=false; h.grid=0; h.finished=false; h.dnf=false; h.dq=false; h.final=0; h.passes=0; h.lost=0; h.rel={}
 h.fieldBest=0; h.fieldBestName=''; h.recap={}; h.recapNew=false; h.stripKey=''
end
-- Message d'AC (ac.onMessage) : affiché sur la ligne de session pendant sa durée (bornée) ; renvoie vrai la première
-- fois qu'un titre apparaît dans la session (journal).
function M.message(h,title,description,kind,time,now)
 title=type(title)=='string' and title or ''; description=type(description)=='string' and description or ''
 if title=='' and description=='' then h.msgUntil=-math.huge; return false end
 h.msgTitle=title; h.msgDetail=description; h.msgIllegal=kind=='illegal'
 h.msgText=title~='' and description~='' and title..' · '..description or title~='' and title or description
 h.msgUntil=now+U.clamp(tonumber(time) or K.hudMessageTime,K.hudMessageMin,K.hudMessageMax)
 h.msgCount=math.min(K.counterMax,h.msgCount+1)
 local key=title~='' and title or description
 if h.seen[key] then return false end
 h.seen[key]=true; return true
end
-- AI flood de CSP réglé par l'app (Beta 1.26) : annonce sur la ligne de session.
function M.flood(h,decision,count,range,now)
 local text=decision=='off' and string.format(L.floodOff,count) or decision=='on' and string.format(L.floodOn,count,range) or L.floodRestored
 M.message(h,L.floodTitle,text,nil,K.hudMessageMax,now)
end
-- Dépassements en piste du joueur : progression (tour et position sur le tour) de chaque voiture du même tour à moins
-- de K.recapPassGap m ; un changement d'ordre entre deux relevés proches compte. Stands, saut de position (dépannage),
-- voiture lapée et voiture de sécurité : jamais.
local function passes(h,frame)
 local a=frame.cars[frame.player]
 local mine=a.lap+a.spline
 for j=1,frame.count do
  local b=frame.cars[j]
  if j~=frame.player then
   local d=nil
   if b.valid and b.splineValid and not b.pit and not b.safetyCar and not b.teleport and not a.pit and not a.teleport then
    local rel=(b.lap+b.spline)-mine
    if math.abs(rel)<0.5 and math.abs(rel)*frame.length<=K.recapPassGap then d=rel end
   end
   local before=h.rel[j]
   if d and before then
    if before>0 and d<0 then h.passes=h.passes+1 elseif before<0 and d>0 then h.lost=h.lost+1 end
   end
   h.rel[j]=d
  end
 end
end
-- Récapitulatif (lignes prêtes à afficher et à noter au journal) : félicitations selon la place, places gagnées ou
-- perdues depuis le départ, meilleur tour, dépassements et tours.
local function recap(h,a)
 local lines=h.recap; for k=#lines,1,-1 do lines[k]=nil end
 local place=h.final
 local cheer=h.dq and L.recapCheer.dq or h.dnf and L.recapCheer.dnf or place==1 and L.recapCheer.win or place==2 and L.recapCheer.second
  or place==3 and L.recapCheer.third or place>0 and place<=5 and L.recapCheer.top5 or place>0 and place<=10 and L.recapCheer.top10 or L.recapCheer.other
 lines[1]=cheer
 local gained=h.grid>0 and place>0 and h.grid-place or 0
 local change=gained>0 and string.format(gained>1 and L.recapGained or L.recapGainedOne,gained) or gained<0 and string.format(-gained>1 and L.recapLost or L.recapLostOne,-gained) or L.recapKept
 lines[2]=place>0 and string.format(L.recapPlace,place,h.cars,h.grid>0 and h.grid or place,change) or L.recapNoPlace
 local best=a.bestLap or 0
 if best<=0 then lines[3]=L.recapNoLap
 elseif h.fieldBest<=0 or best<=h.fieldBest+1e-4 then lines[3]=string.format(L.recapFastest,M.lapTime(best))
 else lines[3]=string.format(L.recapBest,M.lapTime(best),M.lapTime(h.fieldBest),h.fieldBestName) end
 lines[4]=string.format(L.recapStats,h.passes,h.lost,math.max(0,a.lap))
 h.recapSerial=h.recapSerial+1; h.recapNew=true
end
-- Ligne de session : éléments {label, valeur, alerte}, refaits au plus toutes les K.hudStripPeriod s.
-- best (Beta 1.38) : valeur en violet (meilleur tour).
local function item(h,label,value,warn,best)
 h.stripCount=h.stripCount+1; local it=h.strip[h.stripCount]
 if not it then it={}; h.strip[h.stripCount]=it end
 it.label=label; it.value=value; it.warn=warn==true; it.best=best==true
end
local function strip(h,frame,e,a)
 h.stripCount=0
 if a.position>0 then item(h,L.hudPosition,string.format('%d/%d',a.position,h.cars)) end
 local race=e.profile=='C'
 if race and frame.sessionLaps>0 and not frame.timedRace then
  item(h,L.hudLap,string.format('%d/%d',math.min(math.max(1,a.lap+1),frame.sessionLaps),frame.sessionLaps))
 elseif frame.left>0 then item(h,L.hudLeft,M.clock(frame.left)) end
 if (a.bestLap or 0)>0 then item(h,L.hudBest,M.lapTime(a.bestLap),false,true) end
 if race and e.run.mandatoryStops>0 and e.pits.cars[frame.player] then
  local done=math.min(e.pits.cars[frame.player].windowStops,e.run.mandatoryStops)
  item(h,L.hudStops,string.format('%d/%d',done,e.run.mandatoryStops),done<e.run.mandatoryStops and e.pits.state=='open')
 end
 if (a.fuelPerLap or 0)>0 and (a.fuel or -1)>=0 then
  local laps=a.fuel/a.fuelPerLap
  item(h,L.hudFuel,(string.format(L.hudFuelLaps,laps):gsub('%.',L.decimalMark)),laps<K.hudFuelWarn)
 end
end
function M.update(h,frame,e,now)
 if frame.session~=h.session then reset(h,frame.session) end
 if frame.player<=0 then h.stripCount=0; return end
 local a=frame.cars[frame.player]
 if not a.valid then return end
 local cars=0; for i=1,frame.count do local b=frame.cars[i]; if b.valid and not b.safetyCar then cars=cars+1 end end
 h.cars=cars
 -- Passage de la ligne : tour suivant, dernier tour (et nouveau meilleur tour) pendant quelques secondes.
 local race=e.profile=='C'
 if h.lap>=0 and a.lap>h.lap and not a.finished and frame.started then
  local laps=race and frame.sessionLaps>0 and not frame.timedRace and frame.sessionLaps or 0
  local shown=a.lap+1
  h.lapTitle=laps>0 and string.format(L.hudLapTitle,math.min(shown,laps),laps) or string.format(L.hudLapOpen,shown)
  h.lapCode=tostring(laps>0 and math.min(shown,laps) or shown)
  local last=a.lastLap or 0
  local record=(a.bestLap or 0)>0 and (h.best<=0 or a.bestLap<h.best-1e-4) and math.abs(a.bestLap-last)<1e-3
  h.lapDetail=last>0 and string.format(record and L.hudLapRecord or L.hudLapDetail,M.lapTime(last),M.lapTime(a.bestLap)) or L.hudLapNoTime
  -- Beta 1.38 : nouveau meilleur tour, consigne en violet dans l'overlay.
  h.lapRecord=last>0 and record==true
  h.lapUntil=now+K.hudLapTime; h.lapSerial=h.lapSerial+1
 end
 h.lap=a.lap
 if (a.bestLap or 0)>0 then h.best=a.bestLap end
 -- Récapitulatif de course : place au premier feu vert de la session (une relance après drapeau rouge ne la change pas).
 if race then
  if not h.started and frame.started and a.position>0 then h.started=true; h.grid=a.position end
  if h.started and not h.finished then
   if now>=h.at then h.at=now+K.recapPeriod; if frame.length>0 then passes(h,frame) end end
   if a.finished or frame.finished then
    h.finished=true; h.dnf=not a.finished; h.dq=e.penalties.disqualified==true; h.final=a.position
    h.fieldBest=0; h.fieldBestName=''
    for i=1,frame.count do
     local b=frame.cars[i]
     if b.valid and not b.safetyCar and (b.bestLap or 0)>0 and (h.fieldBest<=0 or b.bestLap<h.fieldBest) then h.fieldBest=b.bestLap; h.fieldBestName=b.name~='' and b.name or b.id end
    end
    recap(h,a)
   end
  end
 end
 if now>=h.stripAt then h.stripAt=now+K.hudStripPeriod; strip(h,frame,e,a) end
end
return M
