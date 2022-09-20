--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____LocationMonitor = require("utils.LocationMonitor")
local Heading = ____LocationMonitor.Heading
local HEADING_TO_XZ_VEC = ____LocationMonitor.HEADING_TO_XZ_VEC
local LocationMonitor = ____LocationMonitor.LocationMonitor
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
____exports.PathfinderBehaviour = __TS__Class()
local PathfinderBehaviour = ____exports.PathfinderBehaviour
PathfinderBehaviour.name = "PathfinderBehaviour"
function PathfinderBehaviour.prototype.____constructor(self, targetPos, priority)
    if priority == nil then
        priority = 1
    end
    self.targetPos = targetPos
    self.priority = priority
    self.name = "pathfinding"
end
function PathfinderBehaviour.prototype.step(self)
    local currentPos = LocationMonitor.position
    if not currentPos then
        print("Skipping pathfinding, current location status is", LocationMonitor.status)
        return
    end
    local dx = self.targetPos[1] - currentPos[1]
    local dy = self.targetPos[2] - currentPos[2]
    local dz = self.targetPos[3] - currentPos[3]
    if dy ~= 0 then
        local n = math.abs(dy)
        local ____temp_0
        if dy > 0 then
            ____temp_0 = TurtleController:up(n)
        else
            ____temp_0 = TurtleController:down(n)
        end
    elseif dx ~= 0 or dz ~= 0 then
        print("Gonna move forward")
        if LocationMonitor.heading == Heading.UNKNOWN then
            local success = TurtleController:forward(1, false)
            if not success then
                TurtleController:turnLeft()
            end
            return
        end
        local xx, zz = __TS__Unpack(HEADING_TO_XZ_VEC[LocationMonitor.heading])
        local xOk = xx * dx > 0
        local zOk = zz * dz > 0
        if xOk then
            TurtleController:forward(math.abs(dx))
        elseif zOk then
            TurtleController:forward(math.abs(dz))
        else
            TurtleController:turnLeft()
        end
    else
        return true
    end
end
return ____exports
