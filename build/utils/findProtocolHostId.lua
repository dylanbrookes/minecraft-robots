--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.findProtocolHostId(self, protocolId)
    local modem = peripheral.find("modem")
    if not modem then
        error(
            __TS__New(Error, "Could not find modem"),
            0
        )
    end
    local modemName = peripheral.getName(modem)
    rednet.open(modemName)
    print(("Looking for protocol " .. protocolId) .. " host...")
    local hostIds = rednet.lookup(protocolId)
    local hostId = __TS__ArrayIsArray(hostIds) and hostIds[1] or hostIds
    return hostId
end
return ____exports
