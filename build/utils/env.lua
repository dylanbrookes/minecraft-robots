--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ENV_FILE = "/.env"
local env = {}
if fs.exists(ENV_FILE) then
    local handle, err = fs.open(ENV_FILE, "r")
    if not handle then
        error(
            __TS__New(
                Error,
                (("Failed to open env file " .. ENV_FILE) .. " error: ") .. tostring(err)
            ),
            0
        )
    end
    local line
    while true do
        line = handle.readLine()
        if not line then
            break
        end
        local key, value = table.unpack(__TS__StringSplit(line, "="))
        if not key or not value then
            print("Skipping malformed env line:", line)
        else
            __TS__ObjectAssign(
                env,
                {[__TS__StringReplace(key, " ", "")] = __TS__StringReplace(value, " ", "")}
            )
        end
    end
end
____exports.default = env
return ____exports
