package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")

-- [能量电池]
FixedEnergyRequirement = true
local systemType = "batterybooster"

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    -- 原神抽奖
    local tech = getEnterprise(seed, rarity, systemType)
    -----  我是王者荣耀3000小时玩家  -----
    tech.batteryEnergyResult = math.random(tech.minRandom, tech.maxRandom) / 100
    tech.batteryChargeResult = math.random(tech.minRandom, tech.maxRandom) / 100
    if tech.uid == 0700 then tech.nameId = "W" end
    ------------------------------------

    local energy = 15 -- 基础值 电池容量
    local charge = 15 -- 基础值 充能速度

    -- 基础算法 --
    energy = energy + (tech.rarity + 1) * 15 
    energy = energy + tech.batteryEnergyResult * ((tech.rarity + 1) * 10) 
    
    charge = charge + (tech.rarity + 1) * 4 
    charge = charge + tech.batteryChargeResult * ((tech.rarity + 1) * 4)
    
    
    energy = energy * 0.8 / 100
    charge = charge * 0.8 / 100

    if permanent then
        charge = charge * 1.5
        energy = energy * 1.5
    end

    -- 每级25%额外概率 异域以上必定双享
    local probability = math.max(0, tech.rarity * 0.25) -- 4 级就是 1 了
    if math.random() > probability then
        -- 随机处死一个
        if math.random() < 0.5 then
            energy = 0
        else
            charge = 0
        end
    end
    if not permanent and tech.onlyPerm then
        charge = 0
        energy = 0
    end

    return energy, charge, tech
end

function onInstalled(seed, rarity, permanent)
    local energy, charge = getBonuses(seed, rarity, permanent)

    addBaseMultiplier(StatsBonuses.EnergyCapacity, energy)
    addBaseMultiplier(StatsBonuses.BatteryRecharge, charge)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local energy, charge, tech = getBonuses(seed, rarity, true)
    local name = ""
    local ty
    local cha = false

    if charge > 0 then -- 是否有充能速度

        if energy > 0 then -- 是否有电池容量
            -- 充能和容量都有
            if tech.batteryEnergyResult > tech.batteryChargeResult then
                ty = tech.batteryEnergyResult 
            else 
                ty = tech.batteryChargeResult 
                cha = true
            end
            name = getGrade(ty, tech, 100) .."-".. "Fast-Charge Battery Booster"%_t -- 快速充能电池强化
        else
            -- 只有充能
            ty = tech.batteryChargeResult
            cha = true
            name = getGrade(ty, tech, 100) .."-".. "Fast-Charge Battery Upgrade"%_t -- 快速充能电池升级：
        end
    else
        -- 只有容量
        ty = tech.batteryEnergyResult
        name = getGrade(ty, tech, 100) .."-".. "Battery Booster"%_t -- 电池强化
    end

    local serial = makeSerialNumber(seed, 1, tech.nameId, "", "4A")
    serial = serial .. makeSerialNumber(seed, 1, "", "", "T7")
    if cha then
        serial = serial .. makeSerialNumber(seed, 1, "", "-C", "T7")
    else
        serial = serial .. makeSerialNumber(seed, 1, "", "-E", "Y8")
    end

    return "${serial} ${name} R-${rarity} /* ex: W477-T Fast-Charge Battery Upgrade R-III */"%_t % {serial = serial, name = name, rarity = toRomanLiterals(rarity.value+2)}
end

function getBasicName()
    return "Battery Booster"%_t
end

function getIcon(seed, rarity)
    local energy, charge, tech = getBonuses(seed, rarity, true)

    return makeIcon("battery-pack-alt", tech)
end

function getEnergy(seed, rarity, permanent)
    return 0
end

function getPrice(seed, rarity)
    local energy, charge, tech = getBonuses(seed, rarity, true)
    local price = energy * 100 * 250 + charge * 100 * 150;
    return (price * 3.0 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local energy, charge, tech = getBonuses(seed, rarity, permanent)
    local baseEnergy, baseCharge = getBonuses(seed, rarity, false)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Energy Capacity", "+???", "data/textures/icons/battery-pack-alt.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Recharge Rate", "+???", "data/textures/icons/power-unit.png", permanent)
        return texts, bonuses
    end

    if energy ~= 0 then
        table.insert(texts, {ltext = "Energy Capacity"%_t, rtext = string.format("%+i%%", round(energy * 100)), icon = "data/textures/icons/battery-pack-alt.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Energy Capacity"%_t, rtext = string.format("%+i%%", round(baseEnergy * 0.5 * 100)), icon = "data/textures/icons/battery-pack-alt.png", boosted = permanent})
    end

    if charge ~= 0 then
        table.insert(texts, {ltext = "Recharge Rate"%_t, rtext = string.format("%+i%%", round(charge * 100)), icon = "data/textures/icons/power-unit.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Recharge Rate"%_t, rtext = string.format("%+i%%", round(baseCharge * 0.5 * 100)), icon = "data/textures/icons/power-unit.png", boosted = permanent})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local energy, charge, tech = getBonuses(seed, rarity, permanent)
    local texts = {}
    if tech.uid == 0700 then
        return {}
    end
    local techTexts = getLines(seed, tech)
    for i, v in pairs(techTexts) do
        table.insert(texts, v)   
    end
    return texts
end

function getComparableValues(seed, rarity)
    local energy, charge = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    if energy ~= 0 then
        table.insert(base, {name = "Energy Capacity"%_t, key = "energy_capacity", value = round(energy * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Energy Capacity"%_t, key = "energy_capacity", value = round(energy * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    if charge ~= 0 then
        table.insert(base, {name = "Recharge Rate"%_t, key = "recharge_rate", value = round(charge * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Recharge Rate"%_t, key = "recharge_rate", value = round(charge * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    return base, bonus
end
