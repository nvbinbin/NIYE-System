package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

include ("enterprise")
-- 牵引光束升级
FixedEnergyRequirement = true
local systemType = "lootrangebooster"

function getLootCollectionRange(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, systemType)
    if tech.uid == 0700 then tech.nameId = "RCN" end

    local range = (tech.rarity + 2 + getFloat(0.0, 0.75)) * 2 * (1.3 ^ tech.rarity) -- one unit is 10 meters

    if permanent then
        range = range * 3
    end

    range = round(range)

    return range, tech
end

function onInstalled(seed, rarity, permanent)
    addAbsoluteBias(StatsBonuses.LootCollectionRange, getLootCollectionRange(seed, rarity, permanent))
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local range, tech = getLootCollectionRange(seed, rarity)
    local serial = makeSerialNumber(seed, 2, nil, nil, "0123456789")
    local mark = toRomanLiterals(tech.rarity + 2)
    return "${ids}-${serial} 牵引光束升级 MK ${mark}"%_t % {mark = mark, serial = serial, ids = tech.nameId}
end

function getBasicName()
    return "Tractor Beam Upgrade /* generic name for 'RCN-${serial} Tractor Beam Upgrade MK ${mark}' */"%_t
end

function getIcon(seed, rarity)
    local range, tech = getLootCollectionRange(seed, rarity)

    return makeIcon("tractor", tech)
end

function getEnergy(seed, rarity, permanent)
    local range, tech = getLootCollectionRange(seed, rarity)
    return range * 20 * 1000 * 1000 / (1.1 ^ tech.rarity) * tech.energyFactor
end

function getPrice(seed, rarity)
    local range, tech = getLootCollectionRange(seed, rarity, true)
    return (500 * range) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local range, tech = getLootCollectionRange(seed, rarity, permanent)
    local baseRange = getLootCollectionRange(seed, rarity, false)
    local texts = {}
    local bonuses = {}
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Loot Collection Range", "+???", "data/textures/icons/tractor.png", permanent)
        return texts, bonuses
    end

    return
    {
        {ltext = "Loot Collection Range"%_t, rtext = "+${distance} km"%_t % {distance = round(range / 100, 2)}, icon = "data/textures/icons/tractor.png", boosted = permanent}
    },
    {
        {ltext = "Loot Collection Range"%_t, rtext = "+${distance} km"%_t % {distance = round(baseRange * 2 / 100, 2)}, icon = "data/textures/icons/tractor.png"}
    }
end

function getDescriptionLines(seed, rarity, permanent)
    local range, tech = getLootCollectionRange(seed, rarity, permanent)
    local texts = {}
    if tech.uid == 0700 then
        return
        {
            {ltext = "Gotta catch 'em all!"%_t, lcolor = ColorRGB(1, 0.5, 0.5)}
        }
    end
    local techTexts = getLines(seed, tech)
    for i, v in pairs(techTexts) do
        table.insert(texts, v)   
    end
    return texts
end

function getComparableValues(seed, rarity)
    local range = getLootCollectionRange(seed, rarity, false)

    local base = {}
    local bonus = {}

    table.insert(base, {name = "Loot Collection Range"%_t, key = "range", value = round(range / 100, 2), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Loot Collection Range"%_t, key = "range", value = round(range * 0.5 / 100, 2), comp = UpgradeComparison.MoreIsBetter})

    return base, bonus
end
