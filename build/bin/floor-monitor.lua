--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____FloorMonitorUI = require("utils.ui.FloorMonitorUI")
local FloorMonitorUI = ____FloorMonitorUI.default
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local monitor = peripheral.find("monitor")
if not monitor then
    print("Failed to find a monitor")
else
    local ui = __TS__New(FloorMonitorUI, monitor)
    ui:register()
end
EventLoop:run()
return ____exports
