--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.HOSTNAME = "job-server-" .. tostring(os.computerID())
____exports.TSH_PROTOCOL_NAME = "tsh"
____exports.TURTLE_PROTOCOL_NAME = "tsh:turtle"
____exports.TURTLE_CONTROL_PROTOCOL_NAME = "tsh:turtle-control"
____exports.JOB_REGISTRY_PROTOCOL_NAME = "tsh:job-registry"
____exports.RESOURCE_REGISTRY_PROTOCOL_NAME = "tsh:resource-registry"
____exports.JobRegistryCommand = JobRegistryCommand or ({})
____exports.JobRegistryCommand.LIST = "LIST"
____exports.JobRegistryCommand.DELETE = "DELETE"
____exports.JobRegistryCommand.DELETE_DONE = "DELETE_DONE"
____exports.JobRegistryCommand.DELETE_ALL = "DELETE_ALL"
____exports.JobRegistryCommand.GET = "GET"
____exports.JobRegistryCommand.UPDATE = "UPDATE"
____exports.JobRegistryCommand.ADD = "ADD"
____exports.JobRegistryCommand.CANCEL = "CANCEL"
____exports.JobRegistryCommand.RETRY = "RETRY"
____exports.JobRegistryCommand.JOB_DONE = "JOB_DONE"
____exports.JobRegistryCommand.JOB_FAILED = "JOB_FAILED"
____exports.JobRegistryEvent = JobRegistryEvent or ({})
____exports.JobRegistryEvent.JOB_DONE = "JobRegistry:job_done"
____exports.JobRegistryEvent.JOB_FAILED = "JobRegistry:job_failed"
____exports.JobRegistryEvent.JOB_CANCELLED = "JobRegistry:job_cancelled"
____exports.TurtleControlEvent = TurtleControlEvent or ({})
____exports.TurtleControlEvent.TURTLE_IDLE = "TurtleControl:turtle_idle"
____exports.TurtleControlEvent.TURTLE_OFFLINE = "TurtleControl:turtle_offline"
____exports.ResourceRegistryCommand = ResourceRegistryCommand or ({})
____exports.ResourceRegistryCommand.LIST = "LIST"
____exports.ResourceRegistryCommand.GET = "GET"
____exports.ResourceRegistryCommand.FIND = "FIND"
____exports.ResourceRegistryCommand.ADD = "ADD"
____exports.ResourceRegistryCommand.DELETE = "DELETE"
____exports.ResourceRegistryCommand.UPDATE = "UPDATE"
return ____exports
