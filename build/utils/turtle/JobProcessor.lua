--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____JobRegistryClient = require("utils.clients.JobRegistryClient")
local JobRegistryClient = ____JobRegistryClient.JobRegistryClient
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____JobBehaviour = require("utils.turtle.behaviours.JobBehaviour")
local JobBehaviour = ____JobBehaviour.JobBehaviour
local ____BehaviourStack = require("utils.turtle.BehaviourStack")
local BehaviourStack = ____BehaviourStack.BehaviourStack
local ____Consts = require("utils.turtle.Consts")
local JobEvent = ____Consts.JobEvent
local ____Job = require("utils.turtle.jobs.Job")
local Job = ____Job.default
local __JobProcessor__ = __TS__Class()
__JobProcessor__.name = "__JobProcessor__"
function __JobProcessor__.prototype.____constructor(self)
    self.jobs = __TS__New(Map)
    self.activeJobBehaviour = nil
end
function __JobProcessor__.prototype.checkWork(self)
    if self.activeJobBehaviour then
        return
    end
    local job = self.jobs:values():next().value
    if not job then
        return
    end
    local offFns = {}
    local function offAll()
        return __TS__ArrayForEach(
            offFns,
            function(____, off)
                if not off(nil) then
                    error(
                        __TS__New(Error, "Failed to remove job event callback"),
                        0
                    )
                end
            end
        )
    end
    __TS__ArrayPush(
        offFns,
        EventLoop:on(
            JobEvent:start(job.id),
            function() return self:onJobStart(job.id) end
        ),
        EventLoop:on(
            JobEvent:pause(job.id),
            function() return self:onJobPause(job.id) end
        ),
        EventLoop:on(
            JobEvent:resume(job.id),
            function() return self:onJobResume(job.id) end
        ),
        EventLoop:on(
            JobEvent["end"](JobEvent, job.id),
            function()
                self:onJobEnd(job.id)
                offAll(nil)
            end,
            {async = true}
        ),
        EventLoop:on(
            JobEvent:error(job.id),
            function(____, e)
                self:onJobError(job.id, e)
                offAll(nil)
            end,
            {async = true}
        )
    )
    self.activeJobBehaviour = __TS__New(JobBehaviour, job)
    BehaviourStack:push(self.activeJobBehaviour)
end
function __JobProcessor__.prototype.add(self, jobRecord)
    if self.jobs:has(jobRecord.id) then
        error(
            __TS__New(
                Error,
                ("Job " .. tostring(jobRecord.id)) .. " already exists"
            ),
            0
        )
    end
    self.jobs:set(
        jobRecord.id,
        __TS__New(Job, jobRecord)
    )
    self:checkWork()
end
function __JobProcessor__.prototype.cancel(self, jobId)
    if not self.jobs:has(jobId) then
        return
    end
    local ____table_activeJobBehaviour_job_id_0 = self.activeJobBehaviour
    if ____table_activeJobBehaviour_job_id_0 ~= nil then
        ____table_activeJobBehaviour_job_id_0 = ____table_activeJobBehaviour_job_id_0.job.id
    end
    if ____table_activeJobBehaviour_job_id_0 == jobId then
        self.activeJobBehaviour.cancelled = true
    end
end
function __JobProcessor__.prototype.onJobStart(self, id)
    Logger:info("Job started", id)
end
function __JobProcessor__.prototype.onJobEnd(self, id)
    Logger:info("Job ended", id)
    local job = self.jobs:get(id)
    if not job then
        error(
            __TS__New(
                Error,
                "Missing job " .. tostring(id)
            ),
            0
        )
    end
    local ____table_activeJobBehaviour_cancelled_2 = self.activeJobBehaviour
    if ____table_activeJobBehaviour_cancelled_2 ~= nil then
        ____table_activeJobBehaviour_cancelled_2 = ____table_activeJobBehaviour_cancelled_2.cancelled
    end
    local cancelled = ____table_activeJobBehaviour_cancelled_2
    self.activeJobBehaviour = nil
    self.jobs:delete(id)
    self:checkWork()
    if not cancelled then
        local jobRegistryClient = __TS__New(JobRegistryClient, job.record.issuer_id)
        do
            local function ____catch(e)
                Logger:error(
                    ("Failed to report job " .. tostring(id)) .. " done",
                    e
                )
            end
            local ____try, ____hasReturned = pcall(function()
                jobRegistryClient:jobDone(job.id)
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
end
function __JobProcessor__.prototype.onJobError(self, id, err)
    Logger:info("Job threw an error", id)
    local job = self.jobs:get(id)
    if not job then
        error(
            __TS__New(
                Error,
                "Missing job " .. tostring(id)
            ),
            0
        )
    end
    local ____table_activeJobBehaviour_cancelled_4 = self.activeJobBehaviour
    if ____table_activeJobBehaviour_cancelled_4 ~= nil then
        ____table_activeJobBehaviour_cancelled_4 = ____table_activeJobBehaviour_cancelled_4.cancelled
    end
    local cancelled = ____table_activeJobBehaviour_cancelled_4
    self.activeJobBehaviour = nil
    self.jobs:delete(id)
    self:checkWork()
    if not cancelled then
        local jobRegistryClient = __TS__New(JobRegistryClient, job.record.issuer_id)
        do
            local function ____catch(e)
                Logger:error(
                    ("Failed to report job " .. tostring(id)) .. " failed",
                    e
                )
            end
            local ____try, ____hasReturned = pcall(function()
                jobRegistryClient:jobFailed(job.id, err)
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
end
function __JobProcessor__.prototype.onJobPause(self, id)
    Logger:info("Job paused", id)
end
function __JobProcessor__.prototype.onJobResume(self, id)
    Logger:info("Job resumed", id)
end
local JobProcessor = __TS__New(__JobProcessor__)
____exports.default = JobProcessor
return ____exports
