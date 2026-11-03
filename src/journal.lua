-- Journal de session : lignes nouvelles du journal circulaire, horodatées ; l'écriture sur disque est faite par applier.
local M={}
function M.new() return {serial=0,lines={},count=0,flushAt=0,summaryAt=0} end
-- Lignes ajoutées depuis le dernier prélèvement, de la plus ancienne à la plus récente.
function M.collect(j,log,stamp)
 for n=log.count-1,0,-1 do
  local r=log[(log.head-n-1)%log.limit+1]
  if r.serial>j.serial then
   j.serial=r.serial; j.count=j.count+1
   j.lines[j.count]=string.format('%s %9.1f %-5s %3d %s',stamp,r.time,r.level,r.index,r.message)
  end
 end
end
function M.take(j)
 if j.count==0 then return nil end
 local text=table.concat(j.lines,'\n',1,j.count)..'\n'
 for i=1,j.count do j.lines[i]=nil end
 j.count=0
 return text
end
-- Résumé périodique : IA gérées par état, incidents et neutralisation, coût mesuré.
function M.summary(e)
 local frame=e.frame; local ai,managed,drive,yield,pass,avoid,calm,yellow=0,0,0,0,0,0,0,0
 local unmanaged={}
 if frame then
  for i=1,frame.count do
   local a=frame.cars[i]
   if a.valid and a.control and not a.player then
    ai=ai+1
    local s=e.states[i]; local state=s.state
    if e.commands[i].active then managed=managed+1
    -- IA non gérée et sa raison (voiture de sécurité exclue).
    elseif not a.safetyCar then
     unmanaged[#unmanaged+1]=i..' '..(a.pit and 'stands' or a.offtrack and 'hors piste' or a.finished and 'arrivee' or s.disqualified and 'disqualifiee' or s.excluded and 'ecartee' or e.time<s.errorUntil and 'erreur' or 'attente')
    end
    if state=='DRIVE' then drive=drive+1 elseif state:sub(1,5)=='YIELD' then yield=yield+1
    elseif state:sub(1,3)=='OVT' then pass=pass+1 elseif state=='AVOID' then avoid=avoid+1 elseif state=='CALM' then calm=calm+1 end
    if s.yellow then yellow=yellow+1 end
   end
  end
 end
 local t=e.incidents
 -- Événements de la minute écoulée : transitions des IA (par raison), appels, blocages, incidents ; puis remise à zéro.
 local n=e.stats or {}
 local function c(key) return n[key] or 0 end
 local minute=string.format(' | sur la minute : depassements tentes %d, reussis %d, annules %d (cote ferme %d, cible plus rapide %d, sans rapprochement %d, suiveur rapide %d, cible perdue %d, jaune %d), invitations du joueur %d, passages sur cession %d, cessions %d, abouties %d, cessions sans passage %d, defenses %d, evitements %d, contacts %d, reprises au calme %d, appels de phares %d, blocages %d, manoeuvres interrompues par blocage %d, incidents %d, IA arretees %d',
  c('pass')+c('chain')+c('invited')+c('yielded'),c('clear')+c('chain'),c('abort_blocked')+c('abort_slow')+c('abort_stall')+c('abort_follower')+c('target_lost')+c('abort_yellow'),c('abort_blocked'),c('abort_slow'),c('abort_stall'),c('abort_follower'),c('target_lost'),c('abort_yellow'),c('invited'),c('yielded'),c('yield'),c('passed'),c('lost'),c('attacker'),c('obstacle'),c('contactEvent'),c('contact'),c('flash'),c('limit'),c('direction_limit'),t.started,t.held)
 -- Règles d'arrêt de la 1.6.0 : voitures lentes écartées des incidents et bouchons suivis sans évitement.
 minute=minute..string.format(' | arrets ecartes : file %d, depart ou stands %d, au pas %d | bouchons suivis sans evitement %d',
  t.suppressed.queue,t.suppressed.spawn,t.suppressed.crawl,c('jam'))
 -- Beta 1.31 : vrais dépassements entre IA (échange de places à moins de 20 m), dont ceux menés par une manœuvre de
 -- l'app, et IA passées devant le joueur.
 minute=minute..string.format(' | depassements reels %d (manoeuvre de l app %d), IA passees devant le joueur %d',c('realPass'),c('realPassApp'),c('passedPlayer'))
 t.suppressed.queue=0; t.suppressed.spawn=0; t.suppressed.crawl=0
 local drsOpen,drsAsk=c('drsOpen'),c('drsAsk')
 for key in pairs(n) do n[key]=0 end
 t.started=0; t.held=0
 -- Pneus des IA à l'instant du résumé, et météo retenue par l'app.
 local dry,inter,wet,unknown=0,0,0,0
 if frame then
  for i=1,frame.count do
   local a=frame.cars[i]
   if a.valid and a.control and not a.player then
    if not a.tyresKnown or a.compoundIndex==nil then unknown=unknown+1
    elseif a.currentTyreIsDry then dry=dry+1
    elseif a.compoundIndex==a.interCompound then inter=inter+1
    elseif a.compoundIndex==a.wetCompound then wet=wet+1
    else unknown=unknown+1 end
   end
  end
 end
 minute=minute..string.format(' | pneus IA : secs %d, intermediaires %d, pluie %d, inconnus %d (meteo %s)',dry,inter,wet,unknown,e.weather and e.weather.wet and 'pluie' or 'sec')
  ..string.format(' | DRS des IA : ouvertures %d, dont demandees par l app %d',drsOpen,drsAsk)
 return string.format('resume: profil %s, garde %s, IA %d, gerees %d | conduite %d, cession %d, depassement %d, evitement %d, recuperation %d | sous jaune %d, incidents %d, zones %d, IA arretees %d, neutralisation %s | cout moyen %.3f ms, max %.3f ms, erreurs %d',
  e.profile,e.guard,ai,managed,drive,yield,pass,avoid,calm,yellow,t.activeCount,t.zoneCount,t.holdCount,t.neutral and t.neutralMode or 'aucune',e.meanFrame,e.maxFrame,e.errors)
  ..(e.maxFrame==0 and ' (cout non mesure : aucun chronometre disponible)' or '')..(#unmanaged>0 and ' | hors gestion : '..table.concat(unmanaged,', ') or '')..minute
end
return M
