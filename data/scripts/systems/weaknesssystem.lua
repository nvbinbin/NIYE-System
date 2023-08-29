package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
local SpawnUtility = include ("spawnutility")
include ("randomext")
include ("damagetypeutility")


-- static stats
local weaknessBonus = {}
weaknessBonus[1] = {hpBonus = 0.1, dmgFactor = 3}       -- Petty
weaknessBonus[2] = {hpBonus = 0.2, dmgFactor = 3}       -- Common
weaknessBonus[3] = {hpBonus = 0.3, dmgFactor = 3}       -- Uncommon
weaknessBonus[4] = {hpBonus = 0.3, dmgFactor = 2.75}    -- Rare
weaknessBonus[5] = {hpBonus = 0.3, dmgFactor = 2.5}     -- Exceptional
weaknessBonus[6] = {hpBonus = 0.3, dmgFactor = 2.25}    -- Exotic
weaknessBonus[7] = {hpBonus = 0.3, dmgFactor = 2}       -- Legendary
weaknessBonus[8] = {hpBonus = 0.3, dmgFactor = 1.75}    -- helper

local weaknessTypes =
{
    DamageType.Energy,
    DamageType.Plasma,
    DamageType.Electric,
    DamageType.AntiMatter
}

-- dynamic stats
local weaknessType = nil
local hpBonus = nil
local dmgFactor = nil

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local rarityLevel = rarity.value + 2 -- rarity levels start at -1

    local randomEntry = math.random(1, 4)
    weaknessType = weaknessTypes[randomEntry]
    hpBonus = 0
    dmgFactor = 0

    if permanent then
        hpBonus = weaknessBonus[rarityLevel].hpBonus  
        nextLevelHp = weaknessBonus[rarityLevel+1].hpBonus
        hpBonus = round(hpBonus + math.random() * (nextLevelHp - hpBonus), 2)

        dmgFactor = weaknessBonus[rarityLevel].dmgFactor
        nextLevelDmg = weaknessBonus[rarityLevel+1].dmgFactor
        dmgFactor = round(dmgFactor + math.random() * (nextLevelDmg - dmgFactor), 2)
    end

    return weaknessType, hpBonus, dmgFactor
end

function onInstalled(seed, rarity, permanent)
    if onClient() then return end

    local entity = Entity()
    if not entity then return end

    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, permanent)

    -- the upgrades are unique, so we can just reset the weakness
    local durability = Durability()
    if not durability then return end
    durability:resetWeakness()
    durability.maxDurabilityFactor = 1

    if permanent then
        SpawnUtility.addWeakness(entity, weaknessType, dmgFactor, hpBonus)
    end
end

function onUninstalled(seed, rarity, permanent)
    if onClient() then return end

    local entity = Entity()
    if not entity then return end

    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, permanent)

    local durability = Durability()
    if not durability then return end

    durability:resetWeakness()
    durability.maxDurabilityFactor = 1
end

function getName(seed, rarity)
    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, true)
    local designation = getDamageTypeName(weaknessType)

    return "W-${designation}-Hull Polarizer ${rarity}"%_t % {designation = designation, rarity = tostring((rarity.value + 2) * 1000 + seed % 750)}
end

function getBasicName()
    return "Hull Polarizer /* generic name for 'W-${designation}-Hull Polarizer ${rarity}' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/metal-scales-plus.png"
end

function getEnergy(seed, rarity, permanent)
    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, true)
    return ((hpBonus + 1) * 75 + dmgFactor * 2) * 1000 * 537
end

function getPrice(seed, rarity)
    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, true)
    local price = dmgFactor * 100 * 50 + (hpBonus + 1) * 100 * 25
    return price * 1.8 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, true)

    if permanent then
        table.insert(texts, {ltext = "Hull Durability"%_t, rtext = string.format("%+i%%", round((hpBonus) * 100)), icon = "data/textures/icons/health-normal.png", boosted = permanent})
        table.insert(texts, {ltext = ""})
        table.insert(texts, {ltext = "Weakness against"%_t, rtext = string.format("%s", getDamageTypeName(weaknessType)), rcolor = getDamageTypeColor(weaknessType), icon = "data/textures/icons/metal-scale.png"})
        table.insert(texts, {ltext = string.format("%s damage received"%_t, getDamageTypeName(weaknessType)), rtext = string.format("+%i%%", round(dmgFactor * 100)), rcolor = getDamageTypeColor(weaknessType), icon = "data/textures/icons/metal-scale.png", rcolor = ColorRGB(1, 0, 0)})
    end

    table.insert(bonuses, {ltext = "Hull Durability"%_t, rtext = string.format("%+i%%", round((hpBonus) * 100)), icon = "data/textures/icons/health-normal.png", boosted = permanent})
    table.insert(bonuses, {ltext = ""})
    table.insert(bonuses, {ltext = "Weakness against"%_t, rtext = string.format("%s", getDamageTypeName(weaknessType)), rcolor = getDamageTypeColor(weaknessType), icon = "data/textures/icons/metal-scale.png"})
    table.insert(bonuses, {ltext = string.format("%s damage received"%_t, getDamageTypeName(weaknessType)), rtext = string.format("+%i%%", round(dmgFactor * 100)), icon = "data/textures/icons/metal-scale.png", rcolor = ColorRGB(1, 0, 0)})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, true)

    local texts = {}

    table.insert(texts, {ltext = "Polarizes hull to greatly increase durability."%_t})
    table.insert(texts, {ltext = "A side effect causes the hull to take"%_t})
    table.insert(texts, {ltext = string.format("more damage from %s weapons."%_t, getDamageTypeName(weaknessType))})

    return texts
end

function getComparableValues(seed, rarity)
    local base = {}
    local bonus = {}

    local weaknessType, hpBonus, dmgFactor = getBonuses(seed, rarity, true)

    table.insert(bonus, {name = "Hull Durability"%_t, key = "hp_bonus", value = round((hpBonus) * 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = string.format("%s damage received"%_t, getDamageTypeName(weaknessType)), key = "dmg_factor", value = dmgFactor, comp = UpgradeComparison.LessIsBetter})
    table.insert(base, {name = "Weakness against"%_T, key = "weakness_type", value = weaknessType})

    return base, bonus
end
