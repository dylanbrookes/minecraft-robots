--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.TurtleReason = TurtleReason or ({})
____exports.TurtleReason.OUT_OF_FUEL = "Out of fuel"
____exports.TurtleEvent = TurtleEvent or ({})
____exports.TurtleEvent.moved = "moved"
____exports.TurtleEvent.moved_up = "moved:up"
____exports.TurtleEvent.moved_down = "moved:down"
____exports.TurtleEvent.moved_back = "moved:back"
____exports.TurtleEvent.moved_forward = "moved:forward"
____exports.TurtleEvent.turned = "turned"
____exports.TurtleEvent.turned_left = "turned:left"
____exports.TurtleEvent.turned_right = "turned:right"
____exports.TurtleEvent.out_of_fuel = "out_of_fuel"
____exports.TurtleEvent.low_fuel = "low_fuel"
____exports.TurtleEvent.check_fuel = "check_fuel"
____exports.TurtleEvent.dig = "dig"
____exports.TurtleEvent.dig_forward = "dig:forward"
____exports.TurtleEvent.dig_up = "dig:up"
____exports.TurtleEvent.dig_down = "dig:down"
____exports.positionsEqual = function(____, a, b) return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] end
____exports.serializePosition = function(____, p) return __TS__ArrayJoin(p, "-") end
____exports.cartesianDistance = function(____, a, b) return math.abs(a[1] - b[1]) + math.abs(a[2] - b[2]) + math.abs(a[3] - b[3]) end
____exports.distance = function(____, a, b) return math.sqrt((a[1] - b[1]) ^ 2 + (a[2] - b[2]) ^ 2 + (a[3] - b[3]) ^ 2) end
____exports.JobEvent = {
    start = function(____, id) return "job:start:" .. tostring(id) end,
    ["end"] = function(____, id) return "job:end:" .. tostring(id) end,
    pause = function(____, id) return "job:pause:" .. tostring(id) end,
    resume = function(____, id) return "job:resume:" .. tostring(id) end,
    error = function(____, id) return "job:error:" .. tostring(id) end
}
____exports.JobType = JobType or ({})
____exports.JobType.spin = "spin"
____exports.JobType.clear = "clear"
return ____exports
