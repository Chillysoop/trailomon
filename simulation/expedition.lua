local util = require "simulation.util"
local rng = require "simulation.rng"
local resources = require "simulation.resources"
local progression = require "simulation.progression"
local events = require "simulation.events"
local combat = require "simulation.combat"
local species = require "content.species"
local route = require "content.route"
local wagons = require "content.wagons"
local M = {SCHEMA=1, CONTENT=1, route=route, species=species, resources=resources, events=events, combat=combat}

local function log(s,text)
    s.log[#s.log+1]={day=s.day,text=text}
    if #s.log>70 then table.remove(s.log,1) end
end
M.log=log

local function prepare(snapshot,seed)
    local p=snapshot.profile
    seed=rng.seed(seed)-1
    local s={id=p.next_id,seed=seed,mode="preparation",day=1,target=2,progress=0,distance=route[2].distance,
        terrain="meadow",weather="clear",rainfall=0,food=90,coins=50,repairs=3,medicine=2,
        wagon=100,wagon_type="standard",cargo=100,traveler=100,pace="steady",rations="normal",
        crew={util.copy(p.roster.brindlehorn),util.copy(p.roster.loamling)},hauler=1,
        rng={weather=rng.seed(seed+11),events=rng.seed(seed+173),combat=rng.seed(seed+1019)},
        seen={},flags={},discoveries={},branches={},forage={},cooldown=1,log={},warnings={},
        outcome="",ending="",river_roll=rng.seed(seed+923)%100/100}
    p.next_id=p.next_id+1
    snapshot.run=s
    log(s,"Orchard cuttings for Lantern Reach. Preferred arrival: day 26. Road closes on day 32.")
    return s
end

function M.new(seed)
    local snapshot={schema=M.SCHEMA,content=M.CONTENT,profile=progression.profile(),settings={sound=true,motion=true}}
    prepare(snapshot,seed or 1848)
    return snapshot
end

function M.finish(snapshot,outcome,description)
    local s=snapshot.run
    if s.mode=="result" then return false end
    s.mode,s.outcome,s.ending="result",outcome,description
    s.pending,s.battle,s.encounter=nil,nil,nil
    log(s,description)
    progression.commit(snapshot.profile,s)
    return true
end

local function terminal(snapshot)
    local s=snapshot.run
    if s.mode=="result" then return true end
    if s.traveler<=0 then M.finish(snapshot,"rescued","A passing caravan brings you and your companions home. The traveler needed care."); return true end
    if s.day>=32 then M.finish(snapshot,"rescued","The upland road has closed. A road crew helps the whole wagon home."); return true end
    return false
end

local function reached(snapshot)
    local s=snapshot.run
    if s.progress<s.distance then return false end
    s.progress=s.distance
    if s.target==#route then
        if s.cargo>=20 and s.day<=26 then
            M.finish(snapshot,"delivered","The orchard cuttings reach Lantern Reach in time. There will be new trees here next spring.")
        else
            M.finish(snapshot,"late","You reach Lantern Reach, but the delivery is " .. (s.cargo<20 and "too damaged to plant." or "past its preferred date."))
        end
    else
        s.mode="landmark"
        log(s,"Reached " .. route[s.target].name .. ".")
        if s.target==3 and s.flags.helped_traveler and not s.flags.thanked then
            s.flags.thanked=true; s.coins=s.coins+8
            log(s,"The traveler you helped left 8 coins for you at Mossbell.")
        end
    end
    return true
end

local function add_food(s,amount)
    local space=math.max(0,resources.capacity(s)-resources.weight(s))
    local kept=math.min(space,amount)
    s.food=s.food+kept
    if kept<amount then log(s,"The wagon holds " .. kept .. " of the " .. amount .. " found provisions. The rest stays behind.") end
    return kept
end

local function effects(s,values)
    for key, value in pairs(values or {}) do
        if key=="stamina" then
            for _, c in ipairs(s.crew) do c.stamina=util.clamp(c.stamina+value,0,100) end
        elseif key=="food" and value>0 then add_food(s,value)
        elseif key=="wagon" or key=="cargo" or key=="traveler" then s[key]=util.clamp(s[key]+value,0,100)
        else s[key]=math.max(0,s[key]+value) end
    end
end

local function weather(s)
    local roll=rng.next(s.rng,"weather")
    if roll<(s.weather=="rain" and 0.48 or 0.27) then s.weather="rain"
    elseif s.day>12 and roll>0.76 then s.weather="cold"
    else s.weather="clear" end
    s.rainfall=util.clamp(s.rainfall+(s.weather=="rain" and 2 or -1),0,6)
end

function M.forecast(s)
    local count=resources.daily_food(s)
    local pace=resources.paces[s.pace]
    return {food=count,days=math.floor(s.food/count),progress=pace.speed,
        effort=pace.effort, recovery=resources.rations[s.rations].recovery}
end

local function check_warnings(s)
    local candidates={
        {id="food",bad=s.food<resources.daily_food(s)*3,text="Provisions cover fewer than three days. Forage, reduce rations, or visit Mossbell."},
        {id="wagon",bad=s.wagon<25,text="The wagon needs attention. Repair it before the next rough stretch."},
        {id="traveler",bad=s.traveler<25,text="You need care. Rest with food, use medicine, or request assistance."},
        {id="stamina",bad=not resources.hauler(s),text="Your hauler needs rest or a replacement. Open Crew to assign a ready draft companion."},
        {id="deadline",bad=s.day>=28,text="Cold weather closes the road on day 32. There is time for only a few more stops."},
    }
    for _, warning in ipairs(candidates) do
        if warning.bad and not s.warnings[warning.id] then
            s.warnings[warning.id]=true
            log(s,warning.text)
            if s.mode=="traveling" then s.mode="stopped" end
            s.notice=warning.text
        elseif not warning.bad then s.warnings[warning.id]=nil end
    end
end

-- The only passage of expedition time: weather -> food -> condition/work ->
-- movement/wear -> terminal checks -> landmark -> warnings -> optional incident.
local function day(snapshot,moving,resting)
    local s=snapshot.run
    local hauler=moving and resources.hauler(s) or nil
    if moving and (not hauler or s.wagon<=0) then return false,"Rest, repair, assign a hauler, or request assistance." end
    s.day=s.day+1
    weather(s)
    local need=resources.daily_food(s)
    local fed=s.food>=need
    s.food=math.max(0,s.food-need)
    local recovery=resources.rations[s.rations].recovery
    local warmer=resources.find(s,"cindercoil",8)
    local warm=warmer and warmer.duty=="work" and s.weather=="cold"
    if warm then warmer.stamina=math.max(0,warmer.stamina-5) end
    local exposure=(s.weather=="cold" and not warm) and 2 or 0
    s.traveler=util.clamp(s.traveler+(fed and (resting and 12 or 0.5) or -12)-exposure,0,100)
    for _, c in ipairs(s.crew) do
        local working=moving and c.duty=="work"
        local effort=c==hauler and resources.paces[s.pace].effort or (working and 2 or 0)
        if c==hauler and c.species=="reedskipper" and s.weather=="clear" and s.terrain~="marsh" then effort=effort+2 end
        local gain=fed and (resting and 25 or recovery+(working and 0 or 4)) or 0
        c.stamina=util.clamp(c.stamina-effort+gain-exposure,0,100)
        c.condition=util.clamp(c.condition+(fed and (resting and 8 or 0) or -6),0,100)
    end
    if not fed then log(s,"There was not enough food today. The crew is weaker.") end
    if moving then
        local factor=s.weather=="rain" and 0.86 or (s.weather=="cold" and 0.92 or 1)
        if s.terrain=="woodland" or s.terrain=="gorge" then factor=factor*0.9 end
        if s.terrain=="ridge" then factor=factor*1.05 end
        if hauler.species=="slatewhorl" then factor=factor*0.88 end
        if resources.weight(s)>resources.capacity(s)*0.9 then factor=factor*0.94 end
        s.progress=s.progress+resources.paces[s.pace].speed*factor
        local wear=resources.paces[s.pace].wear+(s.weather=="rain" and 0.4 or 0)+(s.terrain=="ridge" and 0.6 or 0)
        s.wagon=util.clamp(s.wagon-wear,0,100)
        if s.pace=="hurried" and s.terrain=="ridge" then s.cargo=math.max(0,s.cargo-2) end
        if s.weather=="rain" then
            local drying=resources.find(s,"cindercoil",8)
            local damage=2*wagons[s.wagon_type].wet_factor
            if drying and drying.duty=="work" then damage=damage*0.3; drying.stamina=math.max(0,drying.stamina-3) end
            s.cargo=math.max(0,s.cargo-damage)
        end
        s.cooldown=math.max(0,s.cooldown-1)
    end
    if terminal(snapshot) then return true end
    if moving and reached(snapshot) then return true end
    check_warnings(s)
    if moving and s.mode=="traveling" then
        local event=events.select(s,snapshot.profile)
        if event then
            s.seen[event.id]=true
            if event.kind=="ambient" then effects(s,event.effects); log(s,event.text)
            else
                s.mode="event"
                s.pending={id=event.id,roll=rng.next(s.rng,"events")}
                log(s,event.title .. ".")
            end
        end
    end
    return true
end
M.advance_day=day

function M.forage_preview(s)
    local count=s.forage[tostring(s.target)] or 0
    local digger=resources.find(s,"loamling",18)
    local base=(s.terrain=="meadow" or s.terrain=="woodland") and 10 or 6
    local gross=math.max(0,base+(digger and 8 or 0)-count*5)
    local meals=math.min(s.food,resources.daily_food(s))
    local space=math.max(0,resources.capacity(s)-resources.weight(s)+meals)
    local closing=s.day>=31
    local packed=closing and 0 or math.min(gross,space)
    return {gross=gross,packed=packed,net=packed-meals,effort=digger and 18 or 0,member=digger,
        count=count,meals=meals,need=resources.daily_food(s),space=space,closing=closing}
end

local function leave(snapshot,branch)
    local s=snapshot.run
    if s.target==2 then
        if branch~="meadow" and branch~="woodland" then return false,"Choose a path" end
        s.branches.first=branch
    elseif s.target==5 then
        if branch~="ridge" and branch~="gorge" then return false,"Choose a path" end
        s.branches.last=branch
    elseif s.target==4 and not s.flags.river_crossed then return false,"Cross the river first" end
    s.target=s.target+1
    s.progress=0
    s.distance=route[s.target].distance
    s.terrain=route[s.target].terrain
    if s.target==3 then s.terrain=s.branches.first; if s.terrain=="woodland" then s.distance=s.distance+3 end end
    if s.target==6 then s.terrain=s.branches.last; if s.terrain=="gorge" then s.distance=s.distance+5 end end
    s.mode="traveling"
    log(s,"Set out for " .. route[s.target].name .. ".")
    return true
end

function M.river_risk(s,method)
    local risk=0.18+s.rainfall*0.065+(resources.weight(s)/resources.capacity(s))*0.12
    if method=="swim" then risk=risk-0.24 end
    if method=="anchor" then risk=risk-0.18 end
    return util.clamp(risk,0.05,0.85)
end

local function cross(snapshot,method)
    local s=snapshot.run
    if s.flags.river_crossed then return false,"Already across" end
    if method=="inspect" then s.flags.river_inspected=true; log(s,"Measured Willowford's current and noted recent rain."); return true end
    if method=="wait" then local ok,why=day(snapshot,false,true); log(s,"Waited at Willowford; the water may rise or fall."); return ok,why end
    local helper
    if method=="ferry" then
        if s.coins<12 then return false,"Ferry fare: 12 coins" end
        s.coins=s.coins-12
    elseif method=="swim" then helper=resources.find(s,"reedskipper",22); if not helper then return false,"Need a Reedskipper with 22 stamina" end
    elseif method=="anchor" then helper=resources.find(s,"slatewhorl",22) or resources.find(s,"brindlehorn",22); if not helper then return false,"Need an anchor companion with 22 stamina" end
    elseif method~="rope" then return false,"Unknown crossing" end
    local risk=M.river_risk(s,method)
    -- Outcome is fixed for this run; inspecting, saving, or changing menus never rerolls it.
    if helper then helper.stamina=helper.stamina-22; progression.memory(helper,"Helped the wagon cross Willowford.") end
    local bad=method~="ferry" and s.river_roll<risk
    day(snapshot,false,false)
    if s.mode=="result" then return true end
    if bad then
        local wet=wagons[s.wagon_type].wet_factor
        effects(s,{food=-math.ceil(8*wet),cargo=-18*wet,wagon=-6})
        if helper then helper.condition=math.max(0,helper.condition-6) end
        log(s,"Across, but a strong current soaked supplies and jolted the wagon.")
    else log(s,method=="ferry" and "The ferryman brings the wagon safely across." or "The crossing goes cleanly. Everyone reaches the far bank.") end
    s.flags.river_crossed=true
    s.mode="landmark"
    return true
end

local function resolve(snapshot,id)
    local s=snapshot.run
    local event=events.by_id[s.pending.id]
    local choice
    for _, option in ipairs(event.choices) do if option.id==id then choice=option end end
    if not choice then return false,"Unknown choice" end
    local ok,why=events.available(s,choice,snapshot.profile)
    if not ok then return false,why end
    local roll=s.pending.roll
    resources.pay(s,choice.cost)
    local helper=choice.species and resources.find(s,choice.species,choice.effort)
    if helper then helper.stamina=helper.stamina-choice.effort end
    s.mode="stopped"
    s.pending=nil
    s.cooldown=3 -- two full quiet travel days, then eligible on the third.
    log(s,choice.label .. ".")
    for _=1,choice.days or 0 do day(snapshot,false,false); if s.mode=="result" then return true end end
    effects(s,choice.effects)
    if choice.gamble then
        if roll<0.55 then s.progress=s.progress+5; log(s,"The shortcut rejoins the road sooner.")
        else effects(s,{wagon=-10}); log(s,"The shortcut is rougher than it looked. Wagon -10.") end
    end
    if choice.flag then s.flags[choice.flag]=true end
    if choice.discovery then s.discoveries[choice.discovery]=true end
    if choice.recruit then
        s.crew[#s.crew+1]=progression.companion(choice.recruit)
        s.discoveries[choice.recruit]=true
        log(s,species.defs[choice.recruit].name .. " joins the wagon. Food now costs " .. resources.daily_food(s) .. " per day.")
    end
    if choice.memory then
        if helper then progression.memory(helper,choice.memory)
        else for _, c in ipairs(s.crew) do progression.memory(c,choice.memory) end end
    end
    if choice.battle then s.mode="combat_select"; s.encounter=choice.battle
    else reached(snapshot); check_warnings(s) end
    return true
end

local function battle_end(snapshot,outcome)
    local s=snapshot.run
    local battle=s.battle
    local kind=s.battle and s.battle.kind or s.encounter
    if outcome~="won" then
        if kind=="scavengers" then effects(s,{food=-8,cargo=-8}); log(s,"You leave a little cargo and food, and lead the crew away.")
        else log(s,"You take a day-long detour around the territorial creature."); day(snapshot,false,false) end
    else
        log(s,"The wild creatures give you space. Your journey can continue.")
        for _,i in ipairs(battle and battle.team or {}) do progression.memory(s.crew[i],"Helped protect the wagon on the trail.") end
    end
    s.encounter=nil
    if s.mode~="result" then
        if combat.automatic(battle) then
            battle.outcome=outcome;s.mode="combat_result"
            battle.result={food=s.food-battle.initial.food,cargo=s.cargo-battle.initial.cargo,days=s.day-battle.initial.day,crew={}}
            for _,i in ipairs(battle.team) do
                battle.result.crew[i]={stamina=s.crew[i].stamina-battle.initial.crew[i].stamina,condition=s.crew[i].condition-battle.initial.crew[i].condition}
            end
        else s.battle=nil;s.mode="stopped" end
        check_warnings(s)
    end
end

local function stopped(s)
    return s.mode=="stopped" or s.mode=="landmark" or s.mode=="traveling"
end

function M.command(snapshot,command,arg)
    local s=snapshot.run
    arg=arg or {}
    if command=="settings" then
        if arg.key~="sound" and arg.key~="motion" then return false,"Unknown setting" end
        snapshot.settings[arg.key]=not snapshot.settings[arg.key]; return true
    end
    if command=="new" then
        if s.mode~="result" then return false,"Finish this journey first" end
        prepare(snapshot,arg.seed or s.seed+1); return true
    end
    if s.mode=="result" then return false,"This journey has ended" end
    if command=="seed" and s.mode=="preparation" then
        local n=rng.seed(arg.value)-1; s.seed=n
        s.rng={weather=rng.seed(n+11),events=rng.seed(n+173),combat=rng.seed(n+1019)}
        s.river_roll=rng.seed(n+923)%100/100; return true
    elseif command=="crew" and s.mode=="preparation" then
        local id=arg.species
        if not snapshot.profile.roster[id] then return false,"Meet this companion on the trail first" end
        for i,c in ipairs(s.crew) do if c.species==id then table.remove(s.crew,i); s.hauler=1; return true end end
        if #s.crew>=2 then return false,"Choose at most two companions at departure" end
        local budget=species.defs[id].cost
        for _,c in ipairs(s.crew) do budget=budget+species.defs[c.species].cost end
        if budget>7 then return false,"Starting crew budget is seven" end
        s.crew[#s.crew+1]=util.copy(snapshot.profile.roster[id]); return true
    elseif command=="wagon" and s.mode=="preparation" then
        if not wagons[arg.id] or (arg.id=="covered" and not snapshot.profile.covered) then return false,"Study and cross the river to unlock the covered wagon" end
        if resources.weight(s)>wagons[arg.id].capacity then return false,"Reduce supplies to fit this wagon" end
        s.wagon_type=arg.id; return true
    elseif command=="depart" and s.mode=="preparation" then
        if #s.crew<1 or #s.crew>2 then return false,"Choose one or two companions" end
        local draft
        for i,c in ipairs(s.crew) do if species.defs[c.species].draft then draft=i; break end end
        if not draft then return false,"Choose a companion that can pull the wagon" end
        s.hauler=draft; s.mode="stopped"
        log(s,"Left Fernwake with " .. #s.crew .. " companions. Space follows the road; every decision waits for you.")
        return true
    elseif command=="buy" or command=="sell" then
        if s.mode~="preparation" and not (s.mode=="landmark" and s.target==3) then return false,"Supplies are sold at the depot and Mossbell" end
        local goods={food={amount=10,price=6,weight=10},repairs={amount=1,price=8,weight=4},medicine={amount=1,price=7,weight=2}}
        local item=goods[arg.item]
        if not item then return false,"Unknown supply" end
        if command=="sell" then
            if s.mode~="preparation" then return false,"Returns are available before departure" end
            if s[arg.item]<item.amount then return false,"Not enough to return" end
            s[arg.item]=s[arg.item]-item.amount; s.coins=s.coins+item.price
        else
            if s.coins<item.price then return false,"Not enough coins" end
            if resources.weight(s)+item.weight>resources.capacity(s) then return false,"The wagon is full" end
            s.coins=s.coins-item.price; s[arg.item]=s[arg.item]+item.amount
        end
        return true
    elseif command=="policy" and (stopped(s) or s.mode=="preparation") then
        if arg.key=="pace" and resources.paces[arg.value] then s.pace=arg.value
        elseif arg.key=="rations" and resources.rations[arg.value] then s.rations=arg.value
        else return false,"Unknown policy" end
        return true
    elseif command=="duty" and (stopped(s) or s.mode=="preparation") then
        local c=s.crew[arg.member]; if not c then return false,"Unknown companion" end
        c.duty=c.duty=="work" and "rest" or "work"; return true
    elseif command=="hauler" and (stopped(s) or s.mode=="preparation") then
        local c=s.crew[arg.member]
        if not c or not species.defs[c.species].draft then return false,"This companion cannot haul" end
        s.hauler=arg.member; c.duty="work"; return true
    elseif command=="rename" and (stopped(s) or s.mode=="preparation") then
        local c=s.crew[arg.member]
        local name=tostring(arg.name or ""):gsub("[%c]", ""):sub(1,18):match("^%s*(.-)%s*$")
        if not c or name=="" then return false,"Use a short name" end
        c.name=name; return true
    elseif command=="resume" and s.mode=="stopped" then
        if s.wagon<=0 or not resources.hauler(s) then return false,"Rest, repair, or assign a ready hauler first" end
        s.notice=nil; s.mode="traveling"; return true
    elseif command=="pause" and s.mode=="traveling" then s.mode="stopped"; return true
    elseif command=="step" and s.mode=="traveling" then return day(snapshot,true,false)
    elseif command=="rest" and stopped(s) then
        local ok,why=day(snapshot,false,true)
        log(s,"Spent a quiet day recovering. Well-fed companions regain up to 25 stamina and 8 condition.")
        if s.mode=="traveling" then s.mode="stopped" end
        return ok,why
    elseif command=="repair" and stopped(s) then
        if s.repairs<1 then return false,"Need one repair material" end
        if s.wagon>=100 then return false,"The wagon is already sound" end
        s.repairs=s.repairs-1; day(snapshot,false,false)
        if s.mode~="result" then s.wagon=math.min(100,s.wagon+30); log(s,"Refitted the wagon. Condition +30."); if s.mode=="traveling" then s.mode="stopped" end end
        return true
    elseif command=="treat" and stopped(s) then
        if s.medicine<1 then return false,"Need one medicine" end
        local member=arg.member and s.crew[arg.member]
        if arg.member and not member then return false,"Unknown companion" end
        if (member and member.condition or s.traveler)>=100 then return false,"Already in good health" end
        s.medicine=s.medicine-1; day(snapshot,false,true)
        if s.mode~="result" then
            if member then member.condition=math.min(100,member.condition+35)
            else s.traveler=math.min(100,s.traveler+35) end
            log(s,"Medicine and a day of care helped " .. (member and member.name or "the traveler") .. ".")
            if s.mode=="traveling" then s.mode="stopped" end
        end
        return true
    elseif command=="forage" and stopped(s) then
        local preview=M.forage_preview(s)
        local before=s.food
        if preview.gross<=0 then return false,"This stretch has been picked clean" end
        s.forage[tostring(s.target)]=(s.forage[tostring(s.target)] or 0)+1
        if preview.member then preview.member.stamina=preview.member.stamina-preview.effort end
        day(snapshot,false,false)
        if s.mode~="result" then
            local packed=add_food(s,preview.gross)
            local net=s.food-before
            log(s,"Gathered "..preview.gross.."; packed "..packed.."; meals "..preview.meals.."; provisions "..(net>=0 and "+" or "")..net..".")
            if s.mode=="traveling" then s.mode="stopped" end
        end
        return true
    elseif command=="leave" and s.mode=="landmark" then return leave(snapshot,arg.branch)
    elseif command=="river" and s.mode=="landmark" and s.target==4 then return cross(snapshot,arg.method)
    elseif command=="choice" and s.mode=="event" then return resolve(snapshot,arg.id)
    elseif command=="battle_start" and s.mode=="combat_select" then return combat.start(s,s.encounter,arg.team)
    elseif command=="battle_step" and s.mode=="combat" then
        local ok,outcome=combat.step(s)
        if ok then
            local entry=s.battle.history[#s.battle.history]
            log(s,"Exchange "..entry.round..": "..table.concat(entry.notes," ").." "..entry.summary)
            if outcome then battle_end(snapshot,outcome) end
        end
        return ok,not ok and outcome or nil
    elseif command=="battle_continue" and s.mode=="combat_result" then
        s.battle=nil;s.mode="stopped";return true
    elseif command=="round" and s.mode=="combat" then
        local ok,outcome=combat.round(s,arg.actions)
        if ok then
            log(s,s.battle.last)
            if outcome then battle_end(snapshot,outcome) end
        end
        return ok,not ok and outcome or nil
    elseif command=="withdraw" and (s.mode=="combat" or s.mode=="combat_select") then battle_end(snapshot,"withdraw"); return true
    elseif command=="return" and s.mode~="preparation" then return M.finish(snapshot,"returned","You call for help and bring the crew home. The delivery waits for another journey.")
    end
    return false,"That action is unavailable right now"
end

-- Developer-only entry point. The UI explicitly labels these as test controls.
function M.debug(snapshot,action,value)
    local s=snapshot.run
    if action=="event" and stopped(s) and events.by_id[value] and events.by_id[value].choices then
        s.pending={id=value,roll=rng.next(s.rng,"events")}; s.seen[value]=true; s.mode="event"; return true
    elseif action=="resupply" and stopped(s) then
        s.food=math.min(100,resources.capacity(s)-25-s.repairs*4-s.medicine*2)
        s.coins=80; s.wagon=100; s.traveler=100
        for _,c in ipairs(s.crew) do c.stamina=100;c.condition=100 end
        return true
    end
    return false,"Debug action unavailable"
end

return M
