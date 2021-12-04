function digLine(distance)
    print("Digging line with distance: " .. distance)
    for var=1, distance do
        -- this while loop will continue to mine gravel
        while true do
            checkFuel()
            if turtle.detect() then
                turtle.dig()
            else
                turtle.forward()
                break
            end
        end
    end
end

function checkFuel()
    if turtle.getFuelLevel() < 100 then
        turtle.refuel()
    end
end

function turn(direction)
    if direction == "left" then
        print("Turning left")
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
    elseif direction == "right" then
        print("Turning right")
        turtle.turnRight()
        turtle.dig()
        turtle.forward()
        turtle.turnRight()
    end
end

function digLayer(x, y)
    turtle.digDown()
    turtle.down()

    -- initial dig line
    layerY = 1
    digLine(x - 1)
    while true do
        turn("left")
        digLine(x - 1)
        layerY = layerY + 1
        if layerY == y then
            print("LayerY is complete (1)")
            break
        end

        turn("right")
        digLine(x - 1)
        layerY = layerY + 1
        if layerY == y then
            print("LayerY is complete (2)")
            break
        end
    end
    
    if y % 2 == 0 then
        print("Input y is even number")
        turtle.turnLeft()
        for distance = 1, y - 1 do
            turtle.forward()
        end
        turtle.turnLeft()
    elseif y % 2 == 1 then
        print("Input y is odd number")
        turtle.turnRight()
        for distance = 1, y - 1 do
            turtle.forward()
        end
        turtle.turnRight()
        for distance = 1, x - 1 do
            turtle.forward()
        end
        turtle.turnRight()
        turtle.turnRight()
    end
end

function digCube(x, y, z)
    for depth=1, z do
        print("Digging layer: " .. depth)
        checkFuel()
        digLayer(x,y)
    end
end


args = {...}
x = tonumber(args[1])
y = tonumber(args[2])
z = tonumber(args[3])
print(x, y, z)
digCube(x,y,z)
