--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
____exports.JobStatus = JobStatus or ({})
____exports.JobStatus.PENDING = "PENDING"
____exports.JobStatus.IN_PROGRESS = "IN_PROGRESS"
____exports.JobStatus.PAUSED = "PAUSED"
____exports.JobStatus.HALTED = "HALTED"
____exports.JobStatus.DONE = "DONE"
____exports.JobStatus.CANCELLED = "CANCELLED"
____exports.JobStatus.FAILED = "FAILED"
____exports.JobStore = __TS__Class()
local JobStore = ____exports.JobStore
JobStore.name = "JobStore"
function JobStore.prototype.____constructor(self, storeFile)
    if storeFile == nil then
        storeFile = ____exports.JobStore.DEFAULT_STORE_FILE
    end
    self.storeFile = storeFile
    self.maxId = -1
    local ____temp_0 = ____exports.JobStore:LoadStoreFile(self.storeFile)
    self.jobs = ____temp_0[1]
    self.maxId = ____temp_0[2]
    Logger:info("N jobs:", self.jobs.size)
    Logger:info("Max ID:", self.maxId)
end
JobStore.prototype[Symbol.iterator] = function(self)
    return self.jobs:values()
end
function JobStore.prototype.select(self, filter)
    if filter == nil then
        filter = function() return true end
    end
    return __TS__ArrayFilter(
        {__TS__Spread(self.jobs:values())},
        filter
    )
end
function JobStore.LoadStoreFile(self, storeFile)
    local jobs = __TS__New(Map)
    local maxId = 0
    if not fs.exists(storeFile) then
        Logger:debug("Starting without store file")
        return {jobs, maxId}
    end
    local handle, err = fs.open(storeFile, "r")
    if not handle then
        error(
            __TS__New(
                Error,
                (("Failed to open storeFile " .. storeFile) .. " error: ") .. tostring(err)
            ),
            0
        )
    end
    local line
    while true do
        line = handle.readLine()
        if not line then
            break
        end
        local job = textutils.unserialize(line)
        if type(job.id) ~= "number" then
            error(
                __TS__New(Error, "Invalid job parsed from: " .. line),
                0
            )
        end
        jobs:set(job.id, job)
        if job.id > maxId then
            maxId = job.id
        end
    end
    return {jobs, maxId}
end
function JobStore.prototype.getById(self, id)
    return self.jobs:get(id)
end
function JobStore.prototype.removeById(self, id)
    return self.jobs:delete(id)
end
function JobStore.prototype.updateById(self, id, changes)
    local job = self.jobs:get(id)
    if not job then
        return nil
    end
    __TS__ObjectAssign(job, changes)
    return job
end
function JobStore.prototype.list(self)
    Logger:info("Jobs:")
    for ____, job in __TS__Iterator(self.jobs:values()) do
        Logger:info(textutils.serializeJSON(job, true))
    end
end
function JobStore.prototype.add(self, jobRecord)
    local ____self_1, ____maxId_2 = self, "maxId"
    local ____self_maxId_3 = ____self_1[____maxId_2] + 1
    ____self_1[____maxId_2] = ____self_maxId_3
    local job = __TS__ObjectAssign(
        {
            id = ____self_maxId_3,
            resume_counter = 0,
            status = ____exports.JobStatus.PENDING,
            error = nil,
            resume_state = nil,
            turtle_id = nil,
            issuer_id = os.computerID()
        },
        jobRecord
    )
    self.jobs:set(job.id, job)
    return job
end
function JobStore.prototype.save(self)
    if fs.exists(self.storeFile) then
        Logger:debug("Overwriting store file", self.storeFile)
    end
    local handle, err = fs.open(self.storeFile, "w")
    if not handle then
        error(
            __TS__New(
                Error,
                (("Failed to open storeFile " .. self.storeFile) .. " for writing, error: ") .. tostring(err)
            ),
            0
        )
    end
    for ____, job in __TS__Iterator(self.jobs:values()) do
        handle.writeLine(textutils.serialize(job, {compact = true}))
    end
    handle.flush()
    handle.close()
    Logger:debug("Saved to storefile", self.storeFile)
end
function JobStore.prototype.__tostring(self)
    local jobs = {}
    for ____, job in __TS__Iterator(self.jobs:values()) do
        jobs[#jobs + 1] = job
    end
    return textutils.serialize(jobs, {compact = true})
end
JobStore.DEFAULT_STORE_FILE = "/.jobstore"
return ____exports
