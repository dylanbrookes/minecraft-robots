--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.HOSTNAME = "job-server-" .. tostring(os.computerID())
____exports.TSH_PROTOCOL_NAME = "tsh"
____exports.JOBS_PROTOCOL_NAME = "tsh:jobs"
____exports.TURTLE_PROTOCOL_NAME = "tsh:turtle"
____exports.TURTLE_REGISTRY_PROTOCOL_NAME = "tsh:turtle-registry"
____exports.JobServerCommand = JobServerCommand or ({})
____exports.JobServerCommand.LIST = "LIST"
____exports.JobServerCommand.DELETE = "DELETE"
____exports.JobServerCommand.GET = "GET"
____exports.JobServerCommand.UPDATE = "UPDATE"
____exports.JobServerCommand.ADD = "ADD"
return ____exports
