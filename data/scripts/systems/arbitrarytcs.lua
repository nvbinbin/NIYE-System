
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise") -- 新增库

FixedEnergyRequirement = true
-- 通用炮塔栏位
local systemType = "arbitrarytcs"

BoostingUpgrades = {}
BoostingUpgrades["data/scripts/systems/arbitrarytcs.lua"] = true
--[[
    系统联动效果：

    [2/2] 协同联动网络
    通用栏位 + 1

    [4/4] 战斗协同系统
    防御栏位 + 1
    自动栏位 + 1

]]

function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)
    
    local tech = getEnterprise(seed, rarity, systemType)
    if tech.id == 0 then tech.abbr = "TCS" end
    -- 初始化
    local arbs = 0
    local autos = 0
    local pdcs = 0
    -- 算法
    arbs = math.max(1, tech.rarity)
    if permanent then
        arbs = arbs + math.max(1, (tech.rarity + 1) / 2)    -- 8
        pdcs = getInt(0, getInt(1, math.max(0, tech.rarity - 3)))   -- 0 ~ 2
        autos = math.max(0, getInt(math.max(0, tech.rarity - 2), arbs - 2)) -- 3 ~ 6
    end

    return arbs, pdcs, autos, tech
end

function onInstalled(seed, rarity, permanent)
    local turrets, pdcs, autos = getNumTurrets(seed, rarity, permanent)
    local counter = 0
    if permanent then
        -- 侦测装备同类型系统数量
        for upgrade, permanent in pairs(ShipSystem():getUpgrades()) do
            if permanent and BoostingUpgrades[upgrade.script] then
                counter = counter + 1
            end
        end
        if counter >= 2 then
            turrets = turrets + 1
        end
        if counter >= 4 then
            pdcs = pdcs + 1
            autos = autos + 1
        end
    end

    addMultiplyableBias(StatsBonuses.ArbitraryTurrets, turrets)
    addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)

    local ids = tech.abbr
    local num = turrets + pdcs + autos
    local name = "通用炮塔控制系统"%_t

    if num >= 16 then name = "完美的"%_t .. name end
    --if tech.id == 0902 then num = "???" end

    return "[${ids}]${name}-${num}"%_t % {name = name, num = num, ids = ids}
end

function getBasicName()
    return "[TCS]完美的通用炮塔控制系统-16"%_t
end

function getIcon(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    return makeIcon("arbturret", tech)
end

function getEnergy(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 350 * 1000 * 1000 / (1.1 ^ tech.rarity)) * tech.energy
end

function getPrice(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local _, _, autos, tech = getNumTurrets(seed, rarity, true)

    local price = 7500 * (turrets + autos * 0.5)
    return (price * 2.5 ^ tech.rarity) * tech.money
end

function getTooltipLines(seed, rarity, permanent)
    local turrets = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}

    if tech.id ~= 0 then 
        table.insert(texts, {ltext = "[" .. tech.abbr .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        -- if tech.id == 0902 then
        --     texts, bonuses = churchTip(texts, bonuses,"Arbitrary Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        --     texts, bonuses = churchTip(texts, bonuses,"Auto-Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        --     return texts, bonuses
        -- end
    end

    table.insert(texts, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})

    if pdcs > 0 then
        if permanent then
            table.insert(texts, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png"})
    end

    if autos > 0 then
        if permanent then
            table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png"})
    end
    
    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    if tech.id == 1 then
        return
        {
            {ltext = "All-round Turret Control System"%_t, rtext = "", icon = ""},
            {ltext = "Adds slots for any turrets"%_t, rtext = "", icon = ""}
        }
    end
    local bonuses = {}
    table.insert(bonuses, {ltext = "[双联动：协同联动网络]"%_t, lcolor = ColorRGB(0.5, 0.5, 0.5)})
    table.insert(bonuses, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = ColorRGB(0.5, 0.5, 0.5)})
    table.insert(bonuses, {ltext = "[四联动：战斗附属系统]"%_t, lcolor = ColorRGB(0.5, 0.5, 0.5)})
    table.insert(bonuses, {ltext = "Defensive Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = ColorRGB(0.5, 0.5, 0.5)})
    table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = ColorRGB(0.5, 0.5, 0.5)})
    

    local texts = getLines(seed, tech)
    for i, v in pairs(texts) do
        table.insert(bonuses, v)   
    end
    return bonuses
end

function getComparableValues(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local bonusTurrets = getNumBonusTurrets(seed, rarity, true)
    local _, pdcs, autos = getNumTurrets(seed, rarity, true)

    return
    {
        {name = "Arbitrary Turret Slots"%_t, key = "arbitrary_slots", value = turrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Arbitrary Turret Slots"%_t, key = "arbitrary_slots", value = bonusTurrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = pdcs, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = autos, comp = UpgradeComparison.MoreIsBetter},
    }
end
