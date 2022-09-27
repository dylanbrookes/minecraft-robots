--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____FuelMonitor = require("utils.turtle.FuelMonitor")
local FuelMonitor = ____FuelMonitor.default
local FuelStatus = ____FuelMonitor.FuelStatus
local ____createInvSpace = require("utils.turtle.routines.createInvSpace")
local createInvSpace = ____createInvSpace.createInvSpace
local ____refuel = require("utils.turtle.routines.refuel")
local refuel = ____refuel.refuel
local ____ResupplyBehaviour = require("utils.turtle.behaviours.ResupplyBehaviour")
local ResupplyBehaviour = ____ResupplyBehaviour.ResupplyBehaviour
local ____TurtleBehaviour = require("utils.turtle.behaviours.TurtleBehaviour")
local TurtleBehaviourBase = ____TurtleBehaviour.TurtleBehaviourBase
____exports.RefuelBehaviour = __TS__Class()
local RefuelBehaviour = ____exports.RefuelBehaviour
RefuelBehaviour.name = "RefuelBehaviour"
__TS__ClassExtends(RefuelBehaviour, TurtleBehaviourBase)
function RefuelBehaviour.prototype.____constructor(self, ...)
    TurtleBehaviourBase.prototype.____constructor(self, ...)
    self.name = "refueling"
    self.priority = 10000
    self.resupplyBehaviour = __TS__New(ResupplyBehaviour, {"fuel"})
    self.stepn = 0
end
function RefuelBehaviour.prototype.step(self)
    if FuelMonitor.fuelStatus == FuelStatus.OK then
        Logger:info("Cancelled refuel behaviour, fuel status is OK")
        return true
    end
    if self.stepn % ____exports.RefuelBehaviour.RESCAN_STEP_INTERVAL == 0 or FuelMonitor.fuelStatus == FuelStatus.LOW and self.resupplyBehaviour:step() then
        Logger:info("Trying to refuel")
        local refuelled = refuel(nil)
        if refuelled then
            Logger:info("Refuel success")
            return FuelMonitor:checkFuel() == FuelStatus.OK
        end
    end
    if self.stepn == 0 then
        createInvSpace(nil)
    end
    self.stepn = self.stepn + 1
end
RefuelBehaviour.RESCAN_STEP_INTERVAL = 20 * 10
return ____exports
