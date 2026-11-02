local model=require 'simulation.expedition'
local screens=require 'ui.screens'
local scene=require 'presentation.scene'
local controller=require 'services.ambush_controller'
local validate=require 'services.save'.validate
local function write(path,data) local f=assert(io.open(path,'wb'));f:write(json.encode(data));f:close() end
local function read(path) local f=io.open(path,'rb');if not f then return end;local d=f:read('*a');f:close();return json.decode(d) end
function init(self)
 window.set_size(1280,720)
 self.snapshot=model.new(1848,'discovery');self.page='trail';self.buttons={};self.animated={};self.focus=1;self.time=0;self.has_focus=true;self.speed=1;self.battle_actions={};self.battle_team={};self.combat_paused=true;self.combat_speed=1
 self.toast='S10 rendered walkthrough / isolated test state'
 self.redraw=function() self.needs_draw=true end
 self.reset_clock=function() end
 self.save_now=function() assert(validate(self.snapshot)) end
 self.road_writer=function(p) assert(validate(p));return true end
 self.practice_writer=self.road_writer
 self.perform=function(id,args,page)
  assert(model.command(self.snapshot,id,args));self.page=page or self.page;self.speed=self.snapshot.settings.travel_speed or 1
  if id=='choice' or id=='battle_back' or id=='new' then self.battle_team={} end
  if id=='new' then self.ambush=nil end
  if self.snapshot.run.mode=='result' then self.page='trail' end
  self.save_now();self.redraw()
 end
 self.open_page=function(page)
  if self.page=='ambush' then controller.pause(self) end
  if self.snapshot.run.mode=='traveling' then assert(model.command(self.snapshot,'pause')) end
  self.page=page;self.redraw()
 end
 self.toggle_combat=function() self.combat_paused=not self.combat_paused;self.redraw() end
 screens.draw(self)
 self.last=0;self.settle=4;self.request={id=0,name='start'}
end
local function act(self,a)
 if a.click then
  local found=false
  for _,b in ipairs(self.buttons) do if b.key==a.click then assert(b.enabled,'Disabled: '..a.click);b.fn();found=true;break end end
  assert(found,'Missing button: '..a.click)
 elseif a.day then assert(self.page=='trail' and self.snapshot.run.mode=='traveling');self.perform('step')
 elseif a.seconds then
  assert(self.page=='ambush' and self.ambush)
  for _=1,math.floor(a.seconds*10) do controller.update(self,0.1);self.time=self.time+0.1 end
 elseif a.resume_snapshot then
  self.snapshot=read(a.resume_snapshot);assert(validate(self.snapshot));self.ambush=nil;self.page='trail';self.redraw()
 elseif a.new_profile then
  self.snapshot=model.new(a.seed or 1848,'discovery');self.ambush=nil;self.page='trail';self.redraw()
 elseif a.exit then msg.post('@system:','exit',{code=0})
 else error('Unknown action') end
 assert(validate(self.snapshot))
end
function update(self,dt)
 if self.pending then return end
 local ok,err=pcall(function()
  if self.request then
   if self.settle>0 then self.settle=self.settle-1;return end
   self.pending=true
   local req=self.request
   screenshot.png(function(_,png,w,h)
    local f=assert(io.open(req.name..'.png','wb'));f:write(png);f:close()
    local buttons={};for _,b in ipairs(self.buttons) do buttons[#buttons+1]={key=b.key,label=gui.get_text(b.label),enabled=b.enabled} end
    write(req.name..'-state.json',self.snapshot)
    write('response.json',{id=req.id,name=req.name,width=w,height=h,page=self.page,buttons=buttons,snapshot=self.snapshot,ambush=self.ambush and {battle=self.ambush.battle,paused=self.ambush.paused,speed=self.ambush.speed} or nil})
    self.pending=false;self.request=nil
   end)
  else
   local req=read('request.json')
   if req and req.id>self.last then self.last=req.id;self.request=req;act(self,req.action);self.settle=4 end
  end
  if self.needs_draw then screens.draw(self);scene.update(self,self.time,false,self.snapshot.settings.motion);self.needs_draw=false end
 end)
 if not ok then write('response.json',{id=self.last,error=tostring(err)});self.request=nil;self.pending=false end
end
