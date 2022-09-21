--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____BulletinBoardUI = require("utils.ui.BulletinBoardUI")
local BulletinBoardUI = ____BulletinBoardUI.default
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____TaskStore = require("utils.stores.TaskStore")
local TaskStore = ____TaskStore.default
local taskStore = __TS__New(TaskStore)
local monitor = peripheral.find("monitor")
if not monitor then
    print("Failed to find a monitor")
else
    local ui = __TS__New(BulletinBoardUI, monitor, taskStore)
    ui:register()
end
EventLoop:run()
return ____exports
