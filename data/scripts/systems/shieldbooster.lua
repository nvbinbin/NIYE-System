package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("enterprise")
-- dynamic stats
local rechargeReady = 0
local recharging = 0
local rechargeSpeed = 0

-- static stats
rechargeDelay = 300
rechargeTime = 5
rechargeAmount = 0.35

-- 复活强化护盾
FixedEnergyRequirement = true
local systemType = "shieldbooster"

function getUpdateInterval()
    return 0.25
end

function updateServer(timePassed)
    rechargeReady = math.max(0, rechargeReady - timePassed)

    if recharging > 0 then
        recharging = recharging - timePassed
        Entity():healShield(rechargeSpeed * timePassed)
    end

end

function startCharging()

    if rechargeReady == 0 then
        local shield = Entity().shieldMaxDurability
        if shield > 0 then
            rechargeReady = rechargeDelay
            recharging = rechargeTime
            rechargeSpeed = shield * rechargeAmount / rechargeTime
        end
    end

end

function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local tech = getEnterprise(seed, rarity, systemType)
    if tech.uid == 0700 then tech.nameId = "" end
    -----  我是王者荣耀3000小时玩家  -----
    tech.rechargeShieldResult = math.random(tech.minRandom, tech.maxRandom) / 100
    ------------------------------------

    local durability = 5000 -- add base 5.000 hp to shield
    durability = durability + (tech.rarity + 1) * 10000 -- add 0 hp (worst rarity) to 65.000 hp (best rarity) to shield
    durability = durability + round((math.random(0, 5000)) / 500) * 500 -- add random 0 hp to 6000 hp to add some variability

    local recharge = 5 -- base value, in percent
    -- add flat percentage based on rarity
    recharge = recharge + tech.rarity * 2 -- add -2% (worst rarity) to +10% (best rarity)

    -- add randomized percentage, span is based on rarity
    recharge = recharge + tech.rechargeShieldResult * (tech.rarity * 2) -- add random value between -2% (worst rarity) and +10% (best rarity)
    recharge = recharge * 0.8
    recharge = recharge / 100

    -- probability for both of them being used
    local probability = math.max(0, tech.rarity * 0.25)
    if math.random() > probability then
        -- only 1 will be used
        if math.random() < 0.5 then
            durability = 0
        else
            recharge = 0
        end
    end

    local emergencyRecharge = 0

    if permanent then
        durability = durability * 3
        recharge = recharge * 1.5

        if tech.rarity >= 2 then
            emergencyRecharge = 1
        end
    end
    if not permanent and tech.onlyPerm then
        durability = 0
        recharge = 0
    end

    return durability, recharge, emergencyRecharge, tech
end

function onInstalled(seed, rarity, permanent)
    local durability, recharge, emergencyRecharge = getBonuses(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.ShieldDurability, durability)
    addBaseMultiplier(StatsBonuses.ShieldRecharge, recharge)

    if emergencyRecharge == 1 then
        Entity():registerCallback("onShieldDeactivate", "startCharging")
    else
        -- delete this function so it won't be called by the game
        -- -> saves performance
        -- 删除函数以节省性能开销
        updateServer = nil
    end

end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local durability, recharge, emergencyRecharge, tech = getBonuses(seed, rarity, true)

    local random = Random(Seed(seed))
    local name = randomEntry(random, {"Shield Booster"%_t, "Shielder"%_t, "Protector"%_t})
    local serial = makeSerialNumber(random, 2)
    local rarityStr = tostring((tech.rarity + 2) * 1000) .. getGrade(tech.rechargeShieldResult, tech, 100)
    local vars = {name = name, serial = serial, rarity = rarityStr}
    if tech.uid ~= 0700 then
        serial = tech.nameId
    end

    if emergencyRecharge > 0 then
        return "${serial}-${rarity} Reviving ${name} /* ex: 1Q-4000 Reviving Shield Booster*/"%_t % vars
    else
        return "${serial}-${rarity} ${name} /* ex: 1Q-4000 Shielder */"%_t % vars
    end
end

function getBasicName()
    return "Shield Booster"%_t
end

function getIcon(seed, rarity)
    local durability, recharge, emergencyRecharge, tech = getBonuses(seed, rarity)

    return makeIcon("fixshield", tech)
end

function getEnergy(seed, rarity, permanent)
    local durability, recharge, emergencyRecharge, tech = getBonuses(seed, rarity, true)
    return (((durability / 9000) + recharge * 2) * 1000 * 1000 * 1000) * tech.energyFactor
end

function getPrice(seed, rarity)
    local durability, recharge, emergencyRecharge, tech = getBonuses(seed, rarity, true)
    local price = durability / 5 + recharge * 100 * 250 + emergencyRecharge * 15000
    return (price * 2.5 ^ tech.rarity) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local durability, recharge, emergencyRecharge, tech = getBonuses(seed, rarity, permanent)
    local baseDurability, baseRecharge, baseEmergencyRecharge = getBonuses(seed, rarity, false)
    local bonusDurability, _, bonusEmergencyRecharge = getBonuses(seed, rarity, true)
    if tech.uid ~= 0700 then 
        table.insert(texts, {ltext = "[" .. tech.name .. "]", lcolor = ColorRGB(1, 0.5, 1)}) 
        
    end
    if tech.uid == 1002 then
        texts, bonuses = churchTip(texts, bonuses,"Shield Durability", "+???", "data/textures/icons/health-normal.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Shield Recharge Rate", "+???", "data/textures/icons/shield-charge.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Emergency Recharge", "+???", "data/textures/icons/shield-charge.png", permanent)
        texts, bonuses = churchTip(texts, bonuses,"Recharge Upon Depletion", "+???", "data/textures/icons/shield-charge.png", permanent)
        return texts, bonuses
    end

    if durability ~= 0 then
        table.insert(texts, {ltext = "Shield Durability"%_t, rtext = "+" .. createMonetaryString(durability), icon = "data/textures/icons/health-normal.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Shield Durability"%_t, rtext = "+" .. createMonetaryString(bonusDurability - baseDurability), icon = "data/textures/icons/health-normal.png"})
    end

    if recharge ~= 0 then
        table.insert(texts, {ltext = "Shield Recharge Rate"%_t, rtext = string.format("%+i%%", round(recharge * 100)), icon = "data/textures/icons/shield-charge.png", boosted = permanent})
        table.insert(bonuses, {ltext = "Shield Recharge Rate"%_t, rtext = string.format("%+i%%", round(baseRecharge * 0.5 * 100)), icon = "data/textures/icons/shield-charge.png"})
    end

    if emergencyRecharge ~= 0 then
        table.insert(texts, {ltext = "Emergency Recharge"%_t, rtext = string.format("%i%%", round(rechargeAmount * 100)), icon = "data/textures/icons/shield-charge.png", boosted = permanent})
    end

    if bonusEmergencyRecharge ~= 0 then
        table.insert(bonuses, {ltext = "Recharge Upon Depletion"%_t, rtext = string.format("%i%%", round(rechargeAmount * 100)), icon = "data/textures/icons/shield-charge.png", })
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local durability, recharge, emergencyRecharge, tech = getBonuses(seed, rarity, true)

    local texts = {}

    if emergencyRecharge ~= 0 then
        table.insert(texts, {ltext = string.format("Upon depletion: Recharges %i%% of your shield."%_t, rechargeAmount * 100)})
        table.insert(texts, {ltext = plural_t("This effect can only occur once every minute.", "This effect can only occur once every ${i} minutes.", round(rechargeDelay / 60))})
    end
    local techTexts = getLines(seed, tech)
    for i, v in pairs(techTexts) do
        table.insert(texts, v)   
    end
    return texts
end

function getComparableValues(seed, rarity)
    local base = {}
    local bonus = {}

    local baseDurability, baseRecharge, baseEmergencyRecharge = getBonuses(seed, rarity, false)
    local _, _, bonusEmergencyRecharge = getBonuses(seed, rarity, true)

    table.insert(base, {name = "Shield Durability"%_t, key = "durability", value = round(baseDurability * 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(base, {name = "Shield Recharge Rate"%_t, key = "recharge_rate", value = round(baseRecharge * 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(base, {name = "Recharge Upon Depletion"%_t, key = "recharge_on_depletion", value = 0, comp = UpgradeComparison.MoreIsBetter})

    table.insert(bonus, {name = "Shield Durability"%_t, key = "durability", value = round(baseDurability * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Shield Recharge Rate"%_t, key = "recharge_rate", value = round(baseRecharge * 0.5 * 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Recharge Upon Depletion"%_t, key = "recharge_on_depletion", value = bonusEmergencyRecharge, comp = UpgradeComparison.MoreIsBetter})

    return base, bonus
end
