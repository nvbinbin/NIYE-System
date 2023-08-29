package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
PermanentInstallationOnly = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    -- rarity -1 is -1 / 2 + 1 * 50 = 0.5 * 100 = 50
    -- rarity 5 is 5 / 2 + 1 * 50 = 3.5 * 100 = 350
    local range = (rarity.value / 2 + 1 + round(getFloat(0.0, 0.4), 1)) * 100

    local fighterCargoPickup = 0
    if rarity.value >= RarityType.Rare then
        fighterCargoPickup = 1
    end

    return range, fighterCargoPickup
end

function onInstalled(seed, rarity, permanent)
    if not permanent then return end

    local range, fighterCargoPickup = getBonuses(seed, rarity, permanent)
    addAbsoluteBias(StatsBonuses.TransporterRange, range)
    addAbsoluteBias(StatsBonuses.FighterCargoPickup, fighterCargoPickup)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local serial = makeSerialNumber(seed, 2)
    local v = rarity.value + 1
    local s2 = makeSerialNumber(seed, 1, nil, nil, "12345")
    return "T-${serial} Transporter Software v${v}.${s2}0 /* ex: T-3F Transporter Software v2.50 */"%_t % {serial = serial, v = v, s2 = s2}
end

function getBasicName()
    return "Transporter Software /* generic name for 'T-${serial} Transporter Software v${v}.${s2}0' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/processor.png"
end

function getEnergy(seed, rarity, permanent)
    return 0
end

function getPrice(seed, rarity)
    local range, fighterCargoPickup = getBonuses(seed, rarity, true)
    return range * 250
end

function getTooltipLines(seed, rarity, permanent)
    local range, fighterCargoPickup = getBonuses(seed, rarity, permanent)

    local texts =
    {
        {ltext = "Docking Distance"%_t, rtext = "+${distance} km"%_t % {distance = range / 100}, icon = "data/textures/icons/solar-system.png", boosted = permanent}
    }

    if fighterCargoPickup > 0 then
        table.insert(texts, {ltext = "Fighter Cargo Pickup"%_t, icon = "data/textures/icons/fighter.png", boosted = permanent})
    end

    if not permanent then
        return {}, texts
    else
        return texts, texts
    end
end

function getDescriptionLines(seed, rarity, permanent)
    local range, fighterCargoPickup = getBonuses(seed, rarity, permanent)

    local texts =
    {
        {ltext = "Software for Transporter Blocks"%_t, rtext = "", icon = ""},
        {ltext = "Transporter Block on your ship is required to work"%_t, rtext = "", icon = ""},
    }

    if fighterCargoPickup > 0 then
        table.insert(texts, {ltext = "Allows fighters to pick up cargo"%_t, rtext = "", icon = ""})
    end

    return texts
end

function getComparableValues(seed, rarity)
    local range, fighterCargoPickup = getBonuses(seed, rarity, permanent)

    local base = {}
    local bonus = {}
    table.insert(bonus, {name = "Docking Distance"%_t, key = "docking_distance", value = range / 100, comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Fighter Cargo Pickup"%_t, key = "fighter_cargo_pickup", value = fighterCargoPickup, comp = UpgradeComparison.MoreIsBetter})

    return base, bonus
end
