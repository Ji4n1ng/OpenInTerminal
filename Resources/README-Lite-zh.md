<div align="center">
  <img width="100%" src="https://user-images.githubusercontent.com/11001224/104892184-d522b280-59ac-11eb-9c06-5ffd044dce7d.png"><br/><br/>
  <a href="./README-Lite.md">English</a> | 中文 | <a href="./README-Lite-de.md">Deutsch</a>
</div>

## 如何使用 🚀

### 1) 在终端（或编辑器）中打开当前目录

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78589363-b23a6e00-7872-11ea-841d-79227b1125ce.gif" width="600px">
</div>


### 2) 在终端（或编辑器）中打开选择的文件夹或文件

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78589359-afd81400-7872-11ea-8032-8035d4412b19.gif" width="600px">
</div>

### 3) 在自定义应用中打开 (例如, GitHub Desktop)

<div>
  <img src="https://user-images.githubusercontent.com/11001224/104891620-28483580-59ac-11eb-9fb5-3e4dec7863cc.gif" width="600px">
</div>

## 如何安装 🖥

### Homebrew

1. 运行以下命令

```
brew install --cask openinterminal-lite
# 或者
brew install --cask openineditor-lite
```

2. 在 `应用程序` 文件夹中，按住 `Cmd` 键，然后将应用拖到访达工具栏中。

>  ⚠️ 当您第一次运行应用程序时，macOS 将要求访问 `访达` 和 `终端`（或 `iTerm`）的权限。请给予应用程序权限。

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590414-67215a80-7874-11ea-97a1-fb8996db6984.gif" width="600px">
</div>

### 手动安装

1. 从 [release](https://github.com/Ji4n1ng/OpenInTerminal/releases) 中下载。
2. 将应用移动到 `应用程序` 文件夹。
3. 按住 `Cmd` 键，然后将应用拖到访达工具栏中。

## 支持 ❤️

感谢你的支持！

| PayPal | 支付宝 | 微信 |
| --- | --- | --- |
| [paypal.me/ji4ning](https://www.paypal.me/ji4ning) | <img src="./Support-Alipay.jpg" width="50%"> | <img src="./Support-WeChatPay.jpg" width="50%"> |

## 设置 🔨 

### 1) 设置默认终端（或编辑器）

在第一次运行应用的时候，需要选择默认终端。

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78600459-8b396780-7885-11ea-8226-2fe45e539134.png" width="45%">
  <img src="https://user-images.githubusercontent.com/11001224/78600438-88d70d80-7885-11ea-9bcb-d70fcaaf7334.png" width="45%">
</div>

当设置了默认终端之后，选择框将不会再出现。如果想要重新设置默认终端，请在终端中输入以下命令。然后重新运行应用。

```
# 对于 OpenInTerminal-Lite:
defaults remove wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal
# 对于 OpenInEditor-Lite:
defaults remove wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor
```

将下列应用设置为默认：

| 应用 | 命令 |
| --- | --- |
| Alacritty | `defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal Alacritty` |
| cmux | `defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal cmux` |
| kitty | `defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal kitty` |
| TextEdit | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor TextEdit` |
| VSCodium | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor VSCodium` |
| BBEdit | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor BBEdit` |
| Visual Studio Code - Insiders | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor Visual\ Studio\ Code\ -\ Insiders` |
| TextMate | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor TextMate` |
| CotEditor | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor CotEditor` |
| MacVim | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor MacVim` |
| Typora | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor Typora` |
| Neovim | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor neovim` |
| Nova | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor Nova` |
| Cursor | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor Cursor` |
| AppCode | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor AppCode` |
| CLion | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor CLion` |
| GoLand | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor GoLand` |
| IntelliJ IDEA | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor IntelliJ\ IDEA` |
| PhpStorm | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor PhpStorm` |
| PyCharm | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor PyCharm` |
| RubyMine | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor RubyMine` |
| WebStorm | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor WebStorm` |
| Android Studio | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor Android\ Studio` |

如果你想要使用自定义应用，那么你可以下面的命令。以 GitHub Desktop 为例。

```
defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal GitHub\ Desktop
```

#### 针对 Neovim 用户

如果您选择 Neovim 作为编辑器，应用将默认使用 Kitty 作为终端。要切换到其他终端（支持的选项包括 Alacritty、WezTerm 和 Kitty），请使用以下命令更新配置。根据您的安装调整 Neovim 路径（此示例为 /opt/homebrew/bin/nvim）：

```
defaults write wang.jianing.app.OpenInEditor-Lite NeovimCommand "open -na Alacritty --args -e /opt/homebrew/bin/nvim PATH"
```

其他终端配置：

```
// Kitty:
"open -na kitty --args /opt/homebrew/bin/nvim PATH"
// WezTerm:
"open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
// Alacritty:
"open -na Alacritty --args -e /opt/homebrew/bin/nvim PATH"
```

#### 针对 Kitty 用户

Kitty 的默认启动行为是为每个命令打开一个新实例，如下所示：

```
open -na kitty --args --single-instance --instance-group 1 --directory
```

如果您想自定义此行为，可以在终端中运行以下命令。请根据需要调整 open 命令：

```
defaults write wang.jianing.app.OpenInTerminal-Lite KittyCommand "open -na kitty --args --single-instance --instance-group 1 --directory"
```

### 2) 如果你正在使用深色模式 (Dark Mode)

我在 [release](https://github.com/Ji4n1ng/OpenInTerminal/releases) 中提供了几个图标。 您可以右键单击该应用程序并选择 `显示简介`。 拖动图标进行更改。

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78600452-8aa0d100-7885-11ea-8a90-cc88b9233dac.png" width="600px">
  <br>
</div>

#### a. 手动更换图标

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590421-68eb1e00-7874-11ea-91e3-61cfd5ba3a26.gif" width="600px">
</div>

#### b. 利用 [Hammerspoon](https://www.hammerspoon.org) 自动更换图标

对于使用 macOS 的自动 Dark mode 功能的用户来说，下面的步骤特别有用。

1. 通过[下载最新版本](https://github.com/Hammerspoon/hammerspoon/releases/latest) 并将其拖动到 `/Applications` 文件夹中，或使用 Homebrew 安装 Hammerspoon: 
```
brew cask install hammerspoon
```

2. 安装 [fileicon](https://github.com/mklement0/fileicon) 程序，以编程的方式更改图标: 
```
brew install fileicon
```

3. 创建 `~/.hammerspoon/Icons` 文件夹，并将图标放在此处

4. 创建 `~/.hammerspoon/init.lua` 文件（如果该文件不存在），并添加以下代码：
```lua
local function setOpenInEditorLiteIcon(dark)
  -- 如果安装到其他路径，请替换下面的路径
  local appPath = "/Applications/OpenInEditor-Lite.app"
  -- 根据你想使用的图标(editor, atom, sublime, vscode)来更改下面的类型
  local iconType = "editor"
  local iconsFolder = hs.fs.currentDir() .. "/Icons"
  local theme = dark and "dark" or "light"
  hs.execute('fileicon set "' .. appPath .. '" "' .. iconsFolder .. "/icon_" .. iconType .. "_" .. theme .. '.icns"', true)
end

local function setOpenInTerminalLiteIcon(dark)
  -- 如果安装到其他路径，请替换下面的路径
  local appPath = "/Applications/OpenInTerminal-Lite.app"
  -- 根据你想使用的图标(terminal, iterm, hyper)来更改下面的类型
  local iconType = "terminal"
  local iconsFolder = hs.fs.currentDir() .. "/Icons"
  local theme = dark and "dark" or "light"
  hs.execute('fileicon set "' .. appPath .. '" "' .. iconsFolder .. "/icon_" .. iconType .. "_" .. theme .. '.icns"', true)
end

local function updateIcons()
  darkMode = (hs.settings.get("AppleInterfaceStyle") == "Dark")
  setOpenInEditorLiteIcon(darkMode)
  setOpenInTerminalLiteIcon(darkMode)
end

updateIcons()
hs.settings.watchKey("dark_mode", "AppleInterfaceStyle", function()
  updateIcons()
end)
```

现在可以重新加载配置文件（或重新启动 Hammerspoon），就完成了！从亮模式切换为暗模式时，图标应自动更新，反之亦然。不要忘记勾选 "登录时启动 Hammerspoon" 选项。

### 3) 使用 iTerm 时，打开新的标签页或者窗口

当你在使用 `iTerm` 时，你可以设置默认打开一个新的标签或者窗口。**默认**是打开新的窗口。

```
# 打开新的标签
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false
# 打开新的窗口
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool true
```

## 常见问题 ❓

<details><summary>1. 我不小心点了不授权的按钮</summary><br>
<p>你可以运行以下命令。这会重置系统设置里的权限。</p>
<pre><code># 对于 OpenInTerminal-Lite:
tccutil reset AppleEvents wang.jianing.app.OpenInTerminal-Lite
# 对于 OpenInEditor-Lite:
tccutil reset AppleEvents wang.jianing.app.OpenInEditor-Lite
</code></pre>
</details>

<details><summary>2. 路径里的特殊字符</summary><br>
<p>请不要在路径中使用反斜线 <code>\</code> 和双引号 <code>"</code>。</p>
</details>

<details><summary>3. 为什么不能根据深色模式自动切换图标</summary><br>
<p>对于 <code>OpenInTerminal-Lite</code> 来说，访达工具栏里的图标是应用图标，而不是访达扩展图标。目前我还没找到 API 可以更换应用图标（如果你有好的建议，请告诉我谢谢）。</p>
<p>补充：感谢 @MatteoCarnelos 的贡献(#126)，<code>OpenInTerminal-Lite</code>现在可以通过 Hammerspoon 来自动更换图标。</p><br>
<p>对于 <code>OpenInTerminal</code> 来说，访达工具栏里的图标是访达扩展图标，所以支持根据深色模式自动切换图标。</p>
</details>

<details><summary>4. 我的自定义应用不工作</summary><br>
<p>如果你的自定义应用不能通过运行以下命令正常运行，那么该应用不支持通过 OpenInTerminal 打开。例如，GitHub Desktop:</p>
<code>open -a GitHub\ Desktop ~/Desktop</code>
</details>

## 特别感谢 ❤️

所有贡献者和支持者！

### 参考项目

- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)
