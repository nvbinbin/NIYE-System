package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("randomext")
include ("enterprise")
-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, 2)
    if tech.uid == 0700 then tech.nameId = "" end

    local radar = 0
    local hiddenRadar = 0

    radar = math.max(0, getInt(tech.rarity, tech.rarity * 2.0)) + 1
    hiddenRadar = math.max(0, getInt(tech.rarity, tech.rarity * 1.5)) + 1

    -- probability for both of them being used
    -- when rarity.value >= 4, always both
    -- when rarity.value <= 0 always only one
    local probability = math.max(0, tech.rarity * 0.25)
    if math.random() > probability then
        -- only 1 will be used
        if math.random() < 0.5 then
            radar = 0
        else
            hiddenRadar = 0
        end
    end

    if permanent then
        radar = radar * 1.5
        hiddenRadar = hiddenRadar * 2
    end

    return round(radar), round(hiddenRadar), tech
end

function onInstalled(seed, rarity, permanent)
    local radar, hiddenRadar = getBonuses(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.RadarReach, radar)
    addMultiplyableBias(StatsBonuses.HiddenSectorRadarReach, hiddenRadar)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local radar, hiddenRadar, tech = getBonuses(seed, rarity, true)

    local tiers = {}
    tiers[-1] = "F"
    tiers[0] = "E"
    tiers[1] = "D"
    tiers[2] = "C"
    tiers[3] = "B"
    tiers[4] = "A"
    tiers[5] = "S"
    if tech.uid ~= 0700 then
        tiers[5] = tech.nameId
    end

    local name
    if hiddenRadar > 0 and radar > 0 then
        name = "Deep-Scan Radar Booster"%_t
    elseif hiddenRadar > 0 then
        name = "Revealing Radar Booster"%_t
    else
        name = "Radar Booster"%_t
    end

    return "${tier}-Tier ${name} ${normal}-${deep} /* ex: B-Tier Deep-Scan Radar Booster 7-5 */"%_t % {tier = tiers[rarity.value], name = name, normal = radar, deep = hiddenRadar}
end

function getBasicName()
    return "Radar Booster"%_t
end

function getIcon(seed, rarity)
    local radar, hiddenRadar, tech = getBonuses(seed, rarity, true)
    if tech.uid == 0700 then
        return "data/textures/icons/radar-sweep.png"
    end
    return "data/textures/icons/radar-sweep.png"
end

function getEnergy(seed, rarity, permanent)
    local radar, hiddenRadar, tech = getBonuses(seed, rarity)
    return (radar * 75 * 1000 * 1000 + hiddenRadar * 150 * 1000 * 1000) * tech.energyFactor
end

function getPrice(seed, rarity)
    local radar, hiddenRadar, tech = getBonuses(seed, rarity)
    local price = radar * 3000 + hiddenRadar * 5000
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local radar, hiddenRadar, tech = getBonuses(seed, rarity, permanent)
    local baseRadar, baseHidden = getBonuses(seed, rarity, false)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Radar Range"%_t, rtext = "+???", icon = "data/textures/icons/radar-sweep.png"})
            table.insert(bonuses, {ltext = "Deep Scan Range"%_t, rtext = "+???", icon = "data/textures/icons/radar-sweep.png"})
            return texts, bonuses
        end
    end

    if radar ~= 0 then
        table.insert(texts, {ltext = "Radar Range"%_t, rtext = string.format("%+i", radar), icon = "data/textures/icons/radar-sweep.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Radar Range"%_t, rtext = string.format("%+i", round(baseRadar * 0.5)), icon = "data/textures/icons/radar-sweep.png"})
    end

    if hiddenRadar ~= 0 then
        table.insert(texts, {ltext = "Deep Scan Range"%_t, rtext = string.format("%+i", hiddenRadar), icon = "data/textures/icons/radar-sweep.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Deep Scan Range"%_t, rtext = string.format("%+i", baseHidden), icon = "data/textures/icons/radar-sweep.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local texts = {}
    local radar, hiddenRadar, tech = getBonuses(seed, rarity)

    if hiddenRadar ~= 0 then
        table.insert(texts, {ltext = "Shows sectors with mass /* continues with 'as yellow blips on the map' */"%_t})
        table.insert(texts, {ltext = "as yellow blips on the map /* continued from 'Shows sectors with mass '*/"%_t})
    end
    if tech.uid ~= 0700 then 
        texts = getLines(tech)
    end
    return texts
end

function getComparableValues(seed, rarity)
    local radar, hiddenRadar = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    if radar ~= 0 then
        table.insert(base, {name = "Radar Range"%_t, key = "radar_range", value = radar, comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Radar Range"%_t, key = "radar_range", value = round(radar * 0.5), comp = UpgradeComparison.MoreIsBetter})
    end

    if hiddenRadar ~= 0 then
        table.insert(base, {name = "Deep Scan Range"%_t, key = "deep_range", value = hiddenRadar, comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Deep Scan Range"%_t, key = "deep_range", value = hiddenRadar, comp = UpgradeComparison.MoreIsBetter})
    end

    return base, bonus
end
