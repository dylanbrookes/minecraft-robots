--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local ResourceRegistryCommand = ____Consts.ResourceRegistryCommand
local RESOURCE_REGISTRY_PROTOCOL_NAME = ____Consts.RESOURCE_REGISTRY_PROTOCOL_NAME
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
____exports.ResourceRegistryClient = __TS__Class()
local ResourceRegistryClient = ____exports.ResourceRegistryClient
ResourceRegistryClient.name = "ResourceRegistryClient"
function ResourceRegistryClient.prototype.____constructor(self, hostId)
    self.hostId = hostId
end
function ResourceRegistryClient.prototype.call(self, cmd, args)
    if args == nil then
        args = {}
    end
    rednet.send(
        self.hostId,
        __TS__ObjectAssign({cmd = cmd}, args),
        RESOURCE_REGISTRY_PROTOCOL_NAME
    )
    Logger:debug("Sent cmd, waiting for resp...")
    local pid, message = rednet.receive(RESOURCE_REGISTRY_PROTOCOL_NAME, 3)
    if not pid then
        error(
            __TS__New(Error, "No response to command " .. cmd),
            0
        )
    end
    return message
end
function ResourceRegistryClient.prototype.list(self)
    local resp = self:call(ResourceRegistryCommand.LIST)
    return textutils.unserialize(resp)
end
function ResourceRegistryClient.prototype.getById(self, id)
    return self:call(ResourceRegistryCommand.GET, {id = id})
end
function ResourceRegistryClient.prototype.updateById(self, id, changes)
    return self:call(ResourceRegistryCommand.UPDATE, {id = id, changes = changes})
end
function ResourceRegistryClient.prototype.deleteById(self, id)
    return self:call(ResourceRegistryCommand.DELETE, {id = id})
end
function ResourceRegistryClient.prototype.add(self, resource)
    return self:call(ResourceRegistryCommand.ADD, resource)
end
function ResourceRegistryClient.prototype.find(self, tags, position)
    return self:call(ResourceRegistryCommand.FIND, {tags = tags, position = position})
end
return ____exports
