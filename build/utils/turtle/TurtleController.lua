--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____ItemTags = require("utils.ItemTags")
local inspectHasTags = ____ItemTags.inspectHasTags
local ItemTags = ____ItemTags.ItemTags
local ____LocationMonitor = require("utils.LocationMonitor")
local HEADING_ORDER = ____LocationMonitor.HEADING_ORDER
local LocationMonitor = ____LocationMonitor.LocationMonitor
local LocationMonitorStatus = ____LocationMonitor.LocationMonitorStatus
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local TurtleEvent = ____Consts.TurtleEvent
local TurtleReason = ____Consts.TurtleReason
local __TurtleController__ = __TS__Class()
__TurtleController__.name = "__TurtleController__"
function __TurtleController__.prototype.____constructor(self)
end
function __TurtleController__.prototype.checkActionResult(self, assertSuccess, ____bindingPattern0)
    local reason
    local success
    success = ____bindingPattern0[1]
    reason = ____bindingPattern0[2]
    if not success then
        if reason == TurtleReason.OUT_OF_FUEL then
            EventLoop:emit(TurtleEvent.out_of_fuel)
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
                EventLoop:emit(TurtleEvent.moved, direction)
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
        EventLoop:emit(TurtleEvent.turned, direction)
        EventLoop:emit("turned:" .. direction, direction)
    end
    return success
end
function __TurtleController__.prototype._dig(self, direction, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    local occupied, info = turtle[direction == "forward" and "inspect" or (direction == "up" and "inspectUp" or "inspectDown")]()
    if occupied and inspectHasTags(nil, info, {ItemTags.stella_arcanum, ItemTags.turtle}) then
        local message = "Dig target is " .. tostring(type(info) == "string" and info or info and info.name)
        if assertSuccess then
            error(
                __TS__New(Error, message),
                0
            )
        else
            Logger:error(message)
        end
        return false
    end
    local success = self:checkActionResult(
        assertSuccess,
        {turtle[direction == "forward" and "dig" or (direction == "up" and "digUp" or "digDown")]()}
    )
    if success then
        EventLoop:emit(TurtleEvent.dig, direction)
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
        EventLoop:emit(TurtleEvent.dig, direction)
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
function __TurtleController__.prototype.rotate(self, heading, assertSuccess)
    if assertSuccess == nil then
        assertSuccess = true
    end
    if LocationMonitor.status ~= LocationMonitorStatus.ACQUIRED then
        if assertSuccess then
            error(
                __TS__New(
                    Error,
                    (("Unable to rotate towards heading " .. tostring(heading)) .. ", LocationMonitorStatus is ") .. LocationMonitor.status
                ),
                0
            )
        end
        return false
    end
    if LocationMonitor.heading == heading then
        return true
    end
    local currentHeadingIdx = __TS__ArrayIndexOf(HEADING_ORDER, LocationMonitor.heading)
    local targetHeadingIdx = __TS__ArrayIndexOf(HEADING_ORDER, heading)
    if (currentHeadingIdx - 1 + #HEADING_ORDER) % #HEADING_ORDER == targetHeadingIdx then
        return self:turnLeft(assertSuccess)
    elseif (currentHeadingIdx + 1) % #HEADING_ORDER == targetHeadingIdx then
        return self:turnRight(assertSuccess)
    else
        return self:turnRight(assertSuccess) and self:turnRight(assertSuccess)
    end
end
____exports.TurtleController = __TS__New(__TurtleController__)
return ____exports
