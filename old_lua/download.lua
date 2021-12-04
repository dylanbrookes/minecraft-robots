local tArgs = { ... }
 
local function get(paste)
    write( "Connecting... " )
    local response = http.get(
        paste
    )
        
    if response then
        print( "Success." )
        
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        print( "Failed." )
    end
end


-- Determine file to download
local sCode = tArgs[1]
local sFile = tArgs[2]
local sPath = shell.resolve( sFile )
if fs.exists( sPath ) then
    print( "File already exists" )
    return
end

-- GET the contents from pastebin
local res = get(sCode)
if res then
    local file = fs.open( sPath, "w" )
    file.write( res )
    file.close()

    print( "Downloaded as "..sFile )
end 