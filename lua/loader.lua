-- https://pastebin.com/vmw6dGAY
shell.run("set motd.enable false")

local ROOT_GITHUB_PATH = "https://raw.githubusercontent.com/dylanbrookes/minecraft-robots/main/"
local PROJECT_DIR = "/code"
fs.delete(PROJECT_DIR)

-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
  end
  
  -- get all lines from a file, returns an empty 
  -- list/table if the file does not exist
  function lines_from(file)
    if not file_exists(file) then return {} end
    lines = {}
    for line in io.lines(file) do 
      lines[#lines + 1] = line
    end
    return lines
  end
 
local function get(paste)
    local response = http.get(
        paste
    )
        
    if response then
        -- print( "Successfully retrieved: " .. name )
        
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        print( "Failed." )
    end
end

-- download file
local sPath = shell.resolve(PROJECT_DIR.."/manifest.txt")
local res = get(ROOT_GITHUB_PATH .. "manifest.txt?noCache=".. os.time(os.date("!*t")))
if res then
    local file = fs.open(sPath, "w")
    file.write(res)
    file.close()

    print("Successfully downloaded manifest file")
end


local file = PROJECT_DIR..'/manifest.txt'
local lines = lines_from(file)

for k, v in pairs(lines) do
    local sPath = shell.resolve(string.gsub(v, "/build", PROJECT_DIR))
    local file = fs.open(sPath, "w")
    res = get(ROOT_GITHUB_PATH .. v)
    file.write(res)
    file.close()
    print("File updated: " .. sPath)
end


fs.move(PROJECT_DIR.."/lualib_bundle.lua", "/lualib_bundle.lua")
fs.move(PROJECT_DIR.."/require_stub.lua", "/require_stub.lua")
shell.run("cd "..PROJECT_DIR)
