if Debug then Debug.beginFile "FileIO" end
OnInit("UnitStats", function()
    ---@class UnitStats
    ---@field physicalBlock number
    ---@field magicArmor number
    ---@field magicBlock number
    ---@field evasion number
    ---@field evasionCrit number
    ---@field evasionPartial number
    ---@field critChance number
    ---@field critMean number
    ---@field critVariance number
    ---@field magicCritChance number
    ---@field magicCritMean number
    ---@field magicCritVariance number
    ---@field revived boolean
    ---@field reviveTime number
    UnitStats = {}

    DefaultUnitStats = {
        physicalBlock = 0,
        magicArmor = 0,
        magicBlock = 0,
        evasion = 0,
        evasionCrit = 0,
        evasionPartial = 0,
        critChance = 0,
        critMean = 0,
        critVariance = 0.75,
        magicCritChance = 0,
        magicCritMean = 0,
        magicCritVariance = 0.75,
        revived = false,
        reviveTime = 2.5
    }

    local unitCleanupTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(unitCleanupTrigger, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(unitCleanupTrigger, function() 
        local unit = GetTriggerUnit()
        if (UnitStats[unit].revived) then
            -- Should get a timer made here to revive units on death
            return
        end

        if (UnitStats[unit] ~= nil) then
            UnitStats[unit] = nil
        end
    end)
    
end)
if Debug then Debug.endFile() end
