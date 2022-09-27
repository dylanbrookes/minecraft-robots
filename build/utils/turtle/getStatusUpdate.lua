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
    local ____BehaviourStack_peek_result_name_0 = BehaviourStack:peek()
    if ____BehaviourStack_peek_result_name_0 ~= nil then
        ____BehaviourStack_peek_result_name_0 = ____BehaviourStack_peek_result_name_0.name
    end
    return {location = ____temp_2, status = ____temp_3, currentBehaviour = ____BehaviourStack_peek_result_name_0 or ""}
end
return ____exports
