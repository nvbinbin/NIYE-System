-- 设置包路径，添加data/scripts/lib目录下的所有lua文件
package.path = package.path .. ";data/scripts/lib/?.lua"

-- 引入galaxy模块，用于处理银河系相关的数据和函数
include("galaxy")
-- 引入randomext模块，用于生成随机数和概率分布
include("randomext")
-- 引入weapongenerator模块，用于生成武器
local WeaponGenerator = include ("weapongenerator")
-- 引入weapontype模块，用于定义武器的类型和属性
include("weapontype")

-- 定义一个TurretGenerator表，用于存放炮塔生成器的函数和数据
local TurretGenerator =  {}

-- 定义一个generatorFunction表，用于存放不同类型武器的生成函数
local generatorFunction = {}

-- 定义一个generateSeeded函数，用于根据给定的种子和参数生成一个炮塔
-- 参数：
-- seed: 一个整数，用于初始化随机数生成器
-- weaponType: 一个WeaponType枚举值，表示武器的类型
-- dps: 一个数字，表示武器的每秒伤害
-- tech: 一个数字，表示武器的科技等级
-- rarity: 一个Rarity枚举值，表示武器的稀有度
-- material: 一个Material枚举值，表示武器的材质
-- coaxialAllowed: 一个布尔值，表示武器是否允许同轴模式
-- 返回值：
-- 一个Turret对象，表示生成的炮塔
function TurretGenerator.generateSeeded(seed, weaponType, dps, tech, rarity, material, coaxialAllowed)
    -- 调用generateTurret函数，传入一个Random对象和其他参数，返回生成的炮塔
    return TurretGenerator.generateTurret(Random(seed), weaponType, dps, tech, material, rarity, coaxialAllowed)
end

-- 定义一个generateTurret函数，用于根据给定的随机数生成器和参数生成一个炮塔
-- 参数：
-- rand: 一个Random对象，用于生成随机数
-- type: 一个WeaponType枚举值，表示武器的类型
-- dps: 一个数字，表示武器的每秒伤害
-- tech: 一个数字，表示武器的科技等级
-- material: 一个Material枚举值，表示武器的材质
-- rarity: 一个Rarity枚举值，表示武器的稀有度
-- coaxialAllowed: 一个布尔值，表示武器是否允许同轴模式
-- 返回值：
-- 一个Turret对象，表示生成的炮塔
function TurretGenerator.generateTurret(rand, type, dps, tech, material, rarity, coaxialAllowed)
    -- 如果rarity参数为空，则根据一个概率分布生成一个Rarity枚举值
    if rarity == nil then
        -- 调用rand的getValueOfDistribution函数，传入6个数字作为权重，返回一个1到6的整数
        local index = rand:getValueOfDistribution(32, 32, 16, 8, 4, 1)
        -- 根据index的值，创建一个Rarity枚举值，注意index要减1，因为Rarity的值从0开始
        rarity = Rarity(index - 1)
    end

    -- 如果coaxialAllowed参数为空，则默认为true
    if coaxialAllowed == nil then coaxialAllowed = true end

    -- 从generatorFunction表中根据type的值，获取对应的武器生成函数
    -- 调用该函数，传入rand和其他参数，返回生成的炮塔
    return generatorFunctiontype
end


-- 定义一个scales表，用于存放不同类型武器的尺寸和占用槽位的规则
local scales = {}
-- 为WeaponType.ChainGun类型的武器设置规则
-- 规则是一个表的列表，每个表包含四个字段：from, to, size, usedSlots
-- from和to表示科技等级的范围，size表示武器的尺寸，usedSlots表示武器占用的槽位数
-- 例如，{from = 0, to = 15, size = 0.5, usedSlots = 1}表示科技等级在0到15之间的武器，尺寸为0.5，占用1个槽位
scales[WeaponType.ChainGun] = {
    {from = 0, to = 15, size = 0.5, usedSlots = 1},
    {from = 16, to = 31, size = 1.0, usedSlots = 2},
    {from = 32, to = 52, size = 1.5, usedSlots = 3},
}

-- 为WeaponType.PointDefenseChainGun类型的武器设置规则
-- 规则只有一项，表示科技等级在0到52之间的武器，尺寸为0.5，占用1个槽位
scales[WeaponType.PointDefenseChainGun] = {
    {from = 0, to = 52, size = 0.5, usedSlots = 1},
}

-- 为WeaponType.PointDefenseLaser类型的武器设置规则
-- 规则只有一项，表示科技等级在0到52之间的武器，尺寸为0.5，占用1个槽位
scales[WeaponType.PointDefenseLaser] = {
    {from = 0, to = 52, size = 0.5, usedSlots = 1},
}

-- 为WeaponType.Bolter类型的武器设置规则
-- 规则有四项，分别表示科技等级在0到18，19到33，34到45，46到52之间的武器，尺寸分别为0.5，1.0，1.5，2.0，占用槽位分别为1，2，3，4
scales[WeaponType.Bolter] = {
    {from = 0, to = 18, size = 0.5, usedSlots = 1},
    {from = 19, to = 33, size = 1.0, usedSlots = 2},
    {from = 34, to = 45, size = 1.5, usedSlots = 3},
    {from = 46, to = 52, size = 2.0, usedSlots = 4},
}

-- 为WeaponType.Laser类型的武器设置规则
-- 规则有五项，分别表示科技等级在0到24，25到35，36到46，47到49，50到52之间的武器，尺寸分别为0.5，1.0，1.5，2.0，3.5，占用槽位分别为1，2，3，4，6
scales[WeaponType.Laser] = {
    {from = 0, to = 24, size = 0.5, usedSlots = 1},
    {from = 25, to = 35, size = 1.0, usedSlots = 2},
    {from = 36, to = 46, size = 1.5, usedSlots = 3},
    {from = 47, to = 49, size = 2.0, usedSlots = 4},
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

-- 为WeaponType.MiningLaser类型的武器设置规则
-- 规则有五项，分别表示科技等级在0到12，13到25，26到35，36到45，46到52之间的武器，尺寸分别为0.5，1.0，1.5，2.5，3.0，占用槽位分别为1，2，3，4，5
scales[WeaponType.MiningLaser] = {
    {from = 0, to = 12, size = 0.5, usedSlots = 1},
    {from = 13, to = 25, size = 1.0, usedSlots = 2},
    {from = 26, to = 35, size = 1.5, usedSlots = 3},
    {from = 36, to = 45, size = 2.5, usedSlots = 4},
    {from = 46, to = 52, size = 3.0, usedSlots = 5},
}
-- 为WeaponType.RawMiningLaser类型的武器设置规则
-- 规则和WeaponType.MiningLaser类型的武器相同，直接引用scales[WeaponType.MiningLaser]
scales[WeaponType.RawMiningLaser] = scales[WeaponType.MiningLaser]

-- 为WeaponType.SalvagingLaser类型的武器设置规则
-- 规则有五项，分别表示科技等级在0到12，13到25，26到35，36到45，46到52之间的武器，尺寸分别为0.5，1.0，1.5，2.5，3.0，占用槽位分别为1，2，3，4，5
scales[WeaponType.SalvagingLaser] = {
    {from = 0, to = 12, size = 0.5, usedSlots = 1},
    {from = 13, to = 25, size = 1.0, usedSlots = 2},
    {from = 26, to = 35, size = 1.5, usedSlots = 3},
    {from = 36, to = 45, size = 2.5, usedSlots = 4},
    {from = 46, to = 52, size = 3.0, usedSlots = 5},
}
-- 为WeaponType.RawSalvagingLaser类型的武器设置规则
-- 规则和WeaponType.SalvagingLaser类型的武器相同，直接引用scales[WeaponType.SalvagingLaser]
scales[WeaponType.RawSalvagingLaser] = scales[WeaponType.SalvagingLaser]

-- 为WeaponType.PlasmaGun类型的武器设置规则
-- 规则有四项，分别表示科技等级在0到30，31到39，40到48，49到52之间的武器，尺寸分别为0.5，1.0，1.5，2.0，占用槽位分别为1，2，3，4
scales[WeaponType.PlasmaGun] = {
    {from = 0, to = 30, size = 0.5, usedSlots = 1},
    {from = 31, to = 39, size = 1.0, usedSlots = 2},
    {from = 40, to = 48, size = 1.5, usedSlots = 3},
    {from = 49, to = 52, size = 2.0, usedSlots = 4},
}

-- 为WeaponType.RocketLauncher类型的武器设置规则
-- 规则有四项，分别表示科技等级在0到32，33到40，41到48，49到52之间的武器，尺寸分别为1.0，1.5，2.0，3.0，占用槽位分别为2，3，4，5
scales[WeaponType.RocketLauncher] = {
    {from = 0, to = 32, size = 1.0, usedSlots = 2},
    {from = 33, to = 40, size = 1.5, usedSlots = 3},
    {from = 41, to = 48, size = 2.0, usedSlots = 4},
    {from = 49, to = 52, size = 3.0, usedSlots = 5},
}

-- 为WeaponType.Cannon类型的武器设置规则
-- 规则有四项，分别表示科技等级在0到28，29到38，39到49，50到52之间的武器，尺寸分别为1.5，2.0，3.0，3.5，占用槽位分别为3，4，5，6
-- 注意，最后一项是为同轴模式的武器设置的，尺寸和科技等级都比正常的武器高1
scales[WeaponType.Cannon] = {
    {from = 0, to = 28, size = 1.5, usedSlots = 3},
    {from = 29, to = 38, size = 2.0, usedSlots = 4},
    {from = 39, to = 49, size = 3.0, usedSlots = 5},
    --dummy for cooaxial, add 1 to size and level
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

-- 为WeaponType.RailGun类型的武器设置规则
-- 规则有五项，分别表示科技等级在0到28，29到35，36到42，43到49，50到52之间的武器，尺寸分别为1.0，1.5，2.0，3.0，3.5，占用槽位分别为2，3，4，5，6
-- 注意，最后一项是为同轴模式的武器设置的，尺寸和科技等级都比正常的武器高1
scales[WeaponType.RailGun] = {
    {from = 0, to = 28, size = 1.0, usedSlots = 2},
    {from = 29, to = 35, size = 1.5, usedSlots = 3},
    {from = 36, to = 42, size = 2.0, usedSlots = 4},
    {from = 43, to = 49, size = 3.0, usedSlots = 5},
    --dummy for cooaxial, add 1 to size and level
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

-- 为WeaponType.RepairBeam类型的武器设置规则
-- 规则有三项，分别表示科技等级在0到28，29到40，41到52之间的武器，尺寸分别为0.5，1.0，1.5，占用槽位分别为1，2，3
scales[WeaponType.RepairBeam] = {
    {from = 0, to = 28, size = 0.5, usedSlots = 1},
    {from = 29, to = 40, size = 1.0, usedSlots = 2},
    {from = 41, to = 52, size = 1.5, usedSlots = 3},
}

-- 为WeaponType.LightningGun类型的武器设置规则
-- 规则有五项，分别表示科技等级在0到36，37到42，43到46，47到50，51到52之间的武器，尺寸分别为1.0，1.5，2.0，3.0，3.5，占用槽位分别为2，3，4，5，6
-- 注意，最后一项是为同轴模式的武器设置的，尺寸和科技等级都比正常的武器高1
scales[WeaponType.LightningGun] = {
    {from = 0, to = 36, size = 1.0, usedSlots = 2},
    {from = 37, to = 42, size = 1.5, usedSlots = 3},
    {from = 43, to = 46, size = 2.0, usedSlots = 4},
    {from = 47, to = 50, size = 3.0, usedSlots = 5},
    --dummy for cooaxial, add 1 to size and level
    {from = 51, to = 52, size = 3.5, usedSlots = 6},
}

-- 为WeaponType.TeslaGun类型的武器设置规则
-- 规则有四项，分别表示科技等级在0到25，26到36，37到49，50到52之间的武器，尺寸分别为0.5，1.0，1.5，3.5，占用槽位分别为1，2，3，6
scales[WeaponType.TeslaGun] = {
    {from = 0, to = 25, size = 0.5, usedSlots = 1},
    {from = 26, to = 36, size = 1.0, usedSlots = 2},
    {from = 37, to = 49, size = 1.5, usedSlots = 3},
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}

-- 为WeaponType.ForceGun类型的武器设置规则
-- 规则有四项，分别表示科技等级在0到15，16到30，31到44，45到52之间的武器，尺寸分别为1.0，2.0，3.0，4.0，占用槽位分别为2，3，4，6
scales[WeaponType.ForceGun] = {
    {from = 0, to = 15, size = 1.0, usedSlots = 2},
    {from = 16, to = 30, size = 2.0, usedSlots = 3},
    {from = 31, to = 44, size = 3.0, usedSlots = 4},
    {from = 45, to = 52, size = 4.0, usedSlots = 6},
}

-- 为WeaponType.PulseCannon类型的武器设置规则
-- 规则有四项，分别表示科技等级在0到25，26到36，37到47，48到52之间的武器，尺寸分别为0.5，1.0，1.5，2.0，占用槽位分别为1，2，3，4
scales[WeaponType.PulseCannon] = {
    {from = 0, to = 25, size = 0.5, usedSlots = 1},
    {from = 26, to = 36, size = 1.0, usedSlots = 2},
    {from = 37, to = 47, size = 1.5, usedSlots = 3},
    {from = 48, to = 52, size = 2.0, usedSlots = 4},
}

-- 为WeaponType.AntiFighter类型的武器设置规则
-- 规则只有一项，表示科技等级在0到52之间的武器，尺寸为0.5，占用1个槽位
scales[WeaponType.AntiFighter] = {
    {from = 0, to = 52, size = 0.5, usedSlots = 1},
}



-- 定义一个dpsToRequiredCrew函数，用于根据武器的每秒伤害计算所需的船员数量
-- 参数：
-- dps: 一个数字，表示武器的每秒伤害
-- 返回值：
-- 一个整数，表示所需的船员数量
function TurretGenerator.dpsToRequiredCrew(dps)
    -- 根据一个公式计算所需的船员数量，向下取整
    local value = math.floor(1 + (dps / 1400))
    -- 再加上一个最小值，最多为4，也要向下取整
    value = value + math.min(4, math.floor(dps / 100))

    -- 返回计算结果
    return value
end

-- 定义一个attachWeapons函数，用于将武器附加到炮塔上
-- 参数：
-- rand: 一个Random对象，用于生成随机数
-- turret: 一个Turret对象，表示要附加武器的炮塔
-- weapon: 一个Weapon对象，表示要附加的武器
-- numWeapons: 一个整数，表示要附加的武器数量
-- 返回值：
-- 无
function TurretGenerator.attachWeapons(rand, turret, weapon, numWeapons)
    -- 清除炮塔上原有的武器
    turret:clearWeapons()

    -- 调用createWeaponPlaces函数，传入rand和numWeapons，返回一个位置的列表
    local places = {TurretGenerator.createWeaponPlaces(rand, numWeapons)}

    -- 遍历位置列表，对每个位置
    for _, position in pairs(places) do
        -- 将武器的本地位置设置为位置乘以炮塔的尺寸
        weapon.localPosition = position * turret.size
        -- 将武器添加到炮塔上
        turret:addWeapon(weapon)
    end
end

-- 定义一个createWeaponPlaces函数，用于根据武器数量生成武器的位置
-- 参数：
-- rand: 一个Random对象，用于生成随机数
-- numWeapons: 一个整数，表示武器的数量
-- 返回值：
-- 一个或多个vec3对象，表示武器的位置
function TurretGenerator.createWeaponPlaces(rand, numWeapons)
    -- 如果武器数量为1，则返回一个原点的位置
    if numWeapons == 1 then
        return vec3(0, 0, 0)

    -- 如果武器数量为2，则根据一个随机的情况生成两个位置
    elseif numWeapons == 2 then
        -- 生成一个0或1的随机整数，作为情况
        local case = rand:getInt(0, 1)
        -- 生成一个0.1到0.4之间的随机浮点数，作为距离
        local dist = rand:getFloat(0.1, 0.4)
        -- 如果情况为0，则返回两个位置，分别在x轴的正负方向上
        if case == 0 then
            return vec3(dist, 0, 0), vec3(-dist, 0, 0)
        -- 如果情况为1，则返回两个位置，分别在y轴的正负方向上，同时加上0.2的偏移量
        else
            return vec3(0, dist + 0.2, 0), vec3(0, -dist + 0.2, 0)
        end

    -- 如果武器数量为3，则根据一个随机的情况生成三个位置
    elseif numWeapons == 3 then
        -- 生成一个0或1的随机整数，作为情况
        local case = rand:getInt(0, 1)
        -- 如果情况为0，则返回三个位置，分别在x轴的正负方向上，以及y轴的正方向上
        if case == 0 then
            return vec3(0.4, 0, 0), vec3(0, 0.2, 0), vec3(-0.4, 0, 0)
        -- 如果情况为1，则返回三个位置，分别在x轴的正负方向上，以及y轴的原点
        else
            return vec3(0.4, 0, 0), vec3(0, 0, 0), vec3(-0.4, 0, 0)
        end

    -- 如果武器数量为4，则返回四个位置，分别在x轴和y轴的正负方向上，形成一个矩形
    elseif numWeapons == 4 then
        return vec3(0.4, -0.2, 0), vec3(-0.4, 0.2, 0), vec3(0.4, 0.2, 0), vec3(-0.4, -0.2, 0)
    end
end


-- 定义一个createStandardCooling函数，用于为炮塔设置标准的冷却方式
-- 参数：
-- turret: 一个Turret对象，表示要设置冷却方式的炮塔
-- coolingTime: 一个数字，表示炮塔从最高热量降到0所需的时间，单位为秒
-- shootingTime: 一个数字，表示炮塔从0热量升到最高热量所需的时间，单位为秒
-- 返回值：
-- 无
function TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)
    -- 调用turret的updateStaticStats函数，更新炮塔的静态属性，如每秒射击次数等
    turret:updateStaticStats()

    -- 定义一个局部变量maxHeat，表示炮塔的最高热量，固定为10
    local maxHeat = 10

    -- 根据coolingTime计算炮塔的冷却速率，即每秒降低的热量
    -- 冷却速率必须小于加热速率，否则炮塔永远不会过热
    local coolingRate = maxHeat / coolingTime -- must be smaller than heating rate or the weapon will never overheat
    -- 根据shootingTime计算炮塔的加热差值，即每秒增加的热量
    local heatDelta = maxHeat / shootingTime
    -- 根据加热差值和冷却速率计算炮塔的加热速率，即每秒实际增加的热量
    local heatingRate = heatDelta + coolingRate
    -- 根据加热速率和每秒射击次数计算炮塔的每次射击增加的热量
    local heatPerShot = heatingRate / turret.firingsPerSecond

    -- 设置炮塔的冷却类型为CoolingType.Standard，表示标准冷却方式
    turret.coolingType = CoolingType.Standard
    -- 设置炮塔的最高热量为maxHeat
    turret.maxHeat = maxHeat
    -- 设置炮塔的每次射击增加的热量为heatPerShot，如果heatPerShot为空，则设置为0
    turret.heatPerShot = heatPerShot or 0
    -- 设置炮塔的冷却速率为coolingRate，如果coolingRate为空，则设置为0
    turret.coolingRate = coolingRate or 0

end

-- 定义一个createBatteryChargeCooling函数，用于为炮塔设置电池充电的冷却方式
-- 参数：
-- turret: 一个Turret对象，表示要设置冷却方式的炮塔
-- rechargeTime: 一个数字，表示炮塔从0充电到最大充电所需的时间，单位为秒
-- shootingTime: 一个数字，表示炮塔从最大充电消耗到0所需的时间，单位为秒
-- 返回值：
-- 无
function TurretGenerator.createBatteryChargeCooling(turret, rechargeTime, shootingTime)
    -- 调用turret的updateStaticStats函数，更新炮塔的静态属性，如每秒射击次数等
    turret:updateStaticStats()

    -- 定义一个局部变量maxCharge，表示炮塔的最大充电
    local maxCharge
    -- 如果炮塔的每秒伤害大于0，则将最大充电设置为每秒伤害乘以10
    if turret.dps > 0 then
        maxCharge = turret.dps * 10
    -- 否则，将最大充电设置为5
    else
        maxCharge = 5
    end

    -- 根据rechargeTime计算炮塔的充电速率，即每秒增加的充电
    -- 充电速率必须小于消耗速率，否则炮塔永远不会耗尽能量
    local rechargeRate = maxCharge / rechargeTime -- must be smaller than consumption rate or the weapon will never run out of energy
    -- 根据shootingTime计算炮塔的消耗差值，即每秒减少的充电
    local consumptionDelta = maxCharge / shootingTime
    -- 根据消耗差值和充电速率计算炮塔的消耗速率，即每秒实际减少的充电
    local consumptionRate = consumptionDelta + rechargeRate

    -- 根据消耗速率和每秒射击次数计算炮塔的每次射击消耗的充电
    local consumptionPerShot = consumptionRate / turret.firingsPerSecond

    -- 设置炮塔的冷却类型为CoolingType.BatteryCharge，表示电池充电方式
    turret.coolingType = CoolingType.BatteryCharge
    -- 设置炮塔的最大热量为maxCharge，注意这里的热量实际上是充电
    turret.maxHeat = maxCharge
    -- 设置炮塔的每次射击增加的热量为consumptionPerShot，注意这里的热量实际上是充电，如果consumptionPerShot为空，则设置为0
    turret.heatPerShot = consumptionPerShot or 0
    -- 设置炮塔的冷却速率为rechargeRate，注意这里的冷却实际上是充电，如果rechargeRate为空，则设置为0
    turret.coolingRate = rechargeRate or 0
end


-- 定义一个scale函数，用于根据武器类型和科技等级调整炮塔的尺寸、槽位、转速和武器属性
-- 参数：
-- rand: 一个Random对象，用于生成随机数
-- turret: 一个Turret对象，表示要调整的炮塔
-- type: 一个WeaponType枚举值，表示武器的类型
-- tech: 一个数字，表示武器的科技等级
-- turnSpeedFactor: 一个数字，表示炮塔转速的系数
-- coaxialPossible: 一个布尔值，表示炮塔是否可以是同轴的，默认为true
-- 返回值：
-- 一个数字，表示炮塔的实际科技等级
function TurretGenerator.scale(rand, turret, type, tech, turnSpeedFactor, coaxialPossible)
    -- 如果coaxialPossible参数为空，则将其设置为true
    -- 避免使用coaxialPossible = coaxialPossible or true，因为这样会把false也设置为true
    if coaxialPossible == nil then coaxialPossible = true end -- avoid coaxialPossible = coaxialPossible or true, as it will set it to true if "false" is passed

    -- 定义一个局部变量scaleTech，表示用于计算炮塔尺寸的科技等级，初始值为tech
    local scaleTech = tech
    -- 以50%的概率，将scaleTech设置为1到tech之间的一个随机整数
    if rand:test(0.5) then
        scaleTech = math.floor(math.max(1, scaleTech * rand:getFloat(0, 1)))
    end

    -- 调用TurretGenerator的getScale函数，传入type和scaleTech，返回一个尺寸对象和一个科技等级
    local scale, lvl = TurretGenerator.getScale(type, scaleTech)

    -- 如果coaxialPossible为true，则根据尺寸对象的usedSlots属性和一个随机数判断炮塔是否为同轴的
    -- 如果usedSlots大于等于5，并且随机数小于0.25，则炮塔为同轴的
    if coaxialPossible then
        turret.coaxial = (scale.usedSlots >= 5) and rand:test(0.25)
    -- 如果coaxialPossible为false，则炮塔不为同轴的
    else
        turret.coaxial = false
    end

    -- 设置炮塔的尺寸为尺寸对象的size属性
    turret.size = scale.size
    -- 设置炮塔的槽位为尺寸对象的usedSlots属性
    turret.slots = scale.usedSlots
    -- 设置炮塔的转速为炮塔尺寸、turnSpeedFactor和一个随机数的乘积
    -- 炮塔尺寸越大，转速越低
    turret.turningSpeed = lerp(turret.size, 0.5, 3, 1, 0.5) * rand:getFloat(0.8, 1.2) * turnSpeedFactor

    -- 定义一个局部变量coaxialDamageScale，表示同轴武器的伤害系数
    -- 如果炮塔为同轴的，则为3，否则为1
    local coaxialDamageScale = turret.coaxial and 3 or 1

    -- 调用turret的getWeapons函数，返回一个武器对象的列表
    local weapons = {turret:getWeapons()}
    -- 遍历武器列表，对每个武器对象
    for _, weapon in pairs(weapons) do
        -- 将武器的本地位置乘以炮塔的尺寸
        weapon.localPosition = weapon.localPosition * scale.size

        -- 如果尺寸对象的usedSlots属性大于1，则根据usedSlots和coaxialDamageScale调整武器的各项属性
        if scale.usedSlots > 1 then
            -- 线性地调整武器的伤害、修复、力量等属性
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

            -- 定义一个局部变量increase，表示武器的射程增加的比例
            local increase = 0
            -- 如果武器类型为采矿激光或拆解激光，则射程增加的比例更大
            if type == WeaponType.MiningLaser or type == WeaponType.SalvagingLaser then
                -- 采矿和拆解激光的射程增加的比例为尺寸对象的size属性加上0.5再减去1
                -- mining and salvaging laser reach is scaled more
                increase = (scale.size + 0.5) - 1
            -- 如果武器类型为其他，则射程增加的比例较小
            else
                -- 其他类型的武器的射程增加的比例为尺寸对象的usedSlots属性减去1再乘以0.15
                -- scale reach a little
                increase = (scale.usedSlots - 1) * 0.15
            end

            -- 将武器的射程乘以1加上increase
            weapon.reach = weapon.reach * (1 + increase)

            -- 定义一个局部变量shotSizeFactor，表示武器的射击大小的系数，为尺寸对象的size属性乘以2
            local shotSizeFactor = scale.size * 2
            -- 如果武器是弹射物，则调整弹射物的大小和速度
            if weapon.isProjectile then
                -- 定义一个局部变量velocityIncrease，表示弹射物的速度增加的比例，为尺寸对象的usedSlots属性减去1再乘以0.25
                local velocityIncrease = (scale.usedSlots - 1) * 0.25

                -- 将弹射物的大小乘以shotSizeFactor
                weapon.psize = weapon.psize * shotSizeFactor
                -- 将弹射物的速度乘以1加上velocityIncrease
                weapon.pvelocity = weapon.pvelocity * (1 + velocityIncrease)
            end
            -- 如果武器是光束，则调整光束的宽度
            if weapon.isBeam then weapon.bwidth = weapon.bwidth * shotSizeFactor end
        end
    end

    -- 调用turret的clearWeapons函数，清除炮塔上的武器
    turret:clearWeapons()
    -- 遍历武器列表，对每个武器对象
    for _, weapon in pairs(weapons) do
        -- 调用turret的addWeapon函数，将武器添加到炮塔上
        turret:addWeapon(weapon)
    end

    -- 返回科技等级
    return lvl
end


-- 定义一个getScale函数，用于根据武器类型和科技等级获取炮塔的尺寸对象和等级
-- 参数：
-- type: 一个WeaponType枚举值，表示武器的类型
-- tech: 一个数字，表示武器的科技等级
-- 返回值：
-- 一个尺寸对象，包含from, to, size, usedSlots四个属性，分别表示科技等级的范围，炮塔的尺寸和槽位
-- 一个数字，表示炮塔的等级
function TurretGenerator.getScale(type, tech)
    -- 遍历scales表中type对应的子表，每个子表是一个尺寸对象，同时记录其等级
    for lvl, scale in pairs(scales[type]) do
        -- 如果tech在尺寸对象的from和to之间，则返回该尺寸对象和等级
        if tech >= scale.from and tech <= scale.to then return scale, lvl end
    end

    -- 如果没有找到合适的尺寸对象，则返回一个默认的尺寸对象
    return {from = 0, to = 0, size = 1, usedSlots = 1}
end


-- 定义一个局部变量i，初始值为0
local i = 0
-- 定义一个局部函数c，用于返回i的值并将i加1
local function c() i = i + 1 return i end

-- 定义一个Specialty表，用于存储不同的武器特性
local Specialty =
{
    HighDamage = c(), -- 高伤害
    HighRange = c(), -- 高射程
    HighFireRate = c(), -- 高射速
    HighAccuracy = c(), -- 高精度
    BurstFireEnergy = c(), -- 能量爆发
    BurstFire = c(), -- 物理爆发
    HighEfficiency = c(), -- 高效率，只适用于采矿和拆解激光
    HighShootingTime = c(), -- 高射击时间
    LessEnergyConsumption = c(), -- 低能耗
    IonizedProjectile = c(), -- 离子弹射物
}

-- 将i和c设置为nil，释放内存
i = nil
c = nil

-- 将Specialty表赋值给TurretGenerator的Specialty属性，方便其他模块使用
TurretGenerator.Specialty = Specialty

-- 定义一个局部变量possibleSpecialties，用于存储不同类型的武器可能拥有的特性和概率
local possibleSpecialties = {}
-- 激光武器可能拥有低能耗，高伤害，高射程三种特性，各自的概率为0.2，0.25，0.2
possibleSpecialties[WeaponType.Laser] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.25},
    {specialty = Specialty.HighRange, probability = 0.2},
}

-- 特斯拉武器可能拥有低能耗，高伤害，高射程三种特性，各自的概率为0.2，0.2，0.1
possibleSpecialties[WeaponType.TeslaGun] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.2},
    {specialty = Specialty.HighRange, probability = 0.1},
}

-- 闪电武器可能拥有低能耗，高伤害，高射程，高射速，高精度五种特性，各自的概率为0.15，0.15，0.2，0.2，0.15
possibleSpecialties[WeaponType.LightningGun] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.15},
    {specialty = Specialty.HighDamage, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.2},
    {specialty = Specialty.HighFireRate, probability = 0.2},
    {specialty = Specialty.HighAccuracy, probability = 0.15},
}

-- 采矿激光武器可能拥有高效率，高伤害，高射程三种特性，各自的概率为0.3，0.1，0.1
possibleSpecialties[WeaponType.MiningLaser] = {
    {specialty = Specialty.HighEfficiency, probability = 0.3},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
}
-- 原始采矿激光武器和采矿激光武器的可能特性相同
possibleSpecialties[WeaponType.RawMiningLaser] = possibleSpecialties[WeaponType.MiningLaser]

-- 拆解激光武器可能拥有高效率，高伤害，高射程三种特性，各自的概率为0.3，0.1，0.1
possibleSpecialties[WeaponType.SalvagingLaser] = {
    {specialty = Specialty.HighEfficiency, probability = 0.3},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
}
-- 原始拆解激光武器和拆解激光武器的可能特性相同
possibleSpecialties[WeaponType.RawSalvagingLaser] = possibleSpecialties[WeaponType.SalvagingLaser]

-- 修复光束武器可能拥有低能耗，高伤害，高射程三种特性，各自的概率为0.2，0.2，0.1
possibleSpecialties[WeaponType.RepairBeam] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.2},
    {specialty = Specialty.HighRange, probability = 0.1},
}

-- 等离子武器可能拥有低能耗，高伤害，高射速，高射程，高精度，能量爆发六种特性，各自的概率为0.2，0.1，0.1，0.1，0.1，0.1
possibleSpecialties[WeaponType.PlasmaGun] = {
    {specialty = Specialty.LessEnergyConsumption, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighFireRate, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.HighAccuracy, probability = 0.1},
    {specialty = Specialty.BurstFireEnergy, probability = 0.1},
}


-- 炮弹武器可能拥有高射击时间，高射程，高伤害，高精度四种特性，各自的概率为0.2，0.1，0.1，0.1
possibleSpecialties[WeaponType.Cannon] = {
    {specialty = Specialty.HighShootingTime, probability = 0.2},
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighAccuracy, probability = 0.1},
}

-- 连发炮武器可能拥有高伤害，高射程，离子弹射物，高射速，高精度，物理爆发六种特性，各自的概率为0.1，0.1，0.05，0.2，0.2，0.1
possibleSpecialties[WeaponType.ChainGun] = {
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.IonizedProjectile, probability = 0.05},
    {specialty = Specialty.HighFireRate, probability = 0.2},
    {specialty = Specialty.HighAccuracy, probability = 0.2},
    {specialty = Specialty.BurstFire, probability = 0.1},
}

-- 近防连发炮武器可能拥有高射程一种特性，概率为0.1
possibleSpecialties[WeaponType.PointDefenseChainGun] = {
    {specialty = Specialty.HighRange, probability = 0.1},
}

-- 近防激光武器可能拥有高射程一种特性，概率为0.1
possibleSpecialties[WeaponType.PointDefenseLaser] = {
    {specialty = Specialty.HighRange, probability = 0.1},
}

-- 螺栓武器可能拥有高射击时间，高射速，高精度，高伤害，物理爆发，高射程六种特性，各自的概率为0.25，0.15，0.15，0.1，0.15，0.1
possibleSpecialties[WeaponType.Bolter] = {
    {specialty = Specialty.HighShootingTime, probability = 0.25},
    {specialty = Specialty.HighFireRate, probability = 0.15},
    {specialty = Specialty.HighAccuracy, probability = 0.15},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.BurstFire, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.1},
}

-- 磁轨炮武器可能拥有高射击时间，高伤害，高射程，高精度，高射速五种特性，各自的概率为0.25，0.1，0.25，0.25，0.1
possibleSpecialties[WeaponType.RailGun] = {
    {specialty = Specialty.HighShootingTime, probability = 0.25},
    {specialty = Specialty.HighDamage, probability = 0.1},
    {specialty = Specialty.HighRange, probability = 0.25},
    {specialty = Specialty.HighAccuracy, probability = 0.25},
    {specialty = Specialty.HighFireRate, probability = 0.10},
}

-- 火箭发射器武器可能拥有高射击时间，高伤害，高射速，高射程，物理爆发五种特性，各自的概率为0.2，0.15，0.15，0.25，0.1
possibleSpecialties[WeaponType.RocketLauncher] = {
    {specialty = Specialty.HighShootingTime, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.15},
    {specialty = Specialty.HighFireRate, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.25},
    {specialty = Specialty.BurstFire, probability = 0.1},
}

-- 推力枪武器可能拥有高射程一种特性，概率为0.2
possibleSpecialties[WeaponType.ForceGun] = {
    {specialty = Specialty.HighRange, probability = 0.2},
}

-- 脉冲炮武器可能拥有高射击时间，高伤害，高射速，高精度，高射程，能量爆发六种特性，各自的概率为0.2，0.15，0.15，0.15，0.15，0.3
possibleSpecialties[WeaponType.PulseCannon] = {
    {specialty = Specialty.HighShootingTime, probability = 0.2},
    {specialty = Specialty.HighDamage, probability = 0.15},
    {specialty = Specialty.HighFireRate, probability = 0.15},
    {specialty = Specialty.HighAccuracy, probability = 0.15},
    {specialty = Specialty.HighRange, probability = 0.15},
    {specialty = Specialty.BurstFire, probability = 0.3},
}

-- 反战斗机武器可能拥有高射程，高射速，高伤害三种特性，各自的概率为0.1，0.1，0.1
possibleSpecialties[WeaponType.AntiFighter] = {
    {specialty = Specialty.HighRange, probability = 0.1},
    {specialty = Specialty.HighFireRate, probability = 0.1},
    {specialty = Specialty.HighDamage, probability = 0.1},
}


-- 定义一个addSpecialties函数，用于为炮塔添加特性
-- 参数：
-- rand: 一个Random对象，用于生成随机数
-- turret: 一个Turret对象，表示要添加特性的炮塔
-- type: 一个WeaponType枚举值，表示武器的类型
-- customSpecialties: 一个表或nil，表示自定义的特性和概率，如果不为空，则覆盖possibleSpecialties表中的内容
-- forbiddenSpecialties: 一个表或nil，表示禁止的特性，如果不为空，则从possibleSpecialties表中排除这些特性
-- 返回值：
-- 无
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
