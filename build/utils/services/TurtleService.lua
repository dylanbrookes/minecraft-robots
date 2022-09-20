--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local HOSTNAME = ____Consts.HOSTNAME
local TURTLE_PROTOCOL_NAME = ____Consts.TURTLE_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____PathfinderBehaviour = require("utils.turtle.behaviours.PathfinderBehaviour")
local PathfinderBehaviour = ____PathfinderBehaviour.PathfinderBehaviour
local ____BehaviourStack = require("utils.turtle.BehaviourStack")
local BehaviourStack = ____BehaviourStack.BehaviourStack
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
____exports.TurtleServiceCommands = TurtleServiceCommands or ({})
____exports.TurtleServiceCommands.forward = "forward"
____exports.TurtleServiceCommands.back = "back"
____exports.TurtleServiceCommands.turnLeft = "turnLeft"
____exports.TurtleServiceCommands.turnRight = "turnRight"
____exports.TurtleServiceCommands.up = "up"
____exports.TurtleServiceCommands.down = "down"
____exports.TurtleServiceCommands.moveTo = "moveTo"
____exports.TurtleServiceCommands.exec = "exec"
____exports.TurtleServiceCommands.dig = "dig"
____exports.TurtleServiceCommands.digUp = "digUp"
____exports.TurtleServiceCommands.digDown = "digDown"
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
    print("Registering Turtle Service")
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
    if message.cmd ~= nil then
        repeat
            local ____switch9 = message.cmd
            local ____cond9 = ____switch9 == ____exports.TurtleServiceCommands.forward or ____switch9 == ____exports.TurtleServiceCommands.back or ____switch9 == ____exports.TurtleServiceCommands.turnLeft or ____switch9 == ____exports.TurtleServiceCommands.turnRight or ____switch9 == ____exports.TurtleServiceCommands.up or ____switch9 == ____exports.TurtleServiceCommands.down or ____switch9 == ____exports.TurtleServiceCommands.dig or ____switch9 == ____exports.TurtleServiceCommands.digUp or ____switch9 == ____exports.TurtleServiceCommands.digDown
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
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleServiceCommands.moveTo
            if ____cond9 then
                print(
                    "Adding pathfinder to",
                    __TS__Spread(message.params)
                )
                BehaviourStack:push(__TS__New(PathfinderBehaviour, message.params))
                break
            end
            ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleServiceCommands.exec
            if ____cond9 then
                print(
                    "Running command:",
                    __TS__Spread(message.params)
                )
                shell.run(__TS__Spread(message.params))
                break
            end
            do
                print("invalid command", message.cmd)
            end
        until true
    else
        print(
            "idk what to do with this",
            textutils.serialize(message)
        )
    end
end
____exports.TurtleService = __TS__New(__TurtleService__)
return ____exports
