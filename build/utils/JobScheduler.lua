--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____TurtleClient = require("utils.clients.TurtleClient")
local TurtleClient = ____TurtleClient.TurtleClient
local ____Consts = require("utils.Consts")
local JobRegistryEvent = ____Consts.JobRegistryEvent
local TurtleControlEvent = ____Consts.TurtleControlEvent
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____JobStore = require("utils.stores.JobStore")
local JobStatus = ____JobStore.JobStatus
local ____TurtleStore = require("utils.stores.TurtleStore")
local TurtleStatus = ____TurtleStore.TurtleStatus
local ____Job = require("utils.turtle.jobs.Job")
local Job = ____Job.default
____exports.default = __TS__Class()
local JobScheduler = ____exports.default
JobScheduler.name = "JobScheduler"
function JobScheduler.prototype.____constructor(self, jobStore, turtleStore)
    self.jobStore = jobStore
    self.turtleStore = turtleStore
    self.registered = false
    self.schedulingInProgress = false
end
function JobScheduler.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "JobScheduler is already registered"),
            0
        )
    end
    self.registered = true
    Logger:info("Registering Job Scheduler")
    EventLoop:on(
        ____exports.default.SCHEDULE_JOBS_EVENT,
        function() return self:scheduleJobs() end,
        {async = true}
    )
    EventLoop:emitRepeat(____exports.default.SCHEDULE_JOBS_EVENT, ____exports.default.SCHEDULE_JOBS_INTERVAL)
    EventLoop:setTimeout(function() return EventLoop:emit(____exports.default.SCHEDULE_JOBS_EVENT) end)
    EventLoop:on(
        JobRegistryEvent.JOB_DONE,
        function() return self:scheduleJobs() end,
        {async = true}
    )
    EventLoop:on(
        TurtleControlEvent.TURTLE_IDLE,
        function() return self:scheduleJobs() end,
        {async = true}
    )
    EventLoop:on(
        TurtleControlEvent.TURTLE_OFFLINE,
        function(____, id) return self:onTurtleOffline(id) end
    )
end
function JobScheduler.prototype.onTurtleOffline(self, id)
    local assignedJobs = self.jobStore:select(function(____, ____bindingPattern0)
        local turtle_id
        local status
        status = ____bindingPattern0.status
        turtle_id = ____bindingPattern0.turtle_id
        return status == JobStatus.IN_PROGRESS and turtle_id == id
    end)
    for ____, job in ipairs(assignedJobs) do
        Logger:info(("Releasing job " .. tostring(job.id)) .. " to be retried")
        self.jobStore:updateById(job.id, {status = JobStatus.HALTED})
    end
    if #assignedJobs > 0 then
        self.jobStore:save()
    end
end
function JobScheduler.prototype.scheduleJobs(self)
    if self.schedulingInProgress then
        Logger:debug("Skipping job scheduling, already in progress")
        return
    end
    self.schedulingInProgress = true
    local assignedTurtleIds = __TS__New(
        Set,
        __TS__ArrayFilter(
            __TS__ArrayMap(
                self.jobStore:select(function(____, ____bindingPattern0)
                    local status
                    status = ____bindingPattern0.status
                    return status == JobStatus.IN_PROGRESS
                end),
                function(____, ____bindingPattern0)
                    local turtle_id
                    turtle_id = ____bindingPattern0.turtle_id
                    return turtle_id
                end
            ),
            function(____, id) return id ~= nil end
        )
    )
    local availableTurtles = self.turtleStore:select(function(____, ____bindingPattern0)
        local status
        local id
        id = ____bindingPattern0.id
        status = ____bindingPattern0.status
        return status == TurtleStatus.IDLE and not assignedTurtleIds:has(id)
    end)
    if #availableTurtles == 0 then
        Logger:info("All idle turtles are assigned a job")
        self.schedulingInProgress = false
        return
    end
    for ____, job in ipairs(__TS__ArrayMap(
        self.jobStore:select(function(____, ____bindingPattern0)
            local status
            status = ____bindingPattern0.status
            return __TS__ArrayIncludes({JobStatus.PENDING, JobStatus.HALTED}, status)
        end),
        function(____, jobRecord) return __TS__New(Job, jobRecord) end
    )) do
        local turtleFitnesses = nil
        do
            local function ____catch(____error)
                Logger:error(
                    ((("Error while evaluating fitness for job " .. tostring(job.id)) .. " (") .. job.type) .. "):",
                    ____error
                )
                self.jobStore:updateById(job.id, {status = JobStatus.FAILED, error = ____error})
                self.jobStore:save()
            end
            local ____try, ____hasReturned = pcall(function()
                turtleFitnesses = __TS__ArraySort(
                    __TS__ArrayFilter(
                        __TS__ArrayMap(
                            availableTurtles,
                            function(____, turtleRecord) return {
                                turtleRecord,
                                job:turtleFitness(turtleRecord)
                            } end
                        ),
                        function(____, v) return v[2] ~= false end
                    ),
                    function(____, a, b) return b[2] - a[2] end
                )
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
        if turtleFitnesses then
            if #turtleFitnesses == 0 then
                Logger:warn(((("No available turtles can perform job " .. job.record.type) .. " [") .. tostring(job.id)) .. "]")
            else
                for ____, ____value in ipairs(turtleFitnesses) do
                    local turtle = ____value[1]
                    local success = self:assignJobToTurtle(job, turtle)
                    if success then
                        assert(job.record.status == JobStatus.IN_PROGRESS)
                        availableTurtles = __TS__ArrayFilter(
                            availableTurtles,
                            function(____, ____bindingPattern0)
                                local id
                                id = ____bindingPattern0.id
                                return id ~= turtle.id
                            end
                        )
                        break
                    end
                end
                if #availableTurtles == 0 then
                    break
                end
            end
        end
    end
    local pendingJobs = self.jobStore:select(function(____, ____bindingPattern0)
        local status
        status = ____bindingPattern0.status
        return status == JobStatus.PENDING
    end)
    if #pendingJobs > 0 then
        Logger:info("Pending jobs: " .. tostring(#pendingJobs))
    end
    self.schedulingInProgress = false
end
function JobScheduler.prototype.assignJobToTurtle(self, job, turtleRecord)
    Logger:info(((((((("Assigning job " .. job.record.type) .. " [") .. tostring(job.id)) .. "] to turtle ") .. turtleRecord.label) .. " [") .. tostring(turtleRecord.id)) .. "]")
    local turtleClient = __TS__New(TurtleClient, turtleRecord.id)
    do
        local function ____catch(e)
            Logger:error("Failed to assign job to turtle", e)
            return true, false
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            turtleClient:addJob(job.record)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
    self.jobStore:updateById(job.id, {turtle_id = turtleRecord.id, status = JobStatus.IN_PROGRESS})
    self.jobStore:save()
    return true
end
JobScheduler.SCHEDULE_JOBS_EVENT = "JobScheduler:schedule_jobs"
JobScheduler.SCHEDULE_JOBS_INTERVAL = 5
____exports.default = JobScheduler
return ____exports
