-- Fixed-seed, same-opponent S29 comparison. Run with the pinned Lua runtime.
local c=require "simulation.wagon_combat"
local util=require "simulation.util"
local json=require "tools.report.json"
local function equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end;return true
end
local rows={}
for _,preset in ipairs({"guard","rush","control"}) do
    for _,gear in ipairs({false,true}) do
        local row={preset=preset,gear=gear,seeds=24,wins=0,min_ticks=1800,max_ticks=0,min_wagon=100,max_wagon=0,crew_hp=0,item_triggers=0}
        for seed=1,24 do
            local s=c.new(preset,seed)
            for _,u in ipairs(c.crew(s)) do c.equip(s,u.id,"") end
            if gear then
                local ids=preset=="control" and {"ripple","pip","flint"} or {"moss","ember","lumen"}
                for i,item in ipairs({"padded_trace","release_rope","dry_wrap"}) do c.equip(s,ids[i],item) end
            end
            c.start(s);c.step(s,37);local checkpoint=util.copy(s)
            c.step(s,1800);c.step(checkpoint,1800);assert(equal(s,checkpoint));assert(c.validate(s))
            if s.result=="victory" then row.wins=row.wins+1 end
            row.min_ticks=math.min(row.min_ticks,s.tick);row.max_ticks=math.max(row.max_ticks,s.tick)
            row.min_wagon=math.min(row.min_wagon,s.wagon.hp);row.max_wagon=math.max(row.max_wagon,s.wagon.hp)
            local hp,max_hp=0,0
            for _,u in ipairs(c.crew(s)) do hp=hp+u.hp;max_hp=max_hp+u.max_hp;row.item_triggers=row.item_triggers+u.stats.item_procs end
            row.crew_hp=row.crew_hp+hp/max_hp
        end
        row.crew_hp=math.floor(row.crew_hp/24*1000+0.5)/10
        rows[#rows+1]=row
    end
end
print(json.encode({rules=c.RULES,policy="No supplies; fixed formation; seeds 1-24; checkpoint at tick 37",rows=rows}))
