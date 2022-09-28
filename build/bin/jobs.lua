--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____Consts = require("utils.Consts")
local JobRegistryCommand = ____Consts.JobRegistryCommand
local JOB_REGISTRY_PROTOCOL_NAME = ____Consts.JOB_REGISTRY_PROTOCOL_NAME
local ____findProtocolHostId = require("utils.findProtocolHostId")
local findProtocolHostId = ____findProtocolHostId.findProtocolHostId
local ____JobRegistryClient = require("utils.clients.JobRegistryClient")
local JobRegistryClient = ____JobRegistryClient.JobRegistryClient
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local JobType = ____Consts.JobType
local ____parseHeadingParam = require("utils.parseHeadingParam")
local parseHeadingParam = ____parseHeadingParam.default
local hostId = findProtocolHostId(nil, JOB_REGISTRY_PROTOCOL_NAME)
if not hostId then
    error(
        __TS__New(Error, "Could not find any job registry protocol hosts"),
        0
    )
end
Logger:info("Found host ID: " .. tostring(hostId))
local jobRegistryClient = __TS__New(JobRegistryClient, hostId)
local ____temp_0 = {...}
local cmd = ____temp_0[1]
local params = __TS__ArraySlice(____temp_0, 1)
repeat
    local ____switch3 = string.upper(cmd)
    local ____cond3 = ____switch3 == JobRegistryCommand.LIST
    if ____cond3 then
        Logger:info(textutils.serialize(jobRegistryClient:list()))
        break
    end
    ____cond3 = ____cond3 or ____switch3 == JobRegistryCommand.DELETE
    if ____cond3 then
        do
            local id = __TS__ParseInt(params[1])
            Logger:info(jobRegistryClient:deleteById(id))
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == JobRegistryCommand.DELETE_DONE
    if ____cond3 then
        do
            Logger:info(jobRegistryClient:deleteDone())
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == JobRegistryCommand.GET
    if ____cond3 then
        do
            local id = __TS__ParseInt(params[1])
            Logger:info(jobRegistryClient:getById(id))
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == JobRegistryCommand.UPDATE
    if ____cond3 then
        do
            error(
                __TS__New(Error, "Not implemented"),
                0
            )
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == JobRegistryCommand.ADD
    if ____cond3 then
        do
            local ____params_1 = params
            local ____type = ____params_1[1]
            local args = __TS__ArraySlice(____params_1, 1)
            Logger:info(jobRegistryClient:add(____type, args))
        end
        break
    end
    ____cond3 = ____cond3 or ____switch3 == "CLEAR"
    if ____cond3 then
        do
            local ____params_2 = params
            local headingParam = ____params_2[1]
            local dimensions = __TS__ArraySlice(____params_2, 1)
            local heading = parseHeadingParam(nil, headingParam)
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
            Logger:info(
                "Clearing...",
                textutils.serialize(feetPos),
                heading,
                dimensions
            )
            Logger:info(jobRegistryClient:add(
                JobType.clear,
                {
                    feetPos,
                    heading,
                    {
                        __TS__ParseInt(dimensions[1]),
                        __TS__ParseInt(dimensions[2]),
                        __TS__ParseInt(dimensions[3])
                    }
                }
            ))
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
