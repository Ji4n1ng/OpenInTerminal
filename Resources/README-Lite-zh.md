<p align="center">
  <img width="100%" src="./screenshots/lite-readme-header.png"><br/><br/>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/releases/tag/0.4.4"><img src="https://img.shields.io/badge/Version-0.4.4-blue.svg?longCache=true&style=for-the-badge"></a>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?longCache=true&style=for-the-badge"></a>
  <img src="https://img.shields.io/badge/Made With-Swift-red.svg?longCache=true&style=for-the-badge">
  <a href="https://travis-ci.org/Ji4n1ng/OpenInTerminal"><img src="https://img.shields.io/travis/Ji4n1ng/OpenInTerminal.svg?style=for-the-badge"></a>
</p>

[English](./README-Lite.md) | 中文说明

## 如何使用 🚀

### 1) 在终端（或编辑器）中打开当前目录

<div>
  <img src="./screenshots/lite-run.gif" width="600px">
</div>

### 2) 在终端（或编辑器）中打开选择的文件夹或文件

<div>
  <img src="./screenshots/lite-run-editor.gif" width="600px">
</div>

## 如何安装 🖥

### Homebrew (最新版本：0.4.4)

>  ⚠️ OpenInEditor-Lite 目前只能通过手动安装.

1. 运行以下命令

   ```
   brew cask install openinterminal-lite
   ```

2. 在 `应用程序` 文件夹中，按住 `Cmd` 键，然后将应用拖到访达工具栏中。

3. 完成

>  ⚠️ 当您第一次运行应用程序时，macOS 将要求访问 `访达` 和 `终端`（或 `iTerm`）的权限。请给予应用程序权限。

<div>
  <img src="./screenshots/lite-drag_to_toolbar.gif" width="600px">
</div>

### 手动安装 (最新版本：0.4.4)

1. 从 [release](https://github.com/Ji4n1ng/OpenInTerminal/releases) 中下载。
2. 将应用移动到 `应用程序` 文件夹。
3. 按住 `Cmd` 键，然后将应用拖到访达工具栏中。
4. 完成。

## 设置 🔨 

### 1) 设置默认终端（或编辑器）

在第一次运行应用的时候，你需要选择默认终端。

<div>
  <img src="./screenshots/lite-terminal-selector.png" width="45%">
  <img src="./screenshots/lite-editor-selector.png" width="45%">
</div>

当你设置了默认终端之后，选择框将不会再出现。如果你想要重新设置默认终端，请在终端中输入以下命令。然后重新运行应用。

```
# 对于 OpenInTerminal-Lite:
defaults remove wang.jianing.OpenInTerminal-Lite OIT_TerminalBundleIdentifier
# 对于 OpenInEditor-Lite:
defaults remove wang.jianing.OpenInEditor-Lite OIT_EditorBundleIdentifier
```

<details><summary>设置 <strong>Alacritty</strong> 为默认终端:</summary><br>
<code>defaults write wang.jianing.OpenInTerminal-Lite OIT_TerminalBundleIdentifier io.alacritty </code>
<br>
</details>

<details><summary>设置 <strong>VSCodium</strong> 为默认编辑器:</summary><br>
<code>defaults write wang.jianing.OpenInEditor-Lite OIT_EditorBundleIdentifier com.visualstudio.code.oss </code>
<br>
</details>

### 2) 如果你正在使用深色模式 (Dark Mode)

我在 [release](https://github.com/Ji4n1ng/OpenInTerminal/releases) 中提供了几个图标。 您可以右键单击该应用程序并选择 `显示简介`。 拖动图标进行更改。

<div>
  <img src="./screenshots/lite-icons.png" width="600px">
  <br>
  <img src="./screenshots/lite-change_icon-zh.gif" width="600px">
</div>

### 3) 打开新的标签页或者窗口

当你在使用 `Terminal` 或者 `iTerm`，你可以设置默认打开一个新的标签页或者窗口。**默认**是打开新的窗口。

#### 对于 Terminal:

```
# 打开新的标签页
defaults write wang.jianing.OpenInTerminal-Lite OIT_TerminalNewOption tab
# 打开新的窗口
defaults write wang.jianing.OpenInTerminal-Lite OIT_TerminalNewOption window
```

#### 对于 iTerm:

版本 0.4.4 及以上：

```
# 打开新的标签页
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false
# 打开新的窗口
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool true
```

老版本：

```
# 打开新的标签页
defaults write wang.jianing.OpenInTerminal-Lite OIT_iTermNewOption tab
# 打开新的窗口
defaults write wang.jianing.OpenInTerminal-Lite OIT_iTermNewOption window
```

对于 `Hyper` 用户来说，更推荐打开新的标签页。

对于 `Alacritty` 用户来说，目前只支持打开新的窗口。

## 常见问题 ❓

<details><summary>1. 我不小心点了不授权的按钮</summary><br>
<p>你可以运行以下命令。这会重置系统设置里的权限。</p>
<pre><code>tccutil reset AppleEvents</code></pre>
</details>

<details><summary>2. 路径里的特殊字符</summary><br>
<p>请不要在路径中使用反斜线 <code>\</code> 和双引号 <code>"</code>。</p>
</details>

<details><summary>3. 为什么不能根据深色模式自动切换图标</summary><br>
<p>对于 <code>OpenInTerminal-Lite</code> 来说，访达工具栏里的图标是应用图标，而不是访达扩展图标。目前我还没找到 API 可以更换应用图标（如果你有好的建议，请告诉我谢谢）。因此，目前不支持根据深色模式自动切换图标。<br>
<p>对于 <code>OpenInTerminal</code> 来说，访达工具栏里的图标是访达扩展图标，所以支持根据深色模式自动切换图标。</p>
</details>

## 版本变动 🗒

**version 0.4.4**

- 感谢 [pynixwang](https://github.com/pynixwang) 的建议。iTerm 现在不会在 history 中留下 `cd xxx`。
- 修复了启动程序时图标在 Dock 栏闪动的问题。

**version 0.4.3**

- 修复了本地化的 bug

**version 0.4.2**

- 支持 French
- 感谢 [filmgirl](https://github.com/filmgirl) 提供的图标

<details><summary>旧版本</summary><br>
<p><strong>version 0.4.1</strong></p>
<ul>
<li>支持 Alacritty</li>
</ul>
<p><strong>version 0.4.0</strong></p>
<ul>
<li>当使用 Terminal 和 iTerm 的时候，你可以设置默认打开新的标签页或者窗口。</li>
</ul>
<p><strong>version 0.3.0</strong></p>
<ul>
<li>更名为 OpenInTerminal-Lite (OpenInTerminal 将会在未来以功能更强大的版本出现)</li>
<li>解决了当打开 Hyper 的时候，特殊字符导致程序崩溃的 bug</li>
</ul>
<p><strong>version 0.2.0</strong></p>
<ul>
<li>增加终端选择框</li>
<li>在打开 iTerm 的时候，取消执行 <code>clear</code> 命令</li>
</ul>
<p><strong>version 0.1.1</strong></p>
<ul>
<li>支持 <code>Hyper</code></li>
<li>在打开 iTerm 的时候，优先新建一个 tab 标签页。</li>
</ul>
<p><strong>version 0.1.0</strong></p>
<ul>
<li>第一次 release</li>
</ul>
<br>
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