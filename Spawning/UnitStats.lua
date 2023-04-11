if Debug then Debug.beginFile "UnitStats" end
OnInit("UnitStats", function()
    ---@class UnitStats
    ---@field weaponCooldownModifier number
    ---@field physicalAutoAttackDamageModifiers number
    ---@field physicalBlock number
    ---@field physicalArmorPierce number
    ---@field physicalBlockPierce number
    ---@field magicAutoAttackDamage integer
    ---@field magicArmor number
    ---@field magicBlock number
    ---@field magicArmorPierce number
    ---@field magicBlockPierce number
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
        weaponCooldownModifier = 0,

        physicalAutoAttackDamageModifiers = 0,
        physicalBlock = 0,
        physicalArmorPierce = 0,
        physicalBlockPierce = 0,

        magicAutoAttackDamage = 0,
        magicArmor = 0,
        magicBlock = 0,
        magicArmorPierce = 0,
        magicBlockPierce = 0,

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
