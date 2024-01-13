
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
    通用炮塔系统

    通用栏位算法：
    默认拥有2个通用栏位 = 2
    增加稀有度x1的额外栏位 = 5
    随机增加[0 - 稀有度x0.5]个通用栏位 = 2.5
    id0max = 9.5
    remix3 = 14

    自动栏位算法：
    默认拥有1个自动栏位 = 1
    增加稀有度x0.5的额外栏位 = 2.5
    随机增加[0 - 稀有度x0.5]个通用栏位 = 2.5
    id0max = 6
    remix3 = 9

    系统联动效果：
    [联动效果只影响本插件；三件套的出现概率10%；四件套5%；五件套1%]
    [3/3]通用战斗协同系统
    通用栏位-2
    武装栏位+4
    

]]

function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)
    

    local tech = getEnterprise(seed, rarity, systemType)
    if tech.id == 0 then
        tech.abbr = "A"
    end

    local counter = 0

    local turrets = math.max(1, tech.rarity)
    local autos = math.max(0, getInt(math.max(0, tech.rarity - 2), turrets - 1))

    if permanent then
        turrets = (turrets + math.max(1,  tech.rarity / 2)) 
        autos = autos
        -- 侦测装备同类型系统数量
        for upgrade, permanent in pairs(ShipSystem():getUpgrades()) do
            if permanent and BoostingUpgrades[upgrade.script] then
                counter = counter + 1
            end
        end
        tech.counter = counter
    end
    if not permanent then -- and tech.onlyPerm
        --turrets = 0
        autos = 0
    end

    return turrets, autos, tech
end

function onInstalled(seed, rarity, permanent)
    local turrets, autos = getNumTurrets(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.ArbitraryTurrets, turrets)
    addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local turrets, autos, tech = getNumTurrets(seed, rarity, true)

    local ids = tech.abbr
    local num = turrets + autos
    local name = "炮塔火控跃增系统"
    if tech.id ~= 0700 then name = "通用火控处理系统" end
    if tech.id == 0902 then num = "000" end

    return "${name} ${ids}-TCS-${num}"%_t % {name = name, num = num, ids = ids}
end

function getBasicName()
    return "Turret Control Subsystem (Arbitrary) /* generic name for 'Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local _, _, tech = getNumTurrets(seed, rarity, permanent)

    return makeIcon("arbturret", tech)
end

function getEnergy(seed, rarity, permanent)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 350 * 1000 * 1000 / (1.1 ^ tech.rarity)) * tech.energy
end

function getPrice(seed, rarity)
    local turrets, _, _ = getNumTurrets(seed, rarity, false)
    local _, autos, tech = getNumTurrets(seed, rarity, true)

    local price = 7500 * (turrets + autos * 0.5);
    return (price * 2.5 ^ tech.rarity) * tech.money
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, _, tech = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, autos = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}

    if tech.id ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.id == 0902 then
            texts, bonuses = churchTip(texts, bonuses,"Arbitrary Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
            texts, bonuses = churchTip(texts, bonuses,"Auto-Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
            return texts, bonuses
        end
    end

    table.insert(texts, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})

    if autos > 0 then
        if permanent then
            table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)
    if tech.id == 1 then
        return
        {
            {ltext = "All-round Turret Control System"%_t, rtext = "", icon = ""},
            {ltext = "Adds slots for any turrets"%_t, rtext = "", icon = ""}
        }
    end
    local texts = getLines(seed, tech)
    return texts
end

function getComparableValues(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local bonusTurrets = getNumBonusTurrets(seed, rarity, true)
    local _, autos = getNumTurrets(seed, rarity, true)

    return
    {
        {name = "Arbitrary Turret Slots"%_t, key = "arbitrary_slots", value = turrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Arbitrary Turret Slots"%_t, key = "arbitrary_slots", value = bonusTurrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = autos, comp = UpgradeComparison.MoreIsBetter},
    }
end
