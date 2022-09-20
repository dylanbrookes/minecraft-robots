--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____PriorityQueue = require("utils.PriorityQueue")
local PriorityQueue = ____PriorityQueue.default
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
        print("Found something to do!")
    elseif currentBehaviour ~= self.lastBehaviour then
    end
    self.lastBehaviour = currentBehaviour
    if not currentBehaviour then
        return
    end
    local done = currentBehaviour:step()
    if done then
        self.lastBehaviour = nil
        if self.priorityQueue:peek() ~= currentBehaviour then
            error(
                __TS__New(Error, "Failed to finish behaviour, priority queue behaviour is not the current behaviour and idk how to remove any element :("),
                0
            )
        end
        self.priorityQueue:pop()
        if self.priorityQueue:size() == 0 then
            print("Nothing to do...")
        end
    end
end
____exports.BehaviourStack = __TS__New(__BehaviourStack__)
return ____exports
