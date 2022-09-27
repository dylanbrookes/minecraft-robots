--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.TurtleBehaviourStatus = TurtleBehaviourStatus or ({})
____exports.TurtleBehaviourStatus.INIT = "INIT"
____exports.TurtleBehaviourStatus.RUNNING = "RUNNING"
____exports.TurtleBehaviourStatus.PAUSED = "PAUSED"
____exports.TurtleBehaviourStatus.DONE = "DONE"
____exports.TurtleBehaviourBase = __TS__Class()
local TurtleBehaviourBase = ____exports.TurtleBehaviourBase
TurtleBehaviourBase.name = "TurtleBehaviourBase"
function TurtleBehaviourBase.prototype.____constructor(self)
    self._status = ____exports.TurtleBehaviourStatus.INIT
end
__TS__SetDescriptor(
    TurtleBehaviourBase.prototype,
    "status",
    {
        get = function(self)
            return self._status
        end,
        set = function(self, status)
            repeat
                local ____switch5 = status
                local ____cond5 = ____switch5 == ____exports.TurtleBehaviourStatus.INIT
                if ____cond5 then
                    error(
                        __TS__New(Error, "Cannot transition to TurtleBehaviourStatus.INIT"),
                        0
                    )
                end
                ____cond5 = ____cond5 or ____switch5 == ____exports.TurtleBehaviourStatus.RUNNING
                if ____cond5 then
                    repeat
                        local ____switch6 = self._status
                        local ____cond6 = ____switch6 == ____exports.TurtleBehaviourStatus.INIT or ____switch6 == ____exports.TurtleBehaviourStatus.PAUSED
                        if ____cond6 then
                            self._status = status
                            break
                        end
                        do
                            error(
                                __TS__New(Error, (("Cannot transition from " .. self._status) .. " to ") .. status),
                                0
                            )
                        end
                    until true
                    break
                end
                ____cond5 = ____cond5 or (____switch5 == ____exports.TurtleBehaviourStatus.PAUSED or ____switch5 == ____exports.TurtleBehaviourStatus.DONE)
                if ____cond5 then
                    if self._status ~= ____exports.TurtleBehaviourStatus.RUNNING then
                        error(
                            __TS__New(Error, (("Cannot transition from " .. self._status) .. " to ") .. status),
                            0
                        )
                    end
                    self._status = status
                    break
                end
            until true
        end
    },
    true
)
return ____exports
