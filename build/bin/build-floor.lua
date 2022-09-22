--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local function checkFuel(self)
    if turtle.getFuelLevel() < 100 then
        print("Refuelling...")
        local startSlot = turtle.getSelectedSlot()
        local refuelled = false
        local tries = 16
        while not refuelled do
            refuelled = turtle.refuel()
            if not refuelled then
                turtle.select(turtle.getSelectedSlot() % 16 + 1)
                tries = tries - 1
                if tries == 0 then
                    print("ERROR: Ran out of fuel, will search again in 3 seconds")
                    sleep(3)
                    tries = 16
                end
            end
        end
        turtle.select(startSlot)
    end
end
local function forceMoveForward(self)
    while not turtle.forward() do
        print("Could not move, waiting 5 seconds...")
        sleep(5)
    end
end
local function locateItemInInv(self, itemId)
    local currentSlot = turtle.getSelectedSlot()
    local currentItem = turtle.getItemDetail(currentSlot)
    local tries = 16
    while not currentItem or currentItem.name ~= itemId do
        if currentItem then
            print(currentItem.name)
        end
        currentSlot = turtle.getSelectedSlot() % 16 + 1
        turtle.select(currentSlot)
        currentItem = turtle.getItemDetail(currentSlot)
        tries = tries - 1
        if tries == 0 then
            print(("ERROR: Failed to find item " .. itemId) .. ", will search again in 3 seconds")
            sleep(3)
            tries = 16
        end
    end
end
local function buildFloor(self, itemId, w, d)
    print((("Building floor, dimensions: w=" .. tostring(w)) .. " d=") .. tostring(d))
    checkFuel(nil)
    do
        local x = 0
        while true do
            local ____w_3
            if w then
                ____w_3 = x < w
            else
                ____w_3 = true
            end
            if not ____w_3 then
                break
            end
            do
                local y = 0
                while true do
                    local ____d_0
                    if d then
                        ____d_0 = y < d
                    else
                        ____d_0 = true
                    end
                    if not ____d_0 then
                        break
                    end
                    checkFuel(nil)
                    print((tostring(x) .. ",") .. tostring(y))
                    locateItemInInv(nil, itemId)
                    turtle.placeDown()
                    if d then
                        if d - y > 1 then
                            forceMoveForward(nil)
                        end
                    else
                        local moved = turtle.forward()
                        if not moved then
                            print("Reached end of row")
                            break
                        end
                    end
                    y = y + 1
                end
            end
            if w then
                if w - x > 1 then
                    if x % 2 == 0 then
                        turtle.turnRight()
                        forceMoveForward(nil)
                        turtle.turnRight()
                    else
                        turtle.turnLeft()
                        forceMoveForward(nil)
                        turtle.turnLeft()
                    end
                end
            else
                local moved
                if x % 2 == 0 then
                    turtle.turnRight()
                    local ____temp_1 = {turtle.forward()}
                    moved = ____temp_1[1]
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                    local ____temp_2 = {turtle.forward()}
                    moved = ____temp_2[1]
                    turtle.turnLeft()
                end
                if not moved then
                    break
                end
            end
            x = x + 1
        end
    end
    print("Done clearing")
end
local args = {...}
assert(#args == 1 or #args == 3)
print(textutils.serialize(args))
if #args == 1 then
    local itemId = __TS__Unpack(args)
    buildFloor(nil, itemId)
elseif #args == 3 then
    local itemId, w, d = __TS__Unpack(args)
    buildFloor(
        nil,
        itemId,
        __TS__ParseInt(w),
        __TS__ParseInt(d)
    )
else
    print("usage: build-floor <itemId> [w] [d]")
end
return ____exports
