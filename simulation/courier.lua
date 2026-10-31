local M={RULES="courier-v1"}
function M.enabled(s) return s.courier_rules==M.RULES end
function M.open(s,id)
    s.pending={id=id,roll=0};s.seen[id]=true;s.mode="event"
end
function M.arrive(snapshot)
    local s,p=snapshot.run,snapshot.profile
    if not M.enabled(s) then return end
    if s.target==2 and not s.seen.courier_intro then M.open(s,"courier_intro") end
    if s.target==3 and not s.flags.courier_greeted then
        s.flags.courier_greeted=true
        local old=p.courier or {}
        local note=s.flags.courier_helped and "Mara recognizes your wagon. The meal you shared kept her crew going." or
            (old.sparred and "Mara remembers your last practice match. Her crew is ready for another." or
            (old.helped and "Mara remembers your help on an earlier journey." or
            (s.seen.courier_intro and "Mara waves you over. Her Brindlehorn and Bellmoth rest beside a practice load." or "Mara, a fellow courier, offers a friendly practice match.")))
        s.road_story=(s.road_story and s.road_story.."\n\n" or "")..note
    end
end
function M.commit(p,s)
    if not M.enabled(s) then return end
    p.courier=p.courier or {}
    if s.seen.courier_intro or s.flags.courier_greeted then p.courier.met=true end
    if s.flags.courier_helped then p.courier.helped=true end
    if s.flags.courier_sparred then p.courier.sparred=true end
end
function M.valid(record)
    if record==nil then return true end
    if type(record)~="table" then return false end
    for k,v in pairs(record) do if (k~="met" and k~="helped" and k~="sparred") or v~=true then return false end end
    return true
end
function M.intent(b)
    local stages={{"rush","cargo",14,0},{"heavy",b.team[1],18,8},{"heavy","cargo",20,0}}
    local x=stages[b.round]
    return x and {kind=x[1],target=x[2],damage=x[3],cover=x[4]}
end
return M
