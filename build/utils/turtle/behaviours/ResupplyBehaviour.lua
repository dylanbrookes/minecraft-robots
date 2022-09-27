--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____ResourceRegistryClient = require("utils.clients.ResourceRegistryClient")
local ResourceRegistryClient = ____ResourceRegistryClient.ResourceRegistryClient
local ____Consts = require("utils.Consts")
local RESOURCE_REGISTRY_PROTOCOL_NAME = ____Consts.RESOURCE_REGISTRY_PROTOCOL_NAME
local ____findProtocolHostId = require("utils.findProtocolHostId")
local findProtocolHostId = ____findProtocolHostId.findProtocolHostId
local ____LocationMonitor = require("utils.LocationMonitor")
local LocationMonitor = ____LocationMonitor.LocationMonitor
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____Consts = require("utils.turtle.Consts")
local positionsEqual = ____Consts.positionsEqual
local serializePosition = ____Consts.serializePosition
local ____PathfinderBehaviour = require("utils.turtle.behaviours.PathfinderBehaviour")
local PathfinderBehaviour = ____PathfinderBehaviour.PathfinderBehaviour
local ____TurtleBehaviour = require("utils.turtle.behaviours.TurtleBehaviour")
local TurtleBehaviourBase = ____TurtleBehaviour.TurtleBehaviourBase
____exports.ResupplyBehaviour = __TS__Class()
local ResupplyBehaviour = ____exports.ResupplyBehaviour
ResupplyBehaviour.name = "ResupplyBehaviour"
__TS__ClassExtends(ResupplyBehaviour, TurtleBehaviourBase)
function ResupplyBehaviour.prototype.____constructor(self, resourceTags, count, priority)
    if priority == nil then
        priority = 1
    end
    TurtleBehaviourBase.prototype.____constructor(self)
    self.resourceTags = resourceTags
    self.count = count
    self.priority = priority
    self.resource = nil
    self.pathfinderBehaviour = nil
    self.name = "resupply:" .. table.concat(resourceTags, "|")
end
function ResupplyBehaviour.prototype.step(self)
    if not LocationMonitor.position then
        Logger:info("Waiting for position")
        return
    end
    if not self.resource then
        local resourceRegistryHostId = findProtocolHostId(nil, RESOURCE_REGISTRY_PROTOCOL_NAME)
        if not resourceRegistryHostId then
            error(
                __TS__New(Error, "Failed to find resource registry host id"),
                0
            )
        end
        local resourceClient = __TS__New(ResourceRegistryClient, resourceRegistryHostId)
        local ____temp_0 = resourceClient:find(self.resourceTags, LocationMonitor.position)
        local resource = ____temp_0.resource
        if not resource then
            error(
                __TS__New(
                    Error,
                    "Failed to find resource with tags " .. table.concat(self.resourceTags, ",")
                ),
                0
            )
        end
        self.resource = resource
        Logger:info("Located resource", self.resource)
    end
    if positionsEqual(nil, LocationMonitor.position, self.resource.position) then
        local success, reason = turtle.suckDown(self.count)
        if success then
            return true
        else
            Logger:info("Failed to get items", reason)
        end
    else
        if not self.pathfinderBehaviour then
            Logger:info(
                "Travelling to supply target",
                serializePosition(nil, self.resource.position)
            )
            self.pathfinderBehaviour = __TS__New(PathfinderBehaviour, self.resource.position)
        end
        self.pathfinderBehaviour:step()
    end
end
return ____exports
