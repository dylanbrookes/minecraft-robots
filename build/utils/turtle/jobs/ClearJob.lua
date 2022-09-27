--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____ClearBehaviour = require("utils.turtle.behaviours.ClearBehaviour")
local ClearBehaviour = ____ClearBehaviour.ClearBehaviour
local ____Consts = require("utils.turtle.Consts")
local cartesianDistance = ____Consts.cartesianDistance
local ClearJob = {
    BehaviourConstructor = ClearBehaviour,
    turtleFitness = function(self, turtleRecord)
        if not turtleRecord.location then
            return 0
        end
        local startPosition = table.unpack(self.record.args)
        return 1 / cartesianDistance(nil, startPosition, turtleRecord.location)
    end
}
____exports.default = ClearJob
return ____exports
