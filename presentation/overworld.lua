local w=require "ui.widgets"
local map=require "presentation.route_map"
local motion=require "presentation.journey_motion"
local M={}
local function line(self,a,b,width,color)
    local dx,dy=b.x-a.x,b.y-a.y
    local n=w.rect(self,(a.x+b.x)/2-math.sqrt(dx*dx+dy*dy)/2,(a.y+b.y)/2-width/2,math.sqrt(dx*dx+dy*dy),width,color)
    gui.set_rotation(n,vmath.quat_rotation_z(math.atan2(dy,dx)))
end
local function center(self,x,y,text,size,color)
    local n=w.text(self,x,y,text,size,color);gui.set_pivot(n,gui.PIVOT_CENTER);return n
end
function M.draw(self,x,y,width,height)
    local s=self.snapshot.run;local sx,sy=width/1000,height/330
    local function point(p) return {x=x+p.x*sx,y=y+p.y*sy} end
    local function rect(a,b,c,d,color) return w.rect(self,x+a*sx,y+b*sy,c*sx,d*sy,color) end
    rect(0,0,1000,330,"314d3d")
    -- Field banks, woodland and upland contours: a place, not a graph on a panel.
    for _,v in ipairs({{0,0,300,95,"456045"},{0,95,180,65,"3e5940"},{180,0,340,44,"3e5940"},
        {260,199,233,131,"294838"},{300,175,165,24,"294838"},{485,0,210,70,"3a5746"},
        {695,0,305,330,"4e5e4d"},{720,222,280,108,"566351"},{805,260,195,70,"626b58"}}) do rect(unpack(v)) end
    -- A winding river crosses the road at Willowford.
    local river={{x=565,y=330},{x=578,y=276},{x=610,y=234},{x=602,y=178},{x=561,y=123},{x=578,y=68},{x=549,y=0}}
    for i=2,#river do
        line(self,point(river[i-1]),point(river[i]),18*sx,"486f69")
        line(self,point(river[i-1]),point(river[i]),9*sx,"73968a")
    end
    local function tree(a,b,size)
        rect(a-1,b,3,size*.45,"7d7050");rect(a-size*.38,b+size*.3,size*.76,size*.22,"203c30")
        rect(a-size*.27,b+size*.52,size*.54,size*.24,"3c6349");rect(a-size*.15,b+size*.76,size*.3,size*.18,"63825a")
    end
    for i=1,26 do tree(270+(i*43)%211,187+(i*29)%109,15+i%4*3) end
    for _,v in ipairs({{33,180,20},{78,198,28},{121,173,21},{161,227,24},{62,276,19},{184,61,19},{403,32,16},{505,154,24},{668,88,15}}) do tree(unpack(v)) end
    for i=1,8 do
        local a=716+(i*43)%263;local b=32+(i*61)%260
        rect(a,b,31,5,"3e4e46");rect(a+4,b+5,23,8,"74816a");rect(a+9,b+13,13,8,"8e9679");rect(a+12,b+21,7,5,"c1bca0")
    end
    for i=1,18 do rect(24+(i*131)%650,20+(i*43)%145,9,2,"66805a") end
    center(self,x+94*sx,y+28*sy,"FERNWAKE FIELDS",10,"adbc9f")
    center(self,x+378*sx,y+311*sy,"BELLWOOD",10,"adbc9f")
    center(self,x+800*sx,y+25*sy,"THE HIGH COUNTRY",10,"c1c4aa")
    local function road(target,branch)
        local points=map.path(target,branch)
        local selected=not branch or map.branch(s,target)==branch
        local passed=target<s.target or (target==s.target and s.progress>=s.distance)
        for i=2,#points do
            local a,b=point(points[i-1]),point(points[i])
            line(self,a,b,9,"263d32")
            line(self,a,b,selected and 4 or 2,selected and (passed and "d6bc7b" or "a5a486") or "708370")
            if not selected then
                for j=1,5 do local f=j/6;w.rect(self,a.x+(b.x-a.x)*f-2,a.y+(b.y-a.y)*f-2,4,4,"a5ae91") end
            end
        end
    end
    road(2);road(3,"meadow");road(3,"woodland");road(4);road(5);road(6,"ridge");road(6,"gorge")
    -- Small landmark silhouettes distinguish services before reading their names.
    for i,p in ipairs(map.places) do
        local q=point(p)
        if i==1 or i==3 or i==6 then
            w.rect(self,q.x-14,q.y+5,28,19,i==6 and "a79773" or "b69d70")
            w.rect(self,q.x-19,q.y+24,38,5,"574838");w.rect(self,q.x-13,q.y+29,26,5,"866746")
            w.rect(self,q.x-7,q.y+34,14,4,"a87f50");w.rect(self,q.x-3,q.y+5,7,13,"435441")
            w.rect(self,q.x+6,q.y+15,5,6,i==6 and "e8c47e" or "64765a")
        elseif i==2 then tree(p.x,p.y+8,44)
        elseif i==4 then
            w.rect(self,q.x-25,q.y+4,50,7,"b7a075");w.rect(self,q.x-22,q.y,4,17,"594d39");w.rect(self,q.x+18,q.y,4,17,"594d39")
        else
            for j=0,2 do w.rect(self,q.x-13+j*4,q.y+5+j*8,26-j*8,8,"a4a88a") end
        end
        local reached=map.reached(s,i);local is_here=i==s.target and s.progress>=s.distance
        local n=w.button(self,q.x-16,q.y-15,32,30,"",function()
            if s.mode=="traveling" then self.perform("pause") end
            self.map_detail=self.map_detail==i and nil or i;self.redraw()
        end,{key="map_"..p.id,size=10,selected=is_here})
        w.icon(self,q.x-12,q.y-12,p.icon,24)
        center(self,q.x,q.y-27,p.name,width<900 and 11 or 13,reached and "ink" or "d3d6bd")
        if p.note then center(self,q.x,q.y-43,p.note,10,w.tint(p.icon)) end
        if is_here then w.rect(self,q.x-17,q.y-18,34,2,"gold") end
    end
    for _,id in ipairs({"meadow","woodland","ridge","gorge"}) do
        local p=map.branches[id];local q=point(p);local option
        for _,v in ipairs(map.options(s)) do if v.id==id then option=v end end
        local chosen=map.branch(s,p.target+1)==id
        if option and not self.journey_motion then
            w.button(self,q.x-42,q.y-12,84,26,p.name,function() self.map_detail=nil;self.perform("leave",{branch=id},"trail") end,
                {key=option.label,size=12,primary=true})
            center(self,q.x,q.y-25,option.distance.." km",11,"ink")
        else
            w.rect(self,q.x-3,q.y-3,6,6,chosen and "gold" or "adbc9f")
            center(self,q.x,q.y-16,p.name,10,chosen and "ink" or "adbc9f")
        end
    end
    local at=motion.position(self);local q=point(at)
    local destination=point(map.position(s))
    local encounter=s.mode=="event" and s.pending
    if encounter then
        local def=require("simulation.events").by_id[s.pending.id]
        local creature
        for _,c in ipairs(def.choices) do creature=creature or c.observe or c.recruit end
        creature=creature or (def.id=="scavengers" and "loamling" or def.id=="territorial" and "slatewhorl")
        if type(creature)=="string" then w.sprite(self,creature,destination.x+53,destination.y+25,56) end
        w.icon(self,destination.x+29,destination.y+48,def.kind=="encounter" and "pressure" or "scout",24)
    end
    -- Put companions and wagon on the chosen path, not in a disconnected vignette.
    local group=gui.new_box_node(vmath.vector3(q.x,q.y+13,0),vmath.vector3());gui.set_parent(group,self.root,false)
    local parent=self.root;self.root=group
    local wagon,wheels=require("presentation.wagon_prop").draw(self,0,0,s.wagon_type,.57)
    for i,c in ipairs(s.crew) do
        local haul=i==s.hauler;local px=haul and 70 or -36-((i-1)%2)*26
        px=math.min(px,x+width-destination.x-30)
        local py=c.species=="bellmoth" and 43 or (not haul and i>2 and 31 or 10)
        local node=w.sprite(self,c.species,px,py,haul and 58 or 43,c.condition<=0)
        self.animated[#self.animated+1]={node=node,x=px,y=py,phase=i*1.7,fly=c.species=="bellmoth",map_crew=true}
    end
    self.root=parent
    self.map_actor={node=group,wheels=wheels,x=x,y=y,sx=sx,sy=sy}
    return group
end
function M.update(self,time,enabled)
    local actor=self.map_actor;if not actor then return end
    local p=motion.position(self)
    local rolling=self.journey_motion~=nil and self.has_focus~=false and self.page=="trail"
    local bob=enabled and rolling and math.sin(time*16)*.65 or 0
    gui.set_position(actor.node,vmath.vector3(actor.x+p.x*actor.sx,actor.y+p.y*actor.sy+13+bob,0))
    if enabled and rolling then for _,wheel in ipairs(actor.wheels) do gui.set_rotation(wheel,vmath.quat_rotation_z(-time*3)) end end
end
return M
