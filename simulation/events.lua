local definitions = require "content.events"
local resources = require "simulation.resources"
local rng = require "simulation.rng"
local species = require "content.species"
local util = require "simulation.util"
local combat = require "simulation.combat"
local M = {defs=definitions, by_id={}}
for _, event in ipairs(definitions) do M.by_id[event.id] = event end

function M.eligible(s, event, profile)
    if s.seen[event.id] then return false end
    local condition = event.condition
    if event.kind=="courier" or event.kind=="discovery_start" then return false end -- Offered at a specific landmark, outside random selection.
    if event.kind=="wildlife" then
        if s.wildlife_rules~="wildlife-v1" then return false end
        return (condition=="wild_meadow" and s.terrain=="meadow" and s.target<=3) or
            (condition=="wild_woods" and s.terrain=="woodland") or
            (condition=="wild_river" and s.target==4 and s.terrain=="marsh")
    end
    if condition == "any" then return true end
    if condition == "mud" then return s.rainfall >= 2 end
    if condition == "worn" then return s.wagon < 85 end
    if condition == "rain" then return s.weather == "rain" end
    if condition == "cold" then return s.weather == "cold" end
    if condition == "woods" then return s.terrain == "woodland" end
    if condition == "soft" then return s.terrain == "woodland" or s.terrain == "meadow" end
    if condition == "upland" then return s.target >= 5 end
    if condition == "cinder_lead" then return s.target >= 3 and not profile.roster.cindercoil end
    if condition == "slate_lead" then return s.target >= 5 and not profile.roster.slatewhorl end
    if condition == "cinder_follow" then return s.flags.cinder_helped and not profile.roster.cindercoil end
    if condition == "slate_follow" then return s.flags.slate_helped and not profile.roster.slatewhorl end
    return false
end

function M.select(s, profile)
    local roll = rng.next(s.rng, "events")
    local majors, ambient, followups, wildlife = {}, {}, {}, {}
    for _, event in ipairs(definitions) do
        if M.eligible(s, event, profile) then
            if event.kind == "wildlife" then wildlife[#wildlife+1]=event
            elseif event.kind == "ambient" then ambient[#ambient+1] = event
            elseif event.condition:find("follow") then followups[#followups+1] = event
            else majors[#majors+1] = event end
        end
    end
    if s.cooldown <= 0 then
        if #followups > 0 then return followups[1] end
        if roll < 0.60 and #majors > 0 then return majors[rng.int(s.rng,"events",1,#majors)] end
    end
    if roll>0.65 and s.cooldown<=0 and #wildlife>0 then return wildlife[rng.int(s.rng,"events",1,#wildlife)] end
    if roll > 0.65 and #ambient > 0 then return ambient[rng.int(s.rng,"events",1,#ambient)] end
end

function M.effort(s,choice) return choice.species and resources.effort(s,choice.species,choice.effort,"event") or choice.effort end
function M.available(s, choice, profile)
    local ok, why = resources.can_pay(s, choice.cost)
    if not ok then return false, why end
    if choice.species and not resources.find(s, choice.species, choice.effort,"event") then return false, "Needs a ready " .. species.defs[choice.species].name end
    if choice.recruit then
        if #s.crew >= 3 then return false, "Crew is full (3 companions)" end
        if profile.roster[choice.recruit] then return false, "Already at your depot" end
        for _, c in ipairs(s.crew) do if c.species == choice.recruit then return false, "Already traveling with you" end end
    end
    if choice.battle then
        local ready = false
        local ordinary=combat.costs(s)
        for _, c in ipairs(s.crew) do if resources.ready(c, ordinary) then ready = true end end
        if not ready then return false, "Needs a companion with "..ordinary.." energy" end
    end
    return true
end

function M.recruit_preview(s, choice)
    if not choice.recruit then return nil end
    local after=util.copy(s)
    resources.pay(after,choice.cost)
    after.crew[#after.crew+1]={species=choice.recruit}
    local before_meals,after_meals=resources.daily_food(s),resources.daily_food(after)
    return {food_before=s.food,food_after=after.food,meals_before=before_meals,meals_after=after_meals,
        days_before=math.floor(s.food/before_meals),days_after=math.floor(after.food/after_meals)}
end

function M.receipt(before,after)
    local pieces={}
    local function add(label,delta,suffix)
        if math.abs(delta)<0.00001 then return end
        local value=string.format("%.1f",delta):gsub("%.0$","")
        pieces[#pieces+1]=label.." "..(delta>0 and "+" or "")..value..(suffix or "")
    end
    for _,entry in ipairs({{"day","Days"},{"food","Provisions"},{"coins","Coins"},{"repairs","Repair"},{"medicine","Medicine"},{"wagon","Wagon","%"},{"cargo","Cargo","%"},{"traveler","Traveler","%"}}) do
        add(entry[2],after[entry[1]]-before[entry[1]],entry[3])
    end
    for i,c in ipairs(before.crew) do
        add(c.name.." energy",after.crew[i].stamina-c.stamina)
        add(c.name.." condition",after.crew[i].condition-c.condition)
    end
    return #pieces>0 and table.concat(pieces," / ").."." or "No supplies or energy spent."
end

function M.cost_text(s, choice)
    if choice.recruit then
        local p=M.recruit_preview(s,choice)
        return "Provisions "..p.food_before.." -> "..p.food_after.." / Meals per day "..p.meals_before.." -> "..p.meals_after.." / Food days "..p.days_before.." -> "..p.days_after
    end
    local pieces = {}
    for _, key in ipairs({"coins","food","repairs","medicine"}) do
        if choice.cost and choice.cost[key] then pieces[#pieces+1] = choice.cost[key] .. " " .. key end
    end
    if choice.effort then pieces[#pieces+1] = M.effort(s,choice) .. " energy" end
    if choice.days then pieces[#pieces+1] = choice.days .. " day + " .. resources.daily_food(s)*choice.days .. " food" end
    if choice.effects then
        for _, key in ipairs({"food","wagon","cargo","traveler","stamina","progress"}) do
            local value=choice.effects[key]
            if value then pieces[#pieces+1] = (value>0 and "+" or "") .. value .. " " .. (key=="stamina" and "energy" or key) end
        end
    end
    if choice.gamble then pieces[#pieces+1]="Chance of saved distance or wagon damage" end
    if choice.battle then pieces[#pieces+1]="Short battle; injuries and fatigue persist" end
    if choice.hint then pieces[#pieces+1]=choice.hint end
    return #pieces > 0 and table.concat(pieces, " / ") or "No supplies required"
end
return M
