--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____refuel = require("utils.turtle.routines.refuel")
local refuel = ____refuel.refuel
local CHECK_FUEL_INTERVAL = 10
local MIN_FUEL_RATIO = 0.2
local TurtleReason = TurtleReason or ({})
TurtleReason.OUT_OF_FUEL = "Out of fuel"
____exports.TurtleEvent = TurtleEvent or ({})
____exports.TurtleEvent.moved = "moved"
____exports.TurtleEvent.moved_up = "moved:up"
____exports.TurtleEvent.moved_down = "moved:down"
____exports.TurtleEvent.moved_back = "moved:back"
____exports.TurtleEvent.moved_forward = "moved:forward"
____exports.TurtleEvent.turned = "turned"
____exports.TurtleEvent.turned_left = "turned:left"
____exports.TurtleEvent.turned_right = "turned:right"
____exports.TurtleEvent.out_of_fuel = "out_of_fuel"
____exports.TurtleEvent.check_fuel = "check_fuel"
____exports.TurtleEvent.dig = "dig"
____exports.TurtleEvent.dig_forward = "dig:forward"
____exports.TurtleEvent.dig_up = "dig:up"
____exports.TurtleEvent.dig_down = "dig:down"
EventLoop:on(
    ____exports.TurtleEvent.out_of_fuel,
    function()
        print("OH NO WE ARE OUT OF FUEL. THIS IS FROM AN EVENT.")
        return false
    end
)
local __TurtleController__ = __TS__Class()
__TurtleController__.name = "__TurtleController__"
function __TurtleController__.prototype.____constructor(self)
    self.registered = false
end
function __TurtleController__.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "TurtleController is already registered"),
            0
        )
    end
    self.registered = true
    EventLoop:emitRepeat(____exports.TurtleEvent.check_fuel, CHECK_FUEL_INTERVAL)
    EventLoop:on(
        ____exports.TurtleEvent.check_fuel,
        function()
            self:checkFuel()
            return false
        end
    )
    self:checkFuel()
end
function __TurtleController__.prototype.checkFuel(self)
    print("Check fuel called")
    local fuelLevel = turtle.getFuelLevel()
    local fuelLimit = turtle.getFuelLimit()
    if fuelLevel == "unlimited" or fuelLimit == "unlimited" then
        return
    end
    if fuelLevel / fuelLimit < MIN_FUEL_RATIO then
        local success = refuel(nil)
        if not success then
            print("Failed to refuel")
        end
    end
end
function __TurtleController__.prototype.checkActionResult(self, assertSuccess, ____bindingPattern0)
    local reason
    local success
    success = ____bindingPattern0[1]
    reason = ____bindingPattern0[2]
    if not success then
        if reason == TurtleReason.OUT_OF_FUEL then
            EventLoop:emit(____exports.TurtleEvent.out_of_fuel)
        end
        if assertSuccess then
            error(
                __TS__New(
                    Error,
                    "Failed to move, reason: " .. tostring(reason)
                ),
                0
            )
        end
    end
    return success
end
function __TurtleController__.prototype.move(self, direction, n, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    local success = false
    local i
    do
        i = 0
        while i < n do
            success = self:checkActionResult(
                assertSuccess,
                {turtle[direction]()}
            )
            if not success then
                break
            else
                EventLoop:emit(____exports.TurtleEvent.moved, direction)
                EventLoop:emit("moved:" .. direction, direction)
            end
            i = i + 1
        end
    end
    return success
end
function __TurtleController__.prototype.turn(self, direction, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    local success = self:checkActionResult(
        assertSuccess,
        {turtle[direction == "left" and "turnLeft" or "turnRight"]()}
    )
    if success then
        EventLoop:emit(____exports.TurtleEvent.turned, direction)
        EventLoop:emit("turned:" .. direction, direction)
    end
    return success
end
function __TurtleController__.prototype._dig(self, direction, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    local success = self:checkActionResult(
        assertSuccess,
        {turtle[direction == "forward" and "dig" or (direction == "up" and "digUp" or "digDown")]()}
    )
    if success then
        EventLoop:emit(____exports.TurtleEvent.dig, direction)
        EventLoop:emit("dig:" .. direction, direction)
    end
    return success
end
function __TurtleController__.prototype._place(self, direction, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    local success = self:checkActionResult(
        assertSuccess,
        {turtle[direction == "forward" and "place" or (direction == "up" and "placeUp" or "placeDown")]()}
    )
    if success then
        EventLoop:emit(____exports.TurtleEvent.dig, direction)
        EventLoop:emit("dig:" .. direction, direction)
    end
    return success
end
function __TurtleController__.prototype.forward(self, n, assertSuccess)
    if n == nil then
        n = 1
    end
    if assertSuccess == nil then
        assertSuccess = true
    end
    if type(n) == "string" then
        n = __TS__ParseInt(n)
    end
    return self:move("forward", n, assertSuccess)
end
function __TurtleController__.prototype.back(self, n, assertSuccess)
    if n == nil then
        n = 1
    end
    if assertSuccess == nil then
        assertSuccess = true
    end
    if type(n) == "string" then
        n = __TS__ParseInt(n)
    end
    return self:move("back", n, assertSuccess)
end
function __TurtleController__.prototype.up(self, n, assertSuccess)
    if n == nil then
        n = 1
    end
    if assertSuccess == nil then
        assertSuccess = true
    end
    if type(n) == "string" then
        n = __TS__ParseInt(n)
    end
    return self:move("up", n, assertSuccess)
end
function __TurtleController__.prototype.down(self, n, assertSuccess)
    if n == nil then
        n = 1
    end
    if assertSuccess == nil then
        assertSuccess = true
    end
    if type(n) == "string" then
        n = __TS__ParseInt(n)
    end
    return self:move("down", n, assertSuccess)
end
function __TurtleController__.prototype.turnLeft(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:turn("left", assertSuccess)
end
function __TurtleController__.prototype.turnRight(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:turn("right", assertSuccess)
end
function __TurtleController__.prototype.dig(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:_dig("forward", assertSuccess)
end
function __TurtleController__.prototype.digUp(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:_dig("up", assertSuccess)
end
function __TurtleController__.prototype.digDown(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:_dig("down", assertSuccess)
end
function __TurtleController__.prototype.place(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:_place("forward", assertSuccess)
end
function __TurtleController__.prototype.placeUp(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:_place("up", assertSuccess)
end
function __TurtleController__.prototype.placeDown(self, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    return self:_place("down", assertSuccess)
end
____exports.TurtleController = __TS__New(__TurtleController__)
return ____exports
