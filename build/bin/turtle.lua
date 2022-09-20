--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
local ____TurtleService = require("utils.services.TurtleService")
local TurtleService = ____TurtleService.TurtleService
local ____findProtocolHostId = require("utils.findProtocolHostId")
local findProtocolHostId = ____findProtocolHostId.findProtocolHostId
local ____Consts = require("utils.Consts")
local TURTLE_REGISTRY_PROTOCOL_NAME = ____Consts.TURTLE_REGISTRY_PROTOCOL_NAME
local modem = peripheral.find("modem")
if not modem then
    error(
        __TS__New(Error, "Could not find modem"),
        0
    )
end
local modemName = peripheral.getName(modem)
rednet.open(modemName)
local hostId = findProtocolHostId(nil, TURTLE_REGISTRY_PROTOCOL_NAME)
if not hostId then
    error(
        __TS__New(Error, "Could not find turtle registry host"),
        0
    )
end
TurtleController:register()
TurtleService:register()
EventLoop:run(function()
end)
return ____exports
