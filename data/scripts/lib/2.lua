-- weapontype.lua
-- 这个文件用来定义新的武器类型
-- 你可以在这里添加一些属性，函数，变量等
package.path = package.path .. ";data/scripts/lib/?.lua" -- 这一行是为了让mod能够使用游戏内置的库文件
require ("randomext") -- 这个库提供了一些随机数相关的函数
require ("utility") -- 这个库提供了一些实用的函数
require ("stringutility") -- 这个库提供了一些字符串相关的函数

WeaponType.NewRailGun = 16 -- 定义一个新的武器类型，数字不能和其他类型重复
WeaponType.NewRailGun.color = ColorRGB(0.8, 0.8, 1.0) -- 定义武器类型的颜色
WeaponType.NewRailGun.name = "New Railgun"%_t -- 定义武器类型的名称
WeaponType.NewRailGun.prefix = "New Railgun"%_t -- 定义武器类型的前缀
WeaponType.NewRailGun.sound = "railgun" -- 定义武器类型的声音
WeaponType.NewRailGun.accuracy = 0.999 -- 定义武器类型的精度
WeaponType.NewRailGun.shieldDamageMultiplicator = 5 -- 定义武器类型对护盾的伤害倍率
WeaponType.NewRailGun.hullDamageMultiplicator = 1 -- 定义武器类型对船体的伤害倍率
WeaponType.NewRailGun.stoneDamageMultiplicator = 1 -- 定义武器类型对矿石的伤害倍率
WeaponType.NewRailGun.shieldPenetration = 0 -- 定义武器类型的护盾穿透
WeaponType.NewRailGun.hullPenetration = 0 -- 定义武器类型的船体穿透
WeaponType.NewRailGun.stonePenetration = 0 -- 定义武器类型的矿石穿透
WeaponType.NewRailGun.damage = 10 -- 定义武器类型的基础伤害
WeaponType.NewRailGun.fireRate = 1 -- 定义武器类型的基础射速
WeaponType.NewRailGun.reach = 1000 -- 定义武器类型的基础射程
WeaponType.NewRailGun.appearance = WeaponAppearance.RailGun -- 定义武器类型的外观
WeaponType.NewRailGun.icon = "data/textures/icons/railgun.png" -- 定义武器类型的图标
WeaponType.NewRailGun.slots = {0, 1, 2, 3, 4, 5} -- 定义武器类型可以使用的槽位
WeaponType.NewRailGun.shotCount = 1 -- 定义武器类型每次发射的子弹数量
WeaponType.NewRailGun.shotSpeed = 1000 -- 定义武器类型的子弹速度
WeaponType.NewRailGun.shotLifetime = 10 -- 定义武器类型的子弹寿命
WeaponType.NewRailGun.shotSize = 0.5 -- 定义武器类型的子弹大小
WeaponType.NewRailGun.shotColor = ColorRGB(0.8, 0.8, 1.0) -- 定义武器类型的子弹颜色
