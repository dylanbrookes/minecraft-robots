--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____JobRegistryClient = require("utils.clients.JobRegistryClient")
local JobRegistryClient = ____JobRegistryClient.JobRegistryClient
local ____Consts = require("utils.Consts")
local JOB_REGISTRY_PROTOCOL_NAME = ____Consts.JOB_REGISTRY_PROTOCOL_NAME
local ____findProtocolHostId = require("utils.findProtocolHostId")
local findProtocolHostId = ____findProtocolHostId.findProtocolHostId
local ____LocationMonitor = require("utils.LocationMonitor")
local Heading = ____LocationMonitor.Heading
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local JobType = ____Consts.JobType
local hostId = findProtocolHostId(nil, JOB_REGISTRY_PROTOCOL_NAME)
if not hostId then
    error(
        __TS__New(Error, "Could not find any job registry protocol hosts"),
        0
    )
end
Logger:info("Found host ID: " .. tostring(hostId))
local jobRegistryClient = __TS__New(JobRegistryClient, hostId)
local CHUNK_SIZE = 3
local values = {...}
local x0p, z0p, x1p, z1p, y, h = table.unpack(__TS__ArrayMap(
    values,
    function(____, v) return __TS__ParseInt(v) end
))
local x0, z0, x1, z1 = math.min(x0p, x1p), math.min(z0p, z1p), math.max(x0p, x1p), math.max(z0p, z1p)
local regions = {}
do
    local x = x0
    while x <= x1 do
        do
            local z = z0
            while z <= z1 do
                regions[#regions + 1] = {
                    {x, y, z},
                    {
                        math.min(x1 - x, CHUNK_SIZE),
                        h,
                        math.min(z1 - z, CHUNK_SIZE)
                    }
                }
                z = z + CHUNK_SIZE
            end
        end
        x = x + CHUNK_SIZE
    end
end
Logger:info(("Submitting " .. tostring(#regions)) .. " jobs...")
for ____, ____value in ipairs(regions) do
    local position = ____value[1]
    local dimensions = ____value[2]
    jobRegistryClient:add(JobType.clear, {position, Heading.EAST, dimensions})
end
Logger:info("Done.")
return ____exports
