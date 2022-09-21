--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
require("/require_stub")
local ____BulletinBoardUI = require("utils.ui.BulletinBoardUI")
local BulletinBoardUI = ____BulletinBoardUI.default
local ____EventLoop = require("utils.EventLoop")
local EventLoop = ____EventLoop.EventLoop
local ____TaskStore = require("utils.stores.TaskStore")
local TaskStore = ____TaskStore.default
local TaskStatus = ____TaskStore.TaskStatus
local taskStore = __TS__New(TaskStore)
local monitor = peripheral.find("monitor")
if not monitor then
    print("Failed to find a monitor")
else
    local ui = __TS__New(BulletinBoardUI, monitor, taskStore)
    ui:register()
end
local VALID_STATUSES = {TaskStatus.DONE, TaskStatus.IN_PROGRESS, TaskStatus.TODO}
local function printPrompt()
    return term.write(">")
end
local function handleCommand(self, cmd, ...)
    local params = {...}
    repeat
        local ____switch6 = cmd
        local status
        local ____cond6 = ____switch6 == "add"
        if ____cond6 then
            taskStore:add({description = params[1], status = TaskStatus.TODO})
            break
        end
        ____cond6 = ____cond6 or ____switch6 == "remove"
        if ____cond6 then
            taskStore:remove(__TS__ParseInt(params[1]))
            break
        end
        ____cond6 = ____cond6 or ____switch6 == "update"
        if ____cond6 then
            status = params[2]
            if not __TS__ArrayIncludes(VALID_STATUSES, status) then
                print((("Invalid status " .. status) .. ", must be one of ") .. textutils.serialize(VALID_STATUSES))
            end
            taskStore:update(
                __TS__ParseInt(params[1]),
                {status = status}
            )
            break
        end
        do
            print(("Unknown command \"" .. cmd) .. "\"")
            return
        end
    until true
    taskStore:save()
end
term.clear()
local line = ""
EventLoop:on(
    "char",
    function(____, char)
        term.write(char)
        if char == "\n" then
            local ____TS__StringSplit_result_0 = __TS__StringSplit(line, " ")
            local cmd = ____TS__StringSplit_result_0[1]
            local params = __TS__ArraySlice(____TS__StringSplit_result_0, 1)
            handleCommand(
                nil,
                cmd,
                __TS__Unpack(params)
            )
            printPrompt(nil)
            line = ""
            return
        end
        line = line .. char
    end
)
print(table.concat({"Commands:", "add <description>", "remove <id>", "update <id> <status>"}, "\n"))
printPrompt(nil)
EventLoop:run()
return ____exports
