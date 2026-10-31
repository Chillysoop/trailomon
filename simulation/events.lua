local definitions = require "content.events"
local resources = require "simulation.resources"
local rng = require "simulation.rng"
local species = require "content.species"
local M = {defs=definitions, by_id={}}
for _, event in ipairs(definitions) do M.by_id[event.id] = event end

function M.eligible(s, event, profile)
    if s.seen[event.id] then return false end
    local condition = event.condition
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
    local majors, ambient, followups = {}, {}, {}
    for _, event in ipairs(definitions) do
        if M.eligible(s, event, profile) then
            if event.kind == "ambient" then ambient[#ambient+1] = event
            elseif event.condition:find("follow") then followups[#followups+1] = event
            else majors[#majors+1] = event end
        end
    end
    if s.cooldown <= 0 then
        if #followups > 0 then return followups[1] end
        if roll < 0.60 and #majors > 0 then return majors[rng.int(s.rng,"events",1,#majors)] end
    end
    if roll > 0.65 and #ambient > 0 then return ambient[rng.int(s.rng,"events",1,#ambient)] end
end

function M.available(s, choice, profile)
    local ok, why = resources.can_pay(s, choice.cost)
    if not ok then return false, why end
    if choice.species and not resources.find(s, choice.species, choice.effort) then return false, "Needs a ready " .. species.defs[choice.species].name end
    if choice.recruit then
        if #s.crew >= 3 then return false, "Crew is full (3 companions)" end
        if profile.roster[choice.recruit] then return false, "Already at your depot" end
        for _, c in ipairs(s.crew) do if c.species == choice.recruit then return false, "Already traveling with you" end end
    end
    if choice.battle then
        local ready = false
        for _, c in ipairs(s.crew) do if resources.ready(c, 6) then ready = true end end
        if not ready then return false, "No companion has enough energy" end
    end
    return true
end

function M.cost_text(s, choice)
    local pieces = {}
    for _, key in ipairs({"coins","food","repairs","medicine"}) do
        if choice.cost and choice.cost[key] then pieces[#pieces+1] = choice.cost[key] .. " " .. key end
    end
    if choice.effort then pieces[#pieces+1] = choice.effort .. " energy" end
    if choice.days then pieces[#pieces+1] = choice.days .. " day + " .. resources.daily_food(s)*choice.days .. " food" end
    if choice.effects then
        for _, key in ipairs({"food","wagon","cargo","traveler","stamina","progress"}) do
            local value=choice.effects[key]
            if value then pieces[#pieces+1] = (value>0 and "+" or "") .. value .. " " .. (key=="stamina" and "energy" or key) end
        end
    end
    if choice.recruit then pieces[#pieces+1]="+1 companion; higher daily food" end
    if choice.gamble then pieces[#pieces+1]="Chance of saved distance or wagon damage" end
    if choice.battle then pieces[#pieces+1]="Short battle; injuries and fatigue persist" end
    return #pieces > 0 and table.concat(pieces, " / ") or "No supplies required"
end
return M
