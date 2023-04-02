if Debug then Debug.beginFile"PhysicalStatsPage" end
OnInit.final("PhysicalStatsPage", function()
    local parent, frameObject, buttonCount, Data, unit
    local index, frame, tooltip, trigger, iconFrame, textFrame

    local function Init()
        buttonCount = 12
        frameObject = {}
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
            0
        )

        AddUnitInfoPanel(parent, function(unit)
            BlzFrameSetText(frameObject[1].Text, BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 0)))
            BlzFrameSetText(frameObject[2].Text, BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 2)))
            BlzFrameSetText(frameObject[3].Text, "0")
            BlzFrameSetText(frameObject[4].Text, "0")
            BlzFrameSetText(frameObject[5].Text, string.format( "%%.0f",GetUnitMoveSpeed(unit)))
            BlzFrameSetText(frameObject[6].Text, BlzFrameGetText(BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)))
            BlzFrameSetText(frameObject[7].Text, BlzFrameGetText(BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)))
            BlzFrameSetText(frameObject[8].Text, BlzFrameGetText(BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)))
            BlzFrameSetText(frameObject[10].Text, string.format( "%%.1f", BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE)))
            BlzFrameSetText(frameObject[11].Text, string.format( "%%.1f", BlzGetUnitRealField(unit, UNIT_RF_MANA_REGENERATION)))
        end,
        function(unit) return IsUnitType(unit, UNIT_TYPE_HERO) end)

        for int = 1, buttonCount do
            frame = BlzGetFrameByName("CustomUnitInfoButton"..int, 0)
            tooltip = BlzCreateFrameByType("SIMPLEFRAME", "", frame, "", 0)
            iconFrame = BlzGetFrameByName("CustomUnitInfoButton"..int, 0)
            textFrame = BlzGetFrameByName("CustomUnitInfoButtonText"..int, 0)
            BlzFrameSetTexture(iconFrame, Data[int][2], 0, false)
            BlzTriggerRegisterFrameEvent(trigger, frame, FRAMEEVENT_CONTROL_CLICK)
            BlzFrameSetTooltip(frame, tooltip)
            BlzFrameSetVisible(tooltip, false)
            UnitInfoPanelAddTooltipListener(tooltip, function(unit) return Data[int][1] .. BlzFrameGetText(frameObject[int].Text).."\n"..Data[int][3] end)
            frameObject[int] = { Index = int, Icon = iconFrame, Text = textFrame, Button = frame, ToolTip = tooltip}
            frameObject[frame] = frameObject[int]
        end
    end

    Data = {
        {"Damage: ", "ReplaceableTextures\\CommandButtons\\BTNSteelMelee", "The amount of damage your basic Attack deals"},
        {"Armor: ", "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne", "Reduces Taken non magical damage"},
        {"Ress: ", "ReplaceableTextures\\CommandButtons\\BTNThickFur", "Reduces Taken magical damage"},
        {"Crit: ", "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike",""},
        {"Speed: ", "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed", "The unit's current movespeed"},
        {"Str: ", "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower", "Increases Life and Liferegeneration"},
        {"Agi: ", "ReplaceableTextures\\CommandButtons\\BTNSlippersOfAgility", "Improves Armor and Attackspeed"},
        {"Int: ", "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence", "Improves Mana and Manaregeneration"},
        {"Zaubermacht: ", "ReplaceableTextures\\CommandButtons\\BTNControlMagic", "Makes most abilities better"},
        {"Hp/s: ", "ReplaceableTextures\\CommandButtons\\BTNRegenerate",""},
        {"Mp/s: ", "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry",""},
        {"Ausweichen: ", "ReplaceableTextures\\CommandButtons\\BTNEvasion",""}
    }

    trigger = CreateTrigger()
    TriggerAddAction(trigger, function()
        local unit = UnitInfoPanelGetUnit(GetTriggerPlayer())
        local buttonIndex = frameObject[BlzGetTriggerFrame()].Index
        print("Custom Stat Panel")
        print(GetPlayerName(GetTriggerPlayer()), "Clicked:", frameObject[BlzGetTriggerFrame()].Index, GetUnitName(unit))
    end)
    Init()
    if FrameLoaderAdd then FrameLoaderAdd(Init) end

end)

if Debug then Debug.endFile() end