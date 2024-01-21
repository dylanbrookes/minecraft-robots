--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____LocationMonitor = require("utils.LocationMonitor")
local LocationMonitor = ____LocationMonitor.LocationMonitor
local ____TurtleStore = require("utils.stores.TurtleStore")
local TurtleStatus = ____TurtleStore.TurtleStatus
local ____BehaviourStack = require("utils.turtle.BehaviourStack")
local BehaviourStack = ____BehaviourStack.BehaviourStack
function ____exports.default(self)
    local ____temp_2 = LocationMonitor.position or nil
    local ____temp_3 = BehaviourStack:peek() and TurtleStatus.BUSY or TurtleStatus.IDLE
    local ____opt_0 = BehaviourStack:peek()
    return {location = ____temp_2, status = ____temp_3, currentBehaviour = ____opt_0 and ____opt_0.name or ""}
end
return ____exports
