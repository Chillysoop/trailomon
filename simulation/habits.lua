local M={}
M.defs={
    brindlehorn={name="Steady pull",icon="haul",text="Hauling energy -2 / travel distance -4% while hauling."},
    reedskipper={name="Measured signals",icon="water",text="Assistance energy -4 / +1 hauling energy on dry, clear ground."},
    loamling={name="Careful digging",icon="dig",text="Gathering energy -6 / gathered food -2."},
    bellmoth={name="Patient scouting",icon="scout",text="Road assistance energy -4 / food upkeep +0.5 per day."},
    cindercoil={name="Gentle warmth",icon="warm",text="Road assistance energy -4 / food upkeep +0.5 per day."},
    slatewhorl={name="Settled footing",icon="guard",text="Hauling energy -2 / travel distance -4% while hauling."},
}
function M.active(c) return c and c.habit==true and c.habit_days==3 end
function M.upkeep(c) return M.active(c) and (c.species=="bellmoth" or c.species=="cindercoil") and 0.5 or 0 end
function M.haul(c) return M.active(c) and (c.species=="brindlehorn" or c.species=="slatewhorl") and -2 or 0 end
function M.speed(c) return M.haul(c)<0 and 0.96 or 1 end
function M.dry_haul(c) return M.active(c) and c.species=="reedskipper" and 1 or 0 end
function M.cost(c,context,base)
    if not M.active(c) then return base end
    if context=="forage" and c.species=="loamling" then return math.max(0,base-6) end
    if (context=="river" and c.species=="reedskipper") or
        (context=="event" and (c.species=="reedskipper" or c.species=="bellmoth" or c.species=="cindercoil")) then return math.max(0,base-4) end
    return base
end
function M.yield(c) return M.active(c) and c.species=="loamling" and -2 or 0 end
function M.work(c)
    c.habit_days=math.min(3,(c.habit_days or 0)+1)
end
function M.valid(c)
    if c.habit_days~=nil and (type(c.habit_days)~="number" or c.habit_days~=math.floor(c.habit_days) or c.habit_days<0 or c.habit_days>3) then return false end
    return (c.habit==nil or c.habit==true) and (not c.habit or c.habit_days==3)
end
function M.toggle(snapshot,id)
    local s,p=snapshot.run,snapshot.profile
    if s.mode~="preparation" then return false,"Choose habits at the departure depot" end
    for _,c in ipairs(s.crew) do if c.species==id then
        if c.habit_days~=3 then return false,"Share three well-fed working travel days first" end
        if c.habit then c.habit=nil else c.habit=true end;p.roster[id].habit=c.habit
        return true
    end end
    return false,"Choose this companion for the journey first"
end
return M
