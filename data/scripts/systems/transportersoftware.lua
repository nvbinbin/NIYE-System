package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
PermanentInstallationOnly = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "" end

    -- rarity -1 is -1 / 2 + 1 * 50 = 0.5 * 100 = 50
    -- rarity 5 is 5 / 2 + 1 * 50 = 3.5 * 100 = 350
    local range = (tech.rarity / 2 + 1 + round(getFloat(0.0, 0.4), 1)) * 100

    local fighterCargoPickup = 0
    if tech.rarity >= RarityType.Rare then
        fighterCargoPickup = 1
    end

    return range, fighterCargoPickup, tech
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
    local range, fighterCargoPickup, tech = getBonuses(seed, rarity, permanent)
    local serial = makeSerialNumber(seed, 2)
    local v = tech.rarity + 1
    local s2 = makeSerialNumber(seed, 1, nil, nil, "12345")
    if tech.uid ~= 0700 then
        serial = tech.nameId
    end
    return "T-${serial} Transporter Software v${v}.${s2}0 /* ex: T-3F Transporter Software v2.50 */"%_t % {serial = serial, v = v, s2 = s2}
end

function getBasicName()
    return "Transporter Software /* generic name for 'T-${serial} Transporter Software v${v}.${s2}0' */"%_t
end

function getIcon(seed, rarity)
    local range, fighterCargoPickup, tech = getBonuses(seed, rarity, permanent)

    return makeIcon("processor", tech)
end

function getEnergy(seed, rarity, permanent)
    return 0
end

function getPrice(seed, rarity)
    local range, fighterCargoPickup, tech = getBonuses(seed, rarity, true)
    return (range * 250) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local range, fighterCargoPickup, tech = getBonuses(seed, rarity, permanent)
    local texts = {}
    local bonuses = {}
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            texts, bonuses = churchTip(texts, bonuses,"Docking Distance", "+??? km", "data/textures/icons/solar-system.png", permanent)
            texts, bonuses = churchTip(texts, bonuses,"Fighter Cargo Pickup", "", "data/textures/icons/fighter.png", permanent)
            return texts, bonuses
        end
    end
    
    if permanent then
        table.insert(texts, {ltext = "Docking Distance"%_t, rtext = "+${distance} km"%_t % {distance = range / 100}, icon = "data/textures/icons/solar-system.png", boosted = permanent}) 
        if fighterCargoPickup > 0 then
            table.insert(texts, {ltext = "Fighter Cargo Pickup"%_t, icon = "data/textures/icons/fighter.png", boosted = permanent})
        end
    else
        table.insert(bonuses, {ltext = "Docking Distance"%_t, rtext = "+${distance} km"%_t % {distance = range / 100}, icon = "data/textures/icons/solar-system.png", boosted = permanent}) 
        if fighterCargoPickup > 0 then
            table.insert(bonuses, {ltext = "Fighter Cargo Pickup"%_t, icon = "data/textures/icons/fighter.png", boosted = permanent})
        end
    end

    return texts, bonuses

end

function getDescriptionLines(seed, rarity, permanent)
    local range, fighterCargoPickup, tech = getBonuses(seed, rarity, permanent)

    local texts =
    {
        {ltext = "Software for Transporter Blocks"%_t, rtext = "", icon = ""},
        {ltext = "Transporter Block on your ship is required to work"%_t, rtext = "", icon = ""},
    }

    if fighterCargoPickup > 0 then
        table.insert(texts, {ltext = "Allows fighters to pick up cargo"%_t, rtext = "", icon = ""})
    end
    if tech.uid ~= 0700 then 
        texts = getLines(seed, tech)
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
