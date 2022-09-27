--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
____exports.ResourceStore = __TS__Class()
local ResourceStore = ____exports.ResourceStore
ResourceStore.name = "ResourceStore"
function ResourceStore.prototype.____constructor(self, storeFile)
    if storeFile == nil then
        storeFile = ____exports.ResourceStore.DEFAULT_STORE_FILE
    end
    self.storeFile = storeFile
    self.maxId = -1
    local ____temp_0 = ____exports.ResourceStore:LoadStoreFile(self.storeFile)
    self.resources = ____temp_0[1]
    self.maxId = ____temp_0[2]
    Logger:info("N resources:", self.resources.size)
    Logger:info("Max ID:", self.maxId)
end
ResourceStore.prototype[Symbol.iterator] = function(self)
    return self.resources:values()
end
function ResourceStore.prototype.select(self, filter)
    if filter == nil then
        filter = function() return true end
    end
    return __TS__ArrayFilter(
        {__TS__Spread(self.resources:values())},
        filter
    )
end
function ResourceStore.LoadStoreFile(self, storeFile)
    local resources = __TS__New(Map)
    local maxId = 0
    if not fs.exists(storeFile) then
        Logger:debug("Starting without store file")
        return {resources, maxId}
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
        local resource = textutils.unserialize(line)
        if type(resource.id) ~= "number" then
            error(
                __TS__New(Error, "Invalid resource parsed from: " .. line),
                0
            )
        end
        resources:set(resource.id, resource)
        if resource.id > maxId then
            maxId = resource.id
        end
    end
    return {resources, maxId}
end
function ResourceStore.prototype.getById(self, id)
    return self.resources:get(id)
end
function ResourceStore.prototype.removeById(self, id)
    return self.resources:delete(id)
end
function ResourceStore.prototype.updateById(self, id, changes)
    local resource = self.resources:get(id)
    if not resource then
        return nil
    end
    __TS__ObjectAssign(resource, changes)
    return resource
end
function ResourceStore.prototype.list(self)
    Logger:info("Resources:")
    for ____, resource in __TS__Iterator(self.resources:values()) do
        Logger:info(textutils.serializeJSON(resource, true))
    end
end
function ResourceStore.prototype.add(self, resourceRecord)
    local ____self_1, ____maxId_2 = self, "maxId"
    local ____self_maxId_3 = ____self_1[____maxId_2] + 1
    ____self_1[____maxId_2] = ____self_maxId_3
    local resource = __TS__ObjectAssign({id = ____self_maxId_3}, resourceRecord)
    self.resources:set(resource.id, resource)
    return resource
end
function ResourceStore.prototype.save(self)
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
    for ____, resource in __TS__Iterator(self.resources:values()) do
        handle.writeLine(textutils.serialize(resource, {compact = true}))
    end
    handle.flush()
    handle.close()
    Logger:debug("Saved to storefile", self.storeFile)
end
function ResourceStore.prototype.__tostring(self)
    local resources = {}
    for ____, resource in __TS__Iterator(self.resources:values()) do
        resources[#resources + 1] = resource
    end
    return textutils.serialize(resources, {compact = true})
end
ResourceStore.DEFAULT_STORE_FILE = "/.resourcestore"
return ____exports
