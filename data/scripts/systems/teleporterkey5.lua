package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")

-- this key is dropped by the 4

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true
MissionRelevant = true

function getBonuses(seed, rarity)

    local energy = 0.3
    local recharge = 0.25
    local militarySlots = 2
    local arbitrarySlots = 1
    local civilSlots = 2
    local shields = 0.25

    local hsReach = 1.5
    local hsEnergy = -0.15

    local cargo = 0.3
    local velocity = 0.3

    local lootRange = 10
    local deepScan = 3
    local radar = 5

    return energy, recharge, militarySlots, arbitrarySlots, civilSlots, shields, hsReach, hsEnergy, cargo, velocity, lootRange, deepScan, radar
end

function onInstalled(seed, rarity, permanent)
    if not permanent then return end

    local energy, recharge, militarySlots, arbitrarySlots, civilSlots, shields, hsReach, hsEnergy, cargo, velocity, lootRange, deepScan, radar = getBonuses(seed, rarity)

    addBaseMultiplier(StatsBonuses.GeneratedEnergy, energy)
    addBaseMultiplier(StatsBonuses.BatteryRecharge, recharge)

    addAbsoluteBias(StatsBonuses.ArmedTurrets, militarySlots)
    addAbsoluteBias(StatsBonuses.ArbitraryTurrets, arbitrarySlots)
    addAbsoluteBias(StatsBonuses.UnarmedTurrets, civilSlots)

    addBaseMultiplier(StatsBonuses.ShieldDurability, shields)

    addAbsoluteBias(StatsBonuses.HyperspaceReach, hsReach)
    addBaseMultiplier(StatsBonuses.HyperspaceChargeEnergy, hsEnergy)

    addBaseMultiplier(StatsBonuses.CargoHold, cargo)

    addBaseMultiplier(StatsBonuses.Velocity, velocity)

    addAbsoluteBias(StatsBonuses.LootCollectionRange, lootRange)

    addAbsoluteBias(StatsBonuses.HiddenSectorRadarReach, deepScan)
    addAbsoluteBias(StatsBonuses.RadarReach, radar)

end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    return "XSTN-K V"%_t
end

function getBasicName()
    return "XSTN-K V"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/key5.png"
end

function getPrice(seed, rarity)
    return 10000
end

function getTooltipLines(seed, rarity, permanent)
    local energy, recharge, militarySlots, arbitrarySlots, civilSlots, shields, hsReach, hsEnergy, cargo, velocity, lootRange, deepScan, radar = getBonuses(seed, rarity)

    local texts =
    {
        {ltext = "Generated Energy"%_t, rtext = string.format("%+i%%", energy * 100), icon = "data/textures/icons/electric.png", boosted = permanent},
        {ltext = "Recharge Rate"%_t, rtext = string.format("%+i%%", recharge * 100), icon = "data/textures/icons/power-unit.png", boosted = permanent},

        {ltext = "Armed Turret Slots"%_t, rtext = "+" .. militarySlots, icon = "data/textures/icons/turret.png", boosted = permanent},
        {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. arbitrarySlots, icon = "data/textures/icons/turret.png", boosted = permanent},
        {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. civilSlots, icon = "data/textures/icons/turret.png", boosted = permanent},

        {ltext = "Shield Durability"%_t, rtext = string.format("%+i%%", shields * 100), icon = "data/textures/icons/health-normal.png", boosted = permanent},

        {ltext = "Jump Range"%_t, rtext = string.format("%+i", hsReach), icon = "data/textures/icons/star-cycle.png", boosted = permanent},
        {ltext = "Recharge Energy"%_t, rtext = string.format("%+i%%", hsEnergy * 100), icon = "data/textures/icons/electric.png", boosted = permanent},

        {ltext = "Cargo Hold"%_t, rtext = string.format("%+i%%", cargo * 100), icon = "data/textures/icons/crate.png", boosted = permanent},

        {ltext = "Velocity"%_t, rtext = string.format("%+i%%", velocity * 100), icon = "data/textures/icons/speedometer.png", boosted = permanent},

        {ltext = "Loot Collection Range"%_t, rtext = "+${distance} km"%_t % {distance = lootRange / 100}, icon = "data/textures/icons/sell.png", boosted = permanent},

        {ltext = "Deep Scan Range"%_t, rtext = string.format("%+i", deepScan), icon = "data/textures/icons/radar-sweep.png", boosted = permanent},
        {ltext = "Radar Range"%_t, rtext = string.format("%+i", radar), icon = "data/textures/icons/radar-sweep.png", boosted = permanent},

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
        {ltext = "When you can't decide what to upgrade."%_t, lcolor = ColorRGB(1, 0.5, 0.5)},
        {ltext = "", boosted = permanent},
        {ltext = "This system has 5 vertical /* continues with 'scratches on its surface.' */"%_t, rtext = "", icon = ""},
        {ltext = "scratches on its surface. /* continued from 'This system has 5 vertical' */"%_t, rtext = "", icon = ""}
    }
end
