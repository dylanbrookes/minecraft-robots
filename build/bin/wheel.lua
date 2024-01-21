--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local speaker
require("/require_stub")
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____Logger = require("utils.Logger")
local Logger = ____Logger.default
local ____ItemTags = require("utils.ItemTags")
local ItemTags = ____ItemTags.ItemTags
local SPIN_END_EVENT = "spin_end"
local WIN_EVENT = "win"
local PLAY_SOUND_SEQUENCE_EVENT = "play_sound_sequence"
local MIN_SPIN_DURATION = 5
local MAX_SPIN_DURATION = 8
local SPIN_SPEED = 4
local WHEEL_TICK_HEIGHT = 3
local WHEEL_SPIN_SOUND = "entity.experience_orb.pickup"
local SOUND_SEQUENCES = {
    winBig = function(self)
        if speaker ~= nil then
            speaker.playSound("ui.toast.challenge_complete")
        end
    end,
    win = function(self)
        if speaker ~= nil then
            speaker.playSound("entity.player.levelup")
        end
    end,
    lose = function(self)
        if speaker ~= nil then
            speaker.playSound("entity.witch.celebrate")
        end
        sleep(0.5)
    end,
    loseBig = function(self)
        if speaker ~= nil then
            speaker.playSound("item.flintandsteel.use")
        end
        sleep(0.25)
        if speaker ~= nil then
            speaker.playSound("entity.tnt.primed")
        end
        sleep(1.5)
        if speaker ~= nil then
            speaker.playSound("entity.villager.no")
        end
    end
}
local WHEEL = {
    {
        item = ItemTags.diamond,
        count = 1,
        label = "Diamond",
        color = colors.lightBlue,
        soundSequence = "winBig"
    },
    {
        item = ItemTags.coal,
        count = 4,
        label = "Coal",
        color = colors.black,
        textColor = colors.white,
        soundSequence = "lose"
    },
    {item = ItemTags.gold_ingot, count = 1, label = "Gold", color = colors.yellow},
    {
        item = ItemTags.stick,
        count = 2,
        label = "Sticks",
        color = colors.brown,
        textColor = colors.white
    },
    {item = ItemTags.emerald, count = 1, label = "Emerald", color = colors.green},
    {
        item = ItemTags.cobblestone,
        count = 8,
        label = "Cobblestone",
        color = colors.lightGray,
        textColor = colors.white,
        soundSequence = "lose"
    },
    {
        item = ItemTags.diamond_block,
        count = 1,
        label = "JACKPOT",
        soundSequence = "winBig",
        color = colors.blue,
        textColor = colors.white
    },
    {
        item = ItemTags.cobblestone,
        count = 8,
        label = "Cobblestone",
        color = colors.lightGray,
        textColor = colors.white,
        soundSequence = "lose"
    },
    {item = ItemTags.gold_ingot, count = 1, label = "Gold", color = colors.yellow},
    {
        item = ItemTags.stick,
        count = 2,
        label = "Sticks",
        color = colors.brown,
        textColor = colors.white
    },
    {item = ItemTags.emerald, count = 1, label = "Emerald", color = colors.green},
    {
        item = ItemTags.coal,
        count = 4,
        label = "Coal",
        color = colors.black,
        textColor = colors.white,
        soundSequence = "lose"
    },
    {
        item = ItemTags.tnt,
        count = 1,
        label = "???",
        color = colors.red,
        textColor = colors.white,
        soundSequence = "loseBig"
    },
    {
        item = ItemTags.coal,
        count = 4,
        label = "Coal",
        color = colors.black,
        textColor = colors.white,
        soundSequence = "lose"
    },
    {item = ItemTags.emerald, count = 4, label = "Emerald x4", color = colors.green},
    {item = ItemTags.gold_ingot, count = 1, label = "Gold", color = colors.yellow}
}
local monitor = peripheral.find("monitor")
if not monitor then
    error(
        __TS__New(Error, "Failed to find a monitor"),
        0
    )
end
speaker = peripheral.find("speaker")
if not speaker then
    Logger:warn("Failed to find a speaker")
end
local dropper = peripheral.find("minecraft:dropper")
if not dropper then
    Logger:warn("Failed to find a dropper")
else
    local maybeSide = peripheral.getName(dropper)
    if not __TS__ArrayIncludes({
        "back",
        "front",
        "top",
        "bottom",
        "left",
        "right"
    }, maybeSide) then
        error(
            __TS__New(Error, "Dropper must be connected directly on a side, connected on " .. maybeSide),
            0
        )
    end
end
local storage = peripheral.find("minecraft:barrel")
if not storage then
    Logger:warn("Failed to find a storage barrel")
end
math.randomseed(os.epoch("utc"))
monitor.setTextScale(0.5)
local w, h = monitor.getSize()
local inputPaused = false
local wheelRenderPaused = false
local spinning = false
local spinStart = 0
local spinDuration = 0
local wheelPos = 0
local oldTerm = term.redirect(monitor)
Logger:setTermRedirect(oldTerm)
monitor.setBackgroundColor(colors.black)
monitor.clear()
EventLoop:on(
    "monitor_touch",
    function()
        if inputPaused then
            return
        end
        inputPaused = true
        spinning = true
        spinStart = os.epoch("utc")
        spinDuration = MIN_SPIN_DURATION + math.random() * (MAX_SPIN_DURATION - MIN_SPIN_DURATION)
    end,
    {async = true}
)
EventLoop:on(
    WIN_EVENT,
    function(____, item, count)
        if dropper == nil or storage == nil then
            Logger:error("Failed to distribute rewards, missing dropper/storage")
            return
        end
        local items = storage.list()
        local filteredItems = {}
        for ____, slot in ipairs(__TS__ObjectKeys(items)) do
            local details = items[slot]
            if details.name == item then
                filteredItems[#filteredItems + 1] = {slot, details}
            end
        end
        local remaining = count
        while remaining > 0 do
            local entry = table.remove(filteredItems)
            if not entry then
                Logger:error((("Ran out of " .. item) .. ", remaining: ") .. tostring(remaining))
                break
            end
            local slot, details = table.unpack(entry)
            local toMove = math.min(remaining, details.count)
            storage.pushItems(
                peripheral.getName(dropper),
                slot,
                toMove
            )
            remaining = remaining - toMove
        end
        local dropperSide = peripheral.getName(dropper)
        while #__TS__ObjectKeys(dropper.list()) > 0 do
            redstone.setOutput(dropperSide, true)
            sleep(0.05)
            redstone.setOutput(dropperSide, false)
            sleep(0.05)
        end
    end,
    {async = true}
)
EventLoop:on(
    PLAY_SOUND_SEQUENCE_EVENT,
    function(____, sequenceName)
        SOUND_SEQUENCES[sequenceName](SOUND_SEQUENCES)
    end,
    {async = true}
)
EventLoop:on(
    SPIN_END_EVENT,
    function()
        local wheelTick = WHEEL[math.floor(wheelPos) % #WHEEL + 1]
        Logger:info(
            "Spin ended",
            wheelPos,
            textutils.serialize(wheelTick)
        )
        spinning = false
        if not (wheelTick.empty ~= nil) then
            EventLoop:emit(WIN_EVENT, wheelTick.item, wheelTick.count)
            EventLoop:emit(PLAY_SOUND_SEQUENCE_EVENT, wheelTick.soundSequence or "win")
        else
            EventLoop:emit(PLAY_SOUND_SEQUENCE_EVENT, "lose")
        end
        inputPaused = false
    end,
    {async = true}
)
local function drawWheelTick(self, wheelTick, yOff)
    local color = colors.red
    local textColor = colors.white
    local label = nil
    if wheelTick.empty ~= nil then
        color = colors.black
    else
        label = wheelTick.label
        color = wheelTick.color
        textColor = wheelTick.textColor or colors.black
    end
    paintutils.drawFilledBox(
        2,
        yOff,
        w - 1,
        yOff + WHEEL_TICK_HEIGHT,
        color
    )
    if label ~= nil then
        term.setCursorPos(
            3,
            yOff + math.floor(WHEEL_TICK_HEIGHT / 2)
        )
        term.setBackgroundColor(color)
        term.setTextColor(textColor)
        term.write(label)
    end
end
Logger:info("Started", w, h)
EventLoop.tickTimeout = 0.05
EventLoop:run(function(____, delta)
    if spinning then
        local duration = os.epoch("utc") - spinStart
        if duration >= spinDuration * 1000 then
            EventLoop:emit(SPIN_END_EVENT)
        else
            local spinSpeed = math.max(
                0.2,
                math.min(1, duration / 1000) * math.min(1, (spinDuration - duration / 1000) / 3)
            ) * SPIN_SPEED
            local lastWheelPosPx = math.floor(wheelPos * WHEEL_TICK_HEIGHT)
            wheelPos = wheelPos - delta / 1000 * spinSpeed
            if wheelPos < 0 then
                wheelPos = wheelPos + #WHEEL
            end
            if lastWheelPosPx ~= math.floor(wheelPos * WHEEL_TICK_HEIGHT) then
                if speaker ~= nil then
                    speaker.playSound(
                        WHEEL_SPIN_SOUND,
                        0.7,
                        0.5 + math.random() * 0.4
                    )
                end
            end
        end
    end
    if not wheelRenderPaused then
        paintutils.drawFilledBox(
            1,
            1,
            w,
            h,
            colors.white
        )
        local wheelPosInt = math.floor(wheelPos)
        local subsectionOffset = wheelPos - wheelPosInt
        do
            local i = 0
            while i <= math.ceil(h / WHEEL_TICK_HEIGHT) do
                local wheelTick = WHEEL[(math.floor(wheelPos - h / 2 / WHEEL_TICK_HEIGHT) + i) % #WHEEL + 1]
                drawWheelTick(
                    nil,
                    wheelTick,
                    math.ceil((i - subsectionOffset) * WHEEL_TICK_HEIGHT)
                )
                i = i + 1
            end
        end
    end
    local marqueeOffset = math.floor(os.epoch("utc") / 1000)
    do
        local y = 2
        while y < h do
            local color = y == h / 2 and colors.white or ((y + marqueeOffset) % 3 == 0 and colors.blue or colors.black)
            paintutils.drawPixel(1, y, color)
            paintutils.drawPixel(w, y, color)
            y = y + 1
        end
    end
    do
        local x = 2
        while x < w do
            paintutils.drawPixel(x, 1, (x + marqueeOffset) % 3 == 0 and colors.blue or colors.black)
            paintutils.drawPixel(x, h, (x + marqueeOffset) % 3 == 1 and colors.blue or colors.black)
            x = x + 1
        end
    end
end)
return ____exports
