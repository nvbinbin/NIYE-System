----------------------------------------------
-- 这段函数用于给暗金教会随机增加一个乱码描述XDD
----------------------------------------------
local chars = {
    ["口"] = 2,
    ["鍒"] = 0.5,
    ["板"] = 0.5,
    ["簳"] = 0.5,
    ["浠"] = 0.5,
    ["涔"] = 0.5,
    ["堟"] = 0.5,
    ["椂"] = 0.5,
    ["鍊"] = 0.5,
    ["椤"] = 0.5,
    ["紑"] = 0.5,
    ["03"] = 0.5,
    ["15"] = 0.5,
    ["16"] = 0.5,
    ["18"] = 0.5,
    ["20"] = 0.5,
    ["05"] = 0.5,
    ["24"] = 0.5,
    ["??"] = 0.5,
    ["锟"] = 0.5,
    ["斤"] = 0.5,
    ["拷"] = 0.5
}
-- 获取权重信息
function getMaxWeight(t)
    local wt = {}
    -- 初始化权重
    local sum = 0
    for k, v in pairs (t) do
        sum = sum + v -- 累计权重
        wt [sum] = k -- 以权重总和为键，元素为值，存入新表
    end
    wt.max = sum -- 记录权重
    return wt
end

-- 打印机
function makeText(seed,num)
    math.randomseed(seed)
    local wt = getMaxWeight(chars)
    -- 抽取字符
    local result = {}
    for i = 1, num do
        local r = math.random (wt.max)
        for k, v in pairs (wt) do
            if r <= k then table.insert(result, v) end
        end
    end
    -- 返回连接后的字符串
    return table.concat(result)
end

function churchText(seed, tech)
    math.randomseed(seed)
    -- 暗金教会开始施法
    local wt = {}
    table.insert(wt, makeSerialNumber(seed, 2, nil, "-", "QWERTYUIOPASDFGHJKLZXCVBNM"))
    table.insert(wt, makeSerialNumber(seed, 3, nil, "-", "1234567890"))
    table.insert(wt, makeText(seed, 6))
    table.insert(tech.text, table.concat(wt))
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