function buildLine()
    while !turtle.detect do
        if !selectBuildingBlock() then
            print("Ran out of building material!")
            return false
        end
        checkFuel()
        if !turtle.detectDown() then
            turtle.placeDown()
        end
        turtle.forward()
    end
    if turtle.detectDown() then
        turtle.placeDown()
    end
end

function checkFuel()
    FUEL_SLOT = 1

    if turtle.getFuelLevel() < 100 then
        currentBlockSlot = turtle.getSelectedSlot()
        turtle.select(FUEL_SLOT)
        turtle.refuel()
        
        turtle.select(currentBlockSlot)
    end
end

function selectBuildingBlock()
    buildingSlot = 2

    while true do
        turtle.select(buildingSlot)
        if turtle.getItemCount() == 0 then
            buildingSlot = buildingSlot + 1
        end
        
        if buildingSlot == 17 then
            return false
        end

        if turtle.getItemCount() > 0 then
            return true
        end
    end
end

function buildFloor()
    while true do
        build_1 = buildLine()
        if !build_1 then
            break
        end
        turtle.turnRight()
        turtle.forward()
        turtle.turnRight()

        build_2 = buildLine()
        if !build_2 then
            break
        end
        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()
    end
    print("build_1: " .. build_1 .. ", build_2: " .. build_2)
end