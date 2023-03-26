if Debug then Debug.beginFile "Spawning" end
function setup_spawning()
    init_spawning_triggers()
end

function init_spawning_triggers()
    init_spawning_trigger()
end

function init_spawning_trigger()
    local trig = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(trig, Player(0), OSKEY_M, 0, true)
    TriggerAddAction(trig, spawning_trigger_action)
end

function spawning_trigger_action()
    local unit = {} ---@type unitStats
    unit.location = GetRectCenter(GetPlayableMapRect())
    unit.name = 'Steven the Test Unit'
    unit.life = math.random(100, 1000)
    unit.mana =  math.random(10, 100)
    unit.damage = math.random(10, 150)
    unit.attackSpeed = (math.random(5, 100) / 100)
    unit.armor = math.random(0, 100)
    unit.block = math.random(0, 20)

    UnitHandle = SpawnUnit(unit)
end

---@class unitStats
---@field location location
---@field skin? integer
---@field name? string
---@field possibleAbilities? table
---@field numAbilities? integer
---@field life? number
---@field lifeRegen? number
---@field mana? number
---@field manaRegen? number
---@field damage? number
---@field attackSpeed? number
---@field armor? number
---@field block? number
---@field magicArmor? number
---@field magicBlock? number
---@field bounty? integer
---@field moveSpeed? number
---@field evasion? number
---@field evasionCrit? number
---@field evasionPartial? number
---@field critChance? number
---@field critMean? number
---@field critVariance? number
---@field unitCode string
---@field player? player
---@field angle? number


---@param unitStats unitStats
---@return unit
function SpawnUnit(unitStats)
    local location = unitStats.location or nil
    local skin = unitStats.skin or nil
    local name = unitStats.name or nil
    local possibleAbilities = unitStats.possibleAbilities or {}
    local numAbilities = unitStats.numAbilities or 0
    local life = unitStats.life or nil
    local lifeRegen = unitStats.lifeRegen or nil
    local mana = unitStats.mana or nil
    local manaRegen = unitStats.manaRegen or nil
    local damage = unitStats.damage or nil
    local attackSpeed = unitStats.attackSpeed or nil
    local armor = unitStats.armor or nil
    local block = unitStats.block or 0
    local magicArmor = unitStats.magicArmor or 0
    local magicBlock = unitStats.magicBlock or 0
    local bounty = unitStats.bounty or nil
    local moveSpeed = unitStats.moveSpeed or nil
    local evasion = unitStats.evasion or 0
    local evasionCrit = unitStats.evasionCrit or 0
    local evasionPartial = unitStats.evasionPartial or 0
    local critChance = unitStats.critChance or 0
    local critMean = unitStats.critMean or 0
    local critVariance = unitStats.critVariance or 0
    local unitCode = unitStats.unitCode or "hfoo"
    local player = unitStats.player or GetLocalPlayer()
    local angle = unitStats.angle or bj_UNIT_FACING

    local createdUnit = nil
    local ability = nil
    local abilities = {}

    if skin == nil then
        skin = math.random(1, #possible_skins)
    end
    if name == nil then
        name = possible_names[math.random(1, #possible_names)]
    end

    if numAbilities > 0 then
        for i = 1, numAbilities do
            ability = math.random(1, #possibleAbilities)
            possibleAbilities[i] = ability
        end
    end

    createdUnit = UnitCreation(player, unitCode, location, angle)

    SetUnitSkin(createdUnit, possible_skins[skin])
    SetUnitName(createdUnit, name .. '_' .. tostring(SpawnCount))
    SetUnitLife(createdUnit, life)
    SetUnitLifeRegen(createdUnit, lifeRegen)
    SetUnitMana(createdUnit, mana)
    SetUnitManaRegen(createdUnit, manaRegen)
    SetUnitDamage(createdUnit, damage)
    SetUnitAttackSpeed(createdUnit, attackSpeed)
    SetUnitArmor(createdUnit, armor)
    SetUnitBounty(createdUnit, bounty)
    SetUnitMoveSpeed(createdUnit, moveSpeed)
    SetUnitBlock(createdUnit, block)
    SetUnitMagicBlock(createdUnit, magicBlock)
    SetUnitMagicArmor(createdUnit, magicArmor)
    SetUnitMagicBlock(createdUnit, block)
    SetUnitEvasion(createdUnit, evasion)
    SetUnitEvasionCrit(createdUnit, evasionCrit)
    SetUnitEvasionPartial(createdUnit, evasionPartial)
    SetUnitCritChance(createdUnit, critChance)
    SetUnitCritMean(createdUnit, critMean)
    SetUnitCritVariance(createdUnit, critVariance)

    SpawnCount = SpawnCount + 1

    return createdUnit
end

--- Spawns a unit and registers the unit handle on UnitStats table
---@param player player Player for which to spawn unit
---@param unitCode string FourCC code of unit to spawn
---@param location location Location of unit spawn
---@param angle number Angle for spawned unit to face
function UnitCreation(player, unitCode, location, angle)
    local unit = CreateUnitAtLoc(player, FourCC(unitCode), location, angle)
    UnitStats[unit] = DefaultUnitStats
    return unit
end

---@param unit unit
---@param skin integer
function SetUnitSkin(unit, skin)
    if (skin == nil) then return end
    BlzSetUnitSkin(unit, skin)
end

---@param unit unit
---@param name string | nil
function SetUnitName(unit, name)
    if (name == nil) then return end
    BlzSetUnitName(unit, name)
end

---@param unit unit
---@param life number | nil
function SetUnitMaxLife(unit, life)
    if (life == nil) then return end
    BlzSetUnitMaxHP(unit, life)
end

---@param unit unit
---@param life number | nil
function SetUnitCurrentLife(unit, life)
    if (life == nil) then return end
    SetUnitState(unit, UNIT_STATE_LIFE, life)
end

---@param unit unit
---@param life number | nil
function SetUnitLife(unit, life)
    if (life ~= nil) then
        SetUnitMaxLife(unit, life)
        SetUnitCurrentLife(unit, life)
    end
end

---@param unit unit
---@param regen number | nil
function SetUnitLifeRegen(unit, regen)
    if (regen == nil) then return end
    BlzSetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, regen)
end

---@param unit unit
---@param mana number | nil
function SetUnitMaxMana(unit, mana)
    if (mana == nil) then return end
    BlzSetUnitMaxMana(unit, mana)
end

---@param unit unit
---@param mana number | nil
function SetUnitCurrentMana(unit, mana)
    if (mana == nil) then return end
    SetUnitState(unit, UNIT_STATE_MANA, mana)
end

---@param unit unit
---@param mana number | nil
function SetUnitMana(unit, mana)
    if (mana == nil) then return end
    SetUnitMaxMana(unit, mana)
    SetUnitCurrentMana(unit, mana)
end

---@param unit unit
---@param regen number | nil
function SetUnitManaRegen(unit, regen)
    if (regen == nil) then return end
    BlzSetUnitRealField(unit, UNIT_RF_MANA_REGENERATION, regen)
end

--- Sets unit damage, ignores dice
---@param unit unit
---@param damage number | nil
---@param index? integer Defaults to 0
function SetUnitDamage(unit, damage, index)
    if (damage == nil) then return end
    local index = index or 0
    BlzSetUnitBaseDamage(unit, damage - 1, index)
    BlzSetUnitDiceNumber(unit, 1, index)
    BlzSetUnitDiceSides(unit, 1, index)
end

--- Sets unit attack cooldown
---@param unit unit
---@param period number | nil
---@param index? integer
function SetUnitAttackSpeed(unit, period, index)
    if (period == nil) then return end
    local index = index or 0
    BlzSetUnitAttackCooldown(unit, period, index)
end

---@param unit unit
---@param speed number | nil
function SetUnitMoveSpeed(unit, speed)
    if (speed == nil) then return end
    SetUnitMoveSpeed(unit, speed)
end

---@param unit unit
---@param armor number | nil
function SetUnitArmor(unit, armor)
    if (armor == nil) then return end
    BlzSetUnitArmor(unit, armor)
end

---@param unit unit
---@param block number | nil
function SetUnitBlock(unit, block)
    if (block == nil) then return end
    UnitStats[unit].block = block
end

---@param unit unit
---@param magicArmor number | nil
function SetUnitMagicArmor(unit, magicArmor)
    if (magicArmor == nil) then return end
    UnitStats[unit].magicArmor = magicArmor
end

---@param unit unit
---@param magicBlock number | nil
function SetUnitMagicBlock(unit, magicBlock)
    if (magicBlock == nil) then return end
    UnitStats[unit].magicBlock = magicBlock
end

---@param unit unit
---@param evasion number | nil
function SetUnitEvasion(unit, evasion)
    if (evasion == nil) then return end
    UnitStats[unit].evasion = evasion
end

---@param unit unit
---@param evasionCrit number | nil
function SetUnitEvasionCrit(unit, evasionCrit)
    if (evasionCrit == nil) then return end
    UnitStats[unit].evasionCrit = evasionCrit
end

---@param unit unit
---@param evasionPartial number | nil
function SetUnitEvasionPartial(unit, evasionPartial)
    if (evasionPartial == nil) then return end
    UnitStats[unit].evasionPartial = evasionPartial
end

---@param unit unit
---@param critChance number | nil
function SetUnitCritChance(unit, critChance)
    if (critChance == nil) then return end
    UnitStats[unit].critChance = critChance
end

---@param unit unit
---@param critMean number | nil
function SetUnitCritMean(unit, critMean)
    if (critMean == nil) then return end
    UnitStats[unit].critMean = critMean
end

---@param unit unit
---@param critVariance number | nil
function SetUnitCritVariance(unit, critVariance)
    if (critVariance == nil) then return end
    UnitStats[unit].critVariance = critVariance
end

--- Sets unit bounty value, dice and dice value
---@param unit unit
---@param bounty integer | nil
function SetUnitBounty(unit, bounty)
    if (bounty == nil) then return end
    local value = bounty or 0
    local bountyDiceKey = UNIT_IF_GOLD_BOUNTY_AWARDED_NUMBER_OF_DICE
    local bountyValueKey = UNIT_IF_GOLD_BOUNTY_AWARDED_BASE
    local bountyDiceValueKey = UNIT_IF_GOLD_BOUNTY_AWARDED_SIDES_PER_DIE

    BlzSetUnitIntegerField(unit, bountyValueKey, value)
    BlzSetUnitIntegerField(unit, bountyDiceKey, 1)
    BlzSetUnitIntegerField(unit, bountyDiceValueKey, 1)
end
if Debug then Debug.endFile() end
