
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("randomext")
include ("utility")
include ("enterprise")

-- [民用炮塔栏位]
FixedEnergyRequirement = true


BoostingUpgrades = {}
BoostingUpgrades["data/scripts/systems/civiltcs.lua"] = true
local systemType = "civiltcs"


function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)

    local tech = getEnterprise(seed, rarity, systemType)
    if tech.uid == 0700 then tech.nameId = "TCS" end

    local baseTurrets = math.max(1, tech.rarity + 1)
    local turrets = baseTurrets

    local pdcs = 0
    local autos = 0

    if permanent then
        turrets = baseTurrets + math.max(1, (tech.rarity + 1) / 2)
        pdcs = baseTurrets / 2
        autos = math.max(0, getInt(math.max(0, tech.rarity - 1), turrets - 1))
        -- 词条
        if tech.uid == 1003 then
            turrets = turrets + 1
        end
    end
    if not permanent and tech.onlyPerm then
        turrets = 0
        pdcs = 0
        autos = 0
    end

    return turrets, pdcs, autos, tech
end
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
            pdcs = pdcs + 1
        end
        if counter >= 4 then
            turrets = turrets + 1
        end
    end

    return turrets, pdcs, autos, counter
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

    local turrets, pdcs, autos = getNumBonusTurrets(seed, rarity, permanent)

    key1 = addMultiplyableBias(StatsBonuses.UnarmedTurrets, turrets)
    key2 = addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    key3 = addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function getName(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)
    local ids = tech.nameId
    local num = turrets + pdcs + autos

    local name = "民用炮塔火控系统"
    if num >= 19 then name = "优质"%_t .. name end
    if tech.uid == 1002 then num = "XXX" end

    return "${name} ${ids}-${num}"%_t % {name = name, num = num, ids = ids}
end

function getBasicName()
    return "Turret Control Subsystem (Civil)"%_t
end

function getIcon(seed, rarity)
    local _, _, _, tech = getNumTurrets(seed, rarity, permanent)

    return makeIcon("civturret", tech)
end

function getEnergy(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 200 * 1000 * 1000 / (1.2 ^ tech.rarity)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local turrets, _, _, _= getNumTurrets(seed, rarity, false)
    local _, _, autos, tech = getNumTurrets(seed, rarity, true)

    local price = 5000 * (turrets + autos * 0.5)
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, _ = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)
    local texts = {}
    local bonuses = {}
    local counter

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Unarmed Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Defensive Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Auto-Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        return texts, bonuses
    end
    if isEntityScript() then
        if permanent then
            turrets, pdcs, autos, counter = getNumBonusTurrets(seed, rarity, true)
        end
    end

    table.insert(texts, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})

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
    local counter

    local lca = ColorRGB(0.5, 0.5, 0.5)
    local lcb = ColorRGB(0.5, 0.5, 0.5)
    local rca = ColorRGB(0.5, 0.5, 0.5)
    local rcb = ColorRGB(0.5, 0.5, 0.5)

    local perm2key = "[双联动：防御联动系统]"%_t
    local perm4key = "[四联动：算力共享协议]"%_t

    if isEntityScript() then
        turrets, pdcs, autos, counter = getNumBonusTurrets(seed, rarity, true)
        local p2 = counter
        local p4 = counter
        if counter >= 2 then p2 = 2 lca = ColorRGB(1, 1, 1) rca = ColorRGB(0, 1, 1) end
        
        if counter >= 4 then p4 = 4 lcb = ColorRGB(1, 1, 1) rcb = ColorRGB(0, 1, 1) end
            
        perm2key = "[防御联动系统]["%_t..p2.."/".."2]"

        perm4key = "[算力共享协议]["%_t..p4.."/".."4]"
    end
    
    table.insert(texts, {ltext = perm2key, lcolor = lca})

    if isEntityScript() then
        if permanent then
            table.insert(texts, {ltext = "Defensive Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = lca, rcolor = rca})
        end
    end
    
    table.insert(texts, {ltext = perm4key, lcolor = lcb})

    if isEntityScript() then
        if permanent then
            table.insert(texts, {ltext = "Unarmed Turret Slots"%_t, rtext = "+1", icon = "data/textures/icons/turret.png", lcolor = lcb, rcolor = rcb})
        end
    end

    if tech.uid == 0700 then
        table.insert(texts, {ltext = "Civil Turret Control System"%_t, rtext = "", icon = ""})
        table.insert(texts, {ltext = "Adds slots for unarmed turrets"%_t, rtext = "", icon = ""})
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
        {name = "Unarmed Turret Slots"%_t, key = "unarmed_slots", value = turrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Unarmed Turret Slots"%_t, key = "unarmed_slots", value = bonusTurrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = pdcs, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = autos, comp = UpgradeComparison.MoreIsBetter},
    }
end
