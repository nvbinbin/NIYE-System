-- 定义一个package.path变量，用于指定lua模块的搜索路径，将"data/scripts/lib/?.lua"添加到原有的路径中
package.path = package.path .. ";data/scripts/lib/?.lua"

-- 使用include函数，加载stringutility和utility两个模块，这些模块提供了一些字符串和通用的函数
include("stringutility")
include("utility")

-- 定义一个WeaponType表，用于存储不同的武器类型
WeaponType = {}
-- 定义一个WeaponTypes表，用于存储不同类型的武器的相关信息，如武器类型的列表，武器类型的名称，武器类型的分类等
WeaponTypes = {}
-- 定义一个WeaponTypes.armedTypes表，用于存储有攻击性的武器类型
WeaponTypes.armedTypes = {}
-- 定义一个WeaponTypes.defensiveTypes表，用于存储有防御性的武器类型
WeaponTypes.defensiveTypes = {}
-- 定义一个WeaponTypes.unarmedTypes表，用于存储无攻击性的武器类型
WeaponTypes.unarmedTypes = {}
-- 定义一个WeaponTypes.nameByType表，用于存储武器类型对应的名称
WeaponTypes.nameByType = {}

-- 定义一个WeaponTypes.getRandom函数，用于从武器类型中随机选择一个
-- 参数：
-- rand: 一个Random对象，用于生成随机数
-- 返回值：
-- 一个WeaponType枚举值，表示随机选择的武器类型
function WeaponTypes.getRandom(rand)
    return rand:getInt(WeaponType.ChainGun, WeaponType.AntiFighter)
end

-- 定义一个WeaponTypes.getArmed函数，用于获取有攻击性的武器类型
-- 参数：
-- 无
-- 返回值：
-- 一个可变参数列表，包含所有有攻击性的武器类型
function WeaponTypes.getArmed()
    return unpack(WeaponTypes.armedTypes)
end

-- 定义一个局部变量unarmed，表示无攻击性的武器类型的分类，值为0
local unarmed = 0
-- 定义一个局部变量armed，表示有攻击性的武器类型的分类，值为1
local armed = 1
-- 定义一个局部变量defensive，表示有防御性的武器类型的分类，值为2
local defensive = 2

-- 定义一个WeaponTypes.addType函数，用于向WeaponType表中添加一个新的武器类型，并设置其名称和分类
-- 参数：
-- id: 一个字符串，表示武器类型的标识符
-- displayName: 一个字符串，表示武器类型的名称
-- armament: 一个数字，表示武器类型的分类，可以是unarmed, armed或defensive
-- 返回值：
-- 无
function WeaponTypes.addType(id, displayName, armament)
    -- 将WeaponType表中id对应的值设置为WeaponType表的长度加1，即新的武器类型的枚举值
    WeaponType[id] = tablelength(WeaponType)
    -- 将WeaponTypes.nameByType表中新的武器类型对应的值设置为displayName，即武器类型的名称
    WeaponTypes.nameByType[WeaponType[id]] = displayName

    -- 如果armament等于armed，则将新的武器类型添加到WeaponTypes.armedTypes表中
    if armament == armed then
        table.insert(WeaponTypes.armedTypes, WeaponType[id])
    -- 如果armament等于unarmed，则将新的武器类型添加到WeaponTypes.unarmedTypes表中
    elseif armament == unarmed then
        table.insert(WeaponTypes.unarmedTypes, WeaponType[id])
    -- 如果armament等于defensive，则将新的武器类型添加到WeaponTypes.defensiveTypes表中
    elseif armament == defensive then
        table.insert(WeaponTypes.defensiveTypes, WeaponType[id])
    end
end

-- 调用WeaponTypes.addType函数，向WeaponType表中添加不同的武器类型，并设置其名称和分类
WeaponTypes.addType("ChainGun",             "Chaingun /* Weapon Type */"%_t,                armed) -- 连发炮，有攻击性
WeaponTypes.addType("PointDefenseChainGun", "Point Defense Cannon /* Weapon Type */"%_t,    defensive) -- 近防连发炮，有防御性
WeaponTypes.addType("PointDefenseLaser",    "Point Defense Laser /* Weapon Type */"%_t,     defensive) -- 近防激光，有防御性
WeaponTypes.addType("Laser",                "Laser /* Weapon Type */"%_t,                   armed) -- 激光，有攻击性
WeaponTypes.addType("MiningLaser",          "Mining Laser /* Weapon Type */"%_t,            unarmed) -- 采矿激光，无攻击性，"MiningLaser"是在C++代码中显式使用的，必须存在
WeaponTypes.addType("RawMiningLaser",       "Raw Mining Laser /* Weapon Type */"%_t,        unarmed) -- 原始采矿激光，无攻击性
WeaponTypes.addType("SalvagingLaser",       "Salvaging Laser /* Weapon Type */"%_t,         unarmed) -- 拆解激光，无攻击性
WeaponTypes.addType("RawSalvagingLaser",    "Raw Salvaging Laser /* Weapon Type */"%_t,     unarmed) -- 原始拆解激光，无攻击性
WeaponTypes.addType("PlasmaGun",            "Plasma /* Weapon Type */"%_t,                  armed) -- 等离子武器，有攻击性
WeaponTypes.addType("RocketLauncher",       "Launcher /* Weapon Type */"%_t,                armed) -- 火箭发射器，有攻击性
WeaponTypes.addType("Cannon",               "Cannon /* Weapon Type */"%_t,                  armed) -- 炮弹武器，有攻击性
WeaponTypes.addType("RailGun",              "Railgun /* Weapon Type */"%_t,                 armed) -- 磁轨炮，有攻击性
WeaponTypes.addType("RepairBeam",           "Repair /* Weapon Type */"%_t,                  unarmed) -- 修复光束，无攻击性
WeaponTypes.addType("Bolter",               "Bolter /* Weapon Type */"%_t,                  armed) -- 螺栓武器，有攻击性
WeaponTypes.addType("LightningGun",         "Lightning Gun /* Weapon Type */"%_t,           armed) -- 闪电武器，有攻击性
WeaponTypes.addType("TeslaGun",             "Tesla Gun /* Weapon Type */"%_t,               armed) -- 特斯拉武器，有攻击性
WeaponTypes.addType("ForceGun",             "Force Gun /* Weapon Type */"%_t,               unarmed) -- 推力枪，无攻击性
WeaponTypes.addType("PulseCannon",          "Pulse Cannon /* Weapon Type */"%_t,            armed) -- 脉冲炮，有攻击性
WeaponTypes.addType("AntiFighter",          "Anti Fighter /* Weapon Type */"%_t,            defensive) -- 反战斗机武器，有防御性
