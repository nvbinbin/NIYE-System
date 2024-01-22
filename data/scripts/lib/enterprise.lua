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
ENTERPRISE_TIP.ATN = { "凡事皆有代价"%_t, "多余的能量换取更强的性能绝对是划算的"%_t, "武装列车只会发行实用好货"%_t}


--[[
    炮塔科技：通用栏位；武装栏位；民用栏位；自动栏位；内部防御
    通用科技：牵引光束，货箱系统；雷达；加速引擎；跃迁；采矿系统
    能量科技：固化护盾；能量护盾；复活护盾；能量电池；能量发生器
    高级科技：运输调度；九头蛇；扫描仪；屏蔽器；船体固
]]
local ENTERS = {
    {
        uid = 1001, name = "Tianfang Creation/*天创造物*/"%_t, nameId = "HEA", minLevel = 3, maxLevel = 3,
        prob = {0.1,0.1,0.1}, onlyPerm = false, coinFactor = 2, energyFactor = 1,
        minRandom = 100, maxRandom = 100,
        text = ENTERPRISE_TIP.HEA,
        perfor = {
            {type = 1, ltext = "Pioneer technology/*先驱科技*/"%_t, rtext ="Only highest quality/*绝对最高品质*/"%_t},
            {type = 2, ltext = "Relic/*遗物*/"%_t, rtext ="Final +100%/*价值+100%*/"%_t},
            {type = 3, ltext = "Lost enterprise/*失落企业*/"%_t, rtext ="Fixed 1‰ appearance probability/*固定1‰出现概率*/"%_t}},
        system = {"all"}
    },
    {
        uid = 1002, name = "暗金教会", nameId = "DGC", minLevel = 1, maxLevel = 3,
        prob = {0.1,0.1,0.1}, onlyPerm = true, coinFactor = 1, energyFactor = 1,
        minRandom = 10, maxRandom = 100,

        text = {},
        perfor = {
            {type = 2, ltext = "暗金工程"%_t, rtext ="数据被加密"%_t},
            {type = 3, ltext = "口口口口"%_t, rtext ="[未知数据]"%_t},
            {type = 3, ltext = "口口口口"%_t, rtext ="[未知数据]"%_t}
        },
        system = {"all"}
    },
    {
        uid = 1003, name = "武装列车", nameId = "Atn", minLevel = 1, maxLevel = 2,
        prob = {0.15,0.025,0}, onlyPerm = false, coinFactor = 1, energyFactor = 1.2,
        minRandom = 10, maxRandom = 100,

        text = ENTERPRISE_TIP.ATN,
        perfor = {
            {type = 1, ltext = "联动线路控制"%_t, rtext ="主要炮塔+1"%_t},
            {type = 3, ltext = "超载线路"%_t, rtext ="能量消耗+20%"%_t}
        },
        system = {"arbitrarytcs"}
    }
    --Xsotan
    -- {
    --     uid = 0901, name = "闪耀科技", nameId = "STAR", rarity = 2, quality = 5, type = 0,
    --     prob = 0.02, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
    --     minRandom = 10, maxRandom = 100,

    --     text = {"Xsotan System Decompile", "产自 - 闪耀科技研讨会"},
    --     perfor = {{type = 3, ltext = "Reverse technology/*逆向科技*/"%_t, rtext ="Maximum quality -5%/*最高品质-5%*/"%_t}},
    --     turretSystem = true, energySystem = true, currentSystem = true, seniorSystem = true
    -- },

    -- {
    --     uid = 9901, name = "晓立天下", nameId = "NVCX", rarity = 2, quality = 5, type = 0,
    --     prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
    --     minRandom = 10, maxRandom = 100,

    --     text = {},
    --     perfor = {},
    --     turretSystem = true, energySystem = true, currentSystem = true, seniorSystem = true
    -- },
    -- {
    --     uid = 9902, name = "莱莎重工", nameId = "BA", rarity = 2, quality = 5, type = 1,
    --     prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
    --     minRandom = 10, maxRandom = 100,

    --     text = {},
    --     perfor = {},
    --     turretSystem = true, energySystem = true, currentSystem = true, seniorSystem = true
    -- },

    -- {
    --     uid = 0801, name = "AISystem", nameId = "AI", rarity = 1, quality = 4, type = 0,
    --     prob = 0.1, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
    --     minRandom = 10, maxRandom = 100,

    --     text = {"通过最新的量子计算器", "我们已成功推算出传说之上"},
    --     perfor = {},
    --     turretSystem = true, energySystem = true, currentSystem = true, seniorSystem = true
    -- },
    -- {
    --     uid = 0802, name = "天顶星集团", nameId = "HCK", rarity = 1, quality = 4, type = 0,
    --     prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
    --     minRandom = 10, maxRandom = 100,

    --     text = {"欢迎加入我们", "无论您是从事什么行业"},
    --     perfor = {},
    --     turretSystem = true, energySystem = true, currentSystem = true, seniorSystem = true
    -- },
    -- {
    --     uid = 0803, name = "大秦军工", nameId = "QIN", rarity = 1, quality = 4, type = 1,
    --     prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
    --     minRandom = 10, maxRandom = 100,

    --     text = {"欢迎购买并使用我们的外贸产品"},
    --     perfor = {},
    --     turretSystem = true, energySystem = true, currentSystem = true, seniorSystem = true
    -- },
    -- {
    --     uid = 0804, name = "惠民企业", nameId = "HM", rarity = 1, quality = 4, type = 2,
    --     prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
    --     minRandom = 10, maxRandom = 100,

    --     text = {"惠民企业给你带来更高端的产业升级"},
    -- }
}

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

            local porb = ent.prob[level] -- 获取当前等级的概率
            if key then
                local random = math.random()
                if random < porb then
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
            uid = 0700, name = "", nameId = "", rarity = rarity.value,
            prob = 0, onlyPerm = false, coinFactor = 1, energyFactor = 1,
            minRandom = 0, maxRandom = 100,
            text = {},perfor = {}
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
    local notice = tech.text
    

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

    
