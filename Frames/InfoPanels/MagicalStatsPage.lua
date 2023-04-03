if Debug then Debug.beginFile "MagicalStatsPage" end
OnInit.final("MagicalStatsPage", function()
    local parent, frameObject, buttonCount, Data, unit
    local index, frame, tooltip, trigger, iconFrame, textFrame
    local tooltipInfo = {}

    local function UnitInfoPanelTooltip(unit, int, context)
        return CreateUnitInfoPanelTooltip(
            Data[int][1],
            tooltipInfo[context][unit][int] .. '\n\n' .. Data[int][3]
        )
    end

    local function Init()
        buttonCount = 12
        frameObject = {}
        local context = 1
        tooltipInfo[context] = {}
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

        AddUnitInfoPanel(parent, function(unit)
            -- Gameplay constants
            local DefenseArmorConstant = 0.06 
            local IntRegenBonus = 0.05
            -- End of Gameplay Constants
            local stats = UnitStats[unit] ---@Type UnitStats
            local baseDamage = stats.magicAutoAttackDamage
            local unitArmor = stats.magicArmor
            local armorReduction = (unitArmor * DefenseArmorConstant)/(1 + DefenseArmorConstant * unitArmor) * 100
            
            local heroStrengthTotal = BlzGetUnitIntegerField(unit, UNIT_IF_STRENGTH_WITH_BONUS)
            local heroStrengthBase = BlzGetUnitIntegerField(unit, UNIT_IF_STRENGTH_PERMANENT)
            local heroStrengthBonus = heroStrengthTotal - heroStrengthBase
            
            local heroAgilityTotal = BlzGetUnitIntegerField(unit, UNIT_IF_AGILITY_WITH_BONUS)
            local heroAgilityBase = BlzGetUnitIntegerField(unit, UNIT_IF_AGILITY_PERMANENT)
            local heroAgilityBonus = heroAgilityTotal - heroAgilityBase

            local heroIntelligenceTotal = BlzGetUnitIntegerField(unit, UNIT_IF_INTELLIGENCE_WITH_BONUS)
            local heroIntelligenceBase = BlzGetUnitIntegerField(unit, UNIT_IF_INTELLIGENCE_PERMANENT)
            local heroIntelligenceBonus = heroIntelligenceTotal - heroIntelligenceBase

            local maxMana = BlzGetUnitMaxMana(unit)
            local manaRegenInt = heroIntelligenceTotal * IntRegenBonus
            local manaRegenUnit = BlzGetUnitRealField(unit, UNIT_RF_MANA_REGENERATION)
            local manaRegenTotal = manaRegenUnit + manaRegenInt

            local armorString = string.format("%%.0f\nReduction: %%.3f", unitArmor, armorReduction) .. "%%"

            tooltipInfo[context][unit] = {
                string.format("%%i", baseDamage),
                armorString,
                string.format("%%.0f", stats.magicBlock),
                string.format("Chance: %%.1f\nMean: %%.1f\nVariance: %%.1f", stats.magicCritChance, stats.magicCritMean, stats.magicCritVariance),
                string.format( "%%.0f",GetUnitMoveSpeed(unit)),
                string.format("Total: |cffAA0000%%i|r\nBase: |cff161cc9%%i|r\nBonus: |cff16c91c%%i|r", heroStrengthTotal, heroStrengthBase, heroStrengthBonus),
                string.format("Total: %%i\nBase: %%i\nBonus: %%i", heroAgilityTotal, heroAgilityBase, heroAgilityBonus),
                string.format("Total: %%i\nBase: %%i\nBonus: %%i", heroIntelligenceTotal, heroIntelligenceBase, heroIntelligenceBonus),
                string.format("Chance: %%.1f\nCrit: %%.1f\nPartial: %%.1f", stats.evasion, stats.evasionCrit, stats.evasionPartial),
                string.format( "%%i", maxMana),
                string.format( "Total: %%.3f\nUnit: %%.3f\nInt: %%.3f", manaRegenTotal, manaRegenUnit, manaRegenInt)
            }

            -- BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 0)) is for the frame that has attack damage
            -- BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 2)) is for the frame that has armor
            -- BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6) is for strength
            BlzFrameSetText(frameObject[1].Text, string.format("%%i", baseDamage))
            BlzFrameSetText(frameObject[2].Text, string.format("%%.0f", unitArmor))
            BlzFrameSetText(frameObject[3].Text, string.format("%%.0f", stats.magicBlock))
            BlzFrameSetText(frameObject[4].Text, string.format("%%.1f", stats.magicCritChance))
            BlzFrameSetText(frameObject[5].Text, string.format( "%%.0f",GetUnitMoveSpeed(unit)))
            BlzFrameSetText(frameObject[6].Text, string.format("%%i", heroStrengthTotal))
            BlzFrameSetText(frameObject[7].Text, string.format("%%i", heroAgilityTotal))
            BlzFrameSetText(frameObject[8].Text, string.format("%%i", heroIntelligenceTotal))
            BlzFrameSetText(frameObject[9].Text, string.format("%%.1f", stats.evasion))
            BlzFrameSetText(frameObject[10].Text, string.format( "%%i", maxMana))
            BlzFrameSetText(frameObject[11].Text, string.format( "%%.1f", manaRegenTotal))
            BlzFrameSetText(frameObject[12].Text, string.format( "%%.1f", maxMana))
        end,
        function(unit) return IsUnitType(unit, UNIT_TYPE_HERO) end)

        for int = 1, buttonCount do
            frame = BlzGetFrameByName("CustomUnitInfoButton"..int, context)
            tooltip = BlzCreateFrameByType("SIMPLEFRAME", "", frame, "", context)
            iconFrame = BlzGetFrameByName("CustomUnitInfoButtonIcon"..int, context)
            textFrame = BlzGetFrameByName("CustomUnitInfoButtonText"..int, context)
            BlzFrameSetTexture(iconFrame, Data[int][2], 0, false)
            BlzTriggerRegisterFrameEvent(trigger, frame, FRAMEEVENT_CONTROL_CLICK)
            BlzFrameSetTooltip(frame, tooltip)
            BlzFrameSetVisible(tooltip, false)
            UnitInfoPanelAddTooltipListener(tooltip, function(unit) 
                return UnitInfoPanelTooltip(unit, int, context)
            end)
            frameObject[int] = { Index = int, Icon = iconFrame, Text = textFrame, Button = frame, ToolTip = tooltip}
            frameObject[frame] = frameObject[int]
        end
        BlzFrameSetVisible(BlzGetFrameByName("CustomUnitInfoButton12", context), false)

    end

    Data = {
        {"Damage: ", "ReplaceableTextures\\CommandButtons\\BTNFlare", "Basic attack magical damage."},
        {"Armor: ", "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne", "Reduces magical damage by a percentage."},
        {"Block: ", "ReplaceableTextures\\CommandButtons\\BTNThickFur", "Reduces magical damage by the specified amount."},
        {"Crit: ", "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike","Magic crit chance, mean and variance for a gaussian distribution."},
        {"Speed: ", "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed", "Current move speed."},
        {"Str: ", "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower", "Increases life and life regeneration."},
        {"Agi:: ", "ReplaceableTextures\\CommandButtons\\BTNSlippersOfAgility", "Increases armor and attack speed."},
        {"Int: ", "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence", "Increases mana and mana regeneration."},
        {"Evasion: ", "ReplaceableTextures\\CommandButtons\\BTNEvasion", "Evasion for normal attacks, critical hits and partial avoidance."},
        {"MP: ", "ReplaceableTextures\\CommandButtons\\BTNStatUp","Max mana."},
        {"MP/s: ", "ReplaceableTextures\\CommandButtons\\BTNRegenerate","Mana regeneration per second."},
        {"Ausweichen: ", "ReplaceableTextures\\CommandButtons\\BTNEvasion",""}
    }

    trigger = CreateTrigger()
    TriggerAddAction(trigger, function()
        local unit = UnitInfoPanelGetUnit(GetTriggerPlayer())
        local buttonIndex = frameObject[BlzGetTriggerFrame()].Index
        FOI = frameObject[BlzGetTriggerFrame()].Icon
        print("Custom Stat Panel")
        print(GetPlayerName(GetTriggerPlayer()), "Clicked:", frameObject[BlzGetTriggerFrame()].Index, GetUnitName(unit))
    end)

    Init()

    if FrameLoaderAdd then FrameLoaderAdd(Init) end

end)

if Debug then Debug.endFile() end