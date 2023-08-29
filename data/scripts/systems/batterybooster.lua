package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local energy = 15 -- base value, in percent
    -- add flat percentage based on rarity
    energy = energy + (rarity.value + 1) * 15 -- add 0% (worst rarity) to +80% (best rarity)

    -- add randomized percentage, span is based on rarity
    energy = energy + math.random() * ((rarity.value + 1) * 10) -- add random value between 0% (worst rarity) and +60% (best rarity)
    energy = energy * 0.8
    energy = energy / 100

    local charge = 15 -- base value, in percent
    -- add flat percentage based on rarity
    charge = charge + (rarity.value + 1) * 4 -- add 0% (worst rarity) to +24% (best rarity)

    -- add randomized percentage, span is based on rarity
    charge = charge + math.random() * ((rarity.value + 1) * 4) -- add random value between 0% (worst rarity) and +24% (best rarity)
    charge = charge * 0.8
    charge = charge / 100

    if permanent then
        charge = charge * 1.5
        energy = energy * 1.5
    end

    -- probability for both of them being used
    -- when rarity.value >= 4, always both
    -- when rarity.value <= 0 always only one
    local probability = math.max(0, rarity.value * 0.25)
    if math.random() > probability then
        -- only 1 will be used
        if math.random() < 0.5 then
            energy = 0
        else
            charge = 0
        end
    end

    return energy, charge
end

function onInstalled(seed, rarity, permanent)
    local energy, charge = getBonuses(seed, rarity, permanent)

    addBaseMultiplier(StatsBonuses.EnergyCapacity, energy)
    addBaseMultiplier(StatsBonuses.BatteryRecharge, charge)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local energy, charge = getBonuses(seed, rarity, true)

    local name = ""
    if charge > 0 then
        if energy > 0 then
            name = "Fast-Charge Battery Booster"%_t
        else
            name = "Fast-Charge Battery Upgrade"%_t
        end
    else
        name = "Battery Booster"%_t
    end

    local serial = makeSerialNumber(seed, 1, "W", "", "4A")
    serial = serial .. makeSerialNumber(seed, 1, "", "", "T7")
    serial = serial .. makeSerialNumber(seed, 1, "", "-T", "T7")

    return "${serial} ${name} R-${rarity} /* ex: W477-T Fast-Charge Battery Upgrade R-III */"%_t % {serial = serial, name = name, rarity = toRomanLiterals(rarity.value+2)}
end

function getBasicName()
    return "Battery Booster"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/battery-pack-alt.png"
end

function getEnergy(seed, rarity, permanent)
    return 0
end

function getPrice(seed, rarity)
    local energy, charge = getBonuses(seed, rarity)
    local price = energy * 100 * 250 + charge * 100 * 150;
    return price * 3.0 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local energy, charge = getBonuses(seed, rarity, permanent)
    local baseEnergy, baseCharge = getBonuses(seed, rarity, false)

    if energy ~= 0 then
        table.insert(texts, {ltext = "Energy Capacity"%_t, rtext = string.format("%+i%%", round(energy * 100)), icon = "data/textures/icons/battery-pack-alt.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Energy Capacity"%_t, rtext = string.format("%+i%%", round(baseEnergy * 0.5 * 100)), icon = "data/textures/icons/battery-pack-alt.png", boosted = permanent})
    end

    if charge ~= 0 then
        table.insert(texts, {ltext = "Recharge Rate"%_t, rtext = string.format("%+i%%", round(charge * 100)), icon = "data/textures/icons/power-unit.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Recharge Rate"%_t, rtext = string.format("%+i%%", round(baseCharge * 0.5 * 100)), icon = "data/textures/icons/power-unit.png", boosted = permanent})
    end

    return texts, bonuses
end


function getComparableValues(seed, rarity)
    local energy, charge = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    if energy ~= 0 then
        table.insert(base, {name = "Energy Capacity"%_t, key = "energy_capacity", value = round(energy * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Energy Capacity"%_t, key = "energy_capacity", value = round(energy * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    if charge ~= 0 then
        table.insert(base, {name = "Recharge Rate"%_t, key = "recharge_rate", value = round(charge * 100), comp = UpgradeComparison.MoreIsBetter})
        table.insert(bonus, {name = "Recharge Rate"%_t, key = "recharge_rate", value = round(charge * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    return base, bonus
end
