--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local Routine = __TS__Class()
Routine.name = "Routine"
function Routine.prototype.____constructor(self, fn)
    local ____Routine_0, ____ID_COUNTER_1 = Routine, "ID_COUNTER"
    local ____Routine_ID_COUNTER_2 = ____Routine_0[____ID_COUNTER_1]
    ____Routine_0[____ID_COUNTER_1] = ____Routine_ID_COUNTER_2 + 1
    self.id = ____Routine_ID_COUNTER_2
    self.co = coroutine.create(fn)
    self:resume()
end
function Routine.prototype.isDead(self)
    if not self.co then
        return true
    end
    return coroutine.status(self.co) == "dead"
end
function Routine.prototype.terminate(self)
    if self.co then
        self:resume("terminate")
    end
end
function Routine.prototype.resume(self, event, ...)
    if not self.co then
        error(
            __TS__New(
                Error,
                "Cannot resume a dead routine " .. tostring(self.id)
            ),
            0
        )
    end
    local result = {coroutine.resume(self.co, event, ...)}
    if result[1] == false then
        error(
            __TS__New(
                Error,
                (("Error in routine " .. tostring(self.id)) .. ": ") .. textutils.serialize(result[2])
            ),
            0
        )
    end
    if coroutine.status(self.co) == "dead" then
        self.co = nil
        return true
    end
end
Routine.ID_COUNTER = 0
local __EventLoop__ = __TS__Class()
__EventLoop__.name = "__EventLoop__"
function __EventLoop__.prototype.____constructor(self)
    self.running = false
    self.events = {}
    self.routines = __TS__New(Map)
end
function __EventLoop__.prototype.on(self, name, cb, options)
    if options == nil then
        options = {}
    end
    if not (self.events[name] ~= nil) then
        self.events[name] = {}
    end
    local ____self_events_name_3 = self.events[name]
    ____self_events_name_3[#____self_events_name_3 + 1] = __TS__ObjectAssign({cb = cb, name = name}, options)
end
function __EventLoop__.prototype.off(self, name, cb)
    if not (self.events[name] ~= nil) then
        return false
    end
    local idx = __TS__ArrayFindIndex(
        self.events[name],
        function(____, ev) return ev.cb == cb end
    )
    if idx == -1 then
        return false
    end
    __TS__ArraySplice(self.events[name], idx, 1)
    return true
end
function __EventLoop__.prototype.emit(self, name, ...)
    local params = {...}
    if not (self.events[name] ~= nil) then
        return
    end
    local cbsLeft = {}
    local startLen = #self.events[name]
    for ____, ev in ipairs(self.events[name]) do
        local cb = ev.cb
        local async = ev.async
        local remove = false
        if async then
            --- Okay maybe native lua coroutines? But how does the computer decide which coroutine gets the events?
            -- OHHH you provide the events to the coroutine by calling resume! SICK
            -- So what we need to do is:
            --  1. wrap the cb in a "promise" (coroutine?) - routine
            --  2. Add that promise to an internal array
            --  3. On each event pulled invoke resume on the promise until it completes
            local routine = __TS__New(
                Routine,
                function() return cb(
                    nil,
                    table.unpack(params)
                ) end
            )
            if routine:isDead() then
            else
                self.routines:set(routine.id, routine)
            end
        else
            remove = not not cb(
                nil,
                table.unpack(params)
            )
        end
        if not remove then
            cbsLeft[#cbsLeft + 1] = ev
        else
            print("REMOVED EVENT LISTENER", name)
        end
    end
    if #self.events[name] > startLen then
        local newCbs = __TS__ArraySlice(self.events[name], startLen)
        print("Added", #newCbs, "events that would have been missed", name)
        __TS__ArrayPushArray(cbsLeft, newCbs)
    end
    self.events[name] = cbsLeft
end
function __EventLoop__.prototype.emitRepeat(self, name, interval, ...)
    local ev = {...}
    local evTimer = os.startTimer(interval)
    self:on(
        "timer",
        function(____, id)
            if id ~= evTimer then
                return false
            end
            self:emit(
                name,
                table.unpack(ev)
            )
            evTimer = os.startTimer(interval)
            return false
        end
    )
end
function __EventLoop__.prototype.setTimeout(self, cb, interval)
    local evTimer = os.startTimer(interval)
    self:on(
        "timer",
        function(____, id)
            if id ~= evTimer then
                return false
            end
            cb(nil)
            return true
        end
    )
end
function __EventLoop__.prototype.run(self, tick)
    if self.running then
        error(
            __TS__New(Error, "Already running"),
            0
        )
    end
    self.running = true
    os.queueEvent("_tick", 0)
    self:on(
        "_tick",
        function(____, n)
            do
                local function ____catch(e)
                    Logger:error("Error in EventLoop tick:", e)
                    error(e, 0)
                end
                local ____try, ____hasReturned = pcall(function()
                    local ____tick_result_4 = tick
                    if ____tick_result_4 ~= nil then
                        ____tick_result_4 = ____tick_result_4(nil)
                    end
                end)
                if not ____try then
                    ____catch(____hasReturned)
                end
            end
            sleep(__EventLoop__.TICK_TIMEOUT)
            os.queueEvent("_tick", n + 1)
        end,
        {async = true}
    )
    while self.running do
        local ____temp_6 = {os.pullEvent()}
        local event = ____temp_6[1]
        local params = __TS__ArraySlice(____temp_6, 1)
        if not event then
            error(
                __TS__New(Error, "wtf why isn't there an event"),
                0
            )
        end
        self:emit(
            event,
            table.unpack(params)
        )
        for ____, routine in __TS__Iterator(self.routines:values()) do
            local finished = routine:resume(
                event,
                table.unpack(params)
            )
            if finished then
                self.routines:delete(routine.id)
            end
        end
    end
end
__EventLoop__.TICK_TIMEOUT = 0.01
____exports.EventLoop = __TS__New(__EventLoop__)
return ____exports
