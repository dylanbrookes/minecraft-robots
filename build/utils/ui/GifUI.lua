--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
____exports.default = __TS__Class()
local GifUI = ____exports.default
GifUI.name = "GifUI"
function GifUI.prototype.____constructor(self, monitor, path, fps)
    if fps == nil then
        fps = 8
    end
    self.monitor = monitor
    self.path = path
    self.fps = fps
    self.frameNum = 0
    monitor.setTextScale(0.5)
    local size = {monitor.getSize()}
    self.width = size[1]
    self.height = size[2]
    if not fs.exists(path) then
        error(
            __TS__New(Error, "Path doesn't exist"),
            0
        )
    end
    if not fs.isDir(path) then
        error(
            __TS__New(Error, "Path is not a directory"),
            0
        )
    end
    local files = fs.list(path)
    self.frames = __TS__ArrayMap(
        files,
        function(____, fn)
            local data = paintutils.loadImage((path .. "/") .. fn)
            if not data then
                error(
                    __TS__New(Error, "Failed to load frame " .. fn),
                    0
                )
            end
            return data
        end
    )
    print((((("GifUI created with " .. tostring(#self.frames)) .. " frames, w:") .. tostring(self.width)) .. " h:") .. tostring(self.height))
end
function GifUI.prototype.register(self)
    if ____exports.default.registered then
        error(
            __TS__New(Error, "GifUI is already registered"),
            0
        )
    end
    ____exports.default.registered = true
    local renderEvent = "render:GifUI"
    EventLoop:on(
        renderEvent,
        function() return self:render() end
    )
    EventLoop:emitRepeat(renderEvent, 1 / self.fps)
end
function GifUI.prototype.render(self)
    local oldterm = term.redirect(self.monitor)
    paintutils.drawImage(self.frames[self.frameNum + 1], 1, 1)
    term.redirect(oldterm)
    self.frameNum = (self.frameNum + 1) % #self.frames
end
GifUI.registered = false
return ____exports
