package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("randomext")
include ("utility")
include ("enterprise")
-- tanceqi
-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, 2)
    if tech.uid == 0700 then tech.nameId = "" end
    local scanner = 1

    scanner = 5 -- base value, in percent
    -- add flat percentage based on rarity
    scanner = scanner + (tech.rarity + 2) * 15 -- add +15% (worst rarity) to +105% (best rarity)

    -- add randomized percentage, span is based on rarity
    scanner = scanner + math.random() * ((tech.rarity + 1) * 15) -- add random value between +0% (worst rarity) and +90% (best rarity)
    scanner = scanner / 100

    if permanent then
        scanner = scanner * 2
    end

    return scanner, tech
end

function onInstalled(seed, rarity, permanent)
    local scanner = getBonuses(seed, rarity, permanent)

    addBaseMultiplier(StatsBonuses.ScannerReach, scanner)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local scanner, tech = getBonuses(seed, rarity, true)

    local rarityStr = tostring(tech.rarity + 2)
    local serial = tostring(round(scanner * 100))

    return "T-${rarity}-${serial} Scanner Booster /* ex: T-5-12D Scanner Booster */"%_t % {rarity = rarityStr, serial = serial}
end

function getBasicName()
    return "Scanner Booster /* generic name for 'T-${rarity}-${serial} Scanner Booster' */"%_t
end

function getIcon(seed, rarity)
    local scanner, tech = getBonuses(seed, rarity, true)
    if tech.uid == 0700 then
        return "data/textures/icons/signal-range.png"
    end
    return "data/textures/icons/signal-range.png"
end

function getEnergy(seed, rarity, permanent)
    local scanner, tech = getBonuses(seed, rarity, true)
    local scanner = getBonuses(seed, rarity)
    return (scanner * 550 * 1000 * 1000) * tech.energyFactor
end

function getPrice(seed, rarity)
    local scanner, tech = getBonuses(seed, rarity, true)
    local scanner = getBonuses(seed, rarity)
    local price = scanner * 100 * 250
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local scanner, tech = getBonuses(seed, rarity, permanent)
    local baseScanner = getBonuses(seed, rarity, false)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Scanner Range"%_t, rtext = "+???", icon = "data/textures/icons/signal-range.png"})
            return texts, bonuses
        end
    end

    if scanner ~= 0 then
        table.insert(texts, {ltext = "Scanner Range"%_t, rtext = string.format("%+i%%", round(scanner * 100)), icon = "data/textures/icons/signal-range.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Scanner Range"%_t, rtext = string.format("%+i%%", round(baseScanner * 100)), icon = "data/textures/icons/signal-range.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local scanner, tech = getBonuses(seed, rarity, permanent)
    if tech.uid == 0700 then 
        return
        {
            {ltext = "Increases the distance from which you can /* continues with 'see cargo, exact HP, etc. of other ships'*/"%_t, rtext = "", icon = ""},
            {ltext = "see cargo, exact HP, etc. of other ships /* continued from 'Increases the distance from which you can'*/"%_t, rtext = "", icon = ""}
        }
    end
    local texts = getLines(tech)
    return texts
end

function getComparableValues(seed, rarity)
    local scanner = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    table.insert(base, {name = "Scanner Range"%_t, key = "range", value = round(scanner * 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Scanner Range"%_t, key = "range", value = round(scanner * 100), comp = UpgradeComparison.MoreIsBetter})

    return base, bonus
end
