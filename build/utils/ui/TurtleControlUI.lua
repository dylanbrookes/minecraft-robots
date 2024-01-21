--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____JobStore = require("utils.stores.JobStore")
local JobStatus = ____JobStore.JobStatus
local ____Consts = require("utils.turtle.Consts")
local serializePosition = ____Consts.serializePosition
____exports.default = __TS__Class()
local TurtleControlUI = ____exports.default
TurtleControlUI.name = "TurtleControlUI"
function TurtleControlUI.prototype.____constructor(self, monitor, turtleStore, jobStore, resourceStore, fps)
    if fps == nil then
        fps = 1
    end
    self.monitor = monitor
    self.turtleStore = turtleStore
    self.jobStore = jobStore
    self.resourceStore = resourceStore
    self.fps = fps
    self.id = 0
    self.registered = false
    self.frameNum = 0
    local ____exports_default_0, ____ID_COUNTER_1 = ____exports.default, "ID_COUNTER"
    local ____exports_default_ID_COUNTER_2 = ____exports_default_0[____ID_COUNTER_1]
    ____exports_default_0[____ID_COUNTER_1] = ____exports_default_ID_COUNTER_2 + 1
    self.id = ____exports_default_ID_COUNTER_2
    monitor.setTextScale(0.5)
    local size = {monitor.getSize()}
    self.width = size[1]
    self.height = size[2]
    Logger:info((((((("TurtleControlUI " .. tostring(self.id)) .. " created for monitor ") .. __TS__StringTrim(peripheral.getName(monitor))) .. ", w:") .. tostring(self.width)) .. " h:") .. tostring(self.height))
end
function TurtleControlUI.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "TurtleControlUI is already registered"),
            0
        )
    end
    self.registered = true
    local renderEvent = "render:TurtleControlUI:" .. tostring(self.id)
    EventLoop:on(
        renderEvent,
        function() return self:render() end
    )
    EventLoop:emitRepeat(renderEvent, 1 / self.fps)
    EventLoop:on(
        "monitor_touch",
        function(____, side, x, y)
            local oldterm = term.redirect(self.monitor)
            paintutils.drawPixel(x, y, 4)
            term.redirect(oldterm)
        end
    )
end
function TurtleControlUI.prototype.render(self)
    self.frameNum = self.frameNum + 1
    local oldterm = term.redirect(self.monitor)
    self.monitor.setBackgroundColor(32768)
    self.monitor.clear()
    paintutils.drawBox(
        1,
        1,
        self.width,
        self.height,
        8
    )
    self.monitor.setBackgroundColor(32768)
    self.monitor.setCursorPos(2, 2)
    self.monitor.write("Hey there!!!!! " .. tostring(self.frameNum))
    local text = {}
    __TS__ArrayForEach(
        self.turtleStore:select(),
        function(____, ____bindingPattern0)
            local currentBehaviour
            local status
            local lastSeen
            local location
            local label
            local id
            id = ____bindingPattern0.id
            label = ____bindingPattern0.label
            location = ____bindingPattern0.location
            lastSeen = ____bindingPattern0.lastSeen
            status = ____bindingPattern0.status
            currentBehaviour = ____bindingPattern0.currentBehaviour
            return __TS__ArrayPush(
                text,
                (("[" .. tostring(id)) .. "] ") .. label,
                ("    status: " .. status) .. (currentBehaviour and currentBehaviour ~= "" and (" (" .. currentBehaviour) .. ")" or ""),
                "    lastSeen: " .. tostring(lastSeen),
                location and (((("    x: " .. tostring(location[1])) .. " y: ") .. tostring(location[2])) .. " z: ") .. tostring(location[3]) or "    location unknown"
            )
        end
    )
    for ____, ____value in __TS__Iterator(__TS__ArrayEntries(text)) do
        local i = ____value[1]
        local t = ____value[2]
        self.monitor.setCursorPos(2, 3 + i)
        self.monitor.write(t)
    end
    self.monitor.setCursorPos(
        2,
        select(
            2,
            self.monitor.getCursorPos()
        ) + 1
    )
    self.monitor.write("Resources:")
    self.monitor.setCursorPos(
        2,
        select(
            2,
            self.monitor.getCursorPos()
        ) + 1
    )
    for ____, resource in ipairs(self.resourceStore:select()) do
        self.monitor.write((tostring(resource.id) .. ": ") .. table.concat(resource.tags, ","))
        self.monitor.setCursorPos(
            2,
            select(
                2,
                self.monitor.getCursorPos()
            ) + 1
        )
        self.monitor.write("    Position: " .. serializePosition(nil, resource.position))
        self.monitor.setCursorPos(
            2,
            select(
                2,
                self.monitor.getCursorPos()
            ) + 1
        )
    end
    self.monitor.write("Jobs:")
    self.monitor.setCursorPos(
        2,
        select(
            2,
            self.monitor.getCursorPos()
        ) + 1
    )
    for ____, job in ipairs(self.jobStore:select()) do
        self.monitor.write((((tostring(job.id) .. ": ") .. job.type) .. " ") .. job.status)
        if job.turtle_id then
            self.monitor.setCursorPos(
                2,
                select(
                    2,
                    self.monitor.getCursorPos()
                ) + 1
            )
            self.monitor.write("    Turtle ID: " .. tostring(job.turtle_id))
        end
        if job.status == JobStatus.FAILED then
            self.monitor.setCursorPos(
                2,
                select(
                    2,
                    self.monitor.getCursorPos()
                ) + 1
            )
            local ____self_monitor_write_4 = self.monitor.write
            local ____temp_3
            if job.error and type(job.error) == "table" and job.error.message ~= nil then
                ____temp_3 = job.error.message
            else
                ____temp_3 = "UNKNOWN"
            end
            ____self_monitor_write_4("    Error: " .. tostring(____temp_3))
        end
        self.monitor.setCursorPos(
            2,
            select(
                2,
                self.monitor.getCursorPos()
            ) + 1
        )
    end
    term.redirect(oldterm)
end
TurtleControlUI.ID_COUNTER = 0
return ____exports
