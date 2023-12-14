-- 定义一个package.path变量，用于指定lua模块的搜索路径，将"data/scripts/lib/?.lua"添加到原有的路径中
package.path = package.path .. ";data/scripts/lib/?.lua"

-- 使用include函数，加载galaxy, randomext和weapontype三个模块，这些模块提供了一些关于星系，随机数和武器类型的函数
include("galaxy")
include("randomext")
include("weapontype")

-- 定义一个WeaponGenerator表，用于存储生成不同类型武器的函数
local WeaponGenerator = {}

-- 定义一个WeaponGenerator.generateBolter函数，用于生成螺栓武器
-- 参数：
-- rand: 一个Random对象，用于生成随机数
-- dps: 一个数字，表示武器的每秒伤害
-- tech: 一个数字，表示武器的科技等级
-- material: 一个Material枚举值，表示武器的材料
-- rarity: 一个Rarity枚举值，表示武器的稀有度
-- 返回值：
-- 一个Weapon对象，表示生成的螺栓武器
function WeaponGenerator.generateBolter(rand, dps, tech, material, rarity)
    -- 创建一个Weapon对象，并将其赋值给局部变量weapon
    local weapon = Weapon()
    -- 调用Weapon对象的setProjectile方法，设置武器为发射弹射物的类型
    weapon:setProjectile()

    -- 使用rand对象的getFloat方法，生成一个0.1到0.3之间的随机数，作为武器的开火间隔，并赋值给局部变量fireDelay
    local fireDelay = rand:getFloat(0.1, 0.3)
    -- 使用rand对象的getFloat方法，生成一个650到700之间的随机数，作为武器的射程，并赋值给weapon对象的reach属性
    local reach = rand:getFloat(650, 700)
    -- 计算武器的单次伤害，等于每秒伤害乘以开火间隔，并赋值给局部变量damage
    local damage = dps * fireDelay
    -- 使用rand对象的getFloat方法，生成一个800到1000之间的随机数，作为弹射物的速度，并赋值给局部变量velocity
    local velocity = rand:getFloat(800, 1000)
    -- 计算弹射物的最大飞行时间，等于射程除以速度，并赋值给局部变量maximumTime
    local maximumTime = reach / velocity

    -- 将弹射物的速度赋值给weapon对象的pvelocity属性
    weapon.pvelocity = velocity
    -- 将开火间隔赋值给weapon对象的fireDelay属性
    weapon.fireDelay = fireDelay
    -- 将射程赋值给weapon对象的reach属性
    weapon.reach = reach
    -- 使用rand对象的getInt方法，生成一个随机整数，作为武器的外观种子，并赋值给weapon对象的appearanceSeed属性
    weapon.appearanceSeed = rand:getInt()
    -- 将WeaponAppearance.Bolter枚举值赋值给weapon对象的appearance属性，表示武器的外观类型为螺栓武器
    weapon.appearance = WeaponAppearance.Bolter
    -- 将"Bolter /* Weapon Name*/"%_T字符串赋值给weapon对象的name属性，表示武器的名称为螺栓武器
    weapon.name = "Bolter /* Weapon Name*/"%_T
    -- 将"Bolter /* Weapon Prefix*/"%_T字符串赋值给weapon对象的prefix属性，表示武器的前缀为螺栓
    weapon.prefix = "Bolter /* Weapon Prefix*/"%_T
    -- 将"data/textures/icons/bolter.png"字符串赋值给weapon对象的icon属性，表示武器的图标文件路径
    weapon.icon = "data/textures/icons/bolter.png" -- previously sentry-gun.png
    -- 将"bolter"字符串赋值给weapon对象的sound属性，表示武器的开火音效
    weapon.sound = "bolter"
    -- 使用rand对象的getFloat方法，生成一个0到0.03之间的随机数，从0.99中减去，作为武器的精度，并赋值给weapon对象的accuracy属性
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.03)

    -- 将单次伤害赋值给weapon对象的damage属性
    weapon.damage = damage
    -- 将DamageType.AntiMatter枚举值赋值给weapon对象的damageType属性，表示武器的伤害类型为反物质
    weapon.damageType = DamageType.AntiMatter
    -- 将ImpactParticles.Physical枚举值赋值给weapon对象的impactParticles属性，表示武器的碰撞粒子效果为物理
    weapon.impactParticles = ImpactParticles.Physical
    -- 将1赋值给weapon对象的impactSound属性，表示武器的碰撞音效
    weapon.impactSound = 1

    -- 100 % chance for antimatter
    -- 100%的概率为武器添加反物质伤害
    -- 调用WeaponGenerator表的addAntiMatterDamage方法，传入rand, weapon, rarity, 2.5, 0.15, 0.2，根据稀有度和一些系数为武器添加反物质伤害
    WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2.5, 0.15, 0.2)

    -- 使用rand对象的getFloat方法，生成一个0.15到0.25之间的随机数，作为弹射物的大小，并赋值给weapon对象的psize属性
    weapon.psize = rand:getFloat(0.15, 0.25)
    -- 将弹射物的最大飞行时间赋值给weapon对象的pmaximumTime属性
    weapon.pmaximumTime = maximumTime
    -- 创建一个Color对象，并将其赋值给局部变量color
    local color = Color()
    -- 调用Color对象的setHSV方法，使用rand对象的getFloat方法生成一个10到60之间的随机数，以及0.7和1作为参数，设置color对象的颜色为一个随机的黄色
    color:setHSV(rand:getFloat(10, 60), 0.7, 1)
    -- 将color对象赋值给weapon对象的pcolor属性，表示弹射物的颜色
    weapon.pcolor = color

    -- 使用rand对象的test方法，以0.05的概率判断是否为武器添加多发特性
    if rand:test(0.05) then
        -- 定义一个局部变量shots，是一个包含2, 2, 2, 2, 2, 3, 4的表，表示可能的多发数量
        local shots = {2, 2, 2, 2, 2, 3, 4}
        -- 使用rand对象的getInt方法，生成一个1到表长度之间的随机整数，作为索引，从shots表中取出一个值，赋值给weapon对象的shotsFired属性，表示武器的每次开火发射的弹射物数量
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        -- 将武器的单次伤害乘以1.5，再除以多发数量，重新赋值给weapon对象的damage属性，表示武器的每个弹射物的伤害
        weapon.damage = weapon.damage * 1.5 / weapon.shotsFired
    end

    -- 调用WeaponGenerator表的adaptWeapon方法，传入rand, weapon, tech, material, rarity，根据科技等级，材料和稀有度调整武器的属性
    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- 将武器的伤害

    weapon.recoil = weapon.damage * 16

    return weapon
end

function WeaponGenerator.generateMiningLaser(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    weapon.fireDelay = 0.2
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = 75
    weapon.recoil = 0
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.MiningLaser
    weapon.name = "Mining Laser /* Weapon Name*/"%_T
    weapon.prefix = "Mining /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/mining-laser.png" -- previously mining.png
    weapon.sound = "mining"

    weapon.damage = dps * weapon.fireDelay
    weapon.damageType = DamageType.Energy
    weapon.smaterial = material
    weapon.stoneDamageMultiplier = WeaponGenerator.getStoneDamageMultiplier()
    weapon.shieldDamageMultiplier = 0
    weapon.stoneRefinedEfficiency = math.abs(0.15 + rand:getFloat(0, 0.015) + rarity.value * 0.015)

    weapon.bshape = BeamShape.Straight
    weapon.bouterColor = ColorRGB(0.1, 0.1, 0.1)
    weapon.binnerColor = ColorARGB(material.color.a * 0.5, material.color.r * 0.5, material.color.g * 0.5, material.color.b * 0.5)
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptMiningLaser(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generateSalvagingLaser(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    weapon.fireDelay = 0.2
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = 75
    weapon.recoil = 0
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.MiningLaser
    weapon.name = "Salvaging Laser /* Weapon Name*/"%_T
    weapon.prefix = "Salvaging /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/salvage-laser.png" -- previously recycle.png
    weapon.sound = "salvaging"

    weapon.damage = dps * weapon.fireDelay
    weapon.damageType = DamageType.Energy
    weapon.smaterial = material
    weapon.stoneDamageMultiplier = 0.01
    weapon.shieldDamageMultiplier = 0
    weapon.metalRefinedEfficiency = math.abs(0.12 + rand:getFloat(0, 0.01) + rarity.value * 0.01)

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Straight
    weapon.bouterColor = ColorRGB(0.1, 0.1, 0.1)
    weapon.binnerColor = ColorARGB(material.color.a * 0.5, material.color.r * 0.5, material.color.g * 0.5, material.color.b * 0.5)
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generateRawMiningLaser(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    weapon.fireDelay = 0.2
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = 150
    weapon.recoil = 0
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.MiningLaser
    weapon.name = "R-Mining Laser /* Weapon Name*/"%_T -- keep for legacy compatibility
    weapon.prefix = "R-Mining /* Weapon Prefix*/"%_T -- keep for legacy compatibility
    weapon.name = "R-Mining Laser /* Weapon Name, the R- abbreviation refers to Raw Mining */"%_T
    weapon.prefix = "R-Mining /* Weapon Prefix, the R- abbreviation refers to Raw Mining */"%_T
    weapon.icon = "data/textures/icons/r-mining-laser.png"
    weapon.sound = "raw-mining"

    weapon.damage = dps * weapon.fireDelay
    weapon.damageType = DamageType.Energy
    weapon.smaterial = material
    weapon.stoneDamageMultiplier = WeaponGenerator.getStoneDamageMultiplier()
    weapon.shieldDamageMultiplier = 0
    weapon.stoneRawEfficiency = math.abs(0.63 + rand:getFloat(0, 0.06) + rarity.value * 0.06)

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Straight
    weapon.bouterColor = ColorRGB(0.1, 0.1, 0.1)
    weapon.binnerColor = ColorARGB(material.color.a * 0.5, material.color.r * 0.5, material.color.g * 0.5, material.color.b * 0.5)
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptMiningLaser(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generateRawSalvagingLaser(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    weapon.fireDelay = 0.2
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = 150
    weapon.recoil = 0
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.MiningLaser
    weapon.name = "R-Salvaging Laser /* Weapon Name*/"%_T -- keep for legacy compatibility
    weapon.prefix = "R-Salvaging /* Weapon Prefix*/"%_T -- keep for legacy compatibility
    weapon.name = "R-Salvaging Laser /* Weapon Name, the R- abbreviation refers to Raw Salvaging */"%_T
    weapon.prefix = "R-Salvaging /* Weapon Prefix, the R- abbreviation refers to Raw Salvaging */"%_T
    weapon.icon = "data/textures/icons/r-salvaging-laser.png"
    weapon.sound = "raw-salvaging"

    weapon.damage = dps * weapon.fireDelay
    weapon.damageType = DamageType.Energy
    weapon.smaterial = material
    weapon.stoneDamageMultiplier = 0.01
    weapon.shieldDamageMultiplier = 0
    weapon.metalRawEfficiency = math.abs(0.45 + rand:getFloat(0, 0.05) + rarity.value * 0.05)

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Straight
    weapon.bouterColor = ColorRGB(0.1, 0.1, 0.1)
    weapon.binnerColor = ColorARGB(material.color.a * 0.5, material.color.r * 0.5, material.color.g * 0.5, material.color.b * 0.5)
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generateLightningGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    local fireDelay = rand:getFloat(1, 2.5)
    local reach = rand:getFloat(950, 1400)
    local damage = dps * fireDelay * 1.15

    weapon.fireDelay = fireDelay
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = reach
    weapon.continuousBeam = false
    weapon.appearance = WeaponAppearance.Tesla
    weapon.name = "Lightning Gun /* Weapon Name*/"%_T
    weapon.prefix = "Lightning /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/lightning-gun.png" -- previously lightning-branches.png
    weapon.sound = "lightning"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Energy
    weapon.stoneDamageMultiplier = 0
    weapon.impactSound = 1

    -- 100 % chance for electric damage
    WeaponGenerator.addElectricDamage(weapon)

    -- 10 % chance for plasma
    if rand:test(0.1) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Lightning
    weapon.bwidth = 0.5
    weapon.bauraWidth = 3
    weapon.banimationSpeed = 0
    weapon.banimationAcceleration = 0
    weapon.bshapeSize = 13

    -- shades of blue
    weapon.bouterColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
    weapon.binnerColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.1, 0.5), 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 5

    return weapon
end

function WeaponGenerator.generateTeslaGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(250, 350)
    local damage = dps * fireDelay * 2.0

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Tesla
    weapon.name = "Tesla Gun /* Weapon Name*/"%_T
    weapon.prefix = "Tesla /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/tesla-gun.png" -- previously lightning-frequency.png
    weapon.sound = "tesla"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.06)

    local hue = rand:getFloat(0, 360)

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Energy
    weapon.stoneDamageMultiplier = 0
    weapon.blength = weapon.reach

    -- 100 % chance for electric
    WeaponGenerator.addElectricDamage(weapon)

    -- 10 % chance for plasma
    if rand:test(0.1) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.bouterColor = ColorHSV(hue, 1, rand:getFloat(0.1, 0.3))
    weapon.binnerColor = ColorHSV(hue + rand:getFloat(-120, 120), 0.3, rand:getFloat(0.7, 0.8))
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4
    weapon.bshape = BeamShape.Lightning
    weapon.bshapeSize = 5

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generatePointDefenseLaser(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(500, 600)
    local damage = (5 + (rarity.value * 0.25)) * 0.1
    damage = damage + tech * 0.05

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Laser
    weapon.name = "Point Defense Laser /* Weapon Name*/"%_T
    weapon.prefix = "Point Defense Laser /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/point-defense-laser.png" -- previously laser-gun.png and even older laser-blast.png
    weapon.sound = "pd-laser"

    local hue = rand:getFloat(0, 360)

    weapon.damage = damage
    weapon.damageType = DamageType.Fragments
    weapon.blength = weapon.reach

    weapon.bouterColor = ColorHSV(hue, 1, rand:getFloat(0.1, 0.3))
    weapon.binnerColor = ColorHSV(hue + rand:getFloat(-120, 120), 0.3, rand:getFloat(0.7, 0.8))
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generateLaser(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(450, 750)
    local damage = dps * fireDelay * 1.5

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Laser
    weapon.name = "Laser /* Weapon Name*/"%_T
    weapon.prefix = "Laser /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/laser-gun.png" -- previously laser-blast.png
    weapon.sound = "laser"

    local hue = rand:getFloat(0, 360)

    weapon.damage = damage
    weapon.damageType = DamageType.Energy
    weapon.blength = weapon.reach

    -- 10 % chance for plasma
    if rand:test(0.1) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.bouterColor = ColorHSV(hue, 1, rand:getFloat(0.1, 0.3))
    weapon.binnerColor = ColorHSV(hue + rand:getFloat(-120, 120), 0.3, rand:getFloat(0.7, 0.8))
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generateRepairBeamEmitter(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(200, 300)

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Repair
    weapon.name = "Repair Beam /* Weapon Name*/"%_T
    weapon.prefix = "Repair /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/repair-beam.png" -- previously laser-heal.png
    weapon.sound = "repair"

    weapon.damageType = DamageType.Energy
    weapon.impactParticles = ImpactParticles.Energy
    if rand:test(0.5) then
        weapon.shieldRepair = dps * fireDelay * rand:getFloat(0.9, 1.1)
        weapon.bouterColor = ColorRGB(0.1, 0.2, 0.4)
        weapon.binnerColor = ColorRGB(0.2, 0.4, 0.9)
    else
        weapon.hullRepair = dps * fireDelay * rand:getFloat(0.9, 1.1)
        weapon.bouterColor = ColorARGB(0.5, 0, 0.5, 0)
        weapon.binnerColor = ColorRGB(1, 1, 1)

        weapon.shieldPenetration = 1
    end

    weapon.blength = weapon.reach
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4
    weapon.bshapeSize = 2
    weapon.bshape = BeamShape.Swirly

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.generateRailGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    local fireDelay = rand:getFloat(1, 2.5)
    local reach = rand:getFloat(950, 1400)
    local damage = dps * fireDelay

    weapon.fireDelay = fireDelay
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = reach
    weapon.continuousBeam = false
    weapon.appearance = WeaponAppearance.RailGun
    weapon.name = "Railgun /* Weapon Name*/"%_T
    weapon.prefix = "Railgun /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/rail-gun.png" -- previously beam.png
    weapon.sound = "railgun"
    weapon.accuracy = 0.999 - rand:getFloat(0, 0.01)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1
    weapon.blockPenetration = rand:getInt(3, 5 + rarity.value * 2)

    -- 10 % chance for antimatter
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 0.5
    weapon.bauraWidth = 3
    weapon.banimationSpeed = 1
    weapon.banimationAcceleration = -2

    if rand:getBool() then
        -- shades of red
        weapon.bouterColor = ColorHSV(rand:getFloat(10, 60), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
        weapon.binnerColor = ColorHSV(rand:getFloat(10, 60), rand:getFloat(0.1, 0.5), 1)
    else
        -- shades of blue
        weapon.bouterColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
        weapon.binnerColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.1, 0.5), 1)
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 20

    return weapon
end

function WeaponGenerator.generateForceGun(rand, _, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    -- DO NOT CHANGE THIS VALUE unless you adjust the code in ServerShot.cpp
    -- Their physics is balanced around this firing frequency
    local fireDelay = 0.2

    local reach = rand:getFloat(450, 550)

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Tesla
    weapon.name = "Force Gun /* Weapon Name*/"%_T
    weapon.prefix = "Force /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/force-gun.png" -- previously echo-ripples.png
    weapon.sound = "force"
    weapon.material = material
    weapon.rarity = rarity
    weapon.tech = tech

    -- lerp from tech 1 to 52
    local techFactor = lerp(tech, 1, 52, 0, 1)

    -- lerp by rarity
    local rarityFactor = lerp(rarity.value, -2 --[[-2 on purpose so factor is never 0]], 5, 0, 1)
    local forceFactor = techFactor * rarityFactor

    local minimum = 1500 -- can hold a container okayish
    local maximum = 1500000 -- can hold a normal resource-asteroid okayish

    weapon.holdingForce = lerp(forceFactor, 0, 1, minimum, maximum)

    weapon.impactParticles = ImpactParticles.Energy
    weapon.blength = weapon.reach
    weapon.banimationSpeed = 1

    weapon.bouterColor = ColorHSV(40, 1, 0.1)
    weapon.binnerColor = ColorHSV(40, 0.3, 0.3)
    weapon.bwidth = 2.0
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4
    weapon.bshape = BeamShape.Straight

    return weapon
end

function WeaponGenerator.generatePulseCannon(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    -- weaken dps to balance shield penetration
    dps = dps * 0.75

    local fireDelay = rand:getFloat(0.05, 0.2)
    local reach = rand:getFloat(450, 750)
    local damage = dps * fireDelay
    local speed = rand:getFloat(700, 800)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.PulseCannon
    weapon.name = "Pulse Cannon /* Weapon Name*/"%_T
    weapon.prefix = "Pulse Cannon /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/pulsecannon.png"
    weapon.sound = "pulsecannon"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.04)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1

    weapon.psize = rand:getFloat(0.08, 0.3)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(180, 290), 0.7, 1)

    -- 10 % chance for anti matter damage
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 10

    return weapon
end

function WeaponGenerator.generateAntiFighterGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    dps = dps * 0.1

    local fireDelay = rand:getFloat(2, 2.5)
    local reach = rand:getFloat(300, 350)
    local damage = dps * fireDelay
    damage = damage + tech * 0.05

    local speed = rand:getFloat(300, 400)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.AntiFighter
    weapon.name = "Anti-Fighter Gun /* Weapon Name */"%_T
    weapon.prefix = "Anti-Fighter /* Weapon Prefix */"%_T
    weapon.icon = "data/textures/icons/anti-fighter-gun.png" -- previously flak.png
    weapon.sound = "flak"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.Fragments
    weapon.impactParticles = ImpactParticles.DustExplosion
    weapon.impactSound = 1
    weapon.deathExplosion = true
    weapon.timedDeath = true
    weapon.explosionRadius = 35

    weapon.psize = rand:getFloat(0.3, 0.3)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 75 -- x75 to make up for the reduction to default damage above

    return weapon
end

function WeaponGenerator.generateChaingun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    local fireDelay = rand:getFloat(0.08, 0.12)
    local reach = rand:getFloat(300, 450)
    local damage = dps * fireDelay
    local speed = rand:getFloat(500, 700)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.ChainGun
    weapon.name = "Chaingun /* Weapon Name*/"%_T
    weapon.prefix = "Chaingun /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/chaingun.png" -- previously minigun.png
    weapon.sound = "chaingun"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.06)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1

    weapon.psize = rand:getFloat(0.05, 0.2)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)

    if rand:test(0.05) then
        local shots = {2, 2, 2, 2, 2, 3, 4}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = (weapon.damage * 1.5) / weapon.shotsFired
    end

    -- 7.5 % chance for anti matter damage / plasma damage
    if rand:test(0.075) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 1.5, 0.15, 0.2)
    elseif rand:test(0.075) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 1.5, 0.1, 0.15)
    elseif rand:test(0.05) then
        WeaponGenerator.addElectricDamage(weapon)
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    weapon.recoil = weapon.damage * 20

    return weapon
end

function WeaponGenerator.generatePointDefenseChaingun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    local fireDelay = rand:getFloat(0.075, 0.1)
    local reach = rand:getFloat(700, 750)
    local damage = (1.5 + (rarity.value * 0.25)) * 0.1
    damage = damage + tech * 0.05
    local speed = rand:getFloat(1000, 1100)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.ChainGun
    weapon.name = "Point Defense Cannon /* Weapon Name*/"%_T
    weapon.prefix = "Point Defense Cannon /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/point-defense-chaingun.png" -- previously minigun.png
    weapon.sound = "pd-chaingun"
    weapon.accuracy = 0.995

    weapon.damage = damage
    weapon.damageType = DamageType.Fragments
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1

    weapon.psize = rand:getFloat(0.05, 0.2)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 10

    return weapon
end

function WeaponGenerator.generatePlasmaGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    local fireDelay = rand:getFloat(0.15, 0.2)
    local reach = rand:getFloat(550, 800)
    local damage = dps * fireDelay
    local speed = rand:getFloat(500, 700)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.PlasmaGun
    weapon.name = "Plasma Gun /* Weapon Name*/"%_T
    weapon.prefix = "Plasma /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/plasma-gun.png" -- previously tesla-turret.png
    weapon.sound = "plasma"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.Plasma
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1
    weapon.pshape = ProjectileShape.Plasma

    -- 100 % chance for plasma damage
    WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2.5, 0.15, 0.2)

    weapon.psize = rand:getFloat(0.4, 0.8)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(0, 360), 0.7, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 4

    return weapon
end

function WeaponGenerator.generateRocketLauncher(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    local fireDelay = rand:getFloat(0.5, 1.5)
    local reach = rand:getFloat(1300, 1800)
    local damage = dps * fireDelay
    local speed = rand:getFloat(150, 200)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.seeker = rand:test(1 / 8)
    weapon.appearance = WeaponAppearance.RocketLauncher
    weapon.name = "Rocket Launcher /* Weapon Name*/"%_T
    weapon.prefix = "Launcher /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/rocket-launcher.png" -- previously missile-swarm.png
    weapon.sound = "launcher"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.02)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    -- 10 % chance for anti matter damage
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.psize = rand:getFloat(0.2, 0.4)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)
    weapon.pshape = ProjectileShape.Rocket

    if rand:test(0.05) then
        local shots = {2, 2, 2, 2, 2, 3, 4}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = (weapon.damage * 1.5) / weapon.shotsFired
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 2
    weapon.explosionRadius = math.sqrt(weapon.damage * 5)

    return weapon
end

function WeaponGenerator.generateCannon(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    local fireDelay = rand:getFloat(1.5, 2.5)
    local reach = rand:getFloat(1100, 1500)
    local damage = dps * fireDelay
    local speed = rand:getFloat(600, 800)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Cannon
    weapon.name = "Cannon /* Weapon Name*/"%_T
    weapon.prefix = "Cannon /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/cannon.png" -- previously hypersonic-bolt.png
    weapon.sound = "cannon"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.01)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    -- 10 % chance for anti matter damage
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.psize = rand:getFloat(0.2, 0.5)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 20
    weapon.explosionRadius = math.sqrt(weapon.damage * 5)

    return weapon
end

local generatorFunction = {}
generatorFunction[WeaponType.ChainGun            ] = WeaponGenerator.generateChaingun
generatorFunction[WeaponType.PointDefenseChainGun] = WeaponGenerator.generatePointDefenseChaingun
generatorFunction[WeaponType.PointDefenseLaser   ] = WeaponGenerator.generatePointDefenseLaser
generatorFunction[WeaponType.Laser               ] = WeaponGenerator.generateLaser
generatorFunction[WeaponType.MiningLaser         ] = WeaponGenerator.generateMiningLaser
generatorFunction[WeaponType.RawMiningLaser      ] = WeaponGenerator.generateRawMiningLaser
generatorFunction[WeaponType.SalvagingLaser      ] = WeaponGenerator.generateSalvagingLaser
generatorFunction[WeaponType.RawSalvagingLaser   ] = WeaponGenerator.generateRawSalvagingLaser
generatorFunction[WeaponType.PlasmaGun           ] = WeaponGenerator.generatePlasmaGun
generatorFunction[WeaponType.RocketLauncher      ] = WeaponGenerator.generateRocketLauncher
generatorFunction[WeaponType.Cannon              ] = WeaponGenerator.generateCannon
generatorFunction[WeaponType.RailGun             ] = WeaponGenerator.generateRailGun
generatorFunction[WeaponType.RepairBeam          ] = WeaponGenerator.generateRepairBeamEmitter
generatorFunction[WeaponType.Bolter              ] = WeaponGenerator.generateBolter
generatorFunction[WeaponType.LightningGun        ] = WeaponGenerator.generateLightningGun
generatorFunction[WeaponType.TeslaGun            ] = WeaponGenerator.generateTeslaGun
generatorFunction[WeaponType.ForceGun            ] = WeaponGenerator.generateForceGun
generatorFunction[WeaponType.PulseCannon         ] = WeaponGenerator.generatePulseCannon
generatorFunction[WeaponType.AntiFighter         ] = WeaponGenerator.generateAntiFighterGun

function WeaponGenerator.generateWeapon(rand, type, dps, tech, material, rarity)
    return generatorFunction[type](rand, dps, tech, material, rarity)
end

function WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    local dpsFactor = 1 + rarity.value * 0.4

    weapon.tech = tech
    weapon.material = material
    weapon.rarity = rarity

    if weapon.damage ~= 0 then weapon.damage = weapon.damage * dpsFactor end
    if weapon.shieldRepair ~= 0 then weapon.shieldRepair = weapon.shieldRepair * dpsFactor end
    if weapon.hullRepair ~= 0 then weapon.hullRepair = weapon.hullRepair * dpsFactor end
end

function WeaponGenerator.adaptMiningLaser(rand, weapon, tech, material, rarity)
    local dpsFactor = 1 + rarity.value * 0.05

    weapon.tech = tech
    weapon.material = material
    weapon.rarity = rarity

    if weapon.damage ~= 0 then weapon.damage = weapon.damage * dpsFactor end
end

function WeaponGenerator.getStoneDamageMultiplier()
    return 200
end

-- one function for each DamageType
function WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, flatFactor, randomMax, factor)
    flatFactor = flatFactor or 2
    randomMax = randomMax or 0.15
    factor = factor or 0.2

    -- add damagetype
    weapon.hullDamageMultiplier = flatFactor + rand:getFloat(0, randomMax) + rarity.value * factor
    weapon.damageType = DamageType.AntiMatter
end

function WeaponGenerator.addPhysicalDamage(weapon)
    weapon.damageType = DamageType.Physical
    weapon.hullDamageMultiplier = 1
end

function WeaponGenerator.addEnergyDamage(weapon)
    weapon.damageType = DamageType.Energy
    weapon.shieldDamageMultiplier = 1
end

function WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, flatFactor, randomMax, factor)
    flatFactor = flatFactor or 2
    randomMax = randomMax or 0.15
    factor = factor or 0.2

    -- add DamageType
    weapon.shieldDamageMultiplier = flatFactor + rand:getFloat(0, randomMax) + rarity.value * factor
    weapon.damageType = DamageType.Plasma
end

function WeaponGenerator.addElectricDamage(weapon)
    -- add DamageType
    weapon.damageType = DamageType.Electric
    weapon.stoneDamageMultiplier = 0
    weapon.hullDamageMultiplier = 1
    weapon.shieldDamageMultiplier = 1
end

function WeaponGenerator.addFragmentDamage(weapon)
    -- special damagetype for all point defense weapons
    -- add DamageType
    weapon.damageType = DamageType.Fragments
    weapon.hullDamageMultiplier = 1
    weapon.shieldDamageMultiplier = 1
end

return WeaponGenerator
