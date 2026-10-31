local species = require "content.species"
local wagons = require "content.wagons"
local equipment=require "simulation.equipment"
local habits=require "simulation.habits"
local M = {}
M.goods={food={amount=10,price=6,weight=10},repairs={amount=1,price=8,weight=4},medicine={amount=1,price=7,weight=2}}
M.paces = {easy={speed=5.5, effort=4, wear=0.4}, steady={speed=7.2, effort=7, wear=0.8}, hurried={speed=9.1, effort=11, wear=2}}
M.rations = {sparse={food=0.65, recovery=0}, normal={food=1, recovery=3}, generous={food=1.35, recovery=6}}
function M.weight(s) return s.food + s.repairs * 4 + s.medicine * 2 + 25 + equipment.weight(s) end
function M.capacity(s) return wagons[s.wagon_type].capacity end
function M.daily_food(s)
    local total = 1
    for _, c in ipairs(s.crew) do total = total + species.defs[c.species].upkeep+habits.upkeep(c) end
    return math.ceil(total * M.rations[s.rations].food)
end
function M.ready(c, effort) return c and c.condition > 0 and c.stamina >= (effort or 1) end
function M.effort(s,id,base,context)
    for _,c in ipairs(s.crew) do if c.species==id then return habits.cost(c,context,base) end end
    return base
end
function M.find(s, id, effort, context)
    for i, c in ipairs(s.crew) do
        local cost=habits.cost(c,context,effort)
        if c.species == id and M.ready(c, cost) then return c, i, cost end
    end
end
function M.haul_effort(s,c)
    return math.max(1,M.paces[s.pace].effort+habits.haul(c)-((s.pace=="hurried" and equipment.has(c,"padded_trace")) and 3 or 0))
end
function M.hauler(s)
    local c = s.crew[s.hauler]
    if c and species.defs[c.species].draft and c.duty == "work" and M.ready(c, M.haul_effort(s,c)) then return c end
end
function M.can_pay(s, cost)
    for key, amount in pairs(cost or {}) do
        if s[key] < amount then return false, "Need " .. amount .. " " .. key end
    end
    return true
end
function M.pay(s, cost)
    for key, amount in pairs(cost or {}) do s[key] = s[key] - amount end
end
return M
