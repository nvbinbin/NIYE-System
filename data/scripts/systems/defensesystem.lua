package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getNumDefenseWeapons(seed, rarity, permanent)
    math.randomseed(seed)

    if permanent then
        if rarity.value <= 2 then
            return (rarity.value + 2) * 5 + getInt(0, 3)
        else
            return rarity.value * 10 + getInt(0, 8)
        end
    end

    return 0
end

function onInstalled(seed, rarity, permanent)
    local numWeapons = getNumDefenseWeapons(seed, rarity, permanent)

    addAbsoluteBias(StatsBonuses.DefenseWeapons, numWeapons)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    return "Internal Defense Weapons System IDWS-${num}"%_t % {num = getNumDefenseWeapons(seed, rarity, true)}
end

function getBasicName()
    return "Internal Defense Weapons System /* generic name for 'Internal Defense Weapons System IDWS-${num}' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/shotgun.png"
end

function getEnergy(seed, rarity, permanent)
    local num = getNumDefenseWeapons(seed, rarity, true)
    return num * 75 * 1000 * 1000 / (1.2 ^ rarity.value)
end

function getPrice(seed, rarity)
    local num = getNumDefenseWeapons(seed, rarity, true)
    local price = 500 * num;
    return price * 2 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)
    local text = {ltext = "Internal Defense Weapons"%_t, rtext = "+" .. getNumDefenseWeapons(seed, rarity, true), boosted = permanent, icon = "data/textures/icons/shotgun.png"}
    if permanent then
        return
        {text},
        {text}
    else
        return
        {},
        {text}
    end
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Internal Defense Weapons System"%_t, rtext = "", icon = ""},
        {ltext = "Adds internal defense weapons to fight off enemy boarders"%_t, rtext = "", icon = ""}
    }
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
