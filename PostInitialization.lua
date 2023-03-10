if Debug then Debug.beginFile "PostInitialization" end
function post_initialization()
    Filename = "TestSaveFile"
    Filepath = "AODRemakeTest/" .. GetPlayerName(GetLocalPlayer()) .. "/"
    TestCount = 0
    spell_init()
end

function spell_init()
    init_reapers_promise()
    init_volatile_siphon_weapon()
    init_shattered_earth()
end
if Debug then Debug.endFile() end
