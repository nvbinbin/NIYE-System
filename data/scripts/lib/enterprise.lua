package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
include ("basesystem")
include("utility")
include("randomext")
include("callable")
--nclude("churchtip")
FixedEnergyRequirement = true

--[[
这里是顶级企业的函数库，使用include引用对游戏进行修改。
]]
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

----------------------------------------------
-- 这段函数用于给暗金教会随机增加一个乱码描述XDD
----------------------------------------------

-- 打印机
function makeText(seed,num)
    math.randomseed(seed)
    local chars = {
        {name = "口", prob = 2},
        {name = "鍒", prob = 0.5},
        {name = "板", prob = 0.5},
        {name = "簳", prob = 0.5},
        {name = "浠", prob = 0.5},
        {name = "涔", prob = 0.5},
        {name = "堟", prob = 0.5},
        {name = "椂", prob = 0.5},
        {name = "鍊", prob = 0.5},
        {name = "椤", prob = 0.5},
        {name = "紑", prob = 0.5},
        {name = "03", prob = 0.5},
        {name = "15", prob = 0.5},
        {name = "16", prob = 0.5},
        {name = "18", prob = 0.5},
        {name = "20", prob = 0.5},
        {name = "24", prob = 0.5}
    }
    local sum = 0
    for k, v in pairs (chars) do sum = sum + v.prob end -- 计算总权重
    local result = {}
    for i = 1, num do
        local random = math.random (1,sum)
        for k, v in pairs (chars) do
            if random <= v.prob then table.insert(result, v.name) break end
            random = random - v.prob
        end
    end
    -- 返回连接后的字符串
    return table.concat(result)
end


function churchText(seed)
    math.randomseed(seed)
    -- 暗金教会开始施法
    local wt = {}
    table.insert(wt, makeSerialNumber(seed, 2, nil, "-", "QWERTYUIOPASDFGHJKLZXCVBNM"))
    table.insert(wt, makeSerialNumber(seed, 3, nil, "-", "1234567890"))
    table.insert(wt, makeText(seed, 6))
    return table.concat(wt)
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
-- 顶级企业核心部分
-----------------------------

local effectTable = {}


---------- A
--          effectTable
--          效果特性表
----------
-- 1
effectTable[1000] = {type = 1, ltext = "Pioneer technology/*先驱科技*/"%_t, rtext ="Only the highest quality will appear/*只会出现最高品质*/"%_t, title = "minprob", act = "=", val = 1}
-- 2
effectTable[2000] = {type = 2, ltext = "Relic/*遗物*/"%_t, rtext ="Final value +100%/*最终价值+100%*/"%_t, title = "money", act = "+", val = 1}
-- 3
effectTable[3000] = {type = 3, ltext = "Reverse technology/*逆向科技*/"%_t, rtext ="Maximum quality -5%/*最高品质-5%*/"%_t, title = "maxprob", act = "-", val = 0.05}
effectTable[3001] = {type = 3, ltext = "Stable Quality Control/*稳定品控*/"%_t, rtext ="Minimum quality +5%/*最低品质+5%*/"%_t, title = "mimprob", act = "+", val = 0.05}
-- function needs
effectTable[9000] = {type = 3, ltext = "Lost enterprise/*失落企业*/"%_t, rtext ="Fixed 1‰ appearance probability/*固定1‰出现概率*/"%_t,title = 9000}
effectTable[9001] = {type = 3, ltext = "As sparse as morning stars/*寥若晨星*/"%_t, rtext ="Appearance probability -100%/*出现概率-100%*/"%_t,title = 9001}
effectTable[9002] = {type = 1, ltext = "Emerging enterprise/*新兴企业*/"%_t, rtext ="Appearance probability +50%/*出现概率+50%*/"%_t,title = 9002}


local ENTERPRISE_TIP = {}
ENTERPRISE_TIP.HEA = {"Welcome to the functional expansion subsystem from Tianfang Creation/*欢迎使用 天创开物 的功能拓展子系统*/"%_t, "Feel the peak technology blessing of the star sea/*感受星海的巅峰科技加持*/"%_t}

local ENTERS = {
    {
        uid = 1001, name = "Tianfang Creation/*天创造物*/"%_t, nameId = "HEA", rarity = 3, quality = 5, type = 0,
        prob = 0.1, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.2,
        minRandom = 100, maxRandom = 100,
        text = ENTERPRISE_TIP.HEA,
        perfor = {
            {type = 1, ltext = "Pioneer technology/*先驱科技*/"%_t, rtext ="Only highest quality/*绝对最高品质*/"%_t},
            {type = 2, ltext = "Relic/*遗物*/"%_t, rtext ="Final +100%/*价值+100%*/"%_t},
            {type = 3, ltext = "Lost enterprise/*失落企业*/"%_t, rtext ="Fixed 1‰ appearance probability/*固定1‰出现概率*/"%_t}},
        system = {{id = "all", val = 3, prob = 0.1}}
    },
    {
        uid = 1002, name = "索坦逆向科技", nameId = "Xsotan", rarity = 3, quality = 5, type = 1,
        prob = 0.001, onlyPerm = false, coinFactor = 1.3, energyFactor = 1.2,
        minRandom = 15, maxRandom = 100,

        text = {"Xsotan Key 0X000000", "null - 000000"},
        perfor = {{type = 3, ltext = "Reverse technology/*逆向科技*/"%_t, rtext ="Maximum quality -5%/*最高品质-5%*/"%_t}},
        system = {{id = "all", val = 3, prob = 0.1}}
    },

    {
        uid = 0901, name = "闪耀科技", nameId = "STAR", rarity = 2, quality = 5, type = 0,
        prob = 0.02, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
        minRandom = 10, maxRandom = 100,

        text = {"Xsotan System Decompile", "产自 - 闪耀科技研讨会"},
        perfor = {{type = 3, ltext = "Reverse technology/*逆向科技*/"%_t, rtext ="Maximum quality -5%/*最高品质-5%*/"%_t}},
        system = {}
    },
    {
        uid = 0902, name = "暗金教会", nameId = "DGC", rarity = 2, quality = 5, type = 0,
        prob = 0.1, onlyPerm = true, coinFactor = 1.2, energyFactor = 1.1,
        minRandom = 10, maxRandom = 100,

        text = {},
        perfor = {{type = 2, ltext = "暗金工程"%_t, rtext ="数据被加密"%_t}},
        system = {{id = "all", val = 3, prob = 0.1}}
    },

    {
        uid = 9901, name = "晓立天下", nameId = "NVCX", rarity = 2, quality = 5, type = 0,
        prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
        minRandom = 10, maxRandom = 100,

        text = {},
        perfor = {},
        system = {}
    },
    {
        uid = 9902, name = "莱莎重工", nameId = "BA", rarity = 2, quality = 5, type = 1,
        prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
        minRandom = 10, maxRandom = 100,

        text = {},
        perfor = {},
        system = {}
    },

    {
        uid = 0801, name = "AISystem", nameId = "AI", rarity = 1, quality = 4, type = 0,
        prob = 0.1, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
        minRandom = 10, maxRandom = 100,

        text = {"通过最新的量子计算器", "我们已成功推算出传说之上"},
        perfor = {},
        system = {}
    },
    {
        uid = 0802, name = "天顶星集团", nameId = "HCK", rarity = 1, quality = 4, type = 0,
        prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
        minRandom = 10, maxRandom = 100,

        text = {"欢迎加入我们", "无论您是从事什么行业"},
        perfor = {},
        system = {}
    },
    {
        uid = 0803, name = "大秦军工", nameId = "QIN", rarity = 1, quality = 4, type = 1,
        prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
        minRandom = 10, maxRandom = 100,

        text = {"欢迎购买并使用我们的外贸产品"},
        perfor = {},
        system = {}
    },
    {
        uid = 0804, name = "惠民企业", nameId = "HM", rarity = 1, quality = 4, type = 2,
        prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
        minRandom = 10, maxRandom = 100,

        text = {"惠民企业给你带来更高端的产业升级"},
        perfor = {},
        system = {}
    }
}

--[[企业规模：A+B
    A:企业的规模大小决定了这个企业铺设了多少的生产线作用于不同的装备系统。
        1:small 小型：拥有两件MKI和一件MKII
        2:medium 中型：拥有三件MKI和两件MKII和一件MKIII
        3:large 大型：拥有三件MKI和三件MKII和一件MKIII
        4:top 顶级：拥有四件MKI和三件MKII和两件MKIII

        5:special 特殊：似乎什么改良都有涉及
    

    B:企业的品控决定了出现的概率，额外的属性和其他参数。
        1.盈利目的型活动部门；此类部门主要目的是为了利益性赚钱。他们拥有比较稳定的品控和售价，出现的概率也比较高。
        常规名称：企业；公司；集团
        基础出现概率：MKI[0.06] MKII[0.03] MKIII[0.006]
        基础价格倍率：110%
        基础能量倍率：120%
        基础生产范围：紫色
        基础质量范围：10 - 100

        2.科研目的的活动部门；此类部门主要是为了更高技术的装备系统生产。他们拥有非常稳定的品控，但是售价和出现的概率都比较高。
        常规名称：研究所；科研所；
        基础出现概率：MKI[0.03] MKII[0.015] MKIII[0.003]
        基础价格倍率：125%
        基础能量倍率：110%
        基础生产范围：紫色
        基础质量范围：15 - 100

        3.这是以定制的化为主活动部门，他们往往只生产高品质产品，这就导致了此类物品在市场上的流通极为罕见。
        常规名称：工程部，会议，彩蛋
        基础出现概率：MKI[0.01] MKII[0.005] MKIII[0.001]
        基础价格倍率：145%
        基础能量倍率：100%
        基础生产范围：紫色
        基础质量范围：20 - 105

        4.暗金教会，这是暗金教会的东西，因为很少流通并且数值也被加密，所以很难定价。
        常规名称：教会
        基础出现概率：MKI[0.02] MKII[0.01] MKIII[0.002]
        基础价格倍率：50%
        基础能量倍率：110%
        基础生产范围：紫色
        基础质量范围：0 - 100
    ]]


function getEnterprise(seed, rarity, inType)
    math.randomseed(seed)
    local tech
    local enters = {}
    if rarity.value < 5 then
        goto notech
    end

    for i, t in pairs(ENTERS) do
        local sys = t.system
        -- 一般情况下不会出现这种情况
        if not sys then
            print("Error: " .. t.name .. " 没有检索到系统，本次生成跳过此企业。")
            goto continue
        end
        -- 为enters 添加上所有的 all 和 匹配系统类型
        -- enters的最终参数：id = 类型；val = 等级； prob = 概率； uid = 企业uid
        if next(sys) ~= nil then
            for i2, t2 in pairs(sys) do
                if t2.id == inType or t2.id == "all" then
                    local ent = t2
                    ent.uid = t.uid
                    table.insert(enters, ent)
                end
            end
        end

        ::continue::
    end
    

    for level = 3, 1, -1 do --等级从高到低开始抽取
        for i, t in pairs(enters) do
            if t.val == level then
                if math.random() < t.prob then -- 如果 随机数 比 概率大 和 品级对等/达标则开始抽奖
                    for n, e in pairs(ENTERS) do
                        if e.uid == t.uid then
                            tech = e
                            tech.rarity = rarity.value + level
                            break
                        end
                    end
                    break 
                end
            end
        end

        if tech then
            break
        end
    end

    ::notech::
    if not tech then --如果抽奖失败了那么我们就创造一个0799 = 原版
        tech = {
            uid = 0700, name = "", nameId = "", rarity = rarity.value, quality = 0, type = 0,
            prob = 0, onlyPerm = false, coinFactor = 1, energyFactor = 1,
            minRandom = 0, maxRandom = 100,

            text = {},
            perfor = {},
            system = {{id = "all", val = 0, prob = 0}}
        }
    end

    -- 整合等级
    
    
     return tech
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

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

    local tips = tech.perfor
    local notice = tech.text
    -- 暗金乱码植入
    if tech.uid == 0902 then 
        table.insert(notice, churchText(seed))
    end 

    if next(tips) ~= nil then

        table.insert(texts, {ltext = "Enterprise characteristics:/*企业特性：*/"%_t, lcolor = ColorRGB(0.9, 0.5, 0.3)})
        for i, v in pairs(tips) do
            local lt = v.ltext
            local rt = v.rtext
            local et = v.type
            if et == 2 then colors = ColorRGB(0.8, 0.8, 0.4) end
            if et == 1 then colors = ColorRGB(0.4, 0.8, 0.4) end
            if et == 3 then colors = ColorRGB(0.8, 0.4, 0.4) end
            table.insert(texts, {ltext = " -  " .. lt, rtext = rt, lcolor = colors})
        end
    end
    
    if next(notice) ~= nil then
        table.insert(texts, {ltext = ""})

        for i, v in pairs(notice) do
        table.insert(texts, {ltext = notice[i], lcolor = ColorRGB(0.8, 0.8, 0.8)})
        end
        table.insert(texts, {ltext = ""})
    end
    

    return texts

end   
-----------------------------------------------------------------------------

    
