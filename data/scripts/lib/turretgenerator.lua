package.path = package.path .. ";data/scripts/lib/?.lua"

include("galaxy")
include("randomext")
local WeaponGenerator = include ("weapongenerator")
include("weapontype")

local TurretGenerator =  {}

local generatorFunction = {}

function TurretGenerator.generateSeeded(seed, weaponType, dps, tech, rarity, material, coaxialAllowed)
    return TurretGenerator.generateTurret(Random(seed), weaponType, dps, tech, material, rarity, coaxialAllowed)
end

function TurretGenerator.generateTurret(rand, type, dps, tech, material, rarity, coaxialAllowed)
    if rarity == nil then
        local index = rand:getValueOfDistribution(32, 32, 16, 8, 4, 1)
        rarity = Rarity(index - 1)
    end

    if coaxialAllowed == nil then coaxialAllowed = true end

    return generatorFunction[type](rand, dps, tech, material, rarity, coaxialAllowed)
end


local scales = {}
scales[WeaponType.ChainGun] = {
    {from = 0, to = 15, size = 0.5, usedSlots = 1},
    {from = 16, to = 31, size = 1.0, usedSlots = 2},
    {from = 32, to = 52, size = 1.5, usedSlots = 3},
}

scales[WeaponType.PointDefenseChainGun] = {
    {from = 0, to = 52, size = 0.5, usedSlots = 1},
}

scales[WeaponType.PointDefenseLaser] = {
    {from = 0, to = 52, size = 0.5, usedSlots = 1},
}

scales[WeaponType.Bolter] = {
    {from = 0, to = 18, size = 0.5, usedSlots = 1},
    {from = 19, to = 33, size = 1.0, usedSlots = 2},
    {from = 34, to = 45, size = 1.5, usedSlots = 3},
    {from = 46, to = 52, size = 2.0, usedSlots = 4},
}

scales[WeaponType.Laser] = {
    {from = 0, to = 24, size = 0.5, usedSlots = 1},
    {from = 25, to = 35, size = 1.0, usedSlots = 2},
    {from = 36, to = 46, size = 1.5, usedSlots = 3},
    {from = 47, to = 49, size = 2.0, usedSlots = 4},
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

scales[WeaponType.MiningLaser] = {
    {from = 0, to = 12, size = 0.5, usedSlots = 1},
    {from = 13, to = 25, size = 1.0, usedSlots = 2},
    {from = 26, to = 35, size = 1.5, usedSlots = 3},
    {from = 36, to = 45, size = 2.5, usedSlots = 4},
    {from = 46, to = 52, size = 3.0, usedSlots = 5},
}
scales[WeaponType.RawMiningLaser] = scales[WeaponType.MiningLaser]

scales[WeaponType.SalvagingLaser] = {
    {from = 0, to = 12, size = 0.5, usedSlots = 1},
    {from = 13, to = 25, size = 1.0, usedSlots = 2},
    {from = 26, to = 35, size = 1.5, usedSlots = 3},
    {from = 36, to = 45, size = 2.5, usedSlots = 4},
    {from = 46, to = 52, size = 3.0, usedSlots = 5},
}
scales[WeaponType.RawSalvagingLaser] = scales[WeaponType.SalvagingLaser]

scales[WeaponType.PlasmaGun] = {
    {from = 0, to = 30, size = 0.5, usedSlots = 1},
    {from = 31, to = 39, size = 1.0, usedSlots = 2},
    {from = 40, to = 48, size = 1.5, usedSlots = 3},
    {from = 49, to = 52, size = 2.0, usedSlots = 4},
}

scales[WeaponType.RocketLauncher] = {
    {from = 0, to = 32, size = 1.0, usedSlots = 2},
    {from = 33, to = 40, size = 1.5, usedSlots = 3},
    {from = 41, to = 48, size = 2.0, usedSlots = 4},
    {from = 49, to = 52, size = 3.0, usedSlots = 5},
}

scales[WeaponType.Cannon] = {
    {from = 0, to = 28, size = 1.5, usedSlots = 3},
    {from = 29, to = 38, size = 2.0, usedSlots = 4},
    {from = 39, to = 49, size = 3.0, usedSlots = 5},
    --dummy for cooaxial, add 1 to size and level
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

scales[WeaponType.RailGun] = {
    {from = 0, to = 28, size = 1.0, usedSlots = 2},
    {from = 29, to = 35, size = 1.5, usedSlots = 3},
    {from = 36, to = 42, size = 2.0, usedSlots = 4},
    {from = 43, to = 49, size = 3.0, usedSlots = 5},
    --dummy for cooaxial, add 1 to size and level
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

scales[WeaponType.RepairBeam] = {
    {from = 0, to = 28, size = 0.5, usedSlots = 1},
    {from = 29, to = 40, size = 1.0, usedSlots = 2},
    {from = 41, to = 52, size = 1.5, usedSlots = 3},
}

scales[WeaponType.LightningGun] = {
    {from = 0, to = 36, size = 1.0, usedSlots = 2},
    {from = 37, to = 42, size = 1.5, usedSlots = 3},
    {from = 43, to = 46, size = 2.0, usedSlots = 4},
    {from = 47, to = 50, size = 3.0, usedSlots = 5},
    --dummy for cooaxial, add 1 to size and level
    {from = 51, to = 52, size = 3.5, usedSlots = 6},
}

scales[WeaponType.TeslaGun] = {
    {from = 0, to = 25, size = 0.5, usedSlots = 1},
    {from = 26, to = 36, size = 1.0, usedSlots = 2},
    {from = 37, to = 49, size = 1.5, usedSlots = 3},
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

scales[WeaponType.ForceGun] = {
    {from = 0, to = 15, size = 1.0, usedSlots = 2},
    {from = 16, to = 30, size = 2.0, usedSlots = 3},
    {from = 31, to = 44, size = 3.0, usedSlots = 4},
    {from = 45, to = 52, size = 4.0, usedSlots = 6},
}

scales[WeaponType.PulseCannon] = {
    {from = 0, to = 25, size = 0.5, usedSlots = 1},
    {from = 26, to = 36, size = 1.0, usedSlots = 2},
    {from = 37, to = 47, size = 1.5, usedSlots = 3},
    {from = 48, to = 52, size = 2.0, usedSlots = 4},
}

scales[WeaponType.AntiFighter] = {
    {from = 0, to = 52, size = 0.5, usedSlots = 1},
}


function TurretGenerator.dpsToRequiredCrew(dps)
    local value = math.floor(1 + (dps / 1400))
    value = value + math.min(4, math.floor(dps / 100))

    return value
end

function TurretGenerator.attachWeapons(rand, turret, weapon, numWeapons)
    turret:clearWeapons()

    local places = {TurretGenerator.createWeaponPlaces(rand, numWeapons)}

    for _, position in pairs(places) do
        weapon.localPosition = position * turret.size
        turret:addWeapon(weapon)
    end
end

function TurretGenerator.createWeaponPlaces(rand, numWeapons)
    if numWeapons == 1 then
        return vec3(0, 0, 0)

    elseif numWeapons == 2 then
        local case = rand:getInt(0, 1)
        local dist = rand:getFloat(0.1, 0.4)
        if case == 0 then
            return vec3(dist, 0, 0), vec3(-dist, 0, 0)
        else
            return vec3(0, dist + 0.2, 0), vec3(0, -dist + 0.2, 0)
        end

    elseif numWeapons == 3 then
        local case = rand:getInt(0, 1)
        if case == 0 then
            return vec3(0.4, 0, 0), vec3(0, 0.2, 0), vec3(-0.4, 0, 0)
        else
            return vec3(0.4, 0, 0), vec3(0, 0, 0), vec3(-0.4, 0, 0)
        end

    elseif numWeapons == 4 then
        return vec3(0.4, -0.2, 0), vec3(-0.4, 0.2, 0), vec3(0.4, 0.2, 0), vec3(-0.4, -0.2, 0)
    end
end

function TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)
    turret:updateStaticStats()

    local maxHeat = 10

    local coolingRate = maxHeat / coolingTime -- must be smaller than heating rate or the weapon will never overheat
    local heatDelta = maxHeat / shootingTime
    local heatingRate = heatDelta + coolingRate
    local heatPerShot = heatingRate / turret.firingsPerSecond

    turret.coolingType = CoolingType.Standard
    turret.maxHeat = maxHeat
    turret.heatPerShot = heatPerShot or 0
    turret.coolingRate = coolingRate or 0

end

function TurretGenerator.createBatteryChargeCooling(turret, rechargeTime, shootingTime)
    turret:updateStaticStats()

    local maxCharge
    if turret.dps > 0 then
        maxCharge = turret.dps * 10
    else
        maxCharge = 5
    end

    local rechargeRate = maxCharge / rechargeTime -- must be smaller than consumption rate or the weapon will never run out of energy
    local consumptionDelta = maxCharge / shootingTime
    local consumptionRate = consumptionDelta + rechargeRate

    local consumptionPerShot = consumptionRate / turret.firingsPerSecond

    turret.coolingType = CoolingType.BatteryCharge
    turret.maxHeat = maxCharge
    turret.heatPerShot = consumptionPerShot or 0
    turret.coolingRate = rechargeRate or 0
end

function TurretGenerator.scale(rand, turret, type, tech, turnSpeedFactor, coaxialPossible)
    if coaxialPossible == nil then coaxialPossible = true end -- avoid coaxialPossible = coaxialPossible or true, as it will set it to true if "false" is passed

    local scaleTech = tech
    if rand:test(0.5) then
        scaleTech = math.floor(math.max(1, scaleTech * rand:getFloat(0, 1)))
    end

    local scale, lvl = TurretGenerator.getScale(type, scaleTech)

    if coaxialPossible then
        turret.coaxial = (scale.usedSlots >= 5) and rand:test(0.25)
    else
        turret.coaxial = false
    end

    turret.size = scale.size
    turret.slots = scale.usedSlots
    turret.turningSpeed = lerp(turret.size, 0.5, 3, 1, 0.5) * rand:getFloat(0.8, 1.2) * turnSpeedFactor

    local coaxialDamageScale = turret.coaxial and 3 or 1

    local weapons = {turret:getWeapons()}
    for _, weapon in pairs(weapons) do
        weapon.localPosition = weapon.localPosition * scale.size

        if scale.usedSlots > 1 then
            -- scale damage, etc. linearly with amount of used slots
            if weapon.damage ~= 0 then
                weapon.damage = weapon.damage * scale.usedSlots * coaxialDamageScale
            end

            if weapon.hullRepair ~= 0 then
                weapon.hullRepair = weapon.hullRepair * scale.usedSlots * coaxialDamageScale
            end

            if weapon.shieldRepair ~= 0 then
                weapon.shieldRepair = weapon.shieldRepair * scale.usedSlots * coaxialDamageScale
            end

            if weapon.selfForce ~= 0 then
                weapon.selfForce = weapon.selfForce * scale.usedSlots * coaxialDamageScale
            end

            if weapon.otherForce ~= 0 then
                weapon.otherForce = weapon.otherForce * scale.usedSlots * coaxialDamageScale
            end

            if weapon.holdingForce ~= 0 then
                weapon.holdingForce = weapon.holdingForce * scale.usedSlots * coaxialDamageScale
            end

            local increase = 0
            if type == WeaponType.MiningLaser or type == WeaponType.SalvagingLaser then
                -- mining and salvaging laser reach is scaled more
                increase = (scale.size + 0.5) - 1
            else
                -- scale reach a little
                increase = (scale.usedSlots - 1) * 0.15
            end

            weapon.reach = weapon.reach * (1 + increase)

            local shotSizeFactor = scale.size * 2
            if weapon.isProjectile then
                local velocityIncrease = (scale.usedSlots - 1) * 0.25

                weapon.psize = weapon.psize * shotSizeFactor
                weapon.pvelocity = weapon.pvelocity * (1 + velocityIncrease)
            end
            if weapon.isBeam then weapon.bwidth = weapon.bwidth * shotSizeFactor end
        end
    end

    turret:clearWeapons()
    for _, weapon in pairs(weapons) do
        turret:addWeapon(weapon)
    end

    return lvl
end

function TurretGenerator.getScale(type, tech)
    for lvl, scale in pairs(scales[type]) do
        if tech >= scale.from and tech <= scale.to then return scale, lvl end
    end

    return {from = 0, to = 0, size = 1, usedSlots = 1}
end


local i = 0
local function c() i = i + 1 return i end

local Specialty =
{
    HighDamage = c(),
    HighRange = c(),
    HighFireRate = c(),
    HighAccuracy = c(),
    BurstFireEnergy = c(),
    BurstFire = c(),
    HighEfficiency = c(), -- only applicable to salvage and mining laser
    HighShootingTime = c(),
    LessEnergyConsumption = c(),
    IonizedProjectile = c(),
}

i = nil
c = nil

TurretGenerator.Specialty = Specialty

local possibleSpecialties = {}
possibleSpecialties[WeaponType.Laser] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.25},
    {specialty = Specialty.HighRange, probability = 0.2},
}

possibleSpecialties[WeaponType.TeslaGun] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.2},
    {specialty = Specialty.HighRange, probability = 0.1},
}

possibleSpecialties[WeaponType.LightningGun] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.15},
    {specialty = Specialty.HighDamage, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.2},
    {specialty = Specialty.HighFireRate, probability = 0.2},
    {specialty = Specialty.HighAccuracy, probability = 0.15},
}

possibleSpecialties[WeaponType.MiningLaser] = {
    {specialty = Specialty.HighEfficiency, probability = 0.3},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
}
possibleSpecialties[WeaponType.RawMiningLaser] = possibleSpecialties[WeaponType.MiningLaser]

possibleSpecialties[WeaponType.SalvagingLaser] = {
    {specialty = Specialty.HighEfficiency, probability = 0.3},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
}
possibleSpecialties[WeaponType.RawSalvagingLaser] = possibleSpecialties[WeaponType.SalvagingLaser]

possibleSpecialties[WeaponType.RepairBeam] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.2},
    {specialty = Specialty.HighRange, probability = 0.1},
}

possibleSpecialties[WeaponType.PlasmaGun] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighFireRate, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.HighAccuracy, probability = 0.1},
    {specialty = Specialty.BurstFireEnergy, probability = 0.1},
}

possibleSpecialties[WeaponType.Cannon] = {
    {specialty = Specialty.HighShootingTime, probability = 0.2},
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighAccuracy, probability = 0.1},
}

possibleSpecialties[WeaponType.ChainGun] = {
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.IonizedProjectile, probability = 0.05},
    {specialty = Specialty.HighFireRate, probability = 0.2},
    {specialty = Specialty.HighAccuracy, probability = 0.2},
    {specialty = Specialty.BurstFire, probability = 0.1},
}

possibleSpecialties[WeaponType.PointDefenseChainGun] = {
    {specialty = Specialty.HighRange, probability = 0.1},
}

possibleSpecialties[WeaponType.PointDefenseLaser] = {
    {specialty = Specialty.HighRange, probability = 0.1},
}

possibleSpecialties[WeaponType.Bolter] = {
    {specialty = Specialty.HighShootingTime, probability = 0.25},
    {specialty = Specialty.HighFireRate, probability = 0.15},
    {specialty = Specialty.HighAccuracy, probability = 0.15},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.BurstFire, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.1},
}

possibleSpecialties[WeaponType.RailGun] = {
    {specialty = Specialty.HighShootingTime, probability = 0.25},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.25},
    {specialty = Specialty.HighAccuracy, probability = 0.25},
    {specialty = Specialty.HighFireRate, probability = 0.10},
}

possibleSpecialties[WeaponType.RocketLauncher] = {
    {specialty = Specialty.HighShootingTime, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.15},
    {specialty = Specialty.HighFireRate, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.25},
    {specialty = Specialty.BurstFire, probability = 0.1},
}

possibleSpecialties[WeaponType.ForceGun] = {
    {specialty = Specialty.HighRange, probability = 0.2},
}

possibleSpecialties[WeaponType.PulseCannon] = {
    {specialty = Specialty.HighShootingTime, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.15},
    {specialty = Specialty.HighFireRate, probability = 0.15},
    {specialty = Specialty.HighAccuracy, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.15},
    {specialty = Specialty.BurstFire, probability = 0.3},
}

possibleSpecialties[WeaponType.AntiFighter] = {
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.HighFireRate, probability = 0.1},
    {specialty = Specialty.HighDamage, probability = 0.1},
}

-- customSpecialties needs to be a table or nil
function TurretGenerator.addSpecialties(rand, turret, type, customSpecialties, forbiddenSpecialties)

    customSpecialties = customSpecialties or {}
    forbiddenSpecialties = forbiddenSpecialties or {}

    turret:updateStaticStats()

    local simultaneousShootingProbability = 0

    local specialties = {}

    if type == WeaponType.TeslaGun then
        simultaneousShootingProbability = 0.15

    elseif type == WeaponType.LightningGun then
        simultaneousShootingProbability = 0.15

    elseif type == WeaponType.PlasmaGun then
        simultaneousShootingProbability = 0.25

    elseif type == WeaponType.Cannon then
        simultaneousShootingProbability = 0.5

    elseif type == WeaponType.ChainGun then
        simultaneousShootingProbability = 0.25

    elseif type == WeaponType.RailGun then
        simultaneousShootingProbability = 0.25

    elseif type == WeaponType.RocketLauncher then
        simultaneousShootingProbability = 0.5

    elseif type == WeaponType.PulseCannon then
        simultaneousShootingProbability = 0.25
    end

    local firstWeapon = turret:getWeapons()
    -- select specialties from possible specialties by their probability
    for _, s in pairs(possibleSpecialties[type]) do
        if forbiddenSpecialties[s.specialty] then goto continue end

        if rand:test(s.probability * (firstWeapon.rarity.value + 0.2)) then
            specialties[s.specialty] = true
        end

        ::continue::
    end

    local maxNumSpecialties = rand:getInt(0, 1 + math.ceil(firstWeapon.rarity.value / 2)) -- round to zero

    -- reduce max num specialties possible by amount of custom specialties
    maxNumSpecialties = maxNumSpecialties - tablelength(customSpecialties)

    -- restrict amount of specialties to maxNumSpecialties
    if tablelength(specialties) > maxNumSpecialties then
        local linear = {}
        for specialty, _ in pairs(specialties) do
            table.insert(linear, specialty)
        end

        specialties = {}
        for i = 1, maxNumSpecialties do
            local specialty = randomEntry(rand, linear)
            specialties[specialty] = true
        end
    end

    -- pulse cannons always have ionized projectiles
    if type == WeaponType.PulseCannon then
        if not forbiddenSpecialties[Specialty.IonizedProjectile] then
            specialties[Specialty.IonizedProjectile] = true
        end
    end

    for specialty, _ in pairs(customSpecialties) do
        specialties[specialty] = true
    end

    if rand:test(simultaneousShootingProbability) then
        turret.simultaneousShooting = true
    end

    -- these values mark the variation of strength that a randomly generated weapon may have.
    local baseVariation = rand:getFloat(1.0, 1.1)
    local damageVariation = baseVariation
    local baseDamage = 1.0

    local descriptions = {}

    -- this is a random number between 0.01 and 1, with a tendency to be higher when the rarity is higher
    local rarityFactor = math.max(0.01, rand:getFloat(0, turret.rarity.value / HighestRarity().value))
    rarityFactor = lerp(turret.rarity.value, LowestRarity().value, HighestRarity().value, 0.01, 0.9) + rand:getFloat(0, 0.1)

    local weapons = {turret:getWeapons()}
    for s, _ in pairs(specialties) do

        if s == Specialty.HighDamage then
            local maxIncrease = 0.4
            local increase = 0.1 + rarityFactor * maxIncrease
            damageVariation = damageVariation + increase

        elseif s == Specialty.HighAccuracy then
            local maxIncrease = 0.8
            local increase = 0.1 + rarityFactor * maxIncrease

            for _, weapon in pairs(weapons) do
                weapon.accuracy = lerp(increase, 0, 1, weapon.accuracy, 0.999)
            end

            local addition = round(increase * 100)
            -- turret:addDescription("%s%% Fire Rate"%_T, string.format("%+i", addition))
            descriptions["Accuracy"] = {priority = 1, str = "%s%% Accuracy"%_T, value = string.format("%+i", addition)}

        elseif s == Specialty.HighFireRate then
            local maxIncrease = 0.4
            local increase = 0.1 + rarityFactor * maxIncrease

            for _, weapon in pairs(weapons) do
                weapon.fireRate = weapon.fireRate * (1 + increase)
            end

            local addition = round(increase * 100)
            -- turret:addDescription("%s%% Fire Rate"%_T, string.format("%+i", addition))
            descriptions["FireRate"] = {priority = 1, str = "%s%% Fire Rate"%_T, value = string.format("%+i", addition)}

        elseif s == Specialty.HighRange then
            local maxIncrease = 0.4
            local increase = 0.1 + rarityFactor * maxIncrease

            for _, weapon in pairs(weapons) do
                weapon.reach = weapon.reach * (1 + increase)
            end

            local addition = round(increase * 100)
            --turret:addDescription("%s%% Range"%_T, string.format("%+i", addition))
            descriptions["Range"] = {priority = 2, str = "%s%% Range"%_T, value = string.format("%+i", addition)}

        elseif s == Specialty.HighEfficiency then
            local maxIncrease = 0.4
            local increase = 0.1 + rarityFactor * maxIncrease

            for _, weapon in pairs(weapons) do
                if weapon.stoneRefinedEfficiency ~= 0 then
                    weapon.stoneRefinedEfficiency = math.min(0.9, weapon.stoneRefinedEfficiency * (1 + increase))
                end

                if weapon.metalRefinedEfficiency ~= 0 then
                    weapon.metalRefinedEfficiency = math.min(0.9, weapon.metalRefinedEfficiency * (1 + increase))
                end

                if weapon.stoneRawEfficiency ~= 0 then
                    weapon.stoneRawEfficiency = math.min(0.9, weapon.stoneRawEfficiency * (1 + increase))
                end

                if weapon.metalRawEfficiency ~= 0 then
                    weapon.metalRawEfficiency = math.min(0.9, weapon.metalRawEfficiency * (1 + increase))
                end
            end

            local addition = round(increase * 100)
            -- turret:addDescription("%s%% Efficiency"%_T, string.format("%+i", addition))
            descriptions["Efficiency"] = {priority = 3, str = "%s%% Efficiency"%_T, value = string.format("%+i", addition)}

        elseif s == Specialty.HighShootingTime then
            local maxIncrease = 2.9
            local increase = 0.1 + rarityFactor * maxIncrease

            local coolingTime = turret.coolingTime
            local shootingTime = turret.shootingTime

            shootingTime = shootingTime * (1 + increase)

            turret:clearWeapons()
            for _, weapon in pairs(weapons) do
                turret:addWeapon(weapon)
            end

            TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)

            weapons = {turret:getWeapons()}

            local percentage = round(increase * 100)
            -- turret:addDescription("%s%% Shooting Until Overheated"%_T, string.format("%+i", percentage))
            descriptions["ShootUntilOverheated"] = {priority = 4, str = "%s%% Shooting Until Overheated"%_T, value = string.format("%+i", percentage)}

        elseif s == Specialty.LessEnergyConsumption then
            local maxDecrease = 0.6
            local decrease = 0.1 + rarityFactor * maxDecrease

            local rechargeTime = turret.coolingTime
            local shootingTime = turret.shootingTime

            rechargeTime = rechargeTime * (1 - decrease)

            turret:clearWeapons()
            for _, weapon in pairs(weapons) do
                turret:addWeapon(weapon)
            end

            TurretGenerator.createBatteryChargeCooling(turret, rechargeTime, shootingTime)

            weapons = {turret:getWeapons()}

            local percentage = round(decrease * 100)
            -- turret:addDescription("%s%% Less Energy Consumption"%_T, string.format("%+i", percentage))
            descriptions["LessEnergy"] = {priority = 5, str = "%s%% Less Energy Consumption"%_T, value = string.format("%+i", percentage)}

        elseif s == Specialty.BurstFire then
            local fireRate = turret.fireRate
            local fireDelay = 1 / fireRate

            local increase = rand:getFloat(2, 3)
            fireRate = math.max(fireRate * increase, 6)

            local coolingTime = fireRate * fireDelay

            for _, weapon in pairs(weapons) do
                weapon.fireRate = fireRate / turret.numWeapons
            end

            turret:clearWeapons()
            for _, weapon in pairs(weapons) do
                turret:addWeapon(weapon)
            end

            -- time: 1 second
            TurretGenerator.createStandardCooling(turret, coolingTime, 1)

            weapons = {turret:getWeapons()}

        elseif s == Specialty.BurstFireEnergy then
            local fireRate = turret.fireRate
            local fireDelay = 1 / fireRate

            local increase = rand:getFloat(2, 3)
            fireRate = math.max(fireRate * increase, 6)

            local rechargeTime = fireRate * fireDelay

            for _, weapon in pairs(weapons) do
                weapon.fireRate = fireRate / turret.numWeapons
            end

            turret:clearWeapons()
            for _, weapon in pairs(weapons) do
                turret:addWeapon(weapon)
            end

            -- time: 1 second
            TurretGenerator.createBatteryChargeCooling(turret, rechargeTime, 1)

            weapons = {turret:getWeapons()}

        elseif s == Specialty.IonizedProjectile then
            local chance = rand:getFloat(0.1, 0.25)

            if type == WeaponType.PulseCannon then
                chance = rand:getFloat(0.7, 0.8)

                local varChance = 1 - chance
                chance = chance + rarityFactor * varChance
            end

            for _, weapon in pairs(weapons) do
                weapon.shieldPenetration = chance
            end

            local percentage = round(chance * 100)
            -- turret:addDescription("Ionized Projectiles"%_T, "")
            -- turret:addDescription("%s%% Chance of penetrating shields"%_T, string.format("%i", percentage))
            descriptions["IonizedProjectiles"] = {priority = 6, str = "Ionized Projectiles"%_T}
            descriptions["ShieldPen"] = {priority = 6.1, str = "%s%% Chance of penetrating shields"%_T, value = string.format("%+i", percentage)}
        end
    end

    -- do damage last as it depends on multiple factors
    for _, weapon in pairs(weapons) do
        if weapon.damage ~= 0 then
            weapon.damage = weapon.damage * damageVariation

            local addition = round((damageVariation - baseDamage) * 100)
            if addition >= 5 or addition <= -5 then
                -- turret:addDescription("%s%% Damage"%_T, string.format("%+i", addition))
                descriptions["Damage"] = {priority = 0, str = "%s%% Damage"%_T, value = string.format("%+i", addition)}
            end
        end

        if weapon.shieldRepair ~= 0 then weapon.shieldRepair = weapon.shieldRepair * baseVariation end
        if weapon.hullRepair ~= 0 then weapon.hullRepair = weapon.hullRepair * baseVariation end
    end

    turret:clearWeapons()
    for _, weapon in pairs(weapons) do
        turret:addWeapon(weapon)
    end

    -- sort descriptions and add to turret
    local sortedDescriptions = {}
    for _, desc in pairs(descriptions) do
        table.insert(sortedDescriptions, desc)
    end

    table.sort(sortedDescriptions, function(a, b) return a.priority < b.priority end)

    for _, desc in pairs(sortedDescriptions) do
        turret:addDescription(desc.str or "", desc.value or "")
    end

    return specialties
end

--[[
Adjectives:
- HighDamage = Fierce
- HighRange = Long Range
- HighFireRate = Rapid
- HighAccuracy = Precise
- BurstFireEnergy = Bursting
- BurstFire = Bursting
- HighEfficiency = Efficient
- HighShootingTime = Enduring
- LessEnergyConsumption = Economical
- IonizedProjectile = Ion, Ionized

- Seeker: Seeking
- Mine/Salvage Lasers: Refining, Raw

- Anti-Matter: Dissolving
- Plasma: Plasmatic
- Electro: Electric, E-
- Energy: Energy
- Physical: Grounded
- Fragments: ?

- 2x Shot: Double
- 3x Shot: Triple
- 4x Shot: Quad

- 2x Barrel: Dual
- 3x Barrel: Triple
- 4x Barrel: Quad

]]

--[[

Synonyms:

- [done] Force Gun
- [done] Force Cannon
Push:
- [done] Pusher
- [done] Thruster
- [done] Shover
Pull:
- [done] Attractor
- [done] Tower
- [done] Puller

- [done] Lightning Gun
- [done] Lightning Cannon
- [done] Thunder
- [done] Lightning
- [done] Tesla Gun
- [done] Tesla Cannon
- [done] Shocker
- [done] Electrifier
- [done] Energizer
- [done] Volter

- [done] Repair Beam
- [done] Repair Laser
- [done] Repairer
- [done] Restorer
- [done] Restoration Beam
- [done] Renovator

- [done] Railgun
- [done] Annihilator
- [done] Devastator
- [done] Impaler

- [done] Mining Laser
- [done] Miner
- [done] Excavator
- [done] Digger
- [done] Extractor
- [done] Unearther
- [done] Delver

- [done] Salvaging Laser
- [done] Salvager
- [done] Reclaimer
- [done] Extractor
- [done] Retriever

- [done] PDC
- [done] PDL

- [done] Laser
- [done] Igniter
- [done] Beamer
- [done] Blazer
- [done] Torcher
- [done] Scorcher

- [done] Chain Gun
- [done] Minigun
- [done] Gatling
- [done] Gatling Gun
- [done] Stinger
- [done] Sprayer
- [done] Plasma Gun
- [done] Plasma Cannon
- [done] Nova
- [done] Sol

- [done] Pulse Gun
- [done] Pulse Cannon
- [done] Pulsar
- [done] Quasar
- [done] Meteor
- [done] Intruder

- [done] Launcher
- [done] Missile Launcher
- [done] Rocket Launcher
- [done] Rocket Phalanx
- [done] Missile Phalanx
- [done] Rocket Battery
- [done] Missile Battery
- [done] Ruiner

- [done] Cannon
- [done] Mortar
- [done] Artillery
- [done] Artillery Gun
- [done] Artillery Cannon


- OPEN:
- Bazooka
- Striker
- Ravager
- RPG
- Destroyer
- Exploder
- Destructor
- Biter
- Eradicator
- Smasher
- Lighter
- Nexus
- Burrower
- Defender
- Repeller
- Clearer
- Deflector
- Ward
- Flak
- Defender
- Flakker
- Anti-Fighter
- Anti-Fighter
- Nebula
- Sun
- Aurora
- Cosmos
- Eclipse
- Mender
- Stunner
- Paralyzer

]]

local function getSpecialtyAdjective(rand, specialties)

    -- HighDamage = Fierce
    -- HighRange = Long Range
    -- HighFireRate = Rapid
    -- HighAccuracy = Precise
    -- BurstFireEnergy = Bursting
    -- BurstFire = Bursting
    -- HighEfficiency = Efficient
    -- HighShootingTime = Enduring
    -- LessEnergyConsumption = Economical
    -- IonizedProjectile = Ion, Ionized

    if specialties[Specialty.IonizedProjectile] then
        specialties[Specialty.IonizedProjectile] = nil
        return "Ionized  /* weapon adjective */"%_T, Specialty.IonizedProjectile

    elseif specialties[Specialty.HighFireRate] then
        specialties[Specialty.HighFireRate] = nil
        return "Rapid  /* weapon adjective */"%_T, Specialty.HighFireRate

    elseif specialties[Specialty.HighRange] then
        specialties[Specialty.HighRange] = nil
        return "Long-Range  /* weapon adjective */"%_T, Specialty.HighRange

    elseif specialties[Specialty.BurstFireEnergy] then
        specialties[Specialty.BurstFireEnergy] = nil
        return "Bursting  /* weapon adjective */"%_T, Specialty.BurstFireEnergy

    elseif specialties[Specialty.BurstFire] then
        specialties[Specialty.BurstFire] = nil
        return "Bursting  /* weapon adjective */"%_T, Specialty.BurstFire

    elseif specialties[Specialty.HighAccuracy] then
        specialties[Specialty.HighAccuracy] = nil
        return "Precise  /* weapon adjective */"%_T, Specialty.HighAccuracy

    elseif specialties[Specialty.HighDamage] then
        specialties[Specialty.HighDamage] = nil
        return "Fierce  /* weapon adjective */"%_T, Specialty.HighDamage

    elseif specialties[Specialty.HighEfficiency] then
        specialties[Specialty.HighEfficiency] = nil
        return "Efficient  /* weapon adjective */"%_T, Specialty.HighEfficiency

    elseif specialties[Specialty.HighShootingTime] then
        specialties[Specialty.HighShootingTime] = nil
        return "Enduring  /* weapon adjective */"%_T, Specialty.HighShootingTime

    elseif specialties[Specialty.LessEnergyConsumption] then
        specialties[Specialty.LessEnergyConsumption] = nil
        return "Economical  /* weapon adjective */"%_T, Specialty.LessEnergyConsumption

    end

    return "", nil
end

local rarityAdjectives = {}
rarityAdjectives[RarityType.Petty] = {"Battered  /* weapon adjective */"%_T, "Decaying  /* weapon adjective */"%_T, "Derelict  /* weapon adjective */"%_T}
rarityAdjectives[RarityType.Common] = {"Standard  /* weapon adjective */"%_T, "Regular  /* weapon adjective */"%_T}
rarityAdjectives[RarityType.Uncommon] = {"Quality  /* weapon adjective */"%_T, "Reliable  /* weapon adjective */"%_T}
rarityAdjectives[RarityType.Rare] = {"Fine  /* weapon adjective */"%_T, "Flawless  /* weapon adjective */"%_T}
rarityAdjectives[RarityType.Exceptional] = {"Elite  /* weapon adjective */"%_T, "Superior  /* weapon adjective */"%_T}
rarityAdjectives[RarityType.Exotic] = {"Premium  /* weapon adjective */"%_T, "Prime  /* weapon adjective */"%_T}
rarityAdjectives[RarityType.Legendary] = {"S-Tier  /* weapon adjective */"%_T, "Master  /* weapon adjective */"%_T, "Stellar  /* weapon adjective */"%_T}

local function getRarityAdjective(rand, rarity)
    return randomEntry(rand, rarityAdjectives[rarity.value])
end

local function getBarrelAdjective(rand, turret)
    local barrel = ""
    local multishot = ""
    if turret.shotsPerFiring > 1 then
        if turret.shotsPerFiring == 2 then
            multishot = randomEntry(rand, {"Bi- /* weapon 'barrel' name part */"%_T})
        elseif turret.shotsPerFiring == 3 then
            multishot = randomEntry(rand, {"Tri- /* weapon 'barrel' name part */"%_T})
        elseif turret.shotsPerFiring == 4 then
            multishot = randomEntry(rand, {"Quad- /* weapon 'barrel' name part */"%_T})
        elseif turret.shotsPerFiring > 4 then
            multishot = randomEntry(rand, {"Shotgun- /* weapon 'barrel' name part */"%_T})
        end
    else
        if turret.numVisibleWeapons == 2 then
            barrel = randomEntry(rand, {"Dual  /* weapon 'barrel' name part */"%_T, "Double  /* weapon 'barrel' name part */"%_T})
        elseif turret.numVisibleWeapons == 3 then
            barrel = randomEntry(rand, {"Triple  /* weapon 'barrel' name part */"%_T})
        elseif turret.numVisibleWeapons == 4 then
            barrel = randomEntry(rand, {"Quadra  /* weapon 'barrel' name part */"%_T})
        elseif turret.numVisibleWeapons > 4 then
            barrel = randomEntry(rand, {"Multi  /* weapon 'barrel' name part */"%_T})
        end
    end

    return barrel, multishot
end

local function getDamageTypeAdjective(rand, turret, default)

    if turret.damageType == default then return "" end

    if turret.damageType == DamageType.AntiMatter then
        return randomEntry(rand, {"Anti- /* weapon damage type adjective */"%_T, "Nullifying  /* weapon damage type adjective */"%_T})
    elseif turret.damageType == DamageType.Plasma then
        return randomEntry(rand, {"Plasmatic  /* weapon damage type adjective */"%_T})
    elseif turret.damageType == DamageType.Fragments then
        return randomEntry(rand, {"Frag- /* weapon damage type adjective */"%_T})
    elseif turret.damageType == DamageType.Electric then
        return randomEntry(rand, {"E- /* electro weapon damage type adjective */"%_T, "Electric  /* weapon damage type adjective */"%_T})
    elseif turret.damageType == DamageType.Physical then
        return randomEntry(rand, {"Grounded  /* physical weapon damage type adjective */"%_T})
    elseif turret.damageType == DamageType.Energy then
        return randomEntry(rand, {"Energetic  /* energy weapon damage type adjective */"%_T, "Energy  /* energy weapon damage type adjective */"%_T})
    end

    return ""
end

local function makeSerialFromSpecialties(specialties, prefix)
    local serial = ""

    if specialties[Specialty.IonizedProjectile] then serial = serial .. "I" end
    if specialties[Specialty.HighDamage] then serial = serial .. "D" end
    if specialties[Specialty.HighRange] then serial = serial .. "R" end
    if specialties[Specialty.HighFireRate] then serial = serial .. "F" end
    if specialties[Specialty.HighAccuracy] then serial = serial .. "P" end
    if specialties[Specialty.BurstFireEnergy] then serial = serial .. "B" end
    if specialties[Specialty.BurstFire] then serial = serial .. "B" end
    if specialties[Specialty.HighEfficiency] then serial = serial .. "E" end
    if specialties[Specialty.HighShootingTime] then serial = serial .. "X" end
    if specialties[Specialty.LessEnergyConsumption] then serial = serial .. "3" end

    if serial ~= "" then serial = " " .. prefix .. serial end

    return serial
end

local function makeTitleParts(rand, specialties, turret, defaultDamageType)

    local dmgAdjective = getDamageTypeAdjective(rand, turret, defaultDamageType)
    local outerAdjective = ""

    if dmgAdjective == "" then
        outerAdjective, specialty = getSpecialtyAdjective(rand, specialties)
    end

    if dmgAdjective == "" and outerAdjective == "" then
        outerAdjective = getRarityAdjective(rand, turret.rarity)
    end

    local barrel, multishot = getBarrelAdjective(rand, turret)

    local coax = ""
    if turret.coaxial then
        coax = randomEntry(rand, {"Coax  /* weapon 'coax' name part */"%_T, "Coaxial  /* weapon 'coax' name part */"%_T})
    end

    local serial = makeSerialFromSpecialties(specialties, "T-")

    return dmgAdjective, outerAdjective, barrel, multishot, coax, serial
end


function TurretGenerator.generateBolterTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local weapons = {1, 2, 4}
    local numWeapons = weapons[rand:getInt(1, #weapons)]

    local weapon = WeaponGenerator.generateBolter(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local shootingTime = 7 * rand:getFloat(0.9, 1.3)
    local coolingTime = 5 * rand:getFloat(0.8, 1.2)

    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    -- adjust damage since bolters' DPS only decreases with cooling introduced
    -- bolters have no other damage boost like rockets, cannons or railguns
    local weapons = {result:getWeapons()}
    result:clearWeapons()
    for _, weapon in pairs(weapons) do
        weapon.damage = weapon.damage * ((coolingTime + shootingTime) / shootingTime)
        result:addWeapon(weapon)
    end

    local scaleLevel = TurretGenerator.scale(rand, result, WeaponType.Bolter, tech, 0.7, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.Bolter)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Bolter /* weapon name */"%_T
    if result.shotsPerFiring > 1 then
        name = "Thumper /* weapon name */"%_T
    elseif specialties[Specialty.HighDamage] and specialties[Specialty.BurstFire] then
        name = "Burster /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.BurstFire] = nil
    elseif specialties[Specialty.HighDamage] then
        name = "Blaster /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
    elseif specialties[Specialty.HighFireRate] then
        name = "Shooter /* weapon name */"%_T
        specialties[Specialty.HighFireRate] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.AntiMatter)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Bolter T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateChaingunTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generateChaingun(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    -- chainguns don't need cooling
    local scaleLevel = TurretGenerator.scale(rand, result, WeaponType.ChainGun, tech, 1, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.ChainGun)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Chaingun /* weapon name */"%_T
    if result.shotsPerFiring > 1 then
        name = "Sprayer /* weapon name */"%_T
    elseif specialties[Specialty.HighDamage] and specialties[Specialty.HighFireRate] then
        name = randomEntry(rand, {"Gatling /* weapon name */"%_T, "Gatling Gun/* weapon name */"%_T})
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighFireRate] = nil
    elseif specialties[Specialty.HighDamage] then
        name = "Stinger /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
    elseif specialties[Specialty.HighFireRate] then
        name = "Minigun /* weapon name */"%_T
        specialties[Specialty.HighFireRate] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Physical)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Chaingun T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generatePointDefenseChaingunTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(2, 3)

    local weapon = WeaponGenerator.generatePointDefenseChaingun(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    -- chainguns don't need cooling
    local scaleLevel = TurretGenerator.scale(rand, result, WeaponType.PointDefenseChainGun, tech, 2, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.PointDefenseChainGun)

    result.slotType = TurretSlotType.PointDefense
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Point Defense Cannon /* weapon name */"%_T
    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Fragments)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-PDC T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateLaserTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateLaser(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)
    local scaleLevel = TurretGenerator.scale(rand, result, WeaponType.Laser, tech, 0.75, coaxialAllowed)

    local rechargeTime = 30 * rand:getFloat(0.8, 1.2)
    local shootingTime = 20 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.Laser)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Laser /* weapon name */"%_T
    if result.slots == 2 then name = "Beamer /* weapon name */"%_T
    elseif result.slots == 3 then name = "Igniter /* weapon name */"%_T
    elseif result.slots == 4 then name = "Blazer /* weapon name */"%_T
    elseif result.slots >= 5 then name = "Torcher /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] then
        name = "Scorcher /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Energy)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Laser T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generatePointDefenseLaserTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = 1

    local weapon = WeaponGenerator.generatePointDefenseLaser(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    -- chainguns don't need cooling
    local scaleLevel = TurretGenerator.scale(rand, result, WeaponType.PointDefenseLaser, tech, 2, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.PointDefenseLaser)

    result.slotType = TurretSlotType.PointDefense
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Point Defense Laser /* weapon name */"%_T
    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Fragments)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-PDL T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateMiningTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Miner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateMiningLaser(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local percentage = math.floor(weapon.stoneDamageMultiplier * 100)
    result:addDescription("%s%% Damage to Stone"%_T, string.format("%+i", percentage))

    -- normal mining lasers don't need cooling
    -- mining laser can't be coaxial
    TurretGenerator.scale(rand, result, WeaponType.MiningLaser, tech, 0.8, false)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.MiningLaser)

    result.slotType = TurretSlotType.Unarmed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Purifying Mining Laser /* weapon name */"%_T
    if result.slots == 2 then name = "Purifying Miner /* weapon name */"%_T
    elseif result.slots == 3 then name = "Purifying Digger /* weapon name */"%_T
    elseif result.slots == 4 then name = "Purifying Unearther /* weapon name */"%_T
    elseif result.slots >= 5 then name = "Purifying Prospector /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] then
        name = "Extractor /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Energy)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Purifying Mining Laser T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateSalvagingTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Miner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateSalvagingLaser(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    -- normal salvaging lasers don't need cooling
    -- salvaging laser can't be coaxial
    TurretGenerator.scale(rand, result, WeaponType.SalvagingLaser, tech, 0.8, false)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.SalvagingLaser)

    result.slotType = TurretSlotType.Unarmed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Purifying Salvaging Laser /* weapon name */"%_T
    if result.slots == 2 then name = "Purifying Salvager /* weapon name */"%_T
    elseif result.slots == 3 then name = "Purifying Reclaimer /* weapon name */"%_T
    elseif result.slots == 4 then name = "Purifying Extractor /* weapon name */"%_T
    elseif result.slots >= 5 then name = "Purifying Retriever /* weapon name */"%_T end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Energy)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Purifying Salvaging T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateRawMiningTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Miner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateRawMiningLaser(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local percentage = math.floor(weapon.stoneDamageMultiplier * 100)
    result:addDescription("%s%% Damage to Stone"%_T, string.format("%+i", percentage))

    -- normal mining lasers don't need cooling
    -- mining laser can't be coaxial
    TurretGenerator.scale(rand, result, WeaponType.RawMiningLaser, tech, 0.8, false)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.RawMiningLaser)

    result.slotType = TurretSlotType.Unarmed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "R-Mining Laser /* weapon name */"%_T
    if result.slots == 2 then name = "R-Miner /* weapon name */"%_T
    elseif result.slots == 3 then name = "R-Delver /* weapon name */"%_T
    elseif result.slots == 4 then name = "R-Driller /* weapon name */"%_T
    elseif result.slots >= 5 then name = "R-Excavator /* weapon name */"%_T end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Energy)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-R-Mining Laser T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateRawSalvagingTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Miner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateRawSalvagingLaser(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    -- normal salvaging lasers don't need cooling
    -- salvaging laser can't be coaxial
    TurretGenerator.scale(rand, result, WeaponType.RawSalvagingLaser, tech, 0.8, false)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.RawSalvagingLaser)

    result.slotType = TurretSlotType.Unarmed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "R-Salvaging Laser /* weapon name */"%_T
    if result.slots == 2 then name = "R-Salvager /* weapon name */"%_T
    elseif result.slots == 3 then name = "R-Disassembler /* weapon name */"%_T
    elseif result.slots == 4 then name = "R-Dismantler /* weapon name */"%_T
    elseif result.slots >= 5 then name = "R-Deconstructor /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] then
        name = "R-Demolisher /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Energy)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-R-Salvaging T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generatePlasmaTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 4)

    local weapon = WeaponGenerator.generatePlasmaGun(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local rechargeTime = 20 * rand:getFloat(0.8, 1.2)
    local shootingTime = 15 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    -- add further descriptions
    TurretGenerator.scale(rand, result, WeaponType.PlasmaGun, tech, 0.7, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.PlasmaGun)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Plasma Gun /* weapon name */"%_T
    if result.slots == 2 then name = "Plasma Cannon /* weapon name */"%_T
    elseif result.slots == 3 then name = "Sol /* weapon name */"%_T
    elseif result.slots >= 4 then name = "Nova /* weapon name */"%_T end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Plasma)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial E-Tri-Plasma Cannon T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateRocketTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateRocketLauncher(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    local positions = {}
    if rand:getBool() then
        table.insert(positions, vec3(0, 0.3, 0))
    else
        table.insert(positions, vec3(0.4, 0.3, 0))
        table.insert(positions, vec3(-0.4, 0.3, 0))
    end

    -- attach
    for _, position in pairs(positions) do
        weapon.localPosition = position * result.size
        result:addWeapon(weapon)
    end

    local shootingTime = 20 * rand:getFloat(0.8, 1.2)
    local coolingTime = 15 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.RocketLauncher, tech, 0.6, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.RocketLauncher)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Rocket Launcher /* weapon name */"%_T
    if result.slots == 4 then name = "Rocket Battery /* weapon name */"%_T
    elseif result.slots >= 5 then name = "Rocket Phalanx /* weapon name */"%_T end

    if result.seeker then
        name = "Missile Launcher /* weapon name */"%_T
        if result.slots == 4 then name = "Missile Battery /* weapon name */"%_T
        elseif result.slots >= 5 then name = "Missile Phalanx /* weapon name */"%_T end
    end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] then
        name = "Ruiner /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Physical)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Anti-Tri-Missile Battery T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateCannonTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 4)

    local weapon = WeaponGenerator.generateCannon(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local shootingTime = 25 * rand:getFloat(0.8, 1.2)
    local coolingTime = 15 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.Cannon, tech, 0.5, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.Cannon)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Cannon /* weapon name */"%_T
    if result.slots == 4 then name = "Mortar /* weapon name */"%_T
    elseif result.slots >= 5 then name = "Artillery Cannon /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] then
        name = "Destructor Cannon /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Physical)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial E-Tri-Cannon T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateRailGunTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generateRailGun(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local shootingTime = 27.5 * rand:getFloat(0.8, 1.2)
    local coolingTime = 10 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.RailGun, tech, 0.5, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.RailGun)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Railgun /* weapon name */"%_T
    if result.slots == 3 then name = "Railgun /* weapon name */"%_T
    elseif result.slots == 4 then name = "Devastator /* weapon name */"%_T
    elseif result.slots == 5 then name = "Annihilator /* weapon name */"%_T
    elseif result.slots >= 6 then name = "Annihilator /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] and specialties[Specialty.HighAccuracy] then
        name = "Impaler /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
        specialties[Specialty.HighAccuracy] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Physical)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Railgun T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateRepairBeamTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Repair))
    result.crew = crew

    -- generate weapons
    local weapon = WeaponGenerator.generateRepairBeamEmitter(rand, dps, tech, material, rarity)

    -- on rare occasions generate a turret that can do both shield and hull repair
    if rand:test(0.125) == true then
        weapon.localPosition = vec3(0.1, 0, 0)
        if weapon.shieldRepair > 0 then
            weapon.bouterColor = ColorRGB(0.1, 0.2, 0.4)
            weapon.binnerColor = ColorRGB(0.2, 0.4, 0.9)
            weapon.shieldPenetration = 0
        else
            weapon.bouterColor = ColorARGB(0.5, 0, 0.5, 0)
            weapon.binnerColor = ColorRGB(1, 1, 1)
            weapon.shieldPenetration = 1
        end
        result:addWeapon(weapon)

        weapon.localPosition = vec3(-0.1, 0, 0)

        -- swap the two properties
        local shieldRepair = weapon.shieldRepair
        weapon.shieldRepair = weapon.hullRepair
        weapon.hullRepair = shieldRepair
        if weapon.shieldRepair > 0 then
            weapon.bouterColor = ColorRGB(0.1, 0.2, 0.4)
            weapon.binnerColor = ColorRGB(0.2, 0.4, 0.9)
            weapon.shieldPenetration = 0
        else
            weapon.bouterColor = ColorARGB(0.5, 0, 0.5, 0)
            weapon.binnerColor = ColorRGB(1, 1, 1)
            weapon.shieldPenetration = 1
        end
        result:addWeapon(weapon)

    else
        -- just attach normally
        TurretGenerator.attachWeapons(rand, result, weapon, 1)
    end

    local rechargeTime = 15 * rand:getFloat(0.8, 1.2)
    local shootingTime = 10 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.RepairBeam, tech, 1, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.RepairBeam)

    result.slotType = TurretSlotType.Unarmed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Repair Laser /* weapon name */"%_T
    if result.slots == 2 then name = "Repairer /* weapon name */"%_T
    elseif result.slots >= 3 then name = "Restorer /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] then
        name = "Renovator /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Energy)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Renovator T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateLightningTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateLightningGun(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local rechargeTime = 20 * rand:getFloat(0.8, 1.2)
    local shootingTime = 15 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.LightningGun, tech, 0.5, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.LightningGun)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Lightning Cannon /* weapon name */"%_T
    if result.slots == 4 then name = "Energizer /* weapon name */"%_T
    elseif result.slots == 5 then name = "Volter /* weapon name */"%_T
    elseif result.slots >= 6 then name = "Thunder /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] and specialties[Specialty.HighFireRate] then
        name = "Thor /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
        specialties[Specialty.HighFireRate] = nil

        result.flavorText = "For Asgard!"%_T
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Electric)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Thunder T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateTeslaTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateTeslaGun(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local rechargeTime = 20 * rand:getFloat(0.8, 1.2)
    local shootingTime = 15 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.TeslaGun, tech, 0.5, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.TeslaGun)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Tesla Cannon /* weapon name */"%_T
    if result.slots == 2 then name = "Tesla Cannon /* weapon name */"%_T
    elseif result.slots == 3 then name = "Shocker /* weapon name */"%_T
    elseif result.slots >= 4 then name = "Electrifier /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] and specialties[Specialty.LessEnergyConsumption] then
        name = "OverTesla /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
        specialties[Specialty.LessEnergyConsumption] = nil

        result.flavorText = "UNLIMITED POWER!"%_T
    end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Electric)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-Electrifier T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateForceTurret(rand, _, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateForceGun(rand, _, tech, material, rarity)
    local force = weapon.holdingForce

    local requiredCrew = math.floor(lerp(tech, 1, 52, 1, 6))
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Engine))
    result.crew = crew

    if weapon.otherForce ~= 0 then weapon.otherForce = weapon.otherForce / numWeapons end
    if weapon.selfForce ~= 0 then weapon.selfForce = weapon.selfForce / numWeapons end
    if weapon.holdingForce ~= 0 then weapon.holdingForce = weapon.holdingForce / numWeapons end

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    -- add more beams, for this we add invisible weapons doing nothing but creating beams
    local weapons = {result:getWeapons()}
    for _, weapon in pairs(weapons) do
        weapon.selfForce = 0
        weapon.otherForce = 0
        weapon.holdingForce = 0
        weapon.bshape = BeamShape.Swirly
        weapon.bshapeSize = 1.25
        weapon.appearance = WeaponAppearance.Invisible
        result:addWeapon(weapon)
    end

    TurretGenerator.scale(rand, result, WeaponType.ForceGun, tech, 2, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.ForceGun)

    -- force weapons use unarmed slots, but are counted as category armed,
    -- since they can inflict damage by throwing and don't fit into any other category
    result.slotType = TurretSlotType.Unarmed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Force Cannon /* weapon name */"%_T
    if result.slots == 3 then name = "Grabber /* weapon name */"%_T
    elseif result.slots == 4 then name = "Manipulator /* weapon name */"%_T
    elseif result.slots >= 5 then name = "Gravitron /* weapon name */"%_T end

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Physical)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Bi-Force Cannon T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generatePulseTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generatePulseCannon(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local shootingTime = 15 * rand:getFloat(1, 1.5)
    local coolingTime = 5 * rand:getFloat(1, 1.5)

    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    -- adjust damage since pulse guns' DPS only decreases with cooling introduced
    -- pulse guns have no other damage boost like rockets, cannons or railguns
    local weapons = {result:getWeapons()}
    result:clearWeapons()
    for _, weapon in pairs(weapons) do
        weapon.damage = weapon.damage * ((coolingTime + shootingTime) / shootingTime)
        result:addWeapon(weapon)
    end

    TurretGenerator.scale(rand, result, WeaponType.PulseCannon, tech, 0.8, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.PulseCannon)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Pulse Gun /* weapon name */"%_T
    if result.slots == 2 then name = "Pulse Cannon /* weapon name */"%_T
    elseif result.slots == 3 then name = "Pulsar /* weapon name */"%_T
    elseif result.slots >= 4 then name = "Quasar /* weapon name */"%_T end

    if specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] and specialties[Specialty.HighAccuracy] then
        name = "Meteor /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
        specialties[Specialty.HighAccuracy] = nil
    elseif specialties[Specialty.HighDamage] and specialties[Specialty.HighRange] and specialties[Specialty.HighFireRate] then
        name = "Intruder /* weapon name */"%_T
        specialties[Specialty.HighDamage] = nil
        specialties[Specialty.HighRange] = nil
        specialties[Specialty.HighFireRate] = nil
    end

    specialties[Specialty.IonizedProjectile] = nil

    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Physical)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Bi-Pulse Cannon T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end

function TurretGenerator.generateAntiFighterTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generateAntiFighterGun(rand, dps, tech, material, rarity)

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    TurretGenerator.scale(rand, result, WeaponType.AntiFighter, tech, 1.2, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.AntiFighter)

    result.slotType = TurretSlotType.PointDefense
    result:updateStaticStats()

    -- create a nice name for the turret
    local name = "Anti-Fighter Cannon /* weapon name */"%_T
    local dmgAdjective, outerAdjective, barrel, multishot, coax, serial = makeTitleParts(rand, specialties, result, DamageType.Fragments)
    result.title = Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial Plasmatic Tri-PDC T-F */"%_T, outerAdjective, barrel, coax, dmgAdjective, multishot, name, serial)

    return result
end


generatorFunction[WeaponType.ChainGun            ] = TurretGenerator.generateChaingunTurret
generatorFunction[WeaponType.PointDefenseChainGun] = TurretGenerator.generatePointDefenseChaingunTurret
generatorFunction[WeaponType.PointDefenseLaser   ] = TurretGenerator.generatePointDefenseLaserTurret
generatorFunction[WeaponType.Laser               ] = TurretGenerator.generateLaserTurret
generatorFunction[WeaponType.MiningLaser         ] = TurretGenerator.generateMiningTurret
generatorFunction[WeaponType.RawMiningLaser      ] = TurretGenerator.generateRawMiningTurret
generatorFunction[WeaponType.SalvagingLaser      ] = TurretGenerator.generateSalvagingTurret
generatorFunction[WeaponType.RawSalvagingLaser   ] = TurretGenerator.generateRawSalvagingTurret
generatorFunction[WeaponType.PlasmaGun           ] = TurretGenerator.generatePlasmaTurret
generatorFunction[WeaponType.RocketLauncher      ] = TurretGenerator.generateRocketTurret
generatorFunction[WeaponType.Cannon              ] = TurretGenerator.generateCannonTurret
generatorFunction[WeaponType.RailGun             ] = TurretGenerator.generateRailGunTurret
generatorFunction[WeaponType.RepairBeam          ] = TurretGenerator.generateRepairBeamTurret
generatorFunction[WeaponType.Bolter              ] = TurretGenerator.generateBolterTurret
generatorFunction[WeaponType.LightningGun        ] = TurretGenerator.generateLightningTurret
generatorFunction[WeaponType.TeslaGun            ] = TurretGenerator.generateTeslaTurret
generatorFunction[WeaponType.ForceGun            ] = TurretGenerator.generateForceTurret
generatorFunction[WeaponType.PulseCannon         ] = TurretGenerator.generatePulseTurret
generatorFunction[WeaponType.AntiFighter         ] = TurretGenerator.generateAntiFighterTurret


return TurretGenerator
