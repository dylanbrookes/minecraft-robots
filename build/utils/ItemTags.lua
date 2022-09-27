--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.ItemTags = ItemTags or ({})
____exports.ItemTags.turtle = "computercraft:turtle"
____exports.inspectHasTag = function(____, info, tag)
    if not info or type(info) ~= "table" then
        return false
    end
    return info.tags[tag] ~= nil
end
return ____exports
