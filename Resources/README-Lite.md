<div align="center">
  <img width="100%" src="https://user-images.githubusercontent.com/11001224/104892184-d522b280-59ac-11eb-9c06-5ffd044dce7d.png"><br/><br/>
  English | <a href="./README-Lite-zh.md">中文</a> | <a href="./README-Lite-de.md">Deutsch</a>
</div>

## How to use 🚀

### 1) Open current directory in Terminal (or Editor)

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78589363-b23a6e00-7872-11ea-841d-79227b1125ce.gif" width="600px">
</div>

### 2) Open selected folder or file in Terminal (or Editor)

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78589359-afd81400-7872-11ea-8032-8035d4412b19.gif" width="600px">
</div>

### 3) Open the selected in X (e.g., GitHub Desktop)

<div>
  <img src="https://user-images.githubusercontent.com/11001224/104891620-28483580-59ac-11eb-9fb5-3e4dec7863cc.gif" width="600px">
</div>

## How to install 🖥

### Homebrew

1. Run the following command

```
brew install --cask openinterminal-lite
brew install --cask openineditor-lite
```

2. In `/Applications` folder, hold down the `Cmd` key and drag the app into Finder Toolbar.

>  ⚠️ macOS will ask your permissions to access Finder and Terminal (iTerm or Hyper) when you run the app for the first time. Please give the application permissions.

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590414-67215a80-7874-11ea-97a1-fb8996db6984.gif" width="600px">
</div>

### Manual

1. Download from [release](https://github.com/Ji4n1ng/OpenInTerminal/releases).
2. Move the app into `/Applications`.
3. Hold down the `Cmd` key and drag the app into Finder Toolbar.

## Support ❤️

Open-source projects cannot live long without your help. If you like OpenInTerminal, please consider supporting this project by becoming a sponsor. Your user icon or company logo shows up on the README with a link to your home page.

Become a sponsor through [GitHub Sponsors](https://github.com/sponsors/Ji4n1ng) 💖.

| PayPal | AliPay | WeChat Pay |
| --- | --- | --- |
| [paypal.me/ji4ning](https://www.paypal.me/ji4ning) | <img src="./Support-Alipay.jpg" width="50%"> | <img src="./Support-WeChatPay.jpg" width="50%"> |

<!-- ### Backers & Sponsors -->
<!---->
<!-- <a href="https://github.com/sparrowcode"><img src="https://avatars.githubusercontent.com/u/98487302?s=200&v=4" width="10%" style="border-radius:10px;" /></a> -->

## Settings 🔨

### 1) Set default terminal (or editor)

You are asked to set the default terminal (or editor) to open after first launch.

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78600459-8b396780-7885-11ea-8226-2fe45e539134.png" width="45%">
  <img src="https://user-images.githubusercontent.com/11001224/78600438-88d70d80-7885-11ea-9bcb-d70fcaaf7334.png" width="45%">
</div>

The selection box will not appear after you have set the default terminal. If you want to reset the default terminal, please enter the following command in the terminal. Then just run the application again.

```
# For OpenInTerminal-Lite:
defaults remove wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal
# For OpenInEditor-Lite:
defaults remove wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor
```

Set the following app as the default app to open:

| App | Command |
| --- | --- |
| Alacritty | `defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal Alacritty` |
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

In particular, if you want to use a custom application as the default, then you can also use this command. Take `GitHub Desktop` as an example.

```
defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal GitHub\ Desktop
```

#### For Neovim Users

If you select Neovim as your editor, the app will use Kitty as the default terminal. To switch to a different terminal (supported options: Alacritty, WezTerm, and Kitty), update the configuration with the following command. Adjust the Neovim path (`/opt/homebrew/bin/nvim` in this example) to match your installation:

```
defaults write wang.jianing.app.OpenInEditor-Lite NeovimCommand "open -na Alacritty --args -e /opt/homebrew/bin/nvim PATH"
```

Other terminal configurations:

```
// kitty:
"open -na kitty --args /opt/homebrew/bin/nvim PATH"
// WezTerm:
"open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
// Alacritty:
"open -na Alacritty --args -e /opt/homebrew/bin/nvim PATH"
```

#### For Kitty Users

The default launch behavior for kitty is to open a new instance for each command, like the following:

```
open -na kitty --args --single-instance --instance-group 1 --directory
```

If you want to customize this behavior, you can run the following command in your terminal. Make sure to replace the open command as what you want:

```
defaults write wang.jianing.app.OpenInTerminal-Lite KittyCommand "open -na kitty --args --single-instance --instance-group 1 --directory"
```

### 2) If you are using Dark Mode

I provided several icons along with the app in the [release page](https://github.com/Ji4n1ng/OpenInTerminal/releases).

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78600452-8aa0d100-7885-11ea-8a90-cc88b9233dac.png" width="600px">
</div>

#### a. Changing the icon manually

You can right click on the app and select `Get Info`. Drag the icon to cover the default icon.

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590421-68eb1e00-7874-11ea-91e3-61cfd5ba3a26.gif" width="600px">
</div>

#### b. Changing the icon automatically with [Hammerspoon](https://www.hammerspoon.org)

This procedure is particularly useful for those using the automatic dark/light mode switching feature of macOS.

1. Install Hammerspoon either by [downloading the latest release](https://github.com/Hammerspoon/hammerspoon/releases/latest) and dragging it in the `/Applications` folder, or by using Homebrew:
```
brew install --cask hammerspoon
```

2. Install the [fileicon](https://github.com/mklement0/fileicon) utility to change the app icon programmatically:
```
brew install fileicon
```

3. Create the `~/.hammerspoon/Icons` folder and put the icons there

4. Create the `~/.hammerspoon/init.lua` file (if it doesn't already exist) and add the following code:
```lua
local function setOpenInEditorLiteIcon(dark)
  -- Change the path in case of a different install location
  local appPath = "/Applications/OpenInEditor-Lite.app"
  -- Change the type accordingly to the icon you want to use (editor, atom, sublime, vscode)
  local iconType = "editor"
  local iconsFolder = hs.fs.currentDir() .. "/Icons"
  local theme = dark and "dark" or "light"
  hs.execute('fileicon set "' .. appPath .. '" "' .. iconsFolder .. "/icon_" .. iconType .. "_" .. theme .. '.icns"', true)
end

local function setOpenInTerminalLiteIcon(dark)
  -- Change the path in case of a different install location
  local appPath = "/Applications/OpenInTerminal-Lite.app"
  -- Change the type accordingly to the icon you want to use (terminal, iterm, hyper)
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

You can now reload the config file (or restart hammerspoon) and you're done! The icons should automatically update when switching from light to dark mode and vice versa. Don't forget to check the "Launch Hammerspoon at login" option.

### 3) Open in a new Tab or Window when using iTerm

When you are using `iTerm`, you can set a default to open a new tab or window. The **default** is to open a new window. 

```
# Open a new Tab
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false
# Open a new Window
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool true
```

## FAQ ❓

<details><summary>1. Oops, hit <code>Don't Allow</code> button by mistake.</summary><br>
<p>No sweat! Just run the following command in your terminal, and it'll reset the permissions in System Preferences.</p>
<pre><code># For OpenInTerminal-Lite:
tccutil reset AppleEvents wang.jianing.app.OpenInTerminal-Lite
# For OpenInEditor-Lite:
tccutil reset AppleEvents wang.jianing.app.OpenInEditor-Lite
</code></pre>
</details>

<details><summary>2. Special characters in the <code>path</code>.</summary><br>
<p>Please do not use backslash <code>\</code> and double quotes <code>"</code> in the path</p>
</details>

<details><summary>3. Why it cannot automatically switch icons in Dark mode</summary><br>
<p>As for <code>OpenInTerminal-Lite</code>, the icon you see in the Finder Toolbar is actually the app icon, not the Finder extension icon. And I haven't found an API yet that lets you swtich the app icon on the fly (got any cool ideas? Do share!). 
<p>But hey, good news! Thanks to @MatteoCarnelos's awesome contribution (#126), <code>OpenInTerminal-Lite</code> can now automatically switch icons using Hammerspoon.</p>
</details>

<details><summary>4. My custom app doesn't work.</summary><br>
<p>If your custom application doesn't work with the following command, then it's not supported. For example, GitHub Desktop:</p>
<code>open -a GitHub\ Desktop ~/Desktop</code>
</details>

## Changes 🗒

<details><summary>show all</summary><br>
<p><strong>version 1.2.7</strong></p>
<ul>
<li>Support "open in neovim" for Alacritty, WezTerm, and kitty users.</li>
<li>Customize open command for kitty users</li>
</ul>
<p><strong>version 1.2.6</strong></p>
<ul>
<li>Support Korean</li>
<li>For kitty users: open in a signle instance instead of a new one</li>
</ul>
<p><strong>version 1.2.5</strong></p>
<ul>
<li>Support German</li>
</ul>
<p><strong>version 1.2.4</strong></p>
<ul>
<li>Support Turkish</li>
</ul>
<p><strong>version 1.2.3</strong></p>
<ul>
<li>Fix: cannot open path with white space when using Terminal</li>
</ul>
<p><strong>version 1.2.2</strong></p>
<ul>
<li>Fix: cannot open alacritty</li>
<li>Fix: cannot set default editor</li>
</ul>
<p><strong>version 1.2.1</strong></p>
<ul>
<li>Fix: cannot open alacritty</li>
<li>Fix: cannot set default editor</li>
</ul>
<p><strong>version 1.2.0</strong></p>
<ul>
<li>Support setting custom app (Not all apps support)</li>
<li>BigSur-style icon</li>
</ul>
<p><strong>version 1.1.5</strong></p>
<ul>
<li>fix bug in OpenInEditor-Lite</li>
</ul>
<p><strong>version 1.1.4</strong></p>
<ul>
<li>Support kitty</li>
<li>Open multi-selected files in editors</li>
</ul>
<p><strong>version 1.1.3</strong></p>
<ul>
<li>Support Italian and Spanish</li>
</ul>
<p><strong>version 1.1.2</strong></p>
<ul>
<li>Support JetBrains</li>
</ul>
<p><strong>version 1.1.1</strong></p>
<ul>
<li>Support Russian and Korean</li>
<li>Support PhpStorm</li>
</ul>
<p><strong>version 1.1.0</strong></p>
<ul>
<li>Support CotEditor and MacVim</li>
</ul>
<p><strong>version 1.0.3</strong></p>
<ul>
<li>Signed the application with the developer account. Bundle ID has changed</li>
<li>Support Korean</li>
</ul>
<p><strong>version 1.0.2</strong></p>
<ul>
<li>Support TextMate</li>
<li>Change OpenInEditor-Lite default icon</li>
</ul>
<p><strong>version 1.0.1</strong></p>
<ul>
<li>Support Visual Studio Code - Insiders</li>
</ul>
<p><strong>version 1.0.0</strong></p>
<ul>
<li>Support BBEdit</li>
<li>Fix: check application folder under home directory</li>
</ul>
<p><strong>version 0.4.4</strong></p>
<ul>
<li>iTerm will not leave 'cd xxx' in history</li>
<li>Fix: icon will not flash in dock</li>
</ul>
<p><strong>version 0.4.3</strong></p>
<ul>
<li>Fix localization bug</li>
</ul>
<p><strong>version 0.4.2</strong></p>
<ul>
<li>Support French</li>
</ul>
<p><strong>version 0.4.1</strong></p>
<ul>
<li>Support Alacritty</li>
</ul>
<p><strong>version 0.4.0</strong></p>
<ul>
<li>You can set a default to open a new tab or window when using Terminal and Hyper.</li>
</ul>
<p><strong>version 0.3.0</strong></p>
<ul>
<li>Change name to OpenInTerminal-Lite (OpenInTerminal will come as a more powerful version in the future.)</li>
<li>Fix a bug that some special characters in the path would crash the program when opening Hyper.</li>
</ul>
<p><strong>version 0.2.0</strong></p>
<ul>
<li>Add terminal selector</li>
<li>Cancel running <code>clear</code> command when opening iTerm</li>
</ul>
<p><strong>version 0.1.1</strong></p>
<ul>
<li>Support <code>Hyper</code></li>
<li>Give priority to creating a new tab when opening iTerm</li>
</ul>
<p><strong>version 0.1.0</strong></p>
<ul>
<li>First release</li>
</ul>
<br>
</details>

## Special Thanks to ❤️

All the contributors who have helped with the development of OpenInTerminal-Lite.

### Reference projects

- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)
