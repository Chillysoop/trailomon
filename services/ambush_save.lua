-- Separate checkpoint: this prototype never writes an expedition snapshot.
local battle=require "simulation.wagon_combat"
local M={}
function M.path()
    return sys.get_save_file(sys.get_config_string("trailomon.save_namespace","trailomon"),"wagon_ambush_v1")
end
function M.validate(v)
    if type(v)~="table" or (v.speed~=1 and v.speed~=2) or type(v.carry)~="number" or v.carry~=v.carry or v.carry<0 or v.carry>=battle.TICK then return false,"Invalid playback" end
    return battle.validate(v.battle)
end
function M.load()
    local path=M.path();local exists=io.open(path,"rb");local primary_exists=exists~=nil
    if exists then exists:close() end
    local ok,data=pcall(sys.load,path)
    if ok and M.validate(data) then return data end
    local backup_ok,backup=pcall(sys.load,path..".backup")
    if backup_ok and M.validate(backup) then return backup,"Recovered previous ambush checkpoint" end
    if not primary_exists then return nil end
    return nil,"Unreadable checkpoint; starting a sample replaces it"
end
function M.write(v)
    local valid,why=M.validate(v);if not valid then return false,why end
    local path=M.path();local ok,old=pcall(sys.load,path)
    if ok and M.validate(old) then
        local wrote,result=pcall(sys.save,path..".backup",old)
        if not wrote or not result then return false,"Ambush backup failed" end
    end
    local wrote,result=pcall(sys.save,path,v)
    return wrote and result or false,"Ambush save failed"
end
return M
