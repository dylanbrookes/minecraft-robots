--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____Consts = require("utils.Consts")
local ResourceRegistryCommand = ____Consts.ResourceRegistryCommand
local RESOURCE_REGISTRY_PROTOCOL_NAME = ____Consts.RESOURCE_REGISTRY_PROTOCOL_NAME
local ____findProtocolHostId = require("utils.findProtocolHostId")
local findProtocolHostId = ____findProtocolHostId.findProtocolHostId
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____ResourceRegistryClient = require("utils.clients.ResourceRegistryClient")
local ResourceRegistryClient = ____ResourceRegistryClient.ResourceRegistryClient
local hostId = findProtocolHostId(nil, RESOURCE_REGISTRY_PROTOCOL_NAME)
if not hostId then
    error(
        __TS__New(Error, "Could not find any job registry protocol hosts"),
        0
    )
end
Logger:info("Found host ID: " .. tostring(hostId))
local resourceRegistryClient = __TS__New(ResourceRegistryClient, hostId)
local ____temp_0 = {...}
local cmd = ____temp_0[1]
local params = __TS__ArraySlice(____temp_0, 1)
repeat
    local ____switch3 = string.upper(cmd)
    local ____cond3 = ____switch3 == ResourceRegistryCommand.LIST
    if ____cond3 then
        Logger:info(textutils.serialize(resourceRegistryClient:list()))
        break
    end
    ____cond3 = ____cond3 or ____switch3 == ResourceRegistryCommand.DELETE
    if ____cond3 then
        do
            local id = __TS__ParseInt(params[1])
            Logger:info(resourceRegistryClient:deleteById(id))
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == ResourceRegistryCommand.GET
    if ____cond3 then
        do
            local id = __TS__ParseInt(params[1])
            Logger:info(resourceRegistryClient:getById(id))
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == ResourceRegistryCommand.UPDATE
    if ____cond3 then
        do
            error(
                __TS__New(Error, "Not implemented"),
                0
            )
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == ResourceRegistryCommand.ADD
    if ____cond3 then
        do
            Logger:info("Locating...")
            local pos = {gps.locate(3)}
            if not pos or not pos[1] then
                error(
                    __TS__New(Error, "Failed to geolocate"),
                    0
                )
            end
            local feetPos = {
                math.floor(pos[1]),
                math.floor(pos[2]) - 1,
                math.floor(pos[3])
            }
            Logger:info(resourceRegistryClient:add({tags = params, position = feetPos}))
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == ResourceRegistryCommand.FIND
    if ____cond3 then
        do
            Logger:info("Locating...")
            local pos = {gps.locate(3)}
            if not pos or not pos[1] then
                error(
                    __TS__New(Error, "Failed to geolocate"),
                    0
                )
            end
            local feetPos = {
                math.floor(pos[1]),
                math.floor(pos[2]) - 1,
                math.floor(pos[3])
            }
            Logger:info(resourceRegistryClient:find(params, feetPos))
        end
        break
    end
    do
        error(
            __TS__New(Error, "Unknown command: " .. cmd),
            0
        )
    end
until true
return ____exports
