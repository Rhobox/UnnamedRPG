function init_shattered_earth()
    shattered_earth_timer_trigger = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(shattered_earth_timer_trigger, 0.1)
    TriggerAddAction(shattered_earth_timer_trigger, shattered_earth_periodic_action)
    DisableTrigger(shattered_earth_timer_trigger)

    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_CAST)
    TriggerAddAction(trigger, shattered_earth_action)


    Shattered_Earth_Indexing = {}
    Shattered_Earth_Indexing.caster = nil
    Shattered_Earth_Indexing.targetx = nil
    Shattered_Earth_Indexing.targety = nil
    Shattered_Earth_Indexing.radius = nil
    Shattered_Earth_Indexing.angle = nil
    Shattered_Earth_Indexing.time = nil
    Shattered_Earth_Indexing.effects = nil
    Shattered_Earth_Indexing.target_stacks = nil
end

function shattered_earth_action()
    local spell = GetSpellAbilityId()
    if spell == FourCC("A003") then
        local caster = GetTriggerUnit()
        local targetx = GetSpellTargetX()
        local targety = GetSpellTargetY()
        local count = #Shattered_Earth_Indexing + 1
        Shattered_Earth_Indexing[count] = {}
        Shattered_Earth_Indexing[count].caster = caster
        Shattered_Earth_Indexing[count].targetx = targetx
        Shattered_Earth_Indexing[count].targety = targety
        Shattered_Earth_Indexing[count].radius = 25
        Shattered_Earth_Indexing[count].angle = 0
        Shattered_Earth_Indexing[count].time = 0
        Shattered_Earth_Indexing[count].effects = {}
        Shattered_Earth_Indexing[count].target_stacks = {}
        if not IsTriggerEnabled(shattered_earth_timer_trigger) then
            EnableTrigger(shattered_earth_timer_trigger)
        end
    end
end

function shattered_earth_periodic_action()
    global_key = nil
    local group = nil
    local small_radius = 100
    local large_radius = 600
    local count = nil
    local x = nil
    local y = nil
    local offset = nil
    local angle = nil -- radians
    local period = 2
    local frequency = 0.1
    local effect = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
    local numTraces = 6
    local last_effect = nil
    if #Shattered_Earth_Indexing > 0 then
        for key, value in pairs(Shattered_Earth_Indexing) do
            rounded_time = round(value.time, 10)
            remove_effects(key)
            if rounded_time < 2.06 then
                value.radius = value.radius + 25
                coeff = 0.1 / period
                angle = math.pi * 2 * coeff
                value.angle = value.angle + angle

                -- native AddSpecialEffect             takes string modelName, real x, real y returns effect
                -- native GroupEnumUnitsInRange                takes group whichGroup, real x, real y, real radius, boolexpr filter (accepts null) returns nothing

                for i = 0, numTraces - 1 do
                    angle = value.angle + i * (2 * math.pi / numTraces)
                    x = value.radius * math.cos(angle) + value.targetx
                    y = value.radius * math.sin(angle) + value.targety
                    
                    
                    last_effect = AddSpecialEffect(effect, x, y)
                    BlzSetSpecialEffectScale(last_effect, 0.1)

                    group = CreateGroup()
                    GroupEnumUnitsInRange(group, x, y, small_radius, nil)
                    global_key = key
                    ForGroup(group, small_explosion_effects)
                    DestroyGroup(group)

                    count = #value.effects + 1
                    value.effects[count] = last_effect
                end
                

            elseif rounded_time < 3.06 then
                radius = value.radius
                coeff = rounded_time
                angle = math.pi / 2 * coeff
                value.angle = value.angle + angle

                for i = 0, numTraces - 1 do
                    angle = angle + i * (2 * math.pi / numTraces)
                    x = radius * math.cos(angle) + value.targetx
                    y = radius * math.sin(angle) + value.targety
                    
                    last_effect = AddSpecialEffect(effect, x, y)
                    BlzSetSpecialEffectScale(last_effect, 0.1)

                    group = CreateGroup()
                    GroupEnumUnitsInRange(group, x, y, small_radius, nil)
                    global_key = key
                    ForGroup(group, small_explosion_effects)
                    DestroyGroup(group)


                    count = #value.effects + 1
                    value.effects[count] = last_effect
                end

            elseif rounded_time < 5.06 then
                value.radius = value.radius - 25
                coeff = 0.1 / period
                angle = math.pi * 2 * coeff
                value.angle = value.angle + angle

                

                for i = 0, numTraces - 1 do
                    angle = value.angle + i * (2 * math.pi / numTraces)
                    x = value.radius * math.cos(angle) + value.targetx
                    y = value.radius * math.sin(angle) + value.targety
                    
                    last_effect = AddSpecialEffect(effect, x, y)
                    BlzSetSpecialEffectScale(last_effect, 0.1)

                    group = CreateGroup()
                    GroupEnumUnitsInRange(group, x, y, small_radius, nil)
                    global_key = key
                    ForGroup(group, small_explosion_effects)
                    DestroyGroup(group)


                    count = #value.effects + 1
                    value.effects[count] = last_effect
                end
            end

            if (rounded_time - 5.1) > 0 and (rounded_time - 5.1) < 0.1 then
                    x = value.targetx
                    y = value.targety
                    last_effect = AddSpecialEffect(effect, x, y)
                    BlzSetSpecialEffectScale(last_effect, 3)
                    group = CreateGroup()
                    GroupEnumUnitsInRange(group, x, y, large_radius, nil)
                    global_key = key
                    ForGroup(group, large_explosion_effects)
                    DestroyGroup(group)

                    count = #value.effects + 1
                    value.effects[count] = last_effect
            end
            value.time = value.time + 0.10
            if value.time > 5.2 then
                cleanup_shattered_earth_index(key)
            end
        end
    else
        DisableTrigger(shattered_earth_timer_trigger)
    end
end

function small_explosion_effects()
    local key = global_key
    local unit_target = GetEnumUnit()
    if IsUnitType(unit_target, UNIT_TYPE_DEAD) then

    else
        local caster = Shattered_Earth_Indexing[key].caster
        UnitDamageTarget(caster, unit_target, 1, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC)
        if Shattered_Earth_Indexing[key].target_stacks[unit_target] == nil then
            Shattered_Earth_Indexing[key].target_stacks[unit_target] = 1
        else
            Shattered_Earth_Indexing[key].target_stacks[unit_target] = Shattered_Earth_Indexing[key].target_stacks[unit_target] +1
        end
        print(caster, Shattered_Earth_Indexing[key].target_stacks[unit_target])
    end
    
end

function large_explosion_effects()
    local key = global_key
    local unit_target = GetEnumUnit()
    if IsUnitType(unit_target, UNIT_TYPE_DEAD) then

    else
        local caster = Shattered_Earth_Indexing[key].caster
        local stacks = Shattered_Earth_Indexing[key].target_stacks[unit_target]
        print(unit_target)
        print(stacks)
        if stacks == nil then
            
        else
            UnitDamageTarget(caster, unit_target, (10 * stacks), ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC)
        end
    end
    

end

function remove_effects(index)
    for key, value in pairs(Shattered_Earth_Indexing[index].effects) do
        Shattered_Earth_Indexing[index].effects[key] = nil
        DestroyEffect(value)
    end
end

function cleanup_shattered_earth_index(index_to_remove)
    Shattered_Earth_Indexing[index_to_remove] = nil
    count = 1
    for key, value in pairs(Shattered_Earth_Indexing) do
        Shattered_Earth_Indexing[count] = Shattered_Earth_Indexing[key]
        count = count + 1
    end
end

function shattered_earth_cleanup(caster)
    
end