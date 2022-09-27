--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____TurtleService = require("utils.services.TurtleService")
local TurtleService = ____TurtleService.TurtleService
local ____LocationMonitor = require("utils.LocationMonitor")
local LocationMonitor = ____LocationMonitor.LocationMonitor
local ____BehaviourStack = require("utils.turtle.BehaviourStack")
local BehaviourStack = ____BehaviourStack.BehaviourStack
local ____Consts = require("utils.turtle.Consts")
local TurtleEvent = ____Consts.TurtleEvent
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____RefuelBehaviour = require("utils.turtle.behaviours.RefuelBehaviour")
local RefuelBehaviour = ____RefuelBehaviour.RefuelBehaviour
local ____FuelMonitor = require("utils.turtle.FuelMonitor")
local FuelMonitor = ____FuelMonitor.default
local ____TurtleControlClient = require("utils.clients.TurtleControlClient")
local TurtleControlClient = ____TurtleControlClient.TurtleControlClient
local ____findProtocolHostId = require("utils.findProtocolHostId")
local findProtocolHostId = ____findProtocolHostId.findProtocolHostId
local ____Consts = require("utils.Consts")
local TURTLE_CONTROL_PROTOCOL_NAME = ____Consts.TURTLE_CONTROL_PROTOCOL_NAME
local modem = peripheral.find("modem")
if not modem then
    error(
        __TS__New(Error, "Could not find modem"),
        0
    )
end
local modemName = peripheral.getName(modem)
rednet.open(modemName)
local turtleControlHostId = findProtocolHostId(nil, TURTLE_CONTROL_PROTOCOL_NAME)
FuelMonitor:register()
TurtleService:register()
LocationMonitor:register()
if not turtleControlHostId then
    Logger:warn("Did not find a turtle control host")
else
    local turtleControlClient = __TS__New(TurtleControlClient, turtleControlHostId)
    turtleControlClient:register()
end
EventLoop:on(
    TurtleEvent.low_fuel,
    function()
        BehaviourStack:push(__TS__New(RefuelBehaviour))
    end
)
EventLoop:on(
    TurtleEvent.out_of_fuel,
    function()
        Logger:error("OH NO WE ARE OUT OF FUEL. THIS IS FROM AN EVENT.")
        return false
    end
)
Logger:info("Done startup")
EventLoop:run(function()
    BehaviourStack:step()
end)
return ____exports
