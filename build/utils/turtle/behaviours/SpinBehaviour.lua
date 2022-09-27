--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
local ____TurtleBehaviour = require("utils.turtle.behaviours.TurtleBehaviour")
local TurtleBehaviourBase = ____TurtleBehaviour.TurtleBehaviourBase
____exports.SpinBehaviour = __TS__Class()
local SpinBehaviour = ____exports.SpinBehaviour
SpinBehaviour.name = "SpinBehaviour"
__TS__ClassExtends(SpinBehaviour, TurtleBehaviourBase)
function SpinBehaviour.prototype.____constructor(self, duration)
    if duration == nil then
        duration = 5
    end
    TurtleBehaviourBase.prototype.____constructor(self)
    self.duration = duration
    self.priority = 1
    self.name = "spinning"
    self.endTime = 0
    Logger:info(("Spinning for " .. tostring(self.duration)) .. " seconds")
end
function SpinBehaviour.prototype.onStart(self)
    self.endTime = os.epoch("utc") + self.duration * 1000
end
function SpinBehaviour.prototype.step(self)
    if os.epoch("utc") > self.endTime then
        return true
    end
    TurtleController:turnLeft()
end
return ____exports
