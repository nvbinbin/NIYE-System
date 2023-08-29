package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
PermanentInstallationOnly = true

function getBonus(seed, rarity, permanent)
    return 1
end

function onInstalled(seed, rarity, permanent)
    local steps = getBonus(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.ExcessProcessingPowerSteps, steps)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    return "Stabilizing Mainframe Wiring"%_t
end

function getBasicName()
    return "Stabilizing Mainframe Wiring"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/nanobot-wiring.png"
end

function getEnergy(seed, rarity, permanent)
    return 0
end

function getPrice(seed, rarity)
    return 1000000
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}

    table.insert(bonuses, {ltext = "Excess Processing Power"%_t, rtext = "+117.2k", icon = "data/textures/icons/star-cycle.png", boosted = permanent})
    table.insert(bonuses, {ltext = "Socket Equivalent"%_t, rtext = "+1", icon = "data/textures/icons/star-cycle.png", boosted = permanent})
    table.insert(bonuses, {ltext = "", rtext = "", icon = ""})
    table.insert(bonuses, {ltext = "Required Subsystem Sockets"%_t, rtext = "15", icon = "data/textures/icons/star-cycle.png", boosted = false})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Only active with 15 subsystem sockets available."%_t},
        {ltext = "Increases maximum Processing Power,"%_t},
        {ltext = "as if it had more than 15 subsystem sockets."%_t},
        {ltext = "", lcolor = ColorRGB(1, 0.5, 0.5)},
        {ltext = "Because bigger is better."%_t, lcolor = ColorRGB(1, 0.5, 0.5)},
    }
end

function getComparableValues(seed, rarity)

    local base = {}
    local bonus = {}

    return base, bonus
end
