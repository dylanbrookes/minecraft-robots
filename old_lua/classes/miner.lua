Miner = {
    x = 0,
    y = 0,
    z = 0
}

function Miner:move()
    turtle.forward()
    self.x = x + 1
end

function Miner:new()
    t = t or {}
    setmetatable(t, self)
    self.__index = self
    return t
end