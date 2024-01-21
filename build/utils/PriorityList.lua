--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.default = __TS__Class()
local PriorityList = ____exports.default
PriorityList.name = "PriorityList"
function PriorityList.prototype.____constructor(self, comparator)
    if comparator == nil then
        comparator = function(____, a, b) return a > b end
    end
    self.comparator = comparator
    self.head = nil
    self._size = 0
end
function PriorityList.prototype.isEmpty(self)
    return self.size == 0
end
PriorityList.prototype[Symbol.iterator] = function(self)
    local item = self.head
    local i = 0
    return {next = function(self)
        if item then
            local ____item_0 = item
            local value = ____item_0.value
            local next = ____item_0.next
            item = next
            local ____i_1 = i
            i = ____i_1 + 1
            return {value = {____i_1, value}, done = false}
        else
            return {value = nil, done = true}
        end
    end}
end
function PriorityList.prototype.get(self, idx)
    if idx >= self.size then
        return nil
    end
    local item = self.head
    do
        local i = 0
        while i < idx do
            if not item then
                error(
                    __TS__New(
                        Error,
                        "Missing item " .. tostring(i)
                    ),
                    0
                )
            end
            item = item.next
            i = i + 1
        end
    end
    return item and item.value
end
function PriorityList.prototype.peek(self)
    local ____opt_4 = self.head
    return ____opt_4 and ____opt_4.value
end
function PriorityList.prototype.push(self, ...)
    local values = {...}
    if not #values then
        return self.size
    end
    __TS__ArraySort(
        values,
        function(____, a, b) return self:comparator(a, b) and 1 or -1 end
    )
    local item = self.head
    local lastItem = nil
    for ____, value in ipairs(values) do
        self._size = self._size + 1
        if not item then
            if not lastItem then
                local ____temp_6 = {value = value, next = nil}
                self.head = ____temp_6
                item = ____temp_6
            else
                local ____lastItem_7 = lastItem
                item = {value = value, next = nil}
                ____lastItem_7.next = item
            end
        elseif self:comparator(value, item.value) then
            local vItem = {value = value, next = item}
            if not lastItem then
                self.head = vItem
            else
                lastItem.next = vItem
            end
        end
        item = item and item.next
        lastItem = item
    end
    return self.size
end
function PriorityList.prototype.pop(self)
    local head = self.head
    if head then
        self._size = self._size - 1
        self.head = head.next
        return head.value
    else
        return head
    end
end
function PriorityList.prototype.remove(self, idx)
    if idx > self.size - 1 then
        error(
            __TS__New(Error, "Cannot remove out of bounds"),
            0
        )
    end
    local item = self.head
    local lastItem = nil
    do
        local i = 0
        while i < idx do
            if not item then
                error(
                    __TS__New(Error, "Missing item"),
                    0
                )
            end
            lastItem = item
            item = item.next
            i = i + 1
        end
    end
    if not item then
        error(
            __TS__New(Error, "Missing item"),
            0
        )
    end
    if not lastItem then
        self.head = item.next
    else
        lastItem.next = item.next
    end
    item.next = nil
end
__TS__SetDescriptor(
    PriorityList.prototype,
    "size",
    {get = function(self)
        return self._size
    end},
    true
)
return ____exports
