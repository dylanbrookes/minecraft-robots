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
    local offFns
    offFns = {
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
                __TS__ArrayForEach(
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
            end,
            {async = true}
        )
    }
    BehaviourStack:push(__TS__New(JobBehaviour, job))
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
    self.activeJobBehaviour = nil
    self.jobs:delete(id)
    self:checkWork()
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
function __JobProcessor__.prototype.onJobPause(self, id)
    Logger:info("Job paused", id)
end
function __JobProcessor__.prototype.onJobResume(self, id)
    Logger:info("Job resumed", id)
end
local JobProcessor = __TS__New(__JobProcessor__)
____exports.default = JobProcessor
return ____exports
