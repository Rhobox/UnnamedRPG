function init_reapers_promise()
    reapers_promise_timer_trigger = CreateTrigger()
    TriggerRegisterTimerEventPeriodic(reapers_promise_timer_trigger, 0.10)
    TriggerAddAction(reapers_promise_timer_trigger, reapers_promise_periodic_action)

    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_CAST)
    TriggerAddAction(trigger, reapers_promise_action)


    Reapers_Promise_Indexing = {}
    Reapers_Promise_Indexing.caster = nil
    Reapers_Promise_Indexing.target = nil
    Reapers_Promise_Indexing.time = nil
end

function reapers_promise_action()
    local spell = GetSpellAbilityId()
    if spell == FourCC("A000") then
        local caster = GetTriggerUnit()
        local target = GetSpellTargetUnit()
        local count = #Reapers_Promise_Indexing + 1
        Reapers_Promise_Indexing[count] = {}
        Reapers_Promise_Indexing[count].caster = caster
        Reapers_Promise_Indexing[count].target = target
        Reapers_Promise_Indexing[count].time = 0
        if not IsTriggerEnabled(reapers_promise_timer_trigger) then
            EnableTrigger(reapers_promise_timer_trigger)
        end
    end
end

function reapers_promise_periodic_action()
    local current_life = nil
    local max_life = nil
    if #Reapers_Promise_Indexing > 0 then
        for key, value in pairs(Reapers_Promise_Indexing) do
            rounded_time = round(Reapers_Promise_Indexing[key].time, 10)
            if (rounded_time %% 5) < 0.1 then
                max_life = GetUnitState(Reapers_Promise_Indexing[key].target, UNIT_STATE_MAX_LIFE)
                current_life = GetUnitState(Reapers_Promise_Indexing[key].target, UNIT_STATE_LIFE)

                if current_life > 0 then
                    SetUnitState(Reapers_Promise_Indexing[key].target, UNIT_STATE_LIFE, (current_life - (max_life/5)))
                end
            end
            current_life = GetUnitState(Reapers_Promise_Indexing[key].target, UNIT_STATE_LIFE)
            caster_life = GetUnitState(Reapers_Promise_Indexing[key].caster, UNIT_STATE_LIFE)
            if Reapers_Promise_Indexing[key].time >= 30 then
                if current_life > 0 then
                    reapers_promise_cleanup(Reapers_Promise_Indexing[key].caster)
                end
                cleanup_reapers_promise_index(key)
            elseif current_life <= 0 then
                cleanup_reapers_promise_index(key)
            elseif caster_life <= 0 then
                cleanup_reapers_promise_index(key)
            end
            Reapers_Promise_Indexing[key].time = Reapers_Promise_Indexing[key].time + 0.1
        end
    else
        DisableTrigger(reapers_promise_timer_trigger)
    end
end

function cleanup_reapers_promise_index(index_to_remove)
    Reapers_Promise_Indexing[index_to_remove] = nil
    count = 1
    for key, value in pairs(Reapers_Promise_Indexing) do
        Reapers_Promise_Indexing[count] = Reapers_Promise_Indexing[key]
        count = count + 1
    end
end

function reapers_promise_cleanup(caster)
    SetUnitState(caster, UNIT_STATE_LIFE, 0)
end