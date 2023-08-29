package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
local SpawnUtility = include ("spawnutility")
include ("damagetypeutility")
include ("randomext")


-- static stats
local resistanceBonus = {}
resistanceBonus[1] = {dmgFactor = 0.04} -- Petty
resistanceBonus[2] = {dmgFactor = 0.07} -- Common
resistanceBonus[3] = {dmgFactor = 0.1}  -- Uncommon
resistanceBonus[4] = {dmgFactor = 0.15} -- Rare
resistanceBonus[5] = {dmgFactor = 0.2}  -- Exceptional
resistanceBonus[6] = {dmgFactor = 0.25} -- Exotic
resistanceBonus[7] = {dmgFactor = 0.3}  -- Legendary
resistanceBonus[8] = {dmgFactor = 0.35} -- helper

local resistanceTypes =
{
    DamageType.Physical,
    DamageType.Plasma,
    DamageType.Electric,
    DamageType.AntiMatter
}

-- dynamic stats
local resistanceType = nil
local hpBonus = nil
local dmgFactor = nil

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local rarityLevel = rarity.value + 2 -- rarity levels start at -1

    local randomEntry = math.random(1, 4)
    resistanceType = resistanceTypes[randomEntry]
    dmgFactor = 0

    if permanent then
        dmgFactor = resistanceBonus[rarityLevel].dmgFactor
        nextLevel = resistanceBonus[rarityLevel+1].dmgFactor
        dmgFactor = dmgFactor + math.random() * (nextLevel - dmgFactor - 0.01)
    end

    return resistanceType, dmgFactor
end

function onInstalled(seed, rarity, permanent)
    local resistanceType, dmgFactor = getBonuses(seed, rarity, permanent)

    local entity = Entity()
    if not entity then return end

    -- the upgrades are unique, so we can just reset the resistance
    SpawnUtility.resetResistance(entity)

    if permanent then
        SpawnUtility.addResistance(entity, resistanceType, dmgFactor)
    end
end

function onUninstalled(seed, rarity, permanent)

    local entity = Entity()
    if not entity then return end

    SpawnUtility.resetResistance(entity)
end

function getName(seed, rarity)

    local name = "Shield Ionizer"%_t
    if resistanceType == DamageType.Physical then
        name = "Hardening Shield Ionizer"%_t
    elseif resistanceType == DamageType.Plasma then
        name = "Plasmatic Shield Ionizer"%_t
    elseif resistanceType == DamageType.Electric then
        name = "Grounding Shield Ionizer"%_t
    elseif resistanceType == DamageType.AntiMatter then
        name = "Solidifying Shield Ionizer"%_t
    end

    local mark = toRomanLiterals(rarity.value + 2)
    return "${name} MK ${mark} /* ex: Plasmatic Shield Ionizer MK III */"%_t % {name = name, mark = mark}
end

function getBasicName()
    return "Shield Ionizer"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/edged-shield.png"
end

function getEnergy(seed, rarity, permanent)
    local resistanceType, dmgFactor = getBonuses(seed, rarity, true)
    return (dmgFactor * 75 + dmgFactor * 2) * 1000 * 537
end

function getPrice(seed, rarity)
    local resistanceType, dmgFactor = getBonuses(seed, rarity, true)
    local price = dmgFactor * 100 * 500 + dmgFactor * 100 * 257
    return price * 2.5 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local resistanceType, dmgFactor = getBonuses(seed, rarity, true)

    if permanent then
        table.insert(texts, {ltext = "Resistance against"%_t, rtext = string.format("%s", getDamageTypeName(resistanceType)), rcolor = getDamageTypeColor(resistanceType), icon = "data/textures/icons/shield-charge.png"})
        table.insert(texts, {ltext = string.format("%s damage"%_t, getDamageTypeName(resistanceType)), rtext = string.format("-%i%%", round(dmgFactor * 100)), icon = "data/textures/icons/shield-charge.png", boosted = permanent})
    end

    table.insert(bonuses, {ltext = "Resistance against"%_t, rtext = string.format("%s", getDamageTypeName(resistanceType)), rcolor = getDamageTypeColor(resistanceType), icon = "data/textures/icons/shield-charge.png"})
    table.insert(bonuses, {ltext = string.format("%s damage"%_t, getDamageTypeName(resistanceType)), rtext = string.format("-%i%%", round(dmgFactor * 100)), icon = "data/textures/icons/shield-charge.png", boosted = permanent})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local resistanceType, dmgFactor = getBonuses(seed, rarity, true)

    local texts = {}
    table.insert(texts, {ltext = "Ionizes the shield against incoming damage."%_t})
    table.insert(texts, {ltext = "Reduces damage received from"%_t})
    table.insert(texts, {ltext = string.format("%s weapons."%_t, getDamageTypeName(resistanceType))})
    return texts
end

function getComparableValues(seed, rarity)
    local base = {}
    local bonus = {}

    local resistanceType, dmgFactor = getBonuses(seed, rarity, true)

    table.insert(bonus, {name = string.format("%s damage"%_t, getDamageTypeName(resistanceType)), key = "dmg_factor", value = dmgFactor, comp = UpgradeComparison.MoreIsBetter})
    table.insert(base, {name = "Resistance against"%_T, key = "resistance_type", value = resistanceType})

    return base, bonus
end
