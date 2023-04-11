if Debug then Debug.beginFile "PhysicalStatsPageDebug" end
OnInit.final("PhysicalStatsPage", function()
    local maxButtons = 12
    local parent, buttonCount
    local frame, tooltip, trigger, iconFrame, textFrame

    local function Init()
        buttonCount = 11
        local frameObject = {}
        local context = 0
        -- Frames need to be preloaded to ensure they're available for all players
        -- to avoid a desync
        BlzGetFrameByName("InfoPanelIconValue", 0)
        BlzGetFrameByName("InfoPanelIconValue", 2)
        BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)
        BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)
        BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)
        
        parent = BlzCreateSimpleFrame(
            "CustomUnitInfoPanel3x4", 
            BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0),
            context
        )

        -- Physical Stats --
        -- Damage
        -- Weapon Cooldown
        -- Armor
        -- Block
        -- Crit
        -- Evade
        -- Armor Pierce
        -- Block Pierce

        local FrameButtonData = {
            field = {
                "Damage",
                "Armor",
                "Block",
                "Crit",
                "Speed",
                "Strength",
                "Agility",
                "Intelligence",
                "Evasion",
                "Hitpoints",
                "Hitpoint Regeneration"
            },
            texture = {
               "ReplaceableTextures\\CommandButtons\\BTNSteelMelee",
                "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne",
                "ReplaceableTextures\\CommandButtons\\BTNThickFur",
                "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike",
                "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed",
                "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower",
                "ReplaceableTextures\\CommandButtons\\BTNSlippersOfAgility",
                "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence",
                "ReplaceableTextures\\CommandButtons\\BTNEvasion",
                "ReplaceableTextures\\CommandButtons\\BTNStatUp",
                "ReplaceableTextures\\CommandButtons\\BTNRegenerate",
            },
            description = {
                "Basic attack physical damage.",
                "Reduces physical damage by a percentage.",
                "Reduces physical damage by the specified amount.",
                "Crit chance, mean and variance for a gaussian distribution.",
                "Current move speed.",
                "Increases life and life regeneration.",
                "Increases armor and attack speed.",
                "Increases mana and mana regeneration.",
                "Evasion for normal attacks, critical hits and partial avoidance.",
                "Max hitpoints.",
                "Hitpoint regeneration per second.",
            }
        }

        for int = 1, buttonCount do
            frame = BlzGetFrameByName("CustomUnitInfoButton"..int, context)
            tooltip = BlzCreateFrameByType("SIMPLEFRAME", "", frame, "", context)
            iconFrame = BlzGetFrameByName("CustomUnitInfoButtonIcon"..int, context)
            textFrame = BlzGetFrameByName("CustomUnitInfoButtonText"..int, context)
            BlzFrameSetTexture(iconFrame, FrameButtonData.texture[int], 0, false)
            BlzTriggerRegisterFrameEvent(trigger, frame, FRAMEEVENT_CONTROL_CLICK)
            BlzFrameSetTooltip(frame, tooltip)
            BlzFrameSetVisible(tooltip, false)
            RegisterTooltipUpdate(frame)
            frameObject[int] = { Index = int, Icon = iconFrame, Text = textFrame, Button = frame, ToolTip = tooltip}
            frameObject[frame] = frameObject[int]
        end

        for int = buttonCount + 1, maxButtons do
            BlzFrameSetVisible(BlzGetFrameByName("CustomUnitInfoButton"..int, context), false)
        end

        local update = function(unit)
            local baseDamage = BlzGetUnitBaseDamage(unit, 0)
            local unitArmor = BlzGetUnitArmor(unit)
            local stats = UnitStats[unit] ---@Type UnitStats
            local heroStrengthTotal = BlzGetUnitIntegerField(unit, UNIT_IF_STRENGTH_WITH_BONUS)
            local heroAgilityTotal = BlzGetUnitIntegerField(unit, UNIT_IF_AGILITY_WITH_BONUS)
            local heroIntelligenceTotal = BlzGetUnitIntegerField(unit, UNIT_IF_INTELLIGENCE_WITH_BONUS)
            local maxHealth = BlzGetUnitMaxHP(unit)
            local healthRegenStr = heroStrengthTotal * StrRegenBonus
            local healthRegenUnit = BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE)
            local healthRegenTotal = healthRegenUnit + healthRegenStr

            BlzFrameSetText(frameObject[1].Text, string.format("%%i", baseDamage))
            BlzFrameSetText(frameObject[2].Text, string.format("%%.0f", unitArmor))
            BlzFrameSetText(frameObject[3].Text, string.format("%%.0f", stats.physicalBlock))
            BlzFrameSetText(frameObject[4].Text, string.format("%%.1f", stats.critChance))
            BlzFrameSetText(frameObject[5].Text, string.format( "%%.0f",GetUnitMoveSpeed(unit)))
            BlzFrameSetText(frameObject[6].Text, string.format("%%i", heroStrengthTotal))
            BlzFrameSetText(frameObject[7].Text, string.format("%%i", heroAgilityTotal))
            BlzFrameSetText(frameObject[8].Text, string.format("%%i", heroIntelligenceTotal))
            BlzFrameSetText(frameObject[9].Text, string.format("%%.1f", stats.evasion))
            BlzFrameSetText(frameObject[10].Text, string.format( "%%.1f", maxHealth))
            BlzFrameSetText(frameObject[11].Text, string.format( "%%.1f", healthRegenTotal))
        end

        local tooltipText = {
            function(unit)
                local baseDamage = BlzGetUnitBaseDamage(unit, 0)
                return string.format("%%i", baseDamage)
            end,
            function(unit)
                local unitArmor = BlzGetUnitArmor(unit)
                local armorReduction = (unitArmor * DefenseArmorConstant)/(1 + DefenseArmorConstant * unitArmor) * 100
                local armorString = string.format("%%.0f\nReduction: %%.3f", unitArmor, armorReduction) .. "%%"
                return armorString
            end,
            function(unit)
                local stats = UnitStats[unit] ---@Type UnitStats
                return string.format("%%.0f", stats.physicalBlock)
            end,
            function(unit)
                local stats = UnitStats[unit] ---@Type UnitStats
                return string.format("Chance: %%.1f\nMean: %%.1f\nVariance: %%.1f", stats.critChance, stats.critMean, stats.critVariance)
            end,
            function(unit)
                return string.format( "%%.0f",GetUnitMoveSpeed(unit))
            end,
            function(unit)
                local heroStrengthTotal = BlzGetUnitIntegerField(unit, UNIT_IF_STRENGTH_WITH_BONUS)
                local heroStrengthBase = BlzGetUnitIntegerField(unit, UNIT_IF_STRENGTH_PERMANENT)
                local heroStrengthBonus = heroStrengthTotal - heroStrengthBase
                return string.format("Total: |cffAA0000%%i|r\nBase: |cff161cc9%%i|r\nBonus: |cff16c91c%%i|r", heroStrengthTotal, heroStrengthBase, heroStrengthBonus)
            end,
            function(unit)
                local heroAgilityTotal = BlzGetUnitIntegerField(unit, UNIT_IF_AGILITY_WITH_BONUS)
                local heroAgilityBase = BlzGetUnitIntegerField(unit, UNIT_IF_AGILITY_PERMANENT)
                local heroAgilityBonus = heroAgilityTotal - heroAgilityBase
                return string.format("Total: %%i\nBase: %%i\nBonus: %%i", heroAgilityTotal, heroAgilityBase, heroAgilityBonus)
            end,
            function(unit)
                local heroIntelligenceTotal = BlzGetUnitIntegerField(unit, UNIT_IF_INTELLIGENCE_WITH_BONUS)
                local heroIntelligenceBase = BlzGetUnitIntegerField(unit, UNIT_IF_INTELLIGENCE_PERMANENT)
                local heroIntelligenceBonus = heroIntelligenceTotal - heroIntelligenceBase
                return string.format("Total: %%i\nBase: %%i\nBonus: %%i", heroIntelligenceTotal, heroIntelligenceBase, heroIntelligenceBonus)
            end,
            function(unit)
                local stats = UnitStats[unit] ---@Type UnitStats
                return string.format("Chance: %%.1f\nCrit: %%.1f\nPartial: %%.1f", stats.evasion, stats.evasionCrit, stats.evasionPartial)
            end,
            function(unit)
                local maxHealth = BlzGetUnitMaxHP(unit)
                return string.format( "%%i", maxHealth)
            end,
            function(unit)
                local heroStrengthTotal = BlzGetUnitIntegerField(unit, UNIT_IF_STRENGTH_WITH_BONUS)
                local healthRegenStr = heroStrengthTotal * StrRegenBonus
                local healthRegenUnit = BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE)
                local healthRegenTotal = healthRegenUnit + healthRegenStr
                return string.format( "Total: %%.3f\nUnit: %%.3f\nStr: %%.3f", healthRegenTotal, healthRegenUnit, healthRegenStr)
            end,
        }

        AddUnitInfoPanelFrame(parent,
        update,
        UNIT_TYPE_HERO,
        function(unit)
            if IsUnitType(unit, UNIT_TYPE_HERO) then
                return UNIT_TYPE_HERO
            end

            return nil
        end,
        function(unit, index)
            
            return CreateUnitInfoPanelTooltip(
                FrameButtonData.field[index] .. ":",
                tooltipText[index](unit) .. '\n\n' .. FrameButtonData.description[index]
            )
        end,
        buttonCount,
        frameObject)
    end

    trigger = CreateTrigger()
    TriggerAddAction(trigger, function()
        local unit = GetSelectedUnit(GetTriggerPlayer())
        local buttonIndex = frameObject[BlzGetTriggerFrame()].Index
        FOI = frameObject[BlzGetTriggerFrame()].Icon
        print("Custom Stat Panel")
        print(GetPlayerName(GetTriggerPlayer()), "Clicked:", frameObject[BlzGetTriggerFrame()].Index, GetUnitName(unit))
    end)

    Init()

    if FrameLoaderAdd then FrameLoaderAdd(Init) end

end)

if Debug then Debug.endFile() end