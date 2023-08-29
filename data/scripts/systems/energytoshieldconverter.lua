
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local baseAmplification = 20
    -- add flat percentage based on rarity
    local baseAmplification = baseAmplification + (rarity.value + 1) * 15 -- add 0% (worst rarity) to +120% (best rarity)

    -- add randomized percentage, span is based on rarity
    local amplification = baseAmplification + math.random() * (rarity.value + 1) * 10 -- add random value between 0% (worst rarity) and +60% (best rarity)

    baseAmplification = baseAmplification / 100
    amplification = amplification / 100

    energy = -baseAmplification * 0.45 / (1.05 ^ rarity.value) -- note the minus

    -- is balanced around permanent installation
    -- permanent installation reverses this factor
    amplification = amplification * 0.4
    if permanent then
        amplification = amplification * 3.5
    end

    return amplification, energy
end

function getEnergyChange(seed, rarity)
end

function onInstalled(seed, rarity, permanent)
    local amplification, energy = getBonuses(seed, rarity, permanent)

    addMultiplier(StatsBonuses.ShieldDurability, 1 + amplification)
    addBaseMultiplier(StatsBonuses.GeneratedEnergy, energy)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local mark = toRomanLiterals(rarity.value + 2)

    return "MK ${mark} Energy-To-Shield Converter"%_t % {mark = mark}
end

function getBasicName()
    return "Energy-To-Shield Converter /* generic name for 'MK ${mark} Energy-To-Shield Converter' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/shield.png"
end

function getPrice(seed, rarity)
    local amplification = getBonuses(seed, rarity)
    local price = 150 * 1000 * amplification;
    return price * 2.0 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)
    local texts = {}
    local bonuses = {}
    local amplification, energy = getBonuses(seed, rarity, permanent)
    local baseAmplification, baseEnergy = getBonuses(seed, rarity, false)

    table.insert(texts, {ltext = "Shield Durability"%_t, rtext = string.format("%+i%%", round(amplification * 100)), icon = "data/textures/icons/health-normal.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Shield Durability"%_t, rtext = string.format("%+i%%", round(baseAmplification * 3.5 * 100 - amplification * 100)), icon = "data/textures/icons/health-normal.png"})

    table.insert(texts, {ltext = "Generated Energy"%_t, rtext = string.format("%i%%", round(energy * 100)), icon = "data/textures/icons/electric.png"})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Re-routes energy to shields"%_t, rtext = "", icon = ""}
    }
end

function getComparableValues(seed, rarity)
    local baseAmplification, baseEnergy = getBonuses(seed, rarity, false)

    return
    {
        {name = "Shield Durability"%_t, key = "durability", value = round(baseAmplification * 100), comp = UpgradeComparison.MoreIsBetter},
        {name = "Generated Energy"%_t, key = "energy", value = round(baseEnergy * 100), comp = UpgradeComparison.LessIsBetter},
    },
    {
        {name = "Shield Durability"%_t, key = "durability", value = round(baseAmplification * 3.5 * 100), comp = UpgradeComparison.MoreIsBetter},
    }
end
