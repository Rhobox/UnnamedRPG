if Debug then Debug.beginFile "FileIO" end
--[[
    Lua Codeless Save Load FileIO v1

    A modification of FileIO by Trokkin
    https://www.hiveworkshop.com/threads/fileio-lua-optimized.347049/

    API:

        FileIO.Save(filename, filepath, data)
            - Write string data to a file
 
        FileIO.Load(filename, readingPlayer) -> string
            - Read string data from a file
 
    Optional requirements:
        DebugUtils by Eikonium                          @ https://www.hiveworkshop.com/threads/330758/
        Total Initialization by Bribe                   @ https://www.hiveworkshop.com/threads/317099/

    Inspired by:
        - Trokkin's FileIO                              @ https://www.hiveworkshop.com/threads/fileio-lua-optimized.347049/
        - ScrewTheTrees BlzSendSyncData save system     @ https://www.hiveworkshop.com/threads/lua-typescript-codeless-saving-synchronized-loading-of-huge-amounts-of-data.325749/

        Who were in turn inspired by, at least in part:
        - TriggerHappy's Codeless Save and Load         @ https://www.hiveworkshop.com/threads/278664/
        - ScrewTheTrees's Codeless Save/Sync concept    @ https://www.hiveworkshop.com/threads/325749/
        - Luashine's LUA variant of TH's FileIO         @ https://www.hiveworkshop.com/threads/307568/post-3519040
        - HerlySQR's LUA variant of TH's Save/Load      @ https://www.hiveworkshop.com/threads/331536/post-3565884

    Updated: March 8 2023
--]]
OnInit("FileIO", function()
    local RAW_OPEN = "]]"
    local RAW_CLOSE = "--[["
    local SYNC_PREFIX = "S_TIO"  -- From ScrewTheTrees
    local SYNC_SUFFIX = "S_TIOP" -- Changed S_TIOF to S_TIOP because it almost spells STOP
    local chunkSize = 180 -- Random value taken from ScrewTheTrees, satisfies the "must be shorter than Blizzards magic number" requirement
    local maxChunks = 315 -- From testing, loading 401 chunks reliably causes desync, but 308 seems to have no problems.

    ---@param filename string
    ---@param filepath string
    ---@param data string
    local function savefile(filename, filepath, data)
        local name = filepath .. filename ..'.pld'
        local toCompile = Base64Encode.to_url64(data)
        local assembledChunk = ""
        local totalChunks = math.ceil(#toCompile / chunkSize)
        local header

        if (totalChunks > maxChunks) then
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 1, "Failed to save. File exceeds maximum safe size.")
        else
            PreloadGenClear()
            PreloadGenStart()

            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 1, "Preparing to save...")
            Preload('")\nendfunction\n//!beginusercode\n--[[')

            for i = 1, #toCompile, 1 do
                assembledChunk = assembledChunk .. toCompile:sub(i, i)
                if (#assembledChunk >= chunkSize) then
                    header = string.format('%%04X', tostring(totalChunks)) .. string.format('%%04X', tostring(math.ceil(i / chunkSize)))
                    Preload(RAW_OPEN .. 'BlzSendSyncData("' .. SYNC_PREFIX .. '","' .. header .. assembledChunk ..'")\n' .. RAW_CLOSE)
                    assembledChunk = ""
                    header = ""
                end
            end
            if (#assembledChunk > 0) then
                header = string.format('%%04X', tostring(totalChunks)) .. string.format('%%04X', tostring(totalChunks))
                Preload(RAW_OPEN .. 'BlzSendSyncData("'..SYNC_PREFIX..'", "'..header..assembledChunk .. '")\n' .. RAW_CLOSE)
            end
            Preload(']]\n//!endusercode\nfunction a takes nothing returns nothing\n//')
            PreloadGenEnd(name)
            PreloadGenEnd(filepath .. "Backups/" .. filename .. '_' .. tostring(os.time()) .. '.pld')
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 1, "Saved successfully.")
        end
    end

    ---@param filename string
    local function loadfile(filename, readingPlayer)
        local isReading = PlayerLoadBuffers[readingPlayer].reading
        if (isReading == false and GetLocalPlayer() == readingPlayer) then
            if (not PlayerLoadBuffers[readingPlayer].hasLoaded) then
                PlayerLoadBuffers[readingPlayer].reading = true
                PreloadStart()
                Preloader(filename)
                PreloadEnd(1)
                BlzSendSyncData(SYNC_SUFFIX, "")
            end
        elseif (isReading == true) then
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "Attempting to load while reading. Wait a second and try again.")
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "If this persists, file a bug report.")
        else
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "An error occurred in loading. Please file a bug report.")
        end
    end

    FileIO = {
        Save = savefile,
        Load = loadfile,
    }

end)
if Debug then Debug.endFile() end

