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
    if tech.id == 0700 then
        icon = icon .. ".png"
    else
        icon = icon .. toRomanLiterals(tech.rar - 5) .. ".png"
    end
    return icon
end

local enters ={}
local systemTable = {}
local weaponTable = {}
local effectTable = {}
local rarityTable = {}

local enterpriseID = 1000
local baseTable = {}
-- T
local enterpriseType = {
    {"militaryEnterprise/*军工企业*/"%_t},
    {"civilEnterprise/*民用企业*/"%_t},
    {"HybridEnterprise/*混合企业*/"%_t}
}
-- C
local enterpriseSuffix = {
    {"Enterprise/*企业*/"%_t},
    {"Enterprise/*集团*/"%_t}
}
---------- A
--          effectTable
--          效果特性表
----------
-- 1
effectTable[1000] = {type = 1, ltext = "Pioneer technology/*先驱科技*/"%_t, rtext ="Only the highest quality will appear/*只会出现最高品质*/"%_t, title = "minPorb", act = "=", val = 1}
-- 2
effectTable[2000] = {type = 2, ltext = "Relic/*遗物*/"%_t, rtext ="Final value +100%/*最终价值+100%*/"%_t, title = "money", act = "+", val = 1}
-- 3
effectTable[3000] = {type = 3, ltext = "Reverse technology/*逆向科技*/"%_t, rtext ="Maximum quality -5%/*最高品质-5%*/"%_t, title = "maxPorb", act = "-", val = 0.05}
effectTable[3000] = {type = 3, ltext = "Stable Quality Control/*稳定品控*/"%_t, rtext ="Minimum quality +5%/*最低品质+5%*/"%_t, title = "mimPorb", act = "+", val = 0.05}
-- function needs
effectTable[9000] = {type = 3, ltext = "Lost enterprise/*失落企业*/"%_t, rtext ="Fixed 1‰ appearance probability/*固定1‰出现概率*/"%_t, title = "ny", act = "+", val = 0}
effectTable[9001] = {type = 3, ltext = "As sparse as morning stars/*寥若晨星*/"%_t, rtext ="Appearance probability -100%/*出现概率-100%*/"%_t, title = "ny", act = "+", val = 0}
effectTable[9002] = {type = 1, ltext = "Emerging enterprise/*新兴企业*/"%_t, rtext ="Appearance probability +50%/*出现概率+50%*/"%_t, title = "ny", act = "+", val = 0}

---------- B
--          rarityTable
--          出现概率表
--          MKI     MKII    MKIII
----------

rarityTable[0] = {0, 0, 0}
rarityTable[1] = {0.06, 0.03, 0.006}
rarityTable[2] = {0.03, 0.015, 0.003}
rarityTable[3] = {0.01, 0.005, 0.001}
rarityTable[4] = {0.02, 0.01, 0.002}
---------- F
--          baseTable
--          基础数值表
--          最低品质    最高品质    售价倍率    能量倍率
----------
baseTable[0] = {0, 100, 1, 1} --NIYECORE
baseTable[1] = {10, 100, 1.1, 1.2}
baseTable[2] = {15, 100, 1.25, 1.1}
baseTable[3] = {20, 105, 1.45, 1}
baseTable[4] = {0, 100, 0.5, 1.1}

systemTable.all = {}
systemTable.arbitrarytcs = {}
systemTable.militarytcs = {}


-- 参数顺序：企业的名字 企业的ID  ||  企业类型(1-3)  企业规模(1-5)  企业业务(1-3)  部门产能(1-4) 后缀(n)[TABC]
                                --  军民混合      小中大顶特      装备科技通用   基础概率表     企业集团
function creatorEnterprise(inName, inAbbr, inType, inScale, inWork, inRarity, inSuffix)
    -- 基础数据
    local ent = {}
    local base = baseTable[inRarity]
    ent.id = enterpriseID
    ent.name = inName
    ent.abbr = inAbbr
    ent.type = inType
    ent.scale = inScale
    ent.work = inWork
    ent.rarity = inRarity
    ent.suffix = inSuffix
    --基础属性
    ent.ny = 0
    ent.minProb = base[1]
    ent.maxProb = base[2]
    ent.money = base[3]
    ent.energy = base[4]


    --收尾
    enterpriseID = enterpriseID + 1
    return ent
end

function getFixRarity(inRarity, eft)
    local rarity = rarityTable[inRarity]-- 设置基础概率
    if eft == 9000 then local rarity = {0.1, 0.1, 0.1} end
    if eft == 9001 then for i=1 ,#rarity do rarity[i] = rarity[i] * 0.5 end end
    if eft == 9002 then for i=1 ,#rarity do rarity[i] = rarity[i] * 1.5 end end
    return rarity
end

-- 注册格式：注册表单 部门产能 系统名称 最小等级 最大等级
function addSystem(inTable, inRarity, sys, minProb, maxProb)
    local eft = inTable.eft[1]
    local abbr = inTable.abbr
    --修正概率
    if eft and eft >= 9000 then
        local rarity = getFixRarity(inRarity, eft)
    else
        local rarity = rarityTable[inRarity]
    end
    -- 参数：名称  等级  ：概率 所属
    for i=minProb, maxProb do
        table.insert(systemTable[sys][i], {rarity[i], abbr})
    end
end
function addWeapon(inTable, inRarity, weap, minProb, maxProb)
    local eft = inTable.eft[1]
    local abbr = inTable.abbr
    --修正概率
    if eft and eft >= 9000 then local rarity = getFixRarity(inRarity, eft)
    else
        local rarity = rarityTable[inRarity]
    end
    for i=minProb, maxProb do
        table.insert(weaponTable[weap][i], {rarity[i], abbr})
    end
end

function addEffect(inTable)
    if not inTable.eft then 
        return 
    end
    
    local function ope(act, a, b)
        if act == "=" then return b
        elseif act == "+" then return a + b
        elseif act == "-" then return a - b
        elseif act == "/" then return a / b
        elseif act == "*" then return a * b end
    end
    for i, v in pairs(inTable.eft) do
        local eft = effectTable[v] --通过地址获取词条
        local title = eft.title -- 获取词条名称
        local origVal = inTable[title] -- 获取原始数据
        inTable[title] = ope(eft.act,origVal,eft.val) -- 修正数值
    end
    return inTable
end

function addTips(t, nameId)
end

-- 这个函数用于注册所有的企业信息，所有的信息都会保存到页面内的局部函数enters内
function regEnterprise()
    -- 3：混合企业  5：特殊规模  2：科技企业  1：品控类型  2：集团
    local ent = creatorEnterprise("Tianfang Creation/*天创造物*/"%_t, "HEA", 3, 5, 2, 1, 2)
    --注册并修正效果表
    ent.eft = {9000, 2000, 1000}
    ent = addEffect(ent)
    -- 生成产品列表     警告：你必须要先注册效果表，否则perfor[1]涉及到概率的修正无法生效。
    addSystem(ent, 1, "all", 3, 3)
    
    ent.tip = {
        {"Welcome to the functional expansion subsystem from Tianfang Creation/*欢迎使用来自 天堂造物 的功能拓展子系统*/"%_t}, 
        {"Feel the peak technology blessing of the star sea/*感受星海的巅峰科技加持*/"%_t}}
    
    table.insert(enters, ent) -- 完成注册一个企业

    local ent = creatorEnterprise("Daqin Military/*大秦军工*/"%_t, "QIN", 3, 3, 1, 1, 1)
    ent.eft = {}
    ent = addEffect(ent)
    addSystem(ent, 1, "militarytcs", 1, 2)
    addWeapon(ent, 1, "RailGun", 1, 3)
    addWeapon(ent, 1, "ChainGun", 1, 3)
    ent.tip = {
        {"Welcome to buy and use the products of Daqin Military/*欢迎购买并使用大秦军工的产品*/"%_t},
        {"I haven't thought of what to write here yet/*我还没想好这里写什么*/"%_t}}
    table.insert(enters, ent) -- 完成注册一个企业

        -- 暗金工程
end

function getEnterprise(seed, rarity, inType)
    math.randomseed(seed)
    local function getNIYECore()
        -- 基础数据
        local ent = {}
        ent.id = 0700
        --基础属性
        ent.ny = 0
        ent.minProb = 0
        ent.maxProb = 1
        ent.money = 1
        ent.energy = 1
        ent.rar = rarity.value
        ent.eft = {}
        return ent
    end
    -- 不是传奇就不要玩了
    if rarity.value < 5 then
        local tech = getNIYECore()
         return tech
    end 

    regEnterprise() -- 注册所有的企业
    local tech
    local function getTech(inAbbr)
        for i, ent in pairs(enters) do
            if ent.abbr == inAbbr then
                return ent
            end
        end
    end
    
    -- 先从最大等级开始，再到最低等级。
    for level = 3, 1, -1 do
        -- 获取等级内所有信息
        for i, t in pairs(systemTable[inType][level]) do
            local random = math.random()
            local prob = t[1]
            -- 随机数 小于 概率
            if random < prob then
                tech = getTech(t[2])
                tech.rar = rarity.value + level
                break
            end
        end
    end

    if not tech then --如果抽奖失败了那么我们就创造一个0700 = 原版
        tech = getNIYECore()
        return tech
    end
     return tech
end



---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

function getGrade(dist, tech,num) 
     if tech.id == 0700 then return "错误" end -- 直接返回
      dist = dist * num

     local grade = "未验证" 

    --  local vals = {
    --      "淘汰", 
    --      "粗劣", 
    --      "普通", 
    --      "优良", 
    --      "罕见", 
    --      "稀有", 
    --      "完美", 
    --      "无暇", 
    --      "极限", 
    --      "奇迹" 
    --  } 

    --  local last = 0
    --  for i, v in ipairs(vals) do
    --      -- 随机数值 大于或等于 上一个值*10 和 随机数值 小于 当前索引值*10
    --      if  dist >= last*10 and dist < i*10 then 
    --        grade = v
    --        break 
    --      end 
    --      last = i
    --  end 
  
     return grade 
 end

function getLines(seed, tech)
    math.randomseed(seed)
    local texts = {}
    local wlin = false
    -- 暗金乱码植入
    --if tech.uid == 0902 then churchText(seed, tech) end 
    
    if next(tech.tip) ~= nil then

        for i, v in pairs(tech.tip) do
        table.insert(texts, {ltext = tech.tip[i], lcolor = ColorRGB(1, 0.5, 0.6)})
        end
        table.insert(texts, {ltext = ""})
    end
    if next(tech.eft) ~= nil then
        local colors

        table.insert(texts, {ltext = "厂牌特性：", lcolor = ColorRGB(0.9, 0.5, 0.3)})
        for i, v in pairs(tech.eft) do
            local eft = effectTable[v] --通过地址获取词条
            local eftType = eft.type
            if eft.type == 0 then colors = ColorRGB(0.8, 0.8, 0.8) end
            if eft.type == 1 then colors = ColorRGB(0.4, 0.8, 0.4) end
            if eft.type == 2 then colors = ColorRGB(0.8, 0.4, 0.4) end

            table.insert(texts, {ltext = " -  " .. eft.ltext, rtext = eft.rtext, lcolor = colors})
        end
    end

    return texts
end   
-----------------------------------------------------------------------------
