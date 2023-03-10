function setup_spawning()
    init_spawning_triggers()
end

function init_spawning_triggers()
    init_spawning_trigger()
end

function init_spawning_trigger()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig, Player(0), OSKEY_M, 0, true)
    TriggerAddAction(trig, spawning_trigger_action)
end

function spawning_trigger_action()
    spawn_unit(
        GetRectCenter(GetPlayableMapRect()),
        nil,
        nil,
        0,
        math.random(100, 1000),
        math.random(10, 100),
        math.random(10, 150),
        math.random(0, 100),
        math.random(0, 100),
        math.random(0, 100),
        math.random(0, 100),
        math.random(0, 100),
        math.random(150, 300),
        math.random(0, 75),
        math.random(0, 100),
        math.random(1,2),
        math.random(0.25, 0.75),
        "hfoo",
        math.random(0, 4),
        0
    )
end

function spawn_unit
    (
        location,
        skin,
        name,
        num_abilities,
        life,
        mana,
        damage,
        armour,
        block,
        magic_armour,
        magic_block,
        bounty,
        move_speed,
        evasion,
        crit_chance,
        crit_mean,
        crit_variance,
        unit_code,
        player,
        angle
    )
    local created_unit = nil
    local ability = nil
    local abilities = {}

    local location_spawn = location
    local unit_to_spawn = unit_code or "h001"
    local unit_angle = angle or bj_UNIT_FACING
    local unit_player = Player(player) or Player(0)

    -- takes player id, integer unitid, location whichLocation, real face returns unit
    -- constant unitstate UNIT_STATE_LIFE                          = ConvertUnitState(0)
    -- constant unitstate UNIT_STATE_MAX_LIFE                      = ConvertUnitState(1)
    -- constant unitstate UNIT_STATE_MANA                          = ConvertUnitState(2)
    -- constant unitstate UNIT_STATE_MAX_MANA                      = ConvertUnitState(3)

    if skin == nil then
        skin = math.random(1, #possible_skins)
    end
    if name == nil then
        name = math.random(1, #possible_names)
    end

    if num_abilities > 0 then
        for i = 1, num_abilities do
            ability = math.random(1, #possible_abilities)
            abilities[i] = ability
        end
    end

    created_unit = CreateUnitAtLoc(unit_player, FourCC(unit_to_spawn), location_spawn, unit_angle)

    set_unit_skin(created_unit, possible_skins[skin])
    set_unit_name(created_unit, possible_names[name] .. tostring(spawn_count))
    set_unit_life(created_unit, life)
    set_unit_mana(created_unit, mana)
    set_unit_damage(created_unit, damage)
    set_unit_armour(created_unit, armour)
    set_unit_bounty(created_unit, bounty, 0, 0)
    set_unit_move_speed(created_unit, move_speed)

    unit_stats[created_unit] = {}
    unit_stats[created_unit].physical_block = block
    unit_stats[created_unit].magic_armour = magic_armour
    unit_stats[created_unit].magic_block = magic_block
    unit_stats[created_unit].evasion = evasion
    unit_stats[created_unit].evasion_crit = 0
    unit_stats[created_unit].evasion_partial = 0
    unit_stats[created_unit].crit_chance = crit_chance
    unit_stats[created_unit].crit_mean = crit_mean
    unit_stats[created_unit].crit_variance = crit_variance

    return created_unit
end

function set_unit_skin(unit, skin)
    BlzSetUnitSkin(unit, skin)
end

function set_unit_name(unit, name)
    BlzSetUnitName(unit, name)
end

function set_unit_max_life(unit, life)
    BlzSetUnitMaxHP(unit, life)
end

function set_unit_current_life(unit, life)
    SetUnitState(unit, UNIT_STATE_LIFE, life)
end

function set_unit_life(unit, life)
    set_unit_max_life(unit, life)
    set_unit_current_life(unit, life)
end

function set_unit_life_regen(unit, regen)
    BlzSetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, regen)
end

function set_unit_max_mana(unit, mana)
    BlzSetUnitMaxMana(unit, mana)
end

function set_unit_current_mana(unit, mana)
    SetUnitState(unit, UNIT_STATE_MANA, mana)
end

function set_unit_mana(unit, mana)
    set_unit_max_mana(unit, mana)
    set_unit_current_mana(unit, mana)
end

function set_unit_mana_regen(unit, regen)
    BlzSetUnitRealField(unit, UNIT_RF_MANA_REGENERATION, regen)
end

function set_unit_damage(unit, damage, index)
    local index = index or 0
    BlzSetUnitBaseDamage(unit, damage - 1, index)
    BlzSetUnitDiceNumber(unit, 1, index)
    BlzSetUnitDiceSides(unit, 1, index)
end

function set_unit_move_speed(unit, speed)
    SetUnitMoveSpeed(unit, speed)
end

function set_unit_armour(unit, armour)
    BlzSetUnitArmor(unit, armour)
end

function set_unit_physical_block(unit, block)
    unit_stats[unit].physical_block = block
end

function set_unit_magical_armour(unit, magic_armour)
    unit_stats[unit].magic_armour = magic_armour
end

function set_unit_magic_block(unit, magic_block)
    unit_stats[unit].magic_block = magic_block
end

function set_unit_evasion(unit, evasion)
    unit_stats[unit].evasion = evasion
end

function set_unit_crit(unit, crit)
    unit_stats[unit].crit = crit
end

function set_unit_bounty(unit, bounty, dice, diceValue)
    local bountyDiceKey = UNIT_IF_GOLD_BOUNTY_AWARDED_NUMBER_OF_DICE
    local bountyValueKey = UNIT_IF_GOLD_BOUNTY_AWARDED_BASE
    local bountyDiceValueKey = UNIT_IF_GOLD_BOUNTY_AWARDED_SIDES_PER_DIE

    BlzSetUnitIntegerField(unit, bountyValueKey, bounty)
    BlzSetUnitIntegerField(unit, bountyDiceKey, dice)
    BlzSetUnitIntegerField(unit, bountyDiceValueKey, diceValue)
end