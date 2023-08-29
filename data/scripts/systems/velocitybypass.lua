package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local energy = (6.0 - (rarity.value + 1)) * 8  -- base value 60 for worst, 0 for best rarity
    energy = energy + getInt(0, 10) -- add a random number of 10
    energy = energy / 100

    return energy
end


function onInstalled(seed, rarity, permanent)
    if not permanent then return end

    local energy = getBonuses(seed, rarity, permanent)

    addAbsoluteBias(StatsBonuses.Velocity, 10000000.0)
    addBaseMultiplier(StatsBonuses.GeneratedEnergy, -energy)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local serial = makeSerialNumber(seed, 3)

    if rarity.value >= RarityType.Exceptional then serial = "WEEE" end
    return "Velocity Security Control Bypass BP-${serial}"%_t % {serial = serial}
end

function getBasicName()
    return "Velocity Security Control Bypass /* generic name for 'Velocity Security Control Bypass BP-${serial}' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/bypass.png"
end

function getPrice(seed, rarity)
    return 15000 * (2.5 ^ rarity.value)
end

function getTooltipLines(seed, rarity, permanent)
    local energy = getBonuses(seed, rarity)

    local texts = {}
    table.insert(texts, {ltext = "Velocity"%_t, rtext = "+?", icon = "data/textures/icons/speedometer.png", boosted = permanent})
    table.insert(texts, {ltext = "Generated Energy"%_t, rtext = string.format("%+i%%", round(-energy * 100)), icon = "data/textures/icons/power-lightning.png", boosted = permanent})
    table.insert(texts, {})
    table.insert(texts, {ltext = "Bypasses the velocity security control, /* continues with 'but leaks energy from the generators.' */"%_t})
    table.insert(texts, {ltext = "but leaks energy from the generators. /* continued from 'Bypasses the velocity security control,' */"%_t})

    if permanent then
        return texts, texts
    else
        return {}, texts
    end
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Weeeeeee!"%_t, lcolor = ColorRGB(1, 0.5, 0.5)}
    }
end


function getComparableValues(seed, rarity)
    local energy = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    table.insert(bonus, {name = "Generated Energy"%_t, key = "generated_energy", value = round(-energy * 100), comp = UpgradeComparison.MoreIsBetter})

    table.insert(bonus, {name = "Velocity"%_t, key = "velocity", value = 1, comp = UpgradeComparison.MoreIsBetter})

    return base, bonus
end
