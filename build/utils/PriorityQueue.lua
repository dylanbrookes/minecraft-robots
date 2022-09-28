--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local top = 0
local function parent(____, i)
    return math.floor((i + 1) / 2) - 1
end
local function left(____, i)
    return i * 2 + 1
end
local function right(____, i)
    return (i + 1) * 2
end
____exports.default = __TS__Class()
local PriorityQueue = ____exports.default
PriorityQueue.name = "PriorityQueue"
function PriorityQueue.prototype.____constructor(self, evaluate)
    if evaluate == nil then
        evaluate = function(____, a)
            if type(a) == "number" then
                return a
            end
            error(
                __TS__New(
                    Error,
                    "Missing evaulator fn for item" .. textutils.serialize(a)
                ),
                0
            )
        end
    end
    self.evaluate = evaluate
    self.heap = {}
end
function PriorityQueue.prototype.clear(self)
    self.heap = {}
end
function PriorityQueue.prototype.size(self)
    return #self.heap
end
function PriorityQueue.prototype.isEmpty(self)
    return self:size() == 0
end
function PriorityQueue.prototype.peek(self)
    return self.heap[top + 1]
end
function PriorityQueue.prototype.push(self, ...)
    local values = {...}
    __TS__ArrayForEach(
        values,
        function(____, value)
            local ____self_heap_0 = self.heap
            ____self_heap_0[#____self_heap_0 + 1] = value
            self:siftUp()
        end
    )
    return self:size()
end
function PriorityQueue.prototype.pop(self)
    local poppedValue = self:peek()
    local bottom = self:size() - 1
    if bottom > top then
        self:swap(top, bottom)
    end
    table.remove(self.heap)
    self:_siftDown()
    return poppedValue
end
function PriorityQueue.prototype.replace(self, value)
    local replacedValue = self:peek()
    self.heap[top + 1] = value
    self:_siftDown()
    return replacedValue
end
function PriorityQueue.prototype.greater(self, i, j)
    return self:evaluate(self.heap[i + 1]) > self:evaluate(self.heap[j + 1])
end
function PriorityQueue.prototype.swap(self, i, j)
    local ____temp_1 = {self.heap[j + 1], self.heap[i + 1]}
    self.heap[i + 1] = ____temp_1[1]
    self.heap[j + 1] = ____temp_1[2]
end
function PriorityQueue.prototype.siftUp(self)
    local node = self:size() - 1
    while node > top and self:greater(
        node,
        parent(nil, node)
    ) do
        self:swap(
            node,
            parent(nil, node)
        )
        node = parent(nil, node)
    end
end
function PriorityQueue.prototype._siftDown(self)
    local node = top
    while left(nil, node) < self:size() and self:greater(
        left(nil, node),
        node
    ) or right(nil, node) < self:size() and self:greater(
        right(nil, node),
        node
    ) do
        local maxChild = right(nil, node) < self:size() and self:greater(
            right(nil, node),
            left(nil, node)
        ) and right(nil, node) or left(nil, node)
        self:swap(node, maxChild)
        node = maxChild
    end
end
____exports.default = PriorityQueue
return ____exports
