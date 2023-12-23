
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")

-- 自动栏位
FixedEnergyRequirement = true


function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)

    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "A" end

    local turrets = math.max(1, tech.rar + 1)

    if permanent then
         turrets = turrets * 2 
    end
    if not permanent and tech.onlyPerm then
        turrets = 0
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
    local num = turrets
    local name = "自动炮塔火控跃增系统"
    if tech.uid ~= 0700 then name = "自动火控处理系统" end
    if tech.uid == 0902 then num = "000" end

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
    return (num * 200 * 1000 * 1000 / (1.2 ^ tech.rar)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local num, tech = getNumTurrets(seed, rarity, true)
    local price = 5000 * num;
    return (price * 2.5 ^ tech.rar) * tech.money
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, tech = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, _ = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}

    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
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
