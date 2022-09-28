--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.ItemTags = ItemTags or ({})
____exports.ItemTags.turtle = "computercraft:turtle"
____exports.ItemTags.stella_arcanum = "forge:ores/stella_arcanum"
____exports.inspectHasTags = function(____, info, tagsParam)
    if not info or type(info) ~= "table" then
        return false
    end
    local tags = __TS__ArrayIsArray(tagsParam) and tagsParam or ({tagsParam})
    return __TS__ArrayFindIndex(
        tags,
        function(____, tag) return info.tags[tag] ~= nil end
    ) ~= -1
end
return ____exports
