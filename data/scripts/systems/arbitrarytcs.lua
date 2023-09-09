
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getNumTurrets(seed, rarity, permanent)

    math.randomseed(seed)

    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "A" end

    local turrets = math.max(1, tech.rarity)
    local autos = math.max(0, getInt(math.max(0, tech.rarity - 2), turrets - 1))

    if permanent then
        turrets = (turrets + math.max(1,  tech.rarity / 2)) 
        autos = autos

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

    local ids = tech.nameId

    if tech.uid == 0700 then
        return "Turret Control Subsystem ${ids}-TCS-${num}"%_t % {num = turrets + autos, ids = ids}
    end
    if tech.uid == 0902 then
        return "通用炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = "???", ids = ids}
    end
    return "通用炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = turrets + autos, ids = ids}


end

function getBasicName()
    return "Turret Control Subsystem (Arbitrary) /* generic name for 'Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)

    if tech.uid == 0700 then
        return "data/textures/icons/turret.png"
    end
    return "data/textures/icons/NYturret.png"
end

function getEnergy(seed, rarity, permanent)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 350 * 1000 * 1000 / (1.1 ^ rarity.value)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local turrets, _ = getNumTurrets(seed, rarity, false)
    local _, autos, tech = getNumTurrets(seed, rarity, true)

    local price = 7500 * (turrets + autos * 0.5);
    return (price * 2.5 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, _, tech = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, autos = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})
            table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})
            return texts, bonuses
        end
    end

    table.insert(texts, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    if permanent then
        if autos > 0 then
            table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
    end

    table.insert(bonuses, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})

    if autos > 0 then
        table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)
    if tech.uid == 0700 then
        return
        {
            {ltext = "All-round Turret Control System"%_t, rtext = "", icon = ""},
            {ltext = "Adds slots for any turrets"%_t, rtext = "", icon = ""}
        }
    end
    local texts = getLines(tech)
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
