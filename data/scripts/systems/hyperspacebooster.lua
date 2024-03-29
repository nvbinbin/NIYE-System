package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")

-- 超空间跃迁

FixedEnergyRequirement = true

local systemType = "hyperspacebooster"

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, systemType)
    if tech.uid == 0700 then tech.nameId = "R" end

    local reach = 0
    local cdfactor = 0
    local efactor = 0
    local radar = 0
    local cdbias = 0

    -- 双选概率
    local numBonuses = 1

    if rarity.value >= 4 then numBonuses = 3
    elseif rarity.value == 3 then numBonuses = getInt(2, 3)
    elseif rarity.value == 2 then numBonuses = getInt(2, 3)
    elseif rarity.value == 1 then numBonuses = 2
    end


    -- pick bonuses
    local bonuses = {}
    local megaReach = false
    bonuses[StatsBonuses.HyperspaceCooldown] = 1
    bonuses[StatsBonuses.HyperspaceChargeEnergy] = 1
    bonuses[StatsBonuses.RadarReach] = 0.25
    if rarity.value >= 1 then
        bonuses[StatsBonuses.HyperspaceReach] = 100
        megaReach = random():test(0.5)
    end

    if megaReach then
        bonuses[StatsBonuses.HyperspaceCooldown] = 0
    end

    local enabled = {}

    for i = 1, numBonuses do
        local bonus = selectByWeight(random(), bonuses)
        enabled[bonus] = 1
        bonuses[bonus] = nil -- 删除
    end

    if enabled[StatsBonuses.HyperspaceCooldown] then -- 跃迁冷却
        cdfactor = 5 -- base value, in percent
        -- add flat percentage based on rarity
        cdfactor = cdfactor + (tech.rarity + 1) * 2.5 -- add 0% (worst rarity) to +15% (best rarity)

        -- add randomized percentage, span is based on rarity
        cdfactor = cdfactor + math.random() * ((tech.rarity + 1) * 2.5) -- add random value between 0% (worst rarity) and +15% (best rarity)
        cdfactor = -cdfactor / 100
    end

    if enabled[StatsBonuses.HyperspaceChargeEnergy] then -- 超空间跃迁能量
        efactor = 5 -- base value, in percent
        -- add flat percentage based on rarity
        efactor = efactor + (tech.rarity + 1) * 3 -- add 0% (worst rarity) to +18% (best rarity)

        -- add randomized percentage, span is based on rarity
        efactor = efactor + math.random() * ((tech.rarity + 1) * 4) -- add random value between 0% (worst rarity) and +24% (best rarity)
        efactor = -efactor / 100
    end

    if enabled[StatsBonuses.RadarReach] then -- 雷达范围
        radar = math.max(0, getInt(tech.rarity, tech.rarity * 2.0)) + 1
    end

    if permanent then
        if enabled[StatsBonuses.HyperspaceReach] then -- 超空间雷达
            if megaReach then
                reach = math.max(1, tech.rarity + 1) * 2 + tech.rarity -- 跃迁范围
                cdbias = round(math.max(0, (reach - 2) / 4) * 60)
                cdfactor = 0
            else
                reach = math.max(0, (tech.rarity * tech.rarity) / 25 * 8 + random():getFloat(0, 1.0))
            end
        end

        radar = radar * 1.5
    else
        cdfactor = 0
    end
    if not permanent and tech.onlyPerm then
        reach = 0
        cdbias = 0
        cdfactor = 0
        efactor = 0
    end


    return round(reach, 1), cdfactor, efactor, round(radar), cdbias, tech
end

function onInstalled(seed, rarity, permanent)
    local reach, cooldown, energy, radar, cdbias = getBonuses(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.HyperspaceReach, reach)
    addBaseMultiplier(StatsBonuses.HyperspaceCooldown, cooldown)
    addBaseMultiplier(StatsBonuses.HyperspaceChargeEnergy, energy)
    addMultiplyableBias(StatsBonuses.RadarReach, radar)
    addAbsoluteBias(StatsBonuses.HyperspaceCooldown, cdbias)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local reach, cooldown, energy, radar, cdbias, tech = getBonuses(seed, rarity, true)

    local reachStr = ""
    if reach > 0 then
        reachStr = tech.nameId .. math.ceil(reach) .. " "
    end

    local mark = toRomanLiterals(tech.rarity + 2)

    local type = "Hyperspace Subsystem"%_t --超空间跃增系统
    if cooldown ~= 0 and efactor ~= 0 then
        type = "Hyperspace Booster"%_t -- 超空间强化
    elseif cooldown ~= 0 then
        type = "Hyperspace Accelerator"%_t -- 超空间加速器
    elseif efactor ~= 0 then
        type = "Hyperspace Enhancer"%_t -- 超空间增强
    end

    local prefix = ""
    if radar > 0 then
        prefix = "Unveiling"%_t
    end

    return "${prefix} ${reach}${type} MK ${mark} /* ex: Unveiling R-4 Hyperspace Enhancer MK IV*/"%_t % {prefix = prefix, reach = reachStr, type = type, mark = mark}
end

function getBasicName()
    return "Hyperspace Booster"%_t
end

function getIcon(seed, rarity)
    local reach, cdfactor, efactor, radar, cdbias, tech = getBonuses(seed, rarity, permanent)

    return makeIcon("vortex", tech)
end

function getEnergy(seed, rarity, permanent)
    local reach, cdfactor, efactor, radar, cdbias, tech = getBonuses(seed, rarity, permanent)
    return (math.abs(cdfactor) * 2.5 * 1000 * 1000 * 1000 + reach * 125 * 1000 * 1000 + radar * 75 * 1000 * 1000) * tech.energyFactor
end

function getPrice(seed, rarity)
    local reach, _, efactor, radar, _ = getBonuses(seed, rarity, false)
    local _, cdfactor, _, _, _, tech= getBonuses(seed, rarity, true)
    local price = math.abs(cdfactor) * 100 * 350 + math.abs(efactor) * 100 * 250 + reach * 3000 + radar * 450
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local reach, _, efactor, radar = getBonuses(seed, rarity, permanent)
    local baseReach, _, _, baseRadar = getBonuses(seed, rarity, false)
    local betterReach, cdfactor, _, betterRadar, cdbias, tech = getBonuses(seed, rarity, true)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Jump Range", "+???", "data/textures/icons/star-cycle.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Radar Range", "+???", "data/textures/icons/radar-sweep.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Hyperspace Cooldown", "+???", "data/textures/icons/hourglass.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Hyperspace Charge Energy", "data/textures/icons/electric.png", permanent)
        return texts, bonuses
    end

    if reach ~= 0 then
        table.insert(texts, {ltext = "Jump Range"%_t, rtext = string.format("%+g", reach), icon = "data/textures/icons/star-cycle.png", boosted = permanent})
    end
    if betterReach ~= 0 then
        table.insert(bonuses, {ltext = "Jump Range"%_t, rtext = string.format("%+g", betterReach - baseReach), icon = "data/textures/icons/star-cycle.png", boosted = permanent})
    end

    if radar ~= 0 then
        table.insert(texts, {ltext = "Radar Range"%_t, rtext = string.format("%+i", radar), icon = "data/textures/icons/radar-sweep.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Radar Range"%_t, rtext = string.format("%+i", betterRadar - baseRadar), icon = "data/textures/icons/radar-sweep.png", boosted = permanent})
    end

    if cdfactor ~= 0 then
        if permanent then
            table.insert(texts, {ltext = "Hyperspace Cooldown"%_t, rtext = string.format("%+i%%", round(cdfactor * 100)), icon = "data/textures/icons/hourglass.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Hyperspace Cooldown"%_t, rtext = string.format("%+i%%", round(cdfactor * 100)), icon = "data/textures/icons/hourglass.png", boosted = permanent})
    end

    if cdbias ~= 0 then
        if permanent then
            table.insert(texts, {ltext = "Hyperspace Cooldown"%_t, rtext = "+${cd}" % {cd = createReadableShortTimeString(cdbias)}, icon = "data/textures/icons/hourglass.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Hyperspace Cooldown"%_t, rtext = "+${cd}" % {cd = createReadableShortTimeString(cdbias)}, icon = "data/textures/icons/hourglass.png", boosted = permanent})
    end

    if efactor ~= 0 then
        table.insert(texts, {ltext = "Hyperspace Charge Energy"%_t, rtext = string.format("%+i%%", round(efactor * 100)), icon = "data/textures/icons/electric.png"})
    end

    if #bonuses == 0 then bonuses = nil end

    return texts, bonuses
end
function getDescriptionLines(seed, rarity, permanent)
    local reach, cdfactor, efactor, radar, cdbias, tech = getBonuses(seed, rarity, permanent)
    local texts = {}
    if tech.uid == 0700 then
        return
        {
        }
    end

    local techTexts = getLines(seed, tech)
    for i, v in pairs(techTexts) do
        table.insert(texts, v)   
    end
    return texts
end


function getComparableValues(seed, rarity)

    local base = {}
    local bonus = {}

    for _, p in pairs({{base, false}, {bonus, true}}) do
        local values = p[1]
        local permanent = p[2]

        local reach, cdfactor, efactor, radar, cdbias = getBonuses(seed, rarity, permanent)

        if reach ~= 0 then
            table.insert(values, {name = "Jump Range"%_t, key = "jump_range", value = round(reach * 100), comp = UpgradeComparison.MoreIsBetter})
        end

        if radar ~= 0 then
            table.insert(values, {name = "Radar Range"%_t, key = "radar_range", value = round(radar * 100), comp = UpgradeComparison.MoreIsBetter})
        end

        if cdfactor ~= 0 then
            table.insert(values, {name = "Hyperspace Cooldown"%_t, key = "hs_cooldown", value = round(cdfactor * 100), comp = UpgradeComparison.LessIsBetter})
        end

        if efactor ~= 0 then
            table.insert(values, {name = "Hyperspace Charge Energy"%_t, key = "recharge_energy", value = round(efactor * 100), comp = UpgradeComparison.LessIsBetter})
        end

        if cdbias ~= 0 then
            table.insert(values, {name = "Hyperspace Cooldown"%_t, key = "hs_cooldown_time", value = cdbias, comp = UpgradeComparison.LessIsBetter})
        end
    end

    return base, bonus
end
