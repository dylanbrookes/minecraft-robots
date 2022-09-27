--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
--- Must be run async
function ____exports.refuel(self)
    Logger:info("Refueling")
    local startSlot = turtle.getSelectedSlot()
    local tries = 16
    local refuelled = false
    repeat
        do
            refuelled = turtle.refuel()
            if not refuelled then
                turtle.select(turtle.getSelectedSlot() % 16 + 1)
                tries = tries - 1
            end
        end
    until not (not refuelled and tries > 0)
    turtle.select(startSlot)
    return refuelled
end
return ____exports
