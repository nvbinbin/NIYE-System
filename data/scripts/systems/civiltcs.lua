
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("randomext")
include ("utility")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true

function getNumBonusTurrets(seed, rarity, permanent)
    if permanent then
        return math.max(1, math.floor((rarity.value + 1) / 2))
    end

    return 0
end

function getNumTurrets(seed, rarity, permanent)
    math.randomseed(seed)

    local techs = { 
        { -- 天堂造物
        -- 卡牌UID        厂牌                厂牌简称     卡面额外等级 最低卡片品质
            tech = "1001",tip = "[天堂造物]", id = "HEA", rarity = 3, quality = 5,
        --  出现概率      普通安装倍率    永久安装倍率      价值倍率         能量倍率
            prob = 0.999, permFalse = 1, permTrue = 1, coinFactor = 6, energyFactor = 1.3,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0, -- 非永久安装倍率
            turretBonuses = 0, pdcBonuses = 0, autoBonuses = 0, -- 额外奖励

            text1 = "欢迎使用系统升级插件 - 等级: X", text2 ="", text3 ="全银河30年联保  通讯:114514 - 1919",
            perfor1 = "先驱者",  perfor2 = "遗物", perfor3 = "", perfor4 = ""
        }, 
        { -- 索坦逆向
            tech = "1002",tip = "[索坦]", id = "Xsotan", rarity = 3, quality = 5,
            prob = 2, permFalse = 1, permTrue = 1, coinFactor = 5, energyFactor = 1.15,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 1, pdcBonuses = 0, autoBonuses = 0,

            text1 = "Xsotan Key 0X000000", text2 ="null - 000000", text3 ="",
            perfor1 = "逆向科技",  perfor2 = "质量优先", perfor3 = "火力网络模块", perfor4 = "不屑一顾"
        }, 
----------------------------------------------------------------------------------------------------------------------------------------------
        { -- 彩蛋：晓立天下
            tech = "0901",tip = "[晓立天下]", id = "NVCX", rarity = 2, quality = 5,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 3, energyFactor = 1.2,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 2, pdcBonuses = -1, autoBonuses = -1,

            text1 = "闪耀超频核心已激活", text2 ="", text3 ="  - 现代工艺的极限" ,
            perfor1 = "寥若晨星",  perfor2 = "完美的品控", perfor3 = "骇人惊闻的价值", perfor4 = "侵略战斗系统"
        }, 

        { -- 暗金教会
            tech = "0902",tip = "[????]", id = "NULL", rarity = 2, quality = 5,
            prob = 0.99, permFalse = 0, permTrue = 1, coinFactor = 0.1, energyFactor = 1.2,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 0, pdcBonuses = 0, autoBonuses = 1, 

            text1 = "口口口口", text2 ="口口口口口口口口口口", text3 ="口口口口口口口" ,
            perfor1 = "神秘加密",  perfor2 = "????", perfor3 = "????", perfor4 = "????"
        }, -- 设计缺陷  智能网络模块  未注册商品
        { -- 彩蛋：蔚蓝档案
            tech = "0903",tip = "[莱莎重工]", id = "BA", rarity = 2, quality = 5,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 2, energyFactor = 1.25,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 1, pdcBonuses = 0, autoBonuses = 0, 

            text1 = "", text2 ="", text3 ="",
            perfor1 = "寥若晨星",  perfor2 = "粗劣算法", perfor3 = "不屑一顾", perfor4 = ""
        },
        { -- 闪耀科技
            tech = "0904",tip = "[闪耀科技]", id = "STAR", rarity = 2, quality = 5,
            prob = 0.98, permFalse = 1, permTrue = 1, coinFactor = 3, energyFactor = 1.3,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 0, pdcBonuses = 1, autoBonuses = 0,

            text1 = "", text2 ="", text3 ="",
            perfor1 = "超频核心",  perfor2 = "逆向科技", perfor3 = "防御网络模块", perfor4 = ""
        },  
----------------------------------------------------------------------------------------------------------------------------------------------
        { -- 黑市集团
            tech = "0801",tip = "[天顶星集团]", id = "HCK", rarity = 1, quality = 4,
            prob = 0.95, permFalse = 1, permTrue = 1, coinFactor = 1.6, energyFactor = 1.2,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 2, pdcBonuses = -1, autoBonuses = -1,

            text1 = "", text2 ="", text3 ="畅享更高级的插件升级",
            perfor1 = "地下流通",  perfor2 = "偷工减料", perfor3 = "侵略战斗系统", perfor4 = ""
        }, 

        { -- 巨匠工程
            tech = "0802",tip = "[巨匠工程]", id = "GM", rarity = 1, quality = 4,
            prob = 0.96, permFalse = 1, permTrue = 1, coinFactor = 1.6, energyFactor = 1.1,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 0, pdcBonuses = 0, autoBonuses = 0,

            text1 = "巨匠工程部出品", text2 ="", text3 ="",
            perfor1 = "巨匠工程",  perfor2 = "优秀的品控", perfor3 = "", perfor4 = ""
        }, 
            
        { -- 大秦军工
            tech = "0803",tip = "[大秦军工]", id = "QIN", rarity = 1, quality = 4,
            prob = 2, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 0, pdcBonuses = 1, autoBonuses = 1,

            text1 = "外贸版升级系统查件", text2 ="", text3 ="",
            perfor1 = "并行调度处理器",  perfor2 = "智能网络模块", perfor3 = "防御网络模块", perfor4 = "不屑一顾"
        },
        { -- 惠民企业
            tech = "0804",tip = "[惠民企业]", id = "HM", rarity = 1, quality = 4,
            prob = 0.96, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 0, pdcBonuses = 0, autoBonuses = 0,

            text1 = "惠民企业巨献", text2 ="", text3 ="",
            perfor1 = "偷工减料",  perfor2 = "", perfor3 = "", perfor4 = ""
        },  
        { -- 彩蛋：焚风反抗军
            tech = "0805",tip = "[焚风]", id = "FR", rarity = 1, quality = 4,
            prob = 2, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = -1, pdcBonuses = 2, autoBonuses = 0,

            text1 = "Flying the Foehn banner!", text2 ="", text3 ="",
            perfor1 = "寥若晨星",  perfor2 = "质量优先", perfor3 = "不屑一顾", perfor4 = ""
        }, 
        { -- AI
            tech = "0806",tip = "[AI]", id = "AI", rarity = 1, quality = 4,
            prob = 0.97, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
            turretBonuses = 0, pdcBonuses = 0, autoBonuses = 1,

            text1 = "", text2 ="", text3 ="",
            perfor1 = "优化算法",  perfor2 = "稀有货物", perfor3 = "", perfor4 = ""
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

        tech = "0799",tip = "", id = "M", rarity = 0, quality = 0,
        prob = 0, permFalse = 1, permTrue = 1, coinFactor = 1, energyFactor = 1,

        turretBaseFactor = 1, pdcBaseFactor = 0, autoBaseFactor = 0,
        turretBonuses = 0, pdcBonuses = 0, autoBonuses = 0,

        text1 = "", text2 ="", text3 ="",
        perfor1 = "",  perfor2 = "", perfor3 = "", perfor4 = ""
    } 
    end



    local baseTurrets = math.max(1, rarity.value + 1)
    local turrets = baseTurrets + getNumBonusTurrets(seed, rarity, permanent)

    local pdcs = math.floor(baseTurrets / 2)
    if not permanent then
        pdcs = 0
    end

    local autos = 0
    if permanent then
        autos = math.max(0, getInt(math.max(0, rarity.value - 1), turrets - 1))
    end

    return turrets, pdcs, autos
end

function onInstalled(seed, rarity, permanent)
    local turrets, pdcs, autos = getNumTurrets(seed, rarity, permanent)

    addMultiplyableBias(StatsBonuses.UnarmedTurrets, turrets)
    addMultiplyableBias(StatsBonuses.PointDefenseTurrets, pdcs)
    addMultiplyableBias(StatsBonuses.AutomaticTurrets, autos)
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    local turrets, pdcs, autos = getNumTurrets(seed, rarity, true)

    local ids = "C"
    if pdcs > 0 then ids = ids .. "D" end
    if autos > 0 then ids = ids .. "I" end

    return "Civil Turret Control Subsystem ${ids}-TCS-${num}"%_t % {num = turrets + pdcs + autos, ids = ids}
end

function getBasicName()
    return "Turret Control Subsystem (Civil) /* generic name for 'Civil Turret Control Subsystem ${ids}-TCS-${num}' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/turret.png"
end

function getEnergy(seed, rarity, permanent)
    local turrets, pdcs, autos = getNumTurrets(seed, rarity, permanent)
    return turrets * 200 * 1000 * 1000 / (1.2 ^ rarity.value)
end

function getPrice(seed, rarity)
    local turrets, _, _ = getNumTurrets(seed, rarity, false)
    local _, _, autos = getNumTurrets(seed, rarity, true)

    local price = 5000 * (turrets + autos * 0.5)
    return price * 2.5 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)
    local turrets, _ = getNumTurrets(seed, rarity, permanent)
    local _, pdcs, autos = getNumTurrets(seed, rarity, true)

    local texts = {}
    local bonuses = {}

    table.insert(texts, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. turrets, icon = "data/textures/icons/turret.png", boosted = permanent})
    if permanent then
        if pdcs > 0 then
            table.insert(texts, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
        if autos > 0 then
            table.insert(texts, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png", boosted = permanent})
        end
    end

    table.insert(bonuses, {ltext = "Unarmed Turret Slots"%_t, rtext = "+" .. getNumBonusTurrets(seed, rarity, true), icon = "data/textures/icons/turret.png"})
    if pdcs > 0 then
        table.insert(bonuses, {ltext = "Defensive Turret Slots"%_t, rtext = "+" .. pdcs, icon = "data/textures/icons/turret.png"})
    end
    if autos > 0 then
        table.insert(bonuses, {ltext = "Auto-Turret Slots"%_t, rtext = "+" .. autos, icon = "data/textures/icons/turret.png"})
    end

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Civil Turret Control System"%_t, rtext = "", icon = ""},
        {ltext = "Adds slots for unarmed turrets"%_t, rtext = "", icon = ""}
    }
end

function getComparableValues(seed, rarity)
    local turrets = getNumTurrets(seed, rarity, false)
    local bonusTurrets = getNumBonusTurrets(seed, rarity, true)
    local _, pdcs, autos = getNumTurrets(seed, rarity, true)

    return
    {
        {name = "Unarmed Turret Slots"%_t, key = "unarmed_slots", value = turrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = 0, comp = UpgradeComparison.MoreIsBetter},
    },
    {
        {name = "Unarmed Turret Slots"%_t, key = "unarmed_slots", value = bonusTurrets, comp = UpgradeComparison.MoreIsBetter},
        {name = "Defensive Turret Slots"%_t, key = "pdc_slots", value = pdcs, comp = UpgradeComparison.MoreIsBetter},
        {name = "Auto-Turret Slots"%_t, key = "auto_slots", value = autos, comp = UpgradeComparison.MoreIsBetter},
    }
end
