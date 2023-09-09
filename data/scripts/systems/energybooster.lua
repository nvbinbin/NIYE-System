package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    -- 原神抽奖
    local tech = getEnterprise(seed, rarity, 2)
    -----  我是王者荣耀3000小时玩家  -----
    tech.boosterEnergyResult = math.random(tech.minRandom, tech.maxRandom) / 100
    tech.boosterChargeResult = math.random(tech.minRandom, tech.maxRandom) / 100
    if tech.uid == 0700 then tech.nameId = "V" end
    ------------------------------------

    local energy = 15 -- base value, in percent
    -- add flat percentage based on rarity
    energy = energy + (tech.rarity + 1) * 10 -- add 0% (worst rarity) to +60% (best rarity)

    -- add randomized percentage, span is based on rarity
    energy = energy + tech.boosterEnergyResult * ((tech.rarity + 1) * 8) -- add random value between 0% (worst rarity) and +48% (best rarity)
    energy = energy * 0.8
    energy = energy / 100

    local charge = 15 -- base value, in percent
    -- add flat percentage based on rarity
    charge = charge + (tech.rarity + 1) * 4 -- add 0% (worst rarity) to +24% (best rarity)

    -- add randomized percentage, span is based on rarity
    charge = charge + tech.boosterChargeResult * ((tech.rarity + 1) * 4) -- add random value between 0% (worst rarity) and +24% (best rarity)
    charge = charge * 0.8
    charge = charge / 100

    if permanent then
        energy = energy * 1.5
        charge = charge * 1.5
    end

    -- 异域以上必定双享
    -- when rarity.value >= 4, always both
    -- when rarity.value <= 0 always only one
    local probability = math.max(0, rarity.value * 0.25)
    if math.random() > probability then
        -- only 1 will be used
        if math.random() < 0.5 then
            energy = 0
        else
            charge = 0
        end
    end

    return energy, charge, tech
end

function onInstalled(seed, rarity, permanent)
    local energy, charge = getBonuses(seed, rarity, permanent)

    addBaseMultiplier(StatsBonuses.GeneratedEnergy, energy)
    addBaseMultiplier(StatsBonuses.BatteryRecharge, charge)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local energy, charge, tech = getBonuses(seed, rarity, permanent)

    local serial = makeSerialNumber(seed, 1, "V", "L", "0O")
    if tech.uid ~= 0700 then serial = tech.nameId end
    serial = serial .. makeSerialNumber(seed, 1, "", "-T", "T7")

    local name = "Generator Subsystem"%_t

    if energy > 0 and charge > 0 then
        name = getGrade(tech.boosterChargeResult, tech, 100) .. "Generator Booster"%_t
    elseif energy > 0 then
        name = getGrade(tech.boosterEnergyResult, tech, 100) .. "Generator Enhancer"%_t
    end

    return "${serial} ${name} R-${rarity} /* ex: V0L7-T Generator Booster R-Zeta */"%_t % {serial = serial, name = name, rarity = toGreekNumber(rarity.value+2)}
end

function getBasicName()
    return "Generator Subsystem"%_t
end

function getIcon(seed, rarity)
    local energy, charge, tech = getBonuses(seed, rarity, true)

    if tech.uid == 0700 then
        return "data/textures/icons/electric.png"
    end
    return "data/textures/icons/electric.png"
end

function getEnergy(seed, rarity, permanent)
    return 0
end

function getPrice(seed, rarity)
    local energy, charge, tech = getBonuses(seed, rarity)
    local price = energy * 100 * 400 + charge * 100 * 300
    return (price * 2.5 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local energy, charge, tech = getBonuses(seed, rarity, permanent)
    local baseEnergy, baseCharge = getBonuses(seed, rarity, false)

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Generated Energy"%_t, rtext = "+???", icon = "data/textures/icons/electric.png"})
            table.insert(bonuses, {ltext = "Recharge Rate"%_t, rtext = "+???", icon = "data/textures/icons/power-unit.png"})
            return texts, bonuses
        end
    end

    if energy ~= 0 then
        table.insert(texts, {ltext = "Generated Energy"%_t, rtext = string.format("%+i%%", round(energy * 100)), icon = "data/textures/icons/electric.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Generated Energy"%_t, rtext = string.format("%+i%%", round(baseEnergy * 0.5 * 100)), icon = "data/textures/icons/electric.png"})
    end

    if charge ~= 0 then
        table.insert(texts, {ltext = "Recharge Rate"%_t, rtext = string.format("%+i%%", round(charge * 100)), icon = "data/textures/icons/power-unit.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Recharge Rate"%_t, rtext = string.format("%+i%%", round(baseCharge * 0.5 * 100)), icon = "data/textures/icons/power-unit.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local energy, charge, tech = getBonuses(seed, rarity, permanent)
    if tech.uid == 0700 then
        return {}
    end
    local texts = getLines(tech)
    return texts
end

function getComparableValues(seed, rarity)
    local energy, charge = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    if energy ~= 0 then
        table.insert(base, {name = "Generated Energy"%_t, key = "generated_energy", value = round(energy * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Generated Energy"%_t, key = "generated_energy", value = round(energy * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    if charge ~= 0 then
        table.insert(base, {name = "Recharge Rate"%_t, key = "recharge_rate", value = round(charge * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Recharge Rate"%_t, key = "recharge_rate", value = round(charge * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    return base, bonus
end
