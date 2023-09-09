
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("randomext")
include ("utility")
include ("enterprise")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true


function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)

    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "C" end

    local baseTurrets = math.max(1, tech.rarity + 1)
    local turrets = baseTurrets

    local pdcs = 0
    local autos = 0


    if permanent then
        turrets = baseTurrets + math.max(1, (tech.rarity + 1) / 2)
        pdcs = baseTurrets / 2
        autos = math.max(0, getInt(math.max(0, tech.rarity - 1), turrets - 1))
        
    end

    return turrets, pdcs, autos, tech
end

function onInstalled(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.UnarmedTurrets, turrets)
    addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)
    local ids = tech.nameId

    if tech.uid == 0700 then
        return "Civil Turret Control Subsystem ${ids}-TCS-${num}"%_t % {num = turrets + pdcs + autos, ids = ids}
    end
    if tech.uid == 0902 then
        return "民用炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = "???", ids = ids}
    end
    return "民用炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = turrets + pdcs + autos, ids = ids}
end

function getBasicName()
    return "Turret Control Subsystem (Civil)"%_t
end

function getIcon(seed, rarity)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    if tech.uid == 0700 then
        return "data/textures/icons/turret.png"
    end
    return "data/textures/icons/NYturret.png"
end

function getEnergy(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 200 * 1000 * 1000 / (1.2 ^ rarity.value)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local turrets, _, _, tech= getNumTurrets(seed, rarity, false)
    local _, _, autos = getNumTurrets(seed, rarity, true)

    local price = 5000 * (turrets + autos * 0.5)
    return (price * 2.5 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, _ = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, pdcs, autos, tech = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Unarmed Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})
            table.insert(bonuses, {ltext = "Defensive Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})
            table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})

            return texts, bonuses
        end
    end

    table.insert(texts, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    if permanent then
        if pdcs > 0 then
            table.insert(texts, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        if autos > 0 then
            table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
    end

    table.insert(bonuses, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})
    if pdcs > 0 then
        table.insert(bonuses, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png"})
    end
    if autos > 0 then
        table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local turrets, pdcs, autos, tech = getNumTurrets(seed, rarity, permanent)
    if tech.uid == 0700 then
        return
        {
            {ltext = "Civil Turret Control System"%_t, rtext = "", icon = ""},
            {ltext = "Adds slots for unarmed turrets"%_t, rtext = "", icon = ""}
        }
    end
    local texts = getLines(tech)
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
