-- Bounded S5 study, reusing the expedition reporter rather than another engine.
package.path="./?.lua;./?/init.lua;"..package.path
local model=require "simulation.expedition"
local progression=require "simulation.progression"
local runner=require "tools.report.runner"
local reference=require "tools.report.policy"
local json=require "tools.report.json"
local util=require "simulation.util"
local species=model.species
local output=assert(arg[1],"Output JSON path required")
assert(not io.open(output,"rb"),"Output already exists")
local seeds=tonumber(arg[2]) or 20
local shard=tonumber(arg[3]) or 0
assert(seeds>=1 and seeds<=40 and seeds==math.floor(seeds))
local rows,paired,samples=json.array(),json.array(),json.array()
local pairs_list={}
for i,a in ipairs(species.order) do for j=i+1,#species.order do
    local b=species.order[j]
    if (species.defs[a].draft or species.defs[b].draft) and species.defs[a].cost+species.defs[b].cost<=7 then
        pairs_list[#pairs_list+1]=species.defs[a].draft and {a,b} or {b,a}
    end
end end
local function command(p,id,args) local ok,why=model.command(p,id,args);assert(ok,tostring(why)) end
local function initial(seed,crew,c)
    local p=model.new(seed)
    -- Veteran-depot cohort: all six species already met, so recruitment cannot
    -- silently turn a two-member comparison into different three-member crews.
    for _,id in ipairs(species.order) do p.profile.roster[id]=progression.companion(id);p.profile.discoveries[id]=true end
    p.run.crew={}
    for _,id in ipairs(crew) do command(p,"crew",{species=id}) end
    if c.item~="none" then
        command(p,"buy_work_item",{item=c.item})
        local wearer=1
        if c.item=="dry_wrap" then for i,id in ipairs(crew) do if id=="bellmoth" then wearer=i end end end
        command(p,"equip_work_item",{item=c.item,member=wearer})
    end
    command(p,"depart");command(p,"policy",{key="pace",value=c.pace})
    return p
end
local function peaceful(p)
    local choices=model.events.by_id[p.run.pending.id].choices
    for _,c in ipairs(choices) do if c.species and not c.battle and model.events.available(p.run,c,p.profile) then return c end end
    return reference.choice(p,"peaceful")
end
local function policy(c,override)
    -- No RNG inspection or simulated look-ahead. Same visible-state rules in
    -- every variant; an override applies only to the initial matched threat.
    local first=true
    return function(p)
        local s=p.run
        if s.road_story then return "ack_story",{},"read consequence" end
        if s.mode=="event" then
            local mode=c.style
            if first and override then mode=override;first=false end
            local battle=reference.choice(p,"fight")
            if model.events.by_id[s.pending.id].kind=="encounter" then
                if mode=="withdraw" then return "withdraw",{},"matched withdrawal before any exchange" end
                local pick=mode=="fight" and battle or peaceful(p)
                if not pick then return "withdraw",{},"no affordable offer; withdraw without fighting" end
                return "choice",{id=pick.id},"fixed encounter policy: "..mode
            end
            if s.pending.id=="roots" and s.food>=model.resources.daily_food(s)*8 then return "choice",{id="leave"},"food covers at least eight days" end
            local pick=peaceful(p)
            return "choice",{id=pick.id},"ready species assistance before fallback"
        end
        if s.mode=="stopped" or s.mode=="traveling" then
            if not model.resources.hauler(s) or s.crew[s.hauler].stamina<18 then
                for i,member in ipairs(s.crew) do
                    if i~=s.hauler and species.defs[member.species].draft and model.resources.ready(member,18)
                        and member.stamina>s.crew[s.hauler].stamina+8 then return "hauler",{member=i},"rotate to a ready draft companion" end
                end
            end
        end
        if s.mode=="landmark" and s.target==4 and not s.flags.river_crossed and s.flags.river_inspected and c.river=="rope" then
            return "river",{method="rope"},"fixed risky-crossing cohort"
        end
        if s.mode=="combat_select" then
            local team={};local order=c.order==1 and {1,2} or {2,1}
            for _,i in ipairs(order) do if model.resources.ready(s.crew[i],model.combat.costs(s)) then team[#team+1]=i end end
            if #team>0 then return "battle_start",{team=team},"fixed position order" end
            return "withdraw",{},"no ready combatant"
        end
        local id,args,why=reference.next(p,"careful")
        if id=="leave" then args.branch=s.target==2 and c.first or c.last;why="fixed route" end
        return id,args,why
    end
end
local executions=0
local function run(p,c,override,capture)
    local a,ended,encounters=runner.run(p,"balance-v1",{policy=policy(c,override),capture=capture})
    local b,repeated=runner.run(p,"balance-v1",{policy=policy(c,override)})
    a.policy_version="balance-v1";b.policy_version="balance-v1"
    if a.status~="completed" then
        local f=assert(io.open(output..".failure.json","wb"));f:write(json.encode(a));f:close()
        error(json.encode(a.failure))
    end
    assert(json.encode(a)==json.encode(b) and json.encode(ended)==json.encode(repeated),"Repeated run differed")
    executions=executions+2
    return a,ended,encounters
end
local function summary(report,p)
    local s=p.run;local energy,condition=0,0
    for _,m in ipairs(s.crew) do energy=energy+m.stamina;condition=condition+m.condition end
    return {outcome=s.outcome,day=s.day,cargo=s.cargo,wagon=s.wagon,food=s.food,coins=s.coins,
        energy=energy,condition=condition,recovery=report.totals.recovery_days,exchanges=report.totals.combat_exchanges,
        min_food=report.minimum.food.value,actions=report.actions}
end
local configs={}
local function config(style,pace,item,first,last,order,river)
    return {style=style,pace=pace or "steady",item=item or "none",first=first or "meadow",last=last or "ridge",order=order or 1,river=river or "ferry"}
end
for _,style in ipairs({"peaceful","fight"}) do
    for _,pace in ipairs({"steady","hurried"}) do for _,item in ipairs({"none","padded_trace","release_rope","dry_wrap"}) do
        configs[#configs+1]=config(style,pace,item)
    end end
    configs[#configs+1]=config(style,nil,nil,nil,nil,2)
    for _,routes in ipairs({{"woodland","ridge"},{"meadow","gorge"},{"woodland","gorge"}}) do configs[#configs+1]=config(style,nil,nil,routes[1],routes[2]) end
    for _,item in ipairs({"none","release_rope"}) do configs[#configs+1]=config(style,nil,item,nil,nil,nil,"rope") end
end
for crew_index,crew in ipairs(pairs_list) do if shard==0 or (crew_index-1)%3+1==shard then
    for _,c in ipairs(configs) do for seed=1,seeds do
        local p=initial(seed,crew,c)
        local capture=seed<=math.min(8,seeds) and c.pace=="steady" and c.item=="none" and c.first=="meadow" and c.last=="ridge" and c.order==1 and c.river=="ferry"
        local r,ended,encounters=run(p,c,nil,capture)
        rows[#rows+1]={crew=table.concat(crew,"+"),seed=seed,config=util.copy(c),result=summary(r,ended)}
        if capture then for n,encounter in ipairs(encounters) do
            local point={crew=table.concat(crew,"+"),seed=seed,parent_style=c.style,event=encounter.event,index=n,results={}}
            local methods=peaceful(encounter.snapshot) and {"fight","peaceful","withdraw"} or {"fight","withdraw"}
            for _,method in ipairs(methods) do
                local report,final=run(encounter.snapshot,c,method)
                local receipt
                for _,step in ipairs(report.steps) do
                    if step.after.mode=="stopped" or step.after.mode=="combat_result" or step.after.mode=="result" then receipt=step.after;break end
                end
                assert(receipt)
                local immediate={days=receipt.day-encounter.snapshot.run.day,food=receipt.food-encounter.snapshot.run.food,cargo=receipt.cargo-encounter.snapshot.run.cargo,energy=0,condition=0}
                for i,m in ipairs(receipt.crew) do
                    immediate.energy=immediate.energy+m.energy-encounter.snapshot.run.crew[i].stamina
                    immediate.condition=immediate.condition+m.condition-encounter.snapshot.run.crew[i].condition
                end
                point.results[method]={final=summary(report,final),immediate=immediate}
                if #samples<3 then samples[#samples+1]={crew=point.crew,method=method,report=report} end
            end
            paired[#paired+1]=point
        end end
    end end
    io.stderr:write("Compared "..table.concat(crew," + ").."\n")
end end
local f=assert(io.open(output,"wb"));f:write(json.encode({schema=1,policy="balance-v1",cohort="all-six-species-unlocked",seeds=seeds,crews=#pairs_list,configs=#configs,runs=#rows,matched_starts=#paired,executions=executions,repeated_exactly=true,rows=rows,paired=paired,samples=samples}));f:close()
print("Wrote "..#rows.." journeys and "..#paired.." matched encounter starts; all repeated exactly.")
