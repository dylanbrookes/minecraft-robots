--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____TurtleControlService = require("utils.services.TurtleControlService")
local TurtleControlService = ____TurtleControlService.default
local ____TurtleStore = require("utils.stores.TurtleStore")
local TurtleStore = ____TurtleStore.default
local ____TurtleControlUI = require("utils.ui.TurtleControlUI")
local TurtleControlUI = ____TurtleControlUI.default
local ____JobStore = require("utils.stores.JobStore")
local JobStore = ____JobStore.JobStore
local ____JobRegistryService = require("utils.services.JobRegistryService")
local JobRegistryService = ____JobRegistryService.default
local ____JobScheduler = require("utils.JobScheduler")
local JobScheduler = ____JobScheduler.default
local ____ResourceRegistryService = require("utils.services.ResourceRegistryService")
local ResourceRegistryService = ____ResourceRegistryService.default
local ____ResourceStore = require("utils.stores.ResourceStore")
local ResourceStore = ____ResourceStore.ResourceStore
local modem = peripheral.find("modem")
if not modem then
    error(
        __TS__New(Error, "Could not find modem"),
        0
    )
end
local modemName = peripheral.getName(modem)
rednet.open(modemName)
local turtleStore = __TS__New(TurtleStore)
local turtleRegistry = __TS__New(TurtleControlService, turtleStore)
turtleRegistry:register()
local jobStore = __TS__New(JobStore)
local jobRegistry = __TS__New(JobRegistryService, jobStore)
jobRegistry:register()
local jobScheduler = __TS__New(JobScheduler, jobStore, turtleStore)
jobScheduler:register()
local resourceStore = __TS__New(ResourceStore)
local resourceRegistry = __TS__New(ResourceRegistryService, resourceStore)
resourceRegistry:register()
local monitor = peripheral.find("monitor")
if not monitor then
    Logger:error("Failed to find a monitor")
else
    local ui = __TS__New(
        TurtleControlUI,
        monitor,
        turtleStore,
        jobStore,
        resourceStore
    )
    ui:register()
end
EventLoop:run()
return ____exports
