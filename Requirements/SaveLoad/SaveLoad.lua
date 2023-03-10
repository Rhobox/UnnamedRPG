if Debug then Debug.beginFile "SaveLoad" end
--[[
    Initializes save/load system with associated triggers and variables

    HandleLoad should handle the setup of the load data and any associated functions.
    May still be in asynchronous state, some testing will likely be required.
    
--]]
function init_save_load_data_sync()
    SaveLoadSyncTrigger = CreateTrigger()
    SyncPrefix = "S_TIO"
    SyncPrefixFinish = "S_TIOP"

    PlayerLoadBuffers = {}

    for i = 0, GetBJMaxPlayers(), 1 do
        PlayerLoadBuffers[Player(i)] = {}
        PlayerLoadBuffers[Player(i)].buffer = {}
        PlayerLoadBuffers[Player(i)].loadedString = ""
        PlayerLoadBuffers[Player(i)].reading = false
        PlayerLoadBuffers[Player(i)].hasLoaded = false
        BlzTriggerRegisterPlayerSyncEvent(SaveLoadSyncTrigger, Player(i), SyncPrefix, false)
        BlzTriggerRegisterPlayerSyncEvent(SaveLoadSyncTrigger, Player(i), SyncPrefixFinish, false)
    end

    TriggerAddAction(SaveLoadSyncTrigger, SaveLoadOnSync)
end

function SaveLoadOnSync()
    local player = GetTriggerPlayer()
    local data = BlzGetTriggerSyncData()
    local prefix = BlzGetTriggerSyncPrefix()
    local totalChunks = tonumber(data:sub(1, 4), 16)
    local currentChunk = tonumber(data:sub(5, 8), 16)
    local payload = data:sub(9, -1)
    local result = nil
    if (prefix == SyncPrefix) then
        if (player == GetLocalPlayer()) then
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 1, "Loaded " .. currentChunk .. " chunks of " .. totalChunks)
        end
        PlayerLoadBuffers[GetTriggerPlayer()].buffer[currentChunk] = payload
    elseif (prefix == SyncPrefixFinish) then
        result = DecodeBuffer()
        HandleLoad(result, player)
    end
end

function DecodeBuffer()
    local player = GetTriggerPlayer()
    local LoadResult = nil
    if (#PlayerLoadBuffers[player].buffer > 0) then
        LoadResult = Base64Encode.from_url64(table.concat(PlayerLoadBuffers[player].buffer))
    end
    return LoadResult
end

---@param loadData string
---@param player player
function HandleLoad(loadData, player)
    -- -exec PlayerLoadBuffers[GetLocalPlayer()].loadedString
    -- -exec PlayerLoadBuffers[Player(1)].loadedString
    -- -exec PlayerLoadBuffers[GetLocalPlayer()].hasLoaded
    -- -exec PlayerLoadBuffers[Player(1)].hasLoaded
    if (loadData ~= nil) then
        DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 1, "Successfully loaded player data for " .. GetPlayerName(player))
        PlayerLoadBuffers[player].hasLoaded = true
        PlayerLoadBuffers[player].loadedString = loadData
        PlayerLoadBuffers[player].reading = false
    end
end
if Debug then Debug.endFile() end
