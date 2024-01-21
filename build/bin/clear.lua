--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local function checkFuel(self)
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel ~= "unlimited" and fuelLevel < 100 then
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
-- will dig up until there's no block
local function clearColSimple(self)
    local off = 0
    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
        off = off + 1
    end
    while off > 0 do
        turtle.digDown()
        turtle.down()
        off = off - 1
    end
end
--- clears a col
local function clearCol(self, breakForward, height, up)
    if up == nil then
        up = true
    end
    do
        local i = 0
        while i < height - 1 do
            if breakForward then
                turtle.dig()
            end
            turtle[up and "digUp" or "digDown"]()
            turtle[up and "up" or "down"]()
            i = i + 1
        end
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
            local lastRow = x + 1 == w
            do
                local y = 0
                while y < d do
                    checkFuel(nil)
                    print((("Clearing column " .. tostring(x)) .. ",") .. tostring(y))
                    local lastCol = y + 1 == d
                    if lastCol then
                        if x % 2 == 0 then
                            turtle.turnRight()
                        else
                            turtle.turnLeft()
                        end
                    end
                    if not h then
                        clearColSimple(nil)
                    elseif (x * d + y) % 2 == 0 then
                        clearCol(
                            nil,
                            not (lastCol and lastRow),
                            h,
                            bit32.arshift(x * d + y, 1) % 2 == 0
                        )
                    end
                    if not (lastCol and lastRow) then
                        breakAndMove(nil)
                    end
                    y = y + 1
                end
            end
            if not lastRow then
                if x % 2 == 0 then
                    turtle.turnRight()
                else
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
