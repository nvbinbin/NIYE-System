package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- 护盾加固发生器
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "SR" end

    local durability = 0.25
    durability = durability + (tech.rarity * 0.03) + (0.03 * math.random())

    local rechargeTimeFactor = 4.0
    rechargeTimeFactor = rechargeTimeFactor - (tech.rarity * 0.2) - (0.2 * math.random())


    return durability, rechargeTimeFactor, tech
end

function onInstalled(seed, rarity, permanent)
    local durability, rechargeTimeFactor = getBonuses(seed, rarity, permanent)

    if permanent then
        addAbsoluteBias(StatsBonuses.ShieldImpenetrable, 1)
        addMultiplier(StatsBonuses.ShieldDurability, durability)
        addBaseMultiplier(StatsBonuses.ShieldTimeUntilRechargeAfterHit, rechargeTimeFactor)
    end
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local durability, rechargeTimeFactor, tech = getBonuses(seed, rarity)
    local random = Random(Seed(seed))
    local serial = makeSerialNumber(random, 2)
    local gen = toGreekNumber(tech.rarity + 2)
    local name = randomEntry(random, {"Shield Reinforcer"%_t, "Shield Impenetrator"%_t})

    return "${ids}-${serial} ${name} Gen. ${gen} /* SR-FL Shield Impenetrator Gen. Delta */"%_t % {ids = tech.nameId, serial = serial, gen = gen, name = name}
end

function getBasicName()
    return "Shield Reinforcer"%_t
end

function getIcon(seed, rarity)
    local durability, rechargeTimeFactor, tech = getBonuses(seed, rarity, permanent)

    return makeIcon("bordered-shield", tech)
end

function getEnergy(seed, rarity, permanent)
    local durability, rechargeTimeFactor, tech = getBonuses(seed, rarity)
    return (durability * 1.75 * 1000 * 1000 * 1000) * tech.energyFactor
end

function getPrice(seed, rarity)
    local durability, rechargeTimeFactor, tech = getBonuses(seed, rarity, true)
    local price = durability * 1000 * 100
    return (price * 2.5 ^ tech.rar) * tech.money
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local durability, rechargeTimeFactor, tech = getBonuses(seed, rarity)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            texts, bonuses = churchTip(texts, bonuses,"Impenetrable Shields", "Yes", "data/textures/icons/shield.png", permanent)
            texts, bonuses = churchTip(texts, bonuses,"Shield Durability", "+???", "data/textures/icons/health-normal.png", permanent)
            texts, bonuses = churchTip(texts, bonuses,"Time Until Recharge", "+???", "data/textures/icons/recharge-time.png", permanent)
            return texts, bonuses
        end
    end

    table.insert(bonuses, {ltext = "Impenetrable Shields"%_t, rtext = "Yes"%_t, icon = "data/textures/icons/shield.png", boosted = permanent})

    if durability ~= 0 then
        table.insert(bonuses, {ltext = "Shield Durability"%_t, rtext = string.format("%+i%%", round(-(1.0 - durability) * 100)), icon = "data/textures/icons/health-normal.png", boosted = permanent})
    end
    if rechargeTimeFactor ~= 0 then
        table.insert(bonuses, {ltext = "Time Until Recharge"%_t, rtext = string.format("%+i%%", round(rechargeTimeFactor * 100)), icon = "data/textures/icons/recharge-time.png", boosted = permanent})
    end

    return texts, bonuses

end

function getDescriptionLines(seed, rarity, permanent)
    local durability, rechargeTimeFactor, tech = getBonuses(seed, rarity)
    local texts = {}
    table.insert(texts, {ltext = "Permanent Installation:"%_t})
    table.insert(texts, {ltext = "Shields can't be penetrated by shots or torpedoes."%_t})
    table.insert(texts, {ltext = "Durability is diverted to reinforce shield membrane."%_t})
    table.insert(texts, {ltext = "Time until recharge after a hit is increased."%_t})
    if tech.uid ~= 0700 then 
        texts = getLines(seed, tech)
    end
    return texts
end

function getComparableValues(seed, rarity)
    local base = {}
    local bonus = {}

    local durability, rechargeTimeFactor = getBonuses(seed, rarity)

    table.insert(bonus, {name = "Impenetrable Shields"%_t, key = "impenetrable", value = 1, comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Shield Durability"%_t, key = "durability", value = round(-(1.0 - durability) * 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Time Until Recharge"%_t, key = "recharge_time", value = round(rechargeTimeFactor * 100), comp = UpgradeComparison.LessIsBetter})

    return base, bonus
end
