-- Original two-pixel-grid wagon. One root moves the entire vehicle on the road.
local w=require 'ui.widgets'
local M={}
function M.draw(self,wx,wy,kind,scale)
    local parent=self.root
    local root=gui.new_box_node(vmath.vector3(wx,wy,0),vmath.vector3())
    gui.set_parent(root,parent,false);gui.set_scale(root,vmath.vector3(scale or 1,scale or 1,1));self.root=root
    local function r(x,y,a,b,c) return w.rect(self,x,y,a,b,c) end
    local outline='302d29';local shade='604132';local wood='96613e';local light='c38d51'
    r(-57,-14,113,8,'263b32');r(-50,-10,101,10,'344736')
    r(-43,0,88,10,outline);r(40,9,61,6,outline);r(42,13,59,3,light)
    r(45,7,51,2,shade);r(-52,12,103,42,outline);r(-48,16,95,34,shade)
    for i=0,3 do
        r(-46,18+i*8,90,6,i%2==0 and wood or 'a57046')
        r(-44,23+i*8,86,1,light)
    end
    r(-49,44,95,5,'d3a266');r(-49,49,96,3,outline)
    r(-49,12,97,5,light);r(-47,14,92,2,'e0b578')
    for _,p in ipairs({{-32,20,14},{-8,28,18},{14,36,12},{-35,36,10},{17,20,18}}) do r(p[1],p[2],p[3],1,shade) end
    for _,x in ipairs({-41,28}) do
        r(x,15,5,32,'434a43');r(x+1,17,2,28,'909889')
        for _,y in ipairs({19,36,43}) do r(x+1,y,2,2,'d0c5a5') end
    end
    if kind=='covered' then
        r(-46,51,84,36,outline);r(-40,87,72,8,outline);r(-30,95,52,6,outline)
        r(-44,53,80,30,'b9a37c');r(-38,83,68,10,'dfc99b');r(-28,93,48,6,'f0dfb2')
        r(-36,55,58,28,'e4cfa2');r(-28,84,44,8,'f4e1b7')
        r(-33,57,3,31,'f4e1b7');r(-6,55,3,37,'b6a079');r(18,55,3,29,'b6a079')
        r(26,54,8,25,'806d54');r(28,56,8,19,'4e463a');r(-43,52,77,3,'8e7657')
    else
        -- Low hoops, folded canvas, tied sack and living orchard cuttings.
        r(-42,52,4,29,'6c5a43');r(-40,79,5,3,light);r(-35,81,12,3,light)
        r(-23,78,5,4,light);r(-20,52,4,27,'6c5a43')
        r(-47,51,31,8,'c7b28a');r(-44,59,25,5,'ebd8ac');r(-40,51,3,12,'7c6f54')
        r(-16,52,24,17,outline);r(-14,53,20,13,'b7a16e');r(-11,66,14,5,'ddca90')
        r(-9,70,10,3,'b7a16e');r(-8,69,11,2,'6d6146');r(-13,56,3,8,'decb96')
        r(7,51,28,18,'534835');r(9,54,24,14,'b18a4d');r(9,62,24,2,'e0b578')
        r(14,53,3,14,'755a38');r(28,53,3,14,'755a38')
        r(17,68,2,16,'a0ad69');r(24,68,2,23,'a0ad69')
        r(11,75,7,4,'6c985d');r(18,81,8,5,'bdd184');r(25,86,8,4,'799e60')
        r(12,77,4,2,'bed18b');r(26,89,5,2,'b8cf86')
    end
    local wheels={}
    for _,x in ipairs({-29,29}) do
        r(x-14,-10,28,28,outline);r(x-18,-4,36,16,outline)
        r(x-12,-10,24,28,'805736');r(x-16,-2,32,12,'a27443')
        r(x-10,-6,20,20,'d0a566');r(x-12,-2,24,12,'d0a566')
        r(x-8,-4,16,16,'493d30');r(x-10,0,20,8,'493d30')
        local hub=gui.new_box_node(vmath.vector3(x,4,0),vmath.vector3());gui.set_parent(hub,root,false)
        self.root=hub;r(-1,-10,3,20,light);r(-10,-1,20,3,light)
        r(-3,-3,7,7,'e0bb7e');r(-1,-1,3,3,'605e50');self.root=root
        r(x-8,15,16,2,'e6c38a');r(x-15,8,2,6,'d0aa6c');wheels[#wheels+1]=hub
    end
    r(36,49,12,6,outline);r(37,54,11,15,'44695d');r(39,56,4,12,'6e9380')
    r(39,69,8,9,'c08e62');r(41,72,5,6,'dfb686')
    r(35,77,17,3,'5a4a35');r(39,80,9,5,'a1814e');r(38,78,12,2,'cfac72')
    r(45,51,7,3,'7d5d40');r(49,27,8,17,outline);r(51,30,4,10,'e4ba65')
    r(52,33,2,5,'ffdf95');r(50,43,6,2,'bca26c')
    self.root=parent
    return root,wheels
end
return M
