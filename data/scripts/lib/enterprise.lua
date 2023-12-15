package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
include ("basesystem")
include("utility")
include("randomext")
include("callable")

FixedEnergyRequirement = true

--[[

这里是顶级企业的函数库，使用include引用对游戏进行修改。

]]

----------------------------------------------
-- 这段函数用于给暗金教会随机增加一个乱码描述XDD
----------------------------------------------
local chars = {
    ["口"] = 2,
    ["鍒"] = 0.5,
    ["板"] = 0.5,
    ["簳"] = 0.5,
    ["浠"] = 0.5,
    ["涔"] = 0.5,
    ["堟"] = 0.5,
    ["椂"] = 0.5,
    ["鍊"] = 0.5,
    ["椤"] = 0.5,
    ["紑"] = 0.5,
    ["03"] = 0.5,
    ["15"] = 0.5,
    ["16"] = 0.5,
    ["18"] = 0.5,
    ["20"] = 0.5,
    ["05"] = 0.5,
    ["24"] = 0.5,
    ["??"] = 0.5,
    ["锟"] = 0.5,
    ["斤"] = 0.5,
    ["拷"] = 0.5
}
-- 获取权重信息
function getMaxWeight(t)
    local wt = {}
    -- 初始化权重
    local sum = 0
    for k, v in pairs (t) do
        sum = sum + v -- 累计权重
        wt [sum] = k -- 以权重总和为键，元素为值，存入新表
    end
    wt.max = sum -- 记录权重
    return wt
end

-- 打印机
function makeText(seed,num)
    math.randomseed(seed)
    local wt = getMaxWeight(chars)
    -- 抽取字符
    local result = {}
    for i = 1, num do
        local r = math.random (wt.max)
        for k, v in pairs (wt) do
            if r <= k then table.insert(result, v) end
        end
    end
    -- 返回连接后的字符串
    return table.concat(result)
end

function churchText(seed, tech)
    math.randomseed(seed)
    -- 暗金教会开始施法
    local wt = {}
    table.insert(wt, makeSerialNumber(seed, 2, nil, "-", "QWERTYUIOPASDFGHJKLZXCVBNM"))
    table.insert(wt, makeSerialNumber(seed, 3, nil, "-", "1234567890"))
    table.insert(wt, makeText(seed, 6))
    table.insert(tech.text, table.concat(wt))
end
-- 传入表单会增加性能开销
function churchTip(texts, bonuses, ltext, rtext, icon, permanent)
    if permanent then
        table.insert(texts, {ltext = ltext, rtext = rtext, icon = icon})
    else
        table.insert(bonuses, {ltext = ltext, rtext = rtext, icon = icon})
    end
    return texts, bonuses
end
-----------------------------

-- 企业为所有系统应用上新图标
function makeIcon(name, tech)
    local icon = "data/textures/icons/" .. name
    if tech.uid == 0700 then
        icon = icon .. ".png"
    else
        icon = icon .. toRomanLiterals(tech.rarity - 5) .. ".png"
    end
    return icon
end

--[[企业类型
    militaryEnterprise 军工企业ME：专注于军用的装备系统研发生产企业
    civilEnterprise 民工企业CE：专注于民用的装备系统研发生产企业
    hybridEnterprise 混合企业HE:军用和民用都有涉猎的混合生产企业

    军用系统：武装栏位
    民用系统：民用栏位；充能电池；能量电池
    独立系统：自动栏位；通用栏位；能量护盾；
    军用武器：
    民用武器：

    ]]
--[[企业规模：A+B+C
    A:企业的规模大小决定了这个企业铺设了多少的生产线作用于不同的装备系统。
        1:small 小型：推出一件改良
        2:medium 中型：推出两件改良
        3:large 大型：推出三件改良
        4:top 顶级：推出四件改良
        5:special 特殊：似乎什么改良都有涉及
    
    B:企业的生产类型决定了是推出装备还是系统升级。
        1.equipment 装备：只会推出炮台
        2.technology 科技：只会推出系统
        3.general 通用：炮台和系统都有

    C:企业的品控决定了出现的概率，额外的属性和其他参数。
        1.盈利目的型活动部门；此类部门主要目的是为了利益性赚钱。他们拥有比较稳定的品控和售价，出现的概率也比较高。
        常规名称：企业；公司；集团
        价格：口口
        质量：口口
        概率：口口口口
        基础出现概率：MKI[0.06] MKII[0.03] MKIII[0.006]
        基础价格倍率：110%
        基础能量倍率：120%
        基础生产范围：红色

        2.科研目的的活动部门；此类部门主要是为了更高技术的装备系统生产。他们拥有非常稳定的品控，但是售价和出现的概率都比较高。
        常规名称：研究所；科研所；
        价格：口口口口
        质量：口口口
        概率：口口
        基础出现概率：MKI[0.03] MKII[0.015] MKIII[0.003]
        基础价格倍率：125%
        基础能量倍率：110%
        基础生产范围：紫色

        3.这是以定制的化为主活动部门，他们往往只生产高品质产品，这就导致了此类物品在市场上的流通极为罕见。
        常规名称：工程部，会议，彩蛋
        价格：口口口口口
        质量：口口口口
        概率：口
        基础出现概率：MKI[0.01] MKII[0.005] MKIII[0.001]
        基础价格倍率：145%
        基础能量倍率：100%
        基础生产范围：紫色

        4.暗金教会，这是暗金教会的东西，因为很少流通并且数值也被加密，所以很难定价。
        常规名称：教会
        价格：口
        质量：口
        概率：口
        基础出现概率：MKI[0.02] MKII[0.01] MKIII[0.002]
        基础价格倍率：50%
        基础能量倍率：110%
        基础生产范围：紫色

    ]]

function getEnterprise(seed, rarity, useType)
    math.randomseed(seed)
    
    
    local enters ={}

    local ent = {}
    ent.uid = 1001  ent.name = "Daqin Military/*大秦军工*/"%_t  ent.nameId = "QIN"  ent.enterType = "HybridEnterprise/*混合企业*/"%_t
    -- 企业规模         企业业务范围         企业品控               企业后缀
    ent.enterScale = 3  ent.enterWork = 3  ent.enterQuality = 1  ent.enterSuffix = "Enterprise/*企业*/"
    --是否系统插件  产品ID   最小等级  最大等级
    ent.put = {
        {true, "militarytcs", 1, 2},
        {false, "RailGun", 1, 3},
        {false, "ChainGun", 1, 2}
    }
    ent.tipLink = 2
    ent.tip_1 = {"Welcome to buy and use the products of Daqin Military/*欢迎购买并使用大秦军工的产品*/"%_t}
    ent.tip_2 = {"I haven't thought of what to write here yet/*我还没想好这里写什么*/"%_t}
    ent.perfor = {{name = "Stable Quality Control/*稳定品控*/"%_t, tip = "Minimum Quality +10%/*最低品质+10%*/", type =1}}
    
    table.insert(enters, ent)



    local entes = {

        {
            uid = 1001, name = "天堂造物"%_t, nameId = "HEA", rarity = 3, quality = 5, type = 0,
            sys = {"all",3,3},
            wap = {"false"},
            prob = 0.001, onlyPerm = false, coinFactor = 1.3, energyFactor = 1.2,
            minRandom = 15, maxRandom = 100,

            text = {"欢迎使用来自 天堂造物 的功能拓展子系统"%_t, "感受星海的巅峰科技加持"%_t},
            perfor = {{name = "先驱者", type = 0}, {name = "遗物", type = 0}},
            entry = {}
        },
        {
            uid = 1002, name = "索坦逆向科技", nameId = "Xsotan", rarity = 3, quality = 5, type = 1,
            prob = 0.001, onlyPerm = false, coinFactor = 1.3, energyFactor = 1.2,
            minRandom = 15, maxRandom = 100,

            text = {"Xsotan Key 0X000000", "null - 000000"},
            perfor = {{name = "逆向科技", type = 0}},
            entry = {}
        },

        {
            uid = 0901, name = "闪耀科技", nameId = "STAR", rarity = 2, quality = 5, type = 0,
            prob = 0.02, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {"Xsotan System Decompile", "产自 - 闪耀科技研讨会"},
            perfor = {{name = "逆向科技", type = 0}},
            entry = {}
        },
        {
            uid = 0902, name = "暗金教会", nameId = "DGC", rarity = 2, quality = 5, type = 0,
            prob = 0.02, onlyPerm = true, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {},
            perfor = {{name = "暗金工程", type = 2}},
            entry = {}
        },

        {
            uid = 9901, name = "晓立天下", nameId = "NVCX", rarity = 2, quality = 5, type = 0,
            prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {},
            perfor = {{name = "寥若晨星", type = 0}},
            entry = {}
        },
        {
            uid = 9902, name = "莱莎重工", nameId = "BA", rarity = 2, quality = 5, type = 1,
            prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {},
            perfor = {{name = "寥若晨星", type = 0}},
            entry = {}
        },

        {
            uid = 0801, name = "AISystem", nameId = "AI", rarity = 1, quality = 4, type = 0,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"通过最新的量子计算器", "我们已成功推算出传说之上"},
            perfor = {},
            entry = {}
        },
        {
            uid = 0802, name = "天顶星集团", nameId = "HCK", rarity = 1, quality = 4, type = 0,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"欢迎加入我们", "无论您是从事什么行业"},
            perfor = {},
            entry = {}
        },
        {
            uid = 0803, name = "大秦军工", nameId = "QIN", rarity = 1, quality = 4, type = 1,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"欢迎购买并使用我们的外贸产品"},
            perfor = {},
            entry = {}
        },
        {
            uid = 0804, name = "惠民企业", nameId = "HM", rarity = 1, quality = 4, type = 2,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"惠民企业给你带来更高端的产业升级"},
            perfor = {},
            entry = {}
        }


    }

    --[[
        type:   0null 1good 2bad
    ]]
    local perfors = {
    }


    local tech
    --  民用插件定义：非战斗用途    civil = 2

    for i, t in pairs(entes) do

        if t.type == 0 or t.type == useType then
            if math.random() < t.prob and rarity.value >= t.quality then -- 如果 随机数 比 概率大 和 品级对等/达标则开始抽奖
                tech = t 
                break 
            end
            
         end

        
    end

    if not tech then --如果抽奖失败了那么我们就创造一个0799 = 原版
        tech = {
            uid = 0700, name = "", nameId = "", rarity = 0, quality = 0, type = 0,
            prob = 0, onlyPerm = false, coinFactor = 1, energyFactor = 1,
            minRandom = 0, maxRandom = 100,

            text = {},
            perfor = {},
            entry = {}
        }
    end

    -- 整合等级
    tech.rarity = rarity.value + tech.rarity
    
     return tech

end

function getGrade(dist, tech,num) 
     if tech.uid == 0902 then return "错误" end -- 直接返回
      dist = dist * num

     local grade = "未验证" 

     local vals = {
         "淘汰", 
         "粗劣", 
         "普通", 
         "优良", 
         "罕见", 
         "稀有", 
         "完美", 
         "无暇", 
         "极限", 
         "奇迹" 
     } 

     local last = 0
     for i, v in ipairs(vals) do
         -- 随机数值 大于或等于 上一个值*10 和 随机数值 小于 当前索引值*10
         if  dist >= last*10 and dist < i*10 then 
           grade = v
           break 
         end 
         last = i
     end 
  
     return grade 
 end

function getLines(seed, tech)
    math.randomseed(seed)
    local texts = {}
    local wlin = false
    local colors
    -- 暗金乱码植入
    if tech.uid == 0902 then churchText(seed, tech) end 
    
    if next(tech.text) ~= nil then

        for i, v in pairs(tech.text) do
        table.insert(texts, {ltext = tech.text[i], lcolor = ColorRGB(1, 0.5, 0.6)})
        end
        table.insert(texts, {ltext = ""})
    end
    if next(tech.perfor) ~= nil then

        table.insert(texts, {ltext = "厂牌特性：", lcolor = ColorRGB(0.9, 0.5, 0.3)})
        for i, v in pairs(tech.perfor) do
            if tech.perfor[i].type == 0 then colors = ColorRGB(0.8, 0.8, 0.8) end
            if tech.perfor[i].type == 1 then colors = ColorRGB(0.4, 0.8, 0.4) end
            if tech.perfor[i].type == 2 then colors = ColorRGB(0.8, 0.4, 0.4) end
            table.insert(texts, {ltext = " -  " .. tech.perfor[i].name, lcolor = colors})
        end
    end

    return texts
end
    
-----------------------------------------------------------------------------
--[[
    更新说明：
    在原版中7+5似乎强度就已经足够了
    所以我并不打算实装奖池
]]
--[[
function getRoll(seed, tech)
    math.randomseed(seed)
    --[[
        抽奖规则：卡片有 等级 - 3 次抽奖机会（红色有1次 紫色2次 8级3次 9级4次 10级5次）
        默认情况下获得词条的概率为：30  20  10  1  0
        厂牌等级每级会额外增加：4 的概率
        如果是 超稀有 卡牌，都会额外增加 5 的概率
        ----------
        中奖后将有60%的概率是个好词条，30%的概率是个坏词条，10%的概率是个中性词条
        厂牌等级的补正：  +3 -5 +2 
        中奖的补正（每次中奖后）： -5 +3 +2                  

    --]
    local jackpot = {
        all = {
            {type = 0, name = "纪念版", coinFactor = 0.2},
            {type = 0, name = "客制化", coinFactor = 0.2, energyFactor = -0.05},
            {type = 1, name = "内置电池", energyFactor = -0.05},
            {type = 1, name = "能量转换器", energyFactor = -0.1},
            {type = 2, name = "短路", energyFactor = 0.05}
        }

        turret = {
            {type = 1, name = "火力网络模块", coinFactor = 0.2},

        }
    }
    local i = #tech.perfor
    
    local draw = tech.rarity - 3 --异域卡片开始便有一次抽卡机会
    local drawProb = {30, 20, 10, 1, 0} -- 基础中奖概率
    local goodEntry, badEntry, neutEntry = 60, 30, 10 -- 基础中奖类型

    if draw > 2 then

        local techDraw = draw - 2
        for i, techDraw do--类型概率补正
            for i, #drawProb do drawProb[i] = drawProb[i] + 4 end --基础概率补正
            goodEntry = goodEntry + 3 
            badEntry = badEntry -5
            neutEntry = neutEntry + 2
        end
    end

    if next(tech.perfor) ~= nil then

        for i, v in pairs(tech.perfor) do
            if tech.perfor[i].name == "寥若晨星" then
                for i, #drawProb do drawProb[i] = drawProb[i] + 5 end --稀有补正
            end
        end
    end

    local quan = 0
    local drawPerfor = {}

    for i, draw do -- 原神抽卡
        if math.random(0,100) < draw[quan + 1] then
            quan = quan + 1
        end
    end

    for i, quan do -- 抽出来啦！

        local randoms = math.random(0,100)

        if randoms <= goodEntry then
            --table.insert(tech.entry, {哇！金色传说！})
        elseif randoms <= goodEntry + neutEntry then
            --table.insert(tech.entry, {哇！褒贬不一！})
        else
            --table.insert(tech.entry, {好好好！})
        end
        goodEntry = goodEntry - 5 
        badEntry = badEntry + 3
        neutEntry = neutEntry + 2
    end

end
]]