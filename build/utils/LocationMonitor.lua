--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local TurtleEvent = ____Consts.TurtleEvent
____exports.LocationMonitorStatus = LocationMonitorStatus or ({})
____exports.LocationMonitorStatus.UNKNOWN = "UNKNOWN"
____exports.LocationMonitorStatus.POS_ONLY = "POS_ONLY"
____exports.LocationMonitorStatus.ACQUIRED = "ACQUIRED"
____exports.LocationMonitorStatus.ERROR = "ERROR"
____exports.Heading = Heading or ({})
____exports.Heading.UNKNOWN = 0
____exports.Heading[____exports.Heading.UNKNOWN] = "UNKNOWN"
____exports.Heading.SYNCING = 1
____exports.Heading[____exports.Heading.SYNCING] = "SYNCING"
____exports.Heading.NORTH = 2
____exports.Heading[____exports.Heading.NORTH] = "NORTH"
____exports.Heading.SOUTH = 3
____exports.Heading[____exports.Heading.SOUTH] = "SOUTH"
____exports.Heading.EAST = 4
____exports.Heading[____exports.Heading.EAST] = "EAST"
____exports.Heading.WEST = 5
____exports.Heading[____exports.Heading.WEST] = "WEST"
____exports.HEADING_ORDER = {____exports.Heading.NORTH, ____exports.Heading.EAST, ____exports.Heading.SOUTH, ____exports.Heading.WEST}
____exports.HEADING_TO_XZ_VEC = {
    [____exports.Heading.UNKNOWN] = {0, 0},
    [____exports.Heading.SYNCING] = {0, 0},
    [____exports.Heading.NORTH] = {0, -1},
    [____exports.Heading.SOUTH] = {0, 1},
    [____exports.Heading.EAST] = {1, 0},
    [____exports.Heading.WEST] = {-1, 0}
}
local RELEVANT_EVENTS = {
    TurtleEvent.moved_forward,
    TurtleEvent.moved_back,
    TurtleEvent.moved_up,
    TurtleEvent.moved_down,
    TurtleEvent.turned_left,
    TurtleEvent.turned_right
}
local __LocationMonitor__ = __TS__Class()
__LocationMonitor__.name = "__LocationMonitor__"
function __LocationMonitor__.prototype.____constructor(self)
    self._status = ____exports.LocationMonitorStatus.UNKNOWN
    self._heading = ____exports.Heading.UNKNOWN
    self.pos = {0, 0, 0}
    self.registered = false
end
__TS__SetDescriptor(
    __LocationMonitor__.prototype,
    "status",
    {get = function(self)
        return self._status
    end},
    true
)
__TS__SetDescriptor(
    __LocationMonitor__.prototype,
    "position",
    {get = function(self)
        if not self.hasPosition then
            return nil
        end
        return {table.unpack(self.pos)}
    end},
    true
)
__TS__SetDescriptor(
    __LocationMonitor__.prototype,
    "heading",
    {get = function(self)
        return self._heading
    end},
    true
)
__TS__SetDescriptor(
    __LocationMonitor__.prototype,
    "hasPosition",
    {get = function(self)
        return __TS__ArrayIncludes({____exports.LocationMonitorStatus.ACQUIRED, ____exports.LocationMonitorStatus.POS_ONLY}, self._status)
    end},
    true
)
function __LocationMonitor__.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "LocationMonitor is already registered"),
            0
        )
    end
    self.registered = true
    Logger:info("Registering Location Monitor")
    for ____, event in ipairs(RELEVANT_EVENTS) do
        EventLoop:on(
            event,
            function() return self:onMove(event) end
        )
    end
    EventLoop:on(
        "check_position",
        function() return self:checkPosition() end,
        {async = true}
    )
    EventLoop:emitRepeat("check_position", 10)
    EventLoop:setTimeout(function() return EventLoop:emit("check_position") end)
end
function __LocationMonitor__.prototype.checkPosition(self)
    if self._status == ____exports.LocationMonitorStatus.UNKNOWN then
        Logger:info("Retrieving location...")
        local pos = {gps.locate(3)}
        if not pos or pos[1] == nil then
            Logger:warn("Failed to retrieve location")
            self._status = ____exports.LocationMonitorStatus.ERROR
        else
            Logger:info(
                "Retrieved location:",
                table.unpack(pos)
            )
            self.pos = pos
            self._status = ____exports.LocationMonitorStatus.POS_ONLY
        end
        return
    elseif not __TS__ArrayIncludes({____exports.LocationMonitorStatus.POS_ONLY, ____exports.LocationMonitorStatus.ACQUIRED}, self._status) then
        Logger:debug("Skipping gps check, status is", self._status)
        return
    end
    Logger:debug("Checking gps position...")
    local pos = {gps.locate(3)}
    if not pos or pos[1] == nil then
        Logger:error("Could not retrieve gps position for check")
        return
    end
    if self._heading == ____exports.Heading.SYNCING then
        local oldPos = self.pos
        local dx = pos[1] - oldPos[1]
        local dy = pos[2] - oldPos[2]
        local dz = pos[3] - oldPos[3]
        local diff = math.abs(dx) + math.abs(dy) + math.abs(dz)
        if diff == 1 then
            if dy ~= 0 then
                error(
                    __TS__New(Error, "how tf this happed"),
                    0
                )
            elseif dx ~= 0 then
                self._heading = dx == 1 and ____exports.Heading.EAST or ____exports.Heading.WEST
            elseif dz ~= 0 then
                self._heading = dz == 1 and ____exports.Heading.SOUTH or ____exports.Heading.NORTH
            else
                error(
                    __TS__New(Error, "okay wtf 3979827590"),
                    0
                )
            end
            self.pos = pos
            self._status = ____exports.LocationMonitorStatus.ACQUIRED
            Logger:debug("acquired location and heading")
            Logger:debug(
                "location:",
                table.unpack(self.pos)
            )
            Logger:debug("heading:", self._heading)
        else
            Logger:warn("Could not determine heading, pos diff is not 1 (maybe we moved backwards? I didn't implement heading calculation for that 🙂):")
            Logger:debug(
                "oldPos:",
                table.unpack(oldPos)
            )
            Logger:debug(
                "pos:",
                table.unpack(pos)
            )
            self._heading = ____exports.Heading.UNKNOWN
            self.pos = pos
        end
    end
    if pos[1] ~= self.pos[1] or pos[2] ~= self.pos[2] or pos[3] ~= self.pos[3] then
        Logger:warn("GPS POSITION MISMATCH, will update")
        Logger:warn(
            "Our position:",
            table.unpack(self.pos)
        )
        Logger:warn(
            "GPS pos:",
            table.unpack(pos)
        )
        self.pos = pos
    end
end
function __LocationMonitor__.prototype.onMoveForwardOrBack(self, forward)
    local delta = forward and 1 or -1
    repeat
        local ____switch30 = self._heading
        local ____cond30 = ____switch30 == ____exports.Heading.NORTH
        if ____cond30 then
            local ____self_pos_0, ____3_1 = self.pos, 3
            ____self_pos_0[____3_1] = ____self_pos_0[____3_1] - delta
            break
        end
        ____cond30 = ____cond30 or ____switch30 == ____exports.Heading.SOUTH
        if ____cond30 then
            local ____self_pos_2, ____3_3 = self.pos, 3
            ____self_pos_2[____3_3] = ____self_pos_2[____3_3] + delta
            break
        end
        ____cond30 = ____cond30 or ____switch30 == ____exports.Heading.EAST
        if ____cond30 then
            local ____self_pos_4, ____1_5 = self.pos, 1
            ____self_pos_4[____1_5] = ____self_pos_4[____1_5] + delta
            break
        end
        ____cond30 = ____cond30 or ____switch30 == ____exports.Heading.WEST
        if ____cond30 then
            local ____self_pos_6, ____1_7 = self.pos, 1
            ____self_pos_6[____1_7] = ____self_pos_6[____1_7] - delta
            break
        end
    until true
end
function __LocationMonitor__.prototype.onMove(self, eventName)
    if self._status == ____exports.LocationMonitorStatus.UNKNOWN then
        return
    end
    repeat
        local ____switch33 = eventName
        local ____cond33 = ____switch33 == TurtleEvent.moved_forward
        if ____cond33 then
            if self._status == ____exports.LocationMonitorStatus.POS_ONLY and self._heading == ____exports.Heading.UNKNOWN then
                self._heading = ____exports.Heading.SYNCING
                EventLoop:emit("check_position")
            else
                self:onMoveForwardOrBack(true)
            end
            break
        end
        ____cond33 = ____cond33 or ____switch33 == TurtleEvent.moved_back
        if ____cond33 then
            if self._status ~= ____exports.LocationMonitorStatus.ACQUIRED then
                break
            end
            self:onMoveForwardOrBack(false)
            break
        end
        ____cond33 = ____cond33 or ____switch33 == TurtleEvent.moved_up
        if ____cond33 then
            local ____self_pos_8, ____2_9 = self.pos, 2
            ____self_pos_8[____2_9] = ____self_pos_8[____2_9] + 1
            break
        end
        ____cond33 = ____cond33 or ____switch33 == TurtleEvent.moved_down
        if ____cond33 then
            local ____self_pos_10, ____2_11 = self.pos, 2
            ____self_pos_10[____2_11] = ____self_pos_10[____2_11] - 1
            break
        end
        ____cond33 = ____cond33 or ____switch33 == TurtleEvent.turned_left
        if ____cond33 then
            if self._heading == ____exports.Heading.UNKNOWN then
                break
            end
            self._heading = ____exports.HEADING_ORDER[(__TS__ArrayIndexOf(____exports.HEADING_ORDER, self._heading) + #____exports.HEADING_ORDER - 1) % #____exports.HEADING_ORDER + 1]
            break
        end
        ____cond33 = ____cond33 or ____switch33 == TurtleEvent.turned_right
        if ____cond33 then
            if self._heading == ____exports.Heading.UNKNOWN then
                break
            end
            self._heading = ____exports.HEADING_ORDER[(__TS__ArrayIndexOf(____exports.HEADING_ORDER, self._heading) + 1) % #____exports.HEADING_ORDER + 1]
            break
        end
    until true
end
____exports.LocationMonitor = __TS__New(__LocationMonitor__)
return ____exports
