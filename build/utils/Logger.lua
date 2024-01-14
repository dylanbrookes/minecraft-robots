--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____env = require("utils.env")
local env = ____env.default
local LogLevel = LogLevel or ({})
LogLevel.INTERNAL = "INTERNAL"
LogLevel.DEBUG = "DEBUG"
LogLevel.INFO = "INFO"
LogLevel.WARN = "WARN"
LogLevel.ERROR = "ERROR"
local LOG_LEVEL_SHORTCODES = {
    [LogLevel.INTERNAL] = "[*]",
    [LogLevel.DEBUG] = "[D]",
    [LogLevel.INFO] = "[I]",
    [LogLevel.WARN] = "[W]",
    [LogLevel.ERROR] = "[E]"
}
local LOG_LEVEL_ORDER = {
    LogLevel.INTERNAL,
    LogLevel.DEBUG,
    LogLevel.INFO,
    LogLevel.WARN,
    LogLevel.ERROR
}
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
local function printLog(____, line, level, termRedirect)
    local oTerm = termRedirect and term.redirect(termRedirect)
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
    term.redirect(oTerm)
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
    if env.LOG_LEVEL ~= nil then
        local idx = __TS__ArrayIndexOf(LOG_LEVEL_ORDER, env.LOG_LEVEL)
        if idx == -1 then
            error(
                __TS__New(Error, "Invalid log level " .. env.LOG_LEVEL),
                0
            )
        end
        self.logLevel = env.LOG_LEVEL
    else
        self.logLevel = LogLevel.INFO
    end
    if env.FILE_LOG_LEVEL ~= nil then
        local idx = __TS__ArrayIndexOf(LOG_LEVEL_ORDER, env.FILE_LOG_LEVEL)
        if idx == -1 then
            error(
                __TS__New(Error, "Invalid log level " .. env.FILE_LOG_LEVEL),
                0
            )
        end
        self.fileLogLevel = env.FILE_LOG_LEVEL
    else
        self.fileLogLevel = LogLevel.DEBUG
    end
    self:writeLine(
        (((("Logger " .. tostring(self.id)) .. " created with log level ") .. self.logLevel) .. "/") .. self.fileLogLevel,
        LogLevel.INTERNAL
    )
end
function __Logger__.prototype.writeLine(self, line, level)
    if __TS__ArrayIndexOf(LOG_LEVEL_ORDER, level) >= __TS__ArrayIndexOf(LOG_LEVEL_ORDER, self.logLevel) then
        printLog(nil, line, level, self.termRedirect)
    end
    if env.FILE_LOGGING ~= nil and __TS__ArrayIndexOf(LOG_LEVEL_ORDER, level) >= __TS__ArrayIndexOf(LOG_LEVEL_ORDER, self.fileLogLevel) then
        local log = (LOG_LEVEL_SHORTCODES[level] .. " ") .. line
        self.file.writeLine(log)
        self.file.flush()
    end
end
function __Logger__.prototype.setTermRedirect(self, termRedirect)
    self.termRedirect = termRedirect
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
