--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____PathfinderBehaviour = require("utils.turtle.behaviours.PathfinderBehaviour")
local PathfinderBehaviour = ____PathfinderBehaviour.PathfinderBehaviour
____exports.RefuelBehaviour = __TS__Class()
local RefuelBehaviour = ____exports.RefuelBehaviour
RefuelBehaviour.name = "RefuelBehaviour"
function RefuelBehaviour.prototype.____constructor(self)
    self.name = "refueling"
    self.priority = 10000
end
function RefuelBehaviour.prototype.step(self)
    local targetPos = {0, 0, 0}
    local arrived = __TS__New(PathfinderBehaviour, targetPos):step()
    if arrived then
        return true
    end
end
return ____exports
