package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getNumDefenseWeapons(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "IDWS" end

    if permanent then
        if rarity.value <= 2 then
            return (tech.rarity + 2) * 5 + getInt(0, 3), tech
        else
            return tech.rarity * 10 + getInt(0, 8), tech
        end
    end

    return 0, tech
end

function onInstalled(seed, rarity, permanent)
    local numWeapons = getNumDefenseWeapons(seed, rarity, permanent)

    addAbsoluteBias(StatsBonuses.DefenseWeapons, numWeapons)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    return "内部防御武器系统 ${id}-${num}"%_t % {id = tech.nameId, num = getNumDefenseWeapons(seed, rarity, true)}
end

function getBasicName()
    return "内部防御武器系统 /* generic name for 'Internal Defense Weapons System IDWS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    if tech.uid == 0700 then
        return "data/textures/icons/shotgun.png"
    end
    return "data/textures/icons/shotgun.png"
end

function getEnergy(seed, rarity, permanent)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    return (num * 75 * 1000 * 1000 / (1.2 ^ rarity.value)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    local price = 500 * num;
    return (price * 2 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    local texts = {}
    local bonuses = {}
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            table.insert(bonuses, {ltext = "Internal Defense Weapons"%_t, rtext = "+???", boosted = permanent, icon = "data/textures/icons/shotgun.png", boosted = permanent})
            return texts, bonuses
        end
    end
    table.insert(bonuses, {ltext = "Internal Defense Weapons"%_t, rtext = "+" .. num, boosted = permanent, icon = "data/textures/icons/shotgun.png", boosted = permanent})

    return texts , bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)

    if tech.uid == 0700 then
        return{
            {ltext = "Internal Defense Weapons System"%_t, rtext = "", icon = ""},
            {ltext = "Adds internal defense weapons to fight off enemy boarders"%_t, rtext = "", icon = ""}
        }
    end

    local texts = getLines(tech)
    return texts
    
end

function getComparableValues(seed, rarity)
    local defense = getNumDefenseWeapons(seed, rarity, true)

    return
    {
        {name = "Internal Defense Weapons"%_t, key = "defense_weapons", value = defense, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Internal Defense Weapons"%_t, key = "defense_weapons", value = defense, comp = UpgradeComparison.MoreIsBetter},
    }
end
