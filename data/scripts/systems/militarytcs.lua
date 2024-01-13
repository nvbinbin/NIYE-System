
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")

-- 武装栏位
FixedEnergyRequirement = true

function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)

    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "M" end

    local baseTurrets = math.max(1, tech.rarity + 1) -- 原神
    local turrets = baseTurrets
    
    local pdcs = 0
    local autos = 0

    if permanent then
        turrets = baseTurrets + math.max(1, (tech.rarity + 1) / 2)
        pdcs = baseTurrets / 2
        -- 科技等级-1 ~ 最大炮台栏位-1
        autos = math.max(0, getInt(math.max(0, tech.rarity - 1), turrets - 1))
    end
    -- turrets = math.floor(turrets)
    -- pdcs = math.floor(pdcs)
    -- autos = math.floor(autos)
    if not permanent and tech.onlyPerm then
        turrets = 0
        pdcs = 0
        autos = 0
    end

    return turrets, pdcs, autos, tech -- 启动！
end

function onInstalled(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.ArmedTurrets, turrets)
    addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)

    local ids = tech.nameId
    local num = turrets + pdcs + autos
    local name = "武装炮塔火控跃增系统"
    if tech.uid ~= 0700 then name = "武装火控处理系统" end
    if tech.uid == 0902 then num = "000" end

    return "${name} ${ids}-TCS-${num}"%_t % {name = name, num = num, ids = ids}
end

function getBasicName()
    return "Turret Control Subsystem (Combat) "%_t
end

function getIcon(seed, rarity)
    local _, _, _, tech = getNumTurrets(seed, rarity, permanent)

    return makeIcon("milturret", tech)
end

function getEnergy(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 300 * 1000 * 1000 / (1.2 ^ tech.rar)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local turrets, _, _, baseTech = getNumTurrets(seed, rarity, false)
    local _, _, autos, tech = getNumTurrets(seed, rarity, true)

    local price = 6000 * (turrets + autos * 0.5)
    return (price * 2.5 ^ tech.rar) * tech.money
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, _, baseTech = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            texts, bonuses = churchTip(texts, bonuses,"Armed Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
            texts, bonuses = churchTip(texts, bonuses,"Defensive Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
            texts, bonuses = churchTip(texts, bonuses,"Auto-Turret Slots", "+???", "data/textures/icons/turret.png", permanent)
            return texts, bonuses
        end
    end

    table.insert(texts, {ltext = "Armed Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Armed Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})

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

    if tech.uid == 0700 then
        return{
            {ltext = "Military Turret Control System"%_t, rtext = "", icon = ""},
            {ltext = "Adds slots for armed turrets"%_t, rtext = "", icon = ""}
        }
    end

    local texts = getLines(seed, tech)
    return texts
end

function getComparableValues(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local bonusTurrets = getNumBonusTurrets(seed, rarity, true)
    local _, pdcs, autos = getNumTurrets(seed, rarity, true)

    return
    {
        {name = "Armed Turret Slots"%_t, key = "armed_slots", value = turrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Armed Turret Slots"%_t, key = "armed_slots", value = bonusTurrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = pdcs, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = autos, comp = UpgradeComparison.MoreIsBetter},
    }
end
