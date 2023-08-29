package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")

-- this key is dropped by the AI

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true
MissionRelevant = true

function onInstalled(seed, rarity, permanent)
    if not permanent then return end

    addAbsoluteBias(StatsBonuses.Pilots, 1200)
    addAbsoluteBias(StatsBonuses.FighterSquads, 4)
    addAbsoluteBias(StatsBonuses.MinersPerTurret, -100000)
    addAbsoluteBias(StatsBonuses.MechanicsPerTurret, -100000)
    addAbsoluteBias(StatsBonuses.GunnersPerTurret, -100000)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    return "XSTN-K VI"%_t
end

function getBasicName()
    return "XSTN-K VI"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/key6.png"
end

function getPrice(seed, rarity)
    return 10000
end

function getTooltipLines(seed, rarity, permanent)
    local texts =
    {
        {ltext = "Gunners Required"%_t, rtext = "0", icon = CrewProfession(CrewProfessionType.Gunner).icon, boosted = permanent},
        {ltext = "Miners Required"%_t, rtext = "0", icon = CrewProfession(CrewProfessionType.Miner).icon, boosted = permanent},
        {ltext = "Pilot Workforce"%_t, rtext = "+1200", icon = CrewProfession(CrewProfessionType.Pilot).icon, boosted = permanent},
        {ltext = "Fighter Squadrons"%_t, rtext = "+4", icon = "data/textures/icons/fighter.png", boosted = permanent},
    }

    if not permanent then
        return {}, texts
    else
        return texts, texts
    end
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Replaces Gunners and Pilots with AIs"%_t, rtext = "", icon = ""},
        {ltext = "", rtext = "", icon = ""},
        {ltext = "This system has 6 vertical /* continues with 'scratches on its surface.' */"%_t, rtext = "", icon = ""},
        {ltext = "scratches on its surface. /* continued from 'This system has 6 vertical' */"%_t, rtext = "", icon = ""}
    }
end
