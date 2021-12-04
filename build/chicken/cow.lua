--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
animals = {"chicken", "cow", "dog"}
__TS__ArrayForEach(
    animals,
    function(____, animal) return print(animal) end
)
