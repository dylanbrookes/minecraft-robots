--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____LocationMonitor = require("utils.LocationMonitor")
local LocationMonitor = ____LocationMonitor.LocationMonitor
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local serializePosition = ____Consts.serializePosition
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
local ____PathfinderBehaviour = require("utils.turtle.behaviours.PathfinderBehaviour")
local PathfinderBehaviour = ____PathfinderBehaviour.PathfinderBehaviour
local ____TurtleBehaviour = require("utils.turtle.behaviours.TurtleBehaviour")
local TurtleBehaviourBase = ____TurtleBehaviour.TurtleBehaviourBase
local TurtleBehaviourStatus = ____TurtleBehaviour.TurtleBehaviourStatus
local function clearCol(self, breakForward, height, up)
    if up == nil then
        up = true
    end
    do
        local i = 0
        while i < height - 1 do
            if breakForward then
                TurtleController:dig(false)
            end
            TurtleController[up and "digUp" or "digDown"](TurtleController, false)
            TurtleController[up and "up" or "down"](TurtleController)
            i = i + 1
        end
    end
end
local function breakAndMove(self)
    TurtleController:dig(false)
    while not TurtleController:forward(1, false) do
        print("Could not move, waiting 5 seconds...")
        sleep(5)
    end
end
____exports.ClearBehaviour = __TS__Class()
local ClearBehaviour = ____exports.ClearBehaviour
ClearBehaviour.name = "ClearBehaviour"
__TS__ClassExtends(ClearBehaviour, TurtleBehaviourBase)
function ClearBehaviour.prototype.____constructor(self, startPosition, startHeading, dimensions)
    TurtleBehaviourBase.prototype.____constructor(self)
    self.startPosition = startPosition
    self.startHeading = startHeading
    self.dimensions = dimensions
    self.priority = 1
    self.name = "clearing"
    self.pausedPosition = nil
    self.x = 0
    self.y = 0
    local w, d, h = table.unpack(dimensions)
    Logger:info((((((("Moving to " .. serializePosition(nil, startPosition)) .. " and clearing w=") .. tostring(w)) .. " d=") .. tostring(d)) .. " h=") .. tostring(h))
    self.startPathfinder = __TS__New(PathfinderBehaviour, startPosition)
end
__TS__SetDescriptor(
    ClearBehaviour.prototype,
    "w",
    {get = function(self)
        return self.dimensions[1]
    end},
    true
)
__TS__SetDescriptor(
    ClearBehaviour.prototype,
    "d",
    {get = function(self)
        return self.dimensions[2]
    end},
    true
)
__TS__SetDescriptor(
    ClearBehaviour.prototype,
    "h",
    {get = function(self)
        return self.dimensions[3]
    end},
    true
)
function ClearBehaviour.prototype.onResume(self)
    self.startPathfinder = __TS__New(PathfinderBehaviour, self.pausedPosition or self.startPosition)
end
function ClearBehaviour.prototype.onPause(self)
    if self.startPathfinder.status == TurtleBehaviourStatus.DONE then
        self.pausedPosition = LocationMonitor.position
        self.startHeading = LocationMonitor.heading
    end
end
function ClearBehaviour.prototype.step(self)
    if self.startPathfinder.status ~= TurtleBehaviourStatus.DONE then
        if self.startPathfinder.status == TurtleBehaviourStatus.INIT then
            self.startPathfinder.status = TurtleBehaviourStatus.RUNNING
        end
        local done = self.startPathfinder:step()
        if done then
            self.startPathfinder.status = TurtleBehaviourStatus.DONE
            TurtleController:rotate(self.startHeading)
        end
        return
    end
    if self.x < self.w then
        local lastRow = self.x + 1 == self.w
        Logger:info((("Clearing column " .. tostring(self.x)) .. ", ") .. tostring(self.y))
        local lastCol = self.y + 1 == self.d
        if lastCol then
            if self.x % 2 == 0 then
                TurtleController:turnRight()
            else
                TurtleController:turnLeft()
            end
        end
        if (self.x * self.d + self.y) % 2 == 0 then
            clearCol(
                nil,
                not (lastCol and lastRow),
                self.h,
                bit32.arshift(self.x * self.d + self.y, 1) % 2 == 0
            )
        end
        if not (lastCol and lastRow) then
            breakAndMove(nil)
        end
        self.y = self.y + 1
        if self.y == self.d then
            if not lastRow then
                if self.x % 2 == 0 then
                    TurtleController:turnRight()
                else
                    TurtleController:turnLeft()
                end
            end
            self.x = self.x + 1
            self.y = 0
        end
        return
    end
    Logger:info("Done clearing")
    return true
end
return ____exports
