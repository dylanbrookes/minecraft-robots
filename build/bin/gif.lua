--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____GifUI = require("utils.ui.GifUI")
local GifUI = ____GifUI.default
local path = ...
local monitor = peripheral.find("monitor")
if not monitor then
    print("Failed to find a monitor")
else
    local ui = __TS__New(GifUI, monitor, path)
    ui:register()
end
EventLoop:run()
return ____exports
