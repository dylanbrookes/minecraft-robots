--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
local ____TurtleService = require("utils.services.TurtleService")
local TurtleService = ____TurtleService.TurtleService
local ____LocationMonitor = require("utils.LocationMonitor")
local LocationMonitor = ____LocationMonitor.LocationMonitor
local ____BehaviourStack = require("utils.turtle.BehaviourStack")
local BehaviourStack = ____BehaviourStack.BehaviourStack
local modem = peripheral.find("modem")
if not modem then
    error(
        __TS__New(Error, "Could not find modem"),
        0
    )
end
local modemName = peripheral.getName(modem)
rednet.open(modemName)
TurtleController:register()
TurtleService:register()
LocationMonitor:register()
EventLoop:run(function()
    BehaviourStack:step()
end)
return ____exports
