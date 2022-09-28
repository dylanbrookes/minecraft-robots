--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local JobEvent = ____Consts.JobEvent
local ____TurtleBehaviour = require("utils.turtle.behaviours.TurtleBehaviour")
local TurtleBehaviourBase = ____TurtleBehaviour.TurtleBehaviourBase
____exports.JobBehaviour = __TS__Class()
local JobBehaviour = ____exports.JobBehaviour
JobBehaviour.name = "JobBehaviour"
__TS__ClassExtends(JobBehaviour, TurtleBehaviourBase)
function JobBehaviour.prototype.____constructor(self, job, priority)
    if priority == nil then
        priority = 1
    end
    TurtleBehaviourBase.prototype.____constructor(self)
    self.job = job
    self.priority = priority
    self.cancelled = false
    self.name = ((("job:" .. self.job.type) .. " [") .. tostring(self.job.id)) .. "]"
    self.behaviour = self.job:buildBehaviour()
    Logger:info("Created job behaviour " .. self.behaviour.name)
end
function JobBehaviour.prototype.step(self)
    if self.cancelled then
        Logger:info(("Job behaviour " .. self.name) .. " cancelled")
        return true
    end
    return self.behaviour:step()
end
function JobBehaviour.prototype.onStart(self)
    local ____this_1
    ____this_1 = self.behaviour
    local ____table_behaviour_onStart_result_0 = ____this_1.onStart
    if ____table_behaviour_onStart_result_0 ~= nil then
        ____table_behaviour_onStart_result_0 = ____table_behaviour_onStart_result_0(____this_1)
    end
    EventLoop:emit(JobEvent:start(self.job.id))
end
function JobBehaviour.prototype.onResume(self)
    local ____this_3
    ____this_3 = self.behaviour
    local ____table_behaviour_onResume_result_2 = ____this_3.onResume
    if ____table_behaviour_onResume_result_2 ~= nil then
        ____table_behaviour_onResume_result_2 = ____table_behaviour_onResume_result_2(____this_3)
    end
    EventLoop:emit(JobEvent:resume(self.job.id))
end
function JobBehaviour.prototype.onPause(self)
    local ____this_5
    ____this_5 = self.behaviour
    local ____table_behaviour_onPause_result_4 = ____this_5.onPause
    if ____table_behaviour_onPause_result_4 ~= nil then
        ____table_behaviour_onPause_result_4 = ____table_behaviour_onPause_result_4(____this_5)
    end
    EventLoop:emit(JobEvent:pause(self.job.id))
end
function JobBehaviour.prototype.onEnd(self)
    local ____this_7
    ____this_7 = self.behaviour
    local ____table_behaviour_onEnd_result_6 = ____this_7.onEnd
    if ____table_behaviour_onEnd_result_6 ~= nil then
        ____table_behaviour_onEnd_result_6 = ____table_behaviour_onEnd_result_6(____this_7)
    end
    EventLoop:emit(JobEvent["end"](JobEvent, self.job.id))
end
function JobBehaviour.prototype.onError(self, e)
    local ____this_9
    ____this_9 = self.behaviour
    local ____table_behaviour_onError_result_8 = ____this_9.onError
    if ____table_behaviour_onError_result_8 ~= nil then
        ____table_behaviour_onError_result_8 = ____table_behaviour_onError_result_8(____this_9, e)
    end
    EventLoop:emit(
        JobEvent:error(self.job.id),
        e
    )
end
return ____exports
