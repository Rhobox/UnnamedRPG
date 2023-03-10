function spawn_footmen_at_the_click_of_a_button()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig, Player(0), OSKEY_N, 0, true)
    TriggerAddAction(trig, function()
        -- CreateUnitAtLoc         takes player id, integer unitid, location whichLocation, real face returns unit
        unit = CreateUnitAtLoc(Player(0), FourCC("hfoo"), GetRectCenter(GetPlayableMapRect()), bj_UNIT_FACING)
        unit_stats[unit] = {}
        unit_stats[unit].physical_block = math.random(0, 100)
        unit_stats[unit].magic_armour = math.random(0, 100)
        unit_stats[unit].magic_block = math.random(0, 100)
        unit_stats[unit].evasion = 50
        unit_stats[unit].evasion_crit = 50
        unit_stats[unit].evasion_partial = 50
        unit_stats[unit].crit_chance = 80
        unit_stats[unit].crit_mean = 1
        unit_stats[unit].crit_variance = 1

        print("Blam, a footie!")
    end)
end

function spawn_enemy_footmen_at_the_click_of_a_button()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig, Player(0), OSKEY_B, 0, true)
    TriggerAddAction(trig, function()
        -- CreateUnitAtLoc         takes player id, integer unitid, location whichLocation, real face returns unit
        unit = CreateUnitAtLoc(Player(1), FourCC("Nalc"), GetRectCenter(GetPlayableMapRect()), bj_UNIT_FACING)
        unit_stats[unit] = {}
        unit_stats[unit].physical_block = math.random(0, 100)
        unit_stats[unit].magic_armour = math.random(0, 100)
        unit_stats[unit].magic_block = math.random(0, 100)
        unit_stats[unit].evasion = 50
        unit_stats[unit].evasion_crit = 50
        unit_stats[unit].evasion_partial = 50
        unit_stats[unit].crit_chance = 80
        unit_stats[unit].crit_mean = 1
        unit_stats[unit].crit_variance = 1

        print("Blam, a footie!")
    end)
end

function kill_selected_unit()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig, Player(0), OSKEY_DELETE, 0, true)
    TriggerAddAction(trig, function()
        local selected_group = CreateGroup()
        GroupEnumUnitsSelected(selected_group, Player(0))
        ForGroup(selected_group, function()
            local unit = GetEnumUnit()
            KillUnit(unit)
        end)
        print("You just killed some dudes!")
    end
    )
end

function level_test_hero()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig, Player(0), OSKEY_P, 0, true)
    TriggerAddAction(trig, function()
        local lvl = GetHeroLevel(TestHero)
        SetHeroLevel(TestHero, lvl + 1, false)
    end
    )
end