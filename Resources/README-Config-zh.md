## OpenInTerminal 配置

### macOS 15 中 Finder 扩展未显示在系统设置中

从 macOS 15 开始，Apple 从系统设置中移除了 Finder 同步扩展的配置。要启用 Finder 扩展，可以使用 `pluginkit` 命令行工具，如下所示：

```
$ pluginkit -mAD -p com.apple.FinderSync -vvv
```

会看到类似以下的输出：

```
wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension(2.3.5)
           Path = /Applications/OpenInTerminal.app/Contents/PlugIns/OpenInTerminalFinderExtension.appex
           UUID = F2547F13-4E43-4E88-9D8F-56DF05C020D8
      Timestamp = 2024-09-17 09:34:07 +0000
            SDK = com.apple.FinderSync
  Parent Bundle = /Applications/OpenInTerminal.app
   Display Name = OpenInTerminalFinderExtension
     Short Name = OpenInTerminalFinderExtension
    Parent Name = OpenInTerminal
       Platform = macOS
```

要手动启用 Finder 扩展，请使用输出中的 UUID 运行以下命令：

```
$ pluginkit -e "use" -u "F2547F13-4E43-4E88-9D8F-56DF05C020D8"
```

或者，您可以使用一个名为 [FinderSyncer](https://zigz.ag/FinderSyncer/) 的图形界面工具来启用扩展。

### 在 macOS 14 及更早版本中检查 Finder 扩展权限

对于 macOS 14 及更早版本，请确保通过系统偏好设置启用了 Finder 扩展：

1. 打开 OpenInTerminal 应用。
2. 依次进入 系统偏好设置 -> 扩展 -> Finder 扩展。
3. 勾选 OpenInTerminalFinderExtension 旁的复选框，如下图所示：

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590336-448f4180-7874-11ea-827c-ad3a7bffca5e.png" width="400px">
</div>

### 针对 Neovim 用户

如果您在 OpenInTerminal 中选择 Neovim 作为编辑器，应用将使用 Kitty 作为默认终端。要切换到其他终端（支持的选项包括 Alacritty、WezTerm 和 Kitty），请使用以下命令更新配置。将 `<Your Name>` 替换为您的用户名，并根据您的安装调整 Neovim 路径（此示例为 `/opt/homebrew/bin/nvim`）：

```
defaults write /Users/<Your Name>/Library/Group\ Containers/group.wang.jianing.app.OpenInTerminal/Library/Preferences/group.wang.jianing.app.OpenInTerminal.plist NeovimCommand "open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
```

其他终端配置：

```
// kitty:
"open -na kitty --args /opt/homebrew/bin/nvim PATH"
// WezTerm:
"open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
// Alacritty:
"open -na Alacritty --args -e /opt/homebrew/bin/nvim PATH"
```

### 针对 Kitty 用户

默认情况下，Kitty 的启动行为是为每个命令打开一个新实例，如下所示：

```
open -na kitty --args --single-instance --instance-group 1 --directory
```

如果您想自定义此行为，可以在终端中运行以下命令。请确保将 <Your Name> 替换为您的用户名，并根据需要调整命令：

```
defaults write /Users/<Your Name>/Library/Group\ Containers/group.wang.jianing.app.OpenInTerminal/Library/Preferences/group.wang.jianing.app.OpenInTerminal.plist KittyCommand "open -na kitty --args --single-instance --instance-group 1 --directory"
```

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

