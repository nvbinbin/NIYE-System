
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")

-- [自动炮塔栏位]autotcs
FixedEnergyRequirement = true

BoostingUpgrades = {}
BoostingUpgrades["data/scripts/systems/autotcs.lua"] = true

local systemType = "autotcs"

--[[
战斗炮塔控制系统
6+3主要；3防御；8自动
工业炮塔控制系统
6+3主要；3防御；7自动
通用炮塔控制系统
5+2主要；2防御；6自动

    （原自动炮塔）智能炮塔协调器（only）

    1.增加 5+2+6 个基础自动炮塔


]]
function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)

    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "TCS" end

    -- 初始化
    local turrets = 0
    local civils = 0
    local militarys = 0
    local arbits = 0
    local pdcs = 0
    local types

    -- 50%的概率获得三选一
    if math.random() < 0.5 then
        local typeRandom = math.random()
        if typeRandom < 0.33 then
            types = "civils"
        end
        if typeRandom >= 0.33 and typeRandom < 0.66 then
            types = "militarys"
        end
        if typeRandom >= 0.66 then
            types = "arbits"
        end
    end

    local turrets = math.max(1, tech.rarity)

    if permanent then
        turrets = turrets + math.max(1, tech.rarity + 1)
        turrets = turrets + getInt(0, getInt(1, math.max(0, tech.rarity - 3)))   -- 0 ~ 2

        pdcs = getInt(0, getInt(1, math.max(0, tech.rarity - 3)))   -- 0 ~ 2
        -- 词条
        if tech.uid == 1003 then
            turrets = turrets + 1
        end
    end
    if not permanent and tech.onlyPerm then
        turrets = 0
        civils = 0
        militarys = 0
        arbits = 0
        pdcs = 0
    end

    return turrets, pdcs, types, civils, militarys, arbits, tech
end

function getNumBonusTurrets(seed, rarity, permanent)
    local turrets, pdcs, types, civils, militarys, arbits, tech = getNumTurrets(seed, rarity, permanent)
    local counter = 0
    local specials = 0
    if permanent then
        -- 侦测装备同类型系统数量
        for upgrade, permanent in pairs(ShipSystem():getUpgrades()) do
            if permanent and BoostingUpgrades[upgrade.script] then
                counter = counter + 1
            end
        end
        if types == "civils" then
            civils = civils + counter * 0.5
            specials = civils
        end
        if types == "militarys" then
            militarys = militarys + counter * 0.5
            specials = militarys
        end
        if types == "arbit" then
            arbits = arbits + counter * 0.5
            specials = arbits
        end
    end

    return turrets, pdcs, types, specials, counter
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
    local key3Type


    local turrets, pdcs, types, specials, counter = getNumBonusTurrets(seed, rarity, permanent)
    if types then
        if types == "civils" then
            key3Type = StatsBonuses.UnarmedTurrets
        end
        if types == "militarys" then
            key3Type = StatsBonuses.ArmedTurrets
        end
        if types == "arbit" then
            key3Type = StatsBonuses.ArbitraryTurrets
        end
    end

    key1 = addMultiplyableBias(StatsBonuses.AutomaticTurrets, turrets)
    key2 = addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    if key3Type then
        key3 = addMultiplyableBias(key3Type, specials)
    end

end

--jindu
function getName(seed, rarity)
    local turrets, pdcs, types, civils, militarys, arbits, tech = getNumTurrets(seed, rarity, true)
    local ids = tech.nameId
    local num = turrets + pdcs + civils + militarys + arbits
    local name = "自动炮塔火控系统"%_t
    if num >= 15 then name = "优质"%_t .. name end
    if tech.uid == 1002 then num = "XXX" end

    return "${name} ${ids}-${num}"%_t % {name = name, num = num, ids = ids}

end

function getBasicName()
    return "Turret Control Subsystem (Auto) /* generic name for 'Auto-Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local turrets, pdcs, types, civils, militarys, arbits, tech = getNumTurrets(seed, rarity, permanent)

    return makeIcon("autoturret", tech)
end

function getEnergy(seed, rarity, permanent)
    local num, pdcs, types, civils, militarys, arbits, tech = getNumTurrets(seed, rarity, permanent)
    return (num * 200 * 1000 * 1000 / (1.2 ^ tech.rarity)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local num, pdcs, types, civils, militarys, arbits, tech = getNumTurrets(seed, rarity, true)
    local price = 5000 * num;
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, pdcs, types, civils, militarys, arbits, tech = getNumTurrets(seed, rarity, true)
    local permTurrets = maxTurrets - turrets
    local texts = {}
    local bonuses = {}
    local specials
    local counter

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Auto-Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Defensive Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
        if types then
            texts, bonuses = churchTip(texts, bonuses,"未知炮塔"%_t, "+???", "data/textures/icons/turret.png", permanent)
        end
        return texts, bonuses
    end
    if isEntityScript() then
        if permanent then
            turrets, pdcs, types, specials, counter = getNumBonusTurrets(seed, rarity, true)
        end 
        if types then
            if types == "civil" then
                civils = specials
            end
            if types == "military" then
                militarys = specials
            end
            if types == "arbit" then
                arbits = specials
            end
        end
    end

    table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. permTurrets, icon = "data/textures/icons/turret.png"})
    if pdcs > 0 then
        if permanent then
            table.insert(texts, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png"})
    end
    -----------------------
    if civils > 0 then
        if permanent then
            table.insert(texts, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. civils, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. civils, icon = "data/textures/icons/turret.png"})
    end
    if arbits > 0 then
        if permanent then
            table.insert(texts, {ltext = "Arbitration Turret Slots"%_t, rtext = "+" .. arbits, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Arbitration Turret Slots"%_t, rtext = "+" .. arbits, icon = "data/textures/icons/turret.png"})
    end
    if militarys > 0 then
        if permanent then
            table.insert(texts, {ltext = "Armed Turret Slots"%_t, rtext = "+" .. militarys, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        table.insert(bonuses, {ltext = "Armed Turret Slots"%_t, rtext = "+" .. militarys, icon = "data/textures/icons/turret.png"})
    end


    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local turrets, tech = getNumTurrets(seed, rarity, permanent)
    local specials
    local counter
    if tech.uid == 0700 then
        return
        {
        {ltext = "Independent Turret Control System"%_t, rtext = "", icon = ""},
        {ltext = "Adds slots for independent turrets"%_t, rtext = "", icon = ""}
        }
    end

    local texts = getLines(seed, tech)
    return texts
end

function getComparableValues(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local bonusTurrets =  getNumTurrets(seed, rarity, true)

    return
    {
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = turrets, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = bonusTurrets, comp = UpgradeComparison.MoreIsBetter},
    }
end
