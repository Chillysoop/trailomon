-- Journey-versioned recovery. Existing saves keep their original daily costs.
local M={RULES="camp-v2"}
function M.values(s)
    if s.recovery_rules==M.RULES then return 40,20 end
    return 25,8
end
function M.repair_rests(s) return s.recovery_rules==M.RULES end
function M.valid(s) return s.recovery_rules==nil or s.recovery_rules==M.RULES end
return M
