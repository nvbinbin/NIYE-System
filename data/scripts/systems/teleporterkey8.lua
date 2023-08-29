package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")

-- this key is dropped by the smuggler

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true
MissionRelevant = true

function getBonuses(seed, rarity)
    local reach = 7
    local cdfactor = -0.5
    local energy = -0.8

    return reach, cdfactor, energy
end


function onInstalled(seed, rarity, permanent)
    if not permanent then return end

    local reach, cooldown, energy = getBonuses(seed, rarity)

    addAbsoluteBias(StatsBonuses.HyperspaceReach, reach)
    addBaseMultiplier(StatsBonuses.HyperspaceCooldown, cooldown)
    addBaseMultiplier(StatsBonuses.HyperspaceChargeEnergy, energy)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    return "XSTN-K VIII"%_t
end

function getBasicName()
    return "XSTN-K VIII"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/key8.png"
end

function getPrice(seed, rarity)
    return 10000
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local reach, cdfactor, efactor = getBonuses(seed, rarity)

    table.insert(texts, {ltext = "Jump Range"%_t, rtext = string.format("%+i", reach), icon = "data/textures/icons/star-cycle.png", boosted = permanent})
    table.insert(texts, {ltext = "Hyperspace Cooldown"%_t, rtext = string.format("%+i%%", cdfactor * 100), icon = "data/textures/icons/hourglass.png", boosted = permanent})
    table.insert(texts, {ltext = "Hyperspace Energy"%_t, rtext = string.format("%+i%%", efactor * 100), icon = "data/textures/icons/electric.png", boosted = permanent})

    if not permanent then
        return {}, texts
    else
        return texts, texts
    end

end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "This system has 8 vertical /* continues with 'scratches on its surface.' */"%_t, rtext = "", icon = ""},
        {ltext = "scratches on its surface. /* continued from 'This system has 8 vertical' */"%_t, rtext = "", icon = ""}
    }
end
