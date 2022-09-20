--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local JobServerCommand = ____Consts.JobServerCommand
local JOBS_PROTOCOL_NAME = ____Consts.JOBS_PROTOCOL_NAME
____exports.JobServerClient = __TS__Class()
local JobServerClient = ____exports.JobServerClient
JobServerClient.name = "JobServerClient"
function JobServerClient.prototype.____constructor(self, hostId)
    self.hostId = hostId
end
function JobServerClient.prototype.call(self, cmd, args)
    if args == nil then
        args = {}
    end
    rednet.send(
        self.hostId,
        textutils.serialize(
            __TS__ObjectAssign({cmd = cmd}, args),
            {compact = true}
        ),
        JOBS_PROTOCOL_NAME
    )
    print("Sent cmd, waiting for resp...")
    local pid, message = rednet.receive(JOBS_PROTOCOL_NAME, 3)
    if not pid then
        error(
            __TS__New(Error, "No response to command " .. cmd),
            0
        )
    end
    return message
end
function JobServerClient.prototype.list(self)
    local resp = self:call(JobServerCommand.LIST)
    return textutils.unserialize(resp)
end
function JobServerClient.prototype.getById(self, id)
    return self:call(JobServerCommand.GET, {id = id})
end
function JobServerClient.prototype.updateById(self, id, changes)
    return self:call(JobServerCommand.UPDATE, {id = id, changes = changes})
end
function JobServerClient.prototype.deleteById(self, id)
    return self:call(JobServerCommand.DELETE, {id = id})
end
function JobServerClient.prototype.add(self)
    return self:call(JobServerCommand.ADD)
end
return ____exports
