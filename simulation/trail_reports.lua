local forks=require "content.forks"
local resources=require "simulation.resources"
local gear=require "simulation.equipment"
local M={}

local function member(s,id)
    for _,c in ipairs(s.crew) do if c.species==id then return c end end
end
local function forage_help(s)
    local c=member(s,"loamling")
    if not c then return end
    if resources.ready(c,18) then
        return {icon="forage",text=c.name..": ready to find +8 food for 18 energy. Gathering still takes a day and meals."}
    end
    return {icon="forage",text=c.name..": needs care or at least 18 energy to help gather. Recover before relying on extra food."}
end
local function rain_help(s)
    local c=member(s,"cindercoil")
    if c then
        local ready=resources.ready(c,8) and c.duty=="work"
        return {icon="cargo",text=c.name..(ready and ": working; reduces rain damage to cargo by 70% (3 energy). Needs 8 energy to start." or ": to dry cargo, needs positive condition, Work duty and at least 8 energy.")}
    end
    c=gear.wearer(s,"dry_wrap")
    if c then return {icon="stamina",text=c.name..": dry wrap gives +3 energy recovery on fed, rainy days. It does not protect cargo."} end
end
local function haul_help(s)
    local c=s.crew[s.hauler]
    if gear.has(c,"padded_trace") then
        return {icon="haul",text=c.name..": padded trace saves 3 haul energy at hurried pace. It does not reduce wagon wear or cargo loss."}
    end
    if (s.work_items or {}).padded_trace then
        return {icon="haul",text="Padded trace is packed. Equip it on your hauler for 3 less haul energy at hurried pace."}
    end
end
local function help(s,id)
    if id=="meadow" then return forage_help(s) or haul_help(s) or rain_help(s)
        or {icon="food",text="Gathering costs a day and meals. Check Camp's net-food preview before spending the time."} end
    if id=="woodland" then return rain_help(s) or haul_help(s) or forage_help(s)
        or {icon="food",text="The extra distance uses more meals. Mossbell is the last supply shop; keep food for the approach."} end
    if id=="ridge" then return haul_help(s) or rain_help(s)
        or {icon="repairs",text="Repair before the climb. Steady pace avoids the ridge's hurried cargo loss; extra wagon wear remains."} end
    return forage_help(s) or rain_help(s) or haul_help(s)
        or {icon="time",text="The longer route uses more meals and days. There are no more shops; the road closes on day 32."}
end

-- Pure observation: no look-ahead into weather/event RNG and no saved report state.
-- Resting can change today's evidence, but opening a report cannot change a journey.
function M.get(s)
    local paths=s.mode=="landmark" and forks[s.target]
    if not paths then return nil end
    local early=s.target==2
    local outlook={
        rain="Rain now; wet weather may linger. Rain slows travel and can damage cargo; tomorrow may clear.",
        cold="Cold now; another cold day is possible. Cold slows travel and drains energy; conditions may change.",
        clear="Clear now; this is no promise for tomorrow. Either route can turn wet, and encounters are unreported.",
    }
    local report={
        source=early and "LOCAL OUTLOOK / UNCERTAIN" or "BEYOND THE LAST SHELTER / UNKNOWN",
        outlook=early and outlook[s.weather] or "No fresh report from either path. Today's "..s.weather.." weather cannot tell you what lies beyond the cairns.",
        reminder=early and "Based on today's conditions, not a forecast of the next stretch." or "No more supply shops. Preferred arrival: day 26. Road closes: day 32.",
        routes={},
    }
    for _,path in ipairs(paths) do
        report.routes[#report.routes+1]={id=path.id,label=path.label,distance=path.distance,facts=path.facts,help=help(s,path.id)}
    end
    return report
end
return M
