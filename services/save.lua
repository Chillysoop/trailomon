local util=require "simulation.util"
local model=require "simulation.expedition"
local species=require "content.species"
local aims=require "simulation.journal_aims"
local M={}
local modes={preparation=true,traveling=true,stopped=true,event=true,landmark=true,combat_select=true,combat=true,combat_result=true,result=true}
local outcomes={delivered=true,late=true,returned=true,rescued=true}
local function number(n,lo,hi) return util.finite(n) and n>=lo and n<=hi end
local function integer(n,lo,hi) return number(n,lo,hi) and n==math.floor(n) end
local function companion(c)
    if type(c)~="table" or not species.defs[c.species] or type(c.name)~="string" or #c.name>72 then return false end
    if not number(c.condition,0,100) or not number(c.stamina,0,100) or not integer(c.trust,1,3) then return false end
    if c.work_item~=nil and not model.equipment.defs[c.work_item] then return false end
    if c.duty~="work" and c.duty~="rest" then return false end
    if type(c.temperament)~="string" or type(c.memories)~="table" or #c.memories>6 then return false end
    for _,text in ipairs(c.memories) do if type(text)~="string" or #text>250 then return false end end
    return true
end

local function validate(snapshot)
    if type(snapshot)~="table" or snapshot.schema~=model.SCHEMA or snapshot.content~=model.CONTENT then return false,"Unsupported save version" end
    local s,p=snapshot.run,snapshot.profile
    if type(s)~="table" or type(p)~="table" or not modes[s.mode] then return false,"Missing journey state" end
    local guide=require "simulation.field_guide"
    if s.wildlife_rules~=nil and s.wildlife_rules~="wildlife-v1" then return false,"Unknown wildlife rules" end
    if not guide.valid(s.observations) or not guide.valid(s.new_observations) or not guide.valid(p.observations) or not guide.valid(p.traveled) then return false,"Invalid field observations" end
    if s.combat_effort~=nil and s.combat_effort~=model.combat.EFFORT then return false,"Unknown journey combat effort" end
    if type(snapshot.settings)~="table" or type(snapshot.settings.sound)~="boolean" or type(snapshot.settings.motion)~="boolean" then return false,"Invalid settings" end
    if snapshot.settings.travel_speed~=nil and not integer(snapshot.settings.travel_speed,1,2) then return false,"Invalid viewing speed" end
    if type(p.roster)~="table" or type(p.history)~="table" or #p.history>10 or type(p.discoveries)~="table" or type(p.covered)~="boolean" then return false,"Invalid depot" end
    if not integer(p.next_id,1,1e9) or not integer(p.last_committed,0,p.next_id-1) or not integer(s.id,1,p.next_id-1) then return false,"Invalid journey identity" end
    if not aims.valid_profile(p.aims,p.last_committed) or not aims.valid_journey(s.aim_journey) then return false,"Invalid journal aims" end
    local roster_count=0
    for id,c in pairs(p.roster) do
        if not companion(c) or c.species~=id or c.work_item~=nil then return false,"Invalid saved companion" end
        roster_count=roster_count+1
    end
    if roster_count>6 then return false,"Roster too large" end
    for _,id in ipairs({"brindlehorn","reedskipper","loamling","bellmoth"}) do if not p.roster[id] then return false,"Missing depot companion" end end
    for _,record in ipairs(p.history) do
        if type(record)~="table" or not integer(record.id,1,p.last_committed) or not outcomes[record.outcome] or not integer(record.seed,0,2147483646) or not number(record.day,1,32) or not number(record.cargo,0,100) or type(record.summary)~="string" or type(record.route)~="table" then return false,"Invalid history" end
    end
    if not integer(s.seed,0,2147483646) or not integer(s.day,1,32) or not integer(s.target,2,6) or not integer(s.hauler,1,3) then return false,"Invalid journey position" end
    if not number(s.progress,0,100) or not number(s.distance,1,100) or s.progress>s.distance then return false,"Invalid route progress" end
    if s.wagon_type~="standard" and s.wagon_type~="covered" then return false,"Invalid wagon" end
    if not model.resources.paces[s.pace] or not model.resources.rations[s.rations] then return false,"Invalid travel policies" end
    if s.weather~="clear" and s.weather~="rain" and s.weather~="cold" then return false,"Invalid weather" end
    local terrains={meadow=true,woodland=true,marsh=true,upland=true,ridge=true,gorge=true}
    if not terrains[s.terrain] or not number(s.rainfall,0,6) or not integer(s.cooldown,0,3) then return false,"Invalid conditions" end
    for _,key in ipairs({"food","coins","repairs","medicine"}) do if not integer(s[key],0,10000) then return false,"Invalid supply: " .. key end end
    for _,key in ipairs({"wagon","cargo","traveler"}) do if not number(s[key],0,100) then return false,"Invalid condition" end end
    if s.work_items~=nil then
        if type(s.work_items)~="table" then return false,"Invalid work items" end
        for id,owned in pairs(s.work_items) do
            if not model.equipment.defs[id] or owned~=true then return false,"Invalid packed work item" end
        end
    end
    if model.resources.weight(s)>model.resources.capacity(s) then return false,"Wagon is over capacity" end
    if type(s.crew)~="table" or #s.crew>3 or (s.mode~="preparation" and #s.crew<1) then return false,"Invalid crew" end
    local crew,assigned={},{}
    for _,c in ipairs(s.crew) do
        if not companion(c) or crew[c.species] then return false,"Invalid crew member" end
        crew[c.species]=true
        if c.work_item then
            if not (s.work_items or {})[c.work_item] or assigned[c.work_item] then return false,"Invalid work-item assignment" end
            assigned[c.work_item]=true
        end
    end
    for _,key in ipairs({"seen","flags","discoveries","branches","forage","warnings","rng","log"}) do if type(s[key])~="table" then return false,"Missing " .. key end end
    for _,key in ipairs({"road_cleared","road_repaid","axle_lashed"}) do
        if s.flags[key]~=nil and type(s.flags[key])~="boolean" then return false,"Invalid road consequence" end
    end
    if s.road_story~=nil and (type(s.road_story)~="string" or #s.road_story>1000) then return false,"Invalid road story" end
    for _,name in ipairs({"weather","events","combat"}) do if not integer(s.rng[name],1,2147483646) then return false,"Invalid random state" end end
    if not number(s.river_roll,0,1) or #s.log>70 then return false,"Invalid journal" end
    for _,entry in ipairs(s.log) do if type(entry)~="table" or not integer(entry.day,1,32) or type(entry.text)~="string" or #entry.text>1000 then return false,"Invalid journal entry" end end
    for key,n in pairs(s.forage) do if type(key)~="string" or not integer(n,0,100) then return false,"Invalid forage record" end end
    if s.mode=="event" or s.pending~=nil then
        if type(s.pending)~="table" or not model.events.by_id[s.pending.id] or not model.events.by_id[s.pending.id].choices or not number(s.pending.roll,0,1) then return false,"Missing pending event" end
        if s.pending.pattern~=nil and (s.pending.id~="territorial" or s.pending.pattern~=model.combat.GUARDIAN_PATTERN) then return false,"Invalid pending guardian pattern" end
        if s.mode~="event" then
            if s.mode~="combat_select" and s.mode~="combat" then return false,"Unexpected pending event" end
            local matching=false
            for _,choice in ipairs(model.events.by_id[s.pending.id].choices) do
                if choice.battle and choice.battle==s.encounter then matching=true end
            end
            if not matching then return false,"Mismatched encounter return" end
            if s.mode=="combat" and (not model.combat.automatic(s.battle) or #s.battle.history~=0 or not integer(s.return_rng,1,2147483646)) then return false,"Invalid encounter return" end
        end
    end
    if s.return_rng~=nil and (s.mode~="combat" or not s.pending) then return false,"Unexpected return random state" end
    if s.mode=="combat_select" and s.encounter~="scavengers" and s.encounter~="territorial" then return false,"Missing encounter" end
    if s.mode=="combat" or s.mode=="combat_result" then
        local b=s.battle
        if type(b)~="table" or (b.kind~="scavengers" and b.kind~="territorial") or type(b.team)~="table" or #b.team<1 or #b.team>2 or type(b.used)~="table" or type(b.intent)~="table" then return false,"Invalid battle" end
        if not integer(b.limit,3,4) or not integer(b.round,1,b.limit) or not number(b.resolve,0,75) or type(b.last)~="string" then return false,"Invalid battle round" end
        if b.item_used~=nil then
            if type(b.item_used)~="table" then return false,"Invalid spent work items" end
            for id,spent in pairs(b.item_used) do
                if id~="padded_trace" or spent~=true or not model.equipment.has(s.crew[b.team[1]],id) then return false,"Invalid spent work item" end
            end
        end
        local used={}
        for _,i in ipairs(b.team) do if not integer(i,1,#s.crew) or used[i] then return false,"Invalid battle team" end; used[i]=true end
        if b.intent.target~="cargo" and not used[b.intent.target] then return false,"Invalid battle target" end
        if not number(b.intent.damage,0,100) then return false,"Invalid battle damage" end
        if b.rules~=nil and not model.combat.automatic(b) then return false,"Unknown battle rules" end
        if b.pattern and not model.combat.automatic(b) then return false,"Legacy battle cannot have a guardian pattern" end
        if b.effort~=nil and b.effort~=model.combat.EFFORT then return false,"Unknown battle effort" end
        if s.pending and b.pattern~=model.combat.selected_pattern(s) then return false,"Mismatched pending pattern" end
        for i,v in pairs(b.used) do if not used[i] or v~=true then return false,"Invalid used ability" end end
        if model.combat.automatic(b) then
            if b.pattern~=nil then
                if b.pattern~=model.combat.GUARDIAN_PATTERN or b.kind~="territorial" then return false,"Invalid guardian pattern" end
                local expected=model.combat.pattern_intent(b)
                if not expected or b.intent.kind~=expected.kind or b.intent.target~=expected.target or b.intent.damage~=expected.damage then return false,"Invalid guardian stage" end
            end
            if b.limit~=(b.kind=="scavengers" and 3 or 4) or (b.intent.kind~="rush" and b.intent.kind~="heavy" and not (b.pattern and b.intent.kind=="warning")) then return false,"Invalid automatic threat" end
            if b.intent.target~="cargo" and b.intent.target~=b.team[1] then return false,"Threat must target the approach or cargo" end
            if type(b.history)~="table" or #b.history>b.limit or type(b.initial)~="table" or type(b.initial.crew)~="table" then return false,"Missing combat accounting" end
            if not number(b.initial.cargo,0,100) or not integer(b.initial.food,0,10000) or not integer(b.initial.day,1,s.day) then return false,"Invalid starting resources" end
            for _,i in ipairs(b.team) do
                local c=b.initial.crew[i]
                if type(c)~="table" or not number(c.stamina,0,100) or not number(c.condition,0,100) then return false,"Invalid starting companion" end
            end
            for index,entry in ipairs(b.history) do
                if type(entry)~="table" or entry.round~=index or type(entry.notes)~="table" or #entry.notes>6 or type(entry.summary)~="string" or #entry.summary>200 then return false,"Invalid exchange history" end
                for _,note in ipairs(entry.notes) do if type(note)~="string" or #note>200 then return false,"Invalid exchange note" end end
                if entry.target~="cargo" and not used[entry.target] then return false,"Invalid historical target" end
                for _,key in ipairs({"damage","pressure","cover"}) do if not number(entry[key],0,100) then return false,"Invalid exchange cost" end end
            end
            if s.mode=="combat_result" then
                if b.outcome~="won" and b.outcome~="withdraw" and b.outcome~="fallback" then return false,"Missing battle outcome" end
                if type(b.result)~="table" or type(b.result.crew)~="table" or not integer(b.result.days,0,1) or not integer(b.result.food,-10000,0) or not number(b.result.cargo,-100,0) then return false,"Invalid battle result" end
                for _,i in ipairs(b.team) do
                    local c=b.result.crew[i]
                    if type(c)~="table" or not number(c.stamina,-100,100) or not number(c.condition,-100,100) then return false,"Invalid companion result" end
                end
            elseif b.outcome~=nil or #b.history~=b.round-1 or b.resolve<=0 then return false,"Invalid pending exchange" end
        elseif s.mode=="combat_result" then return false,"Legacy battle cannot have an automatic result" end
    end
    if s.mode=="result" then
        if not outcomes[s.outcome] or type(s.ending)~="string" or p.last_committed~=s.id then return false,"Uncommitted result" end
    elseif s.id<=p.last_committed then return false,"Journey was already completed" end
    return true
end

function M.validate(snapshot)
    local ok,valid,why=pcall(validate,snapshot)
    if not ok then return false,"Malformed save data" end
    return valid,why
end
function M.paths()
    local namespace=sys.get_config_string("trailomon.save_namespace","trailomon")
    return sys.get_save_file(namespace,"expedition_v1"),sys.get_save_file(namespace,"expedition_v1.backup")
end
local function load_valid(path)
    local ok,data=pcall(sys.load,path)
    if not ok then return nil,"Could not read the save" end
    if type(data)=="table" and next(data)==nil then
        -- sys.load can also return {} for a corrupt file. Only a missing file
        -- is a fresh start; an existing unreadable file must show recovery.
        if sys.exists(path) then return nil,"Could not read the save" end
        return nil,"empty"
    end
    local valid,why=M.validate(data)
    if valid then return data end
    return nil,why
end
function M.load()
    local primary,backup=M.paths()
    local data,why=load_valid(primary)
    if data then return data end
    local fallback,fallback_why=load_valid(backup)
    if fallback then return fallback,"Recovered the last good save. Your previous decision is ready." end
    if why=="empty" and fallback_why=="empty" then return nil end
    return nil,"The save could not be read. Start a new depot to continue.",true
end
function M.write(snapshot)
    local valid,why=M.validate(snapshot)
    if not valid then return false,"Save rejected: " .. tostring(why) end
    local primary,backup=M.paths()
    local old=load_valid(primary)
    if old then
        local ok,saved=pcall(sys.save,backup,old)
        if not ok or not saved then return false,"Backup could not be written" end
    end
    local ok,saved=pcall(sys.save,primary,snapshot)
    if not ok or not saved then return false,"Save could not be written; the last good backup is available" end
    return true
end
return M
