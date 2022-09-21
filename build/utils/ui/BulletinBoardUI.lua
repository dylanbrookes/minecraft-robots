--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
____exports.default = __TS__Class()
local BulletinBoardUI = ____exports.default
BulletinBoardUI.name = "BulletinBoardUI"
function BulletinBoardUI.prototype.____constructor(self, monitor, taskStore, fps)
    if fps == nil then
        fps = 1
    end
    self.monitor = monitor
    self.taskStore = taskStore
    self.fps = fps
    self.id = 0
    self.registered = false
    self.frameNum = 0
    local ____exports_default_0, ____ID_COUNTER_1 = ____exports.default, "ID_COUNTER"
    local ____exports_default_ID_COUNTER_2 = ____exports_default_0[____ID_COUNTER_1]
    ____exports_default_0[____ID_COUNTER_1] = ____exports_default_ID_COUNTER_2 + 1
    self.id = ____exports_default_ID_COUNTER_2
    monitor.setTextScale(1)
    local size = {monitor.getSize()}
    self.width = size[1]
    self.height = size[2]
    print((((((("BulletinBoardUI " .. tostring(self.id)) .. " created for monitor ") .. __TS__StringTrim(peripheral.getName(monitor))) .. ", w:") .. tostring(self.width)) .. " h:") .. tostring(self.height))
end
function BulletinBoardUI.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "BulletinBoardUI is already registered"),
            0
        )
    end
    self.registered = true
    local renderEvent = "render:BulletinBoardUI:" .. tostring(self.id)
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
function BulletinBoardUI.prototype.render(self)
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
        self.taskStore:getAll(),
        function(____, ____bindingPattern0, i)
            local status
            local description
            local id
            id = ____bindingPattern0.id
            description = ____bindingPattern0.description
            status = ____bindingPattern0.status
            return __TS__ArrayPush(
                text,
                (("[" .. tostring(id)) .. "] ") .. description,
                "    status: " .. status
            )
        end
    )
    for ____, ____value in __TS__Iterator(__TS__ArrayEntries(text)) do
        local i = ____value[1]
        local t = ____value[2]
        self.monitor.setCursorPos(2, 3 + i)
        self.monitor.write(t)
    end
    term.redirect(oldterm)
end
BulletinBoardUI.ID_COUNTER = 0
____exports.default = BulletinBoardUI
return ____exports
