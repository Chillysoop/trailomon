local w=require "ui.widgets"
local habits=require "simulation.habits"
local M={}
function M.draw(self)
    local s=self.snapshot.run
    w.text(self,28,611,"LEARNED HABITS / ONE OPTIONAL TRADEOFF PER COMPANION",12,"muted")
    w.text(self,28,575,"A rhythm learned together.",27,"ink")
    w.text(self,28,542,"Unlock: 3 well-fed working travel days. Select at the departure depot.",13,"muted")
    for i,c in ipairs(s.crew) do
        local y=389-(i-1)*148;local def=habits.defs[c.species];local id=c.species
        w.panel(self,28,y,834,135);w.sprite(self,c.species,88,y+72,96)
        w.reading(self,158,y+103,def.icon,nil,{label=c.name.." / "..def.name,size=18})
        w.text(self,158,y+72,def.text,13,"muted",680)
        w.text(self,158,y+34,(c.habit_days or 0).." / 3 working days",12,"ink")
        w.button(self,606,y+18,236,34,c.habit and "Habit: on" or "Habit: off",function() self.perform("habit",{species=id}) end,
            {key="habit_"..id,selected=c.habit==true,enabled=s.mode=="preparation" and c.habit_days==3,size=12,icon=def.icon})
    end
    w.button(self,28,48,240,32,"Back to Crew",function() self.open_page("crew") end,{key="habits_back",size=12,icon="crew"})
end
return M
