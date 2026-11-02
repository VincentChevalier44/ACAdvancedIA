local U=require('src/util')
local M={version=3,release='Beta 1.33',profiles={'J','P','Q','C','H'},schema={},sections={'general','yield','blue','flash','overtake','lateral','human','start','accidents','rules','endurance','weather','traffic','globals'}}
local sectionKeys={}
for _,group in ipairs(M.sections) do sectionKeys[group]='section_'..group end
M.globalRuntimeKeys={'overrideAwareness','useGripBoost','useBrakeAssist','gripPerLevelPct','occLatMin','occLatMax','occMargin','occSpeedGain','seed','levelMode','debugLog'}
-- Préréglages : chaque onglet qui agit dans la session est coché. Départ n'agit qu'en course, Espacement qu'en
-- journée circuit ; la cession ordinaire est sans objet en course, les drapeaux bleus par tours hors course.
-- Les options physiques globales restent désactivées.
local presetSections={
 Nordschleife={general=true,yield=true,flash=true,overtake=true,lateral=true,human=true,accidents=true,rules=true,endurance=true,weather=true,traffic=true},
 Qualifications={general=true,yield=true,flash=true,overtake=true,lateral=true,human=true,accidents=true,rules=true,endurance=true,weather=true},
 -- Essais : mêmes onglets que les qualifications, sessions d'essais seules ou de week-end.
 Essais={general=true,yield=true,flash=true,overtake=true,lateral=true,human=true,accidents=true,rules=true,endurance=true,weather=true},
 Course={general=true,blue=true,flash=true,overtake=true,lateral=true,human=true,start=true,accidents=true,rules=true,endurance=true,weather=true}}
-- Valeurs propres à un préréglage, au-delà des valeurs par défaut du profil. Multi-classes partout : sans écart
-- d'allure d'au moins classGapPct, une grille d'une seule classe reste une seule classe.
local presetValues={
 Nordschleife={multiClass=true},Qualifications={multiClass=true},Course={multiClass=true,overtakeSide='auto'},
 Essais={multiClass=true,levelPct=97,aggressionPct=40,paceSpreadPct=6,lapseEnabled=true,overtakeChain=true}}
-- Version 1.2.0 des préréglages intégrés, figée : un profil resté identique est mis à jour une seule fois.
local legacySections={
 Nordschleife={general=true,yield=true,flash=true,overtake=true,lateral=true,human=true,start=true,weather=true,traffic=true},
 Qualifications={general=true,yield=true,flash=true,overtake=true,lateral=true,human=true,start=true,weather=true},
 Essais={general=true,yield=true,flash=true,overtake=true,lateral=true,human=true,start=true,weather=true},
 Course={general=true,blue=true,flash=true,overtake=true,lateral=true,human=true,start=true,weather=true}}
local legacyGroups={general=true,yield=true,blue=true,flash=true,overtake=true,lateral=true,human=true,start=true,endurance=true,weather=true,traffic=true,globals=true}
local legacyCandidates={J={'Nordschleife','Endurance'},P={'Essais'},Q={'Qualifications'},C={'Course','Endurance'}}
-- Règles de course : valeurs par catégorie, appliquées ensemble aux profils Essais, Qualifications et Course.
M.ruleCategories={'base','F1','F1_2026','GT','Endurance'}
M.ruleProfiles={'P','Q','C'}
-- Valeurs tirées des règlements (F1 2025 et 2026, WEC 2026, GT World Challenge 2026) : double jaune au temps de secteur
-- +15 % (F1, défaut de toutes les catégories) ; FCY réelle à 80 km/h fixes, rendue par un delta +150 % (du même ordre
-- sur la plupart des circuits) ; Slow Zone d'endurance à 80 km/h ; stands fermés sous FCY (GT et WEC) et pendant trois
-- tours de voiture de sécurité (WEC 2026, art. 14.5) ; stands ouverts sous FCY en GT World Challenge (SRO 2026, art. 39.4 :
-- seule la FCY courte les ferme) ; arrêt GT Sprint entre 25 et 35 min sur 60, sans temps minimal ; F1 sans fenêtre
-- (arrêt fait avant 95 % de la course), pneus changés sous drapeau rouge ; F1 2025 avec DRS ; F1 2026 avec Overtake Mode
-- et aileron mobile sans attente (pluie et drapeaux le coupent toujours). Ravitaillement interdit en F1 (depuis 2010) et en
-- GT World Challenge Sprint : plein prévu au départ ; autorisé en endurance (WEC) : ravitaillement à l'arrêt,
-- libre au fil de la course (fin de relais, réservoir), pneus neufs et réparations à chaque arrêt (Beta 1.20). Voiture de
-- sécurité en escalade : VSC, FCY ou zone jaune d'abord, voiture de sécurité si l'incident s'aggrave, comme le fait la
-- direction de course ; activée par défaut en course avec tous les jeux de règles (Beta 1.19).
M.rulePresets={
 base={},
 F1={neutralization='vsc',mandatoryStops=1,pitWindowOpenPct=20,pitWindowClosePct=95,pitCompoundChange=true,redFlagWork=true,pitFuel='plan'},
 F1_2026={neutralization='vsc',mandatoryStops=1,pitWindowOpenPct=20,pitWindowClosePct=95,pitCompoundChange=true,redFlagWork=true,overtakeMode=true,rulesDrsLaps=0,pitFuel='plan'},
 GT={neutralization='fcy',fcyDeltaPct=150,mandatoryStops=1,pitWindowOpenPct=42,pitWindowClosePct=58,bopEnabled=true,proAmEnabled=true,pitFuel='plan'},
 Endurance={neutralization='fcy',fcyDeltaPct=150,slowZoneKmh=80,yellowSpeedKmh=80,maxStintMin=50,pitsClosed='pitFcySc',bopEnabled=true,proAmEnabled=true,predictableSlowClass=true,pitFuel='refuel',pitTyres=true,pitRepair=true}}
-- Préréglage intégré appliqué une fois à un profil jamais réglé, lorsque la détection l'active.
M.recommended={J='Nordschleife',P='Essais',Q='Qualifications',C='Course'}
-- Réglages qui comptent quelque chose (réactions, voitures, arrêts) : valeurs entières.
M.integerKeys={flashMaxReactors=true,redFlagCars=true,mandatoryStops=true,penaltySeconds=true,penaltyDisqualify=true,rulesDrsLaps=true}
-- Réglages des pénalités (jamais en journée circuit) et de la surcouche Endurance (journée circuit et course).
M.penaltyKeys={playerPenalties=true,deltaTolerance=true,penaltySeconds=true,penaltyDisqualify=true,aiPenalties=true}
M.overlayKeys={enduranceOverlay=true,stintLevelSwing=true,stintDegradationPct=true}
-- Réglages sans effet dans un profil : masqués dans l'interface et ramenés à leur valeur par défaut (pénalités en
-- journée circuit, surcouche Endurance en essais et en qualifications).
-- Sessions hors week-end de course (journée circuit, hotlap) : ni pénalités, ni règles de championnat.
function M.solo(profile) return profile=='J' or profile=='H' end
-- Répartition des IA (Beta 1.26) : ni en course ni en hotlap ; portée d'AI flood de CSP en journée circuit seulement.
M.spawnKeys={spawnMode=true,spawnMinCars=true,spawnPitPct=true,spawnGapVariation=true,floodRangeKm=true}
function M.hidden(profile,key) return M.solo(profile) and M.penaltyKeys[key] or (profile=='P' or profile=='Q' or profile=='H') and M.overlayKeys[key] or (profile=='C' or profile=='H') and M.spawnKeys[key] or key=='floodRangeKm' and profile~='J' or false end
-- Préférences du pilote (panneau, messages, drapeau du HUD, DRS) : conservées au chargement d'un préréglage intégré.
M.preferenceKeys={'flagPanel','yellowHud','yellowMessage','pitMessage','drsAssist','drsBeepVolume','deltaBeeps'}
-- Clés ajoutées depuis la 1.3.0 (préréglages personnels antérieurs et préréglages intégrés 1.2.0).
local newKeys={}
local function add(group,key,label,lo,hi,j,q,c,choices)
  -- Profil Essais (P) : valeurs préparées des qualifications.
  -- Profil Hotlap (H) : valeurs de la journée circuit (aucune IA dans ces sessions).
  M.schema[#M.schema+1]={group=group,sectionKey=sectionKeys[group],key=key,label=label,min=lo,max=hi,defaults={J=j,P=q,Q=q,C=c,H=j},choices=choices}
  if newKeys.open then newKeys[key]=true end
end
local function n(g,k,l,a,b,j,q,c) add(g,k,l,a,b,j,q,c) end
local function b(g,k,l,j,q,c) add(g,k,l,nil,nil,j,q,c) end
local function e(g,k,l,j,q,c,opts) add(g,k,l,nil,nil,j,q,c,opts) end
n('general','levelPct','Niveau (%)',40,110,95,100,100)
n('general','aggressionPct','Agressivité (%)',0,100,55,45,80)
n('general','caution','Prudence',0.5,8,1.6,2.2,1.2)
n('general','brakeZonePct','Zone de freinage émulée (%)',50,150,100,100,100)
n('general','paceSpreadPct','Dispersion du niveau (%)',0,20,8,3,2)
n('general','aggrSpreadPct','Dispersion d’agressivité (%)',0,30,12,8,10)
n('general','cautSpreadPct','Dispersion de prudence (%)',0,30,12,8,8)
newKeys.open=true
n('general','pitExitSpread','Sorties des stands étalées, essais et qualifications (s par IA, 0 = libre)',0,30,0,10,0)
-- Beta 1.26 (demande du pilote) : répartition des IA en début de session, à partir de spawnMinCars IA : sur tout le
-- circuit (défaut en journée circuit), sorties des stands étalées (défaut en essais et qualifications) ou laissée au
-- jeu ; jamais en course (départ sur la grille). Portée d'AI flood de CSP en journée circuit, sous le seuil.
e('general','spawnMode','Répartition des IA en début de session','track','pits','native',{'native','pits','track'})
n('general','spawnMinCars','Répartir à partir de (IA)',2,60,10,10,10)
n('general','spawnPitPct','IA laissées aux stands au départ (%)',0,50,25,25,25)
n('general','spawnGapVariation','Variation des écarts au départ (%)',0,100,100,100,100)
n('general','floodRangeKm','Portée d’AI flood de CSP, sous le seuil (km)',1,5,1,1,1)
newKeys.open=nil
b('yield','yieldEnabled','Cession ordinaire',true,true,false)
e('yield','yieldSide','Côté de cession','right','right','right',{'left','right','auto'})
n('yield','yieldOffset','Décalage de cession',0.2,0.95,0.65,0.8,0.6)
n('yield','yieldDetectBehind','Détection arrière (m)',30,400,100,200,80)
n('yield','yieldBehindMargin','Avantage du suiveur (km/h)',1,30,6,4,6)
n('yield','yieldHorizon','Horizon arrière (s)',3,30,10,12,8)
n('yield','confirmTime','Confirmation (s)',0.1,2,0.6,0.4,0.5)
n('yield','yieldHoldMin','Maintien minimal (s)',0.3,5,1,1,1)
n('yield','yieldHoldAfterMin','Maintien après passage min. (s)',0.2,6,0.8,0.6,0.8)
n('yield','yieldHoldAfterMax','Maintien après passage max. (s)',0.2,6,2.2,1.6,1.8)
n('yield','yieldSlowdownPct','Ralentissement en cession (%)',0,20,6,8,6)
n('yield','inviteSlowdownPct','Invitation supplémentaire (%)',0,25,10,10,10)
n('yield','yieldMaxHold','Durée maximale de cession (s)',8,60,25,25,25)
b('yield','pressureEnabled','Réaction à la pression',true,true,false)
n('yield','pressureGap','Distance de pression (m)',5,30,15,15,15)
n('yield','pressureTime','Durée de pression (s)',1,15,4,3,4)
b('blue','blueFlagEnabled','Drapeaux bleus',false,true,true)
n('blue','blueFlagRange','Portée du drapeau bleu (m)',50,400,150,200,150)
e('blue','blueFlagSide','Côté sous drapeau bleu','auto','auto','auto',{'auto','left','right'})
e('flash','flashMode','Appels de phares','always','always','lapped',{'never','lapped','always'})
n('flash','flashRange','Portée des appels (m)',40,250,200,200,150)
n('flash','flashMinAdvantage','Avantage pour appel (km/h)',3,40,12,8,15)
n('flash','flashCloseAdvantage','Avantage à courte distance (km/h)',-10,15,-5,-5,6)
n('flash','flashRequestTTL','Durée d’une demande (s)',3,20,8,8,8)
n('flash','flashObliviousPct','Inattention au premier appel (%)',0,40,10,5,10)
n('flash','flashMaxReactors','Nombre de réactions',1,3,3,3,3)
b('flash','hornEnabled','Klaxon en complément',false,false,false)
newKeys.open=true
b('flash','aiFlashEnabled','Appels de phares entre IA',true,true,true)
newKeys.open=nil
b('overtake','overtakeEnabled','Dépassements',true,true,true)
e('overtake','overtakeSide','Côté de dépassement','left','left','left',{'opposite','auto','left','right'})
n('overtake','overtakeOffset','Décalage de dépassement',0.2,0.95,0.7,0.65,0.6)
n('overtake','overtakeDetectAhead','Détection avant (m)',20,200,60,50,50)
n('overtake','overtakeAheadMargin','Avantage pour dépasser (km/h)',1,30,8,10,3)
n('overtake','overtakeHorizon','Horizon avant (s)',2,20,6,6,6)
n('overtake','overtakeClearMargin','Marge après dépassement (m)',8,40,18,20,10)
n('overtake','overtakeRestTime','Repos après dépassement (s)',0,10,2,3,1)
b('overtake','overtakeChain','Enchaîner les dépassements',true,false,true)
n('overtake','stuckTime','Confirmation de retenue (s)',0.5,10,2,3,1.2)
n('overtake','stuckPaceRatio','Seuil d’allure retenue',0.8,0.99,0.93,0.93,0.95)
n('overtake','pullOutGapBase','Distance de déboîtement (m)',4,15,8,8,8)
n('overtake','pullOutGapPerMps','Gain de déboîtement (s)',0,0.5,0.25,0.25,0.25)
b('overtake','slipstreamEnabled','Aspiration',true,true,true)
b('overtake','defenseEnabled','Défense',true,true,true)
n('overtake','defenseMaxOffset','Décalage maximal de défense',0.1,0.5,0.35,0.35,0.35)
n('overtake','defenseCooldown','Repos entre défenses (s)',2,30,8,8,8)
n('overtake','defenseTriggerGap','Distance de défense (m)',5,25,12,12,12)
n('lateral','rampSpeed','Vitesse de déplacement latéral',0.1,1,0.3,0.3,0.45)
n('lateral','rampAccel','Accélération latérale',0.5,4,1.5,1.5,2)
n('lateral','lowPassTau','Lissage latéral (s)',0.05,1,0.25,0.25,0.2)
n('lateral','maxSideOffset','Décalage maximal',0.3,0.95,0.85,0.85,0.8)
n('lateral','cornerMin','Seuil de ligne droite',0,1,0.35,0.35,0.5)
n('lateral','cornerYawRef','Référence de rotation (rad/s)',0.2,1.2,0.5,0.5,0.5)
n('lateral','lateralCooldown','Repos entre directions (s)',0.3,5,1.2,1.2,1)
n('lateral','emergencyReleaseFactor','Facteur de relâchement',1,4,2,2,2)
n('human','reactMin','Réaction minimale (s)',0.1,2,0.25,0.2,0.2)
n('human','reactMax','Réaction maximale (s)',0.1,2,0.9,0.6,0.6)
n('human','awMin','Attention minimale (s)',0.2,5,0.6,0.4,0.4)
n('human','awMax','Attention maximale (s)',0.2,5,2,1.2,1.2)
n('human','paceDriftPct','Variation lente du rythme (%)',0,6,2,1,1)
n('human','personalLineJitter','Variation de trajectoire',0,0.15,0.05,0.03,0.02)
b('human','lapseEnabled','Petites baisses de concentration',true,false,false)
n('human','lapseIntervalMin','Intervalle minimal (s)',20,900,60,120,120)
n('human','lapseIntervalMax','Intervalle maximal (s)',20,900,300,600,600)
n('human','lapseDurMin','Durée minimale (s)',0.5,8,1.5,1,1)
n('human','lapseDurMax','Durée maximale (s)',0.5,8,3,2,2)
n('human','lapseDropMin','Perte minimale de rythme (%)',0,25,6,3,3)
n('human','lapseDropMax','Perte maximale de rythme (%)',0,25,12,7,7)
b('human','laneBiasEnabled','Ligne liée à l’allure',true,false,false)
n('human','laneBiasMax','Biais maximal de ligne',0,0.4,0.25,0.25,0.25)
newKeys.open=true
b('human','mistakesEnabled','Erreurs de pilotage des IA (blocages, patinage)',true,true,true)
n('human','mistakeRate','Erreurs : fréquence (par heure et par IA)',0,6,1,0.5,0.5)
newKeys.open=nil
n('start','startDelay','Attente au départ (s)',0,30,0,0,1)
n('start','startCautionMult','Prudence au départ',1,3,1,1,1.3)
n('start','startAggrMult','Agressivité au départ',0.2,1,1,1,0.8)
n('start','startRelax','Détente après départ (s)',2,30,12,12,25)
b('start','startLaneHold','Maintien de ligne au départ',false,false,false)
-- Accidents : mêmes clés d'obstacle qu'en 1.2.0 (onglet Départ), pour un retour arrière sans perte.
b('accidents','obstacleEnabled','Évitement des voitures arrêtées ou accidentées',true,true,true)
n('accidents','obstacleSpeedKmh','Vitesse d’obstacle (km/h)',5,50,25,25,25)
n('accidents','obstacleDetect','Détection d’obstacle (m)',50,300,150,150,150)
n('accidents','obstacleLevelDrop','Réduction près d’obstacle (%)',0,50,25,25,25)
n('accidents','obstacleCautionMult','Prudence près d’obstacle',1,3,1.5,1.5,1.5)
newKeys.open=true
n('accidents','avoidOffset','Écart d’évitement',0.3,0.9,0.6,0.6,0.6)
b('accidents','contactRecovery','Récupération après contact',true,true,true)
b('accidents','incidentStop','Arrêt des IA accidentées',true,true,true)
n('accidents','incidentStopMin','Arrêt minimal (s)',1,15,3,3,3)
n('accidents','incidentStopMax','Arrêt maximal (s)',1,30,8,8,8)
n('accidents','rejoinGap','Piste libre derrière pour repartir (m)',30,300,120,120,120)
b('accidents','yellowEnabled','Drapeaux jaunes (zone d’incident)',true,true,true)
n('accidents','yellowBefore','Début de zone avant l’incident (m)',50,800,300,300,300)
n('accidents','yellowAfter','Fin de zone après l’incident (m)',0,300,50,50,50)
n('accidents','yellowHold','Maintien après dégagement (s)',0,60,10,10,10)
n('accidents','yellowDecel','Décélération d’approche (m/s²)',2,10,5,5,5)
n('accidents','zoneDeltaPct','Double jaune : temps de référence plus lent de (%)',5,200,15,15,15)
n('accidents','slowZoneKmh','Double jaune : Slow Zone à vitesse fixe (km/h, 0 = temps delta)',0,150,0,0,0)
n('accidents','yellowSpeedKmh','Double jaune : vitesse de repli, allure inconnue (km/h)',30,200,50,50,50)
b('accidents','yellowHud','Drapeau jaune natif d’AC sur le HUD',false,false,false)
b('accidents','flagPanel','Panneau de drapeaux ACAdvancedIA en conduite',true,true,true)
b('accidents','yellowMessage','Messages d’incident à l’écran',true,true,true)
b('accidents','deltaBeeps','Delta : bips sonores',true,true,true)
b('accidents','playerPenalties','Pénalités du joueur sous drapeau',false,true,true)
n('accidents','deltaTolerance','Delta : tolérance aux mini-secteurs (s)',0,1,0.5,0.5,0.5)
n('accidents','penaltySeconds','Pénalité : coupure des gaz (s)',2,15,5,5,5)
n('accidents','penaltyDisqualify','Infractions tolérées avant disqualification',1,20,5,5,5)
b('accidents','aiPenalties','Sanctions des IA sous drapeau',false,true,true)
b('rules','noMoveBraking','Pas de changement de trajectoire au freinage',true,true,true)
e('rules','neutralization','Neutralisation après un incident majeur','local','local','local',{'local','fcy','vsc','sc'})
n('rules','majorIncidentTime','Incident majeur : immobilisation en piste (s)',5,60,15,15,15)
n('rules','fcySpeedKmh','FCY : vitesse de repli, allure inconnue (km/h)',40,150,80,80,80)
n('rules','fcyDeltaPct','FCY : temps de référence plus lent de (%)',10,150,50,50,50)
n('rules','vscDeltaPct','VSC : temps de référence plus lent de (%)',10,80,30,30,30)
n('rules','neutralizationHold','Durée minimale de neutralisation (s)',10,180,30,30,30)
n('rules','safetyCarSpeedKmh','Vitesse de la voiture de sécurité (km/h)',60,250,120,120,120)
b('rules','safetyCarEscalation','Voiture de sécurité sur incident aggravé',false,true,true)
b('rules','redFlagEnabled','Drapeau rouge sur accident grave (essais, qualifications, course)',true,true,true)
n('rules','redFlagCars','Drapeau rouge : voitures immobilisées en piste',2,10,3,3,3)
n('rules','redFlagSpeedKmh','Drapeau rouge : vitesse de repli, allure inconnue (km/h)',40,150,80,80,80)
n('rules','redDeltaPct','Drapeau rouge : temps de référence plus lent de (%)',10,200,60,60,60)
n('rules','redFlagHold','Drapeau rouge : interruption minimale (s)',20,600,60,60,60)
b('rules','redFlagWork','Drapeau rouge : pneus changés aux stands (arrêt compté)',false,false,false)
n('rules','mandatoryStops','Arrêts obligatoires en course',0,3,0,0,0)
n('rules','pitWindowOpenPct','Ouverture de la fenêtre (% de course)',5,95,25,25,25)
n('rules','pitWindowClosePct','Fermeture de la fenêtre (% de course)',5,100,75,75,75)
b('rules','pitTyres','Pneus neufs à chaque arrêt (règles d’arrêt actives)',true,true,true)
b('rules','pitRepair','Réparations à chaque arrêt en course (carrosserie, suspensions, moteur)',true,true,true)
b('rules','pitCompoundChange','Changer de composé sec (F1)',false,false,false)
n('rules','minPitTime','Temps d’arrêt minimal (s, 0 = libre)',0,120,0,0,0)
n('rules','maxStintMin','Relais maximal (min, 0 = libre)',0,240,0,0,0)
e('rules','pitFuel','Carburant aux arrêts forcés','refuel','refuel','refuel',{'refuel','plan','ac'})
e('rules','pitsClosed','Stands fermés sous neutralisation','open','open','open',{'open','pitFcy','pitFcySc'})
b('rules','pitMessage','Message d’ouverture de la fenêtre d’arrêt',true,true,true)
b('rules','overtakeMode','Overtake Mode (F1 2026, moins d’une seconde à la détection)',false,false,false)
n('rules','overtakeModeGap','Overtake Mode : écart de détection (s)',0.3,2,1,1,1)
n('rules','overtakeModeBoostPct','Overtake Mode : gain de niveau (%)',0,5,2,2,2)
b('rules','drsAssist','DRS du joueur : bip et panneau',true,true,true)
b('rules','rulesDrs','DRS : règles de course (pluie, drapeaux, départ, voiture de sécurité, drapeau rouge)',false,true,true)
n('rules','rulesDrsLaps','DRS : tours du leader avant activation (départ, voiture de sécurité, drapeau rouge)',0,5,1,1,1)
b('rules','aiDrs','DRS des IA : ouverture dans les zones',true,true,true)
n('rules','drsBeepVolume','Bips (DRS et delta) : volume (%)',25,400,200,200,200)
b('rules','bopEnabled','BoP : rythmes resserrés dans chaque classe',false,false,false)
n('rules','bopStrengthPct','BoP : correction maximale (%)',0,5,2,2,2)
b('rules','proAmEnabled','Grades Pro-Am (Bronze à Platinum)',false,false,false)
b('rules','predictableSlowClass','Classe lente : trajectoire prévisible',false,false,false)
newKeys.open=nil
b('endurance','enduranceOverlay','Surcouche Endurance',false,false,false)
b('endurance','multiClass','Multi-classes',false,false,false)
n('endurance','classGapPct','Écart entre classes (%)',3,25,8,8,8)
n('endurance','classYieldMargin','Avantage interclasse (km/h)',1,15,4,4,4)
n('endurance','stintLevelSwing','Variation entre relais (%)',0,8,3,3,3)
n('endurance','stintDegradationPct','Dégradation d’un relais (%)',0,5,1,1,1)
b('weather','weatherAdaptation','Adapter le rythme à la météo',true,true,true)
b('weather','weatherTyresEnabled','Gérer les pneus secs et pluie',true,true,true)
newKeys.open=true
b('weather','weatherMessage','Message à l’écran au changement de météo',true,true,true)
newKeys.open=nil
n('weather','rainGripBoostPct','Compensation pluie sans pneu pluie (%)',0,30,15,15,15)
n('traffic','trafficGapSeconds','Intervalle de base (s)',0.5,5,2.5,2.5,2.5)
n('traffic','trafficDensityGain','Distance ajoutée par IA (m)',0.5,5,2.8,2.8,2.8)
n('traffic','trafficVariation','Variation des espacements (%)',0,50,45,45,45)
n('traffic','trafficMaxReduction','Réduction maximale de vitesse (%)',2,20,14,14,14)
M.globalDefaults={schemaVersion=1,enabled=true,autoProfile=true,manualProfile='J',offsetSign=0,sideSign=0,
 overrideAwareness=false,levelMode='auto',useGripBoost=false,gripPerLevelPct=0.004,useBrakeAssist=true,
 flashField='',occLatMin=0.3,occLatMax=5.5,occMargin=6,occSpeedGain=0.8,seed=19731019,debugLog=false,loadedPreset='',builtinMarks='',presetsUsed=false,dataRevision=0,safetyCarModel='ferrari_458_s3',safetyCarPicked=false,journal=true,panelOpacity=86,panelShow='info',overlayX=-1,overlayY=-1,overlayScale=1,overlayLocked=true,overlayBackground='solid',overlayContent=100,overlayClickThrough=true,overlayHideReplay=true,overlayHidePits=false,trackLights=true,overlaySession=true,overlayExplain=true,overlayRecap=true,overlayNativeBox=true,overlayMessages=true,overlayBlockMessages=true,floodBackup='',panelInfoTime=0,windowCompacted=false,language='en',updateCheck=true}
M.globalBounds={panelOpacity={0,100},panelInfoTime={0,60},overlayX={-1,16000},overlayY={-1,16000},overlayScale={0.5,2.5},overlayContent={30,100},dataRevision={0,1000},offsetSign={-1,1},sideSign={-1,1},gripPerLevelPct={0,0.01},occLatMin={0.1,1},occLatMax={2,8},occMargin={2,15},occSpeedGain={0,2},seed={0,2147483647}}
M.globalChoices={language={'en','fr'},panelShow={'info','always'},overlayBackground={'solid','ghost','transparent'},manualProfile={'J','P','Q','C','H'},levelMode={'auto','native','grip','none'},flashField={'','highBeams','headlightsActive','lowBeams','flashingLightsActive'}}
-- Constantes physiques et temporisations : unique source des valeurs de comportement.
M.K={maxCars=61,paceBins=400,logLines=200,logRate=20,logDedup=5,maxZones=64,maxZoneBytes=65536,
 maxPatterns=8,maxPatternLength=32,dtMax=0.25,teleport=40,perceptionPeriod=0.1,metaPeriod=1,classPeriod=60,classCycles=2,
 neighbors=8,neighborRange=400,fallbackRange=80,sameDirection=0.5,coherenceFloor=15,coherenceRatio=0.35,occLatMax=5.5,
 minLength=3.5,maxLength=6.5,minWidth=1.5,maxWidth=2.3,length=4.4,width=1.85,
 speedTau=0.4,yawTau=0.3,ttcEpsilon=0.1,nearLine=0.3,overlapMargin=2,
 freeRange=80,paceAlpha=0.3,paceRatioAlpha=0.05,paceRatioMin=40,paceMinBins=40,speedMinYield=20,speedMinPass=30,
 latYield=4,latPass=3.2,pressureSa=8,pressureResetTime=1,pressureResetRange=1.5,
 nearYield=25,nearYieldMargin=0.5,confirmReset=0.3,pendingTTL=12,detectMax=400,
 courtesyMin=1.25,courtesyMax=0.75,yieldMarginRange=50,gapMarginMin=0.5,
 holdFloor=1,passBuffer=3,lostRange=1.3,slowLostTime=2.5,slowLostGap=15,ignoreFollower=10,
 invitationGap=25,invitationTime=12,invitationRamp=4,urgentAmp=1.1,cornerAmpMin=0.4,
 assertMin=1.3,assertMax=0.7,passMarginRange=40,stuckGapMin=10,stuckGapTime=1.5,
 passAdvantageJ=4,passAdvantageC=3,passCornerC=0.6,passBrakeMax=0.3,pullOutMax=22,
 corridorMin=40,corridorMax=250,corridorSpeedMin=1.5,abortBlocked=0.4,abortSlowTime=3,abortGap=5,
 abortFollowerSpeed=25,abortFollowerGap=30,passHoldMax=4,holdProgress=0.5,clearConfirm=0.6,alongsideBuffer=3,
 followRange=60,followMinGap=5,followGapRange=30,followCaution=1.35,followTTC=3,followTTCMult=1.1,
 slipCorner=0.9,slipTime=1,slipSpeed=150,slipCaution=0.85,slipCautionMin=0.6,
 brakeClosing=2,brakeGain=10,brakeMax=0.6,
 defenseChance=0.3,defenseAssert=0.5,defenseTime=2.5,defenseAggression=1.2,defenseCaution=0.9,
 obstacleTime=2,stoppedTime=10,slipDegrees=35,obstacleBlockedLevel=0.6,obstacleClear=12,
 contactDrop=25,contactWindow=0.3,contactRange=6,calmTime=4,calmExitSpeed=40,
 driftPeriodMin=90,driftPeriodMax=240,jitterPeriodMin=7,jitterPeriodMax=19,jitterRange=40,baseMax=0.25,
 lapseRamp=0.3,playerFollowGap=8,playerCaution=1.15,lateralSpeedBase=100,lateralSpeedFloor=30,
 lateralRateMin=0.6,lateralRateMax=1.6,blockedRelease=0.3,directionLimit=6,directionWindow=60,directionRest=20,sideDeadband=0.05,
 pitOffsetMax=0.5,pitZone=60,pitExitDelay=2,stintExitDelay=3,stintExitCautionTime=8,stintExitCaution=1.3,
 stintDuration=2400,wetLevel=0.1,wetCaution=0.4,wetAggression=0.25,wetDetect=0.3,
 fatigueTime=5400,fatigueGain=1.3,fatigueMax=2,timeWrap=86400,
 classMax=4,classConfirm=0.7,classReaction=0.8,classFightSpeed=15,classCorner=0.7,classMargin=0.5,
 lapTolerance=0.02,lapRangeMult=1.5,lapSpeed=3,lapConfirm=0.3,lapReaction=0.8,lapCorner=0.7,lapCornerLevel=0.92,
 fightTime=2,fightSpeed=4,flashBurst=1.5,flashHoldMin=0.8,flashHoldMax=4,
 flashDebounce=0.15,flashDedup=0.4,flashLearnTime=6,flashPropagation=0.5,
 flashLat=6,flashSpeed=30,flashCloseGap=60,flashCatchMargin=5,courtesyRange=30,courtesyTime=20,courtesyAggression=0.35,courtesyPassSa=25,stuckRadius=15,inviteReport=3,brakeEcho=0.03,passCloseMin=4,closeMemory=5,realPassGap=20,realPassWindow=20,flashSecondTime=4,flashReact=0.6,flashConfirm=0.1,
 flashMargin=0.5,flashHorizon=1.5,flashUrgentCount=3,flashReactionMin=0.15,flashReactionMax=1.45,
 personaPatienceMin=0.7,personaPatienceMax=1.4,personaBrakeMin=0.9,personaBrakeMax=1.15,
 writePeriod=0.2,readbackPeriod=2,offsetEpsilon=0.002,levelEpsilon=0.005,aggrEpsilon=0.01,cautionEpsilon=0.02,gripEpsilon=0.001,
 capabilityFailures=3,carErrorTime=5,carErrorMax=3,saveDelay=1,maxCaution=16,maxAggression=0.95,
 probeLevel=1.05,probeDelay=0.3,probeTolerance=0.01,gripBase=1.2,calibrationOffset=0.5,
 calibrationTime=3,calibrationMinMove=0.15,calibrationRange=100,calibrationSpeed=60,calibrationCorner=0.95,
 calibrationPairGap=50,calibrationPairMax=150,calibrationMinWidth=2.5,calibrationActiveCorner=0.6,calibrationAlignment=0.98,
 classPatternClassMax=4,defaultLevel=1,defaultAggression=0.5,defaultCaution=1,modulatorTau=0.4,fastModulatorTau=0.15,
 minNativeLevel=0.3,yieldReachedEpsilon=0.03,centerEpsilon=0.03,yieldAggression=0.5,yieldHoldCaution=1.1,yieldRecoveryTau=1.5,
 passAggression=1.15,passCaution=0.7,alongsideCaution=0.8,avoidAggression=0.6,calmLevel=0.95,calmAggression=0.5,calmCaution=1.3,
 blueSlowdown=0.08,blueRecoveryTau=0.8,blueTrainHold=1,lostSaRatio=0.3,returnCornerMin=0.35,
 brakeEmulationGain=0.8,brakeEmulationPedal=0.2,brakeEmulationRange=80,brakeEmulationClosing=3,
 counterMax=2147483647,blockedYieldTime=3,blockedYieldGap=10,lapseSalt=50000,stintSalt=10000,performanceWindow=60,maxAppWindows=256,metadataLength=128,maxCapabilities=128,
 uiCategoryPadding=32,uiTabPadding=16,uiFallbackColumns=3,uiTipWidth=72,maxPresets=16,presetNameBytes=64,
 neutralReaction=0.3,neutralAwareness=0.5,trafficPeriod=0.5,trafficMinGap=15,trafficDensityCapacity=0.65,trafficMaxCapacity=0.9,
 trafficDecelKmh=4,trafficAccelKmh=8,trafficMinSpeed=30,trafficLogDelay=60,trafficFasterMargin=0.03,targetLostGrace=1,spreadDelay=1,spreadPlanDelay=0.5,spreadReport=8,spreadPlayerGap=300,spreadSpeed=50,spreadLaunchWait=0.5,spreadCheck=3,spreadTroubleKmh=10,spreadRetry=2,spreadReached=100,spreadTroubleLines=6,slowRatio=0.6,slowMinPaceKmh=60,slowMinKmh=15,slowFollowGap=60,slowLogTime=20,slowEnd=8,slowSettle=10,spreadMinGap=15,spreadWindow=60,spreadMaxKmh=30,trackDayExitSpeed=40,trackDayExitMaxTotal=600,floodPeriod=2,floodMinLength=7000,floodRound=50,messageProbe='ACAdvancedIA',probeFrames=90,probeTime=0.1,parkReturnPeriod=10,blueCloseGap=40,blueSlack=5,radarLatMargin=0.4,radarWarnTTC=2.5,radarCaution=1.4,radarTTC=1.2,radarMinBrake=0.08,radarBrakeMax=0.45,radarApply=1.5,radarRelease=0.8,radarLogPeriod=15,contactLogPeriod=10,contactLogBudget=3,towWindow=3,blueLogTime=3,pitExitWindow=60,pitExitMinCars=10,pitExitSalt=7717,pitExitJitter=0.6,pitExitMaxTotal=180,pitExitSessionShare=0.25,pitExitMinGap=2,
 repairBase=3,repairBodyMin=5,repairBodyRate=0.1,repairSuspensionMin=0.02,repairSuspensionRate=40,repairEngineMin=990,repairEngineTime=30,repairMax=60,engineLifeNew=1000,trafficArmSpeed=60,trafficEpisode=6,trafficCycle=18,unlimitedSpeed=1e9,
 wrongWaySpeed=10,wrongWayTime=2,spinSpeed=15,spinTime=0.6,incidentClear=2,incidentMaxAge=120,crashSettle=4,rejoinWaitMax=10,rejoinSpeed=30,crashSalt=60000,stopPulse=1.5,stopPulsePeriod=0.5,
 yellowApproach=800,yellowNoPass=150,playerFlagLead=150,playerFlagLeadMax=800,flagLeadTime=1.25,gridGrace=6,flagNone=0,flagCaution=2,flagStart=1,flagStop=5,flagReturnToPits=8,flagFasterCar=12,flagSlippery=3,flagSlowVehicle=6,flagFinished=13,flagOneLapLeft=14,penaltyMandatoryPits=1,penaltyTeleportToPits=2,
 ruleBrake=0.2,aiFlashGap=40,aiFlashCooldown=8,aiFlashPulses=2,aiFlashInterval=0.4,overtakeDetect=0.95,vscEnding=12,restartMax=600,redReleaseFirst=5,redReleaseGap=2,scClosedLaps=3,
 journalPeriod=2,journalSummary=60,journalKeep=3,journalMaxBytes=4194304,
 -- Mise à jour depuis GitHub (Beta 1.33) : vérification une fois par lancement, après updateDelay s de jeu ; lignes des
 -- notes de version montrées ; information de l'overlay aux stands, updateNotice s, une fois par lancement.
 updateDelay=10,updateNotes=8,updateNotice=6,
 queueGap=15,pillFontMin=11,deltaBoxMin=12,deltaStart=1,laneMin=0.5,laneBias=0.3,laneRelease=1,deltaCap=3,deltaJump=150,deltaMinKmh=30,miniSectorLength=250,miniSectorsMin=8,miniSectorsMax=60,fleetBinsPerFrame=4,scMergeMargin=30,singleYellowPct=15,passGiveBack=10,giveBackMin=5,giveBackDrop=25,queueKeep=15,queueClose=0.5,aiDeltaMarginMin=0.02,aiDeltaMarginMax=0.06,slipperyShow=30,slipperyGrace=30,lightsHold=1.5,lightsFiles=16,lightsBytes=4194304,slowVehicleRange=300,slowVehicleBehind=10,slowVehicleTime=3,slowVehicleRatio=0.5,meatballShow=20,meatballBody=100,meatballSuspension=0.2,meatballEngine=600,meatballGearbox=0.4,playerDamagePeriod=1,warningShow=10,safetySkinPattern='safety',drsLateLoad=60,drsLapsMax=99,drsAiBrake=0.2,drsAiCorner=0.5,drsAiKmh=80,drsAiRetry=1,drsAiCloseRetry=0.1,mistakeCheck=1,mistakeStartMin=60,mistakeArm=15,mistakeCooldown=180,mistakeGap=20,mistakeCalm=180,mistakeLapse=4,mistakeWet=2,mistakeWetCause=0.3,mistakeSkill=5,mistakeSkillMin=0.5,mistakeSkillMax=3,mistakeWeak=0.95,mistakePlayerGap=40,mistakeMinKmh=50,mistakeBrakePedal=0.6,mistakeBrakeKmh=120,mistakeGasPedal=0.8,mistakeCorner=0.6,mistakeTractionKmh=180,mistakeSeverity=1.4,mistakeSalt=80000,mistakeBrakeMin=0.4,mistakeBrakeMax=0.9,mistakeTractionMin=0.3,mistakeTractionMax=0.7,deltaBeepFile='sounds/delta-beep.wav',deltaBeepNegative=0.15,deltaBeepNear=0.2,deltaBeepFast=0.3,deltaBeepMid=0.5,deltaBeepMedium=0.6,deltaBeepFar=1,deltaBeepSlow=1.2,slipperyStripes=6,flagBlinkTime=5,pitRemindTime=15,pitRemindLate=0.2,aiPenaltyDecel=3,inviteLatMax=6,inviteCurve=0.001,passArmMax=20,carNameMax=96,passStallSa=2,passStallTime=8,pullOutTargetLat=1,pitGuardTime=15,pitGuardGap=80,pitGuardMin=12,pitGuardAllowance=15,pitGuardBack=5,pitGuardCaution=1.5,inviteLat=2,inviteGap=40,inviteTime=0.6,inviteSa=3,inviteClear=60,inviteRespite=20,aiPenaltyFactor=0.7,penaltyBlackFlag=4,penaltyReleaseBlackFlag=5,journalMarker='.ACAdvancedIA.journal',drsBeepFile='sounds/drs-available-beep.wav',penaltyBrakeMargin=2.5,incidentStopSpeed=10,obstacleClosing=15,penaltyCooldown=20,passWatch=40,noticeTime=8,penaltySlowDown=3,avoidClearMargin=10,avoidRecheck=1,crashWindow=30,neutralMax=600,neutralRecoverTime=20,stuckRecoverTime=30,trackRecoverTime=8,brokenRecoverTime=3,ruleDecision=5,calibrationRetry=60,laneMaxOffset=0.7,hudMessageTime=5,hudMessageMin=2,hudMessageMax=10,recapPassGap=40,recapPeriod=0.1,hudStripPeriod=0.25,hudFuelWarn=2,hudLapTime=5,hudWidth=600,hudTop=0.07,hudStripH=26,hudBandH=82,hudExplainLine=16,hudPillH=24,hudPad=8,hudHandle=18,hudGhost=0.38,scKickPeriod=2,startCorner=0.9,startCareRise=4,startCareFall=0.6,radarLaunchTTC=0.8,brokenSuspension=0.5,brokenEngine=50,brokenGearbox=0.9,damageReadSpeed=25,
 redFlagMax=300,compactWidth=900,compactHeight=700,fuelReserveLaps=0.6,fuelMargin=1.03,fuelAlpha=0.3,fuelLapShare=0.5,fuelLapTimeMin=20,fuelStep=1,redFlagMaxCap=1800,redLapFactor=1.25,redPitMargin=60,redRecoverTime=8,redStopSpeed=5,redStopTime=5,greenShow=5,greenZoneShow=3,panelPeriod=0.25,panelWrap=58,
 bopGain=0.5,bopPeriod=60,scCatchUp=40,scQueueGap=60,scCallTime=10,scEscalateCars=2,scEscalateTime=30,scMinOut=60,scExitMax=90,scStuckTime=20,scInMax=300,parkPeriod=2,maxCarList=4000,pitSpread=0.85,pitSalt=80000,pitConcurrent=3,pitLastStint=0.95,gradeSalt=70000,gradeLevel={1,0.99,0.975,0.96},gradeCaution={1,1,1.05,1.1},
 weatherPeriod=1,weatherConfirm=15,weatherWetOn=0.12,weatherWetOff=0.05,weatherRainOn=0.1,weatherRainOff=0.02,weatherWaterOn=0.03,weatherWaterOff=0.01,weatherHeavy=0.6,maxTyreCompounds=32,tyreCatalogBudget=2,tyreStopSpeed=1,tyreSalt=90000,spawnWindow=15,enduranceSuggestionSeconds=3600}
M.timerFields={'since','aiFlashAt','stintStart','pitExitUntil','pitCautionUntil','pitGuardUntil','pendingUntil','holdUntil','ignoreUntil','restUntil','nextPerception',
 'defendUntil','defendCooldown','calmUntil','speedWindowStart','lastContact','lapseAt','errorUntil','lastDirectionAt','driveUntil','yieldStart'}
M.optionalTimerFields={'pendingAt','lapseUntil'}
function M.defaults(profile)
 local r={schemaVersion=M.version,classPatterns='',configured=false}
 for _,s in ipairs(M.schema) do r[s.key]=s.defaults[profile] end
 for _,group in ipairs(M.sections) do r['section_'..group]=false end
 -- Hotlap : onglet Règles seul coché (règles de base) ; drapeaux, panneau et bip du DRS, aucune IA à piloter.
 if profile=='H' then r.section_rules=true end
 return r
end
-- Onglets différents du défaut du profil (Hotlap : onglet Règles coché par défaut).
function M.sectionsChanged(profile,p)
 for _,group in ipairs(M.sections) do
  local key=sectionKeys[group]
  if (p[key]==true)~=(profile=='H' and group=='rules') then return true end
 end
 return false
end
function M.anySection(p)
 for _,group in ipairs(M.sections) do if p[sectionKeys[group]]==true then return true end end
 return false
end
local function choice(v,list) for _,x in ipairs(list) do if x==v then return true end end return false end
function M.patterns(text,out)
 out=out or {}; for i=#out,1,-1 do out[i]=nil end
 if type(text)~='string' or #text>M.K.maxPatterns*(M.K.maxPatternLength+4) then return out,false end
 for pattern,class in text:gmatch('([%w_%-]+)%s*:%s*([1-4])') do
  if #pattern>M.K.maxPatternLength or #out>=M.K.maxPatterns then return out,false end
  out[#out+1]={pattern=pattern:lower(),class=tonumber(class)}
 end
 local rest=text:gsub('[%w_%-]+%s*:%s*[1-4]',''):gsub('[%s,;]','')
 return out,rest==''
end
function M.validate(profile,input,out)
 out=out or {}; local errors=0
 -- Migration v0 : mêmes clés reconnues ; toute version future est refusée.
 if input.schemaVersion~=nil and (not U.finite(input.schemaVersion) or input.schemaVersion<0 or input.schemaVersion>M.version or input.schemaVersion%1~=0) then input=M.defaults(profile); errors=errors+1 end
 for _,s in ipairs(M.schema) do
  local v=input[s.key]; local good
  if s.min then good=U.finite(v) and v>=s.min and v<=s.max
  elseif s.choices then good=choice(v,s.choices) else good=type(v)=='boolean' end
  if not good then v=s.defaults[profile]; if not (input.schemaVersion==2 and (s.key=='weatherTyresEnabled' or s.key=='rainGripBoostPct')) then errors=errors+1 end end
  out[s.key]=v
 end
 for _,group in ipairs(M.sections) do
  local active=(input.schemaVersion==M.version or input.schemaVersion==2) and input[sectionKeys[group]]==true
  if group=='weather' and input.schemaVersion==2 then active=input.section_endurance==true and input.weatherAdaptation==true end
  out[sectionKeys[group]]=active
 end
 for _,s in ipairs(M.schema) do if M.hidden(profile,s.key) then out[s.key]=s.defaults[profile] end end
 for _,pair in ipairs({{'yieldHoldAfterMin','yieldHoldAfterMax'},{'reactMin','reactMax'},{'awMin','awMax'},{'lapseIntervalMin','lapseIntervalMax'},{'lapseDurMin','lapseDurMax'},{'lapseDropMin','lapseDropMax'},{'incidentStopMin','incidentStopMax'},{'pitWindowOpenPct','pitWindowClosePct'}}) do
  if out[pair[1]]>out[pair[2]] then out[pair[2]]=out[pair[1]]; errors=errors+1 end
 end
 local _,valid=M.patterns(input.classPatterns); out.classPatterns=valid and input.classPatterns or ''
 if not valid then errors=errors+1 end
 for key in pairs(M.integerKeys) do out[key]=math.floor(out[key]+0.5) end
 out.schemaVersion=M.version
 -- Migration : un profil ayant déjà une section active est considéré comme réglé.
 out.configured=input.configured==true or M.sectionsChanged(profile,out)
 return out,errors
end
function M.validateGlobals(input,out)
 out=out or {}; local errors=0
 if input.schemaVersion~=nil and (not U.finite(input.schemaVersion) or input.schemaVersion<0 or input.schemaVersion>M.version or input.schemaVersion%1~=0) then input=M.globalDefaults; errors=errors+1 end
 for k,d in pairs(M.globalDefaults) do
  local v=input[k]; local valid=type(v)==type(d)
  if type(d)=='number' then valid=U.finite(v); local r=M.globalBounds[k]; if valid and r then valid=v>=r[1] and v<=r[2] end end
  if M.globalChoices[k] then valid=choice(v,M.globalChoices[k]) end
  if k=='floodBackup' then valid=type(v)=='string' and #v<=512 and not v:find('%c') end
  if k=='loadedPreset' then valid=type(v)=='string' and #v<=M.K.presetNameBytes+16 and not v:find('%c') end
  if k=='builtinMarks' then valid=type(v)=='string' and #v<=128 and v:match('^[%w=,]*$')~=nil end
  if k=='safetyCarModel' then valid=type(v)=='string' and #v<=M.K.metadataLength and v:match('^[%w_%-%.]*$')~=nil end
  if (k=='offsetSign' or k=='sideSign') and valid then valid=v==-1 or v==0 or v==1 end
  if not valid then v=d; errors=errors+1 end
  out[k]=v
 end
 out.seed=math.floor(out.seed); out.dataRevision=math.floor(out.dataRevision); out.schemaVersion=M.version
 if out.loadedPreset~='' then out.presetsUsed=true end
 return out,errors
end
function M.preset(name,profile,out)
 local p=name=='Nordschleife' and 'J' or name=='Essais' and 'P' or name=='Qualifications' and 'Q' or name=='Endurance' and profile or 'C'
 out=M.validate(p,M.defaults(p),out)
 local base=presetSections[name] and name or p=='J' and 'Nordschleife' or 'Course'
 local sections=presetSections[base]
 for _,group in ipairs(M.sections) do out['section_'..group]=sections[group]==true end
 for key,value in pairs(presetValues[base]) do out[key]=value end
 local endurance=name=='Endurance' and profile~='Q' and profile~='P'
 if endurance then out.section_endurance=true; out.enduranceOverlay=true; out.multiClass=true; out.lapseEnabled=true end
 out.configured=true
 return out
end
function M.on(p,group) return p[sectionKeys[group]]==true end
function M.any(p)
 for _,group in ipairs(M.sections) do if group~='globals' and M.on(p,group) then return true end end
 return false
end
-- Les valeurs sauvegardées restent intactes ; seules les sections cochées sont appliquées.
function M.effective(profile,p,out)
 out=out or {}
 for _,s in ipairs(M.schema) do
  if p[s.sectionKey]==true then out[s.key]=p[s.key] else out[s.key]=s.defaults[profile] end
 end
 for _,group in ipairs(M.sections) do local key=sectionKeys[group]; out[key]=p[key]==true end
 out.classPatterns=M.on(p,'endurance') and p.classPatterns or ''
 if not M.on(p,'general') then out.paceSpreadPct=0; out.aggrSpreadPct=0; out.cautSpreadPct=0; out.brakeZonePct=100 end
 if not M.on(p,'yield') then out.yieldEnabled=false; out.pressureEnabled=false end
 if not M.on(p,'blue') then out.blueFlagEnabled=false end
 if not M.on(p,'flash') then out.flashMode='never'; out.hornEnabled=false; out.aiFlashEnabled=false end
 if not M.on(p,'overtake') then out.overtakeEnabled=false; out.defenseEnabled=false; out.slipstreamEnabled=false end
 if not M.on(p,'human') then out.paceDriftPct=0; out.personalLineJitter=0; out.laneBiasEnabled=false; out.lapseEnabled=false; out.mistakesEnabled=false end
 if not M.on(p,'start') then out.startDelay=0; out.startRelax=0; out.startCautionMult=1; out.startAggrMult=1; out.startLaneHold=false end
 if not M.on(p,'accidents') then
  out.obstacleEnabled=false; out.contactRecovery=false; out.incidentStop=false; out.yellowEnabled=false; out.yellowHud=false; out.playerPenalties=false; out.aiPenalties=false
  -- Neutralisations et drapeau rouge restent signalés (et leur delta bipé) tant que l'onglet Règles agit.
  if M.on(p,'rules') then out.yellowMessage=p.yellowMessage; out.flagPanel=p.flagPanel; out.deltaBeeps=p.deltaBeeps else out.yellowMessage=false; out.flagPanel=false; out.deltaBeeps=false end
 end
 if not M.on(p,'rules') then
  out.noMoveBraking=false; out.neutralization='local'; out.mandatoryStops=0; out.minPitTime=0; out.maxStintMin=0
  out.overtakeMode=false; out.bopEnabled=false; out.proAmEnabled=false; out.predictableSlowClass=false; out.redFlagEnabled=false; out.drsAssist=false
  -- Ni DRS coupé par les règles, ni DRS des IA ouvert par l'app : décocher l'onglet arrête toute la section.
  out.rulesDrs=false; out.aiDrs=false; out.pitsClosed='open'; out.redFlagWork=false; out.pitRepair=false
 end
 -- Volume des bips : préférence du pilote, aussi pour le delta d'une zone jaune quand l'onglet Règles est décoché.
 out.drsBeepVolume=p.drsBeepVolume
 if not M.on(p,'endurance') then out.enduranceOverlay=false; out.multiClass=false; out.stintLevelSwing=0; out.stintDegradationPct=0 end
 if not M.on(p,'weather') then out.weatherAdaptation=false; out.weatherTyresEnabled=false; out.rainGripBoostPct=0; out.weatherMessage=false end
 return out
end
function M.effectiveGlobals(g,p,out)
 out=out or {}; for key,value in pairs(g) do out[key]=value end
 if not M.on(p,'globals') then
  for _,key in ipairs(M.globalRuntimeKeys) do out[key]=M.globalDefaults[key] end
 end
 return out
end
function M.needsOffset(p)
 return p.yieldEnabled or p.blueFlagEnabled or p.flashMode~='never' or p.overtakeEnabled or p.defenseEnabled or p.obstacleEnabled or p.laneBiasEnabled or p.personalLineJitter>0 or p.multiClass
end
local function equal(a,b) return a==b or type(a)=='number' and type(b)=='number' and math.abs(a-b)<1e-6 end
-- Valeurs de la 1.2.0 changées depuis : espacement de la journée circuit (Beta 1.20).
local trafficOld={trafficGapSeconds=1.2,trafficVariation=35,trafficMaxReduction=10}
-- Départ de course jusqu'à la Beta 1.23 (profil Course) : prudence ×1,6 et agressivité ×0,6, trop frileux en peloton.
local startOld={startCautionMult=1.6,startAggrMult=0.6}
-- Départ de course jusqu'à la Beta 1.26 (profil Course) : attente de 12 s, détente de 12 s, maintien de ligne ;
-- la Beta 1.27 reprend le profil personnalisé « Course Test » du pilote (1 s, 25 s, sans maintien de ligne).
-- Reconnaissance des préréglages 1.2.0 : seules l'attente et la détente y figuraient.
local startOld126={startDelay=12,startRelax=12}
local startMoved127={startDelay=12,startRelax=12,startLaneHold=true}
-- Portée des appels de phares jusqu'à la Beta 1.28 (aussi celle des préréglages 1.2.0).
local flashOld128={J=120,P=150,Q=150,C=100,H=120}
local flashCloseOld128={J=5,P=4,Q=4,C=6,H=5}
-- Interrupteurs indépendants des jeux de règles (Beta 1.19) : ignorés pour reconnaître un jeu (interface, journal).
M.switchKeys={mandatoryStops=true,safetyCarEscalation=true}
-- Préréglage intégré 1.2.0 resté strictement identique dans ce profil, ou nil.
function M.legacyMatch(profile,p)
 if p.classPatterns~='' then return nil end
 local base=M.validate(profile,M.defaults(profile),{})
 for _,name in ipairs(legacyCandidates[profile] or {}) do
  local endurance=name=='Endurance'
  local sections=legacySections[endurance and (profile=='J' and 'Nordschleife' or 'Course') or name]
  local same=true
  for _,s in ipairs(M.schema) do
   if not newKeys[s.key] then
    local expected=trafficOld[s.key] or s.key=='flashRange' and flashOld128[profile] or s.key=='flashCloseAdvantage' and flashCloseOld128[profile] or profile=='C' and (startOld[s.key] or startOld126[s.key]) or base[s.key]
    if endurance and (s.key=='enduranceOverlay' or s.key=='multiClass' or s.key=='lapseEnabled') then expected=true end
    if not equal(p[s.key],expected) then same=false; break end
   end
  end
  for _,group in ipairs(M.sections) do
   if not same then break end
   local expected=legacyGroups[group]==true and (sections[group]==true or endurance and group=='endurance')
   if p['section_'..group]~=expected then same=false end
  end
  if same then return name end
 end
 return nil
end
-- Profil ou préréglage personnel antérieur à la 1.3.0 : l'évitement des obstacles suit ses clés dans l'onglet Accidents,
-- sans les nouveautés (drapeaux jaunes, arrêt des IA accidentées).
function M.upgradeObstacles(p) if p.section_start==true and not p.section_accidents then p.section_accidents=true; p.yellowEnabled=false; p.incidentStop=false end end
-- Migration unique des données enregistrées. 1.2.0 : un profil identique à un préréglage intégré reçoit sa version
-- 1.3.0 ; un profil modifié reste tel quel, sauf l'évitement des obstacles qui suit ses clés dans l'onglet Accidents.
-- Révisions par profil, communes aux profils enregistrés et aux préréglages personnels (from : révision des données).
-- Révision 5 (Beta 1.8) : temps delta assoupli ; un profil resté sur l'ancien défaut (0,10 s) passe au nouveau. Un
-- préréglage enregistré avant n'a pas le maintien de ligne : lu avec la valeur de la journée circuit, il prend celle
-- de son profil. Révision 6 (Beta 1.9) : règles GT conformes au règlement SRO (stands ouverts sous FCY) ; seuls les
-- profils qui portaient exactement les anciennes règles GT changent. Renvoie la liste des changements faits.
-- Clés de règles apparues après les révisions qui jugent un jeu de règles : ignorées par ces révisions.
local keys18={safetyCarEscalation=true}
M.dataRevision=17
function M.migrateProfile(profile,p,from,preset,out)
 out=out or {}
 if from<5 then
  if equal(p.deltaTolerance,0.1) then p.deltaTolerance=M.defaults(profile).deltaTolerance; out[#out+1]=profile..':delta' end
  if preset and not M.solo(profile) and p.startLaneHold==M.defaults('J').startLaneHold then p.startLaneHold=M.defaults(profile).startLaneHold end
 end
 if from<6 and not M.solo(profile) and p.pitsClosed=='pitFcy' then
  p.pitsClosed='open'
  if M.ruleCategory(profile,p,keys18)=='GT' then out[#out+1]=profile..':regles GT' else p.pitsClosed='pitFcy' end
 end
 -- Révision 7 (Beta 1.12) : erreurs de pilotage dans toutes les sessions ; l'ancien défaut hors course (décoché)
 -- prend le nouveau, et la fréquence de la journée circuit restée à l'ancien défaut aussi.
 if from<7 and profile~='C' then
  if p.mistakesEnabled==false then p.mistakesEnabled=true end
  if M.solo(profile) and equal(p.mistakeRate,0.5) then p.mistakeRate=M.defaults(profile).mistakeRate end
 end
 -- Révision 8 (Beta 1.15) : un profil Hotlap encore vide et jamais réglé prend son défaut (onglet Règles seul).
 if from<8 and profile=='H' and not p.configured and not M.anySection(p) then p.section_rules=true end
 -- Révision 7 : carburant ; un jeu de règles F1 ou GT resté intact (lu avec le défaut, ravitaillement) le suit.
 if from<7 and not M.solo(profile) and p.pitFuel=='refuel' then
  p.pitFuel='plan'
  local category=M.ruleCategory(profile,p,keys18)
  if category~='F1' and category~='F1_2026' and category~='GT' then p.pitFuel='refuel' end
 end
 -- Révisions 10 et 11 (Beta 1.18 et 1.19) : voiture de sécurité en escalade, activée par défaut en course avec tous les
 -- jeux de règles (essais, qualifications et course, comme son interrupteur).
 if from<11 and not M.solo(profile) then p.safetyCarEscalation=true end
 -- Révision 12 (Beta 1.20) : espacement de la journée circuit élargi ; des valeurs restées aux anciens défauts les
 -- suivent, des valeurs réglées restent telles quelles.
 if from<12 then
  local moved=false
  for key,old in pairs(trafficOld) do if equal(p[key],old) then p[key]=M.defaults(profile)[key]; moved=true end end
  if moved and profile=='J' then out[#out+1]='J:espacement' end
 end
 -- Révision 16 (Beta 1.27) : départ de course du pilote ; des valeurs restées aux anciens défauts les suivent.
 if from<16 and profile=='C' then
  local moved=false
  for key,old in pairs(startMoved127) do if equal(p[key],old) then p[key]=M.defaults('C')[key]; moved=true end end
  if moved then out[#out+1]='C:depart' end
 end
 -- Révision 17 (Beta 1.29, demande du pilote) : appels de phares vus de plus loin et compris collé derrière ; des
 -- valeurs restées aux anciens défauts les suivent, des valeurs réglées restent telles quelles.
 if from<17 then
  local moved=false
  if equal(p.flashRange,flashOld128[profile]) then p.flashRange=M.defaults(profile).flashRange; moved=true end
  if equal(p.flashCloseAdvantage,flashCloseOld128[profile]) and not equal(p.flashCloseAdvantage,M.defaults(profile).flashCloseAdvantage) then p.flashCloseAdvantage=M.defaults(profile).flashCloseAdvantage; moved=true end
  if moved then out[#out+1]=profile..':phares' end
 end
 -- Révision 13 (Beta 1.24) : départ de course moins frileux ; des valeurs restées aux anciens défauts les suivent.
 if from<13 and profile=='C' then
  local moved=false
  for key,old in pairs(startOld) do if equal(p[key],old) then p[key]=M.defaults('C')[key]; moved=true end end
  if moved then out[#out+1]='C:depart' end
 end
 return out
end
function M.migrate(g,profiles)
 if g.dataRevision>=M.dataRevision then return nil end
 local upgraded={}
 -- Révision 4 (Beta 1.6) : première installation (aucune donnée enregistrée, aucun profil réglé) : comme un clic sur
 -- « Règles de base » ; Essais, Qualifications et Course reçoivent leur préréglage recommandé et les règles de base,
 -- la Journée circuit reste sans commande. Une installation existante n'est jamais modifiée.
 local fresh=g.dataRevision==0 and not g.presetsUsed
 -- Un profil compte comme réglé s'il l'est, ou si ses onglets diffèrent de son défaut (Hotlap : onglet Règles).
 for _,profile in ipairs(M.profiles) do
  local p=profiles[profile]
  if p.configured or M.sectionsChanged(profile,p) then fresh=false end
 end
 if g.dataRevision<1 then
  for _,profile in ipairs(M.profiles) do
   local p=profiles[profile]
   local name=M.legacyMatch(profile,p)
   if name then M.preset(name,profile,p); upgraded[#upgraded+1]=profile..':'..name else M.upgradeObstacles(p) end
  end
 end
 -- Révision 2 (1.5.0) : panneau de drapeaux seul, choix du pilote ; le drapeau jaune natif n'est plus imposé.
 if g.dataRevision<2 then for _,profile in ipairs(M.profiles) do profiles[profile].yellowHud=false end end
 -- Révision 3 (Beta 1.4) : jeux de règles réels.
 if g.dataRevision<3 then
  for _,profile in ipairs(M.profiles) do
   local name=M.migrateRules(profile,profiles[profile])
   if name and name~='base' then upgraded[#upgraded+1]=profile..':regles '..name end
  end
 end
 if fresh then M.applyRules('base',profiles) end
 for _,profile in ipairs(M.profiles) do M.migrateProfile(profile,profiles[profile],g.dataRevision,false,upgraded) end
 -- Révision 9 (Beta 1.16) : interface en anglais à la première installation ; une installation existante, utilisée
 -- jusque-là en français, le reste.
 if g.dataRevision<9 and not fresh then g.language='fr' end
 -- Révision 11 (Beta 1.19) : voiture de sécurité par défaut, la Ferrari 458 Italia Stage 3 du jeu de base, si aucune
 -- n'était choisie ; un modèle déjà choisi l'a été par le pilote.
 if g.dataRevision<11 and not fresh then g.safetyCarPicked=g.safetyCarModel~='' and g.safetyCarModel~=M.globalDefaults.safetyCarModel end
 if g.dataRevision<11 and g.safetyCarModel=='' then g.safetyCarModel=M.globalDefaults.safetyCarModel end
 -- Révision 13 (Beta 1.24) : radar avant (léger freinage d'appoint progressif) activé par défaut.
 if g.dataRevision<13 and g.useBrakeAssist==false then g.useBrakeAssist=true end
 -- Révision 14 (Beta 1.25) : sens latéral perdu (0 / 0) sur une installation existante, jamais remesuré depuis (une
 -- seule tentative par lancement) : aucun déplacement latéral n'était plus écrit. Il reprend la convention d'AC,
 -- -1 / -1, mesurée sur cette installation jusqu'à la Beta 1.8 ; la mesure la confirme ou la corrige ensuite.
 local restored=g.dataRevision<14 and not fresh and g.offsetSign==0 and g.sideSign==0
 if restored then g.offsetSign=-1; g.sideSign=-1 end
 -- Révision 15 (Beta 1.26, demande du pilote) : messages d'origine d'AC masqués par défaut, repris sur l'overlay.
 if g.dataRevision<15 then g.overlayBlockMessages=true end
 g.dataRevision=M.dataRevision
 return upgraded,fresh,restored
end
-- Règles d'une catégorie, appliquées ensemble aux profils Essais, Qualifications et Course : clés de l'onglet
-- Règles de course (hors préférences du pilote) et réglages de double jaune propres à une catégorie (delta de zone,
-- Slow Zone, repli) de chaque profil de week-end ; un profil jamais réglé reçoit d'abord son préréglage recommandé.
-- Ces clés forment un axe indépendant des préréglages de session, qui les conservent.
local zoneRuleKeys={zoneDeltaPct=true,slowZoneKmh=true,yellowSpeedKmh=true}
M.ruleSchema={}
M.keptKeySet={classPatterns=true}; for _,key in ipairs(M.preferenceKeys) do M.keptKeySet[key]=true end
for _,s in ipairs(M.schema) do if s.group=='rules' and not M.keptKeySet[s.key] or zoneRuleKeys[s.key] then M.ruleSchema[#M.ruleSchema+1]=s end end
M.ruleKeySet={}
for _,s in ipairs(M.ruleSchema) do M.keptKeySet[s.key]=true; M.ruleKeySet[s.key]=true end
-- Beta 1.29 (demande du pilote) : un préréglage intégré ou personnel règle tout son profil, règles de championnat
-- comprises ; il ne garde que les préférences du pilote et les motifs de classes, aussi ignorés pour le reconnaître.
M.presetKeptKeySet={classPatterns=true}; for _,key in ipairs(M.preferenceKeys) do M.presetKeptKeySet[key]=true end
-- Réglage gardé par « Restaurer » et par un préréglage intégré : préférences du pilote, motifs de classes et règles de
-- championnat choisies ; en journée circuit, qu'aucun jeu de règles ne règle, les règles reviennent aussi au défaut.
function M.kept(profile,key) return M.keptKeySet[key] and (not M.solo(profile) or not M.ruleKeySet[key]) end
local function ruleValue(values,s,profile) local value=values[s.key]; if value==nil then return s.defaults[profile] end return value end
function M.restore(profile,p)
 local kept={}
 for _,group in ipairs(M.sections) do kept['section_'..group]=p['section_'..group] end
 for key in pairs(M.keptKeySet) do if M.kept(profile,key) then kept[key]=p[key] end end
 M.validate(profile,M.defaults(profile),p)
 for key,value in pairs(kept) do p[key]=value end
 M.validate(profile,p,p)
 return p
end
local function applyValues(category,profile,p) for _,s in ipairs(M.ruleSchema) do p[s.key]=ruleValue(M.rulePresets[category],s,profile) end end
-- Interrupteurs de l'onglet Règles de course (Beta 1.18) : arrêt obligatoire et voiture de sécurité, réglés ensemble pour
-- les Essais, Qualifications et Course comme les jeux de règles ; un profil jamais réglé reçoit d'abord son préréglage
-- recommandé. Arrêt obligatoire activé : le nombre d'arrêts réglé est gardé (un au moins).
function M.weekendSwitch(profiles,key,on)
 for _,profile in ipairs(M.ruleProfiles) do
  local p=profiles[profile]
  if not (p.configured or M.anySection(p)) and M.recommended[profile] then M.preset(M.recommended[profile],profile,p) end
  if key=='mandatoryStops' then p.mandatoryStops=on and math.max(1,p.mandatoryStops) or 0 else p[key]=on==true end
  p.configured=true
  M.validate(profile,p,p)
 end
end
function M.applyRules(category,profiles)
 if not M.rulePresets[category] then return false end
 for _,profile in ipairs(M.ruleProfiles) do
  local p=profiles[profile]
  if not p.configured and not M.anySection(p) and M.recommended[profile] then M.preset(M.recommended[profile],profile,p) end
  applyValues(category,profile,p)
  p.section_rules=true; p.configured=true
  M.validate(profile,p,p)
 end
 return true
end
-- Beta 1.29 : préréglage d'essais, de qualifications ou de course : ses règles de championnat valent pour tout le
-- week-end, comme un jeu de règles ou un interrupteur de l'onglet Règles de course. Seules les valeurs sont copiées
-- (onglet Règles laissé tel quel, profil jamais réglé laissé tel quel : son préréglage recommandé les garde ensuite).
-- Journée circuit et hotlap n'y touchent jamais.
function M.spreadRules(from,profiles)
 if M.solo(from) then return false end
 local source=profiles[from]
 for _,profile in ipairs(M.ruleProfiles) do
  local p=profiles[profile]
  if profile~=from then
   for _,s in ipairs(M.ruleSchema) do p[s.key]=source[s.key] end
   M.validate(profile,p,p)
  end
 end
 return true
end
-- Beta 1.29 (demande du pilote) : un préréglage intégré n'est allumé qu'après un clic, pour le profil affiché qu'il règle
-- (« J=Nordschleife,C=Endurance ») ; un préréglage recommandé appliqué tout seul n'en pose aucun.
function M.mark(g,profile)
 for x,name in (g.builtinMarks or ''):gmatch('(%u)=(%w+)') do if x==profile then return name end end
 return ''
end
function M.setMark(g,profile,name)
 local parts={}
 for _,x in ipairs(M.profiles) do local value=x==profile and (name or '') or M.mark(g,x); if value~='' then parts[#parts+1]=x..'='..value end end
 g.builtinMarks=table.concat(parts,',')
end
-- Préréglage intégré portant un jeu de règles (Endurance en course), pour le reconnaître.
function M.withRules(category,profile,p) applyValues(category,profile,p); return M.validate(profile,p,p) end
-- Axe et jeux de règles de la Beta 1.3, figés : un profil enregistré resté sur l'un d'eux reçoit sa version Beta 1.4.
local axis13={'noMoveBraking','neutralization','majorIncidentTime','fcySpeedKmh','fcyDeltaPct','vscDeltaPct','neutralizationHold',
 'safetyCarSpeedKmh','redFlagEnabled','redFlagCars','redFlagSpeedKmh','redDeltaPct','redFlagHold','mandatoryStops','pitWindowOpenPct',
 'pitWindowClosePct','pitTyres','pitCompoundChange','minPitTime','maxStintMin','pitMessage','overtakeMode','overtakeModeGap',
 'overtakeModeBoostPct','rulesDrs','rulesDrsLaps','aiDrs','bopEnabled','bopStrengthPct','proAmEnabled','predictableSlowClass','yellowSpeedKmh'}
local presets13={base={},F1={neutralization='vsc',mandatoryStops=1,pitWindowOpenPct=20,pitWindowClosePct=80,pitCompoundChange=true,overtakeMode=true},
 GT={neutralization='fcy',mandatoryStops=1,pitWindowOpenPct=30,pitWindowClosePct=70,minPitTime=50,bopEnabled=true,proAmEnabled=true},
 Endurance={neutralization='fcy',yellowSpeedKmh=80,maxStintMin=50,bopEnabled=true,proAmEnabled=true,predictableSlowClass=true}}
local schemaByKey={}; for _,s in ipairs(M.schema) do schemaByKey[s.key]=s end
local oldZoneDelta=70
local function category13(profile,p)
 for _,name in ipairs({'base','F1','GT','Endurance'}) do
  local values=presets13[name]; local same=true
  for _,key in ipairs(axis13) do
   local expected=values[key]; if expected==nil then expected=schemaByKey[key].defaults[profile] end
   if not equal(p[key],expected) then same=false; break end
  end
  if same then return name end
 end
 return nil
end
-- Profil (ou préréglage personnel) enregistré avant la Beta 1.4 : un jeu de règles de la Beta 1.3 resté intact devient
-- celui de la Beta 1.4 (F1 : F1 2025) ; le double jaune quitte l'ancien défaut (+70 %), un réglage du pilote est gardé.
-- Renvoie la catégorie appliquée, ou nil.
function M.migrateRules(profile,p)
 local zone=p.zoneDeltaPct
 local name=not M.solo(profile) and category13(profile,p) or nil
 if name then applyValues(name,profile,p) end
 if not equal(zone,oldZoneDelta) then p.zoneDeltaPct=zone elseif not name then p.zoneDeltaPct=schemaByKey.zoneDeltaPct.defaults[profile] end
 return name
end
-- skip : clés ignorées (révisions antérieures à ces clés).
-- Jeu de règles le plus proche (le moins de réglages différents ; à égalité, le premier de la liste) : réinitialisation d'un
-- jeu retouché (Beta 1.19).
function M.closestRuleCategory(profile,p,skip)
 local best,count=nil,math.huge
 for _,category in ipairs(M.ruleCategories) do
  local values=M.rulePresets[category]; local n=0
  for _,s in ipairs(M.ruleSchema) do if not (skip and skip[s.key]) and not equal(p[s.key],ruleValue(values,s,profile)) then n=n+1 end end
  if n<count then best,count=category,n end
 end
 return best
end
function M.ruleCategory(profile,p,skip)
 for _,category in ipairs(M.ruleCategories) do
  local values=M.rulePresets[category]; local same=true
  for _,s in ipairs(M.ruleSchema) do
   if not (skip and skip[s.key]) and not equal(p[s.key],ruleValue(values,s,profile)) then same=false; break end
  end
  if same then return category end
 end
 return nil
end
-- Modes Content Manager : Journée circuit = session « Track Day » de type essais ; Essai et essais d'un
-- week-end = essais déclarés sous un autre nom. Sans race.ini lisible, les essais restent en Journée circuit.
function M.autoProfile(frame)
 local declared=frame.configType~=nil and frame.configType>=1 and frame.configType<=7
 local kind=declared and frame.configType or frame.type
 -- Journée circuit Content Manager : session « Track Day », déclarée en essais (TYPE 1, 66 race.ini archivés) ou en
 -- qualifications (TYPE 2, relevé le 29 octobre 2026) ; jamais prise pour des qualifications.
 if declared and frame.configTrackDay and (kind==1 or kind==2) then return 'J' end
 if kind==3 then return 'C' elseif kind==2 then return 'Q' end
 if kind==1 and declared and not frame.configTrackDay then return 'P' end
 -- Hotlap, time attack, drift, drag : sessions sans IA, profil Hotlap.
 if kind>=4 and kind<=7 then return 'H' end
 return 'J'
end
return M
