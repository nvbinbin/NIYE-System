package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("stringutility")
include ("callable")

local seed = nil
local rarity = nil
local permanent = false

function initialize(seed32_in, rarity_in, permanent_in)
    if seed32_in and rarity_in then
        seed = Seed(seed32_in)
        rarity = rarity_in
        permanent = permanent_in
        if seed and rarity then
            onInstalled(seed, rarity, permanent)
        end
    end

    if onClient() then
        invokeServerFunction("remoteInstall")
    end
end

function remoteInstall()
    broadcastInvokeClientFunction("remoteInstallCallback", seed, rarity, permanent)
end
callable(nil, "remoteInstall")

function remoteInstallCallback(seed_in, rarity_in, permanent_in)
    seed = seed_in
    rarity = rarity_in
    permanent = permanent_in or false
    onInstalled(seed, rarity, permanent)
end

-- example: factor 0.3 -> new = old * 1.3
function addBaseMultiplier(bonus, factor)
    if factor == 1 then return end
    if onClient() then return end

    local key = Entity():addBaseMultiplier(bonus, factor)
    return key
end

-- example: factor 0.3 -> new = old * 0.3
function addMultiplier(bonus, factor)
    if factor == 1 then return end
    if onClient() then return end

    local key = Entity():addMultiplier(bonus, factor)
    return key
end

function addMultiplyableBias(bonus, factor)
    if factor == 0 then return end
    if onClient() then return end

    local key = Entity():addMultiplyableBias(bonus, factor)
    return key
end

function addAbsoluteBias(bonus, factor)
    if factor == 0 then return end
    if onClient() then return end

    local key = Entity():addAbsoluteBias(bonus, factor)
    return key
end

function removeBonus(key)
    if onClient() then return end

    Entity():removeBonus(key)
end

function onRemove()
    if onUninstalled then
        onUninstalled(seed, rarity, permanent)
    end
end

function secure()
    -- this acts as a failsafe when something crashes
    seed = seed or Seed(111111)
    rarity = rarity or Rarity(0)
    permanent = permanent or false

    return {seed = seed.value, rarity = rarity.value, permanent = permanent}
end

function restore(data)
    if not data then
        seed = Seed(111111)
        rarity = Rarity(0)
        permanent = false
    else
        seed = Seed(data.seed or 111111)
        rarity = Rarity(data.rarity or 0)
        permanent = data.permanent or false
    end

    onInstalled(seed, rarity, permanent)
end

function makeLine(l)
    l = l or {}
    local fontSize = 13
    local lineHeight = 16

    local iconColor = ColorRGB(0.5, 0.5, 0.5)

    local line = TooltipLine(lineHeight, fontSize)
    line.ltext = l.ltext or ""
    line.ctext = l.ctext or ""
    line.rtext = l.rtext or ""
    line.icon = l.icon or ""
    line.lcolor = l.lcolor or line.lcolor
    line.ccolor = l.ccolor or line.lcolor
    line.rcolor = l.rcolor or line.lcolor
    line.lbold = l.lbold or false
    line.cbold = l.cbold or false
    line.rbold = l.rbold or false
    line.litalic = l.litalic or false
    line.citalic = l.citalic or false
    line.ritalic = l.ritalic or false
    line.iconColor = l.color or iconColor

    return line
end

UpgradeComparison =
{
    MoreIsBetter = 1,
    LessIsBetter = 2,
}


local compResult = {}
compResult[-2] = {icon = "data/textures/icons/minus.png", color = ColorRGB(0.0, 0.0, 0.0)}
compResult[-1] = {icon = "data/textures/icons/arrow-down.png", color = ColorRGB(1, 0, 0)}
compResult[0] = {icon = "data/textures/icons/minus.png", color = ColorRGB(1, 1, 0)}
compResult[1] = {icon = "data/textures/icons/arrow-up.png", color = ColorRGB(0, 1, 0)}

local function applyLessBetter(line, a, b, digits)
    if not line or not a or not b then return end

    local comp = function()
        local va = a or 0
        local vb = b or 0

        if digits then
            va = round(va, digits)
            vb = round(vb, digits)
        end

        if va < vb then return 1 end
        if va > vb then return -1 end
        return 0
    end

    local result = compResult[comp()]
    if not result then return end

    line.iconRight = result.icon
    line.iconRightColor = result.color
end

local function applyMoreBetter(line, a, b, digits)
    if not line or not a or not b then return end

    local comp = function()
        local va = a or 0
        local vb = b or 0

        if not va then return nil end
        if not vb then return nil end

        if digits then
            va = round(va, digits)
            vb = round(vb, digits)
        end

        if va > vb then return 1 end
        if va < vb then return -1 end
        return 0
    end

    local result = compResult[comp()]
    if not result then return end

    line.iconRight = result.icon
    line.iconRightColor = result.color
end

function applyComparisons(tooltipLines, valuesA, valuesB)

    local collect = function(name, valuesA, valuesB)
        local a, b
        for _, la in pairs(valuesA) do
            if name == la.name then
                a = la
                break
            end
        end

        for _, lb in pairs(valuesB) do
            if name == lb.name then
                b = lb
                break
            end
        end

        return a, b
    end

    for _, l in pairs(tooltipLines) do
        local a, b = collect(l.ltext, valuesA, valuesB)

        if a and b then
            if a.comp == UpgradeComparison.MoreIsBetter then
                applyMoreBetter(l, a.value, b.value, a.digits)
            else
                applyLessBetter(l, a.value, b.value, a.digits)
            end
        elseif (a and not b) or (b and not a) then
            local result = compResult[-2]

            l.iconRight = result.icon
            l.iconRightColor = result.color
        end
    end
end

function makeTooltip(seed, rarity, permanent, otherSeed, otherRarity)

    local tooltip = Tooltip()
    tooltip.icon = getIcon(seed, rarity)
    tooltip.price = getPrice(seed, rarity) * 0.25
    tooltip.rarity = rarity

    local iconColor = ColorRGB(0.5, 0.5, 0.5)

    -- head line
    local line = TooltipLine(25, 15)
    line.ctext = getName(seed, rarity)
    line.ccolor = rarity.tooltipFontColor
    tooltip:addLine(line)

    -- rarity name
    local line = TooltipLine(5, 12)
    line.ctext = string.upper(tostring(rarity))
    line.ccolor = rarity.tooltipFontColor
    tooltip:addLine(line)

    local fontSize = 13;
    local lineHeight = 18;

    -- empty line to separate headline from descriptions
    tooltip:addLine(TooltipLine(18, 18))

    local bonusLines
    local boostA, boostB
    if getTooltipLines then
        local lines
        lines, bonusLines = getTooltipLines(seed, rarity, permanent)

        local tooltipLines = {}

        for _, l in pairs(lines) do
            local line = makeLine(l)
            if l.boosted then line.rcolor = ColorRGB(0.3, 1.0, 0.3) end
            table.insert(tooltipLines, line)
        end

        if otherSeed and otherRarity and getComparableValues then
            local valuesA, valuesB
            valuesA, boostA = getComparableValues(seed, rarity)
            valuesB, boostB = getComparableValues(otherSeed, otherRarity)

            applyComparisons(tooltipLines, valuesA, valuesB)
        end

        for _, l in pairs(tooltipLines) do
            tooltip:addLine(l)
        end
    end

    local requiredEnergy = 0
    local requiredBaseEnergy = 0
    local requiredPermanentEnergy = 0
    if getEnergy then
        requiredEnergy = getEnergy(seed, rarity, permanent)
        requiredBaseEnergy = getEnergy(seed, rarity, false)
        requiredPermanentEnergy = getEnergy(seed, rarity, true)
    end

    -- empty lines to separate stats and descriptions
    if bonusLines then
        tooltip:addLine(TooltipLine(8, 8))

        if not permanent then
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Permanent Installation Only (not active):"%_t
            line.icon = "data/textures/icons/anchor.png"
            line.iconColor = ColorRGB(0.9, 0.9, 0.9)
            line.lcolor = ColorRGB(0.9, 0.9, 0.9)
            line.litalic = true
            tooltip:addLine(line)

            local tooltipLines = {}

            for _, l in pairs(bonusLines) do
                local line = makeLine(l)
                line.rcolor = ColorRGB(0.47, 0.47, 0.47)
                line.ccolor = ColorRGB(0.47, 0.47, 0.47)
                line.lcolor = ColorRGB(0.47, 0.47, 0.47)
                table.insert(tooltipLines, line)
            end

            if otherSeed and otherRarity and boostA and boostB then
                applyComparisons(tooltipLines, boostA, boostB)
            end

            for _, l in pairs(tooltipLines) do
                tooltip:addLine(l)
            end

            if requiredBaseEnergy ~= requiredPermanentEnergy and requiredPermanentEnergy > 0 then
                local ownDelta = requiredPermanentEnergy - requiredBaseEnergy
                local energy, unitPrefix = getReadableValue(ownDelta)

                local otherDelta
                if otherSeed and otherRarity then
                    otherDelta = getEnergy(otherSeed, otherRarity, true) - getEnergy(otherSeed, otherRarity, false)
                end

                local line = makeLine()
                line.rcolor = ColorRGB(0.47, 0.47, 0.47)
                line.ccolor = ColorRGB(0.47, 0.47, 0.47)
                line.lcolor = ColorRGB(0.47, 0.47, 0.47)
                line.ltext = "Energy Consumption"%_t
                line.rtext = string.format("%+g %sW", energy, unitPrefix)
                line.icon = "data/textures/icons/electric.png"
                line.iconColor = iconColor
                if otherDelta then
                    applyLessBetter(line, ownDelta, otherDelta)
                end
                tooltip:addLine(line)

            end
        else
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Permanent Installation Bonuses Active"%_t
            line.icon = "data/textures/icons/anchor.png"
            line.iconColor = ColorRGB(1, 1, 1)
            line.litalic = true
            tooltip:addLine(line)
        end
    end

    -- energy consumption (if any)
    if getEnergy then
        tooltip:addLine(TooltipLine(8, 8))

        local energy, unitPrefix = getReadableValue(getEnergy(seed, rarity, permanent))

        local originalEnergy, otherEnergy
        if otherSeed and otherRarity then
            originalEnergy = getEnergy(seed, rarity, permanent)
            otherEnergy = getEnergy(otherSeed, otherRarity, permanent)
        end

        if energy ~= 0 then
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Energy Consumption"%_t
            line.rtext = string.format("%g %sW", energy, unitPrefix)
            line.icon = "data/textures/icons/electric.png"
            line.iconColor = iconColor
            if otherEnergy then
                applyLessBetter(line, originalEnergy, otherEnergy)
            end
            tooltip:addLine(line)
        end
    end

    if Unique == true then
        tooltip:addLine(TooltipLine(8, 8))

        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Unique: only one per ship"%_t
        line.icon = "data/textures/icons/diamonds.png"
        line.iconColor = iconColor
        tooltip:addLine(line)
    end

    if PermanentInstallationOnly == true then
        tooltip:addLine(TooltipLine(8, 8))

        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Permanent: can only be installed permanently"%_t
        line.icon = "data/textures/icons/anchor.png"
        line.iconColor = iconColor
        tooltip:addLine(line)
    end

    tooltip:addLine(TooltipLine(15, 15))

    if getDescriptionLines then
        local lines = getDescriptionLines(seed, rarity, permanent)

        for _, l in pairs(lines) do
            tooltip:addLine(makeLine(l))
        end

        -- empty lines so the icon wont overlap with the descriptions
        for i = 1, 4 - #lines do
            tooltip:addLine(TooltipLine(15, 15))
        end

    else
        -- empty lines so the icon wont overlap with the descriptions
        for i = 1, 4 do
            tooltip:addLine(TooltipLine(15, 15))
        end
    end

    return tooltip
end

function getRarity()
    return rarity
end

function getSeed()
    return seed
end

function getPermanent()
    return permanent
end



