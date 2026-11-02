-- Panneaux lumineux du circuit et signaux FIA propres au joueur (Beta 1.32) : décisions pures, aucune écriture.
-- - Véhicule lent devant le joueur (drapeau blanc) : voiture en piste, ni en incident (c'est le drapeau jaune) ni aux
--   stands ou à leur sortie, nettement sous l'allure apprise à cet endroit (au pas sans allure connue), depuis
--   quelques secondes.
-- - Voiture du joueur endommagée (drapeau noir à disque orange) : annoncée à l'apparition d'un dégât notable.
-- - Valeur du drapeau du joueur pour les panneaux du circuit (entrée FLAG_TYPE des configurations CSP) : rouge, jaune
--   (zone, neutralisation), véhicule lent, piste glissante, bleu, vert ; 0 : drapeau rendu à AC.
-- - Panneaux détectés dans la configuration du circuit : une section qui s'allume sur une condition lue sur FLAG_TYPE.
local U=require('src/util')
local K=require('src/config').K
local Delta=require('src/delta')
local Panel=require('src/panel')
local M={}
-- Importance des valeurs : vers plus important, écrite aussitôt ; vers moins important, après une tenue minimale.
M.rank={[0]=0,[1]=1,[12]=2,[3]=3,[6]=4,[2]=5,[5]=6}
-- Noms au journal.
M.names={[0]='aucun',[1]='vert',[2]='jaune',[3]='piste glissante',[5]='rouge',[6]='vehicule lent',[12]='bleu'}
local neutralNames={sc='voiture de securite',vsc='VSC',fcy='FCY'}
function M.new()
 return {at=-math.huge,last=-math.huge,value=0,reason='',slowFor={},slowSlot=0,slowGap=0,slowKmh=0,
  damaged=false,dSuspension=false,dEngine=false,dGearbox=false,dBody=false,dTyre=false,meatballUntil=-math.huge,
  rel={index=0,long=0,lat=0,gap=0,sa=0,ttc=math.huge,same=false,alongside=false}}
end
function M.reset(l)
 for j in pairs(l.slowFor) do l.slowFor[j]=0 end
 l.slowSlot=0; l.slowGap=0; l.slowKmh=0; l.value=0; l.reason=''; l.last=-math.huge; l.at=-math.huge
 l.damaged=false; l.dSuspension=false; l.dEngine=false; l.dGearbox=false; l.dBody=false; l.dTyre=false; l.meatballUntil=-math.huge
end
function M.rebase(l,amount)
 if U.finite(l.at) then l.at=l.at-amount end
 if U.finite(l.last) then l.last=l.last-amount end
 if U.finite(l.meatballUntil) then l.meatballUntil=l.meatballUntil-amount end
end
-- Véhicule lent le plus proche devant le joueur, dans la portée (ou déjà à sa hauteur) : en piste, roulé depuis le
-- départ, ni en incident ni à la sortie des stands, sous K.slowVehicleRatio de son allure apprise à cet endroit (sous
-- la vitesse d'obstacle sans allure connue) depuis K.slowVehicleTime s. Drapeaux jaunes de l'app actifs seulement.
local function slow(l,inc,frame,p,d,states,multi,dt,now)
 local i=frame.player; local a=i>0 and frame.cars[i] or nil
 local track=a~=nil and p.yellowEnabled==true and a.valid and not a.pit and a.splineValid and frame.length>0 and frame.started
 local best,gap=0,math.huge
 for j=1,frame.count do
  local b=frame.cars[j]; local c=inc.cars[j]; local s=states[j]
  local candidate=track and j~=i and b.valid and not b.pit and not b.finished and b.splineValid and not b.safetyCar
   and c.moved and not c.incident and now>=(s.pitCautionUntil or 0)
  if candidate then
   local pace=Delta.pace(d,states,j,Delta.bin(b.spline),multi)
   candidate=pace>0 and b.speed<pace*K.slowVehicleRatio or pace<=0 and b.kmh<p.obstacleSpeedKmh
  end
  local held=candidate and (l.slowFor[j] or 0)+dt or 0
  l.slowFor[j]=held
  if held>=K.slowVehicleTime then
   local ahead=U.spline(b.spline-a.spline)*frame.length
   if ahead>=-K.slowVehicleBehind and ahead<=K.slowVehicleRange and ahead<gap then best=j; gap=ahead end
  end
 end
 l.slowSlot=best; l.slowGap=best>0 and math.max(0,gap) or 0; l.slowKmh=best>0 and frame.cars[best].kmh or 0
end
-- Dégâts notables du joueur (lus une fois par seconde, dégâts mécaniques activés) : suspension, moteur, boîte,
-- carrosserie lourdement touchée, pneu éclaté. Renvoie vrai à l'apparition d'un nouveau dégât, annoncé quelques
-- secondes (jamais dans la voie des stands) ; une réparation le réarme.
local function damage(l,frame,now)
 local i=frame.player; local a=i>0 and frame.cars[i] or nil
 local known=a~=nil and a.valid and frame.playerDamageSlot==i and (frame.damageRate or 0)>0
 local s=known and (frame.playerSuspension or 0)>=K.meatballSuspension
 local m=known and (frame.playerEngine or K.engineLifeNew)<=K.meatballEngine
 local b=known and (frame.playerGearbox or 0)>=K.meatballGearbox
 local c=known and (frame.playerBody or 0)>=K.meatballBody
 local t=known and frame.playerBlown==true
 local fresh=s and not l.dSuspension or m and not l.dEngine or b and not l.dGearbox or c and not l.dBody or t and not l.dTyre
 l.dSuspension=s; l.dEngine=m; l.dGearbox=b; l.dBody=c; l.dTyre=t
 l.damaged=s or m or b or c or t
 if fresh and not a.pit then l.meatballUntil=now+K.meatballShow; return true end
 return false
end
-- Valeur des panneaux (ac.FlagType) et sa raison au journal. Rouge (5) décidé tel quel : M.output le ramène au jaune
-- tant que les drapeaux d'AC ne sont pas masqués (5 est le drapeau noir de leur affichage).
function M.decide(l,inc,frame,p,profile,now)
 local i=frame.player
 if i==0 then return K.flagNone,'' end
 local a=frame.cars[i]
 -- Arrivée : damier d'AC rendu.
 if not a.valid or a.finished or frame.finished then return K.flagNone,'arrivee' end
 if inc.red then return K.flagStop,'drapeau rouge' end
 if inc.playerYellow then return K.flagCaution,inc.neutral and (neutralNames[inc.neutralMode] or 'neutralisation') or 'drapeau jaune' end
 -- Dernier tour d'une course aux tours : drapeau blanc d'AC rendu, jamais masqué par une information.
 if profile=='C' and frame.sessionLaps>0 and not frame.timedRace and a.lap+1>=frame.sessionLaps then return K.flagNone,'dernier tour' end
 if l.slowSlot>0 then return K.flagSlowVehicle,'vehicule lent' end
 if now<(inc.slipperyUntil or -math.huge) then return K.flagSlippery,'piste glissante' end
 if Panel.blue(l.rel,frame,p,profile,l.value==K.flagFasterCar) then return K.flagFasterCar,'drapeau bleu' end
 if now<(inc.greenUntil or -math.huge) then return K.flagStart,'drapeau vert' end
 return K.flagNone,''
end
-- Tous les K.panelPeriod : véhicule lent, dégâts, valeur des panneaux. Renvoie vrai à l'apparition d'un dégât.
function M.update(l,inc,frame,p,profile,d,states,multi,now)
 if now<l.at then return false end
 local dt=U.finite(l.last) and U.clamp(now-l.last,0,1) or 0
 l.last=now; l.at=now+K.panelPeriod
 slow(l,inc,frame,p,d,states,multi,dt,now)
 local fresh=damage(l,frame,now)
 l.value,l.reason=M.decide(l,inc,frame,p,profile,now)
 return fresh
end
-- Valeur écrite : panneaux du circuit (option, circuit équipé) ; sinon le jaune natif du HUD que le pilote a demandé
-- (préférence d'origine, inchangée). hidden : drapeaux d'AC masqués (CSP), seul cas où le rouge est écrit.
function M.output(l,inc,on,hidden)
 if on then
  local value=l.value
  if value==K.flagStop and hidden~=true then value=K.flagCaution end
  return value,l.reason
 end
 return inc.playerFlag and K.flagCaution or K.flagNone,''
end
-- Lecture d'une configuration de circuit : conditions lues sur FLAG_TYPE (sections [CONDITION_...]), conditions dont
-- se servent les autres sections actives (CONDITION=...), fichiers inclus. out : cumul de plusieurs fichiers.
function M.scan(text,out)
 out=out or {defs={},uses={},includes={}}
 if type(text)~='string' then return out end
 local section,name,input,active,used='',nil,nil,true,nil
 local function close()
  if section:find('^CONDITION') then
   if name and input=='FLAG_TYPE' then out.defs[name]=true end
  elseif used and active then
   for token in used:gmatch('[%w_]+') do out.uses[token]=true end
  end
  name=nil; input=nil; active=true; used=nil
 end
 for line in (text..'\n'):gmatch('([^\n]*)\n') do
  line=line:gsub(';.*$',''):gsub('\r','')
  if not line:find('^%s*//') then
   local header=line:match('^%s*%[([^%]]+)%]')
   if header then
    close(); section=header:upper()
    local include=header:match('^%s*[Ii][Nn][Cc][Ll][Uu][Dd][Ee]%s*:%s*(.-)%s*$')
    if include and include~='' then out.includes[#out.includes+1]=include end
   else
    local key,value=line:match('^%s*([%w_]+)%s*=%s*(.-)%s*$')
    if key then
     key=key:upper()
     if key=='NAME' then name=value:upper()
     elseif key=='INPUT' then input=value:upper()
     elseif key=='ACTIVE' then active=value~='0'
     elseif key=='CONDITION' then used=value:upper()
     elseif key=='INCLUDE' then for item in value:gmatch('[^,]+') do local f=item:match('^%s*(.-)%s*$'); if f~='' then out.includes[#out.includes+1]=f end end end
    end
   end
  end
 end
 close()
 return out
end
-- Équipé : une section active s'allume sur une condition lue sur FLAG_TYPE.
function M.equipped(out)
 for token in pairs(out.uses) do if out.defs[token] then return true end end
 return false
end
return M
