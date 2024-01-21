--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.ItemTags = ItemTags or ({})
____exports.ItemTags.turtle = "computercraft:turtle"
____exports.ItemTags.stella_arcanum = "forge:ores/stella_arcanum"
____exports.ItemTags.diamond = "minecraft:diamond"
____exports.ItemTags.diamond_block = "minecraft:diamond_block"
____exports.ItemTags.gold_ingot = "minecraft:gold_ingot"
____exports.ItemTags.gold_block = "minecraft:gold_block"
____exports.ItemTags.emerald = "minecraft:emerald"
____exports.ItemTags.emerald_block = "minecraft:emerald_block"
____exports.ItemTags.cobblestone = "minecraft:cobblestone"
____exports.ItemTags.coal = "minecraft:coal"
____exports.ItemTags.tnt = "minecraft:tnt"
____exports.ItemTags.stick = "minecraft:stick"
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
