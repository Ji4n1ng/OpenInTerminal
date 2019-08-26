<p align="center">
  <img width="100%" src="./screenshots/readme-header-zh.png"><br/><br/>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/releases/tag/2.0.5"><img src="https://img.shields.io/badge/Version-2.0.5-blue.svg?longCache=true&style=for-the-badge"></a>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?longCache=true&style=for-the-badge"></a>
  <img src="https://img.shields.io/badge/Made With-Swift-red.svg?longCache=true&style=for-the-badge">
  <a href="https://travis-ci.org/Ji4n1ng/OpenInTerminal"><img src="https://img.shields.io/travis/Ji4n1ng/OpenInTerminal.svg?style=for-the-badge"></a>
</p>

[English](../README.md) | 中文说明

[OpenInTerminal-Lite English](./README-Lite.md) | [OpenInTerminal-Lite 中文说明](./README-Lite-zh.md)

## 如何使用 🚀

| 功能 | OpenInTerminal | OpenInTerminal-Lite & OpenInEditor-Lite |
| --- | --- | --- |
| 在终端（或编辑器）中打开当前目录 | ![](./screenshots/main-open-in-terminal.gif) | ![](./screenshots/lite-run.gif) |
| 在终端（或编辑器）中打开选择的文件夹或文件 | ![](./screenshots/main-open-in-editor.gif) | ![](./screenshots/lite-run-editor.gif) |
| 将已选择的文件或者访达窗口的路径拷贝到粘贴板 | ![](./screenshots/main-copy-path-to-clipboard.gif) |  ❌ Not Supported |

### 更多功能

| 功能 | OpenInTerminal | OpenInTerminal-Lite & OpenInEditor-Lite |
| --- | --- | --- |
| 支持 Terminal, [iTerm](https://www.iterm2.com/), [Hyper](https://github.com/zeit/hyper) 和 [Alacritty](https://github.com/jwilm/alacritty). | ✅ | ✅ |
| 支持 [Visual Studio Code](https://code.visualstudio.com/), [VSCode Insiders](https://code.visualstudio.com/insiders/), [Atom](https://atom.io/), [Sublime Text](https://www.sublimetext.com/), [VSCodium](https://github.com/VSCodium/vscodium), [BBEdit](https://www.barebones.com/products/bbedit/) 和 [TextMate](https://macromates.com). | ✅ | ✅ |
| 设置为打开新的窗口或者标签页 | ✅ | ✅ |
| 支持中文，英语和法语 | ✅ | ✅ |
| 图形化设置界面 | ✅ | ❌ |
| 支持键盘快捷键 | ✅ | ❌ |
| 支持 Dark Mode | ✅ | ❌ |
| 不需要后台运行 | ❌ | ✅ |

## OpenInTerminal 和 OpenInTerminal-Lite (OpenInEditor-Lite) 👀

选择哪个？这两个应用都是我的孩子。如果你喜欢更强大的功能和图形化设置界面，那么你可以选择 `OpenInTerminal`。如果你仅仅需要打开终端或编辑器而不需要应用一直常驻后台，那么你可以选择 `OpenInTerminal-Lite`。

对于我而言，我更喜欢 `OpenInTerminal-Lite`，它只需要点击一次来完成功能（另一个需要点击两次😂），而且更轻量一些。

对于 `OpenInTerminal-Lite` 用户：

请看文档： [English](./README-Lite.md) | [中文说明](./README-Lite-zh.md)

## 如何安装 🖥

### 1. 下载

#### a) Homebrew (当前版本：2.0.5)

```
brew cask install openinterminal
```

#### b) 手动 (最新版本：2.0.5)

1. 从 [release](https://github.com/Ji4n1ng/OpenInTerminal/releases) 中下载。
2. 将应用移动到 `应用程序` 文件夹。

> ⚠️ 当您第一次运行应用程序时，macOS 将要求访问 `访达` 和 `终端`（或 `iTerm`）的权限。请给予应用程序权限。

### 2. 打开 Finder 扩展权限

打开 OpenInTerminal 应用。去 `系统偏好设置` -> `扩展` -> `访达扩展`，打开下图中的权限按钮。

<div>
  <img src="./screenshots/finder-extension-permission-zh.png" width="450px">
</div>

### 3. 将 OpenInTerminal 设置为开机启动

勾选 `偏好设置` 中的 `自动启动` 按钮即可。

> 如果 OpenInTerminal 主应用不运行， Finder 扩展将不会工作。所以更推荐将 OpenInTerminal 设置为自动启动。

<div>
  <img src="./screenshots/pref-general-zh.png" width="400px">
</div>

## 常见问题 ❓

<details><summary>1. OpenInTerminal 和 OpenInTerminal-Lite 的区别是什么？</summary><br>
<p>OpenInTerminal 目前有正常版和 Lite 版。如果你仅仅需要打开终端而且不需要应用一直常驻后台，那么你可以选择 Lite 版。如果你喜欢更强大的功能，那么你可以选择正常版。</p>
</details>

<details><summary>2. Finder 扩展不工作了</summary><br>
<p>请检查 OpenInTerminal（主应用）的图标是否在菜单栏中。因为 Finder 扩展会一直在 Finder 工具栏中，所以当主应用不运行时 Finder 扩展无法工作。推荐在偏好设置中将 OpenInTerminal 设置为自动启动。</p>
</details>

<details><summary>3. 我不小心点了不授权的按钮</summary><br>
<p>你可以运行以下命令。这会重置系统设置里的权限。</p>
<pre><code>tccutil reset AppleEvents</code></pre>
</details>

<details><summary>4. 路径里的特殊字符</summary><br>
<p>请不要在路径中使用反斜线 <code>\</code> 和双引号 <code>"</code>。</p>
</details>

<details><summary>5. 在 Mojave 上打开了两个终端窗口</summary><br>
<p>这个问题只发生在第一次启动终端的时候。所以，你可以通过 <code>⌘W</code> 来关闭终端的窗口，而不是用 <code>⌘Q</code> 来退出终端。</p>
</details>

## 特别感谢 ❤️

### 贡献者

- [Camji55](https://github.com/Camji55)

### 译者

- [Dorian Eydoux](https://github.com/dorianeydx)

### 参考项目

- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)