package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
include ("basesystem")
include("utility")
include("randomext")
include("callable")

FixedEnergyRequirement = true

function churchText(seed)
end
function createEnte(val,uid)
end


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
            perfor = {{name = "先驱者", type = 0}, {name = "遗物", type = 0}}
        },
        {
            uid = 1002, name = "索坦逆向科技", nameId = "Xsotan", rarity = 3, quality = 5, type = 1,
            prob = 0.001, onlyPerm = false, coinFactor = 1.3, energyFactor = 1.2,
            minRandom = 15, maxRandom = 100,

            text = {"Xsotan Key 0X000000", "null - 000000"},
            perfor = {{name = "逆向科技", type = 0}}
        },

        {
            uid = 0901, name = "闪耀科技", nameId = "STAR", rarity = 2, quality = 5, type = 0,
            prob = 0.02, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {"Xsotan System Decompile", "产自 - 闪耀科技研讨会"},
            perfor = {{name = "逆向科技", type = 0}}
        },
        {
            uid = 0902, name = "暗金教会", nameId = "DGC", rarity = 2, quality = 5, type = 0,
            prob = 0.02, onlyPerm = true, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {},
            perfor = {{name = "暗金工程", type = 2}}
        },

        {
            uid = 9901, name = "晓立天下", nameId = "NVCX", rarity = 2, quality = 5, type = 0,
            prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {},
            perfor = {{name = "寥若晨星", type = 0}}
        },
        {
            uid = 9902, name = "莱莎重工", nameId = "BA", rarity = 2, quality = 5, type = 1,
            prob = 0.006, onlyPerm = false, coinFactor = 1.2, energyFactor = 1.1,
            minRandom = 10, maxRandom = 100,

            text = {},
            perfor = {{name = "寥若晨星", type = 0}}
        },

        {
            uid = 0801, name = "AISystem", nameId = "AI", rarity = 1, quality = 4, type = 0,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"通过最新的量子计算器", "我们已成功推算出传说之上"},
            perfor = {}
        },
        {
            uid = 0802, name = "天顶星集团", nameId = "HCK", rarity = 1, quality = 4, type = 0,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"欢迎加入我们", "无论您是从事什么行业"},
            perfor = {}
        },
        {
            uid = 0803, name = "大秦军工", nameId = "QIN", rarity = 1, quality = 4, type = 1,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"欢迎购买并使用我们的外贸产品"},
            perfor = {}
        },
        {
            uid = 0804, name = "惠民企业", nameId = "HM", rarity = 1, quality = 4, type = 2,
            prob = 0.04, onlyPerm = false, coinFactor = 1.1, energyFactor = 1.05,
            minRandom = 10, maxRandom = 100,

            text = {"惠民企业给你带来更高端的产业升级"},
            perfor = {}
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
            perfor = {}
        }
    end

    -- 整合等级
    tech.rarity = rarity.value + tech.rarity
    
     return tech

end


function getGrade(dist, tech, types)
    local grade = "未验证"

    if types == "cargo" then -- dist = flat
        dist = dist * 100
    end

    local vals = {
        {value = 20, grade = "淘汰"},
        {value = 30, grade = "粗劣"},
        {value = 40, grade = "普通"},
        {value = 50, grade = "优良"},
        {value = 60, grade = "罕见"},
        {value = 70, grade = "稀有"},
        {value = 80, grade = "完美"},
        {value = 90, grade = "无暇"},
        {value = 95, grade = "极限"},
        {value = 100, grade = "奇迹"}
    }
    local ia = {value = 0, grade = "废品"}
    for i, v in pairs(vals) do
        -- 随机数值 大于或等于 上一个值 和 随机数值 小于 下一个数值
        if  dist >= ia.value and dist < v.value then
          grade = ia.grade
          break
        end
        ia = v
    end

    if tech.tech == 0902 then grade = "ERROR" end

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
    
function getRoll()
    --[[
    概率声明：
    10级卡片：5轮buff 5轮debuff 词条上限：5 正面buff概率：80 60 40 20 1  负面buff概率：50 20 10 5 5
    9级卡片：  4                      

    ]]


end