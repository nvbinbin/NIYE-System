
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local squads = getNumSquads(seed, rarity, permanent)
    local production = 0

    if permanent then
        production = math.max(0, lerp(random():getFloat(0, 1), 0, 1, rarity.value - 1, rarity.value)) * 1000
        production = round(production / 100) * 100
    end

    return squads, production
end

function getNumBonusSquads(seed, rarity, permanent)
    local base, bonus = getAllSquads(seed, rarity)

    if permanent then
        return bonus
    else
        return 0
    end
end

function getNumSquads(seed, rarity, permanent)
    local base, bonus = getAllSquads(seed, rarity)

    if permanent then
        return base + bonus
    else
        return base
    end
end

function getAllSquads(seed, rarity)
    math.randomseed(seed)

    local total = math.max(1, math.ceil((rarity.value + 1.5) / 2))

    local base = getInt(0, 1)
    if rarity.value == RarityType.Petty then base = 0 end

    local bonus = total - base

    return base, bonus
end

function onInstalled(seed, rarity, permanent)
    local squads, production = getBonuses(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.FighterSquads, squads)
    addMultiplyableBias(StatsBonuses.ProductionCapacity, production)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local rarityName = ""

    if rarity == Rarity(-1) then
        rarityName = "One-headed"%_t
    elseif rarity == Rarity(0) then
        rarityName = "Two-headed"%_t
    elseif rarity == Rarity(1) then
        rarityName = "Three-headed"%_t
    elseif rarity == Rarity(2) then
        rarityName = "Four-headed"%_t
    elseif rarity == Rarity(3) then
        rarityName = "Five-headed"%_t
    elseif rarity == Rarity(4) then
        rarityName = "Six-headed"%_t
    elseif rarity == Rarity(5) then
        rarityName = "Seven-headed"%_t
    end

    local rnd = Random(Seed(seed))

    local serialNumber = makeSerialNumber(rnd, 4, "FCS-")

    return "${rarityName} Hydra ${serialNumber}"%_t % {rarityName = rarityName, serialNumber = serialNumber}
end

function getBasicName()
    return "Hydra Subsystem /* generic name for '${rarityName} Hydra ${serialNumber}' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/fighter.png"
end

function getEnergy(seed, rarity, permanent)
    local squads = getNumSquads(seed, rarity, permanent)
    return squads * 600 * 1000 * 1000 / (1.1 ^ rarity.value)
end

function getPrice(seed, rarity)
    local squads = getNumSquads(seed, rarity, true)

    local price = 25000 * (squads)
    return price * 1.5 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)
    local squads, _ = getBonuses(seed, rarity, permanent)
    local _, production = getBonuses(seed, rarity, true)

    local speedup = round(production / 1000 * 60)
    local speedupStr = createReadableShortTimeString(speedup)

    local texts = {}
    local bonuses = {}

    table.insert(texts, {ltext = "Fighter Squadrons"%_t, rtext = "+" .. squads, icon = "data/textures/icons/fighter.png", boosted = permanent})

    if permanent then
        if production > 0 then
            table.insert(texts, {ltext = "Production Speedup"%_t, rtext = "+" .. speedupStr, icon = "data/textures/icons/gears.png", boosted = permanent})
        end
    end

    -- Don't show permanent bonus if there is none
    if getNumBonusSquads(seed, rarity, true) == 0 then
        return texts
    end

    table.insert(bonuses, {ltext = "Fighter Squadrons"%_t, rtext = "+" .. getNumBonusSquads(seed, rarity, true), icon = "data/textures/icons/fighter.png"})

    if production > 0 then
        table.insert(bonuses, {ltext = "Production Speedup"%_t, rtext = "+" .. speedupStr, icon = "data/textures/icons/gears.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Fighter Control System"%_t, rtext = "", icon = ""},
        {ltext = "Controls additional fighter squadrons"%_t, rtext = "", icon = ""},
        {ltext = "Max Squadrons: 10"%_t, rtext = "", icon = ""},

    }
end

function getComparableValues(seed, rarity)
    local squads = getNumSquads(seed, rarity, false)
    local bonusSquads = getNumBonusSquads(seed, rarity, true)

    return
    {
        {name = "Fighter Squadrons"%_t, key = "fighter_squads", value = squads, comp = UpgradeComparison.MoreIsBetter},
        {name = "Fighter Squadrons"%_t, key = "production_capacity", value = squads, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Fighter Squadrons"%_t, key = "fighter_squads", value = bonusSquads, comp = UpgradeComparison.MoreIsBetter},
        {name = "Fighter Squadrons"%_t, key = "production_capacity", value = bonusSquads, comp = UpgradeComparison.MoreIsBetter},
    }
end
