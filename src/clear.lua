function clearColumn()
    tempY = 0

    -- remove everything above the turtle
    while turtle.detectUp() do
        checkFuel()
        turtle.digUp()
        turtle.up()
        tempY = tempY + 1
    end

    -- return the turtle to ground level
    while tempY > 0 do
        checkFuel()
        turtle.down()
        tempY = tempY - 1
    end
end

function turn(direction)
    checkFuel()
    clearColumn()
    if direction == "left" then
        turtle.turnLeft()
        if turtle.detect() then
            turtle.dig()
        end
        turtle.forward()
        turtle.turnLeft()
    elseif direction == "right" then
        turtle.turnRight()
        if turtle.detect() then
            turtle.dig()
        end
        turtle.forward()
        turtle.turnRight()
    end
end

function checkFuel()
    if turtle.getFuelLevel() < 100 then
        turtle.refuel()
    end
end


function clearStrip(distance)
    currentDistance = 0
    while true do
        if currentDistance == distance then
            break
        end

        clearColumn()
        if turtle.detect() then
            turtle.dig()
        end
        turtle.forward()
        currentDistance = currentDistance + 1
    end
end


function traverseSquare(x, y)
    iteration = 1
    while true do
        if iteration == (y + 1) then
            break
        end
        
        clearStrip(x)

        if (iteration % 2) == 1 then
            turn("left")
        elseif (iteration % 2) == 0 then
            turn("right")
        end
        iteration = iteration + 1
    end

    print("completed job")
end

args = {...}
x = tonumber(args[1])
y = tonumber(args[2])
traverseSquare(x,y)