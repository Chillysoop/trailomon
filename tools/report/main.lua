package.path='./?.lua;./?/init.lua;'..package.path
local model=require 'simulation.expedition'
local runner=require 'tools.report.runner'
local json=require 'tools.report.json'
local function split(text)
    local out={};for value in text:gmatch('[^,]+') do out[#out+1]=value end;return out
end
local options={max_actions=assert(tonumber(arg[3])),stall_visits=assert(tonumber(arg[4])),capture=arg[5]=='1'}
local function emit(report) io.write(json.encode(report),'\n') end
for _,seed_text in ipairs(split(arg[1])) do
    local seed=assert(tonumber(seed_text))
    for _,strategy in ipairs(split(arg[2])) do
        local id='seed-'..seed..'-'..strategy
        local report,_,encounters=runner.run(model.new(seed),strategy,options)
        report.id=id;report.kind='journey';report.reproduce={seed=seed,strategy=strategy}
        report.comparison_points=json.array()
        for index,e in ipairs(encounters) do
            report.comparison_points[index]={index=index,action=e.action,event=e.event,peaceful_available=e.peaceful_available,
                note=e.peaceful_available and 'fight, peaceful and withdraw available' or 'peaceful omitted: no available non-battle choice'}
        end
        emit(report)
        if options.capture then for index,encounter in ipairs(encounters) do
            for _,method in ipairs({'fight','peaceful','withdraw'}) do
                if method~='peaceful' or encounter.peaceful_available then
                    local child=runner.run(encounter.snapshot,strategy,{max_actions=options.max_actions,stall_visits=options.stall_visits,intervention=method})
                    child.id=id..'-encounter-'..index..'-'..method;child.kind='comparison'
                    child.parent=id;child.encounter={index=index,event=encounter.event,parent_action=encounter.action,method=method}
                    child.reproduce={seed=seed,strategy=strategy,encounter=index,method=method}
                    emit(child)
                end
            end
        end end
    end
end
