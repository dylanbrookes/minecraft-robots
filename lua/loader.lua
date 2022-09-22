-- https://pastebin.com/WnDg7xEw
shell.run("set motd.enable false")

local ROOT_GITHUB_PATH = "https://raw.githubusercontent.com/dylanbrookes/minecraft-robots/main/"
local PROJECT_DIR = "/code"

local MANIFEST_VERSION_SETTING = 'manifest_version'
local latestManifestVersion = settings.get(MANIFEST_VERSION_SETTING)

if latestManifestVersion ~= nil and not fs.exists(PROJECT_DIR) then
    print("Resetting manifest version setting because "..PROJECT_DIR.." does not exist")
    latestManifestVersion = nil
    -- the upgrade code will set the setting
end

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
        error( "Failed to get: "..paste )
    end
end

-- download file
local sPath = shell.resolve(PROJECT_DIR.."/manifest.txt")
local res = get(ROOT_GITHUB_PATH .. "manifest.txt?noCache=".. os.time(os.date("!*t")))
local file = fs.open(sPath, "w")
file.write(res)
file.close()

-- read manifest
local file = PROJECT_DIR..'/manifest.txt'
local lines = lines_from(file)
local version = tonumber(table.remove(lines, 1))
print("Downloaded manifest file (ver "..version..")")

if latestManifestVersion == nil or version > tonumber(latestManifestVersion) then
    print("Manifest is newer, updating...")
    fs.delete(PROJECT_DIR)

    for i, v in pairs(lines) do
        local sPath = shell.resolve(string.gsub(v, "/build", PROJECT_DIR, 1))
        local file = fs.open(sPath, "w")
        res = get(ROOT_GITHUB_PATH .. v)
        file.write(res)
        file.close()
        print("File updated: " .. sPath)
    end

    fs.delete("/lualib_bundle.lua")
    fs.delete("/require_stub.lua")
    fs.move(PROJECT_DIR.."/lualib_bundle.lua", "/lualib_bundle.lua")
    fs.move(PROJECT_DIR.."/require_stub.lua", "/require_stub.lua")
    settings.set(MANIFEST_VERSION_SETTING, version)
    settings.save()
else
    print("Already synced")
end

shell.run("cd "..PROJECT_DIR.."/bin")
