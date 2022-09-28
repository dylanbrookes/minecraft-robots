--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____ItemTags = require("utils.ItemTags")
local inspectHasTags = ____ItemTags.inspectHasTags
local ItemTags = ____ItemTags.ItemTags
local ____LocationMonitor = require("utils.LocationMonitor")
local HEADING_ORDER = ____LocationMonitor.HEADING_ORDER
local HEADING_TO_XZ_VEC = ____LocationMonitor.HEADING_TO_XZ_VEC
local LocationMonitor = ____LocationMonitor.LocationMonitor
local LocationMonitorStatus = ____LocationMonitor.LocationMonitorStatus
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____PriorityQueue = require("utils.PriorityQueue")
local PriorityQueue = ____PriorityQueue.default
local ____Consts = require("utils.turtle.Consts")
local cartesianDistance = ____Consts.cartesianDistance
local positionsEqual = ____Consts.positionsEqual
local serializePosition = ____Consts.serializePosition
local ____TurtleController = require("utils.turtle.TurtleController")
local TurtleController = ____TurtleController.TurtleController
local ____TurtleBehaviour = require("utils.turtle.behaviours.TurtleBehaviour")
local TurtleBehaviourBase = ____TurtleBehaviour.TurtleBehaviourBase
local function neighbors(____, p)
    local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArrayMap(
        HEADING_ORDER,
        function(____, h) return {p[1] + HEADING_TO_XZ_VEC[h][1], p[2], p[3] + HEADING_TO_XZ_VEC[h][2]} end
    )))
    __TS__SparseArrayPush(____array_0, {p[1], p[2] + 1, p[3]}, {p[1], p[2] - 1, p[3]})
    return {__TS__SparseArraySpread(____array_0)}
end
local function buildPathFromNode(____, p, cameFrom)
    local path = {p}
    while true do
        local lastPos = path[#path]
        local pp = cameFrom[serializePosition(nil, lastPos)]
        if not pp or positionsEqual(nil, lastPos, pp) then
            break
        end
        path[#path + 1] = pp
    end
    return path
end
local function getTargetHeading(____, a, b)
    for ____, heading in ipairs(HEADING_ORDER) do
        local appliedPos = {a[1] + HEADING_TO_XZ_VEC[heading][1], a[2], a[3] + HEADING_TO_XZ_VEC[heading][2]}
        if positionsEqual(nil, appliedPos, b) then
            return heading
        end
    end
    error(
        __TS__New(
            Error,
            (("Failed to get target heading from " .. serializePosition(nil, a)) .. " to ") .. serializePosition(nil, b)
        ),
        0
    )
end
____exports.PathfinderBehaviour = __TS__Class()
local PathfinderBehaviour = ____exports.PathfinderBehaviour
PathfinderBehaviour.name = "PathfinderBehaviour"
__TS__ClassExtends(PathfinderBehaviour, TurtleBehaviourBase)
function PathfinderBehaviour.prototype.____constructor(self, targetPos, priority)
    if priority == nil then
        priority = 1
    end
    TurtleBehaviourBase.prototype.____constructor(self)
    self.targetPos = targetPos
    self.priority = priority
    self.name = "pathfinding"
    self.cameFrom = {}
    self.gScore = {}
    self.initialized = false
    self.nodeQueue = __TS__New(
        PriorityQueue,
        function(____, a, b) return ____exports.PathfinderBehaviour:costHeuristic(b, targetPos) > ____exports.PathfinderBehaviour:costHeuristic(a, targetPos) end
    )
end
function PathfinderBehaviour.costHeuristic(self, pos, target)
    return cartesianDistance(nil, pos, target)
end
function PathfinderBehaviour.prototype.onStart(self)
    Logger:info("pathfinder onStart")
end
function PathfinderBehaviour.prototype.onResume(self)
    Logger:info("Restarting pathfinder")
    self.initialized = false
    self.nodeQueue:clear()
    self.cameFrom = {}
    self.gScore = {}
end
function PathfinderBehaviour.prototype.step(self)
    local currentPos = LocationMonitor.position
    if not currentPos then
        Logger:info("Skipping pathfinding, current location status is", LocationMonitor.status)
        return
    end
    if LocationMonitor.status ~= LocationMonitorStatus.ACQUIRED then
        local success = TurtleController:forward(1, false)
        if not success then
            TurtleController:turnLeft()
        end
        return
    end
    if positionsEqual(nil, currentPos, self.targetPos) then
        Logger:info(
            "Done pathfinding to",
            serializePosition(nil, self.targetPos)
        )
        return true
    end
    if not self.initialized then
        self.initialized = true
        self.nodeQueue:push(currentPos)
        self.cameFrom[serializePosition(nil, currentPos)] = currentPos
        self.gScore[serializePosition(nil, currentPos)] = 0
    end
    local bestNode = self.nodeQueue:peek()
    if bestNode and positionsEqual(nil, bestNode, currentPos) then
        self.nodeQueue:pop()
        local currentGScore = self.gScore[serializePosition(nil, currentPos)]
        if type(currentGScore) ~= "number" then
            error(
                __TS__New(Error, "missing gscore"),
                0
            )
        end
        for ____, neighbor in ipairs(neighbors(nil, currentPos)) do
            local neighborKey = serializePosition(nil, neighbor)
            local tentativeGScore = currentGScore + 1
            local neighbourGScore = self.gScore[neighborKey]
            local known = type(neighbourGScore) == "number"
            if not known or tentativeGScore < neighbourGScore then
                self.cameFrom[neighborKey] = currentPos
                self.gScore[neighborKey] = tentativeGScore
                if not known then
                    self.nodeQueue:push(neighbor)
                end
            end
        end
    end
    bestNode = self.nodeQueue:peek()
    if bestNode ~= nil then
        local bestNodePath = buildPathFromNode(nil, bestNode, self.cameFrom)
        local currentPosIdx = __TS__ArrayFindIndex(
            bestNodePath,
            function(____, p) return positionsEqual(nil, p, currentPos) end
        )
        local nextPos
        if currentPosIdx ~= -1 then
            if currentPosIdx == 0 then
                error(
                    __TS__New(Error, "oh no 675438967"),
                    0
                )
            end
            nextPos = bestNodePath[currentPosIdx]
        else
            local pos = self.cameFrom[serializePosition(nil, currentPos)]
            if not pos then
                error(
                    __TS__New(
                        Error,
                        ("Missing pos " .. serializePosition(nil, currentPos)) .. " in cameFrom"
                    ),
                    0
                )
            end
            nextPos = pos
        end
        local nextPosIsBestNode = positionsEqual(nil, nextPos, bestNode)
        if cartesianDistance(nil, currentPos, nextPos) ~= 1 then
            error(
                __TS__New(
                    Error,
                    (("Next pos " .. serializePosition(nil, nextPos)) .. " is not adjacent to current pos ") .. serializePosition(nil, currentPos)
                ),
                0
            )
        end
        if nextPos[2] > currentPos[2] then
            local occupied, info = turtle.inspectUp()
            if nextPosIsBestNode and occupied and not inspectHasTags(nil, info, ItemTags.turtle) then
                self.nodeQueue:pop()
                return
            end
            if not TurtleController:up(1, false) then
                Logger:warn("failed to move up, sleeping for 5 seconds")
                sleep(5)
            end
        elseif nextPos[2] < currentPos[2] then
            local occupied, info = turtle.inspectDown()
            if nextPosIsBestNode and occupied and not inspectHasTags(nil, info, ItemTags.turtle) then
                self.nodeQueue:pop()
                return
            end
            if not TurtleController:down(1, false) then
                Logger:warn("failed to move up, sleeping for 5 seconds")
                sleep(5)
            end
        else
            local targetHeading = getTargetHeading(nil, currentPos, nextPos)
            Logger:debug("moving " .. tostring(targetHeading))
            TurtleController:rotate(targetHeading)
            local occupied, info = turtle.inspect()
            if nextPosIsBestNode and occupied and not inspectHasTags(nil, info, ItemTags.turtle) then
                self.nodeQueue:pop()
                return
            end
            if not TurtleController:forward(1, false) then
                Logger:warn("failed to move forward, sleeping for 5 seconds")
                sleep(5)
            end
        end
    else
        error(
            __TS__New(
                Error,
                "Failed to find path to " .. serializePosition(nil, self.targetPos)
            ),
            0
        )
    end
end
PathfinderBehaviour.EPSILON = 5
return ____exports
