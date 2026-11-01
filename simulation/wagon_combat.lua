-- S28 only: fixed 100ms ticks, independent clocks, no expedition side effects.
local util=require "simulation.util"
local rng=require "simulation.rng"
local content=require "content.ambush"
local M={RULES="wagon-ambush-v1",TICK=0.1,LIMIT=1800,kits=content.kits,presets=content.presets,positions=content.positions}
local function alive(u) return u and u.hp>0 end
local function lane(u) return (u.position-1)%2+1 end
function M.unit(s,id)
    if id=="wagon" then return s.wagon end
    for _,u in ipairs(s.units) do if u.id==id then return u end end
end
function M.interval(u) return u.id=="ember" and u.position<=2 and 8 or content.kits[u.id].interval end
local function log(s,kind,source,target,value)
    local e={tick=s.tick,kind=kind,source=source or "",target=target or "",value=value or 0}
    s.events[#s.events+1]=e
    if #s.events>90 then table.remove(s.events,1) end
end
local function add(s,id,side,position)
    local k=content.kits[id]
    s.units[#s.units+1]={id=id,side=side,position=position,hp=k.hp,max_hp=k.hp,def=k.def,shield=0,
        focus=0,cost=k.cost,attack_left=k.interval+rng.int(s,"rng",0,3),target="",effects={},
        stats={damage=0,absorbed=0,intercepts=0,attacks=0,casts=0,reactions=0,stuns=0}}
end
function M.new(preset,seed,crew)
    preset=content.presets[preset] and preset or "guard"
    local s={rules=M.RULES,phase="setup",preset=preset,seed=seed or 1848,rng=rng.seed(seed or 1848),tick=0,
        units={},events={},wagon={id="wagon",hp=100,max_hp=100,def=0,shield=0},result=""}
    for _,id in ipairs(crew or {"moss","ember","lumen"}) do
        assert(id=="moss" or id=="ember" or id=="lumen","Unknown companion")
        assert(not M.unit(s,id),"Duplicate companion")
        add(s,id,"crew",content.presets[preset].positions[id])
    end
    assert(#s.units>=1 and #s.units<=3,"One to three companions required")
    add(s,"raider","foe",1);add(s,"caller","foe",4)
    return s
end
local function defender(s,side,wanted_lane)
    for _,u in ipairs(s.units) do
        if alive(u) and u.side==side and u.position<=2 and lane(u)==wanted_lane then return u end
    end
end
function M.target(s,u)
    if u.id=="raider" then return defender(s,"crew",lane(u)) or s.wagon end
    local side=u.side=="crew" and "foe" or "crew"
    local best,rank
    for _,v in ipairs(s.units) do
        if alive(v) and v.side==side then
            local r=(v.position<=2 and 0 or 10)+(lane(v)==lane(u) and 0 or 2)
            if not best or r<rank then best,rank=v,r end
        end
    end
    return best
end
local function targets(s)
    for _,u in ipairs(s.units) do local v=alive(u) and M.target(s,u);u.target=v and v.id or "" end
end
function M.move(s,id,position)
    local u=M.unit(s,id)
    if s.phase~="setup" or not u or u.side~="crew" or position<1 or position>4 or position~=math.floor(position) then return false end
    for _,v in ipairs(s.units) do if v~=u and v.side=="crew" and v.position==position then v.position=u.position end end
    u.position=position;s.preset="custom";targets(s);return true
end
function M.start(s)
    if s.phase~="setup" then return false end
    s.phase="fight"
    for _,u in ipairs(s.units) do u.attack_left=M.interval(u)+(u.attack_left-content.kits[u.id].interval) end
    targets(s);return true
end
function M.effect(s,target,kind,source,value,duration)
    if not alive(target) then return end
    -- One effect of a kind per source. Refresh rather than unbounded stacking.
    for _,e in ipairs(target.effects) do
        if e.kind==kind and e.source==source then e.until_tick=s.tick+duration;e.value=value;return end
    end
    target.effects[#target.effects+1]={kind=kind,source=source,value=value,until_tick=s.tick+duration}
end
function M.has(u,kind)
    for _,e in ipairs(u.effects or {}) do if e.kind==kind then return true end end
    return false
end
function M.shield(s,u,amount,source)
    if not alive(u) then return end
    local added=math.min(amount,u.max_hp-u.shield);u.shield=u.shield+added
    log(s,"shield",source,u.id,added)
end
-- Reactions are queued once per source per tick; reactions cannot cause reactions.
local function damage(s,source,target,amount,kind,intercept,queue)
    if not alive(target) then return end
    local defense=target.def+(target.id=="moss" and target.position<=2 and 55 or 0)
    local hit=math.max(0,math.floor(amount*100/(100+defense)+0.5))
    local absorbed=math.min(hit,target.shield);target.shield=target.shield-absorbed
    local lost=math.min(target.hp,hit-absorbed);target.hp=target.hp-lost
    source.stats.damage=source.stats.damage+lost
    if target.stats then target.stats.absorbed=target.stats.absorbed+absorbed end
    log(s,kind,source.id,target.id,lost)
    if absorbed>0 then log(s,"absorbed",target.id,source.id,absorbed) end
    if intercept then
        target.stats.intercepts=target.stats.intercepts+1;log(s,"intercept",target.id,source.id,hit)
        local ember=M.unit(s,"ember")
        if queue and alive(ember) and target.id~=ember.id and not M.has(ember,"stun") then queue[ember.id]=source.id end
    end
    if target.hp==0 then target.shield=0;target.effects=target.effects and {} or nil;log(s,"down",source.id,target.id) end
end
local function strike(s,u,power,kind,queue,chosen)
    local t=chosen or M.target(s,u)
    if not t then return end
    u.target=t.id
    damage(s,u,t,power,kind,u.id=="raider" and t.id~="wagon",queue)
end
local function cast(s,u,queue)
    u.focus=u.focus-u.cost;u.stats.casts=u.stats.casts+1;log(s,"cast",u.id,"",u.stats.casts)
    if u.id=="moss" then
        M.shield(s,u,22,u.id);M.shield(s,s.wagon,8,u.id)
    elseif u.id=="ember" then strike(s,u,26,"skill",queue)
    elseif u.id=="lumen" then
        local t=M.unit(s,"caller");if not alive(t) then t=M.target(s,u) end
        if t then
            strike(s,u,8,"skill",queue,t)
            if alive(t) then
                M.effect(s,t,"stun",u.id,1,14);u.stats.stuns=u.stats.stuns+1;log(s,"stun",u.id,t.id,14)
                local ally
                for _,v in ipairs(s.units) do if alive(v) and v.side=="crew" and v~=u and (not ally or v.focus/v.cost<ally.focus/ally.cost) then ally=v end end
                if ally then ally.focus=math.min(ally.cost,ally.focus+6);log(s,"focus",u.id,ally.id,6) end
            end
        end
    elseif u.id=="raider" then strike(s,u,26,"skill",queue)
    elseif u.id=="caller" then
        local t=M.target(s,u)
        if t then strike(s,u,10,"skill",queue,t);M.effect(s,t,"slow",u.id,50,30);log(s,"slow",u.id,t.id,30) end
    end
end
local function outcome(s)
    local crew,foes=0,0
    for _,u in ipairs(s.units) do if alive(u) then if u.side=="crew" then crew=crew+1 else foes=foes+1 end end end
    if s.wagon.hp==0 then return "wagon_lost" end
    if crew==0 then return "crew_down" end
    if foes==0 then return "victory" end
    if s.tick>=M.LIMIT then return "stalemate" end
end
local function finish(s,result)
    s.phase="result";s.result=result;targets(s);log(s,"result","",result)
end
function M.retreat(s)
    if s.phase~="fight" then return false end
    finish(s,"retreated");return true
end
function M.step(s,count)
    count=count or 1
    assert(type(count)=="number" and count>=0 and count<=M.LIMIT and count==math.floor(count),"Invalid tick count")
    for _=1,count do
        if s.phase~="fight" then break end
        local ended=outcome(s);if ended then finish(s,ended);break end
        s.tick=s.tick+1
        -- Abilities precede basic attacks. Stable saved unit order breaks ties;
        -- a KO cancels that unit's remaining actions, never resurrects it.
        for _,u in ipairs(s.units) do
            for i=#u.effects,1,-1 do if u.effects[i].until_tick<=s.tick then table.remove(u.effects,i) end end
            if alive(u) and not M.has(u,"stun") then
                u.focus=math.min(u.cost,u.focus+1)
                if not M.has(u,"slow") or s.tick%2==0 then u.attack_left=math.max(0,u.attack_left-1) end
            end
        end
        local reactions={}
        for _,u in ipairs(s.units) do if alive(u) and not M.has(u,"stun") and u.focus>=u.cost then cast(s,u,reactions) end end
        for _,u in ipairs(s.units) do
            if alive(u) and not M.has(u,"stun") and u.attack_left<=0 then
                u.attack_left=M.interval(u);u.stats.attacks=u.stats.attacks+1
                strike(s,u,content.kits[u.id].attack,"attack",reactions)
            end
        end
        for _,u in ipairs(s.units) do
            local target=reactions[u.id] and M.unit(s,reactions[u.id])
            if alive(u) and alive(target) and not M.has(u,"stun") then
                u.stats.reactions=u.stats.reactions+1;damage(s,u,target,7,"follow",false,nil)
            end
        end
        targets(s);ended=outcome(s);if ended then finish(s,ended) end
    end
    return s
end
local function integer(v,lo,hi) return util.finite(v) and v>=lo and v<=hi and v==math.floor(v) end
local results={victory=true,wagon_lost=true,crew_down=true,retreated=true,stalemate=true}
function M.validate(s)
    if type(s)~="table" or s.rules~=M.RULES or (s.phase~="setup" and s.phase~="fight" and s.phase~="result") then return false,"Unsupported ambush" end
    if not integer(s.tick,0,M.LIMIT) or not integer(s.seed,0,2147483646) or not integer(s.rng,1,2147483646) then return false,"Invalid ambush clock" end
    if s.phase=="result" and not results[s.result] or s.phase~="result" and s.result~="" then return false,"Invalid ambush result" end
    if not content.presets[s.preset] and s.preset~="custom" then return false,"Invalid formation" end
    local wagon=s.wagon
    if type(wagon)~="table" or wagon.id~="wagon" or wagon.max_hp~=100 or wagon.def~=0 or not integer(wagon.hp,0,100) or not integer(wagon.shield,0,100) then return false,"Invalid wagon" end
    if type(s.units)~="table" or #s.units<3 or #s.units>5 or type(s.events)~="table" or #s.events>90 then return false,"Invalid units or log" end
    local seen,slots={},{}
    for _,u in ipairs(s.units) do
        if type(u)~="table" or not content.kits[u.id] or seen[u.id] then return false,"Invalid unit" end
        local k=content.kits[u.id];seen[u.id]=true
        if u.side~=((u.id=="raider" or u.id=="caller") and "foe" or "crew") or not integer(u.position,1,4) or slots[u.side..u.position] then return false,"Invalid position" end
        slots[u.side..u.position]=true
        if u.max_hp~=k.hp or u.def~=k.def or u.cost~=k.cost or not integer(u.hp,0,k.hp) or not integer(u.shield,0,k.hp) or not integer(u.focus,0,k.cost) or not integer(u.attack_left,0,53) then return false,"Invalid unit resource" end
        if type(u.effects)~="table" or #u.effects>10 or type(u.stats)~="table" or type(u.target)~="string" then return false,"Invalid unit state" end
        for _,key in ipairs({"damage","absorbed","intercepts","attacks","casts","reactions","stuns"}) do if not integer(u.stats[key],0,100000) then return false,"Invalid statistics" end end
        for _,e in ipairs(u.effects) do
            if type(e)~="table" or (e.kind~="stun" and e.kind~="slow") or not integer(e.value,1,100) or not integer(e.until_tick,s.tick+1,M.LIMIT+30) or not content.kits[e.source] then return false,"Invalid effect" end
        end
    end
    if not seen.raider or not seen.caller then return false,"Missing opponent" end
    for _,u in ipairs(s.units) do if u.target~="" and u.target~="wagon" and not seen[u.target] then return false,"Missing target" end end
    for _,e in ipairs(s.events) do
        if type(e)~="table" or not integer(e.tick,0,s.tick) or type(e.kind)~="string" or #e.kind>20 or type(e.source)~="string" or #e.source>20 or type(e.target)~="string" or #e.target>20 or not integer(e.value,0,100000) then return false,"Invalid event" end
    end
    return true
end
return M
