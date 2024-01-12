--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.TaskStatus = TaskStatus or ({})
____exports.TaskStatus.TODO = "TODO"
____exports.TaskStatus.IN_PROGRESS = "IN_PROGRESS"
____exports.TaskStatus.DONE = "DONE"
____exports.default = __TS__Class()
local TaskStore = ____exports.default
TaskStore.name = "TaskStore"
function TaskStore.prototype.____constructor(self, storeFile)
    if storeFile == nil then
        storeFile = ____exports.default.DEFAULT_STORE_FILE
    end
    self.storeFile = storeFile
    local ____temp_0 = ____exports.default:LoadStoreFile(storeFile)
    local nextTaskId = ____temp_0.nextTaskId
    local tasks = ____temp_0.tasks
    self.nextTaskId = nextTaskId
    self.tasks = tasks
    print("TaskStore loaded with", self.tasks.size, "tasks")
end
function TaskStore.LoadStoreFile(self, storeFile)
    local tasks = __TS__New(Map)
    if not fs.exists(storeFile) then
        print("Creating new task store file")
        return {nextTaskId = 1, tasks = tasks}
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
    local maxId = 0
    local line
    while true do
        line = handle.readLine()
        if not line then
            break
        end
        local res, err = textutils.unserializeJSON(line)
        if res == nil then
            error(
                __TS__New(
                    Error,
                    "Failed to deserialize resource: " .. tostring(err)
                ),
                0
            )
        end
        local task = res
        if type(task.id) ~= "number" then
            error(
                __TS__New(Error, "Invalid task parsed from: " .. line),
                0
            )
        end
        tasks:set(task.id, task)
        if task.id > maxId then
            maxId = task.id
        end
    end
    return {nextTaskId = maxId + 1, tasks = tasks}
end
function TaskStore.prototype.save(self)
    if fs.exists(self.storeFile) then
        print("Overwriting store file", self.storeFile)
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
    for ____, task in __TS__Iterator(self.tasks:values()) do
        handle.writeLine(textutils.serializeJSON(task))
    end
    handle.flush()
    handle.close()
    print("Saved to storefile", self.storeFile)
end
function TaskStore.prototype.__tostring(self)
    local tasks = {}
    for ____, task in __TS__Iterator(self.tasks:values()) do
        tasks[#tasks + 1] = task
    end
    return textutils.serialize(tasks, {compact = true})
end
function TaskStore.prototype.exists(self, id)
    return self.tasks:has(id)
end
function TaskStore.prototype.get(self, id)
    return self.tasks:get(id)
end
function TaskStore.prototype.getAll(self)
    return {__TS__Spread(self.tasks:values())}
end
function TaskStore.prototype.count(self)
    return self.tasks.size
end
function TaskStore.prototype.add(self, record)
    local ____self_1, ____nextTaskId_2 = self, "nextTaskId"
    local ____self_nextTaskId_3 = ____self_1[____nextTaskId_2]
    ____self_1[____nextTaskId_2] = ____self_nextTaskId_3 + 1
    local id = ____self_nextTaskId_3
    self.tasks:set(
        id,
        __TS__ObjectAssign({id = id}, record)
    )
end
function TaskStore.prototype.update(self, id, record)
    local og = self.tasks:get(id)
    if not og then
        error(
            __TS__New(
                Error,
                "Can't update: TaskRecord doesn't exist for id " .. tostring(id)
            ),
            0
        )
    end
    local newRecord = __TS__ObjectAssign({}, og, record)
    self.tasks:set(id, newRecord)
    return newRecord
end
function TaskStore.prototype.remove(self, id)
    self.tasks:delete(id)
end
TaskStore.DEFAULT_STORE_FILE = "/.tasks"
____exports.default = TaskStore
return ____exports
