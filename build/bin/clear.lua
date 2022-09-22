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
--- clears the col directly above
-- optional height, otherwise it will dig up until there's no block
local function clearCol(self, breakForward, height)
    local off = 0
    while not height or off < height - 1 do
        if not height and not turtle.detectUp() then
            break
        end
        turtle.digUp()
        if breakForward and (not height or off < height - 2) then
            turtle.up()
        end
        off = off + 1
    end
    if height and not breakForward then
        off = off - 1
    end
    while off > 0 do
        if breakForward then
            turtle.dig()
        end
        turtle.digDown()
        turtle.down()
        off = off - 1
    end
end
local function breakAndMove(self)
    turtle.dig()
    while not ({turtle.forward()}) do
        print("Could not move, waiting 5 seconds...")
        sleep(5)
    end
end
local function clear(self, w, d, h)
    print((((("Clearing w=" .. tostring(w)) .. " d=") .. tostring(d)) .. " h=") .. tostring(h))
    checkFuel(nil)
    breakAndMove(nil)
    do
        local x = 0
        while x < w do
            do
                local y = 0
                while y < d do
                    checkFuel(nil)
                    print((("Clearing column " .. tostring(x)) .. ",") .. tostring(y))
                    local lastCol = y + 1 == d
                    if y % 2 == 0 then
                        clearCol(nil, not lastCol, h)
                    end
                    if not lastCol then
                        breakAndMove(nil)
                    end
                    y = y + 1
                end
            end
            if w - x > 1 then
                if x % 2 == 0 then
                    turtle.turnRight()
                    breakAndMove(nil)
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                    breakAndMove(nil)
                    turtle.turnLeft()
                end
            end
            x = x + 1
        end
    end
    print("Done clearing")
end
local args = {...}
assert(#args >= 2, "usage: clear <w> <d> [h]")
print(textutils.serialize(args))
clear(
    nil,
    __TS__ParseInt(args[1]),
    __TS__ParseInt(args[2]),
    args[3] and __TS__ParseInt(args[3]) or nil
)
return ____exports
