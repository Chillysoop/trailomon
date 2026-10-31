local model=require 'simulation.expedition'
local util=require 'simulation.util'
local save=require 'services.save'
local policy=require 'tools.report.policy'
local json=require 'tools.report.json'
local M={}
local resources={'food','coins','repairs','medicine','wagon','cargo','traveler'}
local gates={preparation=true,stopped=true,event=true,landmark=true,combat_select=true,combat_result=true,result=true}

local function observe(p)
    local s=p.run
    local out={day=s.day,mode=s.mode,target=s.target,landmark=model.route[s.target].id,
        progress=s.progress,distance=s.distance,terrain=s.terrain,weather=s.weather,
        pace=s.pace,rations=s.rations,food_days=math.floor(s.food/model.resources.daily_food(s)),
        load=model.resources.weight(s),capacity=model.resources.capacity(s),hauler=s.hauler,
        hauler_ready=not not model.resources.hauler(s),crew=json.array(),outcome=s.outcome}
    for _,key in ipairs(resources) do out[key]=s[key] end
    for i,c in ipairs(s.crew) do out.crew[i]={species=c.species,name=c.name,energy=c.stamina,condition=c.condition,duty=c.duty} end
    if s.pending then out.event=s.pending.id end
    if s.battle then out.battle={kind=s.battle.kind,round=s.battle.round,resolve=s.battle.resolve,outcome=s.battle.outcome,intent=util.copy(s.battle.intent)} end
    return out
end
M.observe=observe
local function delta(a,b)
    local out={days=b.day-a.day,crew=json.array()}
    for _,key in ipairs(resources) do out[key]=b[key]-a[key] end
    for i,c in ipairs(b.crew) do
        local prior=a.crew[i]
        out.crew[i]={species=c.species,added=not prior or prior.species~=c.species}
        if not out.crew[i].added then out.crew[i].energy=c.energy-prior.energy;out.crew[i].condition=c.condition-prior.condition end
    end
    return out
end
local function messages(before,after)
    -- The game retains only 70 log entries. Recover additions across truncation.
    local overlap=math.min(#before,#after)
    while overlap>0 do
        local matches=true
        for i=1,overlap do
            local a,b=before[#before-overlap+i],after[i]
            if a.day~=b.day or a.text~=b.text then matches=false;break end
        end
        if matches then break end
        overlap=overlap-1
    end
    local added=json.array();for i=overlap+1,#after do added[#added+1]=util.copy(after[i]) end
    return added
end
local function state_key(p)
    local copy=util.copy(p);copy.run.log=nil -- Repeated prose cannot hide a loop.
    return json.encode(copy)
end

function M.run(initial,strategy,opts)
    opts=opts or {}
    local p=util.copy(initial)
    local report={schema=1,policy_version=policy.VERSION,strategy=strategy,seed=p.run.seed,
        initial_snapshot=util.copy(p),steps=json.array(),waits=json.array(),minimum={},crew_minimum={},
        totals={days=0,recovery_days=0,recovery_actions=0,food_decreases=0,food_increases=0,
            energy_decreases=0,energy_increases=0,condition_decreases=0,travel_ticks=0,longest_travel_stretch=0,combat_exchanges=0,days_by_command={}},
        status='running'}
    local encounters={};local visits={};local intervention=opts.intervention;local travel_stretch=0
    local initial_observation=observe(p)
    local function sample(at)
        local o=observe(p)
        for _,key in ipairs(resources) do
            if not report.minimum[key] or o[key]<report.minimum[key].value then report.minimum[key]={value=o[key],day=o.day,action=at} end
        end
        for _,c in ipairs(o.crew) do
            local m=report.crew_minimum[c.species] or {energy={value=101},condition={value=101}}
            for _,key in ipairs({'energy','condition'}) do if c[key]<m[key].value then m[key]={value=c[key],day=o.day,action=at} end end
            report.crew_minimum[c.species]=m
        end
        return o
    end
    local function fail(kind,message,action)
        report.status=kind;report.failure={message=tostring(message),action=action,context=observe(p)}
    end
    local valid,why=save.validate(p)
    if not valid then fail('invalid_state',why,0) else
        sample(0);visits[state_key(p)]=1
        if gates[p.run.mode] then report.waits[1]={action=0,day=p.run.day,mode=p.run.mode,event=p.run.pending and p.run.pending.id,notice=p.run.notice} end
        for index=1,opts.max_actions or 250 do
            if p.run.mode=='result' then break end
            local before=observe(p);local before_snapshot=util.copy(p)
            if opts.capture and p.run.mode=='event' and policy.choice(p,'fight') then
                encounters[#encounters+1]={snapshot=util.copy(p),action=index,event=p.run.pending.id,
                    peaceful_available=not not policy.choice(p,'peaceful')}
            end
            local decision_ok,id,args,reason=pcall(function()
                if intervention and not report.intervention_result then
                    if p.run.mode=='event' then
                        local pick=assert(policy.choice(p,intervention=='peaceful' and 'peaceful' or 'fight'),'Intervention unavailable')
                        return 'choice',{id=pick.id},'matched intervention: '..intervention
                    elseif intervention=='withdraw' and p.run.mode=='combat_select' then return 'withdraw',{},'matched intervention: withdraw before the first exchange' end
                end
                return (opts.policy or policy.next)(p,strategy)
            end)
            if not decision_ok then fail('policy_error',id,index);break end
            if json.encode(before_snapshot)~=json.encode(p) then fail('policy_error','Policy mutated simulation state',index);break end
            if type(id)~='string' or (args~=nil and type(args)~='table') then fail('policy_error','Policy returned no valid command',index);break end
            args=args or {}
            local called,ok,message=pcall(model.command,p,id,args)
            local after=sample(index);local change=delta(before,after)
            local entry={index=index,command=id,args=util.copy(args),reason=reason or '',before=before,after=after,
                delta=change,ok=called and ok==true,messages=messages(before_snapshot.run.log,p.run.log)}
            report.steps[#report.steps+1]=entry
            if not entry.ok then entry.error=tostring(called and message or ok);fail('command_error',entry.error,index);break end
            valid,why=save.validate(p)
            if not valid then fail('invalid_state',why,index);break end
            local t=report.totals
            t.days=t.days+change.days;t.days_by_command[id]=(t.days_by_command[id] or 0)+change.days
            t.food_decreases=t.food_decreases+math.max(0,-change.food);t.food_increases=t.food_increases+math.max(0,change.food)
            for _,c in ipairs(change.crew) do if not c.added then
                t.energy_decreases=t.energy_decreases+math.max(0,-c.energy);t.energy_increases=t.energy_increases+math.max(0,c.energy)
                t.condition_decreases=t.condition_decreases+math.max(0,-c.condition)
            end end
            if id=='rest' or id=='repair' or id=='treat' or id=='river' and args.method=='wait' then
                t.recovery_actions=t.recovery_actions+1;t.recovery_days=t.recovery_days+change.days
            end
            if id=='step' then
                t.travel_ticks=t.travel_ticks+1;travel_stretch=travel_stretch+1
                t.longest_travel_stretch=math.max(t.longest_travel_stretch,travel_stretch)
            else travel_stretch=0 end
            if id=='battle_step' then t.combat_exchanges=t.combat_exchanges+1 end
            if gates[after.mode] and (after.mode~=before.mode or id=='choice' or id=='battle_continue') then
                report.waits[#report.waits+1]={action=index,day=after.day,mode=after.mode,event=after.event,notice=p.run.notice}
            end
            if intervention and not report.intervention_result and p.run.mode~='event' and p.run.mode~='combat_select' and p.run.mode~='combat' then
                report.intervention_result={action=index,method=intervention,delta=delta(initial_observation,after),after=util.copy(after)}
            end
            if p.run.mode=='result' then break end
            local key=state_key(p);visits[key]=(visits[key] or 0)+1
            if visits[key]>=(opts.stall_visits or 3) then fail('stalled','Simulation state repeated without progress',index);break end
        end
        if report.status=='running' then
            if p.run.mode=='result' then report.status='completed' else fail('action_limit','Action budget exhausted',#report.steps) end
        end
    end
    report.final_snapshot=util.copy(p);report.final=observe(p);report.outcome=p.run.outcome
    report.actions=#report.steps
    return report,p,encounters
end
return M
