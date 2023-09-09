
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- 能量护盾转换器
-- optimization so that energy requirement doesn't have to be read every frame

FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "AP" end
    -----  我是王者荣耀3000小时玩家  -----
    tech.amplificationResult = math.random(tech.minRandom, tech.maxRandom) / 100
    ------------------------------------

    local baseAmplification = 20
    -- add flat percentage based on rarity
    local baseAmplification = baseAmplification + (tech.rarity + 1) * 15 -- add 0% (worst rarity) to +120% (best rarity)

    -- add randomized percentage, span is based on rarity
    local amplification = baseAmplification + tech.amplificationResult * (tech.rarity + 1) * 10 -- add random value between 0% (worst rarity) and +60% (best rarity)

    baseAmplification = baseAmplification / 100
    amplification = amplification / 100

    energy = -baseAmplification * 0.45 / (1.05 ^ tech.rarity) -- note the minus

    -- is balanced around permanent installation
    -- permanent installation reverses this factor
    amplification = amplification * 0.4
    if permanent then
        amplification = amplification * 3.5
    end

    return amplification, energy, tech
end

function getEnergyChange(seed, rarity)
end

function onInstalled(seed, rarity, permanent)
    local amplification, energy = getBonuses(seed, rarity, permanent)

    addMultiplier(StatsBonuses.ShieldDurability, 1 + amplification)
    addBaseMultiplier(StatsBonuses.GeneratedEnergy, energy)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local amplification, energy, tech = getBonuses(seed, rarity, permanent)
    local mark = toRomanLiterals(tech.rarity + 2)
    local ids = tech.nameId
    local grade = getGrade(tech.amplificationResult, tech, 100)
    return "${ids} -${grade}能量护盾转换器MK ${mark}"%_t % {mark = mark, ids = ids, grade = grade}
end

function getBasicName()
    return "Energy-To-Shield Converter /* generic name for 'MK ${mark} Energy-To-Shield Converter' */"%_t
end

function getIcon(seed, rarity)
    local amplification, energy, tech = getBonuses(seed, rarity, permanent)
    if tech.uid == 0700 then
        return "data/textures/icons/shield.png"
    end
    return "data/textures/icons/shield.png"
end

function getPrice(seed, rarity)
    local amplification, energy, tech = getBonuses(seed, rarity, permanent)
    local amplification = getBonuses(seed, rarity)
    local price = 150 * 1000 * amplification;
    return (price * 2.0 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local texts = {}
    local bonuses = {}
    local amplification, energy, tech = getBonuses(seed, rarity, permanent)
    local baseAmplification, baseEnergy = getBonuses(seed, rarity, false)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Shield Durability"%_t, rtext = "+???", icon = "data/textures/icons/health-normal.png"})
            table.insert(texts, {ltext = "Generated Energy"%_t, rtext = "±???", icon = "data/textures/icons/electric.png"})
            return texts, bonuses
        end
    end

    table.insert(texts, {ltext = "Shield Durability"%_t, rtext = string.format("%+i%%", round(amplification * 100)), icon = "data/textures/icons/health-normal.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Shield Durability"%_t, rtext = string.format("%+i%%", round(baseAmplification * 3.5 * 100 - amplification * 100)), icon = "data/textures/icons/health-normal.png"})

    table.insert(texts, {ltext = "Generated Energy"%_t, rtext = string.format("%i%%", round(energy * 100)), icon = "data/textures/icons/electric.png"})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local amplification, energy, tech = getBonuses(seed, rarity, permanent)
    if tech.uid == 0700 then
        return
        {
            {ltext = "Re-routes energy to shields"%_t, rtext = "", icon = ""}
        }
    end

    local texts = getLines(tech)
    return texts
end

function getComparableValues(seed, rarity)
    local baseAmplification, baseEnergy = getBonuses(seed, rarity, false)

    return
    {
        {name = "Shield Durability"%_t, key = "durability", value = round(baseAmplification * 100), comp = UpgradeComparison.MoreIsBetter},
        {name = "Generated Energy"%_t, key = "energy", value = round(baseEnergy * 100), comp = UpgradeComparison.LessIsBetter},
    },
    {
        {name = "Shield Durability"%_t, key = "durability", value = round(baseAmplification * 3.5 * 100), comp = UpgradeComparison.MoreIsBetter},
    }
end
