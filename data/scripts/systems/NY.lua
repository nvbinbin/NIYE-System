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

            

            text1 = "欢迎使用系统升级插件 - 等级: X", text2 ="", text3 ="全银河30年联保  通讯:114514 - 1919",
            perfor1 = "先驱者",  perfor2 = "遗物", perfor3 = "", perfor4 = ""
        }, 
        { -- 索坦逆向
            tech = "1002",tip = "[索坦]", id = "Xsotan", rarity = 3, quality = 5,
            prob = 0.999, permFalse = 1, permTrue = 1, coinFactor = 5, energyFactor = 1.15,

            

            text1 = "Xsotan Key 0X000000", text2 ="null - 000000", text3 ="",
            perfor1 = "逆向科技",  perfor2 = "质量优先", perfor3 = "", perfor4 = ""
        }, 
----------------------------------------------------------------------------------------------------------------------------------------------
        { -- 彩蛋：晓立天下
            tech = "0901",tip = "[晓立天下]", id = "NVCX", rarity = 2, quality = 5,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 3, energyFactor = 1.2,

            percBase = 4, flatBase = 50, minRandom = 20, maxRandom = 100,

            text1 = "闪耀超频核心已激活", text2 ="", text3 ="  - 现代工艺的极限" ,
            perfor1 = "寥若晨星",  perfor2 = "完美的品控", perfor3 = "骇人惊闻的价值", perfor4 = ""
        }, 

        { -- 暗金教会
            tech = "0902",tip = "[????]", id = "NULL", rarity = 2, quality = 5,
            prob = 0.99, permFalse = 0, permTrue = 15, coinFactor = 0.1, energyFactor = 1.2,

            percBase = 4.2, flatBase = 52.5, minRandom = 10, maxRandom = 100,

            text1 = "口口口口", text2 ="口口口口口口口口口口", text3 ="口口口口口口口" ,
            perfor1 = "神秘加密",  perfor2 = "????", perfor3 = "????", perfor4 = "????"
        }, -- 深度激活  优质产品  未注册商品
        { -- 彩蛋：蔚蓝档案
            tech = "0903",tip = "[莱莎重工]", id = "BA", rarity = 2, quality = 5,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 2, energyFactor = 1.25,

            

            text1 = "", text2 ="", text3 ="",
            perfor1 = "寥若晨星",  perfor2 = "粗劣算法", perfor3 = "", perfor4 = ""
        },
        { -- 闪耀科技
            tech = "0904",tip = "[闪耀科技]", id = "STAR", rarity = 2, quality = 5,
            prob = 0.98, permFalse = 1, permTrue = 1, coinFactor = 3, energyFactor = 1.3,

            

            text1 = "", text2 ="", text3 ="",
            perfor1 = "超频核心",  perfor2 = "逆向科技", perfor3 = "", perfor4 = ""
        },  
----------------------------------------------------------------------------------------------------------------------------------------------
        { -- 黑市集团
            tech = "0801",tip = "[天顶星集团]", id = "HCK", rarity = 1, quality = 4,
            prob = 0.95, permFalse = 1, permTrue = 1, coinFactor = 1.6, energyFactor = 1.2,

            percBase = 3.8, flatBase = 47.5, minRandom = 0, maxRandom = 100,

            text1 = "", text2 ="", text3 ="畅享更高级的插件升级",
            perfor1 = "地下流通",  perfor2 = "偷工减料", perfor3 = "毫无产品质保", perfor4 = ""
        }, 

        { -- 巨匠工程
            tech = "0802",tip = "[巨匠工程]", id = "GM", rarity = 1, quality = 4,
            prob = 0.96, permFalse = 1, permTrue = 1, coinFactor = 1.6, energyFactor = 1.1,

            percBase = 4.2, flatBase = 52.5, minRandom = 15, maxRandom = 100,

            text1 = "巨匠工程部出品", text2 ="", text3 ="",
            perfor1 = "巨匠工程",  perfor2 = "优秀的品控", perfor3 = "", perfor4 = ""
        }, 
            
        { -- 大秦军工
            tech = "0803",tip = "[大秦军工]", id = "QIN", rarity = 1, quality = 4,
            prob = 0.96, permFalse = 1.16, permTrue = 1.45, coinFactor = 1.5, energyFactor = 1.1,

            percBase = 4, flatBase = 50, minRandom = 10, maxRandom = 100,

            text1 = "外贸版升级系统插件", text2 ="", text3 ="",
            perfor1 = "外贸版",  perfor2 = "模块化", perfor3 = "", perfor4 = ""
        },
        { -- 惠民企业
            tech = "0804",tip = "[惠民企业]", id = "HM", rarity = 1, quality = 4,
            prob = 0.96, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            

            text1 = "惠民企业巨献", text2 ="", text3 ="",
            perfor1 = "偷工减料",  perfor2 = "", perfor3 = "", perfor4 = ""
        },  
        { -- 彩蛋：焚风反抗军
            tech = "0805",tip = "[焚风]", id = "FR", rarity = 1, quality = 4,
            prob = 0.994, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1,

            percBase = 4, flatBase = 50, minRandom = 10, maxRandom = 100,

            text1 = "Flying the Foehn banner!", text2 ="", text3 ="",
            perfor1 = "寥若晨星",  perfor2 = "质量优先", perfor3 = "", perfor4 = ""
        }, 
        { -- AI
            tech = "0806",tip = "[AI]", id = "AI", rarity = 1, quality = 4,
            prob = 0.97, permFalse = 1, permTrue = 1, coinFactor = 1.5, energyFactor = 1.1,

            percBase = 4, flatBase = 50, minRandom = 15, maxRandom = 100,

            text1 = "", text2 ="", text3 ="",
            perfor1 = "优化算法",  perfor2 = "优秀的品控", perfor3 = "稀有货物", perfor4 = ""
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
    
            tech = "0799",tip = "", id = "T1M", rarity = 0, quality = 0,
            prob = 0, permFalse = 1, permTrue = 1, coinFactor = 1, energyFactor = 1,
    
            
    
            text1 = "", text2 ="", text3 ="",
            perfor1 = "",  perfor2 = "", perfor3 = "", perfor4 = ""
        } 
        end

    --[[

        黑市：通用
        大秦军工：军事  *
        惠民企业：民用  **
        巨匠工程：民用  **
        - 焚风：军用    **
        * AI：通用

        - 晓立天下：通用
        暗金教会：通用
        - 莱莎重工：军用    *
        * 闪耀科技：通用

        * 天堂：通用
        索坦：军用      *



        特性列表：

        不屑一顾    ：稀有度强制2
        世所罕见    ：稀有度强制0.999
        寥若晨星    ：稀有度强制0.994         Ps：原神！启动！
        稀有货物    ：稀有度+0.01
        未注册商品  ：稀有度+0.01 + 价值强制为0.1
        大量流通    ：稀有度-0.01
        地下流通    ：稀有度-0.01 + 价值+10%
        量产物品    ：稀有度-0.02 + 价值+20%

        ----[部分系统并没有这个东西]----

        毫无产品质保    ：质保强制为0
        参差不齐的质量  ：减少50%的保底
        优秀的品控      ：拥有额外50%的保底
        完美的品控      ：拥有额外100%的保底

        ----[部分系统并没有这个东西]----

        劣质产品    ：基础值-5% + 价值-5%
        优质产品    ：基础值+5% + 价值+5%
        巨匠工程    ：基础值+5% + 价值+10%

        ----[]----
        遗物            ：价值+200%
        骇人惊闻的价值   ：价值+100%
        昂贵的定价      ：价值+50%
        ----

        模块化      ：普通安装能获取永久安装的80%的性能
        深度激活    ：普通安装获取不到性能，但是永久安装能获取额外5%的性能
        设计缺陷    ：普通安装获取不到性能

        ----

        质量优先  : 能量需求-10%
        优化算法  ：能量需求-5%
        粗劣算法  ：能量需求+5%
        偷工减料  ：能量需求+10%
        超频核心  ：能量需求+10%

        ----

        神秘加密  ：所有数值鉴定为????
        先驱者    ：---
        逆向科技  ：能量需求-5% + 价值+100%

        ---------------
         ----{炮台}----
        ---------------

        火力网络模块    ：永久武装栏位+1
        智能网络模块    ：永久自动栏位+1
        防御网络模块    ：永久防御栏位+1
        密集阵列处理    ：永久自动防御+0.5
        多功能处理器    ：全功能栏位+1

        侵略战斗系统    ：永久武装栏位+2 + 永久自动防御-1
        自动调度系统    ：永久自动栏位+2 + 防御栏位-1
        防御网络阵列    ：永久防御栏位+2 + 自动栏位-1

        并行调度处理器  ：能搭载2个同区域特性

    ]]
    --[[
        1.完善了文本
        2.修正了一些bug
        3.增加了通用栏位和民用栏位





    ]]