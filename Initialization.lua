if Debug then Debug.beginFile "InitializationDebug" end
OnInit.final("Initialization", function()
    local testing = true
    function round(number, scale)
        return math.floor((number * scale) + 0.5) / scale
    end

    -- Gameplay Constants, not available programmatically?
    DefenseArmorConstant = 0.06 
    StrRegenBonus = 0.05
    IntRegenBonus = 0.05
    --

    DebugDamage = false

    PlayerStats = {}
    PlayerStats.ExperienceRate = 1
    PlayerStats.BountyMultiplier = 1
    PlayerStats.TotalDeaths = 0
    PlayerStats.isAdmin = false

    gg_rct_Region_000 = Rect(-672.0, 96.0, -352.0, 384.0)
    gg_rct_Region_001 = Rect(224.0, 128.0, 512.0, 384.0)
    SpawnCount = 0
    possible_names = {}
    possible_names[1] = "Banana Lad"
    possible_names[2] = "Uber Zeit"
    possible_names[3] = "Steven Blorp"
    possible_names[4] = "Plustrious Zorper"
    possible_skins = {}
    possible_skins[1] = FourCC('hfoo')
    possible_skins[2] = FourCC('hpea')
    possible_skins[3] = FourCC('hkni')
    possible_skins[4] = FourCC('hrif')
    possible_skins[5] = FourCC('opeo')
    possible_skins[6] = FourCC('ogru')
    possible_skins[7] = FourCC('orai')
    possible_skins[8] = FourCC('otau')
    possible_skins[9] = FourCC('uaco')
    possible_skins[10] = FourCC('ushd')
    possible_skins[11] = FourCC('ugho')
    possible_skins[12] = FourCC('uabo')
    possible_skins[13] = FourCC('ewsp')
    possible_skins[14] = FourCC('earc')
    possible_skins[15] = FourCC('esen')
    possible_skins[16] = FourCC('edry')
    
    init_save_load_data_sync()
    init_save_and_load_command_triggers()
    spawn_footmen_at_the_click_of_a_button()
    spawn_enemy_footmen_at_the_click_of_a_button()
    damagetriggers_initialization()
    kill_selected_unit()
    setup_spawning()
    

    TimerStart(CreateTimer(), 0.03, false, post_initialization())

    if testing then
        FogEnable(false)
        FogMaskEnable(false)
        TestHero = UnitCreation(Player(0), 'Hblm', GetRectCenter(GetPlayableMapRect()), 0)
        level_test_hero()
    end
end)
if Debug then Debug.endFile() end
