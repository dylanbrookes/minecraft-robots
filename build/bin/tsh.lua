--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____Consts = require("utils.Consts")
local TURTLE_PROTOCOL_NAME = ____Consts.TURTLE_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____TurtleService = require("utils.services.TurtleService")
local TurtleCommands = ____TurtleService.TurtleCommands
local ____JobStore = require("utils.stores.JobStore")
local JobStatus = ____JobStore.JobStatus
local ____Consts = require("utils.turtle.Consts")
local JobType = ____Consts.JobType
local ____LocationMonitor = require("utils.LocationMonitor")
local Heading = ____LocationMonitor.Heading
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local modem = peripheral.find("modem")
if not modem then
    error(
        __TS__New(Error, "Could not find modem"),
        0
    )
end
local modemName = peripheral.getName(modem)
rednet.open(modemName)
local ____temp_0 = {...}
local hostIdArg = ____temp_0[1]
local cmd = ____temp_0[2]
local params = __TS__ArraySlice(____temp_0, 2)
if not hostIdArg then
    error(
        __TS__New(Error, "host id required (use all to broadcast)"),
        0
    )
end
local broadcast = string.lower(hostIdArg) == "all"
local function sendCmd(____, cmd, ...)
    local params = {...}
    if broadcast then
        rednet.send(
            __TS__ParseInt(hostIdArg),
            {cmd = cmd, params = params},
            TURTLE_PROTOCOL_NAME
        )
    else
        rednet.broadcast({cmd = cmd, params = params}, TURTLE_PROTOCOL_NAME)
    end
end
if cmd == nil then
    Logger:info("Entering interactive mode")
    EventLoop:on(
        "char",
        function(____, char)
            repeat
                local ____switch9 = char
                local ____cond9 = ____switch9 == "w"
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.forward, 1, false)
                    end
                    break
                end
                ____cond9 = ____cond9 or ____switch9 == "s"
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.back, 1, false)
                    end
                    break
                end
                ____cond9 = ____cond9 or ____switch9 == "a"
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.turnLeft, false)
                    end
                    break
                end
                ____cond9 = ____cond9 or ____switch9 == "d"
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.turnRight, false)
                    end
                    break
                end
                ____cond9 = ____cond9 or ____switch9 == "q"
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.up, 1, false)
                    end
                    break
                end
                ____cond9 = ____cond9 or ____switch9 == "e"
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.down, 1, false)
                    end
                    break
                end
                ____cond9 = ____cond9 or ____switch9 == " "
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.dig, false)
                    end
                    break
                end
                ____cond9 = ____cond9 or ____switch9 == "?"
                if ____cond9 then
                    do
                        sendCmd(nil, TurtleCommands.inspect, false)
                        local pid, message = rednet.receive(TURTLE_PROTOCOL_NAME, 3)
                        if not pid then
                            error(
                                __TS__New(
                                    Error,
                                    "No response to command " .. tostring(cmd)
                                ),
                                0
                            )
                        end
                        Logger:info(message)
                    end
                    break
                end
                do
                    Logger:warn("unknown char", char)
                end
            until true
            return false
        end
    )
    EventLoop:run()
elseif cmd == "." then
    Logger:info("Locating...")
    local pos = {gps.locate(3)}
    if not pos or not pos[1] then
        error(
            __TS__New(Error, "Failed to geolocate"),
            0
        )
    end
    sendCmd(
        nil,
        TurtleCommands.moveTo,
        math.floor(pos[1]),
        math.floor(pos[2]) - 1,
        math.floor(pos[3])
    )
elseif cmd == "spin" then
    Logger:info("Making it spin...")
    sendCmd(
        nil,
        TurtleCommands.addJob,
        {
            id = 1,
            type = JobType.spin,
            args = {12},
            resume_counter = 0,
            status = JobStatus.IN_PROGRESS,
            issuer_id = os.computerID()
        }
    )
elseif cmd == "clear" then
    local ____params_1 = params
    local headingParam = ____params_1[1]
    local dimensions = __TS__ArraySlice(____params_1, 1)
    local heading = Heading.UNKNOWN
    repeat
        local ____switch23 = string.lower(headingParam)
        local ____cond23 = ____switch23 == "n" or ____switch23 == "north"
        if ____cond23 then
            heading = Heading.NORTH
            break
        end
        ____cond23 = ____cond23 or (____switch23 == "s" or ____switch23 == "south")
        if ____cond23 then
            heading = Heading.SOUTH
            break
        end
        ____cond23 = ____cond23 or (____switch23 == "w" or ____switch23 == "west")
        if ____cond23 then
            heading = Heading.WEST
            break
        end
        ____cond23 = ____cond23 or (____switch23 == "e" or ____switch23 == "east")
        if ____cond23 then
            heading = Heading.EAST
            break
        end
    until true
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
    sendCmd(
        nil,
        TurtleCommands.addJob,
        {
            id = 1,
            type = JobType.clear,
            args = {
                feetPos,
                heading,
                {
                    __TS__ParseInt(dimensions[1]),
                    __TS__ParseInt(dimensions[2]),
                    __TS__ParseInt(dimensions[3])
                }
            },
            resume_counter = 0,
            status = JobStatus.IN_PROGRESS,
            issuer_id = os.computerID()
        }
    )
elseif cmd == "status" then
    Logger:info("Requesting status...")
    sendCmd(nil, cmd)
    local ____, message = rednet.receive(TURTLE_PROTOCOL_NAME, 3)
    Logger:info("Response:", message)
else
    Logger:info(
        "Sending",
        cmd,
        "with params:",
        table.unpack(params)
    )
    sendCmd(
        nil,
        cmd,
        table.unpack(params)
    )
end
return ____exports
