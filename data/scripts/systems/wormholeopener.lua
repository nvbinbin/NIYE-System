package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
MissionRelevant = true

function onInstalled(seed, rarity, permanent)
    if onClient() and valid(Player()) and rarity == Rarity(RarityType.Legendary) then
        Player():registerCallback("onStartDialog", "onStartDialog")
    end
end

function onStartDialog(entityId)
    local entity = Entity(entityId)
    if entity:hasScript("story/wormholeguardian.lua") then
        ScriptUI(entityId):addDialogOption("[Harness Wormhole Power]"%_t, "onHarnessPower")
    end
end

function onHarnessPower(entityId)
    local guardian = Entity(entityId)

    local _, ok = guardian:invokeFunction("wormholeguardian.lua", "channelPlayer")

    if not ok then
        local dialog = {}
        dialog.text = "This didn't work."%_t
        ScriptUI(entityId):showDialog(dialog)
    end
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    if rarity == Rarity(RarityType.Legendary) then
        return "Wormhole Power Diverter"%_t
    else
        return "Xsotan Technology Fragment"%_t
    end
end

function getBasicName()
    return "Xsotan Technology Fragment"%_t
end

function getIcon(seed, rarity)
    if rarity == Rarity(RarityType.Legendary) then
        return "data/textures/icons/wormhole.png"
    else
        return "data/textures/icons/technology-part.png"
    end
end

function getEnergy(seed, rarity, permanent)
    if rarity == Rarity(RarityType.Legendary) then
        return 250 * 1000 * 1000
    else
        return 0
    end
end

function getPrice(seed, rarity)
    return 5000
end

function getTooltipLines(seed, rarity, permanent)
    return
    {
--        {ltext = "All Turrets", rtext = "+" .. getNumTurrets(seed, rarity, permanent), icon = "data/textures/icons/turret.png"}
    }
end

-- to make them stackable
function getComparableValues(seed, rarity)
    local base = {}
    local bonus = {}

    table.insert(base, {name = "", key = "dummy", value = 1, comp = UpgradeComparison.MoreIsBetter})

    return base, bonus
end

function getDescriptionLines(seed, rarity, permanent)
    if rarity == Rarity(RarityType.Legendary) then
        return
        {
            {ltext = "Lets you harness the power /* continues with 'of Xsotan Wormhole Technology.' */"%_t, rtext = "", icon = ""},
            {ltext = "of Xsotan Wormhole Technology. /* continued from 'Lets you harness the power' */"%_t, rtext = "", icon = ""},
        }
    else
        return
        {
            {ltext = "A fragment of Xsotan technology."%_t, rtext = "", icon = ""},
        }
    end
end
