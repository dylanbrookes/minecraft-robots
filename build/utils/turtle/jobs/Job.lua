--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.turtle.Consts")
local JobType = ____Consts.JobType
local ____ClearJob = require("utils.turtle.jobs.ClearJob")
local ClearJob = ____ClearJob.default
local ____SpinJob = require("utils.turtle.jobs.SpinJob")
local SpinJob = ____SpinJob.default
local JOB_IMPL_TYPE_MAP = {[JobType.spin] = SpinJob, [JobType.clear] = ClearJob}
____exports.default = __TS__Class()
local Job = ____exports.default
Job.name = "Job"
function Job.prototype.____constructor(self, record)
    self.record = record
    self.id = record.id
    self.type = record.type
    self.impl = JOB_IMPL_TYPE_MAP[self.type]
end
function Job.prototype.turtleFitness(self, turtleRecord)
    if self.impl.turtleFitness then
        return self.impl.turtleFitness(self, turtleRecord)
    end
    return 0
end
function Job.prototype.buildBehaviour(self)
    return __TS__New(
        self.impl.BehaviourConstructor,
        table.unpack(self.record.args)
    )
end
return ____exports
