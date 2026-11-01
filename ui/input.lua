local widgets=require "ui.widgets"
local M={}

function M.handle(self,action_id,action)
    if self.edit then
        if action_id==hash("text") and action.text then
            local text=action.text:gsub(self.edit.kind=="seed" and "[^0-9]" or "[^%w _%-]","")
            self.edit.value=(self.edit.value..text):sub(1,self.edit.kind=="seed" and 10 or 18);self.redraw();return true
        elseif action_id==hash("erase") and (action.pressed or action.repeated) then self.edit.value=self.edit.value:sub(1,-2);self.redraw();return true
        elseif action_id==hash("back") and action.pressed then self.edit=nil;self.redraw();return true end
        -- Only the dialog's buttons may receive navigation and activation.
        -- In particular, Space and F3 must not act on the journey behind it.
        if action_id and action_id~=hash("click") and action_id~=hash("next") and action_id~=hash("previous") and action_id~=hash("confirm") then return true end
    end
    if action_id==hash("click") and action.pressed then
        self.keyboard=false
        return widgets.activate(self,action.x,action.y)
    elseif action_id==nil and action.x then
        self.keyboard=false;widgets.highlight(self,action.x,action.y,false)
    elseif action.pressed then
        if action_id==hash("next") or action_id==hash("previous") then
            self.keyboard=true;widgets.focus_next(self,action_id==hash("next") and 1 or -1);widgets.highlight(self,nil,nil,true);return true
        elseif action_id==hash("confirm") then
            local button=self.buttons[self.focus or 1]
            if button and button.enabled then button.fn() end;return true
        elseif action_id==hash("back") then self.open_page("trail");return true
        elseif action_id==hash("pause") and self.page=="ambush" then
            require("services.ambush_controller").command(self,"pause");return true
        elseif action_id==hash("pause") and self.page=="trail" then
            local mode=self.snapshot.run.mode
            if mode=="stopped" then self.perform("resume") elseif mode=="traveling" then self.perform("pause") end
            if mode=="combat" and self.snapshot.run.battle.rules=="automatic-v1" then self.toggle_combat() end
            return true
        elseif action_id==hash("debug") then self.open_page(self.page=="debug" and "trail" or "debug");return true end
    end
    return false
end

return M
