--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____PriorityQueue = require("utils.PriorityQueue")
local PriorityQueue = ____PriorityQueue.default
local ____TurtleBehaviour = require("utils.turtle.behaviours.TurtleBehaviour")
local TurtleBehaviourStatus = ____TurtleBehaviour.TurtleBehaviourStatus
local __BehaviourStack__ = __TS__Class()
__BehaviourStack__.name = "__BehaviourStack__"
function __BehaviourStack__.prototype.____constructor(self)
    self.priorityQueue = __TS__New(PriorityQueue, __BehaviourStack__.CompareBehaviourPriority)
end
function __BehaviourStack__.CompareBehaviourPriority(self, a, b)
    return a.priority > b.priority
end
function __BehaviourStack__.prototype.peek(self)
    return self.priorityQueue:peek()
end
function __BehaviourStack__.prototype.push(self, behaviour)
    self.priorityQueue:push(behaviour)
end
function __BehaviourStack__.prototype.step(self)
    local currentBehaviour = self.priorityQueue:peek()
    if not self.lastBehaviour and currentBehaviour then
        Logger:info("Found something to do!")
    end
    if currentBehaviour and currentBehaviour ~= self.lastBehaviour then
        if currentBehaviour.status == TurtleBehaviourStatus.INIT then
            local ____opt_0 = currentBehaviour.onStart
            if ____opt_0 ~= nil then
                ____opt_0(currentBehaviour)
            end
        else
            local ____opt_2 = currentBehaviour.onResume
            if ____opt_2 ~= nil then
                ____opt_2(currentBehaviour)
            end
        end
        currentBehaviour.status = TurtleBehaviourStatus.RUNNING
    end
    if self.lastBehaviour and currentBehaviour ~= self.lastBehaviour then
        local ____this_5
        ____this_5 = self.lastBehaviour
        local ____opt_4 = ____this_5.onPause
        if ____opt_4 ~= nil then
            ____opt_4(____this_5)
        end
        self.lastBehaviour.status = TurtleBehaviourStatus.PAUSED
    end
    self.lastBehaviour = currentBehaviour
    if not currentBehaviour then
        return
    end
    local done = false
    do
        local function ____catch(e)
            Logger:error(e)
            Logger:error(("Behaviour " .. currentBehaviour.name) .. " threw an error")
            currentBehaviour.status = TurtleBehaviourStatus.FAILED
            local ____opt_6 = currentBehaviour.onError
            if ____opt_6 ~= nil then
                ____opt_6(currentBehaviour, e)
            end
            self.lastBehaviour = nil
            self.priorityQueue:pop()
        end
        local ____try, ____hasReturned = pcall(function()
            done = currentBehaviour:step()
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
    if done then
        currentBehaviour.status = TurtleBehaviourStatus.DONE
        local ____opt_8 = currentBehaviour.onEnd
        if ____opt_8 ~= nil then
            ____opt_8(currentBehaviour)
        end
        self.lastBehaviour = nil
        if self.priorityQueue:peek() ~= currentBehaviour then
            error(
                __TS__New(Error, "Failed to finish behaviour, priority queue behaviour is not the current behaviour and idk how to remove any element :("),
                0
            )
        end
        self.priorityQueue:pop()
        if self.priorityQueue:size() == 0 then
            Logger:info("Nothing to do...")
        end
    end
end
____exports.BehaviourStack = __TS__New(__BehaviourStack__)
return ____exports
