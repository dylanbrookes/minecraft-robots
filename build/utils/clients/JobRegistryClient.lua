--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local JobRegistryCommand = ____Consts.JobRegistryCommand
local JOB_REGISTRY_PROTOCOL_NAME = ____Consts.JOB_REGISTRY_PROTOCOL_NAME
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
____exports.JobRegistryClient = __TS__Class()
local JobRegistryClient = ____exports.JobRegistryClient
JobRegistryClient.name = "JobRegistryClient"
function JobRegistryClient.prototype.____constructor(self, hostId)
    self.hostId = hostId
end
function JobRegistryClient.prototype.call(self, cmd, args)
    if args == nil then
        args = {}
    end
    rednet.send(
        self.hostId,
        __TS__ObjectAssign({cmd = cmd}, args),
        JOB_REGISTRY_PROTOCOL_NAME
    )
    Logger:debug("Sent cmd, waiting for resp...")
    local pid, message = rednet.receive(JOB_REGISTRY_PROTOCOL_NAME, 3)
    if not pid then
        error(
            __TS__New(Error, "No response to command " .. cmd),
            0
        )
    end
    return message
end
function JobRegistryClient.prototype.list(self)
    local resp = self:call(JobRegistryCommand.LIST)
    return textutils.unserialize(resp)
end
function JobRegistryClient.prototype.getById(self, id)
    return self:call(JobRegistryCommand.GET, {id = id})
end
function JobRegistryClient.prototype.updateById(self, id, changes)
    return self:call(JobRegistryCommand.UPDATE, {id = id, changes = changes})
end
function JobRegistryClient.prototype.deleteById(self, id)
    return self:call(JobRegistryCommand.DELETE, {id = id})
end
function JobRegistryClient.prototype.add(self, ____type, args)
    return self:call(JobRegistryCommand.ADD, {type = ____type, args = args})
end
function JobRegistryClient.prototype.cancel(self, id)
    return self:call(JobRegistryCommand.CANCEL, {id = id})
end
function JobRegistryClient.prototype.retry(self, id)
    return self:call(JobRegistryCommand.RETRY, {id = id})
end
function JobRegistryClient.prototype.jobDone(self, id)
    return self:call(JobRegistryCommand.JOB_DONE, {id = id})
end
function JobRegistryClient.prototype.jobFailed(self, id, ____error)
    return self:call(JobRegistryCommand.JOB_DONE, {id = id, error = ____error})
end
function JobRegistryClient.prototype.deleteDone(self)
    return self:call(JobRegistryCommand.DELETE_DONE)
end
function JobRegistryClient.prototype.deleteAll(self)
    return self:call(JobRegistryCommand.DELETE_ALL)
end
return ____exports
