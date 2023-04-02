if Debug then Debug.beginFile "UnitInfoPanels" end
OnInit.final("UnitInfoPanels", function() 
    local realMarkGameStarted = MarkGameStarted
    local wantedIndex = 1
    local panels, panelsCondition, panelFrame, updates
    local tooltipListener, tooltipBox, tooltipText
    local isReforged = (BlzFrameGetChild ~= nil)
    local UnitInfoPanelUnit = nil
    local group, timer, trigger
    local unitInfo, parent, pageUp, pageDown, pageUpBig, pageSwaps, createContext, activeIndex
    local HAVE_BIG_PAGE_BUTTON = false

    function UnitInfoPanelGetUnit(p)
        local player = p or GetLocalPlayer()
        GroupEnumUnitsSelected(group, player, nil)
        UnitInfoPanelUnit = FirstOfGroup(group)
        GroupClear(group)
        return UnitInfoPanelUnit
    end

    function AddUnitInfoPanel(frame, update, condition)
        BlzFrameSetParent(frame, BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0))
        table.insert(panels, frame)
        panelsCondition[#panels] = condition
        updates[#panels] = update
        BlzFrameSetVisible(frame, false)
    end

    function AddUnitInfoPanelEx(update, condition) -- ex?
        local frame = BlzCreateFrameByType("SIMPLEFRAME", "", BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0), "", 0)
        AddUnitInfoPanel(frame, update, condition)
        return frame
    end

    function SetUnitInfoPanelFrame(frame)
        panelFrame[#panels] = frame
        BlzFrameSetVisible(frame, false)
    end

    function SetUnitInfoPanelFrameEx() -- ex?
        local frame = BlzCreateFrameByType("FRAME", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        SetUnitInfoPanelFrame(frame)
        return frame
    end 

    function UnitInfoPanelAddTooltipListener(frame, listener)
        if not tooltipListener[frame] then
            table.insert(tooltipListener, frame)
            tooltipListener[frame] = listener
        end
    end

    function UnitInfoAddTooltip(parent, frame)
        local button = nil
        if not isReforged then
            button = BlzCreateSimpleFrame("EmptySimpleButton", parent, 0)
            BlzFrameSetAllPoints(button, frame)
            BlzFrameSetLevel(button, 9)
        end

        local effectiveParent = button or BlzFrameGetChild(parent, 0)

        local tooltip = BlzCreateFrameByType("SIMPLEFRAME", "", effectiveParent, "", 0)
        
        BlzFrameSetTooltip(effectiveParent, tooltip)
        BlzFrameSetVisible(tooltip, false)
        return tooltip
    end

    function UnitInfoAddTooltipEx(parent, frame, code)
        UnitInfoPanelAddTooltipListener(UnitInfoAddTooltip(parent, frame), code)
    end

    function UnitInfoCreateCustomInfo(parent, label, texture, tooltipCode)
        createContext = createContext + 1
        local infoFrame = BlzCreateSimpleFrame("SimpleInfoPanelIconRank", parent, createContext)
        local iconFrame = BlzGetFrameByName("InfoPanelIconBackdrop", createContext)
        local labelFrame = BlzGetFrameByName("InfoPanelIconLabel", createContext)
        local textFrame = BlzGetFrameByName("InfoPanelIconValue", createContext)

        BlzFrameSetText(labelFrame, label)
        BlzFrameSetText(textFrame, "xxx")
        BlzFrameSetTexture(iconFrame, texture, 0, false)
        BlzFrameClearAllPoints(iconFrame)
        BlzFrameSetSize(iconFrame, 0.028, 0.028)
        if tooltipCode then
            UnitInfoAddTooltipEx(infoFrame, iconFrame, tooltipCode)
        end
        return createContext, infoFrame, iconFrame, labelFrame, textFrame
    end

    local function PageSwapCheck()
        pageSwaps = pageSwaps - 1
        if pageSwaps < 0 then
            return false
        end
        return true
    end

    local function nextPanel()
        activeIndex = activeIndex + 1
        if activeIndex > #panels then
            activeIndex = 1
        end

        if PageSwapCheck() and not panelsCondition[activeIndex](UnitInfoPanelUnit) then
            nextPanel()
        end
    end

    local function prevPanel()
        activeIndex = activeIndex - 1
        if activeIndex < 1 then
           activeIndex = #panels
        end
        if PageSwapCheck() and not panelsCondition[activeIndex](UnitInfoPanelUnit) then
            prevPanel()
        end
    end

    local function makeSub(frame)
        BlzFrameSetParent(frame, parent)
    end

    function UnitInfoPanelSetPage(newPage, updateWanted)
        if string.sub(tostring(newPage), 1, 12) == "framehandle:" then
            local found = false
            for i, v in ipairs(panels) do
                if v == newPage or panelFrame[i] == newPage then
                    newPage = i
                    found = true
                    break
                end
            end
            if not found then 
                return
            end
        end

        BlzFrameSetVisible(panels[activeIndex], false)
        BlzFrameSetVisible(panelFrame[activeIndex], false)

        if newPage == "+" then
            pageSwaps = #panels
            nextPanel()
        elseif newPage == "-" then
            pageSwaps = #panels
            prevPanel()
        else
            activeIndex = math.min(#panels, math.max(1, newPage))
        end

        if updateWanted then
            wantedIndex = activeIndex
        end

        BlzFrameSetVisible(panels[activeIndex], true)
        BlzFrameSetVisible(panelFrame[activeIndex], true)

    end

    local function defaultCondition()
        return true
    end

    local function Init()
        BlzLoadTOCFile("war3mapImported\\UnitInfoPanels.toc")
        tooltipListener = {}
        panelsCondition = {defaultCondition}
        panels = {}
        panelFrame = {}
        updates = {}
        activeIndex = 1
        createContext = 1000
        unitInfo = BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)
        parent = BlzCreateFrameByType("SIMPLEFRAME", "", unitInfo, "", 0)
        pageUp = BlzCreateSimpleFrame("UnitInfoSimpleIconButtonUp", unitInfo, 0)
        pageDown = BlzCreateSimpleFrame("UnitInfoSimpleIconButtonDown", unitInfo, 0)
        BlzFrameSetAbsPoint(pageUp, FRAMEPOINT_BOTTOMRIGHT, 0.51, 0.08)

        if HAVE_BIG_PAGE_BUTTON then
            pageUpBig = BlzCreateSimpleFrame("EmptySimpleButton", unitInfo, 0)
            BlzFrameSetAllPoints(pageUpBig, unitInfo)
            BlzFrameSetLevel(pageUpBig, 0)
            BlzTriggerRegisterFrameEvent(trigger, pageUpBig, FRAMEEVENT_CONTROL_CLICK)
        end

        BlzTriggerRegisterFrameEvent(trigger, pageUp, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(trigger, pageDown, FRAMEEVENT_CONTROL_CLICK)
        panels[1] = parent

        makeSub(BlzGetFrameByName("SimpleInfoPanelIconDamage", 0))
        makeSub(BlzGetFrameByName("SimpleInfoPanelIconDamage", 1))
        makeSub(BlzGetFrameByName("SimpleInfoPanelIconArmor", 2))
        makeSub(BlzGetFrameByName("SimpleInfoPanelIconRank", 3))
        makeSub(BlzGetFrameByName("SimpleInfoPanelIconFood", 4))
        makeSub(BlzGetFrameByName("SimpleInfoPanelIconGold", 5))
        makeSub(BlzGetFrameByName("SimpleInfoPanelIconHero", 6))
        makeSub(BlzGetFrameByName("SimpleInfoPanelIconAlly", 7))
        if isReforged then
            makeSub(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0))
        end

        -- tooltip handling
        if isReforged then
            parent = BlzGetFrameByName("ConsoleUIBackdrop", 0)
        else
            parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        end

        tooltipBox = BlzCreateFrame("CustomUnitInfoTextBox", parent, 0, 0)
        tooltipText = BlzCreateFrame("CustomUnitInfoText", tooltipBox, 0, 0)
        BlzFrameSetAbsPoint(tooltipText, FRAMEPOINT_BOTTOMRIGHT, 0.79, 0.18)
        BlzFrameSetSize(tooltipText, 0.275, 0)
        BlzFrameSetPoint(tooltipBox, FRAMEPOINT_TOPLEFT, tooltipText, FRAMEPOINT_TOPLEFT, -0.01, 0.01)
        BlzFrameSetPoint(tooltipBox, FRAMEPOINT_BOTTOMRIGHT, tooltipText, FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.01)
        BlzFrameSetVisible(tooltipBox, false)

        TimerStart(timer, 0.05, true, function()
            xpcall(function()
                local found = false
                if BlzFrameIsVisible(unitInfo) then
                    UnitInfoPanelGetUnit(GetLocalPlayer())

                    for int = 1, #tooltipListener, 1 do
                        if BlzFrameIsVisible(tooltipListener[int]) then
                        BlzFrameSetText(tooltipText, tooltipListener[tooltipListener[int]](UnitInfoPanelUnit))
                        found = true
                        break
                        end
                    end

                local usablePages = 0
                for i, v in ipairs(panels) do
                    if not panels[v] or panels[v](UnitInfoPanelUnit) then
                        usablePages = usablePages + 1
                    end
                end

                local visiblePageChangeFrames = usablePages > 1
                BlzFrameSetVisible(pageUp, visiblePageChangeFrames)
                BlzFrameSetVisible(pageDown, visiblePageChangeFrames)

                ---@diagnostic disable-next-line: unused-function, redundant-parameter
                if wantedIndex ~= activeIndex and panelsCondition[wantedIndex](UnitInfoPanelUnit) then
                    UnitInfoPanelSetPage(wantedIndex)
                end

                if not panelsCondition[activeIndex](UnitInfoPanelUnit) then
                    UnitInfoPanelSetPage("+")
                end

                if updates[activeIndex] then 
                    updates[activeIndex](UnitInfoPanelUnit) 
                end

                BlzFrameSetVisible(panelFrame[activeIndex], true)
            else
                BlzFrameSetVisible(panelFrame[activeIndex], false)
            end
            BlzFrameSetVisible(tooltipBox, found)
            end, print)
        end)
    end

    group = CreateGroup()
    timer = CreateTimer()
    trigger = CreateTrigger()
    TriggerAddAction(trigger, function()
        if GetTriggerPlayer() == GetLocalPlayer() then
            if BlzGetTriggerFrame() == pageDown then 
                UnitInfoPanelSetPage("-", true)
            else
                UnitInfoPanelSetPage("+", true)
            end
        end
    end)
    Init()
    if FrameLoaderAdd then FrameLoaderAdd(Init) end

end )
if Debug then Debug.endFile() end
