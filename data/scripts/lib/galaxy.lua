-- 以下代码用于设置模块的路径，以便游戏能够找到和加载模块
package.path = package.path .. ";data/scripts/lib/?.lua" -- 添加lib文件夹下的所有lua文件到模块路径中
package.path = package.path .. ";data/scripts/?.lua" -- 添加scripts文件夹下的所有lua文件到模块路径中

-- 以下代码用于引入一些已有的模块，以便使用它们提供的功能
include ("utility") -- 引入utility模块，提供一些实用的函数
include ("weapontype") -- 引入weapontype模块，提供一些关于武器类型的常量和函数

-- 以下代码用于定义一些本地变量，用于控制一些游戏参数
local blockRingMin = 147; -- 定义最小的方块环半径，单位为方块
local blockRingMax = 150; -- 定义最大的方块环半径，单位为方块

local shipVolumeInCenter = 2750 -- 定义银河中心区域的平均船只体积，单位为方块
local turretsInCenter = 25 -- 定义银河中心区域的平均船只炮塔数量

-- 以下代码用于定义一些全局函数，用于计算一些游戏参数，例如资源丰富度，奖励因子，船只体积等

-- 返回一个区域的资源丰富度因子，用于决定靠近银河中心的区域有多少更多的资源
-- 参数x, y是区域的坐标，scale是一个可选的缩放因子，默认为20
function Balancing_GetSectorRichnessFactor(x, y, scale)
    -- 靠近银河中心的区域应该有更多的资源
    scale = scale or 20 -- 如果没有给定scale参数，就使用默认值20
    local coords = vec2(x, y) -- 创建一个二维向量，表示区域的坐标

    local maxDist = Balancing_GetDimensions() / 2 -- 获取银河的最大距离，即银河的半径
    local dist = length(coords) -- 获取区域到银河中心的距离

    if dist > maxDist then dist = maxDist end -- 如果距离超过了最大距离，就将其限制为最大距离

    local linFactor = 1.0 - (dist / maxDist) -- 计算一个线性因子，范围从0到1，越靠近边缘越小
    local distFactor = linFactor + 1.0 -- 计算一个距离因子，范围从1到2
    distFactor = distFactor * distFactor * distFactor -- 将距离因子立方，使其从1增长到8


    local richness = distFactor * 2.0 - 2 -- 计算一个丰富度因子，使其从0增长到14
    richness = richness + linFactor * 6 -- 将丰富度因子与线性因子相加，使其从0增长到20

    return 1.0 + richness / 20 * scale -- 返回最终的资源丰富度因子，范围从1到1+scale
end

-- 返回一个区域的奖励因子，用于决定靠近银河中心的区域有多少更多的奖励
-- 参数x, y是区域的坐标
function Balancing_GetSectorRewardFactor(x, y)
    -- 靠近银河中心的区域应该有更多的奖励
    return Balancing_GetSectorRichnessFactor(x, y, 25) -- 调用上面定义的函数，使用缩放因子25
end


-- 返回一个区域的平均船只体积，取决于区域的位置
-- 参数x, y是区域的坐标
function Balancing_GetSectorShipVolume(x, y)
    -- 靠近银河中心的区域应该有更大的船只

    local coords = vec2(x, y) -- 创建一个二维向量，表示区域的坐标

    local maxDist = Balancing_GetDimensions() / 2 -- 获取银河的最大距离，即银河的半径
    local dist = length(coords) -- 获取区域到银河中心的距离

    if dist > maxDist then dist = maxDist end -- 如果距离超过了最大距离，就将其限制为最大距离
    local linFactor = 1.0 - (dist / maxDist) -- 计算一个线性因子，范围从0到1，越靠近边缘越小
    local linFactorOverall = linFactor -- 计算一个总体的线性因子，范围从0到1，越靠近边缘越小
    local linFactorOuter = math.min(1.0, math.max(0.0, 1.0 - (dist / 400))) -- 计算一个外部的线性因子，范围从0到1，当距离大于400时为0
    local linFactorMid = math.min(1.0, math.max(0.0, 1.0 - (dist / 350))) -- 计算一个中间的线性因子，范围从0到1，当距离大于350时为0

    local b = 150 -- 定义一个基础值，单位为方块
    local q = 1000 -- 定义一个二次项系数，单位为方块
    local loverall = 1000 -- 定义一个总体的线性项系数，单位为方块
    local louter = 2500 -- 定义一个外部的线性项系数，单位为方块
    local lmid = 2500 -- 定义一个中间的线性项系数，单位为方块

    local distFactor = linFactor * 3 + 1.0 -- 计算一个距离因子，范围从1到4
    distFactor = math.pow(distFactor, 4) - 1 -- 将距离因子四次方，使其从0增长到255

    local shipVolume = distFactor * (q / 255) -- 计算一个船只体积，开始时比较平缓，靠近中心时比较陡峭
    shipVolume = shipVolume + linFactorOverall * loverall -- 为船只体积添加一个总体的线性项，使得在外部区域也有一些进展
    shipVolume = shipVolume + linFactorOuter * louter -- 为船只体积添加一个外部的线性项，使得在内部区域难度增加
    shipVolume = shipVolume + linFactorMid * lmid -- 为船只体积添加一个中间的线性项，使得在内部区域难度增加

    shipVolume = shipVolume * (shipVolumeInCenter / (q + loverall + louter + lmid))

    shipVolume = shipVolume + b -- add a small basic factor so there are no ships with volume 0 in the outer regions

    return shipVolume
end

 shipVolume = shipVolume * (shipVolumeInCenter / (q + loverall + louter + lmid))

    shipVolume = shipVolume + b -- add a small basic factor so there are no ships with volume 0 in the outer regions

    return shipVolume
end

-- 以下代码用于计算一个区域的平均空间站体积，取决于区域的位置
-- 参数x, y是区域的坐标
function Balancing_GetSectorStationVolume(x, y)
    return math.min(150000, Balancing_GetSectorShipVolume(x, y) * 100) -- 返回一个区域的平均空间站体积，最大为150000方块，等于该区域的平均船只体积乘以100
end

-- 以下代码用于计算一个船只体积的偏差，用于增加船只体积的随机性
-- 参数f是一个可选的随机数，范围从0到1，默认为math.random()生成的随机数
function Balancing_GetShipVolumeDeviation(f)
    if not f then f = math.random() end -- 如果没有给定f参数，就使用math.random()生成一个随机数
    return 1.0 + 10.0 * f ^ 4.0 -- 返回一个船只体积的偏差，范围从1到11，越靠近1的概率越大
end

-- 以下代码用于计算一个空间站体积的偏差，用于增加空间站体积的随机性
-- 参数f是一个可选的随机数，范围从0到1，默认为math.random()生成的随机数
function Balancing_GetStationVolumeDeviation(f)
    if not f then f = math.random() end -- 如果没有给定f参数，就使用math.random()生成一个随机数
    return 1.0 + 2.5 * f ^ 3.0 -- 返回一个空间站体积的偏差，范围从1到3.5，越靠近1的概率越大
end

-- 以下代码用于计算一个区域的材料强度，取决于区域的位置
-- 参数x, y是区域的坐标
function Balancing_GetSectorMaterialStrength(x, y)
    local probabilities = Balancing_GetMaterialProbability(x, y) -- 调用一个函数，获取一个区域的各种材料的概率

    local strength = 0 -- 定义一个变量，用于累计一个区域的材料强度
    local strengthSum = 0 -- 定义一个变量，用于累计一个区域的材料概率之和
    for key, value in pairs(probabilities) do -- 遍历每一种材料及其概率
        strength = strength + value * Material(key).strengthFactor -- 将该材料的概率乘以该材料的强度系数，然后加到材料强度上
        strengthSum = strengthSum + value -- 将该材料的概率加到材料概率之和上
    end

    return strength / strengthSum -- 返回一个区域的材料强度，等于材料强度除以材料概率之和
end


-- 以下代码用于计算一个物体的技术等级，表示物体的技术强度
-- 参数x, y是物体所在的区域的坐标
function Balancing_GetTechLevel(x, y)
    -- 这只是一个数字，表示物体的技术强度
    -- 范围从0到...很多
    local coords = vec2(x, y) -- 创建一个二维向量，表示区域的坐标
    local dist = math.floor(length(coords)) -- 获取区域到银河中心的距离，取整数

    local tech = lerp(dist, 0, 500, 52, 1) -- 计算一个技术等级，使用线性插值函数，当距离为0时为52，当距离为500时为1

    return math.floor(tech + 0.5) -- 返回技术等级，四舍五入为整数
end

-- 以下代码用于根据技术等级获取一个区域的坐标，与上面的函数相反
-- 参数tech是技术等级
function Balancing_GetSectorByTechLevel(tech)
    local dist = lerp(tech, 1, 52, 500, 0) -- 计算一个距离，使用线性插值函数，当技术等级为1时为500，当技术等级为52时为0
    return math.floor(dist + 0.5), 0 -- 返回一个区域的坐标，x坐标为距离，四舍五入为整数，y坐标为0
end

-- 以下代码用于根据技术等级计算一个武器的伤害每秒（DPS）
-- 参数tech是技术等级
function Balancing_TechWeaponDPS(tech)
    local x, y = Balancing_GetSectorByTechLevel(tech); -- 根据技术等级获取一个区域的坐标
    return Balancing_GetSectorWeaponDPS(x, y) -- 调用一个函数，返回该区域的武器伤害每秒
end

-- 以下代码用于计算一个区域的平均炮塔数量，不取整数
-- 参数x, y是区域的坐标
function Balancing_GetSectorTurretsUnrounded(x, y)
    local dist = length(vec2(x, y)) -- 获取区域到银河中心的距离
    return lerp(dist, 460, 0, 2, turretsInCenter) -- 返回一个区域的平均炮塔数量，使用线性插值函数，当距离为460时为2，当距离为0时为turretsInCenter
end

-- 以下代码用于计算一个区域的平均炮塔数量，取整数
-- 参数x, y是区域的坐标
function Balancing_GetSectorTurrets(x, y)
    return math.floor(Balancing_GetSectorTurretsUnrounded(x, y)) -- 返回一个区域的平均炮塔数量，调用上面的函数，然后取整数
end

-- 以下代码用于计算一个区域的敌对船只的平均炮塔数量，不取整数
-- 参数x, y是区域的坐标
function Balancing_GetEnemySectorTurretsUnrounded(x, y)
    return Balancing_GetSectorTurretsUnrounded(x, y) * 1.5 -- 返回一个区域的敌对船只的平均炮塔数量，等于该区域的平均炮塔数量乘以1.5
end

-- 以下代码用于计算一个区域的敌对船只的平均炮塔数量，取整数
-- 参数x, y是区域的坐标
function Balancing_GetEnemySectorTurrets(x, y)
    return math.floor(Balancing_GetEnemySectorTurretsUnrounded(x, y)) -- 返回一个区域的敌对船只的平均炮塔数量，调用上面的函数，然后取整数
end


-- 以下代码用于计算一个区域的平均船只生命值（HP）
-- 参数x, y是区域的坐标
function Balancing_GetSectorShipHP(x, y)
    -- 该区域的平均船只大约有这么多的生命值
    -- 方块的平均耐久度为体积乘以4
    local materialStrength = Balancing_GetSectorMaterialStrength(x, y) -- 调用一个函数，获取该区域的材料强度
    local shipVolume = Balancing_GetSectorShipVolume(x, y) -- 调用一个函数，获取该区域的平均船只体积

    return shipVolume * materialStrength * 4.0 -- 返回该区域的平均船只生命值，等于船只体积乘以材料强度乘以4
end


-- 以下代码用于计算一个区域的武器伤害每秒（DPS），用于决定一个平均船只需要多少时间才能摧毁另一个平均船只
-- 参数x, y是区域的坐标
function Balancing_GetSectorWeaponDPS(x, y)

    -- 这个函数创建了一个DPS与HP的比例，使得一个平均船只拥有平均数量的炮塔
    -- 需要15秒才能摧毁另一个平均船只
    local coords = vec2(x, y) -- 创建一个二维向量，表示区域的坐标

    local dist = length(coords) -- 获取区域到银河中心的距离

    local la = math.min(1.0, math.max(0.0, 1.0 - (dist / 800))) -- 计算一个线性因子，范围从0到1，当距离为800时为0
    local lb = math.min(1.0, math.max(0.0, 1.0 - (dist / 560))) -- 计算一个线性因子，范围从0到1，当距离为560时为0
    local lc = math.min(1.0, math.max(0.0, 1.0 - (dist / 470))) -- 计算一个线性因子，范围从0到1，当距离为470时为0
    local ld = math.min(1.0, math.max(0.0, 1.0 - (dist / 430))) -- 计算一个线性因子，范围从0到1，当距离为430时为0
    local le = math.min(1.0, math.max(0.0, 1.0 - (dist / 360))) -- 计算一个线性因子，范围从0到1，当距离为360时为0
    local lf = math.min(1.0, math.max(0.0, 1.0 - (dist / 310))) -- 计算一个线性因子，范围从0到1，当距离为310时为0
    local lg = math.min(1.0, math.max(0.0, 1.0 - (dist / 220))) -- 计算一个线性因子，范围从0到1，当距离为220时为0
    local lmin = math.min(1.0, math.max(0.0, 1.0 - (dist / 220))) -- 计算一个线性因子，范围从0到1，当距离为220时为0

    local dps = 0 -- 定义一个变量，用于累计一个区域的武器伤害每秒
    dps = math.max(dps, 95 * la) -- 将武器伤害每秒与95乘以la比较，取较大的值
    dps = math.max(dps, 190 * lb) -- 将武器伤害每秒与190乘以lb比较，取较大的值
    dps = math.max(dps, 310 * lc) -- 将武器伤害每秒与310乘以lc比较，取较大的值
    dps = math.max(dps, 370 * ld) -- 将武器伤害每秒与370乘以ld比较，取较大的值
    dps = math.max(dps, 470 * le) -- 将武器伤害每秒与470乘以le比较，取较大的值
    dps = math.max(dps, 550 * lf) -- 将武器伤害每秒与550乘以lf比较，取较大的值
    dps = math.max(dps, 650 * lg) -- 将武器伤害每秒与650乘以lg比较，取较大的值

    -- 添加一个上限，使得武器伤害每秒不会在靠近中心时爆炸性增长
    dps = math.min(dps, 100 * lmin + 500) -- 将武器伤害每秒与100乘以lmin加上500比较，取较小的值

    -- 最后也应用一个大小因子，因为这个因子也应该与Balancing_GetSectorShipVolume函数中的船只大小成比例
    local maximumHP = Balancing_GetSectorShipHP(0, 0) -- 获取银河中心区域的最大船只生命值
    local maximumTurrets = Balancing_GetSectorTurretsUnrounded(0, 0) -- 获取银河中心区域的最大炮塔数量
    local maximumDps = maximumHP / maximumTurrets / 15.0 -- 假设用一个完全武装的船只摧毁一个平均船只需要这么多秒，计算银河中心区域的最大武器伤害每秒

    -- print (maximumDps)

    dps = dps * (maximumDps / 600) -- 将武器伤害每秒乘以一个比例系数，使其与银河中心区域的最大武器伤害每秒成比例

    dps = math.max(dps, 18) -- 将武器伤害每秒与18比较，取较大的值

    return dps, Balancing_GetTechLevel(x, y) -- 返回武器伤害每秒和技术等级
end

-- 以下代码用于计算一个飞行器的武器伤害每秒（DPS），用于决定需要多少时间才能摧毁一个飞行器
-- 参数hp是飞行器的生命值
function Balancing_GetCraftWeaponDPS(hp)
    -- 强度是DPS，需要20秒才能摧毁一个飞行器
    local dps = hp / 20.0 -- 计算一个飞行器的武器伤害每秒，等于飞行器的生命值除以20

    return dps -- 返回武器伤害每秒
end

-- 以下代码用于计算一个区域的采矿激光的伤害每秒（DPS），用于决定开始时采矿的效率
-- 参数x, y是区域的坐标
function Balancing_GetSectorMiningDPS(x, y)
    -- 这是一个适合开始时采矿激光的值
    local dps = 3.0 -- 定义一个变量，表示采矿激光的伤害每秒

    local materialFactor = 1.0 + (Balancing_GetSectorMaterialStrength(x, y) - 1.0) * 0.1 -- 计算一个材料因子，等于1加上该区域的材料强度减去1再乘以0.1

    dps = dps * materialFactor -- 将采矿激光的伤害每秒乘以材料因子

    return dps, Balancing_GetTechLevel(x, y) -- 返回采矿激光的伤害每秒和技术等级
end

-- 以下代码用于计算一个区域的各种材料的概率，返回一个表格
-- 参数x, y是区域的坐标
function Balancing_GetMaterialProbability(x, y)
    -- 这个表格将被返回
    local result = {} -- 定义一个空的表格，用于存储各种材料的概率

    local coords = vec2(x, y) -- 创建一个二维向量，表示区域的坐标

    local distFromCenter = length(coords) / Balancing_GetMaxCoordinates() -- 计算区域到银河中心的距离，除以银河的最大坐标，得到一个范围从0到1的值
    local beltSize = Balancing_GetMaterialBeltSize() -- 调用一个函数，获取材料带的大小

    for i = 0, NumMaterials() - 1, 1 do -- 遍历每一种材料，从0到材料的数量减1，步长为1
        local beltRadius = Balancing_GetMaterialBeltRadius(i) -- 调用一个函数，获取第i种材料的材料带半径
        local distFromBelt = math.abs(distFromCenter - beltRadius) -- 计算区域到材料带的距离，取绝对值

        local start = beltRadius + beltSize * (1 + Balancing_GetMaterialExistanceThreshold()) -- 计算一个起始值，等于材料带半径加上材料带大小乘以1加上材料存在阈值
        local highest = beltRadius - beltSize * (1 + Balancing_GetMaterialExistanceThreshold()) -- 计算一个最高值，等于材料带半径减去材料带大小乘以1加上材料存在阈值
        local value = lerp(distFromCenter, start, highest, 0, 1 + (i * i)) -- 计算一个值，使用线性插值函数，当区域到银河中心的距离为start时为0，当为highest时为1加上i的平方

        local addition = lerp(distFromBelt, beltSize, 0, 0, (i * i) * 0.5, false) -- 计算一个附加值，使用线性插值函数，当区域到材料带的距离为beltSize时为0，当为0时为i的平方乘以0.5，不允许超出范围
        value = value + addition -- 将值与附加值相加

        result[i] = value -- 将值存储到表格中，以i为键
    end

    -- 总是添加一小部分钛，这样在开始时建造不会太令人沮丧
    if distFromCenter > 0.852 then -- 如果区域到银河中心的距离大于0.852
        result[0] = 0.9 -- 将第0种材料（钛）的概率设为0.9
        result[1] = 0.1 -- 将第1种材料（铁）的概率设为0.1
    end

    -- 永远不要在屏障外创建avorion
    if distFromCenter > Balancing_GetBlockRingMin() then -- 如果区域到银河中心的距离大于方块环的最小半径
        result[6] = 0 -- 将第6种材料（avorion）的概率设为0
    end

    local sum = 0 -- 定义一个变量，用于累计各种材料的概率之和
    for _, amount in pairs(result) do -- 遍历表格中的每一个值
        sum = sum + amount -- 将值加到概率之和上
    end

    -- 归一化
    for i = 0, NumMaterials() - 1, 1 do -- 遍历每一种材料
        result[i] = result[i] / sum -- 将表格中的值除以概率之和，使得各种材料的概率之和为1
    end

    return result -- 返回表格
end

-- 以下代码用于获取一个区域的最高可用材料，即概率大于0的最高编号的材料
-- 参数x, y是区域的坐标
function Balancing_GetHighestAvailableMaterial(x, y)
    local materialProbabilities = Balancing_GetMaterialProbability(x, y) -- 调用上面的函数，获取一个区域的各种材料的概率
    local highestMaterial = 0 -- 定义一个变量，用于存储最高可用材料
    for material, probability in pairs(materialProbabilities) do -- 遍历每一种材料及其概率
        if probability > 0 and material > highestMaterial then -- 如果概率大于0且材料编号大于最高可用材料
            highestMaterial = material -- 将最高可用材料更新为该材料
        end
    end

    return highestMaterial -- 返回最高可用材料
end

-- 以下代码用于获取一个区域的单一材料的概率
-- 参数x, y是区域的坐标，material是材料编号
function Balancing_GetSingleMaterialProbability(x, y, material)
    local probabilities = Balancing_GetMaterialProbability(x, y) -- 调用上面的函数，获取一个区域的各种材料的概率
    return probabilities[material] -- 返回指定材料的概率
end


-- 以下代码用于计算一个区域的技术材料的概率，返回一个表格
-- 参数x, y是区域的坐标
function Balancing_GetTechnologyMaterialProbability(x, y)
    local result = Balancing_GetMaterialProbability(x, y) -- 调用上面的函数，获取一个区域的各种材料的概率

    -- 只使用最强的3种可用材料来制造船只，炮塔等
    local picked = 0 -- 定义一个变量，用于记录已经选择的材料数量
    for i = 6, 0, -1 do -- 遍历每一种材料，从6到0，步长为-1
        if picked >= 3 then -- 如果已经选择了3种材料
            result[i] = 0 -- 将该材料的概率设为0
        elseif result[i] > 0 then -- 如果该材料的概率大于0
            picked = picked + 1 -- 将已选择的材料数量加1
        end
    end

    -- 归一化
    local sum = 0 -- 定义一个变量，用于累计各种材料的概率之和
    for _, p in pairs(result) do -- 遍历表格中的每一个值
        sum = sum + p -- 将值加到概率之和上
    end

    for k, p in pairs(result) do -- 遍历表格中的每一个键值对
        result[k] = p / sum -- 将值除以概率之和，使得各种材料的概率之和为1
    end

    return result -- 返回表格
end

-- 以下代码用于定义一个表格，存储各种武器类型的概率
local weaponProbabilities = {}

weaponProbabilities[WeaponType.ChainGun] =             {p = 2.5} -- 连发炮的概率为2.5
weaponProbabilities[WeaponType.PointDefenseChainGun] = {p = 1.0} -- 近防连发炮的概率为1.0
weaponProbabilities[WeaponType.MiningLaser] =          {p = 1.5} -- 采矿激光的概率为1.5
weaponProbabilities[WeaponType.RawMiningLaser] =       {d = 0.85, p = 1.5} -- 原始采矿激光的概率为1.5，只在距离中心小于0.85的区域出现
weaponProbabilities[WeaponType.SalvagingLaser] =       {p = 1.0} -- 打捞激光的概率为1.0
weaponProbabilities[WeaponType.RawSalvagingLaser] =    {d = 0.85, p = 1.0} -- 原始打捞激光的概率为1.0，只在距离中心小于0.85的区域出现
weaponProbabilities[WeaponType.Bolter] =               {d = 0.9, p = 1.0} -- 钉枪的概率为1.0，只在距离中心小于0.9的区域出现
weaponProbabilities[WeaponType.ForceGun] =             {d = 0.85, p = 1.0} -- 推力枪的概率为1.0，只在距离中心小于0.85的区域出现
weaponProbabilities[WeaponType.Laser] =                {d = 0.75, p = 2.0} -- 激光的概率为2.0，只在距离中心小于0.75的区域出现
weaponProbabilities[WeaponType.PointDefenseLaser] =    {d = 0.75, p = 1.0} -- 近防激光的概率为1.0，只在距离中心小于0.75的区域出现
weaponProbabilities[WeaponType.PlasmaGun] =            {d = 0.73, p = 2.0} -- 等离子枪的概率为2.0，只在距离中心小于0.73的区域出现
weaponProbabilities[WeaponType.PulseCannon] =          {d = 0.73, p = 1.0} -- 脉冲炮的概率为1.0，只在距离中心小于0.73的区域出现
weaponProbabilities[WeaponType.AntiFighter] =          {d = 0.7, p = 2.0} -- 反战斗机的概率为2.0，只在距离中心小于0.7的区域出现
weaponProbabilities[WeaponType.Cannon] =               {d = 0.65, p = 2.0} -- 加农炮的概率为2.0，只在距离中心小于0.65的区域出现
weaponProbabilities[WeaponType.RepairBeam] =           {d = 0.65, p = 2.0} -- 修复光束的概率为2.0，只在距离中心小于0.65的区域出现
weaponProbabilities[WeaponType.RocketLauncher] =       {d = 0.6, p = 1.0} -- 火箭发射器的概率为1.0，只在距离中心小于0.6的区域出现
weaponProbabilities[WeaponType.RailGun] =              {d = 0.6, p = 1.0} -- 磁轨炮的概率为1.0，只在距离中心小于0.6的区域出现
weaponProbabilities[WeaponType.LightningGun] =         {d = 0.45, p = 2.0} -- 闪电枪的概率为2.0，只在距离中心小于0.45的区域出现
weaponProbabilities[WeaponType.TeslaGun] =             {d = 0.4, p = 2.0} -- 特斯拉枪的概率为2.0，只在距离中心小于0.4的区域出现

-- 以下代码用于计算一个区域的武器类型的概率，返回一个表格
-- 参数x, y是区域的坐标
function Balancing_GetWeaponProbability(x, y)
    local distFromCenter = length(vec2(x, y)) / Balancing_GetMaxCoordinates() -- 计算区域到银河中心的距离，除以银河的最大坐标，得到一个范围从0到1的值

    local probabilities = {} -- 定义一个空的表格，用于存储各种武器类型的概率

    for t, specs in pairs(weaponProbabilities) do -- 遍历每一种武器类型及其规格
        if not specs.d or distFromCenter < specs.d then -- 如果没有规定距离限制，或者区域到银河中心的距离小于距离限制
            probabilities[t] = specs.p -- 将该武器类型的概率存储到表格中，以t为键
        end
    end

    return probabilities -- 返回表格
end

-- 以下代码用于计算一种材料的材料带半径，表示该材料在银河中的分布范围
-- 参数material是材料编号
function Balancing_GetMaterialBeltRadius(material)

    -- 编号越低的材料，离银河中心越远
    local level = NumMaterials() - material -- 计算材料的等级，等于材料的数量减去材料的编号

    local distanceFactor = level / (NumMaterials()) - 0.1 -- 计算一个距离因子，等于材料的等级除以材料的数量再减去0.1

    return distanceFactor -- 返回距离因子
end

-- 以下代码用于计算材料带的大小，表示材料在银河中的分布宽度
function Balancing_GetMaterialBeltSize()
    local outer = Balancing_GetMaterialBeltRadius(0) -- 调用上面的函数，获取编号为0的材料（钛）的材料带半径
    local inner = Balancing_GetMaterialBeltRadius(1) -- 调用上面的函数，获取编号为1的材料（铁）的材料带半径

    return (outer - inner) / 2 -- 返回材料带的大小，等于两种材料的材料带半径之差除以2
end

-- 以下代码用于计算材料存在的阈值，表示材料可以在其正常位置的多远处仍然被发现
function Balancing_GetMaterialExistanceThreshold()
    -- 材料可以在X乘以材料带大小的距离外仍然被发现
    return 0.5 -- 返回材料存在的阈值，为0.5
end

-- 以下代码用于计算银河的最大坐标，表示银河的边界
function Balancing_GetMaxCoordinates()
    return Balancing_GetDimensions() / 2 -- 返回银河的最大坐标，等于银河的尺寸除以2
end

-- 以下代码用于计算银河的最小坐标，表示银河的边界
function Balancing_GetMinCoordinates()
    return -(Balancing_GetDimensions() / 2 - 1) -- 返回银河的最小坐标，等于银河的尺寸除以2再取负数再减去1
end

-- 以下代码用于计算银河的尺寸，表示银河的大小
function Balancing_GetDimensions()
    return 1000 -- 返回银河的尺寸，为1000
end

-- 以下代码用于计算一个区域的海盗等级，表示海盗的强度
-- 参数x, y是区域的坐标
function Balancing_GetPirateLevel(x, y)
    local p = vec2(x, y) -- 创建一个二维向量，表示区域的坐标

    local dist = length(p) -- 计算区域到银河中心的距离

    local max = Balancing_GetMaxCoordinates(); -- 获取银河的最大坐标
    max = math.sqrt(max * max + max * max) -- 计算银河的对角线长度，作为银河的最大距离

    local level = (1 - (dist / max)) * 32; -- 计算海盗等级，使用线性插值函数，当距离为0时为32，当距离为max时为0

    return level; -- 返回海盗等级
end


-- 以下代码用于计算一种采矿激光对一种材料的伤害因子，表示采矿的效率
-- 参数laserMaterial是采矿激光的材料，minedMaterial是被采矿的材料
function Balancing_GetMaterialDamageFactor(laserMaterial, minedMaterial)
    local factor = laserMaterial.value - minedMaterial.value -- 计算一个因子，等于采矿激光的材料价值减去被采矿的材料价值
    factor = factor * 0.25 -- 将因子乘以0.25
    factor = factor + 1.0 -- 将因子加上1.0

    return math.max(0.0, factor) -- 返回因子，如果小于0则返回0
end

-- 以下代码用于判断一种材料是否可以被一种采矿激光采集
-- 参数minedMaterial是被采矿的材料，laserMaterial是采矿激光的材料
function Balancing_MineableBy(minedMaterial, laserMaterial)
    return laserMaterial.value + 1 >= minedMaterial.value -- 返回一个布尔值，表示采矿激光的材料价值加上1是否大于等于被采矿的材料价值
end

-- 以下代码用于获取方块环的最小半径，表示方块环在银河中的分布范围
function Balancing_GetBlockRingMin()
    return blockRingMin; -- 返回方块环的最小半径，为一个全局变量
end

-- 以下代码用于获取方块环的最大半径，表示方块环在银河中的分布范围
function Balancing_GetBlockRingMax()
    return blockRingMax; -- 返回方块环的最大半径，为一个全局变量
end

-- 以下代码用于判断一个区域是否在方块环内，表示该区域是否有方块存在
-- 参数x, y是区域的坐标
function Balancing_InsideRing(x, y)
    local d2 = x * x + y * y -- 计算区域到银河中心的距离的平方
    return d2 < blockRingMin * blockRingMin -- 返回一个布尔值，表示距离的平方是否小于方块环的最小半径的平方
end

-- 以下代码用于定义一个表格，存储银河的各种属性和函数
local Galaxy =
{

BlockRingMin = blockRingMin, -- 方块环的最小半径
BlockRingMax = blockRingMax, -- 方块环的最大半径
BlockRingMin2 = blockRingMin * blockRingMin, -- 方块环的最小半径的平方
BlockRingMax2 = blockRingMax * blockRingMax, -- 方块环的最大半径的平方

GetSectorRichnessFactor = Balancing_GetSectorRichnessFactor, -- 获取一个区域的富饶因子的函数
GetSectorRewardFactor = Balancing_GetSectorRewardFactor, -- 获取一个区域的奖励因子的函数
GetSectorShipVolume = Balancing_GetSectorShipVolume, -- 获取一个区域的平均船只体积的函数
GetSectorStationVolume = Balancing_GetSectorStationVolume, -- 获取一个区域的平均空间站体积的函数
GetShipVolumeDeviation = Balancing_GetShipVolumeDeviation, -- 获取一个船只体积的偏差的函数
GetStationVolumeDeviation = Balancing_GetStationVolumeDeviation, -- 获取一个空间站体积的偏差的函数
GetSectorMaterialStrength = Balancing_GetSectorMaterialStrength, -- 获取一个区域的材料强度的函数
GetTechLevel = Balancing_GetTechLevel, -- 获取一个物体的技术等级的函数
GetSectorWeaponDPS = Balancing_GetSectorWeaponDPS, -- 获取一个区域的武器伤害每秒的函数
GetCraftWeaponDPS = Balancing_GetCraftWeaponDPS, -- 获取一个飞行器的武器伤害每秒的函数
GetSectorMiningDPS = Balancing_GetSectorMiningDPS, -- 获取一个区域的采矿激光的伤害每秒的函数
GetMaterialProbability = Balancing_GetMaterialProbability, -- 获取一个区域的各种材料的概率的函数
GetTechnologyMaterialProbability = Balancing_GetTechnologyMaterialProbability, -- 获取一个区域的技术材料的概率的函数
GetSingleMaterialProbability = Balancing_GetSingleMaterialProbability, -- 获取一个区域的单一材料的概率的函数
GetMaterialBeltRadius = Balancing_GetMaterialBeltRadius, -- 获取一种材料的材料带半径的函数
GetMaterialBeltSize = Balancing_GetMaterialBeltSize, -- 获取材料带的大小的函数
GetMaterialExistanceThreshold = Balancing_GetMaterialExistanceThreshold, -- 获取材料存在的阈值的函数
GetMaxCoordinates = Balancing_GetMaxCoordinates, -- 获取银河的最大坐标的函数
GetMinCoordinates = Balancing_GetMinCoordinates, -- 获取银河的最小坐标的函数
GetDimensions = Balancing_GetDimensions, -- 获取银河的尺寸的函数
GetPirateLevel = Balancing_GetPirateLevel, -- 获取一个区域的海盗等级的函数
GetMaterialDamageFactor = Balancing_GetMaterialDamageFactor, -- 获取一种采矿激光对一种材料的伤害因子的函数
MineableBy = Balancing_MineableBy, -- 判断一种材料是否可以被一种采矿激光采集的函数
GetSectorTurrets = Balancing_GetSectorTurrets, -- 获取一个区域的平均炮塔数量的函数

}

return Galaxy -- 返回表格

