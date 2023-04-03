if Debug then Debug.beginFile "UnitInfoPanelsFormatting" end
local spacer = "\n|cff707070----------------------------------------------------|r\n"

function FormatAttributeTooltip(total, base)
    return string.format([[

    ]],
    total,
    base,
    total - base
    )
end

function CreateUnitInfoPanelTooltip(title, body)
    return title .. spacer .. body
end

if Debug then Debug.endFile() end