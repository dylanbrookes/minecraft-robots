--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
--- Must be run async
-- 
-- @returns if an item was dropped
function ____exports.createInvSpace(self)
    do
        local i = 1
        while i <= 16 do
            local result = turtle.getItemDetail(i)
            if not result then
                return false
            end
            i = i + 1
        end
    end
    local dropped = turtle.drop()
    Logger:warn("Dropped an item to clear space")
    return dropped
end
return ____exports
