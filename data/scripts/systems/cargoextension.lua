package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")

-- 优化：让能量需求不需要每帧读取
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    -- 原神抽奖
    local tech = getEnterprise(seed, rarity, 2)
    -----  我是王者荣耀3000小时玩家  -----
    tech.cargoPercResult = math.random(tech.minRandom, tech.maxRandom) / 100
    tech.cargoFlatResult = math.random(tech.minRandom, tech.maxRandom) / 100
    tech.cargoPerc = false
    if tech.uid == 0700 then tech.nameId = "T1M" end
    ------------------------------------
   

    local perc = 10 -- 基础百分比
    local flat = 20 -- 基础固定值

    ---基础算法---
    perc = perc + tech.rarity * 4
    perc = perc + tech.cargoPercResult * 4

    flat = flat + (tech.rarity + 1) * 50
    flat = flat + tech.cargoFlatResult * ((tech.rarity + 1) * 50)



    -- 考虑到厂牌的多样性，部分厂牌可能不屑于给临时安装属性
    if not permanent and tech.onlyPerm then
        perc = 0
        flat = 0
    end
    if permanent then 
        perc = perc * 1.5
        flat = flat * 1.5
    end

    -- 异域级别以上的卡拥有 5% 的概率成为调度系统 / 厂牌的卡片必定为调度系统
    local unite
    local multiFlat = 0.8
    local multiPerc = 0.8
    if (math.random() < 0.05 and rarity.value > 3) or tech.uid ~= 0700 then 
        unite = true 
    end 

    if math.random() < 0.5 then
        if not unite then flat = 0 tech.cargoPerc = true
        else tech.cargoPerc = true multiFlat = 0.4 end -- 1：保留百分数
         
    else 
        if not unite then perc = 0 
        else multiPerc = 0.4 end -- 2：保留绝对数
        
    end

    ---数据整合 / 平衡补正 ---
    perc = (perc * multiPerc) / 100
    flat = round(flat * multiFlat)

    return perc, flat, tech
end

function onInstalled(seed, rarity, permanent)
    local perc, flat, tech = getBonuses(seed, rarity, permanent)

    addBaseMultiplier(StatsBonuses.CargoHold, perc)
    addAbsoluteBias(StatsBonuses.CargoHold, flat)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local perc, flat, tech = getBonuses(seed, rarity, true)
    local name = "科技货舱拓展"
    if perc ~= 0 and flat ~= 0 then name =  "货舱调度系统" end
    local dist

    if tech.cargoPerc then name = name .. "SC" dist = tech.cargoPercResult 
    else name = name .. "TC" dist = tech.cargoFlatResult end

    local grade = getGrade(dist, tech, 100)

    
    return "${id}-${grade}-${name} MK ${mark} "%_t % {id = tech.nameId, name = name, grade = grade, mark = toRomanLiterals(tech.rarity + 2)}
end

function getBasicName()
    return "Cargo Extension "%_t
end

function getIcon(seed, rarity)
    local perc, flat, tech = getBonuses(seed, rarity, permanent)
    if perc ~= 0 and flat ~= 0 then
        return "data/textures/icons/NYcargo.png"
    end
    return "data/textures/icons/cargo-hold.png"
end

function getEnergy(seed, rarity, permanent)
    local perc, flat, tech = getBonuses(seed, rarity)
    return (perc * 1.5 * 1000 * 1000 * 1000 + flat * 0.01 * 1000 * 1000 * 1000) * tech.energyFactor
end

function getPrice(seed, rarity)
    local perc, flat, tech = getBonuses(seed, rarity)
    local price = perc * 100 * 450 + flat * 75
    return (price * 2.5 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local perc, flat, tech = getBonuses(seed, rarity, permanent)
    local basePerc, baseFlat, _ = getBonuses(seed, rarity, false)


    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Cargo Hold (relative)"%_t, rtext = "???"%_t, icon = "data/textures/icons/crate.png", boosted = permanent})
            table.insert(bonuses, {ltext = "Cargo Hold"%_t, rtext = "???"%_t, icon = "data/textures/icons/crate.png", boosted = permanent})
            return texts, bonuses
        end
    end

    if perc ~= 0 then
        table.insert(texts, {ltext = "Cargo Hold (relative)"%_t, rtext = string.format("%+i%%", round(perc * 100)), icon = "data/textures/icons/crate.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Cargo Hold (relative)"%_t, rtext = string.format("%+i%%", round(basePerc * tech.cargoMulti * 100)), icon = "data/textures/icons/crate.png", boosted = permanent})
    end

    if flat ~= 0 then
        table.insert(texts, {ltext = "Cargo Hold"%_t, rtext = string.format("%+i", round(flat)), icon = "data/textures/icons/crate.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Cargo Hold"%_t, rtext = string.format("%+i", round(baseFlat * tech.cargoMulti)), icon = "data/textures/icons/crate.png", boosted = permanent})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local perc, flat, tech = getBonuses(seed, rarity, false)
    if tech.uid == 0700 then
        return{{ltext = "It's bigger on the inside!"%_t, lcolor = ColorRGB(1, 0.5, 0.5)}}
    end
    local texts = getLines(tech)
    return texts
end


function getComparableValues(seed, rarity)
    local perc, flat, tech = getBonuses(seed, rarity, false)
    local basePerc, baseFlat, _ = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    if perc ~= 0 then
        table.insert(base, {name = "Cargo Hold (relative)"%_t, key = "cargo_hold_relative", value = round(perc * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Cargo Hold (relative)"%_t, key = "cargo_hold_relative", value = round(basePerc * tech.cargoMulti * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    if flat ~= 0 then
        table.insert(base, {name = "Cargo Hold"%_t, key = "cargo_hold", value = round(flat), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Cargo Hold"%_t, key = "cargo_hold", value = round(baseFlat * tech.cargoMulti), comp = UpgradeComparison.MoreIsBetter})
    end

    return base, bonus
end


