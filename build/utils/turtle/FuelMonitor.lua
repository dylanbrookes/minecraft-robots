--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local TurtleEvent = ____Consts.TurtleEvent
____exports.FuelStatus = FuelStatus or ({})
____exports.FuelStatus.UNKNOWN = "UNKNOWN"
____exports.FuelStatus.OK = "OK"
____exports.FuelStatus.LOW = "LOW"
____exports.FuelStatus.EMPTY = "EMPTY"
____exports.FuelStatus.UNLIMITED = "UNLIMITED"
local __FuelMonitor__ = __TS__Class()
__FuelMonitor__.name = "__FuelMonitor__"
function __FuelMonitor__.prototype.____constructor(self)
    self.registered = false
    self._fuelStatus = ____exports.FuelStatus.UNKNOWN
end
function __FuelMonitor__.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "FuelMonitor is already registered"),
            0
        )
    end
    self.registered = true
    EventLoop:emitRepeat(TurtleEvent.check_fuel, __FuelMonitor__.CHECK_FUEL_INTERVAL)
    EventLoop:on(
        TurtleEvent.check_fuel,
        function()
            self:checkFuel()
            return false
        end,
        {async = true}
    )
    EventLoop:setTimeout(function() return EventLoop:emit(TurtleEvent.check_fuel) end)
end
function __FuelMonitor__.prototype.checkFuel(self)
    Logger:debug("Check fuel called")
    local fuelLevel = turtle.getFuelLevel()
    local fuelLimit = turtle.getFuelLimit()
    if fuelLevel == "unlimited" or fuelLimit == "unlimited" then
        self._fuelStatus = ____exports.FuelStatus.UNLIMITED
    elseif fuelLevel / fuelLimit < __FuelMonitor__.MIN_FUEL_RATIO then
        if __TS__ArrayIncludes({____exports.FuelStatus.UNKNOWN, ____exports.FuelStatus.OK}, self._fuelStatus) then
            EventLoop:emit(TurtleEvent.low_fuel)
        end
        local nextFuelStatus = fuelLevel == 0 and ____exports.FuelStatus.EMPTY or ____exports.FuelStatus.LOW
        if nextFuelStatus == ____exports.FuelStatus.EMPTY and self._fuelStatus ~= ____exports.FuelStatus.EMPTY then
            EventLoop:emit(TurtleEvent.out_of_fuel)
        end
        self._fuelStatus = nextFuelStatus
    else
        Logger:debug(
            "Fuel OK, level:",
            fuelLevel,
            "limit:",
            fuelLimit,
            "ratio:",
            fuelLevel / fuelLimit * 100,
            "%",
            "target:",
            __FuelMonitor__.MIN_FUEL_RATIO
        )
        self._fuelStatus = ____exports.FuelStatus.OK
    end
    return self.fuelStatus
end
__FuelMonitor__.CHECK_FUEL_INTERVAL = 10
__FuelMonitor__.MIN_FUEL_RATIO = 0.2
__TS__SetDescriptor(
    __FuelMonitor__.prototype,
    "fuelStatus",
    {get = function(self)
        return self._fuelStatus
    end},
    true
)
local FuelMonitor = __TS__New(__FuelMonitor__)
____exports.default = FuelMonitor
return ____exports
