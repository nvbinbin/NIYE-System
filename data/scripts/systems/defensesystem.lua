package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- 内部防御
FixedEnergyRequirement = true

function getNumDefenseWeapons(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, 1)
    if tech.uid == 0700 then tech.nameId = "IDWS" end

    def = 0

    if permanent then
        if rarity.value <= 2 then
            def = (tech.rarity + 2) * 5 + getInt(0, 3)
        else
            def = tech.rarity * 10 + getInt(0, 8)
        end
    end

    return def, tech
end

function onInstalled(seed, rarity, permanent)
    local numWeapons = getNumDefenseWeapons(seed, rarity, permanent)

    addAbsoluteBias(StatsBonuses.DefenseWeapons, numWeapons)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    local n = getNumDefenseWeapons(seed, rarity, true)
    if tech.uid == 0902 then n = "000" end

    return "${id}-舰内防御武器系统 -${num}"%_t % {id = tech.nameId, num = n}
end

function getBasicName()
    return "舰内防御武器系统 /* generic name for 'Internal Defense Weapons System IDWS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)

    return makeIcon("shotgun", tech)
end

function getEnergy(seed, rarity, permanent)
    local num, tech = getNumDefenseWeapons(seed, rarity, permanent)
    return (num * 75 * 1000 * 1000 / (1.2 ^ tech.rar)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    local price = 500 * num;
    return (price * 2 ^ tech.rar) * tech.money
end

function getTooltipLines(seed, rarity, permanent)
    local num, tech = getNumDefenseWeapons(seed, rarity, true)
    local texts = {}
    local bonuses = {}
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.uid == 0902 then
            texts, bonuses = churchTip(texts, bonuses,"Internal Defense Weapons", "+???", "data/textures/icons/shotgun.png", permanent)
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

    local texts = getLines(seed, tech)
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
