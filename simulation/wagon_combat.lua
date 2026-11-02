-- Fixed 100ms clocks; v1 checkpoints retain their original resolver.
local util=require "simulation.util"
local rng=require "simulation.rng"
local content=require "content.ambush"
local legacy=require "simulation.wagon_combat_v1"
local items=require "content.work_items"
local M={RULES="wagon-ambush-v2",TICK=0.1,LIMIT=1800,kits=content.kits,presets=content.presets,positions=content.positions}
local function alive(u) return u and u.hp>0 end
local function lane(u) return (u.position-1)%2+1 end
function M.unit(s,id)
    if id=="wagon" then return s.wagon end
    for _,u in ipairs(s.units) do if u.id==id then return u end end
end
function M.interval(u)
    local n=u.id=="ember" and u.position<=2 and 8 or content.kits[u.id].interval
    return math.min(50,n+(u.item=="padded_trace" and 2 or 0))
end
function M.defense(u)
    return math.max(0,u.def+(u.id=="moss" and u.position<=2 and 55 or 0)+(u.item=="padded_trace" and 18 or 0)-(u.item=="release_rope" and 5 or 0))
end
function M.crew(s)
    local list={};for _,u in ipairs(s.units) do if u.side=="crew" then list[#list+1]=u end end;return list
end
function M.kit(s,id)
    local k=util.copy(content.kits[id])
    for key,value in pairs(((content.road[s.scenario] or {})[id]) or {}) do k[key]=value end
    local u=M.unit(s,id);if u and u.name then k.name=u.name end
    if s.scenario=="mara" and content.mara[id] then for key,value in pairs(content.mara[id]) do k[key]=value end end
    return k
end
local function log(s,kind,source,target,value)
    local e={tick=s.tick,kind=kind,source=source or "",target=target or "",value=value or 0}
    s.events[#s.events+1]=e
    if #s.events>90 then table.remove(s.events,1) end
end
local function add(s,id,side,position)
    local k=M.kit(s,id)
    s.units[#s.units+1]={id=id,side=side,position=position,hp=k.hp,max_hp=k.hp,def=k.def,shield=0,
        focus=0,cost=k.cost,attack_left=k.interval+rng.int(s,"rng",0,3),target="",effects={},item="",opening=0,proc_tick=-1,
        stats={damage=0,absorbed=0,intercepts=0,attacks=0,casts=0,reactions=0,stuns=0,shielded=0,openings=0,item_procs=0}}
end
function M.new(preset,seed,crew,scenario)
    preset=content.presets[preset] and preset or "guard"
    local s={rules=M.RULES,phase="setup",preset=preset,seed=seed or 1848,rng=rng.seed(seed or 1848),tick=0,
        scenario=scenario or "ambush",supplies={medicine=1,repairs=1},used={medicine=0,repairs=0},units={},events={},wagon={id="wagon",hp=100,max_hp=100,def=0,shield=0},result=""}
    for i,id in ipairs(crew or content.presets[preset].crew or {"moss","ember","lumen"}) do
        assert(content.kits[id] and id~="raider" and id~="caller","Unknown companion")
        assert(not M.unit(s,id),"Duplicate companion")
        add(s,id,"crew",content.presets[preset].positions[id] or ({1,3,4})[i])
        s.units[#s.units].item=(content.presets[preset].items or {})[id] or ""
    end
    assert(#s.units>=1 and #s.units<=3,"One to three companions required")
    -- Fill any colliding default positions for arbitrary teams.
    local occupied={}
    for _,u in ipairs(s.units) do
        if occupied[u.position] then for _,pos in ipairs({1,3,4,2}) do if not occupied[pos] then u.position=pos;break end end end
        occupied[u.position]=true
    end
    add(s,"raider","foe",1);add(s,"caller","foe",4)
    return s
end
local function defender(s,side,wanted_lane)
    for _,u in ipairs(s.units) do
        if alive(u) and u.side==side and u.position<=2 and lane(u)==wanted_lane then return u end
    end
end
function M.target(s,u,ignore_lure)
    if s.rules==legacy.RULES then return legacy.target(s,u) end
    for _,e in ipairs(u.effects) do
        if not ignore_lure and e.kind=="lure" and alive(M.unit(s,e.source)) then return M.unit(s,e.source) end
    end
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
    if s.rules==legacy.RULES then return legacy.move(s,id,position) end
    local u=M.unit(s,id)
    if s.phase~="setup" or not u or u.side~="crew" or position<1 or position>4 or position~=math.floor(position) then return false end
    for _,v in ipairs(s.units) do if v~=u and v.side=="crew" and v.position==position then v.position=u.position end end
    u.position=position;s.preset="custom";targets(s);return true
end
function M.start(s)
    if s.rules==legacy.RULES then return legacy.start(s) end
    if s.phase~="setup" then return false end
    s.phase="fight"
    for _,u in ipairs(s.units) do u.attack_left=M.interval(u)+(u.attack_left-content.kits[u.id].interval) end
    targets(s);return true
end
function M.effect(s,target,kind,source,value,duration)
    if s.rules==legacy.RULES then return legacy.effect(s,target,kind,source,value,duration) end
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
    if s.rules==legacy.RULES then return legacy.shield(s,u,amount,source) end
    if not alive(u) then return end
    local added=math.min(amount,u.max_hp-u.shield);u.shield=u.shield+added
    log(s,"shield",source,u.id,added)
    local giver=M.unit(s,source);if giver and giver.stats then giver.stats.shielded=giver.stats.shielded+added end
end
-- Reactions are queued once per source per tick; reactions cannot cause reactions.
local function damage(s,source,target,amount,kind,intercept,queue)
    if not alive(target) then return end
    local defense=M.defense(target)
    if M.has(target,"expose") then amount=amount*1.25 end
    local hit=math.max(0,math.floor(amount*100/(100+defense)+0.5))
    local absorbed=math.min(hit,target.shield);target.shield=target.shield-absorbed
    local lost=math.min(target.hp,hit-absorbed);target.hp=target.hp-lost
    source.stats.damage=source.stats.damage+lost
    if target.stats then target.stats.absorbed=target.stats.absorbed+absorbed end
    log(s,kind,source.id,target.id,lost)
    if absorbed>0 then
        log(s,"absorbed",target.id,source.id,absorbed)
        if target.id=="flint" and target.proc_tick~=s.tick and alive(target) then
            target.proc_tick=s.tick;target.focus=math.min(target.cost,target.focus+4);log(s,"focus",target.id,target.id,4)
        end
    end
    if intercept then
        target.stats.intercepts=target.stats.intercepts+1;log(s,"intercept",target.id,source.id,hit)
        if target.id=="ripple" and target.proc_tick~=s.tick and alive(target) then
            target.proc_tick=s.tick;target.attack_left=math.max(0,target.attack_left-5);log(s,"quick",target.id,target.id,5)
        end
        if target.item=="padded_trace" and target.item_tick~=s.tick and alive(target) then
            target.item_tick=s.tick;target.focus=math.min(target.cost,target.focus+3);target.stats.item_procs=target.stats.item_procs+1
            log(s,"focus",target.id,target.id,3)
        end
        local ember=M.unit(s,"ember")
        if queue and alive(ember) and target.id~=ember.id and not M.has(ember,"stun") then queue[ember.id]=source.id end
    end
    if target.hp==0 then target.shield=0;target.effects=target.effects and {} or nil;log(s,"down",source.id,target.id) end
end
local function strike(s,u,power,kind,queue,chosen)
    local t=chosen or M.target(s,u,kind~="attack")
    if not t then return end
    u.target=t.id
    local redirected=false
    if kind=="attack" then
        for i=#u.effects,1,-1 do if u.effects[i].kind=="lure" then
            redirected=alive(M.unit(s,u.effects[i].source)) and t.id==u.effects[i].source;table.remove(u.effects,i)
        end end
        if u.item=="dry_wrap" then power=math.max(1,power-2) end
        if u.item=="release_rope" and M.has(t,"expose") then
            power=power+4;u.stats.item_procs=u.stats.item_procs+1;log(s,"rope",u.id,t.id,4)
        end
        if u.id=="pip" then for _,e in ipairs(t.effects) do
            if e.kind=="expose" and e.until_tick~=u.opening then
                u.opening=e.until_tick;u.attack_left=math.max(0,u.attack_left-5);u.stats.openings=u.stats.openings+1;log(s,"quick",u.id,u.id,5);break
            end
        end end
    end
    damage(s,u,t,power,kind,redirected or (u.id=="raider" and t.id~="wagon"),queue)
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
    elseif u.id=="ripple" then
        local t=M.unit(s,"raider");if not alive(t) then t=M.target(s,u) end
        if t then
            strike(s,u,10,"skill",queue,t)
            if alive(t) then
                M.effect(s,t,"stun",u.id,1,6);M.effect(s,t,"lure",u.id,1,30)
                u.stats.stuns=u.stats.stuns+1;log(s,"stun",u.id,t.id,6)
            end
        end
    elseif u.id=="pip" then
        local t=M.target(s,u);if t then
            strike(s,u,12,"skill",queue,t);M.effect(s,t,"expose",u.id,25,30);log(s,"expose",u.id,t.id,30)
        end
    elseif u.id=="flint" then
        local ally
        for _,v in ipairs(s.units) do if alive(v) and v.side==u.side and v~=u and (not ally or v.shield/v.max_hp<ally.shield/ally.max_hp) then ally=v end end
        M.shield(s,ally or u,22,u.id)
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
    if s.rules==legacy.RULES then return legacy.retreat(s) end
    if s.phase~="fight" then return false end
    finish(s,"retreated");return true
end
function M.step(s,count)
    if s.rules==legacy.RULES then return legacy.step(s,count) end
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
                if u.item=="dry_wrap" and s.tick%4==0 then
                    local covered=false
                    for _,ally in ipairs(s.units) do if alive(ally) and ally.side==u.side and ally.shield>0 then covered=true;break end end
                    if covered then u.focus=math.min(u.cost,u.focus+1);u.stats.item_procs=u.stats.item_procs+1 end
                end
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
    if type(s)=="table" and s.rules==legacy.RULES then return legacy.validate(s) end
    if type(s)~="table" or s.rules~=M.RULES or (s.phase~="setup" and s.phase~="fight" and s.phase~="result") then return false,"Unsupported ambush" end
    if not integer(s.tick,0,M.LIMIT) or not integer(s.seed,0,2147483646) or not integer(s.rng,1,2147483646) then return false,"Invalid ambush clock" end
    if s.phase=="result" and not results[s.result] or s.phase~="result" and s.result~="" then return false,"Invalid ambush result" end
    if not content.presets[s.preset] and s.preset~="custom" then return false,"Invalid formation" end
    if s.scenario~="ambush" and s.scenario~="mara" and not content.road[s.scenario] then return false,"Invalid encounter" end
    if type(s.supplies)~="table" or type(s.used)~="table" then return false,"Missing supplies" end
    for _,id in ipairs({"medicine","repairs"}) do
        if not integer(s.supplies[id],0,1) or not integer(s.used[id],0,1) or s.supplies[id]+s.used[id]>(1) or (not content.road[s.scenario] and s.supplies[id]+s.used[id]~=1) then return false,"Invalid supplies" end
    end
    local wagon=s.wagon
    if type(wagon)~="table" or wagon.id~="wagon" or wagon.max_hp~=100 or wagon.def~=0 or not integer(wagon.hp,0,100) or not integer(wagon.shield,0,100) then return false,"Invalid wagon" end
    if type(s.units)~="table" or #s.units<3 or #s.units>5 or type(s.events)~="table" or #s.events>90 then return false,"Invalid units or log" end
    local seen,slots,gear={},{},{}
    for _,u in ipairs(s.units) do
        if type(u)~="table" or not content.kits[u.id] or seen[u.id] then return false,"Invalid unit" end
        local k=M.kit(s,u.id);seen[u.id]=true
        if u.name~=nil and (type(u.name)~="string" or #u.name>72) then return false,"Invalid companion name" end
        if type(u.item)~="string" or (u.item~="" and (not items.defs[u.item] or gear[u.item] or u.side~="crew")) then return false,"Invalid equipment" end
        if u.item~="" then gear[u.item]=true end
        if not integer(u.opening,0,M.LIMIT+30) or not integer(u.proc_tick,-1,s.tick) or (u.item_tick~=nil and not integer(u.item_tick,0,s.tick)) then return false,"Invalid trigger state" end
        if u.side~=((u.id=="raider" or u.id=="caller") and "foe" or "crew") or not integer(u.position,1,4) or slots[u.side..u.position] then return false,"Invalid position" end
        slots[u.side..u.position]=true
        if u.max_hp~=k.hp or u.def~=k.def or u.cost~=k.cost or not integer(u.hp,0,k.hp) or not integer(u.shield,0,k.hp) or not integer(u.focus,0,k.cost) or not integer(u.attack_left,0,53) then return false,"Invalid unit resource" end
        if type(u.effects)~="table" or #u.effects>10 or type(u.stats)~="table" or type(u.target)~="string" then return false,"Invalid unit state" end
        for _,key in ipairs({"damage","absorbed","intercepts","attacks","casts","reactions","stuns","shielded","openings","item_procs"}) do if not integer(u.stats[key],0,100000) then return false,"Invalid statistics" end end
        for _,e in ipairs(u.effects) do
            if type(e)~="table" or (e.kind~="stun" and e.kind~="slow" and e.kind~="expose" and e.kind~="lure") or not integer(e.value,1,100) or not integer(e.until_tick,s.tick+1,M.LIMIT+30) or not content.kits[e.source] then return false,"Invalid effect" end
        end
    end
    if not seen.raider or not seen.caller then return false,"Missing opponent" end
    for _,u in ipairs(s.units) do
        if u.target~="" and u.target~="wagon" and not seen[u.target] then return false,"Missing target" end
        local effects={}
        for _,e in ipairs(u.effects) do
            local key=e.kind..e.source
            if not seen[e.source] or effects[key] then return false,"Missing or duplicate effect source" end
            effects[key]=true
        end
    end
    for _,e in ipairs(s.events) do
        if type(e)~="table" or not integer(e.tick,0,s.tick) or type(e.kind)~="string" or #e.kind>20 or type(e.source)~="string" or #e.source>20 or type(e.target)~="string" or #e.target>20 or not integer(e.value,0,100000) then return false,"Invalid event" end
    end
    return true
end
function M.equip(s,id,item)
    local u=M.unit(s,id)
    if s.rules~=M.RULES or s.phase~="setup" or not u or u.side~="crew" or (item~="" and not items.defs[item]) then return false end
    for _,v in ipairs(s.units) do if item~="" and v.item==item then v.item="" end end
    u.item=item;return true
end
function M.replace(s,id,replacement)
    local old=M.unit(s,id)
    if s.rules~=M.RULES or s.phase~="setup" or not old or old.side~="crew" or M.unit(s,replacement) or not content.by_species[(content.kits[replacement] or {}).species] then return false end
    local index;for i,u in ipairs(s.units) do if u==old then index=i end end
    add(s,replacement,"crew",old.position);local fresh=table.remove(s.units);fresh.item=old.item;s.units[index]=fresh;s.preset="custom";targets(s);return true
end
function M.supply_target(s,id)
    if s.rules~=M.RULES or s.phase~="fight" or not s.supplies[id] or s.supplies[id]==0 then return end
    if id=="repairs" then if s.wagon.hp>0 and s.wagon.hp<s.wagon.max_hp then return s.wagon end;return end
    local ally;for _,u in ipairs(M.crew(s)) do if alive(u) and u.hp<u.max_hp and (not ally or u.hp/u.max_hp<ally.hp/ally.max_hp) then ally=u end end;return ally
end
function M.supply(s,id)
    local t=M.supply_target(s,id);if not t then return false end
    local amount=math.min(t.max_hp-t.hp,id=="repairs" and 20 or 28)
    t.hp=t.hp+amount;s.supplies[id]=s.supplies[id]-1;s.used[id]=s.used[id]+1;log(s,"supply",id,t.id,amount);return true
end
return M
