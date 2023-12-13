package.path = package.path .. ";data/scripts/lib/?.lua"

include("stringutility")
include("utility")

WeaponType = {}
WeaponTypes = {}
WeaponTypes.armedTypes = {}
WeaponTypes.defensiveTypes = {}
WeaponTypes.unarmedTypes = {}
WeaponTypes.nameByType = {}

function WeaponTypes.getRandom(rand)
    return rand:getInt(WeaponType.ChainGun, WeaponType.AntiFighter)
end

function WeaponTypes.getArmed()
    return unpack(WeaponTypes.armedTypes)
end

local unarmed = 0
local armed = 1
local defensive = 2

function WeaponTypes.addType(id, displayName, armament)
    WeaponType[id] = tablelength(WeaponType)
    WeaponTypes.nameByType[WeaponType[id]] = displayName

    if armament == armed then
        table.insert(WeaponTypes.armedTypes, WeaponType[id])
    elseif armament == unarmed then
        table.insert(WeaponTypes.unarmedTypes, WeaponType[id])
    elseif armament == defensive then
        table.insert(WeaponTypes.defensiveTypes, WeaponType[id])
    end
end

WeaponTypes.addType("ChainGun",             "Chaingun /* Weapon Type */"%_t,                armed)
WeaponTypes.addType("PointDefenseChainGun", "Point Defense Cannon /* Weapon Type */"%_t,    defensive)
WeaponTypes.addType("PointDefenseLaser",    "Point Defense Laser /* Weapon Type */"%_t,     defensive)
WeaponTypes.addType("Laser",                "Laser /* Weapon Type */"%_t,                   armed)
WeaponTypes.addType("MiningLaser",          "Mining Laser /* Weapon Type */"%_t,            unarmed) -- "MiningLaser" is explicitly used in C++ code and must be available
WeaponTypes.addType("RawMiningLaser",       "Raw Mining Laser /* Weapon Type */"%_t,        unarmed)
WeaponTypes.addType("SalvagingLaser",       "Salvaging Laser /* Weapon Type */"%_t,         unarmed)
WeaponTypes.addType("RawSalvagingLaser",    "Raw Salvaging Laser /* Weapon Type */"%_t,     unarmed)
WeaponTypes.addType("PlasmaGun",            "Plasma /* Weapon Type */"%_t,                  armed)
WeaponTypes.addType("RocketLauncher",       "Launcher /* Weapon Type */"%_t,                armed)
WeaponTypes.addType("Cannon",               "Cannon /* Weapon Type */"%_t,                  armed)
WeaponTypes.addType("RailGun",              "Railgun /* Weapon Type */"%_t,                 armed)
WeaponTypes.addType("RepairBeam",           "Repair /* Weapon Type */"%_t,                  unarmed)
WeaponTypes.addType("Bolter",               "Bolter /* Weapon Type */"%_t,                  armed)
WeaponTypes.addType("LightningGun",         "Lightning Gun /* Weapon Type */"%_t,           armed)
WeaponTypes.addType("TeslaGun",             "Tesla Gun /* Weapon Type */"%_t,               armed)
WeaponTypes.addType("ForceGun",             "Force Gun /* Weapon Type */"%_t,               unarmed)
WeaponTypes.addType("PulseCannon",          "Pulse Cannon /* Weapon Type */"%_t,            armed)
WeaponTypes.addType("AntiFighter",          "Anti Fighter /* Weapon Type */"%_t,            defensive)

