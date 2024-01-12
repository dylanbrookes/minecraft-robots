--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local TURTLE_CONTROL_PROTOCOL_NAME = ____Consts.TURTLE_CONTROL_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____TurtleControlService = require("utils.services.TurtleControlService")
local TurtleControlCommand = ____TurtleControlService.TurtleControlCommand
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____getStatusUpdate = require("utils.turtle.getStatusUpdate")
local getStatusUpdate = ____getStatusUpdate.default
____exports.TurtleControlClient = __TS__Class()
local TurtleControlClient = ____exports.TurtleControlClient
TurtleControlClient.name = "TurtleControlClient"
function TurtleControlClient.prototype.____constructor(self, hostId)
    self.hostId = hostId
    self.terminated = false
end
function TurtleControlClient.prototype.register(self)
    EventLoop:on(
        ____exports.TurtleControlClient.REGISTER_EVENT,
        function() return self:registerSelf() end,
        {async = true}
    )
    EventLoop:on(
        ____exports.TurtleControlClient.PING_EVENT,
        function() return self:sendPing() end,
        {async = true}
    )
    EventLoop:setTimeout(
        function() return EventLoop:emit(____exports.TurtleControlClient.REGISTER_EVENT) end,
        1
    )
    EventLoop:on(
        "terminate",
        function()
            Logger:info("Notifying control server that we're terminating")
            self.terminated = true
            self:call(TurtleControlCommand.TURTLE_TERMINATE, {}, false)
        end,
        {async = true}
    )
end
function TurtleControlClient.prototype.call(self, cmd, args, getResponse, assertResponse)
    if args == nil then
        args = {}
    end
    if getResponse == nil then
        getResponse = true
    end
    if assertResponse == nil then
        assertResponse = true
    end
    rednet.send(
        self.hostId,
        __TS__ObjectAssign({cmd = cmd}, args),
        TURTLE_CONTROL_PROTOCOL_NAME
    )
    if getResponse then
        local pid, message = rednet.receive(TURTLE_CONTROL_PROTOCOL_NAME, 3)
        if not pid and assertResponse then
            error(
                __TS__New(Error, "No response to command " .. cmd),
                0
            )
        end
        return message
    end
    return nil
end
function TurtleControlClient.prototype.list(self)
    return self:call(TurtleControlCommand.LIST)
end
function TurtleControlClient.prototype.registerSelf(self)
    if self.terminated then
        return
    end
    if type(turtle) == "nil" then
        error(
            __TS__New(Error, "Can only register on a turtle"),
            0
        )
    end
    Logger:info("Connecting to turtle control server...")
    local resp = self:call(
        TurtleControlCommand.TURTLE_CONNECT,
        getStatusUpdate(nil),
        true
    )
    local ____resp_ok_0 = resp
    if ____resp_ok_0 ~= nil then
        ____resp_ok_0 = ____resp_ok_0.ok
    end
    if not ____resp_ok_0 then
        Logger:warn(
            "Turtle register failed, will retry:",
            textutils.serialize(resp)
        )
        EventLoop:setTimeout(
            function() return EventLoop:emit(____exports.TurtleControlClient.REGISTER_EVENT) end,
            ____exports.TurtleControlClient.REGISTER_RETRY_INTERVAL
        )
        return
    end
    if type(resp.label) == "string" then
        os.setComputerLabel(((resp.label .. " [") .. tostring(os.computerID())) .. "]")
    else
    end
    Logger:info("Done registration")
    EventLoop:emitRepeat(____exports.TurtleControlClient.PING_EVENT, ____exports.TurtleControlClient.PING_INTERVAL)
end
function TurtleControlClient.prototype.sendPing(self)
    if self.terminated then
        return
    end
    self:call(
        TurtleControlCommand.TURTLE_PING,
        getStatusUpdate(nil),
        false
    )
end
TurtleControlClient.REGISTER_EVENT = "TurtleRegistryClient:registerSelf"
TurtleControlClient.REGISTER_RETRY_INTERVAL = 5
TurtleControlClient.PING_EVENT = "TurtleRegistryClient:sendPing"
TurtleControlClient.PING_INTERVAL = 5
return ____exports
