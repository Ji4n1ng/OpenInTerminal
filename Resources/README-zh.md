<p align="center">
  <img width="80%" src="https://user-images.githubusercontent.com/11001224/104892170-d18f2b80-59ac-11eb-96b1-0293acfde4e5.png"><br/><br/>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/releases/tag/v2.3.6"><img src="https://img.shields.io/badge/Version-2.3.6-blue.svg"></a>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg"></a>
  <img src="https://img.shields.io/badge/Made With-Swift-red.svg">
  <a href="https://travis-ci.org/Ji4n1ng/OpenInTerminal"><img src="https://img.shields.io/travis/Ji4n1ng/OpenInTerminal.svg"></a>
</p>

[English](../README.md) | 中文说明

[OpenInTerminal-Lite English](./README-Lite.md) | [OpenInTerminal-Lite 中文说明](./README-Lite-zh.md)

## 如何使用 🚀

| 核心功能 | OpenInTerminal |
| --- | --- |
| 在终端（或编辑器）中打开目录或文件 | ![](https://user-images.githubusercontent.com/11001224/78589385-b797b880-7872-11ea-9062-c11a49461598.gif) |
| 在自定义应用中打开（以 GitHub Desktop 为例） | ![](https://user-images.githubusercontent.com/11001224/104891620-28483580-59ac-11eb-9fb5-3e4dec7863cc.gif) |

### 更多功能

| 功能 | OpenInTerminal | OpenInTerminal-Lite & OpenInEditor-Lite |
| --- | --- | --- |
| 支持 终端, [iTerm](https://www.iterm2.com/), [Hyper](https://github.com/zeit/hyper), [Alacritty](https://github.com/jwilm/alacritty), [kitty](https://sw.kovidgoyal.net/kitty/), [Warp](https://www.warp.dev), [WezTerm](https://wezfurlong.org/wezterm/index.html), [Tabby](https://tabby.sh). | ✅ | ✅ |
| 支持 文本编辑, Xcode, [Visual Studio Code](https://code.visualstudio.com/), [VSCode Insiders](https://code.visualstudio.com/insiders/), [Atom](https://atom.io/), [Sublime Text](https://www.sublimetext.com/), [VSCodium](https://github.com/VSCodium/vscodium), [BBEdit](https://www.barebones.com/products/bbedit/), [TextMate](https://macromates.com), [CotEditor](https://coteditor.com/), [MacVim](https://github.com/macvim-dev/macvim), [JetBrains](https://www.jetbrains.com/)(AppCode, CLion, GoLand, IntelliJ IDEA, PhpStorm, PyCharm, RubyMine, WebStorm, Android Studio, Fleet), [Typora](https://typora.io/), [Nova](https://nova.app/), [Cursor](https://cursor.sh/). | ✅ | ✅ |
| 打开自定义应用（⚠️ 并不是所有的应用都支持） | ✅ | ✅ |
| 支持中文，英语，法语，俄语，意大利语，西班牙语，土耳其语, 德语, 韩语 | ✅ | ✅ |
| 图形化设置界面 | ✅ | ❌ |
| 支持键盘快捷键 | ✅ | ❌ |

## OpenInTerminal 和 OpenInTerminal-Lite (OpenInEditor-Lite) 👀

选择哪个？如果你喜欢更强大的功能和图形化设置界面，那么你可以选择 `OpenInTerminal`。如果你仅仅需要更快速且更稳定地打开终端或编辑器，那么你可以选择 `OpenInTerminal-Lite`。

对于我而言，我更喜欢 `OpenInTerminal-Lite`，它只需要点击一次来完成功能（另一个需要点击两次😂），而且它更轻量一些。

对于 `OpenInTerminal-Lite` 用户：

请看文档： [English](./README-Lite.md) | [中文说明](./README-Lite-zh.md)

## 如何安装 🖥

### 1. 下载

#### a) Homebrew

```
brew install --cask openinterminal
```

#### b) 手动

1. 从 [release](https://github.com/Ji4n1ng/OpenInTerminal/releases) 中下载。
2. 将应用移动到 `应用程序` 文件夹。

> ⚠️ 当您第一次运行应用程序时，macOS 将要求访问 `访达` 和 `终端`（或 `iTerm`）的权限。请给予应用程序权限。

### 2. 打开 Finder 扩展权限

打开 OpenInTerminal 应用。去 `系统偏好设置` -> `扩展` -> `访达扩展`，打开下图中的权限按钮。

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590335-435e1480-7874-11ea-8adf-124f09c5b15e.png" width="400px">
</div>

## 支持 ❤️

感谢各位的支持！

通过 [GitHub Sponsors](https://github.com/sponsors/Ji4n1ng) 支持 💖。

| PayPal | 支付宝 | 微信 |
| --- | --- | --- |
| [paypal.me/ji4ning](https://www.paypal.me/ji4ning) | <img src="./Support-Alipay.jpg" width="50%"> | <img src="./Support-WeChatPay.jpg" width="50%"> |

### 赞助商

<a href="https://github.com/sparrowcode"><img src="https://avatars.githubusercontent.com/u/98487302?s=200&v=4" width="10%" style="border-radius:10px;" /></a>

## 常见问题 ❓

<details><summary>1. OpenInTerminal 和 OpenInTerminal-Lite 的区别是什么？</summary><br>
<p>OpenInTerminal 目前有正常版和 Lite 版。如果你仅仅需要打开终端而且不需要应用一直常驻后台，那么你可以选择 Lite 版。如果你喜欢更强大的功能，那么你可以选择正常版。</p>
</details>

<details><summary>2. 我不小心点了不授权的按钮</summary><br>
<p>你可以运行以下命令。这会重置系统设置里的权限。</p>
<pre><code>tccutil reset AppleEvents wang.jianing.app.OpenInTerminal</code></pre>
</details>

<details><summary>3. 路径里的特殊字符</summary><br>
<p>请不要在路径中使用反斜线 <code>\</code> 和双引号 <code>"</code>。</p>
</details>

<details><summary>4. 在 Mojave 上打开了两个终端窗口</summary><br>
<p>这个问题只发生在第一次启动终端的时候。所以，你可以通过 <code>⌘W</code> 来关闭终端的窗口，而不是用 <code>⌘Q</code> 来退出终端。</p>
</details>

<details><summary>5. 访达扩展不工作</summary><br>
<p>访达扩展目前完全依赖于 AppleScript 以便于能够独立运行。所以很难保证它的稳定性。当你发现访达扩展不能正常工作的时候，你需要按住 <code>Option(⌥)</code> 键，右键点击访达并选择 <code>重启</code>。</p>
<p>如果你的 Mac 型号比较老，建议取消在上下文菜单中显示图标。如果访达扩展仍旧频繁崩溃，强烈建议使用 OpenInTerminal-Lite</p>
</details>

<details><summary>6. OpenInTerminal 并不按照我的预期来工作</summary><br>
<p>OpenInTerminal 将会按照以下顺序来打开终端或编辑器：</p>
<ul>
<li>1. 打开你所选中的文件或文件夹。</li>
<li>2. 打开最上面的访达窗口。</li>
<li>3. 都不是。那么打开桌面。</li>
</ul>
</details>

<details><summary>7. 我的自定义应用不工作</summary><br>
<p>如果你的自定义应用不能通过运行以下命令正常运行，那么该应用不支持通过 OpenInTerminal 打开。例如，GitHub Desktop:</p>
<code>open -a GitHub\ Desktop ~/Desktop</code>
</details>

## 特别感谢 ❤️

感谢所有的贡献者。你们的付出让 OpenInTerminal 更棒了。

### 参考项目

- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)
