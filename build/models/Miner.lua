--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local Direction = Direction or ({})
Direction.left = "left"
Direction.right = "right"
____exports.default = __TS__Class()
local Miner = ____exports.default
Miner.name = "Miner"
function Miner.prototype.____constructor(self)
    self.coordinates = {x = 0, y = 0, z = 0}
end
function Miner.prototype.digLine(self, distance)
    do
        local i = 0
        while i < distance - 1 do
            turtle.refuel()
            if turtle.detect() then
                turtle.dig()
            else
                turtle.forward()
                break
            end
            i = i + 1
        end
    end
end
function Miner.prototype.turn(self, direction)
    if direction == Direction.left then
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
    elseif direction == Direction.right then
        turtle.turnRight()
        turtle.dig()
        turtle.forward()
        turtle.turnRight()
    end
end
____exports.default = Miner
return ____exports
