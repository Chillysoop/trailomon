local w=require "ui.widgets"
local model=require "simulation.expedition"
local util=require "simulation.util"
local M={}
local function label(self,x,y,text) w.text(self,x,y,text,12,"muted") end
function M.draw(self)
    local s=self.snapshot.run;local b=s.battle
    label(self,28,611,"ROUND "..b.round.." / "..b.limit.."  /  "..(b.kind=="scavengers" and "PROTECT CARGO" or "SECURE PASSAGE"))
    w.text(self,28,575,b.kind=="scavengers" and "Hold the wagon for three rounds." or "Persuade the guardian to retreat.",23,"ink")
    w.text(self,28,535,model.combat.intent_text(s),14,"gold")
    w.bar(self,28,510,834,b.resolve/75*100,"red",8)
    label(self,28,493,"THREAT RESOLVE "..b.resolve.." / Each companion acts once per round")
    self.battle_actions=self.battle_actions or {}
    for row,i in ipairs(b.team) do
        local idx=i; local c=s.crew[i];local x=28+(row-1)*425;local def=model.species.defs[c.species]
        w.panel(self,x,237,409,235)
        w.sprite(self,c.species,x+65,408,92)
        w.text(self,x+128,435,c.name,22,"ink")
        label(self,x+128,406,"Energy "..util.round(c.stamina))
        label(self,x+128,384,"Condition "..util.round(c.condition))
        local selected=self.battle_actions[i]
        local guard_cost=c.condition>0 and math.min(3,c.stamina) or 0
        local options={{id="pressure",label="Pressure (-6 energy)",enabled=model.resources.ready(c,6)},
            {id="guard",label="Guard (-"..guard_cost.." energy)",enabled=true},
            {id="assist",label=def.assist..(b.used[i] and " (used)" or " (-12 energy)"),enabled=not b.used[i] and model.resources.ready(c,12)}}
        for n,option in ipairs(options) do
            local kind=option.id
            w.button(self,x+16,338-(n-1)*33,377,27,option.label..(selected==kind and " / chosen" or ""),function() self.battle_actions[idx]=kind;self.redraw() end,{selected=selected==kind,enabled=option.enabled,size=12,key="action"..i..kind,icon=kind})
        end
    end
    local complete=true
    for _,i in ipairs(b.team) do if not self.battle_actions[i] then complete=false end end
    w.button(self,28,171,409,42,complete and "Resolve this round" or "Choose an action for each companion",function()
        local actions={};for _,i in ipairs(b.team) do actions[#actions+1]={member=i,kind=self.battle_actions[i]} end
        self.perform("round",{actions=actions})
    end,{primary=true,enabled=complete,size=complete and 15 or 12})
    local selected=next(self.battle_actions)~=nil
    w.button(self,453,171,409,42,selected and "Clear selected actions" or "Withdraw",function()
        if selected then self.battle_actions={};self.redraw() else self.perform("withdraw") end
    end,{size=14})
    w.text(self,28,142,"Guard protects the acting companion and cargo. Assist is once per battle. Clear actions before withdrawing.",12,"muted",834)
    w.text(self,28,86,b.last,14,"gold")
end
return M
