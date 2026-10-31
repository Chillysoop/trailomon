local species=require "content.species"
local M={}
M.notes={
    brindlehorn="Herds call across open meadow through hollow antlers.",
    reedskipper="Reed platforms mark shallow river margins.",
    loamling="Hungry groups follow spilled grain toward wagons.",
    bellmoth="Woodland shelter keeps their reflective wings dry.",
    cindercoil="Dry bedding shelters the warmth beneath their coils.",
    slatewhorl="Broad feet and low plates grip loose upland shale.",
}
M.clues={
    brindlehorn={place="Meadows / Split Oak",method="Discovery: meet the youngster at Split Oak. Leave room and 4 food."},
    reedskipper={place="River margins / Willowford",method="Discovery: meet it at Willowford. Leave room and 4 food."},
    loamling={place="Meadows and woodland",method="Watch root diggings; Discovery invitations also wait at Split Oak."},
    bellmoth={place="Woodland / Mossbell",method="Watch sheltered roosts; Discovery invitations also wait at Mossbell."},
    cindercoil={place="Woodland, marsh and uplands",method="Help with medicine, then watch for its return. Keep room and 4 food."},
    slatewhorl={place="Beyond Willowford / high country",method="Free it with a board or a day's work, then watch for its return."},
}
local encounters={scavengers="loamling",territorial="slatewhorl",cinder_shelter="cindercoil",cinder_return="cindercoil",slate_tracks="slatewhorl",slate_return="slatewhorl",meet_brindlehorn="brindlehorn",meet_reedskipper="reedskipper",discover_loamling="loamling",discover_bellmoth="bellmoth"}
function M.observe(s,id)
    if not species.defs[id] then return end
    s.observations=s.observations or {};s.observations[id]=true;s.discoveries[id]=true
end
function M.encounter(s,id) M.observe(s,encounters[id]) end
function M.valid(map)
    if map==nil then return true end
    if type(map)~="table" then return false end
    for id,value in pairs(map) do if not species.defs[id] or value~=true then return false end end
    return true
end
function M.commit(p,s)
    p.observations=p.observations or {};p.traveled=p.traveled or {};s.new_observations={}
    for id in pairs(s.observations or {}) do
        if not p.observations[id] then s.new_observations[id]=true end
        p.observations[id]=true
    end
    for _,c in ipairs(s.crew) do p.traveled[c.species]=true end
end
function M.rows(snapshot)
    local p,s=snapshot.profile,snapshot.run;local rows={}
    for _,id in ipairs(species.order) do
        local seen=(p.observations or {})[id] or (s.observations or {})[id] or false
        local traveled=(p.traveled or {})[id] or false
        if s.mode~="preparation" then for _,c in ipairs(s.crew) do if c.species==id then traveled=true end end end
        rows[#rows+1]={id=id,name=species.defs[id].name,known=p.discoveries[id] or s.discoveries[id] or false,seen=seen,traveled=traveled,note=seen and M.notes[id] or "Watch wildlife to learn its habits.",clue=M.clues[id],evidence=seen and "Seen firsthand" or "Report / unconfirmed"}
    end
    return rows
end
return M
