local U=require('src/util')
local K=require('src/config').K
local M={fields={'highBeams','headlightsActive','lowBeams','flashingLightsActive'}}
function M.new()
 local f={on=false,onAt=0,lastEdge=-math.huge,lastPulse=-math.huge,burst=0,lastEvent=-math.huge,eventId=0,
  eventTime=-math.huge,eventCount=0,learnUntil=0,learned='',scores={},last={},requests={},rank={}}
 for i=1,#M.fields do f.scores[i]=0; f.last[i]=false end
 for i=1,K.maxCars do f.requests[i]={event=0,untilTime=0,cornerUntil=0,extended=false,readyAt=0,urgent=false,advantage=false,lastSeen=-math.huge,second=false}; f.rank[i]=i end
 -- Appels de phares entre IA : demande adressée à la voiture de devant par une IA plus rapide bloquée derrière.
 f.ai={}; for i=1,K.maxCars do f.ai[i]={source=0,untilTime=0,readyAt=0} end
 return f
end
function M.learn(self,now) self.learnUntil=now+K.flashLearnTime; self.learned=''; for i=1,#M.fields do self.scores[i]=0; self.last[i]=false end end
function M.sampleLearn(self,signals,now)
 if self.learnUntil==0 then return nil end
 for i=1,#M.fields do
  local v=signals[M.fields[i]]==true
  if v~=self.last[i] then self.scores[i]=self.scores[i]+1; self.last[i]=v end
 end
 if now<self.learnUntil then return nil end
 local best,score=0,0
 for i=1,#M.fields do if self.scores[i]>score then best=i; score=self.scores[i] end end
 self.learnUntil=0; self.learned=score>=2 and M.fields[best] or ''
 return self.learned
end
function M.step(self,signal,now)
 if signal==self.on or now-self.lastEdge<K.flashDebounce then return false end
 self.lastEdge=now; self.on=signal
 if signal then self.onAt=now; return false end
 local duration=now-self.onAt
 if duration>K.flashHoldMax then self.burst=0; return false end
 if now-self.lastPulse>K.flashBurst then self.burst=0 end
 self.lastPulse=now
 self.burst=math.min(K.flashUrgentCount,self.burst+(duration>=K.flashHoldMin and 2 or 1))
 if self.burst<2 or now-self.lastEvent<K.flashDedup then return false end
 self.eventId=self.eventId%K.counterMax+1; self.eventTime=now; self.eventCount=self.burst; self.lastEvent=now
 return true
end
function M.dispatch(self,cars,count,player,perception,states,p,g,_profile,now)
 if not player or p.flashMode=='never' or cars[player].kmh<=K.flashSpeed then return 0 end
 local ranked=0
 for i=1,count do
  local a=cars[i]; local st=states[i]; local row=perception.rows[i]
  local rel
  for j=1,row.count do if row.neighbors[j].index==player then rel=row.neighbors[j]; break end end
  local lapped=st.lappedByPlayer
  if a.control and not a.pit and not a.offtrack and a.kmh>K.flashSpeed and st.state~='IDLE' and st.state~='CALM'
   and rel and rel.same and rel.long<0 and math.abs(rel.lat)<=K.flashLat and rel.gap>=0 and rel.gap<=p.flashRange
   and (p.flashMode=='always' or lapped) then
   ranked=ranked+1; self.rank[ranked]=i
   local n=ranked-1
   while n>0 and states[self.rank[n]].playerGap>rel.gap do self.rank[n+1]=self.rank[n]; n=n-1 end
   self.rank[n+1]=i; st.playerGap=rel.gap
  end
 end
 local reacted=0
 for rank=1,math.min(ranked,p.flashMaxReactors) do
  local i=self.rank[rank]; local st=states[i]; local req=self.requests[i]
  local second=now-req.lastSeen<=K.flashSecondTime; req.lastSeen=now
  local oblivious=U.unit(g.seed,i,self.eventId)<p.flashObliviousPct/100
  if second or not oblivious then
   local sa=st.playerSa
   req.event=self.eventId; req.untilTime=now+p.flashRequestTTL; req.readyAt=now+(rank-1)*K.flashPropagation
   req.cornerUntil=now+math.max(p.flashRequestTTL,K.pendingTTL); req.extended=false
   req.urgent=second or self.eventCount>=K.flashUrgentCount; req.second=second
   req.advantage=sa>=p.flashMinAdvantage or (st.playerGap<=K.flashCloseGap and sa>=p.flashCloseAdvantage)
   if st.state=='YIELD_IN' or st.state=='YIELD_HOLD' then st.holdUntil=math.max(st.holdUntil,now+p.yieldHoldMin); st.urgent=st.urgent or req.urgent end
   reacted=reacted+1
  end
 end
 return reacted
end
return M
