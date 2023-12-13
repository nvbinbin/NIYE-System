-- server.lua
-- 这个文件是服务器端的脚本，它会在服务器端运行
package.path = package.path .. ";data/scripts/lib/?.lua" -- 这一行是为了让脚本能够使用游戏内置的库文件
require ("randomext") -- 这个库提供了一些随机数相关的函数
require ("utility") -- 这个库提供了一些实用的函数
require ("stringutility") -- 这个库提供了一些字符串相关的函数

local randomNumber -- 这个变量用来存储服务器端生成的随机数

function initialize() -- 这个函数是脚本的初始化函数，它会在脚本加载时运行一次
    if onServer() then -- 如果是在服务器端运行
        randomNumber = random():getInt(1, 100) -- 生成一个1到100之间的随机整数
        print ("Server generated random number: " .. randomNumber) -- 输出信息
    end
end

function sendData() -- 这个函数用来发送数据给客户端
    if onClient() then -- 如果是在客户端运行
        invokeServerFunction("sendData") -- 调用服务器端的函数
        return -- 结束函数
    end
    local player = Player(callingPlayer) -- 获取调用者的玩家对象
    local data = {} -- 创建一个空表，用来存储数据
    data.randomNumber = randomNumber -- 把随机数放入表中
    invokeClientFunction(player, "receiveData", data) -- 调用客户端的函数，发送数据给客户端
end

-- client.lua
-- 这个文件是客户端的脚本，它会在客户端运行
package.path = package.path .. ";data/scripts/lib/?.lua" -- 这一行是为了让脚本能够使用游戏内置的库文件
require ("randomext") -- 这个库提供了一些随机数相关的函数
require ("utility") -- 这个库提供了一些实用的函数
require ("stringutility") -- 这个库提供了一些字符串相关的函数

local randomNumber -- 这个变量用来存储客户端接收的随机数

function initialize() -- 这个函数是脚本的初始化函数，它会在脚本加载时运行一次
    if onClient() then -- 如果是在客户端运行
        sync() -- 调用这个函数来同步服务器端和客户端的数据
    end
end

function receiveData(data) -- 这个函数用来接收服务器端发送的数据
    if onServer() then -- 如果是在服务器端运行
        return -- 结束函数
    end
    randomNumber = data.randomNumber -- 从表中取出随机数
    print ("Client received random number: " .. randomNumber) -- 输出信息
    displayMessage("Random number: " .. randomNumber) -- 显示一条信息
end

function displayMessage(message) -- 这个函数用来显示一条信息
    if onServer() then -- 如果是在服务器端运行
        return -- 结束函数
    end
    local res = getResolution() -- 获取屏幕的分辨率
    local size = vec2(400, 100) -- 定义信息框的大小
    local menu = ScriptUI() -- 获取界面的对象
    local window = menu:createWindow(Rect((res - size) * 0.5, (res + size) * 0.5)) -- 创建一个窗口
    window.caption = "" -- 设置窗口的标题为空
    window.showCloseButton = 0 -- 设置窗口不显示关闭按钮
    window.moveable = 0 -- 设置窗口不可移动
    menu:registerWindow(window, "") -- 注册窗口

    local label = window:createLabel(Rect(vec2(), size), message, 16) -- 创建一个标签，用来显示信息
    label.centered = true -- 设置标签居中
    label.wordBreak = true -- 设置标签自动换行

    window:show() -- 显示窗口
    deferredCallback(3, "hideMessage") -- 延迟3秒后调用隐藏信息的函数
end

function hideMessage() -- 这个函数用来隐藏信息
    if onServer() then -- 如果是在服务器端运行
        return -- 结束函数
    end
    local menu = ScriptUI() -- 获取界面的对象
    local window = menu:findWindow("") -- 查找窗口
    if window then -- 如果窗口存在
        window:hide() -- 隐藏窗口
        menu:destroyWindow(window) -- 销毁窗口
    end
end
