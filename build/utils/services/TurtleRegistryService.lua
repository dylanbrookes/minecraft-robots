--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local HOSTNAME = ____Consts.HOSTNAME
local TURTLE_REGISTRY_PROTOCOL_NAME = ____Consts.TURTLE_REGISTRY_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____generateName = require("utils.generateName")
local generateName = ____generateName.default
____exports.TurtleRegistryCommand = TurtleRegistryCommand or ({})
____exports.TurtleRegistryCommand.REGISTER = "REGISTER"
____exports.TurtleRegistryCommand.LIST = "LIST"
____exports.default = __TS__Class()
local TurtleRegistryService = ____exports.default
TurtleRegistryService.name = "TurtleRegistryService"
function TurtleRegistryService.prototype.____constructor(self, turtleStore)
    self.turtleStore = turtleStore
    self.registered = false
end
function TurtleRegistryService.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "TurtleRegistryService is already registered"),
            0
        )
    end
    self.registered = true
    print("Registering Turtle Registry Service")
    rednet.host(TURTLE_REGISTRY_PROTOCOL_NAME, HOSTNAME)
    EventLoop:on(
        "rednet_message",
        function(____, sender, message, protocol)
            if protocol == TURTLE_REGISTRY_PROTOCOL_NAME then
                self:onMessage(message, sender)
            end
            return false
        end
    )
end
function TurtleRegistryService.prototype.onMessage(self, message, sender)
    print(
        "Got TurtleRegistryService message from sender",
        sender,
        textutils.serialize(message)
    )
    if not (message.cmd ~= nil) then
        print(
            "idk what to do with this",
            textutils.serialize(message)
        )
        return
    end
    repeat
        local ____switch9 = message.cmd
        local ____cond9 = ____switch9 == ____exports.TurtleRegistryCommand.REGISTER
        if ____cond9 then
            if message and type(message) == "table" then
                local updates = {
                    lastSeen = os.epoch(),
                    location = nil,
                    currentBehaviour = message.currentBehaviour,
                    status = message.status
                }
                if message.location ~= nil then
                    local location = message.location
                    if __TS__ArrayIsArray(location) and #location == 3 then
                        updates.location = message.location
                    else
                        print(
                            "Invalid location",
                            textutils.serialize(message.location)
                        )
                    end
                end
                if self.turtleStore:exists(sender) then
                    print(("Turtle " .. tostring(sender)) .. " registered again")
                    self.turtleStore:update(sender, updates)
                    self.turtleStore:save()
                    rednet.send(sender, {ok = true}, TURTLE_REGISTRY_PROTOCOL_NAME)
                else
                    local record = __TS__ObjectAssign(
                        {
                            id = sender,
                            label = generateName(nil),
                            registeredAt = os.epoch()
                        },
                        updates
                    )
                    self.turtleStore:add(record)
                    self.turtleStore:save()
                    rednet.send(sender, {ok = true, label = record.label}, TURTLE_REGISTRY_PROTOCOL_NAME)
                end
            else
                print(
                    "Invalid register params",
                    textutils.serialize(message)
                )
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == ____exports.TurtleRegistryCommand.LIST
        if ____cond9 then
            rednet.send(
                sender,
                tostring(self.turtleStore),
                TURTLE_REGISTRY_PROTOCOL_NAME
            )
            break
        end
        do
            print("invalid TurtleRegistryService command", message.cmd)
        end
    until true
end
____exports.default = TurtleRegistryService
return ____exports
