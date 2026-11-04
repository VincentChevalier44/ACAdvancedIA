-- Premier tour attentif (Beta 1.47, idée du pilote : « sur le premier tour, tout le monde est vraiment très
-- attentif ») : en course, au départ et à chaque relance (drapeau vert derrière la voiture de sécurité, fin du tour de
-- relance d'un drapeau rouge, extinction des feux d'un départ arrêté), chaque IA roule en mode attentif jusqu'à son
-- premier passage de la ligne (passage dans les K.firstLapLineGrace premières secondes ignoré : relance juste avant
-- la ligne), jusqu'à ce que le peloton soit étiré autour d'elle (plus de K.firstLapSpread s devant et derrière
-- pendant K.firstLapSpreadTime s), ou au plus K.firstLapMax s ; entrée aux stands : fini. Puis le mode est rendu en
-- K.firstLapRelease s. Les effets sont lus par le directeur (s.flW, poids de 0 à 1 ; s.flApproach) : écart en temps,
-- anticipation de chaque freinage du tour, radar qui lève le pied d'abord, ni défense ni aspiration cassée ni air
-- sale, dépassements seulement en vraie ligne droite, évitement seulement d'une voiture arrêtée ou très lente,
-- agressivité plafonnée. Points de freinage du tour : appris en direct, là où une IA libre devant (personne à moins
-- de K.firstLapPointFree s) freine depuis K.firstLapPointKmh km/h au moins ; aucune distance fixe.
-- Journal : une ligne au début, une à la fin (pour tout le peloton), compteurs dans le résumé de la minute.
local U=require('src/util')
local K=require('src/config').K
local max,abs=math.max,math.abs
local M={}
function M.new() return {on=false,age=0,kind='',armed=0,why={ligne=0,etire=0,delai=0,stands=0},points={},count=0,restartSerial=0} end
function M.reset(fl) fl.on=false; fl.age=0; fl.kind=''; fl.armed=0; fl.count=0; for k in pairs(fl.why) do fl.why[k]=0 end end
-- Début du mode : chaque IA en piste, avec son tour du moment ; points de freinage oubliés.
function M.arm(e,frame,now,kind)
 local fl=e.fl
 if e.profile~='C' or not e.run.firstLapCare then return false end
 M.reset(fl); fl.on=true; fl.kind=kind
 for i=1,frame.count do
  local a=frame.cars[i]; local s=e.states[i]
  s.flOn=false; s.flW=0; s.flCare=0; s.flApproach=false; s.flBrakeWas=false
  if a.valid and a.control and not a.player and not a.safetyCar and not a.pit and not a.finished then
   s.flOn=true; s.flW=1; s.flLap=a.lap or 0; s.flAge=0; s.flSpread=0; fl.armed=fl.armed+1
  end
 end
 if fl.armed==0 then fl.on=false; return false end
 U.log(e.log,now,'INFO',string.format('premier tour: mode attentif pour %d IA (%s) : ecart en temps, anticipation des freinages, radar en levee de pied, ni defense ni depassement au freinage',fl.armed,kind),-1)
 return true
end
local function finish(fl,s,why) s.flOn=false; fl.why[why]=fl.why[why]+1 end
-- Point de freinage du tour (fraction de tour), fusionné avec un point voisin.
local function addPoint(fl,spline,length)
 local merge=K.firstLapPointMerge/max(1,length)
 for j=1,fl.count do if abs(U.spline(fl.points[j]-spline))<=merge then return end end
 if fl.count>=K.firstLapPoints then return end
 fl.count=fl.count+1; fl.points[fl.count]=spline
end
-- Distance (m) jusqu'au prochain point de freinage connu devant la voiture ; math.huge sans point.
function M.nextPoint(fl,a,length)
 if not a.splineValid or length<=0 then return math.huge end
 local best=math.huge
 for j=1,fl.count do local d=((fl.points[j]-a.spline)%1)*length; if d<best then best=d end end
 return best
end
-- Écart en temps (s) d'une voisine : distance sur la vitesse de la voiture (plancher K.firstLapSpeedMin m/s).
function M.headway(gap,speed) return gap/max(speed,K.firstLapSpeedMin) end
-- Avant le pilotage de chaque image : fin du mode par voiture, rendu progressif, points de freinage, fin au journal.
function M.update(e,frame,now,dt)
 local fl=e.fl
 if not fl.on then return end
 fl.age=fl.age+dt
 local rows=e.perception.rows
 local alive=false
 for i=1,frame.count do
  local a=frame.cars[i]; local s=e.states[i]
  if s.flOn then
   s.flAge=s.flAge+dt
   if not a.valid or a.pit then finish(fl,s,'stands')
   elseif (a.lap or 0)>s.flLap then
    if s.flAge<K.firstLapLineGrace then s.flLap=a.lap else finish(fl,s,'ligne') end
   elseif s.flAge>=K.firstLapMax then finish(fl,s,'delai')
   else
    local row=rows[i]; local spread=true
    for j=1,row.count do local r=row.neighbors[j]; if r.gap<K.firstLapSpread*max(a.speed,K.firstLapSpeedMin) then spread=false; break end end
    s.flSpread=spread and s.flSpread+dt or 0
    if s.flSpread>=K.firstLapSpreadTime then finish(fl,s,'etire') end
   end
  end
  if not s.flOn and s.flW>0 then s.flW=max(0,s.flW-dt/K.firstLapRelease); if s.flW==0 then s.flApproach=false; s.flCare=0 end end
  if s.flOn or s.flW>0 then
   alive=true
   -- Point de freinage : IA libre devant (aucune voisine devant à moins de K.firstLapPointFree s) qui freine elle-même
   -- depuis une vitesse de ligne droite.
   local own=a.brake>(s.appBrake or 0)+K.brakeEcho and a.brake or 0
   local braking=own>K.ruleBrake
   if braking and not s.flBrakeWas and a.kmh>=K.firstLapPointKmh and (a.corner or 1)>=K.firstLapPointCorner and a.splineValid then
    local row=rows[i]; local free=true
    for j=1,row.count do local r=row.neighbors[j]; if r.long>0 and abs(r.lat)<=K.latPass and M.headway(r.gap,a.speed)<K.firstLapPointFree then free=false; break end end
    if free then addPoint(fl,a.spline,frame.length) end
   end
   s.flBrakeWas=braking
  end
 end
 if not alive then
  fl.on=false
  U.log(e.log,now,'INFO',string.format('premier tour: fin du mode attentif apres %.0f s (%d IA : ligne franchie %d, peloton etire %d, delai %d, stands %d ; %d point(s) de freinage appris)',
   fl.age,fl.armed,fl.why.ligne,fl.why.etire,fl.why.delai,fl.why.stands,fl.count),-1)
 end
end
return M
