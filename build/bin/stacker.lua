--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local monitor = peripheral.find("monitor")
if not monitor then
    error(
        __TS__New(Error, "Failed to find a monitor"),
        0
    )
end
monitor.setTextScale(0.5)
local w, h = monitor.getSize()
local maxWidth = math.min(
    4,
    math.ceil(w / 4)
)
local level = 0
local posHistory = {}
local pos = 0
local dir = true
local paused = false
local width = 0
local oldTerm = term.redirect(monitor)
Logger:setTermRedirect(oldTerm)
monitor.setBackgroundColor(colors.black)
monitor.clear()
EventLoop:on(
    "monitor_touch",
    function()
        paused = true
        paintutils.drawLine(
            1,
            h - level,
            w,
            h - level,
            colors.white
        )
        paintutils.drawLine(
            pos + 1,
            h - level,
            pos + width,
            h - level,
            colors.red
        )
        sleep(0.3)
        paintutils.drawLine(
            1,
            h - level,
            w,
            h - level,
            colors.black
        )
        paintutils.drawLine(
            pos + 1,
            h - level,
            pos + width,
            h - level,
            colors.red
        )
        local leftOverflow = level == 0 and 0 or math.max(posHistory[level][1] - pos, 0)
        local rightOverflow = level == 0 and 0 or math.max(pos + width - 1 - posHistory[level][2], 0)
        if leftOverflow + rightOverflow > 0 then
            local placements = {}
            do
                local i = 0
                while i < math.min(leftOverflow, width) do
                    placements[#placements + 1] = {posHistory[level][1] - leftOverflow + i, false, -1}
                    i = i + 1
                end
            end
            do
                local i = 0
                while i < math.min(rightOverflow, width) do
                    placements[#placements + 1] = {posHistory[level][2] + rightOverflow - i, false, -1}
                    i = i + 1
                end
            end
            do
                local l = level - 1
                while l >= 0 do
                    local remainingPlacements = __TS__ArrayFilter(
                        placements,
                        function(____, ____bindingPattern0)
                            local placed
                            placed = ____bindingPattern0[2]
                            return not placed
                        end
                    )
                    if #remainingPlacements == 0 then
                        break
                    end
                    for ____, placement in ipairs(remainingPlacements) do
                        do
                            if placement[2] == true then
                                goto __continue10
                            end
                            paintutils.drawPixel(placement[1] + 1, h - l - 1, colors.black)
                            paintutils.drawPixel(placement[1] + 1, h - l, colors.red)
                            if l == 0 or posHistory[l][1] <= placement[1] and posHistory[l][2] >= placement[1] then
                                placement[2] = true
                                placement[3] = l
                                posHistory[l + 1][1] = math.min(posHistory[l + 1][1], placement[1])
                                posHistory[l + 1][2] = math.max(posHistory[l + 1][2], placement[1])
                            end
                        end
                        ::__continue10::
                    end
                    sleep(0.3)
                    l = l - 1
                end
            end
            for ____, placement in ipairs(placements) do
                paintutils.drawPixel(placement[1] + 1, h - placement[3], colors.white)
            end
            sleep(0.2)
            for ____, placement in ipairs(placements) do
                paintutils.drawPixel(placement[1] + 1, h - placement[3], colors.red)
            end
            sleep(0.2)
        end
        local restart = false
        if leftOverflow + rightOverflow >= width then
            do
                local hh = h - level + 1
                while hh <= h do
                    paintutils.drawLine(
                        1,
                        hh,
                        w,
                        hh,
                        colors.white
                    )
                    sleep(0.1)
                    hh = hh + 1
                end
            end
            sleep(1)
            restart = true
        else
            posHistory[level + 1] = {pos + leftOverflow, pos + width - 1 - rightOverflow}
            level = level + 1
        end
        if level == h then
            restart = true
            do
                local l = level - 1
                while l >= 0 do
                    paintutils.drawLine(
                        1,
                        1,
                        w,
                        1,
                        colors.black
                    )
                    do
                        local i = 1
                        while i < h - l do
                            paintutils.drawLine(
                                1,
                                h - l + 1 - i,
                                w,
                                h - l + 1 - i,
                                colors.black
                            )
                            paintutils.drawLine(
                                posHistory[l + 1][1] + 1,
                                h - l - i,
                                posHistory[l + 1][2] + 1,
                                h - l - i,
                                colors.red
                            )
                            sleep(0.1)
                            i = i + 1
                        end
                    end
                    l = l - 1
                end
            end
            for ____, color in ipairs({
                colors.red,
                colors.orange,
                colors.yellow,
                colors.green,
                colors.blue,
                colors.purple,
                colors.pink
            }) do
                monitor.setBackgroundColor(color)
                monitor.setTextColor(color)
                monitor.clear()
                sleep(0.1)
            end
        end
        if restart then
            monitor.setBackgroundColor(colors.black)
            monitor.setTextColor(colors.black)
            monitor.clear()
            level = 0
        end
        pos = 1
        dir = false
        paused = false
    end,
    {async = true}
)
Logger:info("Started", w, h)
EventLoop.tickTimeout = 0.5
EventLoop:run(function()
    if paused then
        return
    end
    width = math.ceil(math.cos(level / h * math.pi / 2) ^ 1.7 * maxWidth)
    EventLoop.tickTimeout = 0.5 - 0.45 * math.sqrt((level / h) ^ 0.2)
    if dir and pos + width >= w or not dir and pos <= 0 then
        dir = not dir
    end
    paintutils.drawPixel(pos + 1 + (dir and 0 or width - 1), h - level, colors.black)
    pos = pos + (dir and 1 or -1)
    paintutils.drawLine(
        pos + 1,
        h - level,
        pos + width,
        h - level,
        colors.red
    )
end)
return ____exports
