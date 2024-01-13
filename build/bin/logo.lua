--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local monitor = peripheral.find("monitor")
if not monitor then
    print("Failed to find a monitor")
else
    monitor.setTextScale(0.5)
    local oldterm = term.redirect(monitor)
    local image = paintutils.loadImage("/res/logo.nfp")
    if not image then
        error(
            __TS__New(Error, "Missing image"),
            0
        )
    end
    paintutils.drawImage(image, 1, 1)
    term.redirect(oldterm)
end
return ____exports
