package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- 加速引擎强化
FixedEnergyRequirement = true
local systemType = "enginebooster"

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, systemType)
    if tech.uid == 0700 then tech.nameId = "V" end
    -----  我是王者荣耀3000小时玩家  -----
    tech.engineVfactorResult = math.random(tech.minRandom, tech.maxRandom) / 100 -- 航速
    tech.engineAfactorResult = math.random(tech.minRandom, tech.maxRandom) / 100 -- 加速
    ------------------------------------

    local vfactor = 3 -- base value, in percent
    local afactor = 6 -- base value, in percent

    -- add flat percentage based on rarity
    vfactor = vfactor + (tech.rarity + 1) * 3 -- add 0% (worst rarity) to +18% (best rarity)

    -- add randomized percentage, span is based on rarity
    vfactor = vfactor + tech.engineVfactorResult * ((tech.rarity + 1) * 4) -- add random value between 0% (worst rarity) and +24% (best rarity)
    vfactor = vfactor * 0.8 / 100

    
    -- add flat percentage based on rarity
    afactor = afactor + (tech.rarity + 1) * 5 -- add 0% (worst rarity) to +30% (best rarity)

    -- add randomized percentage, span is based on rarity
    afactor = afactor + tech.engineAfactorResult * ((tech.rarity + 1) * 4) -- add random value between 0% (worst rarity) and +24% (best rarity)
    afactor = afactor * 0.8 / 100

    if permanent then
        vfactor = vfactor * 1.5
        afactor = afactor * 1.5
    end
    if not permanent and tech.onlyPerm then
        vfactor = 0
        afactor = 0
    end

    -- probability for both of them being used 异域++
    -- when rarity.value >= 4, always both
    -- when rarity.value <= 0 always only one
    local probability = math.max(0, tech.rarity * 0.25)
    if math.random() > probability then
        -- only 1 will be used
        if math.random() < 0.5 then
            vfactor = 0
        else
            afactor = 0
        end
    end

    return vfactor, afactor, tech
end

function onInstalled(seed, rarity, permanent)
    local vel, acc = getBonuses(seed, rarity, permanent)

    addBaseMultiplier(StatsBonuses.Velocity, vel)
    addBaseMultiplier(StatsBonuses.Acceleration, acc)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local vel, acc, tech = getBonuses(seed, rarity, true)
    local serial = makeSerialNumber(seed, 2, tech.nameId .. "-", "0")

    local name = ""
    if vel > 0 then
        if acc > 0 then
            name = getGrade(tech.engineAfactorResult, tech, 100) .. "Accelerating Engine Booster"%_t
        else
            name = getGrade(tech.engineVfactorResult, tech, 100) .."Engine Booster"%_t
        end
    else
        if acc > 0 then
            name = getGrade(tech.engineAfactorResult, tech, 100) .. "Accelerating Engine Subsystem"%_t
        else
            name = getGrade(tech.engineVfactorResult, tech, 100) .."Engine Subsystem"%_t
        end
    end

    return "${serial} ${name} /* ex: V-AC0 Accelerating Engine Booster */"%_t % {serial = serial, name = name}
end

function getBasicName()
    return "Engine Booster"%_t
end

function getIcon(seed, rarity)
    local vel, acc, tech = getBonuses(seed, rarity, permanent)
    return makeIcon("rocket-thruster", tech)
end

function getEnergy(seed, rarity, permanent)
    local vel, acc, tech = getBonuses(seed, rarity, permanent)
    return ((vel + acc) * 1.5 * 1000 * 1000 * 1000) * tech.energyFactor
end

function getPrice(seed, rarity)
    local vel, acc, tech = getBonuses(seed, rarity, true)
    local price = vel * 100 * 500 + acc * 100 * 500
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local vel, acc, tech = getBonuses(seed, rarity, permanent)
    local baseVel, baseAcc = getBonuses(seed, rarity, false)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Velocity", "+???", "data/textures/icons/speedometer.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Acceleration", "+???", "data/textures/icons/acceleration.png", permanent)
        return texts, bonuses
    end

    if vel ~= 0 then
        table.insert(texts, {ltext = "Velocity"%_t, rtext = string.format("%+i%%", round(vel * 100)), icon = "data/textures/icons/speedometer.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Velocity"%_t, rtext = string.format("%+i%%", round(baseVel * 0.5 * 100)), icon = "data/textures/icons/speedometer.png"})
    end

    if acc ~= 0 then
        table.insert(texts, {ltext = "Acceleration"%_t, rtext = string.format("%+i%%", round(acc * 100)), icon = "data/textures/icons/acceleration.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Acceleration"%_t, rtext = string.format("%+i%%", round(baseAcc * 0.5 * 100)), icon = "data/textures/icons/acceleration.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local vel, acc, tech = getBonuses(seed, rarity, permanent)
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
    local vel, acc = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    if vel ~= 0 then
        table.insert(base, {name = "Velocity"%_t, key = "velocity", value = round(vel * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Velocity"%_t, key = "velocity", value = round(vel * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    if acc ~= 0 then
        table.insert(base, {name = "Acceleration"%_t, key = "acceleration", value = round(acc * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Acceleration"%_t, key = "acceleration", value = round(acc * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    return base, bonus
end
