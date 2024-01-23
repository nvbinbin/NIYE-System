
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


function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)

    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "TCS" end

    -- 初始化
    local turrets = 0
    local arbits = 0
    local pdcs = 0

    local turrets = math.max(1, tech.rarity + 1)

    if permanent then
        turrets = turrets * 2 
        arbits = getInt(0, getInt(1, math.max(0, tech.rarity - 3)))   -- 0 ~ 2
        pdcs = getInt(0, getInt(1, math.max(0, tech.rarity - 3)))   -- 0 ~ 2
        -- 词条
        if tech.uid == 1003 then
            turrets = turrets + 1
        end
    end
    if not permanent and tech.onlyPerm then
        turrets = 0
        arbits = 0
        pdcs = 0
    end

    return turrets, pdcs, arbits, tech
end

function getNumBonusTurrets(seed, rarity, permanent)
    local turrets, pdcs, arbits = getNumTurrets(seed, rarity, permanent)
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
            arbits = arbits + 1
        end
    end

    return turrets, pdcs, arbits, counter
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

    local turrets, pdcs, arbits = getNumBonusTurrets(seed, rarity, permanent)

    key1 = addMultiplyableBias(StatsBonuses.ArbitraryTurrets, turrets)
    key2 = addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    key3 = addMultiplyableBias(StatsBonuses.AutomaticTurrets, arbits)
end

--jindu
function getName(seed, rarity)
    local turrets, tech = getNumTurrets(seed, rarity, true)
    local ids = tech.nameId
    local num = turrets
    local name = "自动炮塔火控跃增系统"
    if tech.uid ~= 0700 then name = "自动火控处理系统" end
    if tech.uid == 1002 then num = "000" end

    return "${name} ${ids}-TCS-${num}"%_t % {name = name, num = num, ids = ids}

end

function getBasicName()
    return "Turret Control Subsystem (Auto) /* generic name for 'Auto-Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local _, tech = getNumTurrets(seed, rarity, permanent)

    return makeIcon("autoturret", tech)
end

function getEnergy(seed, rarity, permanent)
    local num, tech = getNumTurrets(seed, rarity, permanent)
    return (num * 200 * 1000 * 1000 / (1.2 ^ tech.rarity)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local num, tech = getNumTurrets(seed, rarity, true)
    local price = 5000 * num;
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, tech = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, _ = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 1002 then
            texts, bonuses = churchTip(texts, bonuses,"Auto-Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
            return texts, bonuses
        end
    end

    table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local turrets, tech = getNumTurrets(seed, rarity, permanent)
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
