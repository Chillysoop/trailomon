-- Frozen reference policies from tests/run.lua. These are benchmark behaviors,
-- not optimal players. Keep versioning explicit when a policy changes.
local model=require 'simulation.expedition'
local M={VERSION='reference-v1',names={'careful','peaceful','fighter'}}
function M.choice(p,kind)
    local event=model.events.by_id[p.run.pending.id]
    for _,c in ipairs(event.choices) do
        if (kind=='fight' and c.battle or kind=='peaceful' and not c.battle)
            and model.events.available(p.run,c,p.profile) then return c end
    end
end
function M.next(p,strategy)
    local s=p.run
    if s.mode=='preparation' then return 'depart',{},'default crew and supplies'
    elseif s.mode=='stopped' or s.mode=='traveling' then
        if s.food<model.resources.daily_food(s)*3 and model.forage_preview(s).net>0 then return 'forage',{},'fewer than three food days; positive gathering yield'
        elseif s.wagon<28 and s.repairs>0 then return 'repair',{},'wagon below 28'
        elseif not model.resources.hauler(s) or s.crew[s.hauler].stamina<18 then return 'rest',{},'hauler unavailable or below 18 energy'
        elseif s.mode=='stopped' then return 'resume',{},'ready to travel'
        else return 'step',{},'one travel day' end
    elseif s.mode=='landmark' then
        if s.target==4 and not s.flags.river_inspected then return 'river',{method='inspect'},'inspect crossing'
        elseif s.target==4 and not s.flags.river_crossed then return 'river',{method=s.coins>=12 and 'ferry' or 'rope'},'pay for ferry when affordable'
        elseif s.target==3 and s.food<55 and s.coins>=6 and model.resources.weight(s)+10<=model.resources.capacity(s) then return 'buy',{item='food'},'outpost food below 55; room and coins available'
        else return 'leave',{branch=s.target==2 and (strategy=='careful' and 'meadow' or 'woodland') or 'ridge'},'reference route choice' end
    elseif s.mode=='event' then
        local pick
        for _,c in ipairs(model.events.by_id[s.pending.id].choices) do
            if model.events.available(s,c,p.profile) and (strategy~='peaceful' or not c.battle) then pick=c;break end
        end
        if strategy=='fighter' then pick=M.choice(p,'fight') or pick end
        assert(pick,'No available event choice')
        return 'choice',{id=pick.id},strategy=='fighter' and 'prefer battle when available' or 'first available reference choice'
    elseif s.mode=='combat_select' then
        local team={}
        for i,c in ipairs(s.crew) do if #team<2 and model.resources.ready(c,4) then team[#team+1]=i end end
        if #team>0 then return 'battle_start',{team=team},'first two ready companions in crew order' end
        return 'withdraw',{},'no ready combatant'
    elseif s.mode=='combat' then return 'battle_step',{},'automatic exchange'
    elseif s.mode=='combat_result' then return 'battle_continue',{},'acknowledge encounter result' end
    error('No policy action for mode '..tostring(s.mode))
end
return M
