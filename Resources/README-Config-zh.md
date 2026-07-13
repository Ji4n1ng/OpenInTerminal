# OpenInTerminal 配置

## 安装未签名的应用

首次启动时，macOS 可能会拒绝打开应用，例如提示 `“OpenInTerminal”已损坏，无法打开` 或 `无法打开，因为 Apple 无法检查其是否包含恶意软件`。

1. 将应用（`OpenInTerminal.app`、`OpenInTerminal-Lite.app` 或 `OpenInEditor-Lite.app`）移动到 `/Applications` 文件夹。

2. 移除 macOS 为下载或拷贝的应用附加的隔离（quarantine）属性（对每个已安装的应用重复执行，并替换名称）：

   ```
   xattr -dr com.apple.quarantine /Applications/OpenInTerminal.app
   ```

   这一步很重要：除了消除“已损坏”提示外，它还能阻止 macOS 从随机的只读位置运行应用（*App Translocation*，应用位置随机化），否则 Finder 扩展将无法注册。

3. 启动应用。

不想使用命令行？可在访达中按住 Control 键点按（右键点按）应用并选择 `打开`，然后在弹窗中确认。在 macOS 15 (Sequoia) 及更高版本中，请在首次被拦截后进入 `系统设置` -> `隐私与安全性`，找到 **安全性** 部分并点击 `仍要打开`。

## Finder 扩展配置

要启用 Finder 扩展，请右键单击 Finder 工具栏，然后选择 自定义工具栏...，如下图所示：

<div>
  <img src="https://github.com/user-attachments/assets/c834f0d1-2f9d-4200-984c-3f6330eaeb2d" width="400px">
</div>

然后将 OpenInTerminal 图标拖动到工具栏中：

<div>
  <img src="https://github.com/user-attachments/assets/261eb747-27f0-4484-9654-40cab8a52008" width="400px">
</div>

### macOS 15 及更高版本中 Finder 扩展未显示在系统设置中

#### 1) 在设置中启用 Finder 扩展（Tahoe）

依次进入 `系统设置` -> `通用` -> `登录项与扩展` -> `OpenInTerminal Extensions`，然后启用 `File Provider`。

#### 2) 手动启用 Finder 扩展（macOS 15）

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

#### 3) 使用 FinderSyncer

或者，您可以使用一个名为 [FinderSyncer](https://zigz.ag/FinderSyncer/) 的图形界面工具来启用扩展。

### 在 macOS 14 及更早版本中检查 Finder 扩展权限

对于 macOS 14 及更早版本，请确保通过系统偏好设置启用了 Finder 扩展：

1. 打开 OpenInTerminal 应用。
2. 依次进入 系统偏好设置 -> 扩展 -> Finder 扩展。
3. 勾选 OpenInTerminalFinderExtension 旁的复选框，如下图所示：

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590336-448f4180-7874-11ea-827c-ad3a7bffca5e.png" width="400px">
</div>

## 自定义配置

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

<details><summary>我不小心点了不授权的按钮</summary><br>
<p>你可以运行以下命令。这会重置系统设置里的权限。</p>
<pre><code>tccutil reset AppleEvents wang.jianing.app.OpenInTerminal</code></pre>
</details>

<details><summary>路径里的特殊字符</summary><br>
<p>请不要在路径中使用反斜线 <code>\</code> 和双引号 <code>"</code>。</p>
</details>

<details><summary>在 Mojave 上打开了两个终端窗口</summary><br>
<p>这个问题只发生在第一次启动终端的时候。所以，你可以通过 <code>⌘W</code> 来关闭终端的窗口，而不是用 <code>⌘Q</code> 来退出终端。</p>
</details>

<details><summary>OpenInTerminal 并不按照我的预期来工作</summary><br>
<p>OpenInTerminal 将会按照以下顺序来打开终端或编辑器：</p>
<ul>
<li>1. 打开你所选中的文件或文件夹。</li>
<li>2. 打开最上面的访达窗口。</li>
<li>3. 都不是。那么打开桌面。</li>
</ul>
</details>

<details><summary>我的自定义应用不工作</summary><br>
<p>如果你的自定义应用不能通过运行以下命令正常运行，那么该应用不支持通过 OpenInTerminal 打开。例如，GitHub Desktop:</p>
<code>open -a GitHub\ Desktop ~/Desktop</code>
</details>

