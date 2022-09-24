--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local function randomColor()
    return bit32.lshift(
        1,
        math.floor(math.random() * 14 + 0.5)
    )
end
____exports.default = __TS__Class()
local FloorMonitorUI = ____exports.default
FloorMonitorUI.name = "FloorMonitorUI"
function FloorMonitorUI.prototype.____constructor(self, monitor, fps)
    if fps == nil then
        fps = 0.1
    end
    self.monitor = monitor
    self.fps = fps
    self.id = 0
    self.registered = false
    local ____exports_default_0, ____ID_COUNTER_1 = ____exports.default, "ID_COUNTER"
    local ____exports_default_ID_COUNTER_2 = ____exports_default_0[____ID_COUNTER_1]
    ____exports_default_0[____ID_COUNTER_1] = ____exports_default_ID_COUNTER_2 + 1
    self.id = ____exports_default_ID_COUNTER_2
    monitor.setTextScale(0.5)
    local size = {monitor.getSize()}
    self.width = size[1]
    self.height = size[2]
    print((((((("FloorMonitorUI " .. tostring(self.id)) .. " created for monitor ") .. __TS__StringTrim(peripheral.getName(monitor))) .. ", w:") .. tostring(self.width)) .. " h:") .. tostring(self.height))
end
function FloorMonitorUI.prototype.register(self)
    if self.registered then
        error(
            __TS__New(Error, "FloorMonitorUI is already registered"),
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
            paintutils.drawPixel(
                x,
                y,
                randomColor(nil)
            )
            term.redirect(oldterm)
        end
    )
end
function FloorMonitorUI.prototype.render(self)
    local oldterm = term.redirect(self.monitor)
    local wu = bit32.arshift(self.width, 2)
    local hu = bit32.arshift(self.height, 2)
    do
        local x = 0
        while x < self.width / wu do
            do
                local y = 0
                while y < self.height / hu do
                    paintutils.drawFilledBox(
                        x * wu,
                        y * hu,
                        (x + 1) * wu,
                        (y + 1) * hu,
                        randomColor(nil)
                    )
                    y = y + 1
                end
            end
            x = x + 1
        end
    end
    term.redirect(oldterm)
end
FloorMonitorUI.ID_COUNTER = 0
____exports.default = FloorMonitorUI
return ____exports
