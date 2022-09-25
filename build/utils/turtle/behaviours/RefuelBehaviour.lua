--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____NaivePathfinderBehaviour = require("utils.turtle.behaviours.NaivePathfinderBehaviour")
local NaivePathfinderBehaviour = ____NaivePathfinderBehaviour.NaivePathfinderBehaviour
____exports.RefuelBehaviour = __TS__Class()
local RefuelBehaviour = ____exports.RefuelBehaviour
RefuelBehaviour.name = "RefuelBehaviour"
function RefuelBehaviour.prototype.____constructor(self)
    self.name = "refueling"
    self.priority = 10000
end
function RefuelBehaviour.prototype.step(self)
    local targetPos = {0, 0, 0}
    local arrived = __TS__New(NaivePathfinderBehaviour, targetPos):step()
    if arrived then
        return true
    end
end
return ____exports
