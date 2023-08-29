
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getNumTurrets(seed, rarity, permanent)

    math.randomseed(seed)
--[[
                                     基础倍率：0.96/0.98/0.999  
                                     价格平衡：1.5/2/4
                                     电量平衡：1.1/1.2/1.3  
                                     出现品质：4/5/5  
                                     品质保底：10%
    --]]
    local techs = { 
        { -- 天堂造物
        -- 卡牌UID        厂牌                厂牌简称     卡面额外等级 最低卡片品质
            tech = "1001",tip = "[天堂造物]", id = "HEA", rarity = 3, quality = 5,
        --  出现概率      普通安装倍率    永久安装倍率      价值倍率         能量倍率
            prob = 0.999, permFalse = 1, permTrue = 1, coinFactor = 6, energyFactor = 1.3,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 0,

            text1 = "欢迎使用系统升级插件 - 等级: X", text2 ="", text3 ="全银河30年联保  通讯:114514 - 1919",
            perfor1 = "先驱者",  perfor2 = "遗物", perfor3 = "", perfor4 = ""
        }, 
        { -- 索坦逆向
            tech = "1002",tip = "[索坦]", id = "Xsotan", rarity = 3, quality = 5,
            prob = 0.999, permFalse = 1, permTrue = 1, coinFactor = 5, energyFactor = 1.15,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 0,

            text1 = "Xsotan Key 0X000000", text2 ="null - 000000", text3 ="",
            perfor1 = "逆向科技",  perfor2 = "质量优先", perfor3 = "", perfor4 = ""
        }, 
----------------------------------------------------------------------------------------------------------------------------------------------
        { -- 彩蛋：晓立天下
            tech = "0901",tip = "[晓立天下]", id = "NVCX", rarity = 2, quality = 5,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 3, energyFactor = 1.2,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 1,

            text1 = "闪耀超频核心已激活", text2 ="", text3 ="  - 现代工艺的极限" ,
            perfor1 = "寥若晨星",  perfor2 = "完美的品控", perfor3 = "骇人惊闻的价值", perfor4 = "智能网络模块"
        }, 

        { -- 暗金教会
            tech = "0902",tip = "[????]", id = "NULL", rarity = 2, quality = 5,
            prob = 0.99, permFalse = 0, permTrue = 1, coinFactor = 0.1, energyFactor = 1.2,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 1, 

            text1 = "口口口口", text2 ="口口口口口口口口口口", text3 ="口口口口口口口" ,
            perfor1 = "神秘加密",  perfor2 = "????", perfor3 = "????", perfor4 = "????"
        }, -- 设计缺陷  智能网络模块  未注册商品
        { -- 彩蛋：蔚蓝档案
            tech = "0903",tip = "[莱莎重工]", id = "BA", rarity = 2, quality = 5,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 2, energyFactor = 1.25,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 1, autoBonuses = 0,

            text1 = "", text2 ="", text3 ="",
            perfor1 = "寥若晨星",  perfor2 = "粗劣算法", perfor3 = "多功能处理器", perfor4 = ""
        },
        { -- 闪耀科技
            tech = "0904",tip = "[闪耀科技]", id = "STAR", rarity = 2, quality = 5,
            prob = 0.98, permFalse = 1, permTrue = 1, coinFactor = 3, energyFactor = 1.3,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 0,

            text1 = "", text2 ="", text3 ="",
            perfor1 = "超频核心",  perfor2 = "逆向科技", perfor3 = "防御网络模块", perfor4 = ""
        },  
----------------------------------------------------------------------------------------------------------------------------------------------
        { -- 黑市集团
            tech = "0801",tip = "[天顶星集团]", id = "HCK", rarity = 1, quality = 4,
            prob = 0.95, permFalse = 1, permTrue = 1, coinFactor = 1.6, energyFactor = 1.2,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 1,

            text1 = "", text2 ="", text3 ="畅享更高级的插件升级",
            perfor1 = "地下流通",  perfor2 = "偷工减料", perfor3 = "智能网络模块", perfor4 = ""
        }, 

        { -- 巨匠工程
            tech = "0802",tip = "[巨匠工程]", id = "GM", rarity = 1, quality = 4,
            prob = 2, permFalse = 1, permTrue = 1, coinFactor = 1.6, energyFactor = 1.1,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 0,

            text1 = "巨匠工程部出品", text2 ="", text3 ="",
            perfor1 = "不屑一顾",  perfor2 = "", perfor3 = "", perfor4 = ""
        }, 
            
        { -- 大秦军工
            tech = "0803",tip = "[大秦军工]", id = "QIN", rarity = 1, quality = 4,
            prob = 0.96, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 1, autoBonuses = 0,

            text1 = "外贸版升级系统查件", text2 ="", text3 ="",
            perfor1 = "多功能处理器",  perfor2 = "", perfor3 = "", perfor4 = ""
        },
        { -- 惠民企业
            tech = "0804",tip = "[惠民企业]", id = "HM", rarity = 1, quality = 4,
            prob = 2, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 0,

            text1 = "惠民企业巨献", text2 ="", text3 ="",
            perfor1 = "不屑一顾",  perfor2 = "", perfor3 = "", perfor4 = ""
        },  
        { -- 彩蛋：焚风反抗军
            tech = "0805",tip = "[焚风]", id = "FR", rarity = 1, quality = 4,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 1, autoBonuses = 0,

            text1 = "Flying the Foehn banner!", text2 ="", text3 ="",
            perfor1 = "寥若晨星",  perfor2 = "质量优先", perfor3 = "多功能处理器", perfor4 = ""
        }, 
        { -- AI
            tech = "0806",tip = "[AI]", id = "AI", rarity = 1, quality = 4,
            prob = 0.97, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            turretBaseFactor = 1, autoBaseFactor = 0,
            turretBonuses = 0, autoBonuses = 1,

            text1 = "", text2 ="", text3 ="",
            perfor1 = "优化算法",  perfor2 = "智能网络模块", perfor3 = "稀有货物", perfor4 = ""
        }
      }
    local tech

    for i, t in pairs(techs) do
        if math.random() > t.prob and rarity.value >= t.quality then -- 抽奖
            tech = t 
            break 
        end
    end
    if not tech then --如果抽奖失败了那么我们就创造一个0799 = 原版
        tech = {

        tech = "0799",tip = "", id = "A", rarity = 0, quality = 0,
        prob = 0, permFalse = 1, permTrue = 1, coinFactor = 1, energyFactor = 1,

        turretBaseFactor = 1, autoBaseFactor = 0,
        turretBonuses = 0, autoBonuses = 0,

        text1 = "", text2 ="", text3 ="",
        perfor1 = "",  perfor2 = "", perfor3 = "", perfor4 = ""
    } 
    end

    local turrets = math.max(1, rarity.value + tech.rarity)
    local autos = math.max(0, getInt(math.max(0, rarity.value + tech.rarity - 2), turrets - 1))

    if permanent then
        turrets = (turrets + math.max(1, math.floor((rarity.value + tech.rarity) / 2)) + tech.turretBonuses) * tech.permTrue
        autos = (autos + tech.autoBonuses) * tech.permTrue
    else
        turrets = turrets * tech.turretBaseFactor * tech.permFalse
        autos = autos * tech.autoBaseFactor * tech.permFalse
    end

    return turrets, autos, tech
end

function onInstalled(seed, rarity, permanent)
    local turrets, autos = getNumTurrets(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.ArbitraryTurrets, turrets)
    addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local turrets, autos, tech = getNumTurrets(seed, rarity, true)

    local ids = tech.id

    if tech.tech == "0799" then
        return "Turret Control Subsystem ${ids}-TCS-${num}"%_t % {num = turrets + autos, ids = ids}
    end
    if tech.tech == "0902" then
        return "通用炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = "???", ids = ids}
    end
    return "通用炮塔火控处理系统 ${ids}-TCS-${num}"%_t % {num = turrets + autos, ids = ids}


end

function getBasicName()
    return "Turret Control Subsystem (Arbitrary) /* generic name for 'Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)

    if tech.tech == "0799" then
        return "data/textures/icons/turret.png"
    end
    return "data/textures/icons/NYturret.png"
end

function getEnergy(seed, rarity, permanent)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)
    return (turrets * 350 * 1000 * 1000 / (1.1 ^ rarity.value)) * tech.energyFactor
end

function getPrice(seed, rarity)
    local turrets, _ = getNumTurrets(seed, rarity, false)
    local _, autos, tech = getNumTurrets(seed, rarity, true)

    local price = 7500 * (turrets + autos * 0.5);
    return (price * 2.5 ^ rarity.value) * tech.coinFactor
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, _, tech = getNumTurrets(seed, rarity, permanent)
    local maxTurrets, autos = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}
    if tech.tech ~= "0799" then 
        table.insert(texts, {ltext = tech.tip, lcolor = ColorRGB(1, 0.5, 1)}) 
        if tech.tech == "0902" then
            table.insert(bonuses, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})
            table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+???", icon = "data/textures/icons/turret.png"})
            return texts, bonuses
        end
    end

    table.insert(texts, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    if permanent then
        if autos > 0 then
            table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
    end

    table.insert(bonuses, {ltext = "Arbitrary Turret Slots"%_t, rtext = "+" .. maxTurrets - turrets, icon = "data/textures/icons/turret.png"})

    if autos > 0 then
        table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local turrets, autos, tech = getNumTurrets(seed, rarity, permanent)
    if tech.tech == "0799" then
        return
        {
            {ltext = "All-round Turret Control System"%_t, rtext = "", icon = ""},
            {ltext = "Adds slots for any turrets"%_t, rtext = "", icon = ""}
        }
    end

    local texts = {}
    local wlin = false

    if tech.text1 ~= "" then table.insert(texts, {ltext = tech.text1%_t, lcolor = ColorRGB(1, 0.5, 0.6)}) wlin = true end
    if tech.text2 ~= "" then table.insert(texts, {ltext = tech.text2%_t, lcolor = ColorRGB(1, 0.5, 0.6)}) wlin = true end
    if tech.text3 ~= "" then table.insert(texts, {ltext = tech.text3%_t, lcolor = ColorRGB(1, 0.5, 0.6)}) wlin = true end
    if wlin == true then table.insert(texts, {ltext = ""%_t}) end

    if tech.perfor1 ~= "" then table.insert(texts, {ltext = "厂牌特性："%_t, lcolor = ColorRGB(0.9, 0.5, 0.3)}) table.insert(texts, {ltext = " -  " .. tech.perfor1%_t, lcolor = ColorRGB(0.8, 0.8, 0.8)}) end
    if tech.perfor2 ~= "" then table.insert(texts, {ltext = " -  " .. tech.perfor2%_t, lcolor = ColorRGB(0.8, 0.8, 0.8)}) end
    if tech.perfor3 ~= "" then table.insert(texts, {ltext = " -  " .. tech.perfor3%_t, lcolor = ColorRGB(0.8, 0.8, 0.8)}) end
    if tech.perfor4 ~= "" then table.insert(texts, {ltext = " -  " .. tech.perfor4%_t, lcolor = ColorRGB(0.8, 0.8, 0.8)}) end

    return texts
end

function getComparableValues(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local bonusTurrets = getNumBonusTurrets(seed, rarity, true)
    local _, autos = getNumTurrets(seed, rarity, true)

    return
    {
        {name = "Arbitrary Turret Slots"%_t, key = "arbitrary_slots", value = turrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Arbitrary Turret Slots"%_t, key = "arbitrary_slots", value = bonusTurrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = autos, comp = UpgradeComparison.MoreIsBetter},
    }
end
