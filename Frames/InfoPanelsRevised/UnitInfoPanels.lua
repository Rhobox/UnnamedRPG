if Debug then Debug.beginFile "UnitInfoPanelsDebug" end
OnInit.final("UnitInfoPanels", function()
    local panels = {}
    local firstPage, currentPage, lastPage
    local tooltipBox, tooltipTextFrame
    local unitInfo, parent, pageUp, pageDown
    local isReforged = (BlzFrameGetChild ~= nil)
    local renderTimer = CreateTimer()
    local tooltipTrigger = CreateTrigger()
    local nextTrigger = CreateTrigger()
    local prevTrigger = CreateTrigger()
    local storedPage = nil
    local condition

    local function getCondition(page)
        local newCondition
        page = page or currentPage
        for i, v in ipairs(panels[page].condition) do
            newCondition = v(CurrentUnit)
            if newCondition ~= nil then
                return newCondition
            end
        end
        return nil
    end

    local function updateCondition(page)
        local newCondition
        page = page or currentPage
        for i, v in ipairs(panels[currentPage].condition) do
            newCondition = v(CurrentUnit)
            if newCondition ~= nil then
                condition = newCondition
                break
            end
        end

        if newCondition == nil then
            condition = nil
        end
    end

    local function isValidUnitPage()
        updateCondition()
        if currentPage == firstPage and storedPage == nil then
            return true
        end

        local storedCondition = getCondition(storedPage)
        if storedPage ~= nil and storedPage ~= currentPage then
            if panels[storedPage].update[storedCondition] then
                BlzFrameSetVisible(currentPage, false)
                currentPage = storedPage
                updateCondition()
                panels[currentPage].update[condition](CurrentUnit)
                BlzFrameSetVisible(currentPage, true)
                storedPage = nil
                return true
            else
                BlzFrameSetVisible(currentPage, false)
                BlzFrameSetVisible(firstPage, true)
                currentPage = firstPage
            end
        else
            if panels[currentPage].update[condition] then
                panels[currentPage].update[condition](CurrentUnit)
                return true
            else
                storedPage = currentPage
                BlzFrameSetVisible(currentPage, false)
                BlzFrameSetVisible(firstPage, true)
                currentPage = firstPage
            end
        end

        return false
    end

    TriggerAddAction(tooltipTrigger, function()
        local frame = BlzGetTriggerFrame()
        local event = BlzGetTriggerFrameEvent()
        if event == FRAMEEVENT_MOUSE_LEAVE then
            BlzFrameSetVisible(tooltipBox, false)
        elseif event == FRAMEEVENT_MOUSE_ENTER then
            BlzFrameSetVisible(tooltipBox, true)
            local frameObject = panels[currentPage].frameObject[condition][frame]
            local index = frameObject.Index
            local tooltipText = panels[currentPage].tooltipUpdate[condition](CurrentUnit, index)
            BlzFrameSetText(tooltipTextFrame, tooltipText)
        end
    end)

    TriggerAddAction(nextTrigger, function()
        if (firstPage == lastPage) then return end
        local oldCurrent = currentPage

        if (panels[currentPage].nextPage ~= nil) then 
            currentPage = panels[panels[currentPage].nextPage].panel
        else
            currentPage = firstPage
        end

        if isValidUnitPage() then
            storedPage = nil
            BlzFrameSetVisible(oldCurrent, false)
            BlzFrameSetVisible(currentPage, true)
        end
    end)

    TriggerAddAction(prevTrigger, function()
        if (firstPage == lastPage) then return end
        local oldCurrent = currentPage

        if (panels[currentPage].prevPage ~= nil) then
            currentPage = panels[panels[currentPage].prevPage].index
        else
            currentPage = lastPage
        end

        if isValidUnitPage() then
            storedPage = nil
            BlzFrameSetVisible(oldCurrent, false)
            BlzFrameSetVisible(currentPage, true)
        end
    end)

    function GetSelectedUnit(player)
        player = player or GetLocalPlayer()
        local group = CreateGroup()
        GroupEnumUnitsSelected(group, player, nil)
        CurrentUnit = FirstOfGroup(group)
        DestroyGroup(group)
        isValidUnitPage()
    end

    function RegisterTooltipUpdate(frame)
        BlzTriggerRegisterFrameEvent(tooltipTrigger, frame, FRAMEEVENT_MOUSE_ENTER)
        BlzTriggerRegisterFrameEvent(tooltipTrigger, frame, FRAMEEVENT_MOUSE_LEAVE)
    end

    local function makeSubOfParent(frame)
        BlzFrameSetParent(frame, parent)
    end

    function AddUnitInfoPanelFrame(frame, update, condition, conditionCheck, tooltipUpdate, buttonCount, frameObject)
        BlzFrameSetParent(frame, BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0))
        BlzFrameSetVisible(frame, false)
        
        if (panels[frame] == nil) then
            panels[lastPage].nextPage = frame
            panels[frame] = {
                panel = frame,
                update = {
                    [condition] = update
                },
                condition = {
                    conditionCheck
                },
                tooltipUpdate = {
                    [condition] = tooltipUpdate
                },
                prevPage = lastPage,
                nextPage = nil,
                buttonCount = {
                    [condition] = buttonCount
                },
                frameObject = {
                    [condition] = frameObject
                },
                context =  panels[lastPage].context + 1
            }

            lastPage = frame
        else
            panels[frame].update[condition] = update
            panels[frame].tooltipUpdate[condition] = tooltipUpdate
            table.insert(panels[frame].condition, conditionCheck)
            panels[frame].buttonCount[condition] = buttonCount
            panels[frame].frameObject[condition] = frameObject
            panels[frame].index = panels[lastPage].index + 1
        end
    end

    function AddUnitInfoPanelNewSimpleFrame(update, condition)
        local frame = BlzCreateFrameByType("SIMPLEFRAME", "", BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0), "", 0)
        AddUnitInfoPanel(frame, update, condition)
    end

    local function init()
        BlzLoadTOCFile("war3mapImported\\UnitInfoPanels.toc")
        unitInfo = BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)
        parent = BlzCreateFrameByType("SIMPLEFRAME", "", unitInfo, "", 0)
        pageUp = BlzCreateSimpleFrame("UnitInfoSimpleIconButtonUp", unitInfo, 0)
        pageDown = BlzCreateSimpleFrame("UnitInfoSimpleIconButtonDown", unitInfo, 0)
        
        BlzFrameSetAbsPoint(pageUp, FRAMEPOINT_BOTTOMRIGHT, 0.51, 0.08)
        BlzTriggerRegisterFrameEvent(nextTrigger, pageUp, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(prevTrigger, pageDown, FRAMEEVENT_CONTROL_CLICK)
        
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconDamage", 0))
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconDamage", 1))
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconArmor", 2))
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconRank", 3))
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconFood", 4))
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconGold", 5))
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconHero", 6))
        makeSubOfParent(BlzGetFrameByName("SimpleInfoPanelIconAlly", 7))
        if isReforged then
            makeSubOfParent(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0))
        end

        panels[parent] = {
            panel = parent,
            condition = {
                function(unit) return true end
            },
            update = nil,
            prevPage = nil,
            nextPage = nil,
            index = parent,
            context = 1
        }

        firstPage = parent
        currentPage = parent
        lastPage = parent
        condition = true
        
        -- tooltip handling
        if isReforged then
            parent = BlzGetFrameByName("ConsoleUIBackdrop", 0)
        else
            parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        end

        tooltipBox = BlzCreateFrame("CustomUnitInfoTextBox", parent, 0, 0)
        tooltipTextFrame = BlzCreateFrame("CustomUnitInfoText", tooltipBox, 0, 0)
        BlzFrameSetAbsPoint(tooltipTextFrame, FRAMEPOINT_BOTTOMRIGHT, 0.79, 0.18)
        BlzFrameSetSize(tooltipTextFrame, 0.275, 0)
        BlzFrameSetPoint(tooltipBox, FRAMEPOINT_TOPLEFT, tooltipTextFrame, FRAMEPOINT_TOPLEFT, -0.01, 0.01)
        BlzFrameSetPoint(tooltipBox, FRAMEPOINT_BOTTOMRIGHT, tooltipTextFrame, FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.01)
        BlzFrameSetVisible(tooltipBox, false)

        TimerStart(renderTimer, 0.05, true, function()
            xpcall(function()
                if BlzFrameIsVisible(unitInfo) then
                    GetSelectedUnit()
                    updateCondition()
                    local localCondition = condition
                    local visiblePageChangeFrames = panels[currentPage].prevPage ~= nil or panels[currentPage].nextPage ~= nil
                    BlzFrameSetVisible(pageUp, visiblePageChangeFrames)
                    BlzFrameSetVisible(pageDown, visiblePageChangeFrames)

                    if panels[currentPage].update then
                        if panels[currentPage].update[localCondition] then
                            panels[currentPage].update[localCondition](CurrentUnit)
                        end
                    end

                    BlzFrameSetVisible(currentPage, true)
                else
                    BlzFrameSetVisible(currentPage, false)
                end
            end, print)
        end)
    end

    init()



end)
if Debug then Debug.endFile() end