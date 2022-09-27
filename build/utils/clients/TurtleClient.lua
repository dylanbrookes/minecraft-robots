--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local TURTLE_PROTOCOL_NAME = ____Consts.TURTLE_PROTOCOL_NAME
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____TurtleService = require("utils.services.TurtleService")
local TurtleCommands = ____TurtleService.TurtleCommands
____exports.TurtleClient = __TS__Class()
local TurtleClient = ____exports.TurtleClient
TurtleClient.name = "TurtleClient"
function TurtleClient.prototype.____constructor(self, hostId)
    self.hostId = hostId
end
function TurtleClient.prototype.call(self, cmd, params, timeout, assertResp)
    if params == nil then
        params = {}
    end
    if timeout == nil then
        timeout = 3
    end
    if assertResp == nil then
        assertResp = true
    end
    rednet.send(self.hostId, {cmd = cmd, params = params}, TURTLE_PROTOCOL_NAME)
    Logger:debug("Sent cmd, waiting for resp...")
    local pid, message = rednet.receive(TURTLE_PROTOCOL_NAME, timeout)
    if not pid and assertResp then
        error(
            __TS__New(Error, "No response to command " .. cmd),
            0
        )
    end
    return message
end
function TurtleClient.prototype.addJob(self, jobRecord)
    local resp = self:call(TurtleCommands.addJob, jobRecord)
    local ____resp_ok_0 = resp
    if ____resp_ok_0 ~= nil then
        ____resp_ok_0 = ____resp_ok_0.ok
    end
    if not ____resp_ok_0 then
        error(
            __TS__New(
                Error,
                "Response didn't contain ok: " .. textutils.serialize(resp)
            ),
            0
        )
    end
end
function TurtleClient.prototype.status(self)
    local resp = self:call(TurtleCommands.status, {}, 1, false)
    local ____resp_ok_2 = resp
    if ____resp_ok_2 ~= nil then
        ____resp_ok_2 = ____resp_ok_2.ok
    end
    if not ____resp_ok_2 then
        return nil
    end
    return resp.status
end
return ____exports
