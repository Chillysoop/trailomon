-- Original sample kits. Combat purpose is independent of any species type.
local M={}
M.kits={
    moss={species="brindlehorn",name="Moss",hp=116,def=45,attack=10,interval=22,cost=55,
        skill="Antler brace",active="Shield self 22 + wagon 8",passive="Rooted: +55 DEF in front"},
    ember={species="cindercoil",name="Ember",hp=82,def=8,attack=11,interval=15,cost=50,
        skill="Heat spill",active="Strike target for 26",passive="Follow ally intercepts; faster in front"},
    lumen={species="bellmoth",name="Lumen",hp=68,def=5,attack=6,interval=18,cost=40,
        skill="Dusk shimmer",active="Hit + stun the caller for 1.4s",passive="On stun: lowest ally gets 6 Focus"},
    raider={species="loamling",name="Root raider",hp=184,def=15,attack=16,interval=24,cost=70,
        skill="Grain rush",active="26 damage toward wagon / intercepted",passive="Raider: lane 1, front can intercept"},
    caller={species="bellmoth",name="Ridge caller",hp=108,def=10,attack=7,interval=19,cost=45,
        skill="Rattle",active="Hit + slow defender for 3s",passive="Targets exposed crew"},
}
M.presets={
    guard={label="Guard the lane",positions={moss=1,ember=3,lumen=4}},
    rush={label="Race the raid",positions={moss=3,ember=2,lumen=4}},
}
-- 1/2: front lanes 1/2. 3/4: rear lanes 1/2.
M.positions={"Front 1","Front 2","Rear 1","Rear 2"}
return M
