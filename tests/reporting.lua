local model=require 'simulation.expedition'
local util=require 'simulation.util'
local runner=require 'tools.report.runner'
local policy=require 'tools.report.policy'
local json=require 'tools.report.json'
return function(test,equal,legacy_journey)
    test('reporting preserves all 120 original reference journeys',function()
        local counts={}
        for _,name in ipairs(policy.names) do
            counts[name]={}
            for seed=1,40 do
                local input=model.new(seed);input.run.combat_effort=nil;local before=util.copy(input)
                local report,final=runner.run(input,name)
                assert(report.status=='completed');equal(final,legacy_journey(seed,name,nil,true));equal(input,before)
                counts[name][report.outcome]=(counts[name][report.outcome] or 0)+1
                assert(report.totals.days==final.run.day-1)
                assert(report.initial_snapshot.run.food+report.totals.food_increases-report.totals.food_decreases==final.run.food)
                local food_min=input.run.food;local days=0
                for index,step in ipairs(report.steps) do
                    assert(index==step.index and step.ok)
                    assert(step.after.food-step.before.food==step.delta.food)
                    food_min=math.min(food_min,step.after.food);days=days+step.delta.days
                end
                assert(food_min==report.minimum.food.value and days==report.totals.days)
            end
        end
        assert((counts.careful.delivered or 0)+(counts.peaceful.delivered or 0)==37)
        assert(counts.fighter.delivered==5)
    end)
    test('matched interventions preserve their exact source and downstream policy',function()
        local original=model.new(8);assert(model.command(original,'depart'));assert(model.debug(original,'event','scavengers'))
        local before=util.copy(original)
        for _,method in ipairs({'fight','peaceful','withdraw'}) do
            local a=runner.run(original,'careful',{intervention=method})
            local b=runner.run(original,'careful',{intervention=method})
            equal(a,b);equal(original,before);equal(a.initial_snapshot,before)
            assert(a.status=='completed' and a.intervention_result.method==method)
            if method=='peaceful' then assert(a.steps[1].args.id=='food' and a.intervention_result.delta.food==-6)
            elseif method=='withdraw' then assert(a.steps[1].args.id=='battle' and a.steps[2].command=='withdraw' and a.intervention_result.delta.food==-8)
            else assert(a.steps[1].args.id=='battle' and a.totals.combat_exchanges>0) end
        end
    end)
    test('reporter explains stalls, budgets, rejected commands and policy faults',function()
        local p=model.new(7)
        local r=runner.run(p,'careful',{max_actions=1});assert(r.status=='action_limit' and r.failure.action==1)
        r=runner.run(p,'careful',{policy=function() return 'policy',{key='pace',value='steady'} end})
        assert(r.status=='stalled' and r.actions==2 and r.failure.context.mode=='preparation')
        r=runner.run(p,'careful',{policy=function() return 'not-a-command',{} end})
        assert(r.status=='command_error' and r.steps[1].command=='not-a-command' and not r.steps[1].ok)
        r=runner.run(p,'careful',{policy=function() error('deliberate bot fault') end})
        assert(r.status=='policy_error' and r.failure.message:find('deliberate bot fault',1,true))
        r=runner.run(p,'careful',{policy=function() end});assert(r.status=='policy_error')
        r=runner.run(p,'careful',{policy=function(state) state.run.food=12;return 'depart',{} end})
        assert(r.status=='policy_error' and r.failure.message=='Policy mutated simulation state' and p.run.food==90)
        p.run.food=-1;r=runner.run(p,'careful');assert(r.status=='invalid_state' and r.failure.action==0)
    end)
    test('last-budget endings and real decision gates are reported without false stalls',function()
        local p=model.new(1);assert(model.command(p,'depart'));assert(model.command(p,'resume'));p.run.day=31
        local r=runner.run(p,'careful',{max_actions=1})
        assert(r.status=='completed' and r.outcome=='rescued' and r.actions==1)
        assert(r.waits[#r.waits].mode=='result' and r.waits[#r.waits].action==1)
        local _,_,encounters=runner.run(model.new(1),'fighter',{capture=true})
        assert(#encounters>0)
        for _,e in ipairs(encounters) do assert(e.snapshot.run.mode=='event' and policy.choice(e.snapshot,'fight')) end
    end)
    test('report JSON is stable, precise and escapes control characters',function()
        assert(json.encode({z=1,a='line\n"\\'})=='{"a":"line\\u000a\\"\\\\","z":1}')
        assert(json.encode(json.array())=='[]' and json.encode({})=='{}')
        assert(json.encode({1,2,3})=='[1,2,3]')
        assert(not pcall(json.encode,0/0))
        assert(not pcall(json.encode,{[1]=true,['1']=false}))
    end)
    test('report traces retain new messages after the journal reaches its display limit',function()
        local p=model.new(1);p.run.log={}
        for i=1,70 do p.run.log[i]={day=1,text='Earlier note '..i} end
        local r=runner.run(p,'careful',{max_actions=1})
        assert(#r.final_snapshot.run.log==70 and #r.steps[1].messages==1)
        assert(r.steps[1].messages[1].text:find('Left Fernwake',1,true))
    end)
end
