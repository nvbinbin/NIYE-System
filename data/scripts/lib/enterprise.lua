package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
include ("basesystem")
include("utility")
include("randomext")
include("callable")

FixedEnergyRequirement = true

--[[

这里是企业函数库，使用include即可引用。

]]



function churchText(seed)
end

--[[
                                    奖池系统已被移除
function addJackpot(tech, tb)

    for k, v in pairs(tb) do
        -- 数值合并
        if tech[k] and type(v) == "number" and type(tech[k]) == "number" then
            tech[k] = tech[k] + v
        -- 表单合并
        elseif tech[k] and type(v) == "table" and type(tech[k]) == "table" then
            tech[k] = (tech[k] or {}) .. v
        end
    end

end
]]

function getEnterprise(seed, rarity, useType)
    math.randomseed(seed)
    
    --[[
        type：  0：通用     1：军用     2：民用
        onlyPerm:   只能永久安装

        基础倍率：0.04 / 0.02  / 0.001
        价格平衡：1.1/1.2/1.3
        电量平衡：1.05/1.1/1.2 
        出现品质：4/5/5  
        品质保底：5/10/15

        限制：111   211     422
        彩蛋：3     4       8
    ]]
    local entes = {
        {
            uid = 1001, name = "天堂造物", nameId = "HEAVEN", rarity = 3, quality = 5, type = 0,
            prob = 0.001, onlyPerm = false, coinFactor = 1.3, energyFactor = 1.2,
            minRandom = 15, maxRandom = 100,

            text = {"欢迎使用系统升级插件 - 等级 X", "全银河30年联保  通讯:114514 - 1919"},
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

function getGrade(dist, tech,types) 
     if tech.tech == 0902 then return "ERROR" end -- 直接返回
     if types == "cargo" then dist = dist * 100 end

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

function getLines(tech)
    local texts = {}
    local wlin = false
    local colors
    
    if next(tech.text) ~= nil then

        for i, v in pairs(tech.text) do
        table.insert(texts, {ltext = tech.text[i]%_t, lcolor = ColorRGB(1, 0.5, 0.6)})
        end
        table.insert(texts, {ltext = ""%_t})
    end
    if next(tech.perfor) ~= nil then

        table.insert(texts, {ltext = "厂牌特性："%_t, lcolor = ColorRGB(0.9, 0.5, 0.3)})
        for i, v in pairs(tech.perfor) do
            if tech.perfor[i].type == 0 then colors = ColorRGB(0.8, 0.8, 0.8) end
            if tech.perfor[i].type == 1 then colors = ColorRGB(0.4, 0.8, 0.4) end
            if tech.perfor[i].type == 2 then colors = ColorRGB(0.8, 0.4, 0.4) end
            table.insert(texts, {ltext = " -  " .. tech.perfor[i].name%_t, lcolor = colors})
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