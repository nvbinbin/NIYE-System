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
    if tech.uid == 0700 or tech.uid == 1002 then
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

local EFT = {}
--[[
    EFT全称 effectTable 效果表：
    使用魔法数字地址 1000 2000 3000 为企业特色词条  4000 5000 6000为企业通用词条
    每张卡片都有 tech.rarity（-1 ~ 8） - 3 个词条机会  指 红1 紫2 MKI3 MKII4 MKIII5
    词条机会会被固有企业词条占用  例：HEA拥有3个固有词条 那么MKIII的HEA还有机会抽取2个通用随机词条

    记录格式：EFT[魔法数字地址] = { <词条命名类型>, <颜色类型>, <出现概率>, <含有副词条>, <允许系统>, <说明>, <效果说明>, <副词条颜色>, <副词条效果说明>}
]]
-- 如果 id = 1  那么说明这是一个无冲突词条类型；而其他id数字，一旦重复都是冲突；例如你已经抽取过一个含有id2的效果，那么就不可能会抽取到另外一个id2的效果。
-- 固有
EFT[1000] = {id = 1, type = 1, prob = 1, link = false, system = {"all"}, ltext = "Pioneer technology/*先驱科技*/"%_t, rtext ="Only highest quality/*绝对最高品质*/"%_t}
EFT[1001] = {id = 1 ,type = 1, prob = 0.25, link = true, system = {"arbitrarytcs", "autotcs","militarytcs","civiltcs"}, ltext = "超载控制器"%_t, rtext ="主要炮塔+1"%_t, rtype2 = 3, rtext2 ="能量消耗+35%"%_t}
EFT[1002] = {id = 1, type = 1, prob = 1, link = false, system = {"all"}, ltext = "暗金能源"%_t, rtext ="能量消耗-10%"%_t}
EFT[1003] = {id = 1, type = 1, prob = 1, link = false, system = {"all"}, ltext = "盘古™智能稳定器"%_t, rtext ="最低品质+20%"%_t}
EFT[1004] = {id = 1, type = 1, prob = 1, link = false, system = {"arbitrarytcs", "autotcs","militarytcs","civiltcs"}, ltext = "盘古™炮塔终端MKI"%_t, rtext ="主要炮塔+1"%_t}
EFT[1005] = {id = 1, type = 1, prob = 1, link = false, system = {"all"}, ltext = "闪耀信标"%_t, rtext ="最低品质+20%"%_t}

EFT[2000] = {id = 1, type = 2, prob = 1,  link = false, system = {"all"}, ltext = "Relic/*遗物*/"%_t, rtext ="Final +50%/*价值+50%*/"%_t}
EFT[2001] = {id = 1, type = 2, prob = 1,  link = true, system = {"all"}, ltext = "暗金工程"%_t, rtext ="数据被加密"%_t, rtype2 = 3, rtext2 ="[未知数据]"%_t}
EFT[2002] = {id = 1, type = 2, prob = 1,  link = true, system = {"all"}, ltext = "暗金工程"%_t, rtext ="数据已解密"%_t, rtype2 = 2, rtext2 ="Final -25%/*价值-25%*/"%_t}


EFT[3000] = {id = 1, type = 3, prob = 1,  link = false, system = {"all"}, ltext = "Lost enterprise/*失落企业*/"%_t, rtext ="Fixed 1‰ probability/*固定1‰概率*/"%_t}
EFT[3001] = {id = 1, type = 3, prob = 1,  link = false, system = {"all"}, ltext = "口口口口"%_t, rtext ="[未知数据]"%_t}
EFT[3002] = {id = 1, type = 3, prob = 1,  link = false, system = {"all"}, ltext = "深度权限"%_t, rtext ="只能永久安装"%_t}
EFT[3003] = {id = 1, type = 3, prob = 1,  link = false, system = {"all"}, ltext = "超凡工艺"%_t, rtext ="probability-100%/*出现概率-100%*/"%_t}
EFT[3004] = {id = 1, type = 3, prob = 1,  link = false, system = {"all"}, ltext = "隐世"%_t, rtext ="Fixed 6‰ probability/*固定6‰概率*/"%_t}

-- 通用

EFT[6000] = {id = 2, type = 3, prob = 1,  link = false, system = {"all"}, ltext = "品控缺陷"%_t, rtext ="能量消耗+10%"%_t}



------
--[[
    def：正常情况
    core：在有核心的情况下
    lp x = 随机播放
]]

local ENTERPRISE_TIP = {}
ENTERPRISE_TIP.HEA = {}
ENTERPRISE_TIP.DGC = {}
ENTERPRISE_TIP.ATN = {}


ENTERPRISE_TIP.def = {"这是一张企业芯片"%_t}

ENTERPRISE_TIP.DGC.def = {}

ENTERPRISE_TIP.HEA.def = {"Welcome to use TFC's system./*欢迎使用 天创开物 的功能拓展子系统*/"%_t, "Enjoy the top tech galaxy blessing./*感受星海的巅峰科技加持*/"%_t}
ENTERPRISE_TIP.HEA.croe = {}
ENTERPRISE_TIP.ATN.def = {"感谢使用武装列车扩展系统"%_t}
ENTERPRISE_TIP.ATN.core = {"多余的能量换取更强的性能绝对是划算的"%_t, "感谢使用武装列车扩展系统"%_t}


--[[
    炮塔科技：通用栏位；武装栏位；民用栏位；自动栏位；内部防御
    通用科技：牵引光束，货箱系统；雷达；加速引擎；跃迁；采矿系统
    能量科技：固化护盾；能量护盾；复活护盾；能量电池；能量发生器
    高级科技：运输调度；九头蛇；扫描仪；屏蔽器；船体固
]]
local defProb = {0.08,0.04,0.004}

local ENTERS = {
    {
        uid = 1001, name = "Tianfang Creation/*天创造物*/"%_t, nameId = "HEA", minLevel = 3, maxLevel = 3,
        prob = {0.08,0.04,0.001}, onlyPerm = false, coinFactor = 1.5, energyFactor = 1,
        minRandom = 100, maxRandom = 100,
        perfor = {EFT[1000], EFT[2000], EFT[3000]},
        notice = ENTERPRISE_TIP.HEA.def,
        system = {"all"}
    },
    {
        uid = 1002, name = "暗金教会", nameId = "DGC", minLevel = 1, maxLevel = 3,
        prob = defProb, onlyPerm = true, coinFactor = 0.75, energyFactor = 1,
        minRandom = 10, maxRandom = 100,
        perfor = {EFT[3001], EFT[5002], EFT[1002]},
        notice = ENTERPRISE_TIP.DGC.def,
        system = {"all"}
    },
    {
        uid = 1003, name = "武装列车", nameId = "Atn", minLevel = 1, maxLevel = 2,
        prob = defProb, onlyPerm = false, coinFactor = 1, energyFactor = 1.35,
        minRandom = 10, maxRandom = 100,
        perfor = {EFT[1001]},
        notice = ENTERPRISE_TIP.ATN.def,
        system = {"arbitrarytcs", "autotcs","militarytcs","civiltcs"}
    },
    {
        uid = 1004, name = "盘古重工", nameId = "Pan", minLevel = 2, maxLevel = 2,
        prob = {0.04,0.02,0.002}, onlyPerm = false, coinFactor = 1, energyFactor = 1,
        minRandom = 30, maxRandom = 100,
        perfor = {EFT[1003],EFT[1004],EFT[3003]},
        notice = ENTERPRISE_TIP.def,
        system = {"militarytcs"}
    },
    {
        uid = 1005, name = "闪耀研讨会", nameId = "STAR", minLevel = 2, maxLevel = 3,
        prob = defProb, onlyPerm = false, coinFactor = 1, energyFactor = 1,
        minRandom = 10, maxRandom = 100,
        perfor = {EFT[1005]},
        notice = ENTERPRISE_TIP.def,
        system = {"militarytcs"}
    },
    {
        uid = 1006, name = "通用能源公司", nameId = "TY", minLevel = 2, maxLevel = 3,
        prob = defProb, onlyPerm = false, coinFactor = 1, energyFactor = 1,
        minRandom = 10, maxRandom = 100,
        perfor = {},
        notice = ENTERPRISE_TIP.def,
        system = {"militarytcs"}
    },
    {
        uid = 1007, name = "索坦科技所", nameId = "Xsotan", minLevel = 2, maxLevel = 3,
        prob = defProb, onlyPerm = false, coinFactor = 1, energyFactor = 1,
        minRandom = 10, maxRandom = 100,
        perfor = {},
        notice = ENTERPRISE_TIP.def,
        system = {"militarytcs"}
    },
    {
        uid = 1008, name = "天顶星集团", nameId = "BAK", minLevel = 1, maxLevel = 1,
        prob = defProb, onlyPerm = false, coinFactor = 1, energyFactor = 1,
        minRandom = 10, maxRandom = 100,
        perfor = {},
        notice = ENTERPRISE_TIP.def,
        system = {"all"}
    },
    {
        uid = 1009, name = "惠民企业", nameId = "HUI", minLevel = 2, maxLevel = 3,
        prob = defProb, onlyPerm = false, coinFactor = 1, energyFactor = 1,
        minRandom = 10, maxRandom = 100,
        perfor = {},
        notice = ENTERPRISE_TIP.def,
        system = {"militarytcs"}
    }

}
local dbg = {}
dbg.prob = 5 --企业出现倍率

-- 抽取并返回企业数据
function getEnterprise(seed, rarity, inType)
    assert(type(inType) == "string", "getEnterprise传入了一个错误的inType参数")

    math.randomseed(seed)
    local tech
    local enters = {}
    if rarity.value < 5 then
        goto notech -- 不是传奇插件就直接返回普通类型
    end

    -- 从最高等级开始往下抽取
    for level = 3, 1, -1 do
        for i, ent in pairs(ENTERS) do -- 遍历所有企业
            if level >= ent.minLevel and level <= ent.maxLevel then else -- level不在范围内
                goto continue
            end

            local sys = ent.system
            if not sys then 
                print("Error: 企业[" .. ent.name .. " ]没有获取到系统。")
                goto continue
            end

            local key -- 打开新世界大门的钥匙
            local count = 0 -- 计数器
            for k, v in pairs(sys) do
                count = count + 1
                if v == "all" or v == inType then
                  key = true
                end
            end

            if count == 0 then
                print("Error: 企业[" .. ent.name .. " ]没有支持的改装。")
                goto continue
            end

            local prob = ent.prob[level] * dbg.prob -- 获取当前等级的概率
            if key then
                local random = math.random()
                if random < prob then
                    tech = ent
                    tech.rarity = rarity.value + level
                    break -- 退出类型检索循环
                end

            end
            if tech then break end -- 退出企业检索循环
            ::continue::
        end
        if tech then break end -- 退出降级循环
    end

    ::notech::
    if not tech then --如果抽奖失败了那么我们就创造一个0799 = 原版
        tech = {
            uid = 0700, name = "SYS", nameId = "SYS", rarity = rarity.value,
            prob = defProb, onlyPerm = false, coinFactor = 1, energyFactor = 1,
            minRandom = 0, maxRandom = 100,
            notice ={}, perfor = {}
        }
        
    end
    return tech
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

function getGrade(dist, tech,num) 
    if tech.uid == 1002 then return "错误" end -- 直接返回
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

    if tech.notice then
        local notice = tech.notice
    else
        local notice = {}
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
    -- 暗金植入
    if tech.uid == 1002 then 
        local dgcRandom = math.random(3, 10)
        dgcRandom = math.floor(dgcRandom)
        table.insert(texts, {ltext = ""})
        table.insert(texts, {ltext = churchText(seed), lcolor = ColorRGB(0.8, 0.8, 0.8)})
        table.insert(texts, {ltext = makeText(seed + 1, 12), lcolor = ColorRGB(0.8, 0.8, 0.8)})
        table.insert(texts, {ltext = makeText(seed + 2, dgcRandom), lcolor = ColorRGB(0.8, 0.8, 0.8)})
        table.insert(texts, {ltext = ""})
    end 

    return texts

end   
-----------------------------------------------------------------------------

    
