
meta =
{
    -- 您的mod的ID；确保这是独一无二的！
    -- 将用于识别依赖项列表中的mod
    -- 当您将mod上传到车间时，将更改为车间ID（确保唯一性）
    id = "3024105678",

    -- 您的mod名称；你可能希望这是独一无二的，但这并不是绝对必要的。
    -- 这是一个额外的辅助属性，您可以在Mods（）列表中轻松识别您的mod
    name = "[2.3] - 顶级企业",

    -- 将显示给玩家的mod的标题
    title = "[2.3] - 顶级企业",

    -- 你的mod类型 "mod" or "factionpack"
    type = "mod",

    -- 将显示给玩家的mod的描述
    description = "神秘的公司带来了超越原版的卡片等级……",

    -- 将所有作者插入此列表
    authors = {"逆夜"},

    -- 你的mod版本，应该是1.0.0（major.minor.patch）或1.0（major.minor）格式
    -- 这将用于检查未满足的依赖项或不兼容性，并检查客户端和具有mod的专用服务器之间的兼容性。
    -- 如果主要或次要mod版本不匹配的客户端想要登录服务器，则禁止登录。
    -- 不匹配的修补程序版本仍然允许登录到服务器。这有两种方式（服务器或客户端的更高版本或更低版本）。
    version = "1.0",

    --如果你的mod需要依赖项，请在这里输入。游戏将检查是否满足此处给出的所有依赖项。
    --可能的属性：
    --id：另一个mod的id，如其modinfo.loa中所述
    --min，max，exact：版本字符串，用于确定所需的最小、最大或精确版本（exact只是min==max的语法糖）
    --可选：如果此mod只是一个可选依赖项，则设置为true（只会影响加载顺序，而不会影响需求检查）
    --不兼容：如果你的mod与另一个不兼容，则设置为true
    --示例：
    --依赖项={
    --｛id=“Avorion”，min=“0.17”，max=“0.21”｝，--我们只能在版本0.17和0.21之间使用Avorion
    --｛id=“SomeModLoader”，min=“1.0”，max=“2.0”｝，--我们需要SomeModLoader，并且我们需要它的版本介于1.0和2.0之间
    --｛id=“AnotherMod”，max=“2.0”｝，--我们需要AntherMod，并且我们需要其版本为2.0或更低
    --｛id=“CompatibleMod”，compatible=true｝，--我们与不兼容Mod不兼容，无论其版本如何
    --｛id=“CompatibleModB”，exact=“2.0”，compatible=true｝，--我们与不兼容ModB不兼容，但仅限于2.0版本
    --｛id=“OptionalMod”，min=“0.2”，optional=true｝，--我们可选地支持OptionalMod，从版本0.2开始
    -- },
    dependencies = {
        {id = "Avorion", min = "2.3", max = "2.*"}
    },

    -- 如果mod只需要在服务器上运行，则设置为true。客户端会收到mod正在服务器上运行的通知，但他们不会自己下载
    serverSideOnly = false,

    -- 如果mod只需要在客户端上运行，例如UI mods，则设置为true
    clientSideOnly = false,

    -- 如果mod以潜在的破坏性方式更改保存游戏，则设置为true，因为它添加了保存到数据库中的脚本或机制，一旦mod被禁用，这些脚本或机制就不再工作
    -- 从逻辑上讲，如果一个mod只是客户端的，它就不能改变保存游戏，但Avorion目前没有检查这一点
    saveGameAltering = true,

    -- 其他用户的联系信息，以便在他们有问题时与您联系
    contact = "cniye@qq.com",
}
