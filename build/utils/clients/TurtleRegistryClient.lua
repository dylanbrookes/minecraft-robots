--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local TURTLE_REGISTRY_PROTOCOL_NAME = ____Consts.TURTLE_REGISTRY_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____LocationMonitor = require("utils.LocationMonitor")
local LocationMonitor = ____LocationMonitor.LocationMonitor
local ____TurtleRegistryService = require("utils.services.TurtleRegistryService")
local TurtleRegistryCommand = ____TurtleRegistryService.TurtleRegistryCommand
local ____BehaviourStack = require("utils.turtle.BehaviourStack")
local BehaviourStack = ____BehaviourStack.BehaviourStack
local ____TurtleStore = require("utils.stores.TurtleStore")
local TurtleStatus = ____TurtleStore.TurtleStatus
____exports.TurtleRegistryClient = __TS__Class()
local TurtleRegistryClient = ____exports.TurtleRegistryClient
TurtleRegistryClient.name = "TurtleRegistryClient"
function TurtleRegistryClient.prototype.____constructor(self, hostId)
    self.hostId = hostId
end
function TurtleRegistryClient.prototype.startPeriodicRegistration(self)
    local eventName = "TurtleRegistryClient:registerSelf"
    EventLoop:on(
        eventName,
        function() return self:registerSelf() end,
        {async = true}
    )
    EventLoop:emitRepeat(eventName, 5)
end
function TurtleRegistryClient.prototype.call(self, cmd, args, assertResponse)
    if args == nil then
        args = {}
    end
    if assertResponse == nil then
        assertResponse = true
    end
    rednet.send(
        self.hostId,
        __TS__ObjectAssign({cmd = cmd}, args),
        TURTLE_REGISTRY_PROTOCOL_NAME
    )
    print("Sent cmd, waiting for resp...")
    local pid, message = rednet.receive(TURTLE_REGISTRY_PROTOCOL_NAME, 3)
    if assertResponse and not pid then
        error(
            __TS__New(Error, "No response to command " .. cmd),
            0
        )
    end
    return message
end
function TurtleRegistryClient.prototype.list(self)
    return self:call(TurtleRegistryCommand.LIST)
end
function TurtleRegistryClient.prototype.registerSelf(self)
    if type(turtle) == "nil" then
        error(
            __TS__New(Error, "Can only register on a turtle"),
            0
        )
    end
    if not LocationMonitor.hasPosition then
        print("Missing location, will retry registration")
        return
    end
    print("Registering turtle...")
    local ____self_call_5 = self.call
    local ____TurtleRegistryCommand_REGISTER_4 = TurtleRegistryCommand.REGISTER
    local ____LocationMonitor_position_2 = LocationMonitor.position
    local ____temp_3 = BehaviourStack:peek() and TurtleStatus.BUSY or TurtleStatus.IDLE
    local ____BehaviourStack_peek_result_name_0 = BehaviourStack:peek()
    if ____BehaviourStack_peek_result_name_0 ~= nil then
        ____BehaviourStack_peek_result_name_0 = ____BehaviourStack_peek_result_name_0.name
    end
    local resp = ____self_call_5(self, ____TurtleRegistryCommand_REGISTER_4, {location = ____LocationMonitor_position_2, status = ____temp_3, currentBehaviour = ____BehaviourStack_peek_result_name_0 or ""}, false)
    local ____resp_ok_6 = resp
    if ____resp_ok_6 ~= nil then
        ____resp_ok_6 = ____resp_ok_6.ok
    end
    if not ____resp_ok_6 then
        print(
            "Turtle register failed, will retry:",
            textutils.serialize(resp)
        )
        return
    end
    if resp.label then
        os.setComputerLabel(resp.label)
    else
    end
    print("Done registration")
end
return ____exports
