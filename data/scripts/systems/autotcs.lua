
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

    local turrets = math.max(1, tech.rarity + 1)

    if permanent then
         turrets = turrets * 2 
    end

    return turrets, tech
end

function onInstalled(seed, rarity, permanent)
    local turrets = getNumTurrets(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.AutomaticTurrets, turrets)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local turrets, tech = getNumTurrets(seed, rarity, true)
    local ids = tech.nameId

    if tech.uid == 0700 then
        return "Auto-Turret Control Subsystem ${ids}-TCS-${num}"%_t % {num = turrets, ids = ids}
    end
    if tech.uid == 0902 then
        return "自动炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = "???", ids = ids}
    end
    return "自动炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = turrets, ids = ids}

end

function getBasicName()
    return "Turret Control Subsystem (Auto) /* generic name for 'Auto-Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local turrets, tech = getNumTurrets(seed, rarity, permanent)
    if tech.uid == 0700 then
        return "data/textures/icons/turret.png"
    end
    return "data/textures/icons/NYturret.png"
end

function getEnergy(seed, rarity, permanent)
    local num, tech = getNumTurrets(seed, rarity, permanent)
    return (num * 200 * 1000 * 1000 / (1.2 ^ rarity.value)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local num, tech = getNumTurrets(seed, rarity, true)
    local price = 5000 * num;
    return (price * 2.5 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, tech = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, _ = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = tech.tip, lcolor = ColorRGB(1, 0.5, 1)}) 

        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})
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

    local texts = getLines(tech)
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
