package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

local interestingEntities = {}
local baseCooldown = 40.0
local cooldown = 40.0
local remainingCooldown = 0.0 -- no initial cooldown

local highlightDuration = 30.0
local activeTime = nil
local highlightRange = 0

local permanentlyInstalled = false
local tooltipName = "Object Detection"%_t

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local highlightRange = 0
    local cooldown = baseCooldown

    if rarity.value >= RarityType.Legendary then
        if permanent then
            highlightRange = 8500 + math.random() * 1000
        end

        cooldown = baseCooldown

    elseif rarity.value >= RarityType.Exotic then
        if permanent then
            highlightRange = 7000 + math.random() * 1000
        end

        cooldown = baseCooldown

    elseif rarity.value >= RarityType.Exceptional then
        if permanent then
            highlightRange = 5500 + math.random() * 1000
        end

        cooldown = baseCooldown

    elseif rarity.value >= RarityType.Rare then
        if permanent then
            highlightRange = 4000 + math.random() * 1000
        end

        cooldown = baseCooldown

    elseif rarity.value >= RarityType.Uncommon then
        if permanent then
            highlightRange = 2500 + math.random() * 1000
        end

        cooldown = baseCooldown + highlightDuration * 0.5

    elseif rarity.value >= RarityType.Common then
        if permanent then
            highlightRange = 1000 + math.random() * 1000
        end

        cooldown = baseCooldown + highlightDuration

    elseif rarity.value >= RarityType.Petty then
        highlightRange = 0
        cooldown = baseCooldown + highlightDuration * 3
    end

    return highlightRange, cooldown
end

function onInstalled(seed, rarity, permanent)
    if onClient() then
        local player = Player()
        if valid(player) then
            player:registerCallback("onPreRenderHud", "onPreRenderHud")
            player:registerCallback("onPreRenderHud", "sendMessageForValuables")
        end
    end

    highlightRange, cooldown = getBonuses(seed, rarity, permanent)
    permanentlyInstalled = permanent

    if onClient() then
        sendMessageForValuables()
    end
end

function onUninstalled(seed, rarity, permanent)
end

function updateClient(timeStep)
    if remainingCooldown > 0.0 then
        remainingCooldown = math.max(0, remainingCooldown - timeStep)
    end

    if activeTime then
        activeTime = activeTime - timeStep
        if activeTime <= 0.0 then
            activeTime = nil
            interestingEntities = {}
        end
    end
end

function onDetectorButtonPressed()
    -- set cooldown and activeTime on both client and server
    remainingCooldown = cooldown
    activeTime = highlightDuration

    interestingEntities = collectHighlightableObjects()

    playSound("scifi-sonar", SoundType.UI, 0.5)

    -- notify player that entities were found
    if tablelength(interestingEntities) > 0 then
        deferredCallback(3, "showNotification", "Valuable objects detected."%_t)
    else
        deferredCallback(3, "showNotification", "Nothing found here."%_t)
    end

    interestingEntities = filterHighlightableObjects(interestingEntities)
end

function showNotification(text)
    displayChatMessage(text, "Object Detector"%_t, ChatMessageType.Information)

end

function onSectorChanged()
    if onClient() then
        sendMessageForValuables()
    end
end

function interactionPossible(playerIndex, option)
    local player = Player(playerIndex)
    if not player then return false, "" end

    local craftId = player.craftIndex
    if not craftId then return false, "" end

    if craftId ~= Entity().index then
        return false, ""
    end

    if remainingCooldown > 0.0 then
        return false, ""
    end

    return true
end

function initUI()
    ScriptUI():registerInteraction(tooltipName, "onDetectorButtonPressed", -1);
end

function getUIButtonCooldown()
    local tooltipText = ""

    if remainingCooldown > 0 then
        local duration = math.max(0.0, remainingCooldown)
        local minutes = math.floor(duration / 60)
        local seconds = duration - minutes * 60
        tooltipText = tooltipName .. ": " .. string.format("%02d:%02d", math.max(0, minutes), math.max(0.01, seconds))
    else
        tooltipText = tooltipName
    end

    return remainingCooldown / cooldown, tooltipText
end

function collectHighlightableObjects()
    local player = Player()
    if not valid(player) then return end

    local self = Entity()
    if player.craftIndex ~= self.index then return end

    local objects = {}

    -- normal entities
    for _, entity in pairs({Sector():getEntitiesByScriptValue("valuable_object")}) do
        local value = entity:getValue("highlight_color") or entity:getValue("valuable_object")

        -- docked objects are not available for the player
        if not entity.dockingParent then
            if type(value) == "string" then
                objects[entity.id] = {entity = entity, color = Color(value)}
            else
                objects[entity.id] = {entity = entity, color = Rarity(value).color}
            end
        end
    end

    -- wreckages with black boxes
    -- black box wreckages are always tagged as Petty
    for _, entity in pairs({Sector():getEntitiesByScriptValue("blackbox_wreckage")}) do
        -- docked objects are not available for the player
        if not entity.dockingParent then
            objects[entity.id] = {entity = entity, color = ColorRGB(0.3, 0.9, 0.9)}
        end
    end

    return objects
end

function filterHighlightableObjects(objects)
    -- no need to sort out if none of the found entities will be marked
    if highlightRange == 0 then
        return {}
    end

    -- remove all entities that are too far away and shouldn't be marked
    local range2 = highlightRange * highlightRange
    local center = Entity().translationf
    for id, entry in pairs(objects) do
        if valid(entry.entity) then
            if distance2(center, entry.entity.translationf) > range2 then
                objects[id] = nil
            end
        end
    end

    return objects
end

local automaticMessageDisplayed
function sendMessageForValuables()
    if automaticMessageDisplayed then return end
    if not permanentlyInstalled then return end

    local player = Player()
    if not valid(player) then return end

    local self = Entity()
    if player.craftIndex ~= self.index then return end

    local objects = collectHighlightableObjects()

    -- notify player that entities were found
    if tablelength(objects) > 0 then
        displayChatMessage("Valuable objects detected."%_t, "Object Detector"%_t, ChatMessageType.Information)
        automaticMessageDisplayed = true
    end
end

function onPreRenderHud()
    if not highlightRange or highlightRange == 0 then return end
    if not permanentlyInstalled then return end

    local player = Player()
    if not player then return end
    if player.state == PlayerStateType.BuildCraft or player.state == PlayerStateType.BuildTurret then return end

    local self = Entity()
    if player.craftIndex ~= self.index then return end

    if tablelength(interestingEntities) == 0 then return end

    -- detect all objects in range
    local renderer = UIRenderer()

    local range = lerp(activeTime, highlightDuration, highlightDuration - 5, 0, 100000, true)
    local range2 = range * range
    local center = self.translationf

    local timeFactor = 1.25 * math.sin(activeTime * 10)
    for id, object in pairs(interestingEntities) do
        if not valid(object.entity) then
            interestingEntities[id] = nil
            goto continue
        end

        if distance2(object.entity.translationf, center) < range2 then
            local _, size = renderer:calculateEntityTargeter(object.entity)
            local c = lerp(math.sin(activeTime * 10), 0, 1.5, vec3(object.color.r, object.color.g, object.color.b), vec3(1, 1, 1))
            renderer:renderEntityTargeter(object.entity, ColorRGB(c.x, c.y, c.z), size + 1.5 * timeFactor);
        end

        ::continue::
    end

    renderer:display()
end

function getName(seed, rarity)
    local mark = toRomanLiterals(rarity.value + 2)

    local random = Random(Seed(seed))
    local name = randomEntry(random, {"Object Detector"%_t, "Object Finder"%_t})
    local serial = makeSerialNumber(random, 2, nil, nil, "1234567890")

    return "C${serial} ${name} T-${mark} /* ex: C-41 Object Finder T-III */"%_t % {serial = serial, mark = mark, name = name}
end

function getBasicName()
    return "Object Detector"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/movement-sensor.png"
end

function getControlAction()
    return ControlAction.ScriptQuickAccess2
end

function getEnergy(seed, rarity, permanent)
    local highlightRange = getBonuses(seed, rarity, true)
    highlightRange = math.min(highlightRange, 1500)

    return (highlightRange * 0.0005 * 1000 * 1000 * 1000)
end

function getPrice(seed, rarity)
    local range = getBonuses(seed, rarity, true)
    range = math.min(range, 1500)

    local price = (rarity.value + 2) * 750 + range * 1.5;

    return price * 2.5 ^ (rarity.value + 1)
end

function getTooltipLines(seed, rarity, permanent)
    local texts = {}
    local bonuses = nil
    local range, cooldown = getBonuses(seed, rarity, true)

    local toYesNo = function(line, value)
        if value then
            line.rtext = "Yes"%_t
            line.rcolor = ColorRGB(0.3, 1.0, 0.3)
        else
            line.rtext = "No"%_t
            line.rcolor = ColorRGB(1.0, 0.3, 0.3)
        end
    end

    table.insert(texts, {ltext = "Claimable Asteroids"%_t, icon = "data/textures/icons/asteroid.png"})
    toYesNo(texts[#texts], true)

    table.insert(texts, {ltext = "Flight Recorders"%_t, icon = "data/textures/icons/ship.png"})
    toYesNo(texts[#texts], true)

    table.insert(texts, {ltext = "Treasures"%_t, icon = "data/textures/icons/crate.png"})
    toYesNo(texts[#texts], true)

    table.insert(texts, {}) -- empty line

    if permanent then
        table.insert(texts, {ltext = "Automatic Notification"%_t, rtext = "", icon = "data/textures/icons/mission-item.png", boosted = permanent})
        toYesNo(texts[#texts], permanent)
    end

    bonuses = {}
    table.insert(bonuses, {ltext = "Automatic Notification"%_t, rtext = "Yes", icon = "data/textures/icons/mission-item.png"})

    if range > 0 then
        rangeText = string.format("%g km"%_t, round(range / 100, 2))
        if permanent then
            table.insert(texts, {ltext = "Highlight Range"%_t, rtext = rangeText, icon = "data/textures/icons/rss.png", boosted = permanent})
        end

        table.insert(bonuses, {ltext = "Highlight Range"%_t, rtext = rangeText, icon = "data/textures/icons/rss.png"})
    end

    table.insert(texts, {ltext = "Detection Range"%_t, rtext = "Sector"%_t, icon = "data/textures/icons/rss.png"})

    if range > 0 then
        if permanent then
            table.insert(texts, {ltext = "Highlight Duration"%_t, rtext = string.format("%s", createReadableShortTimeString(highlightDuration)), icon = "data/textures/icons/hourglass.png", boosted = permanent})
        end

        table.insert(bonuses, {ltext = "Highlight Duration"%_t, rtext = string.format("%s", createReadableShortTimeString(highlightDuration)), icon = "data/textures/icons/hourglass.png"})
    end

    table.insert(texts, {ltext = "Cooldown"%_t, rtext = string.format("%s", createReadableShortTimeString(cooldown)), icon = "data/textures/icons/hourglass.png"})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local texts = {}

    table.insert(texts, {ltext = "Detects interesting objects in the sector."%_t})

    if rarity > Rarity(RarityType.Petty) then
        table.insert(texts, {ltext = "Highlights objects when permanently installed."%_t})
    end

    return texts
end

function getComparableValues(seed, rarity)
    local range, cooldown = getBonuses(seed, rarity, true)

    local base = {}
    local bonus = {}
    table.insert(bonus, {name = "Highlight Range"%_t, key = "highlight_range", value = round(range / 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Highlight Duration"%_t, key = "highlight_duration", value = round(highlightDuration), comp = UpgradeComparison.MoreIsBetter})

    table.insert(base, {name = "Detection Range"%_t, key = "detection_range", value = 1, comp = UpgradeComparison.MoreIsBetter})
    table.insert(base, {name = "Cooldown"%_t, key = "cooldown", value = cooldown, comp = UpgradeComparison.LessIsBetter})

    return base, bonus
end
