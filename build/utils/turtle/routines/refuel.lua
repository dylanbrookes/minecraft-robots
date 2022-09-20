--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.refuel(self)
    print("Refueling")
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
    until not (not refuelled and tries > 16)
    turtle.select(startSlot)
    return refuelled
end
return ____exports
