--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Consts = require("utils.Consts")
local HOSTNAME = ____Consts.HOSTNAME
local JobRegistryCommand = ____Consts.JobRegistryCommand
local JobRegistryEvent = ____Consts.JobRegistryEvent
local JOB_REGISTRY_PROTOCOL_NAME = ____Consts.JOB_REGISTRY_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____JobStore = require("utils.stores.JobStore")
local JobStatus = ____JobStore.JobStatus
____exports.default = __TS__Class()
local JobRegistryService = ____exports.default
JobRegistryService.name = "JobRegistryService"
function JobRegistryService.prototype.____constructor(self, jobStore)
    self.jobStore = jobStore
    self.registered = false
end
function JobRegistryService.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "JobRegistryService is already registered"),
            0
        )
    end
    self.registered = true
    Logger:info("Registering Job Registry Service")
    rednet.host(JOB_REGISTRY_PROTOCOL_NAME, HOSTNAME)
    EventLoop:on(
        "rednet_message",
        function(____, sender, message, protocol)
            if protocol == JOB_REGISTRY_PROTOCOL_NAME then
                self:onMessage(message, sender)
            end
            return false
        end
    )
end
function JobRegistryService.prototype.onMessage(self, message, sender)
    Logger:info(
        "Got JobRegistryService message from sender",
        sender,
        textutils.serialize(message)
    )
    if not (message.cmd ~= nil) then
        Logger:error("idk what to do with this", message)
        return
    end
    local ____message_0 = message
    local cmd = ____message_0.cmd
    local params = __TS__ObjectRest(____message_0, {cmd = true})
    repeat
        local ____switch9 = cmd
        local ____cond9 = ____switch9 == JobRegistryCommand.LIST
        if ____cond9 then
            do
                rednet.send(
                    sender,
                    tostring(self.jobStore),
                    JOB_REGISTRY_PROTOCOL_NAME
                )
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == JobRegistryCommand.GET
        if ____cond9 then
            do
                local ____params_1 = params
                local id = ____params_1.id
                rednet.send(
                    sender,
                    self.jobStore:getById(id),
                    JOB_REGISTRY_PROTOCOL_NAME
                )
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == JobRegistryCommand.DELETE
        if ____cond9 then
            do
                local ____params_2 = params
                local id = ____params_2.id
                local result = self.jobStore:removeById(id)
                if result then
                    self.jobStore:save()
                end
                rednet.send(sender, result, JOB_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == JobRegistryCommand.DELETE_DONE
        if ____cond9 then
            do
                local count = 0
                for ____, ____value in __TS__Iterator(self.jobStore) do
                    local id = ____value.id
                    local status = ____value.status
                    if status == JobStatus.DONE then
                        self.jobStore:removeById(id)
                        count = count + 1
                    end
                end
                if count > 0 then
                    self.jobStore:save()
                end
                Logger:info(("Removed " .. tostring(count)) .. " done jobs")
                rednet.send(sender, {ok = true, count = count}, JOB_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == JobRegistryCommand.UPDATE
        if ____cond9 then
            do
                local ____params_3 = params
                local id = ____params_3.id
                local changes = __TS__ObjectRest(____params_3, {id = true})
                local result = self.jobStore:updateById(id, changes)
                if result then
                    self.jobStore:save()
                end
                rednet.send(sender, result, JOB_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == JobRegistryCommand.ADD
        if ____cond9 then
            do
                local ____params_4 = params
                local ____type = ____params_4.type
                local args = ____params_4.args
                local result = self.jobStore:add({type = ____type, args = args})
                self.jobStore:save()
                rednet.send(sender, result, JOB_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        ____cond9 = ____cond9 or ____switch9 == JobRegistryCommand.JOB_DONE
        if ____cond9 then
            do
                local ____params_5 = params
                local id = ____params_5.id
                self.jobStore:updateById(id, {status = JobStatus.DONE})
                self.jobStore:save()
                EventLoop:emit(JobRegistryEvent.JOB_DONE, id)
                rednet.send(sender, {ok = true}, JOB_REGISTRY_PROTOCOL_NAME)
            end
            break
        end
        do
            Logger:error("invalid JobRegistryService command", message.cmd)
        end
    until true
end
____exports.default = JobRegistryService
return ____exports