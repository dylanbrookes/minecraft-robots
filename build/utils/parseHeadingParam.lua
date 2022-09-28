--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____LocationMonitor = require("utils.LocationMonitor")
local Heading = ____LocationMonitor.Heading
function ____exports.default(self, headingParam)
    repeat
        local ____switch3 = string.lower(headingParam)
        local ____cond3 = ____switch3 == "n" or ____switch3 == "north"
        if ____cond3 then
            return Heading.NORTH
        end
        ____cond3 = ____cond3 or (____switch3 == "s" or ____switch3 == "south")
        if ____cond3 then
            return Heading.SOUTH
        end
        ____cond3 = ____cond3 or (____switch3 == "w" or ____switch3 == "west")
        if ____cond3 then
            return Heading.WEST
        end
        ____cond3 = ____cond3 or (____switch3 == "e" or ____switch3 == "east")
        if ____cond3 then
            return Heading.EAST
        end
        do
            return Heading.UNKNOWN
        end
    until true
end
return ____exports
