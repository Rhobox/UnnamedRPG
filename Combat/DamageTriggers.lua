function damagetriggers_initialization()
    initalize_damage_trigger()
    initialize_lethal_damage_trigger()
    initialize_after_damage_trigger()
end

function initalize_damage_trigger()
    local trig = CreateTrigger()
    TriggerRegisterVariableEvent(trig, "udg_DamageModifierEvent", EQUAL, 1.00)
    TriggerAddAction(trig, damage_trigger_action)
end

function damage_trigger_action()
    local damage_source = udg_DamageEventSource
    local damage_target = udg_DamageEventTarget
    local damage_value = udg_DamageEventAmount
    local damage_previous = udg_DamageEventPrevAmt
    local damage_attack_type = udg_DamageEventAttackT 
    local damage_type = udg_DamageEventDamageT
    local damage_weapon_type = udg_DamageEventWeaponT 
    local damage_armour_type = udg_DamageEventArmorT 
    local damage_defense_type = udg_DamageEventDefenseT 
    local damage_armour_pierce = udg_DamageEventArmorPierced 
    local damage_spell = udg_IsDamageSpell
    local damage_ranged = udg_IsDamageRanged
    local damage_melee = udg_IsDamageMelee 
    local damage_code = udg_IsDamageCode 
    local damage_event_type = udg_DamageEventType
    -- if DebugDamage then print("Damage Type: " .. damage_type) end
    -- if DebugDamage then print("Damage Spell: " .. tostring(damage_spell)) end
    -- if DebugDamage then print("Attack Type: " .. damage_attack_type) end
    -- if DebugDamage then print("Weapon Type: " .. damage_weapon_type) end

    if DebugDamage then print(damage_source) end
    
    if damage_ranged or damage_melee then
        if damage_attack_type ==  4 then
            if DebugDamage then print("Damage spell") end
            spell_damage(damage_source, damage_target, damage_value)
        else
            if DebugDamage then print("Damage physical") end
            physical_damage(damage_source, damage_target, damage_value)
        end
        
    elseif damage_spell then
        if DebugDamage then print("Damage spell") end
        spell_damage(damage_source, damage_target, damage_value)
    else
        if DebugDamage then print("I don't know what you did, but it did something weird with the damage types.") end
    end
    if DebugDamage then print("Damage was modified probably!") end
end

function initialize_lethal_damage_trigger()
    local trig = CreateTrigger()
    TriggerRegisterVariableEvent(trig, "udg_LethalDamageEvent", EQUAL, 1.00)
    TriggerAddAction(trig, lethal_damage_action)
end

function lethal_damage_action()
    local overkill = udg_LethalDamageHP
    local damage = udg_DamageEventAmount
    local target = udg_DamageEventTarget
    ArcingTextTag("|cffAA0000" .. overkill .. damage .. "|r", target)
    udg_LethalDamageHP = 0
end

function initialize_after_damage_trigger()
    local trig = CreateTrigger()
    TriggerRegisterVariableEvent(trig, "udg_AfterDamageEvent", EQUAL, 1.00)
    TriggerAddAction(trig, after_damage_action)
end

function after_damage_action()
    local damage = udg_DamageEventAmount
    local target = udg_DamageEventTarget
    -- ArcingTextTag(damage .. "|r", target)
end