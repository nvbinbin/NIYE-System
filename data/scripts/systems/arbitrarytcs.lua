
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise") -- 新增库

-- 通用栏位
FixedEnergyRequirement = true

BoostingUpgrades = {}
BoostingUpgrades["data/scripts/systems/arbitrarytcs.lua"] = true

local systemType = "arbitrarytcs"
--[[
    系统联动效果：

    [2/2] 协同联动网络
    通用栏位 + 1

    [4/4] 战斗协同系统
    防御栏位 + 1
    自动栏位 + 1

]]
function getNumBonusTurrets(seed, rarity, permanent)
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

    return turrets, pdcs, autos, counter
end

function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)
    
    local tech = getEnterprise(seed, rarity, systemType)

    if tech.uid == 0700 then tech.nameId = "TCS" end

    -- 初始化
    local turrets = 0
    local autos = 0
    local pdcs = 0


    local turrets = math.max(1, tech.rarity)

    if permanent then
        turrets = turrets + math.max(1,  tech.rarity / 2)
        pdcs = getInt(0, getInt(1, math.max(0, tech.rarity - 3)))   -- 0 ~ 2
        autos = math.max(0, getInt(math.max(0, tech.rarity - 2), turrets - 1))
    end
    if not permanent and tech.onlyPerm then
        turrets = 0
        pdcs = 0
        autos = 0
    end

    return turrets, pdcs, autos, tech
end

function onInstalled(seed, rarity, permanent)
    Entity():registerCallback("onSystemsChanged", "onSystemsChanged")

    applyBonuses(seed, rarity, permanent)
end

function onUninstalled(seed, rarity, permanent)
end

function onSystemsChanged()
    applyBonuses(getSeed(), getRarity(), getPermanent())
end

local key1
local key2
local key3

function applyBonuses(seed, rarity, permanent)
    if key1 then removeBonus(key1) end
    if key2 then removeBonus(key2) end
    if key3 then removeBonus(key3) end

    local turrets, pdcs, autos = getNumTurrets(seed, rarity, permanent)
    turrets = turrets + getNumBonusTurrets(seed, rarity, permanent)

    key1 = addMultiplyableBias(StatsBonuses.ArbitraryTurrets, turrets)
    key2 = addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    key3 = addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function getName(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)

    local ids = tech.nameId
    local num = turrets + pdcs + autos
    local name = "通用炮塔控制系统"%_t

    if num >= 16 then name = "完美的"%_t .. name end
    if tech.uid == 1002 then num = "XXX" end

    return "${ids} ${name}-${num}"%_t % {name = name, num = num, ids = ids}
end

function getBasicName()
    return "Turret Control Subsystem (Arbitrary) /* generic name for 'Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)

    return makeIcon("arbturret", tech)
end

function getEnergy(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 350 * 1000 * 1000 / (1.1 ^ tech.rarity)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local _, _, autos, tech = getNumTurrets(seed, rarity, true)

    local price = 7500 * (turrets + autos * 0.5);
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)
    local permTurrets = maxTurrets - turrets

    
    

    local texts = {}
    local bonuses = {}

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Arbitrary Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Defensive Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Auto-Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        return texts, bonuses
    end
    if isEntityScript() then
        if permanent then
            turrets, pdcs, autos, counter = getNumBonusTurrets(seed, rarity, true)
        end
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
    local texts = {}

    local lca = ColorRGB(0.5, 0.5, 0.5)
    local lcb = ColorRGB(0.5, 0.5, 0.5)
    local rca = ColorRGB(0.5, 0.5, 0.5)
    local rcb = ColorRGB(0.5, 0.5, 0.5)

    local perm2key = "[双联动：协同联动网络]"%_t
    local perm4key = "[四联动：战斗附属系统]"%_t

    if isEntityScript() then
        turrets, pdcs, autos, counter = getNumBonusTurrets(seed, rarity, true)
        local p2 = counter
        local p4 = counter
        if counter >= 2 then p2 = 2 lca = ColorRGB(1, 1, 1) rca = ColorRGB(0, 1, 1) end
        
        if counter >= 4 then p4 = 4 lcb = ColorRGB(1, 1, 1) rcb = ColorRGB(0, 1, 1) end
            
        perm2key = "[协同联动网络]["%_t..p2.."/".."2]"

        perm4key = "[战斗附属系统]["%_t..p4.."/".."4]"
    end
    
    table.insert(texts, {ltext = perm2key, lcolor = lca})

    if isEntityScript() then
        if permanent then
            table.insert(texts, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = lca, rcolor = rca})
        end
    end
    
    table.insert(texts, {ltext = perm4key, lcolor = lcb})

    if isEntityScript() then
        if permanent then
            table.insert(texts, {ltext = "Defensive Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = lcb, rcolor = rcb})
            table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = lcb, rcolor = rcb})
        end
    end
    
    table.insert(texts, {ltext = ""})
    if tech.uid == 0700 then
        table.insert(texts, {ltext = "All-round Turret Control System"%_t, rtext = "", icon = ""})
        table.insert(texts, {ltext = "Adds slots for any turrets"%_t, rtext = "", icon = ""})
    end
    local techTexts = getLines(seed, tech)
    for i, v in pairs(techTexts) do
        table.insert(texts, v)   
    end
    return texts
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
