--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local LogLevel = LogLevel or ({})
LogLevel.DEBUG = "DEBUG"
LogLevel.INFO = "INFO"
LogLevel.WARN = "WARN"
LogLevel.ERROR = "ERROR"
local LOG_LEVEL_SHORTCODES = {[LogLevel.DEBUG] = "[D]", [LogLevel.INFO] = "[I]", [LogLevel.WARN] = "[W]", [LogLevel.ERROR] = "[E]"}
local function formatArgs(____, args)
    return table.concat(
        __TS__ArrayMap(
            args,
            function(____, a) return type(a) == "string" and a or textutils.serialize(a, {compact = true}) end
        ),
        " "
    )
end
local function levelColor(____, level)
    repeat
        local ____switch5 = level
        local ____cond5 = ____switch5 == LogLevel.WARN
        if ____cond5 then
            return colors.yellow
        end
        ____cond5 = ____cond5 or ____switch5 == LogLevel.ERROR
        if ____cond5 then
            return colors.red
        end
        do
            return colors.white
        end
    until true
end
local function printLog(____, line, level)
    local oColor = term.getTextColor()
    local log = line
    if term.isColor() then
        term.setTextColor(levelColor(nil, level))
    else
        if __TS__ArrayIncludes({LogLevel.WARN, LogLevel.ERROR}, level) then
            log = (("[" .. level) .. "] ") .. line
        end
    end
    print(log)
    term.setTextColor(oColor)
end
local __Logger__ = __TS__Class()
__Logger__.name = "__Logger__"
function __Logger__.prototype.____constructor(self, logDir, fileName)
    self.id = os.epoch()
    local filePath = (logDir .. "/") .. (fileName or tostring(self.id) .. ".log")
    local file, err = fs.open(filePath, "a")
    if not file then
        error(
            __TS__New(
                Error,
                (("Failed to open " .. filePath) .. ": ") .. tostring(err)
            ),
            0
        )
    end
    self.file = file
    self:debug(("Logger " .. tostring(self.id)) .. " created")
end
function __Logger__.prototype.writeLine(self, line, level)
    if level ~= LogLevel.DEBUG then
        printLog(nil, line, level)
    end
    local log = (LOG_LEVEL_SHORTCODES[level] .. " ") .. line
    self.file.writeLine(log)
    self.file.flush()
end
function __Logger__.prototype.debug(self, ...)
    local args = {...}
    self:writeLine(
        formatArgs(nil, args),
        LogLevel.DEBUG
    )
end
function __Logger__.prototype.info(self, ...)
    local args = {...}
    self:writeLine(
        formatArgs(nil, args),
        LogLevel.INFO
    )
end
function __Logger__.prototype.warn(self, ...)
    local args = {...}
    self:writeLine(
        formatArgs(nil, args),
        LogLevel.WARN
    )
end
function __Logger__.prototype.error(self, ...)
    local args = {...}
    self:writeLine(
        formatArgs(nil, args),
        LogLevel.ERROR
    )
end
local Logger = __TS__New(__Logger__, "/log", "default.log")
____exports.default = Logger
return ____exports
