function init_volatile_siphon_weapon()
    volatile_siphon_weapon_timer_trigger = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(volatile_siphon_weapon_timer_trigger, 0.10)
    TriggerAddAction(volatile_siphon_weapon_timer_trigger, volatile_siphon_weapon_periodic_action)

    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_CAST)
    TriggerAddAction(trigger, volatile_siphon_weapon_action)


    Volatile_Siphon_Weapon_Indexing = {}
    Volatile_Siphon_Weapon_Indexing.caster = nil
    Volatile_Siphon_Weapon_Indexing.casterInitialDamage = nil
    Volatile_Siphon_Weapon_Indexing.casterDamage = nil
    Volatile_Siphon_Weapon_Indexing.target = nil
    Volatile_Siphon_Weapon_Indexing.targetInitialDamage = nil
    Volatile_Siphon_Weapon_Indexing.targetDamage = nil
    Volatile_Siphon_Weapon_Indexing.time = nil
    Volatile_Siphon_Weapon_Indexing.fractionalDamage = nil
end

function volatile_siphon_weapon_action()
    local spell = GetSpellAbilityId()
    if spell == FourCC("A002") then
        local caster = GetTriggerUnit()
        local target = GetSpellTargetUnit()
        local count = #Volatile_Siphon_Weapon_Indexing + 1
        Volatile_Siphon_Weapon_Indexing[count] = {}
        Volatile_Siphon_Weapon_Indexing[count].caster = caster
        Volatile_Siphon_Weapon_Indexing[count].casterInitialDamage = BlzGetUnitBaseDamage(caster, 0)
        Volatile_Siphon_Weapon_Indexing[count].casterDamage = BlzGetUnitBaseDamage(caster, 0)
        Volatile_Siphon_Weapon_Indexing[count].casterWeaponEnabled = true
        Volatile_Siphon_Weapon_Indexing[count].target = target
        Volatile_Siphon_Weapon_Indexing[count].targetInitialDamage = BlzGetUnitBaseDamage(target, 0)
        Volatile_Siphon_Weapon_Indexing[count].targetDamage = BlzGetUnitBaseDamage(target, 0)
        Volatile_Siphon_Weapon_Indexing[count].targetWeaponEnabled = true
        Volatile_Siphon_Weapon_Indexing[count].fractionalDamage = 0
        Volatile_Siphon_Weapon_Indexing[count].time = 0
        if not IsTriggerEnabled(volatile_siphon_weapon_timer_trigger) then
            EnableTrigger(volatile_siphon_weapon_timer_trigger)
        end
    end
end

function volatile_siphon_weapon_periodic_action()
    local time = nil
    local damage_to_reduce = nil
    local caster = nil
    local casterInitialDamage = nil
    local casterDamage = nil
    local casterWeaponEnabled = nil
    local target = nil
    local targetInitialDamage = nil
    local targetDamage = nil
    local targetWeaponEnabled = nil
    local fractionalDamage = nil

    if #Volatile_Siphon_Weapon_Indexing > 0 then
        for key, value in pairs(Volatile_Siphon_Weapon_Indexing) do
            print("Siphoning for key: " .. key)
            time = Volatile_Siphon_Weapon_Indexing[key].time
            caster = Volatile_Siphon_Weapon_Indexing[key].caster
            casterInitialDamage = Volatile_Siphon_Weapon_Indexing[key].casterInitialDamage
            casterDamage = Volatile_Siphon_Weapon_Indexing[key].casterDamage
            casterWeaponEnabled = Volatile_Siphon_Weapon_Indexing[key].casterWeaponEnabled
            target = Volatile_Siphon_Weapon_Indexing[key].target
            targetInitialDamage = Volatile_Siphon_Weapon_Indexing[key].targetInitialDamage
            targetDamage = Volatile_Siphon_Weapon_Indexing[key].targetDamage
            targetWeaponEnabled = Volatile_Siphon_Weapon_Indexing[key].targetWeaponEnabled
            fractionalDamage = Volatile_Siphon_Weapon_Indexing[key].fractionalDamage
            print("Values assigned")
            print(time)
            rounded_time = round(time, 10)
            print(rounded_time)
            if rounded_time <= 5 then
                damage_to_reduce = targetInitialDamage / 50
                if (targetDamage - damage_to_reduce) <= 0 then
                    BlzSetUnitWeaponBooleanField(target, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0, false)
                    BlzSetUnitBaseDamage(target, R2I(0), 0)
                    BlzSetUnitBaseDamage(caster, R2I(casterDamage + targetDamage), 0)

                    Volatile_Siphon_Weapon_Indexing[key].casterDamage = casterDamage + targetDamage
                    Volatile_Siphon_Weapon_Indexing[key].targetDamage = 0

                else
                    if damage_to_reduce < 1 then
                        fractionalDamage = fractionalDamage + damage_to_reduce
                        damage_to_reduce = 0
                        if fractionalDamage >= 1 then
                            damage_to_reduce = 1
                            fractionalDamage = fractionalDamage - 1
                        end
                    end

                    print(fractionalDamage)
                    print(damage_to_reduce)
                    BlzSetUnitBaseDamage(target, R2I(targetDamage - damage_to_reduce), 0)
                    BlzSetUnitBaseDamage(caster, R2I(casterDamage + damage_to_reduce), 0)

                    Volatile_Siphon_Weapon_Indexing[key].casterDamage = casterDamage + damage_to_reduce
                    Volatile_Siphon_Weapon_Indexing[key].targetDamage = targetDamage - damage_to_reduce
                    Volatile_Siphon_Weapon_Indexing[key].fractionalDamage = fractionalDamage
                end
            elseif rounded_time <= 10 then
                if targetWeaponEnabled then
                    BlzSetUnitWeaponBooleanField(target, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0, false)
                    BlzSetUnitBaseDamage(target, R2I(0), 0)
                    BlzSetUnitBaseDamage(caster, R2I(casterDamage + targetDamage), 0)

                    Volatile_Siphon_Weapon_Indexing[key].casterDamage = casterDamage + targetDamage
                    Volatile_Siphon_Weapon_Indexing[key].targetDamage = 0
                    Volatile_Siphon_Weapon_Indexing[key].targetWeaponEnabled = false
                end
            elseif (rounded_time > 10) and (rounded_time <= 20) then
                if casterWeaponEnabled then
                    BlzSetUnitWeaponBooleanField(caster, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0, false)
                    BlzSetUnitWeaponBooleanField(target, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0, true)
                    BlzSetUnitBaseDamage(target, R2I(targetInitialDamage), 0)
                    BlzSetUnitBaseDamage(caster, R2I(casterInitialDamage), 0)
                    Volatile_Siphon_Weapon_Indexing[key].casterWeaponEnabled = false
                    Volatile_Siphon_Weapon_Indexing[key].targetWeaponEnabled = true
                end
            elseif rounded_time > 20 then
                BlzSetUnitWeaponBooleanField(caster, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0, true)
                cleanup_volatile_siphon_weapon_index(key)
            end

            Volatile_Siphon_Weapon_Indexing[key].time = Volatile_Siphon_Weapon_Indexing[key].time + 0.1
        end
    else
        DisableTrigger(volatile_siphon_weapon_timer_trigger)
    end
end

function cleanup_volatile_siphon_weapon_index(index_to_remove)
    Volatile_Siphon_Weapon_Indexing[index_to_remove] = nil
    count = 1
    for key, value in pairs(Volatile_Siphon_Weapon_Indexing) do
        Volatile_Siphon_Weapon_Indexing[count] = Volatile_Siphon_Weapon_Indexing[key]
        count = count + 1
    end
end