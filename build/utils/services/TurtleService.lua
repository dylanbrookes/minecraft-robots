--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local HOSTNAME = ____Consts.HOSTNAME
local TURTLE_PROTOCOL_NAME = ____Consts.TURTLE_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____PathfinderBehaviour = require("utils.turtle.behaviours.PathfinderBehaviour")
local PathfinderBehaviour = ____PathfinderBehaviour.PathfinderBehaviour
local ____BehaviourStack = require("utils.turtle.BehaviourStack")
local BehaviourStack = ____BehaviourStack.BehaviourStack
local ____getStatusUpdate = require("utils.turtle.getStatusUpdate")
local getStatusUpdate = ____getStatusUpdate.default
local ____JobProcessor = require("utils.turtle.JobProcessor")
local JobProcessor = ____JobProcessor.default
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
____exports.TurtleCommands = TurtleCommands or ({})
____exports.TurtleCommands.forward = "forward"
____exports.TurtleCommands.back = "back"
____exports.TurtleCommands.turnLeft = "turnLeft"
____exports.TurtleCommands.turnRight = "turnRight"
____exports.TurtleCommands.up = "up"
____exports.TurtleCommands.down = "down"
____exports.TurtleCommands.moveTo = "moveTo"
____exports.TurtleCommands.exec = "exec"
____exports.TurtleCommands.dig = "dig"
____exports.TurtleCommands.digUp = "digUp"
____exports.TurtleCommands.digDown = "digDown"
____exports.TurtleCommands.addJob = "addJob"
____exports.TurtleCommands.cancelJob = "cancelJob"
____exports.TurtleCommands.status = "status"
____exports.TurtleCommands.inspect = "inspect"
____exports.TurtleCommands.reboot = "reboot"
local __TurtleService__ = __TS__Class()
__TurtleService__.name = "__TurtleService__"
function __TurtleService__.prototype.____constructor(self)
    self.registered = false
end
function __TurtleService__.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "TurtleService is already registered"),
            0
        )
    end
    self.registered = true
    Logger:info("Registering Turtle Service")
    rednet.host(TURTLE_PROTOCOL_NAME, HOSTNAME)
    EventLoop:on(
        "rednet_message",
        function(____, sender, message, protocol)
            if protocol == TURTLE_PROTOCOL_NAME then
                self:onMessage(message, sender)
            end
            return false
        end
    )
end
function __TurtleService__.prototype.onMessage(self, message, sender)
    Logger:debug("GOT MESSAGE from sender", sender, message)
    if message.cmd ~= nil then
        repeat
            local ____switch9 = message.cmd
            local ____cond9 = ____switch9 == ____exports.TurtleCommands.forward or ____switch9 == ____exports.TurtleCommands.back or ____switch9 == ____exports.TurtleCommands.turnLeft or ____switch9 == ____exports.TurtleCommands.turnRight or ____switch9 == ____exports.TurtleCommands.up or ____switch9 == ____exports.TurtleCommands.down or ____switch9 == ____exports.TurtleCommands.dig or ____switch9 == ____exports.TurtleCommands.digUp or ____switch9 == ____exports.TurtleCommands.digDown
            if ____cond9 then
                if TurtleController[message.cmd] ~= nil and type(TurtleController[message.cmd]) == "function" then
                    TurtleController[message.cmd](
                        TurtleController,
                        __TS__Spread(message.params or ({}))
                    )
                else
                    error(
                        __TS__New(
                            Error,
                            ("Method " .. tostring(message.cmd)) .. " does not exist on TurtleController"
                        ),
                        0
                    )
                end
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleCommands.inspect
            if ____cond9 then
                rednet.send(
                    sender,
                    {result = {turtle.inspect()}},
                    TURTLE_PROTOCOL_NAME
                )
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleCommands.moveTo
            if ____cond9 then
                Logger:info(
                    "Adding pathfinder to",
                    __TS__Spread(message.params)
                )
                BehaviourStack:push(__TS__New(PathfinderBehaviour, message.params))
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleCommands.exec
            if ____cond9 then
                Logger:info(
                    "Running command:",
                    __TS__Spread(message.params)
                )
                shell.run(__TS__Spread(message.params))
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleCommands.addJob
            if ____cond9 then
                do
                    local job = message.params
                    Logger:info("Adding job with params:", job)
                    JobProcessor:add(job)
                    rednet.send(sender, {ok = true}, TURTLE_PROTOCOL_NAME)
                end
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleCommands.cancelJob
            if ____cond9 then
                do
                    local ____message_params_0 = message.params
                    local id = ____message_params_0.id
                    Logger:info("Cancelling job", id)
                    JobProcessor:cancel(id)
                    rednet.send(sender, {ok = true}, TURTLE_PROTOCOL_NAME)
                end
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleCommands.status
            if ____cond9 then
                do
                    local status = getStatusUpdate(nil)
                    Logger:info("Received status request, sending:", status)
                    rednet.send(sender, {ok = true, status = status}, TURTLE_PROTOCOL_NAME)
                end
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleCommands.reboot
            if ____cond9 then
                do
                    EventLoop:emit("terminate", "reboot")
                end
                break
            end
            do
                Logger:error("invalid command", message.cmd)
            end
        until true
    else
        Logger:error(
            "idk what to do with this",
            textutils.serialize(message)
        )
    end
end
____exports.TurtleService = __TS__New(__TurtleService__)
return ____exports
