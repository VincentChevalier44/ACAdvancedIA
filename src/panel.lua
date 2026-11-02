-- Panneau de drapeaux du joueur : décisions pures, aucun dessin. Priorité : rouge, noir et pénalités d'AC, voiture de
-- sécurité, FCY ou VSC (et sa fin), jaune, reprise jusqu'à la ligne, damier, piste glissante, bleu, DRS, dernier tour,
-- vert, départ, arrêt obligatoire. Textes reconstruits seulement quand le drapeau ou sa
-- valeur arrondie change. Le temps delta lui-même est lu à chaque image par l'interface (module delta).
local U=require('src/util')
local C=require('src/config')
local L=require('src/lang')
local P=require('src/perception')
local Classes=require('src/classes')
local K=C.K
local M={}
function M.new() return {kind='none',key='',title='',detail='',raw='',noPass=false,passed=false,drsBlocked=false,drsUsed=false,short='',passOk='',passBad='',infractions=-1,infractionMax=-1,notice='',noticeUntil=-math.huge,at=-math.huge,
 changedAt=-math.huge,double=false,explain='',finish=false,lapCode='',info=nil,drsText='',drsLaps=-1,drsLapsText='',redPit=false,blueGap=nil,rel={index=0,long=0,lat=0,gap=0,sa=0,ttc=math.huge,same=false,alongside=false}} end
-- Drapeau bleu du joueur, en course : une voiture plus rapide qui lui prend au moins un tour arrive derrière. Renvoie
-- son écart en secondes (distance à sa vitesse), sinon nil.
local function blue(panel,frame,p,profile)
 if profile~='C' or not p.blueFlagEnabled or frame.player==0 or frame.length<=0 then return nil end
 local a=frame.cars[frame.player]
 if not a.valid or a.pit or not a.splineValid then return nil end
 local best=nil
 for j=1,frame.count do
  local b=frame.cars[j]
  if j~=frame.player and b.valid and not b.pit and b.splineValid then
   local r=P.relative(a,b,frame.length,panel.rel)
   -- Hystérésis : un drapeau bleu affiché reste tant que la voiture qui double ne s'éloigne pas, même collée derrière.
   if r.same and r.long<0 and r.gap>=0 and r.gap<=p.blueFlagRange and (r.sa>=K.lapSpeed or panel.kind=='blue' and r.sa>-K.lapSpeed) and Classes.laps(a,b,r,frame.length)>0 then
    local gap=r.gap/math.max(1,b.speed)
    if not best or gap<best then best=gap end
   end
  end
 end
 return best
end
-- Drapeaux et pénalités natifs d'AC (Beta 1.11) : repris par le panneau, leur affichage d'origine étant masqué dans
-- CSP. Renvoie le genre et sa valeur (tours ou secondes), ou nil ; le jaune que l'app impose au joueur n'est pas repris.
local function native(panel,frame,now)
 local f=frame.flag
 -- Départ : levé toute la session en hotlap ; repris quelques secondes à son apparition seulement.
 if f~=K.flagStart then panel.startSeen=nil elseif not panel.startSeen then panel.startSeen=now end
 local a=frame.player>0 and frame.cars[frame.player] or nil
 local penalty=a and a.penaltyType or 0; local n=a and a.penaltyParam or 0
 if f==K.flagStop or penalty==K.penaltyBlackFlag then return 'black',0 end
 if penalty==K.penaltyMandatoryPits and n>0 then return 'penaltyDrive',n end
 if penalty==K.penaltyTeleportToPits and n>0 then return 'penaltyTeleport',n end
 if penalty==K.penaltySlowDown and n>0 then return 'penaltySlow',n end
 if penalty>0 or f==K.flagReturnToPits then return 'penalty',0 end
 if f==K.flagFinished then return panel.info and panel.info.finished and 'finish' or 'checkered',0 end
 if f==K.flagCaution and not frame.flagOwned then return 'native',0 end
 if f==K.flagFasterCar then return 'nativeBlue',0 end
 if f==K.flagOneLapLeft then return 'white',0 end
 if f==K.flagStart and now-panel.startSeen<K.greenShow then return 'start',0 end
 return nil,0
end
-- Genre affiché (couleur, sigle, titre) de chaque genre décidé.
local shownKinds={scCall='sc',penaltyDrive='penalty',penaltyTeleport='penalty',penaltySlow='penalty',nativeBlue='blue',start='green',finish='checkered'}
-- Drapeau retenu : genre affiché, horodatage du changement, textes refaits seulement quand le genre ou la valeur change.
-- profile : essais et qualifications parlent de séance, pas de course (drapeau rouge, reprise).
local function show(panel,kind,value,double,gap,now,profile)
 local shown=shownKinds[kind] or kind
 if shown~=panel.kind then panel.changedAt=now end
 panel.kind=shown; panel.double=double; panel.blueGap=gap; panel.redPit=kind=='red' and value==1; panel.finish=kind=='finish'
 -- Passage de la ligne et fin de course (Beta 1.25) : textes tenus par les informations de l'overlay.
 local info=panel.info
 if kind=='lap' and info then value=info.lapSerial elseif kind=='finish' and info then value=info.recapSerial end
 local session=profile=='P' or profile=='Q'
 local key=kind..'|'..value..'|'..(double and 1 or 0)..(session and '|s' or '')
 if key~=panel.key then
  panel.key=key
  if kind=='lap' and info then
   panel.title=info.lapTitle; panel.raw=info.lapDetail; panel.detail=info.lapDetail; panel.short=info.lapDetail; panel.explain=''; panel.lapCode=info.lapCode
  elseif kind=='finish' and info then
   panel.title=L.flagTitles.finish; panel.raw=info.recap[1] or ''; panel.detail=panel.raw; panel.short=panel.raw; panel.explain=''
  elseif kind~='none' then
   panel.title=kind=='yellow' and double and L.flagTitles.yellow2 or L.flagTitles[panel.kind]
   local detail
   if kind=='drs' then detail=L.flagDetails.drs
   elseif kind=='yellow' then detail=string.format(double and L.flagDetails.yellow2 or L.flagDetails.yellow,value)
   elseif kind=='red' then detail=value==1 and (session and L.flagDetails.redSessionPit or L.flagDetails.redPit) or (session and L.flagDetails.redSession or L.flagDetails.red)
   elseif kind=='green' and session then detail=L.flagDetails.greenSession
   else detail=string.format(L.flagDetails[kind],value) end
   panel.raw=detail; panel.detail=U.wrapText(detail,K.panelWrap)
   -- Consigne courte du bandeau (une ligne).
   local short=kind=='red' and (value==1 and (session and 'redSessionPit' or 'redPit') or (session and 'redSession' or 'red'))
    or kind=='green' and session and 'greenSession' or kind=='yellow' and double and 'yellow2' or kind
   panel.short=string.format(L.flagShort[short],value)
   -- Explication de ce qui se passe (Beta 1.25), sous la consigne : jaune, double jaune, neutralisations, rouge...
   local explain=kind=='yellow' and double and 'yellow2' or kind=='red' and (session and 'redSession' or 'red') or kind
   panel.explain=L.flagExplain[explain] or ''
  else panel.explain='' end
 end
end
-- Panneau réduit aux drapeaux d'AC : onglet Règles ou panneau décoché, app à l'arrêt (aucune commande, session finie,
-- panique, pause, hotlap). Ni dépassement interdit ni règles du DRS ; badge DRS du joueur si sa préférence est cochée.
function M.native(panel,frame,now,p)
 if now<panel.at then return end
 panel.at=now+K.panelPeriod
 local kind,value=native(panel,frame,now)
 local a=frame.player>0 and frame.cars[frame.player] or nil
 if a and a.drsActive then panel.drsUsed=true elseif not (a and a.drsAvailable) then panel.drsUsed=false end
 if not kind and panel.info and panel.info.finished then kind='finish' end
 if not kind and panel.info and now<panel.info.lapUntil then kind='lap' end
 if not kind and (not p or p.drsAssist~=false) and a and a.valid and a.drsPresent and a.drsAvailable and not a.drsActive and not panel.drsUsed then kind='drs'; value=1 end
 show(panel,kind or 'none',value,false,nil,now)
 panel.noPass=false; panel.drsBlocked=false
end
-- Informations non urgentes : effacées après la durée réglée (0 : tant qu'elles durent) ; les drapeaux restent.
local infoKinds={green=true,drs=true,white=true,checkered=true,slippery=true,lap=true}
-- Overlay à afficher : un drapeau ou une information encore dans sa durée d'affichage.
function M.visible(panel,g,now)
 if panel.kind=='none' then return false end
 local hold=g and g.panelInfoTime or 0
 return not (infoKinds[panel.kind] and not panel.finish and hold>0 and now-panel.changedAt>=hold)
end
-- Ligne « Dépassement interdit » avec le compteur d'infractions du joueur (textes refaits seulement s'il change).
function M.infractions(panel,count,max)
 if count==panel.infractions and max==panel.infractionMax then return end
 panel.infractions=count; panel.infractionMax=max
 local suffix=count>0 and string.format(L.infractionCount,count,max) or ''
 panel.passOk=L.noPassing..suffix; panel.passBad=L.passMade..suffix
end
-- Pénalité du joueur : ligne rouge sous la consigne pendant quelques secondes.
function M.notice(panel,reason,seconds,now) panel.notice=string.format(L.penaltyNotice[reason],seconds); panel.noticeUntil=now+K.noticeTime end
function M.update(panel,t,frame,p,profile,now)
 if not p.flagPanel then return M.native(panel,frame,now,p) end
 if now<panel.at then return end
 panel.at=now+K.panelPeriod
 local kind,value,double='none',0,false
 local a=frame.player>0 and frame.cars[frame.player] or nil
 local reason=t.drsReason or ''
 local present=p.drsAssist and a and a.valid and a.drsPresent or false
 -- DRS : badge tant qu'il est disponible et fermé ; effacé dès l'ouverture, jusqu'à la fin de la zone (l'aileron se
 -- referme au freinage alors que la zone est encore active).
 if a and a.drsActive then panel.drsUsed=true elseif not (a and a.drsAvailable) then panel.drsUsed=false end
 local drs=present and reason=='' and a.drsAvailable and not a.drsActive and not panel.drsUsed or false
 local gap=nil
 local nk,nv=native(panel,frame,now)
 if t.red then kind='red'; value=a and a.pit and 1 or 0
 -- Drapeau noir et pénalités d'AC : propres au joueur, avant toute neutralisation.
 elseif nk=='black' or nk=='penalty' or nk=='penaltyDrive' or nk=='penaltyTeleport' or nk=='penaltySlow' then kind=nk; value=nv
 elseif t.neutral then
  if t.neutralMode=='sc' then
   local merging=t.safetyPhase=='call' or t.safetyPhase=='out' and t.safety>0 and frame.cars[t.safety].pit
   kind=t.safetyPhase=='in' and 'scIn' or merging and 'scCall' or 'sc'
  elseif t.neutralMode=='vsc' then kind=t.ending and 'vscEnd' or 'vsc'; value=p.vscDeltaPct
  else kind='fcy'; value=p.fcyDeltaPct end
 elseif t.playerZone then
  -- Double jaune : incident en piste (delta de zone) ; simple jaune : incident hors piste.
  double=t.playerZoneDouble==true
  if t.playerInside then kind=double and 'zone' or 'zone1' else kind='yellow'; value=math.floor((t.playerToZone or 0)/10+0.5)*10 end
 -- Drapeau jaune natif d'AC (voiture lente ou arrêtée qu'il signale sans incident de l'app) : affiché aussi, jamais
 -- le drapeau que l'app impose elle-même au joueur.
 elseif nk=='native' then kind='native'
 -- Reprise derrière la voiture de sécurité : vert, dépassement interdit jusqu'à la ligne.
 elseif t.playerRestart then kind='restart'
 -- Course terminée (Beta 1.25) : damier et récapitulatif du joueur, jusqu'à la fin de la session.
 elseif panel.info and panel.info.finished and profile=='C' then kind='finish'
 elseif nk=='checkered' or nk=='finish' then kind='checkered'
 elseif now<(t.slipperyUntil or -math.huge) then kind='slippery'
 else
  gap=blue(panel,frame,p,profile)
  if gap then kind='blue'
  elseif nk=='nativeBlue' then kind='nativeBlue'
  -- Passage de la ligne (Beta 1.25) : tour suivant et temps, quelques secondes.
  elseif panel.info and now<panel.info.lapUntil then kind='lap'
  elseif drs then kind='drs'; value=1
  elseif nk=='white' then kind='white'
  elseif now<t.greenUntil then kind='green'
  elseif nk=='start' then kind='start'
  -- Rappel d'arrêt obligatoire : jamais à la place d'un drapeau, du bleu ou du DRS.
  elseif t.playerPitRemind then kind='pit'; value=t.playerPitDue or 0 end
 end
 show(panel,kind,value,double,gap,now,profile)
 -- Drapeau et zone DRS en même temps : le drapeau reste affiché, avec une ligne « DRS interdit sous drapeau ».
 local calm=kind=='none' or kind=='green' or kind=='blue' or kind=='pit' or kind=='slippery' or kind=='nativeBlue' or kind=='white' or kind=='start' or kind=='checkered' or kind=='finish' or kind=='lap'
 -- Règles de course : pluie et premiers tours affichés avec tout drapeau ; sinon « DRS interdit sous drapeau ».
 panel.drsBlocked=kind~='none' and kind~='drs' and (reason~='' and present and (reason~='flag' or not calm) or reason=='' and drs and not calm)
 if reason=='wet' then panel.drsText=L.drsWet
 elseif reason=='laps' then
  if t.drsLapsLeft~=panel.drsLaps then panel.drsLaps=t.drsLapsLeft; panel.drsLapsText=string.format(L.drsLapsLeft,t.drsLapsLeft) end
  panel.drsText=panel.drsLapsText
 else panel.drsText=L.drsBlocked end
 -- Régimes où doubler est interdit : ligne dédiée, verte, rouge si le joueur a doublé.
 -- Drapeaux d'AC propres au joueur (noir, pénalité) : pas de ligne de dépassement de l'app.
 panel.noPass=not calm and kind~='drs' and kind~='native' and panel.kind~='black' and panel.kind~='penalty' and (kind~='yellow' or t.playerNoPass==true)
end
return M
