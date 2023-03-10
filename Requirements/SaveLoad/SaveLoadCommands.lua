if Debug then Debug.beginFile "SaveLoadCommands" end
function init_save_and_load_command_triggers()
    LoadCommandTrigger = CreateTrigger()
    SaveCommandTrigger = CreateTrigger()
    for i = 0, GetBJMaxPlayers(), 1 do
        TriggerRegisterPlayerChatEvent(LoadCommandTrigger, Player(i), '-load', true)
        TriggerRegisterPlayerChatEvent(SaveCommandTrigger, Player(i), '-save', true)
    end
    TriggerAddAction(LoadCommandTrigger, HandleLoadCommand)
    TriggerAddAction(SaveCommandTrigger, HandleSaveCommand)
end

function HandleLoadCommand()
    local triggeringPlayer = GetTriggerPlayer()
    local localPlayer = GetLocalPlayer()
    if (triggeringPlayer == localPlayer) then
        FileIO.Load(Filepath .. Filename .. '.pld', Player(GetPlayerId(GetLocalPlayer())))
    end
end

function HandleSaveCommand()
    local triggeringPlayer = GetTriggerPlayer()
    local localPlayer = GetLocalPlayer()
    if (triggeringPlayer == localPlayer) then
        FileIO.Save(Filename, Filepath, EntireBeeMovieScript)
    end
end
if Debug then Debug.endFile() end
