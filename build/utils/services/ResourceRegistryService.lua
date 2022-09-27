--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local HOSTNAME = ____Consts.HOSTNAME
local ResourceRegistryCommand = ____Consts.ResourceRegistryCommand
local RESOURCE_REGISTRY_PROTOCOL_NAME = ____Consts.RESOURCE_REGISTRY_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local cartesianDistance = ____Consts.cartesianDistance
____exports.default = __TS__Class()
local ResourceRegistryService = ____exports.default
ResourceRegistryService.name = "ResourceRegistryService"
function ResourceRegistryService.prototype.____constructor(self, resourceStore)
    self.resourceStore = resourceStore
    self.registered = false
end
function ResourceRegistryService.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "ResourceRegistryService is already registered"),
            0
        )
    end
    self.registered = true
    Logger:info("Registering Resource Registry Service")
    rednet.host(RESOURCE_REGISTRY_PROTOCOL_NAME, HOSTNAME)
    EventLoop:on(
        "rednet_message",
        function(____, sender, message, protocol)
            if protocol == RESOURCE_REGISTRY_PROTOCOL_NAME then
                self:onMessage(message, sender)
            end
            return false
        end
    )
end
function ResourceRegistryService.prototype.onMessage(self, message, sender)
    Logger:info(
        "Got ResourceRegistryService message from sender",
        sender,
        textutils.serialize(message)
    )
    if not (message.cmd ~= nil) then
        Logger:error("idk what to do with this", message)
        return
    end
    local ____message_0 = message
    local cmd = ____message_0.cmd
    local params = __TS__ObjectRest(____message_0, {cmd = true})
    repeat
        local ____switch9 = cmd
        local ____cond9 = ____switch9 == ResourceRegistryCommand.LIST
        if ____cond9 then
            do
                rednet.send(
                    sender,
                    tostring(self.resourceStore),
                    RESOURCE_REGISTRY_PROTOCOL_NAME
                )
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == ResourceRegistryCommand.GET
        if ____cond9 then
            do
                local ____params_1 = params
                local id = ____params_1.id
                rednet.send(
                    sender,
                    self.resourceStore:getById(id),
                    RESOURCE_REGISTRY_PROTOCOL_NAME
                )
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == ResourceRegistryCommand.DELETE
        if ____cond9 then
            do
                local ____params_2 = params
                local id = ____params_2.id
                local result = self.resourceStore:removeById(id)
                if result then
                    self.resourceStore:save()
                end
                rednet.send(sender, result, RESOURCE_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == ResourceRegistryCommand.UPDATE
        if ____cond9 then
            do
                local ____params_3 = params
                local id = ____params_3.id
                local changes = __TS__ObjectRest(____params_3, {id = true})
                local result = self.resourceStore:updateById(id, changes)
                if result then
                    self.resourceStore:save()
                end
                rednet.send(sender, result, RESOURCE_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == ResourceRegistryCommand.ADD
        if ____cond9 then
            do
                local ____params_4 = params
                local tags = ____params_4.tags
                local position = ____params_4.position
                local result = self.resourceStore:add({tags = tags, position = position})
                self.resourceStore:save()
                rednet.send(sender, result, RESOURCE_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == ResourceRegistryCommand.FIND
        if ____cond9 then
            do
                local ____params_5 = params
                local tags = ____params_5.tags
                local position = ____params_5.position
                local resources = __TS__ArraySort(
                    self.resourceStore:select(function(____, ____bindingPattern0)
                        local _tags
                        _tags = ____bindingPattern0.tags
                        return __TS__ArrayEvery(
                            tags,
                            function(____, t) return __TS__ArrayIncludes(_tags, t) end
                        )
                    end),
                    function(____, a, b) return cartesianDistance(nil, a.position, position) - cartesianDistance(nil, b.position, position) end
                )
                Logger:info("Resources:", resources)
                if not #resources then
                    rednet.send(sender, {resource = nil}, RESOURCE_REGISTRY_PROTOCOL_NAME)
                else
                    rednet.send(sender, {resource = resources[1]}, RESOURCE_REGISTRY_PROTOCOL_NAME)
                end
            end
            break
        end
        do
            Logger:error("invalid ResourceRegistryService command", message.cmd)
        end
    until true
end
____exports.default = ResourceRegistryService
return ____exports
