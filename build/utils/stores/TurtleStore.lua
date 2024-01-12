--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
____exports.TurtleStatus = TurtleStatus or ({})
____exports.TurtleStatus.OFFLINE = "OFFLINE"
____exports.TurtleStatus.IDLE = "IDLE"
____exports.TurtleStatus.BUSY = "BUSY"
____exports.default = __TS__Class()
local TurtleStore = ____exports.default
TurtleStore.name = "TurtleStore"
function TurtleStore.prototype.____constructor(self, storeFile)
    if storeFile == nil then
        storeFile = ____exports.default.DEFAULT_STORE_FILE
    end
    self.storeFile = storeFile
    self.turtles = ____exports.default:LoadStoreFile(storeFile)
    Logger:info("TurtleStore loaded with", self.turtles.size, "turtles")
end
TurtleStore.prototype[Symbol.iterator] = function(self)
    return self.turtles:values()
end
function TurtleStore.LoadStoreFile(self, storeFile)
    local turtles = __TS__New(Map)
    if not fs.exists(storeFile) then
        Logger:info("Starting without turtle store file")
        return turtles
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
        local res, err = textutils.unserializeJSON(line)
        if res == nil then
            error(
                __TS__New(
                    Error,
                    "Failed to deserialize turtle: " .. tostring(err)
                ),
                0
            )
        end
        local turtle = res
        if type(turtle.id) ~= "number" then
            error(
                __TS__New(Error, "Invalid turtle parsed from: " .. line),
                0
            )
        end
        turtle.status = ____exports.TurtleStatus.OFFLINE
        turtles:set(turtle.id, turtle)
    end
    return turtles
end
function TurtleStore.prototype.save(self)
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
    for ____, job in __TS__Iterator(self.turtles:values()) do
        handle.writeLine(textutils.serializeJSON(job))
    end
    handle.flush()
    handle.close()
    Logger:debug("Saved to storefile", self.storeFile)
end
function TurtleStore.prototype.__tostring(self)
    local jobs = {}
    for ____, job in __TS__Iterator(self.turtles:values()) do
        jobs[#jobs + 1] = job
    end
    return textutils.serialize(jobs, {compact = true})
end
function TurtleStore.prototype.exists(self, id)
    return self.turtles:has(id)
end
function TurtleStore.prototype.get(self, id)
    return self.turtles:get(id)
end
function TurtleStore.prototype.select(self, filter)
    if filter == nil then
        filter = function() return true end
    end
    return __TS__ArrayFilter(
        {__TS__Spread(self.turtles:values())},
        filter
    )
end
function TurtleStore.prototype.count(self)
    return self.turtles.size
end
function TurtleStore.prototype.add(self, record)
    if self:exists(record.id) then
        error(
            __TS__New(
                Error,
                "TurtleRecord already exists for id " .. tostring(record.id)
            ),
            0
        )
    end
    self.turtles:set(record.id, record)
end
function TurtleStore.prototype.update(self, id, record)
    local turtleRecord = self.turtles:get(id)
    if not turtleRecord then
        error(
            __TS__New(
                Error,
                "Can't update: TurtleRecord doesn't exist for id " .. tostring(id)
            ),
            0
        )
    end
    __TS__ObjectAssign(turtleRecord, record)
    return turtleRecord
end
TurtleStore.DEFAULT_STORE_FILE = "/.turtlestore"
____exports.default = TurtleStore
return ____exports
