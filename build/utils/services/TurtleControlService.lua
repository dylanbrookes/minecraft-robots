--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____TurtleClient = require("utils.clients.TurtleClient")
local TurtleClient = ____TurtleClient.TurtleClient
local ____Consts = require("utils.Consts")
local HOSTNAME = ____Consts.HOSTNAME
local TurtleControlEvent = ____Consts.TurtleControlEvent
local TURTLE_CONTROL_PROTOCOL_NAME = ____Consts.TURTLE_CONTROL_PROTOCOL_NAME
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____generateName = require("utils.generateName")
local generateName = ____generateName.default
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____TurtleStore = require("utils.stores.TurtleStore")
local TurtleStatus = ____TurtleStore.TurtleStatus
____exports.TurtleControlCommand = TurtleControlCommand or ({})
____exports.TurtleControlCommand.TURTLE_CONNECT = "TURTLE_CONNECT"
____exports.TurtleControlCommand.TURTLE_PING = "TURTLE_PING"
____exports.TurtleControlCommand.TURTLE_SOS = "TURTLE_SOS"
____exports.TurtleControlCommand.TURTLE_TERMINATE = "TURTLE_TERMINATE"
____exports.TurtleControlCommand.LIST = "LIST"
local function buildUpdates(____, status, turtleRecord)
    local lastKnownLocation = status.location or turtleRecord and turtleRecord.location or turtleRecord and turtleRecord.lastKnownLocation
    return {
        lastSeen = os.epoch("utc"),
        location = status.location,
        lastKnownLocation = lastKnownLocation and ({table.unpack(lastKnownLocation)}),
        currentBehaviour = status.currentBehaviour,
        status = status.status
    }
end
____exports.default = __TS__Class()
local TurtleControlService = ____exports.default
TurtleControlService.name = "TurtleControlService"
function TurtleControlService.prototype.____constructor(self, turtleStore)
    self.turtleStore = turtleStore
    self.registered = false
    self.checkingTurtles = false
end
function TurtleControlService.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "TurtleControlService is already registered"),
            0
        )
    end
    self.registered = true
    Logger:info("Registering Turtle Control Service")
    rednet.host(TURTLE_CONTROL_PROTOCOL_NAME, HOSTNAME)
    EventLoop:on(
        "rednet_message",
        function(____, sender, message, protocol)
            if protocol == TURTLE_CONTROL_PROTOCOL_NAME then
                self:onMessage(message, sender)
            end
            return false
        end
    )
    EventLoop:on(
        ____exports.default.CHECK_TURTLES_EVENT,
        function() return self:checkTurtles() end,
        {async = true}
    )
    EventLoop:emitRepeat(____exports.default.CHECK_TURTLES_EVENT, ____exports.default.STALE_TURTLE_TIMEOUT)
    EventLoop:setTimeout(function() return EventLoop:emit(____exports.default.CHECK_TURTLES_EVENT) end)
end
function TurtleControlService.prototype.checkTurtles(self)
    if self.checkingTurtles then
        Logger:debug("Skipping turtle check, already in progress")
        return
    end
    self.checkingTurtles = true
    for ____, staleTurtle in ipairs(self.turtleStore:select(function(____, ____bindingPattern0)
        local status
        local lastSeen
        lastSeen = ____bindingPattern0.lastSeen
        status = ____bindingPattern0.status
        return status ~= TurtleStatus.OFFLINE and os.epoch("utc") > lastSeen + ____exports.default.STALE_TURTLE_TIMEOUT * 1000
    end)) do
        local turtleClient = __TS__New(TurtleClient, staleTurtle.id)
        Logger:info("Contacting", staleTurtle.label)
        local status = turtleClient:status()
        if not status then
            Logger:warn(((("Failed to contact turtle " .. staleTurtle.label) .. " [") .. tostring(staleTurtle.id)) .. "], setting status OFFLINE")
            self.turtleStore:update(staleTurtle.id, {status = TurtleStatus.OFFLINE})
            EventLoop:emit(TurtleControlEvent.TURTLE_OFFLINE, staleTurtle.id)
        else
            Logger:info("Got status from turtle", staleTurtle.label, status)
            self.turtleStore:update(
                staleTurtle.id,
                buildUpdates(nil, status, staleTurtle)
            )
        end
        self.turtleStore:save()
    end
    self.checkingTurtles = false
end
function TurtleControlService.prototype.onMessage(self, message, sender)
    Logger:debug(
        "Got TurtleControlService message from sender",
        sender,
        textutils.serialize(message)
    )
    if type(message) ~= "table" or message == nil or not (message.cmd ~= nil) then
        Logger:error(
            "idk what to do with this",
            textutils.serialize(message)
        )
        return
    end
    repeat
        local ____switch19 = message.cmd
        local ____cond19 = ____switch19 == ____exports.TurtleControlCommand.TURTLE_CONNECT
        if ____cond19 then
            do
                local turtleRecord = self.turtleStore:get(sender)
                local updates = buildUpdates(nil, message, turtleRecord)
                if turtleRecord then
                    if turtleRecord.status ~= TurtleStatus.OFFLINE then
                        EventLoop:emit(TurtleControlEvent.TURTLE_OFFLINE, turtleRecord.id)
                    end
                    turtleRecord = self.turtleStore:update(sender, updates)
                    self.turtleStore:save()
                    Logger:info(((("Turtle " .. turtleRecord.label) .. " [") .. tostring(sender)) .. "] reconnected")
                    rednet.send(sender, {ok = true, label = turtleRecord.label}, TURTLE_CONTROL_PROTOCOL_NAME)
                else
                    turtleRecord = __TS__ObjectAssign(
                        {
                            id = sender,
                            label = generateName(nil),
                            registeredAt = updates.lastSeen
                        },
                        updates
                    )
                    Logger:info(turtleRecord)
                    self.turtleStore:add(turtleRecord)
                    self.turtleStore:save()
                    rednet.send(sender, {ok = true, label = turtleRecord.label}, TURTLE_CONTROL_PROTOCOL_NAME)
                end
                if turtleRecord.status == TurtleStatus.IDLE then
                    EventLoop:emit(TurtleControlEvent.TURTLE_IDLE, turtleRecord.id)
                end
            end
            break
        end
        ____cond19 = ____cond19 or ____switch19 == ____exports.TurtleControlCommand.TURTLE_PING
        if ____cond19 then
            do
                local turtleRecord = self.turtleStore:get(sender)
                if not turtleRecord then
                    Logger:error("received turtle ping from unknown sender " .. tostring(sender))
                    break
                end
                self.turtleStore:update(
                    sender,
                    buildUpdates(nil, message, turtleRecord)
                )
                self.turtleStore:save()
                Logger:debug(((("Received ping from " .. turtleRecord.label) .. " [") .. tostring(sender)) .. "]")
            end
            break
        end
        ____cond19 = ____cond19 or ____switch19 == ____exports.TurtleControlCommand.TURTLE_TERMINATE
        if ____cond19 then
            do
                if not self.turtleStore:exists(sender) then
                    Logger:error("received turtle terminate from unknown sender " .. tostring(sender))
                    break
                end
                local turtle = self.turtleStore:update(sender, {status = TurtleStatus.OFFLINE})
                EventLoop:emit(TurtleControlEvent.TURTLE_OFFLINE, sender)
                Logger:info(((("Turtle " .. turtle.label) .. " [") .. tostring(sender)) .. "] terminated")
            end
            break
        end
        ____cond19 = ____cond19 or ____switch19 == ____exports.TurtleControlCommand.LIST
        if ____cond19 then
            rednet.send(
                sender,
                tostring(self.turtleStore),
                TURTLE_CONTROL_PROTOCOL_NAME
            )
            break
        end
        do
            Logger:error("invalid TurtleControlService command", message.cmd)
        end
    until true
end
TurtleControlService.CHECK_TURTLES_EVENT = "TurtleControlService:check_turtles"
TurtleControlService.STALE_TURTLE_TIMEOUT = 10
return ____exports
