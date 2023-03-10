function spell_damage(source, target, damage)
    local target_unit_type = GetUnitTypeId(udg_DamageEventTarget)
    local spell_resistance = nil
    local spell_block = nil

    if unit_stats[target] == nil then
        spell_block = 0
        spell_resistance = 0
        if DebugDamage then print("Failed to find unit stats") end
    else
        spell_resistance = unit_stats[target].magic_armour
        spell_block = unit_stats[target].magic_block
    end

    if DebugDamage then print("Spell damage detected") end
    damage, crit_success = calculate_criticals(source, damage)

    if DebugDamage then print("Damaging a " .. GetUnitName(target) .. " attempting to do " .. damage .. " spell damage.") end

    spell_reduction_armour = damage * (spell_resistance / (spell_resistance + 100))
    if DebugDamage then print("Spell damage reduced by armour: " .. spell_reduction_armour) end
    damage = damage - spell_reduction_armour - spell_block
    if DebugDamage then print("Spell damage reduced by block: " .. spell_block) end
    

    if damage < 0 then
        damage = 0
    end
    if DebugDamage then print("Total damage done: " .. damage) end

    if crit_success then
        ArcingTextTag("|cff460F7A" .. damage .. "|r", target)
    end

    udg_DamageEventAmount = damage
    udg_DamageEventDefenseT = udg_DEFENSE_TYPE_UNARMORED
    udg_DamageEventArmorPierced = BlzGetUnitArmor(udg_DamageEventTarget)
    udg_DamageEventType = udg_DamageTypePure

    return damage
end

function physical_damage(source, target, damage)
    local target_unit_type = GetUnitTypeId(udg_DamageEventTarget)
    local armour = BlzGetUnitArmor(target)
    local block = nil
    local crit_success = nil
    local original_damage = damage
    local partial_evasion_success = nil
    local partial_evasion_factor = nil
    local partial_evasion_text_tag = nil
    if DebugDamage then print("Got armour " .. armour) end
    if unit_stats[target] == nil then
        block = 0
        if DebugDamage then print("Failed to find unit stats")  end
    else
        block = unit_stats[target].physical_block
    end

    if DebugDamage then print("Got block " .. block) end
    if DebugDamage then print("Damaging a " .. GetUnitName(target) .. " attempting to do " .. damage .. " physical damage.") end

    if calculate_evasion(target) then
        damage = 0
        ArcingTextTag("|cff2110e3" .. "Miss!" .. "|r", target)
    else
        damage, crit_success = calculate_criticals(source, damage)
        if crit_success then
            if calculate_crit_evasion(target) then
                damage = original_damage
                crit_success = false
                ArcingTextTag("|cff19d916" .. "Crit Evaded!" .. "|r", target)
            end
        end

        physical_reduction_armour = damage * (armour / (armour + 100))
        damage = damage - physical_reduction_armour - block

        partial_evasion_factor, partial_evasion_success = calculate_partial_evasion(target)

        if partial_evasion_success then
            damage = damage * partial_evasion_factor
            partial_evasion_text_tag = round((1 - partial_evasion_factor) * 100, 10)
            if partial_evasion_text_tag < 0 then
                partial_evasion_text_tag = 0
            end
                ArcingTextTag("|cffe3e317" .. partial_evasion_text_tag .. "%% Missed!" .. "|r", target)
        end
    end
    if damage < 0 then
        damage = 0
    end
    
    if DebugDamage then print("Physical damage reduced by armour: " .. physical_reduction_armour) end
    if DebugDamage then print("Physical damage reduced by block: " .. block) end
    if DebugDamage then print("Total damage done: " .. damage) end

    if crit_success then
        ArcingTextTag("|cffdf1212" .. damage .. "|r", target)
    end

    udg_DamageEventAmount = damage
    udg_DamageEventDefenseT = udg_DEFENSE_TYPE_UNARMORED
    udg_DamageEventArmorPierced = BlzGetUnitArmor(udg_DamageEventTarget)
    udg_DamageEventType = udg_DamageTypePure

    return damage
end

function calculate_criticals(source, damage)
    local mean = unit_stats[source].crit_mean
    local variance = unit_stats[source].crit_variance
    local chance = unit_stats[source].crit_chance
    local damage = damage
    local crit_damage = nil
    local success = false
    chance_roll = math.random() * 100
    if chance_roll < chance then
        if DebugDamage then print("Attempting gaussian") end
        crit_damage = damage * (math.exp(math.abs(gaussian(mean, variance))))
        success = true
        if DebugDamage then print("Crit success!") end
    else
        crit_damage = damage
    end
      
    return crit_damage, success
end

function calculate_magic_criticals(source, damage)
    local mean = unit_stats[source].magic_crit_mean
    local variance = unit_stats[source].magic_crit_variance
    local chance = unit_stats[source].magic_crit_chance
    local damage = damage
    local crit_damage = nil
    local success = false
    chance_roll = math.random() * 100
    if chance_roll < chance then
        if DebugDamage then print("Attempting gaussian") end
        crit_damage = damage * (math.exp(math.abs(gaussian(mean, variance))))
        success = true
        if DebugDamage then print("Crit success!") end
    else
        crit_damage = damage
    end
      
    return crit_damage, success
end

function calculate_evasion(target)
    local chance = unit_stats[target].evasion
    return calculate_evasion_roll(chance) 
end

function calculate_crit_evasion(target)
    local chance = unit_stats[target].evasion_crit
    return calculate_evasion_roll(chance) 
end

function calculate_partial_evasion(target)
    local chance = unit_stats[target].evasion_partial
    local success = nil
    local mean = 0
    local variance = 0.3
    local reduction = nil
    success = calculate_evasion_roll(chance)
    if success then
        reduction = 1 - math.abs(gaussian(mean, variance))
        if reduction < 0 then
            reduction = 0
        end
    else
        reduction = 1
    end
    return reduction, success
end

function calculate_evasion_roll(chance)
    local evade_roll = nil
    evade_roll = math.random() * 100
    if evade_roll < chance then
        return true
    else
        return false
    end
end

function calculate_partial_evasion_precentage(target)
    local mean = nil
    local variance = nil
end

function gaussian (mean, variance)
    return  math.sqrt(-2 * variance * math.log(math.random())) * math.cos(2 * math.pi * math.random()) + mean
end