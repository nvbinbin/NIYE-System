package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local durability = 0.25
    durability = durability + (rarity.value * 0.03) + (0.03 * math.random())

    local rechargeTimeFactor = 4.0
    rechargeTimeFactor = rechargeTimeFactor - (rarity.value * 0.2) - (0.2 * math.random())

    return durability, rechargeTimeFactor
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
    local random = Random(Seed(seed))
    local serial = makeSerialNumber(random, 2)
    local gen = toGreekNumber(rarity.value + 2)
    local name = randomEntry(random, {"Shield Reinforcer"%_t, "Shield Impenetrator"%_t})

    return "SR-${serial} ${name} Gen. ${gen} /* SR-FL Shield Impenetrator Gen. Delta */"%_t % {serial = serial, gen = gen, name = name}
end

function getBasicName()
    return "Shield Reinforcer"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/bordered-shield.png"
end

function getEnergy(seed, rarity, permanent)
    local durability, rechargeTimeFactor = getBonuses(seed, rarity)
    return durability * 1.75 * 1000 * 1000 * 1000
end

function getPrice(seed, rarity)
    local durability, rechargeTimeFactor = getBonuses(seed, rarity)
    local price = durability * 1000 * 100
    return price * 2.5 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local durability, rechargeTimeFactor = getBonuses(seed, rarity)

    table.insert(texts, {ltext = "Impenetrable Shields"%_t, rtext = "Yes"%_t, icon = "data/textures/icons/shield.png", boosted = permanent})

    if durability ~= 0 then
        table.insert(texts, {ltext = "Shield Durability"%_t, rtext = string.format("%+i%%", round(-(1.0 - durability) * 100)), icon = "data/textures/icons/health-normal.png", boosted = permanent})
    end
    if rechargeTimeFactor ~= 0 then
        table.insert(texts, {ltext = "Time Until Recharge"%_t, rtext = string.format("%+i%%", round(rechargeTimeFactor * 100)), icon = "data/textures/icons/recharge-time.png", boosted = permanent})
    end

    if permanent then
        return texts, texts
    else
        return {}, texts
    end
end

function getDescriptionLines(seed, rarity, permanent)
    local texts = {}
    table.insert(texts, {ltext = "Permanent Installation:"%_t})
    table.insert(texts, {ltext = "Shields can't be penetrated by shots or torpedoes."%_t})
    table.insert(texts, {ltext = "Durability is diverted to reinforce shield membrane."%_t})
    table.insert(texts, {ltext = "Time until recharge after a hit is increased."%_t})

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
