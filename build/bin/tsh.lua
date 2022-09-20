--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____Consts = require("utils.Consts")
local TURTLE_PROTOCOL_NAME = ____Consts.TURTLE_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____findProtocolHostId = require("utils.findProtocolHostId")
local findProtocolHostId = ____findProtocolHostId.findProtocolHostId
local modem = peripheral.find("modem")
if not modem then
    error(
        __TS__New(Error, "Could not find modem"),
        0
    )
end
local modemName = peripheral.getName(modem)
rednet.open(modemName)
local hostId = findProtocolHostId(nil, TURTLE_PROTOCOL_NAME)
if not hostId then
    error(
        __TS__New(Error, "Could not find any agent protocol hosts"),
        0
    )
end
local ____temp_0 = {...}
local cmd = ____temp_0[1]
local params = __TS__ArraySlice(____temp_0, 1)
local function sendCmd(____, cmd, ...)
    local params = {...}
    rednet.send(hostId, {cmd = cmd, params = params}, TURTLE_PROTOCOL_NAME)
end
if cmd == nil then
    print("Entering interactive mode")
    EventLoop:on(
        "char",
        function(____, char)
            repeat
                local ____switch7 = char
                local ____cond7 = ____switch7 == "w"
                if ____cond7 then
                    do
                        sendCmd(nil, "forward", 1, false)
                    end
                    break
                end
                ____cond7 = ____cond7 or ____switch7 == "s"
                if ____cond7 then
                    do
                        sendCmd(nil, "back", 1, false)
                    end
                    break
                end
                ____cond7 = ____cond7 or ____switch7 == "a"
                if ____cond7 then
                    do
                        sendCmd(nil, "turnLeft", false)
                    end
                    break
                end
                ____cond7 = ____cond7 or ____switch7 == "d"
                if ____cond7 then
                    do
                        sendCmd(nil, "turnRight", false)
                    end
                    break
                end
                do
                    print("unknown char", char)
                end
            until true
            return false
        end
    )
    EventLoop:run()
elseif cmd == "." then
    print("Locating...")
    local pos = {gps.locate(3)}
    if not pos or not pos[1] then
        error(
            __TS__New(Error, "Failed to geolocate"),
            0
        )
    end
    sendCmd(
        nil,
        "moveTo",
        math.floor(pos[1]),
        math.floor(pos[2]) - 1,
        math.floor(pos[3])
    )
else
    print(
        "Sending",
        cmd,
        "with params:",
        __TS__Unpack(params)
    )
    sendCmd(
        nil,
        cmd,
        __TS__Unpack(params)
    )
end
return ____exports
