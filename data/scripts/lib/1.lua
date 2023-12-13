
-- main.lua
-- 这个文件是mod的入口点，它会在mod加载时运行一次
-- 你可以在这里注册一些事件，函数，变量等
package.path = package.path .. ";data/scripts/lib/?.lua" -- 这一行是为了让mod能够使用游戏内置的库文件
require ("randomext") -- 这个库提供了一些随机数相关的函数
require ("utility") -- 这个库提供了一些实用的函数
require ("stringutility") -- 这个库提供了一些字符串相关的函数

local config = {} -- 这个表用来存储mod的配置参数
config.refreshInterval = 10 -- 这个参数表示刷新NPC船的时间间隔，单位是分钟
config.equipmentDockScript = "data/scripts/entity/merchants/equipmentdock.lua" -- 这个参数表示装备船坞的脚本路径
config.npcShipScript = "data/scripts/entity/merchants/npcshiprefresher.lua" -- 这个参数表示NPC船的脚本路径

local npcShip -- 这个变量用来存储NPC船的实体
local equipmentDock -- 这个变量用来存储装备船坞的实体
local timer -- 这个变量用来存储计时器

function initialize() -- 这个函数是mod的初始化函数，它会在mod加载时运行一次
    print ("NPC Ship Refresher mod initialized") -- 这一行是为了在控制台输出一些信息，方便调试
    findEntities() -- 调用这个函数来寻找NPC船和装备船坞
    startTimer() -- 调用这个函数来启动计时器
end

function findEntities() -- 这个函数用来寻找NPC船和装备船坞
    local sector = Sector() -- 获取当前的星区对象
    local entities = {sector:getEntitiesByScript(config.equipmentDockScript)} -- 获取当前星区中所有运行装备船坞脚本的实体
    if #entities > 0 then -- 如果找到了至少一个装备船坞
        equipmentDock = entities[1] -- 随机选择一个作为目标装备船坞
        print ("Found equipment dock: " .. equipmentDock.name) -- 输出信息
    else -- 如果没有找到装备船坞
        print ("No equipment dock found in sector") -- 输出信息
        return -- 结束函数
    end
    entities = {sector:getEntitiesByScript(config.npcShipScript)} -- 获取当前星区中所有运行NPC船脚本的实体
    if #entities > 0 then -- 如果找到了至少一个NPC船
        npcShip = entities[1] -- 随机选择一个作为目标NPC船
        print ("Found NPC ship: " .. npcShip.name) -- 输出信息
    else -- 如果没有找到NPC船
        print ("No NPC ship found in sector") -- 输出信息
        return -- 结束函数
    end
end

function startTimer() -- 这个函数用来启动计时器
    if not npcShip or not equipmentDock then -- 如果没有找到NPC船或装备船坞
        print ("Cannot start timer without NPC ship or equipment dock") -- 输出信息
        return -- 结束函数
    end
    timer = config.refreshInterval * 60 -- 将计时器设置为刷新间隔乘以60，单位是秒
    print ("Timer started: " .. timer .. " seconds") -- 输出信息
end

function updateServer(timeStep) -- 这个函数是mod的服务器端更新函数，它会在每一帧运行一次
    if not npcShip or not equipmentDock then -- 如果没有找到NPC船或装备船坞
        return -- 结束函数
    end
    timer = timer - timeStep -- 将计时器减去每帧的时间，单位是秒
    if timer <= 0 then -- 如果计时器小于等于0
        refreshNPCShip() -- 调用这个函数来刷新NPC船
        startTimer() -- 调用这个函数来重启计时器
    end
end

function refreshNPCShip() -- 这个函数用来刷新NPC船
    print ("Refreshing NPC ship...") -- 输出信息
    local x, y = Sector():getCoordinates() -- 获取当前星区的坐标
    local faction = Galaxy():getNearestFaction(x, y) -- 获取当前星区最近的势力
    local plan = PlanGenerator.makeShipPlan(faction, random():getInt(2, 5)) -- 生成一个随机的船体方案，等级在2到5之间
    npcShip:setPlan(plan) -- 将NPC船的船体方案替换为新的方案
    npcShip.crew = plan.minCrew -- 将NPC船的船员设置为最低要求
    npcShip.shieldDurability = npcShip.shieldMaxDurability -- 将NPC船的护盾恢复满
    npcShip.hullDurability = npcShip.maxHullDurability -- 将NPC船的船体恢复满
    npcShip:clearCargoHold() -- 清空NPC船的货仓
    npcShip:removeAllWeapons() -- 移除NPC船的所有武器
    npcShip:addScriptOnce(config.npcShipScript) -- 为NPC船添加脚本，如果已经有了就不重复添加
    invokeClientFunction(npcShip, "buyEquipment") -- 调用NPC船的客户端函数，让它去买装备
    print ("NPC ship refreshed") -- 输出信息
end


-- npcshiprefresher.lua
-- 这个文件是NPC船的脚本，它会在NPC船加载时运行
-- 你可以在这里定义一些NPC船的行为，函数，变量等
package.path = package.path .. ";data/scripts/lib/?.lua" -- 这一行是为了让脚本能够使用游戏内置的库文件
require ("randomext") -- 这个库提供了一些随机数相关的函数
require ("utility") -- 这个库提供了一些实用的函数
require ("stringutility") -- 这个库提供了一些字符串相关的函数

local config = {} -- 这个表用来存储脚本的配置参数
config.equipmentDockScript = "data/scripts/entity/merchants/equipmentdock.lua" -- 这个参数表示装备船坞的脚本路径

function initialize() -- 这个函数是脚本的初始化函数，它会在脚本加载时运行一次
    if onServer() then -- 如果是在服务器端运行
        Entity():registerCallback("onSectorEntered", "onSectorEntered") -- 注册一个回调函数，当NPC船进入一个星区时触发
    end
    if onClient() then -- 如果是在客户端运行
        sync() -- 调用这个函数来同步服务器端和客户端的数据
    end
end

function onSectorEntered() -- 这个函数是当NPC船进入一个星区时触发的回调函数
    if Entity().factionIndex == -1 then -- 如果NPC船没有势力
        local x, y = Sector():getCoordinates() -- 获取当前星区的坐标
        local faction = Galaxy():getNearestFaction(x, y) -- 获取当前星区最近的势力
        Entity().factionIndex = faction.index -- 将NPC船的势力设置为该势力
        print ("NPC ship joined faction: " .. faction.name) -- 输出信息
    end
end

function buyEquipment() -- 这个函数用来让NPC船去买装备
    local sector = Sector() -- 获取当前的星区对象
    local entities = {sector:getEntitiesByScript(config.equipmentDockScript)} -- 获取当前星区中所有运行装备船坞脚本的实体
    if #entities > 0 then -- 如果找到了至少一个装备船坞
        local equipmentDock = entities[1] -- 随机选择一个作为目标装备船坞
        local distance = distance2(Entity().translationf, equipmentDock.translationf) -- 计算NPC船和装备船坞的距离
        if distance < 1000 then -- 如果距离小于1000
            invokeServerFunction("tradeEquipment", equipmentDock.index) -- 调用服务器端的函数，让NPC船和装备船坞进行交易
        else -- 如果距离大于等于1000
            FlyToAI(Entity()):setTarget(equipmentDock) -- 让NPC船飞向装备船坞
        end
    else -- 如果没有找到装备船坞
        print ("No equipment dock found in sector") -- 输出信息
    end
end

function tradeEquipment(equipmentDockIndex) -- 这个函数用来让NPC船和装备船坞进行交易
    if onClient() then -- 如果是在客户端运行
        invokeServerFunction("tradeEquipment", equipmentDockIndex) -- 调用服务器端的函数
        return -- 结束函数
    end
    local equipmentDock = Entity(equipmentDockIndex) -- 获取装备船坞的实体
    if not equipmentDock then -- 如果没有找到装备船坞
        print ("Invalid equipment dock index") -- 输出信息
        return -- 结束函数
    end
    local ship = Entity() -- 获取NPC船的实体
    local money = ship.money -- 获取NPC船的钱
    local items = {equipmentDock:getInventories()[1]:getItems()} -- 获取装备船坞的第一个仓库的所有物品
    local bought = false -- 这个变量用来记录NPC船是否买到了装备
    for _, item in pairs(items) do -- 遍历所有物品
        if item.item.itemType == InventoryItemType.Turret or item.item.itemType == InventoryItemType.SystemUpgrade then -- 如果物品是炮塔或系统升级
            local price = equipmentDock:getSellPrice(item.item, ship) -- 获取物品的售价
            if money >= price then -- 如果NPC船的钱足够
                ship:receiveMoney(-price) -- NPC船支付钱
                equipmentDock:receiveMoney(price) -- 装备船坞收钱
                equipmentDock:remove(item.item) -- 装备船坞移除物品
                ship:addItem(item.item) -- NPC船添加物品
                ship:installUpgrade(item.item) -- NPC船安装装备
                bought = true -- NPC船买到了装备
                print ("NPC ship bought " .. item.item.name) -- 输出信息
                break -- 结束循环
            end
        end
    end
    if not bought then -- 如果NPC船没有买到装备
        print ("NPC ship could not afford any equipment") -- 输出信息
    end
end

function sync() -- 这个函数用来同步服务器端和客户端的数据
    if onServer() then -- 如果是在服务器端运行
        invokeClientFunction(Player(callingPlayer), "sync") -- 调用客户端的函数
    else -- 如果是在客户端运行
        ScriptUI():registerInteraction("Buy Equipment", "buyEquipment") -- 注册一个交互选项，让玩家可以让NPC船去买装备
    end
end