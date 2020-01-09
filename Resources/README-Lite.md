<p align="center">
  <img width="100%" src="./screenshots/lite-readme-header.png"><br/><br/>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/releases/tag/1.1.0"><img src="https://img.shields.io/badge/Version-1.1.0-blue.svg?longCache=true&style=for-the-badge"></a>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?longCache=true&style=for-the-badge"></a>
  <img src="https://img.shields.io/badge/Made With-Swift-red.svg?longCache=true&style=for-the-badge">
  <a href="https://travis-ci.org/Ji4n1ng/OpenInTerminal"><img src="https://img.shields.io/travis/Ji4n1ng/OpenInTerminal.svg?style=for-the-badge"></a>
</p>

English | [中文说明](./README-Lite-zh.md)

## How to use 🚀

### 1) Open current directory in Terminal (or Editor)

<div>
  <img src="./screenshots/lite-run.gif" width="600px">
</div>

### 2) Open selected folder or file in Terminal (or Editor)

<div>
  <img src="./screenshots/lite-run-editor.gif" width="600px">
</div>

## How to install 🖥

### Homebrew (current version: 1.1.0)

1. Run the following command

```
brew cask install openinterminal-lite
# or
brew cask install openineditor-lite
```

2. In `/Applications` folder, hold down the `Cmd` key and drag the app into Finder Toolbar.

>  ⚠️ macOS will ask your permissions to access Finder and Terminal (iTerm or Hyper) when you run the app for the first time. Please give the application permissions.

<div>
  <img src="./screenshots/lite-drag_to_toolbar.gif" width="600px">
</div>

### Manual (latest version: 1.1.0)

1. Download from [release](https://github.com/Ji4n1ng/OpenInTerminal/releases).
2. Move the app into `/Applications`.
3. Hold down the `Cmd` key and drag the app into Finder Toolbar.

## Support ❤️

Hello, I am Ji4n1ng. I am a student and OpenInTerminal is an open source project I maintain in my spare time. It is free and open source. I will be very grateful that you can support me in purchasing an Apple Developer account. $99/year is not a small expense for students. It's close to my three-week living expenses. Thanks a lot!

| PayPal | AliPay | WeChat Pay |
| --- | --- | --- |
| [paypal.me/ji4n1ng](https://www.paypal.me/ji4n1ng) | ![AliPay](./screenshots/Alipay.jpg) | ![WeChatPay](./screenshots/WeChatPay.jpg) |

## Settings 🔨

### 1) Set default terminal (or editor)

You are asked to set the default terminal (or editor) to open after first launch.

<div>
  <img src="./screenshots/lite-terminal-selector.png" width="45%">
  <img src="./screenshots/lite-editor-selector.png" width="45%">
</div>

The selection box will not appear after you have set the default terminal. If you want to reset the default terminal, please enter the following command in the terminal. Then just run the application again.

```
# For OpenInTerminal-Lite:
defaults remove wang.jianing.app.OpenInTerminal-Lite OIT_TerminalBundleIdentifier
# For OpenInEditor-Lite:
defaults remove wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier
```

<details><summary>Set <strong>Alacritty</strong> as the default terminal:</summary><br>
<code>defaults write wang.jianing.app.OpenInTerminal-Lite OIT_TerminalBundleIdentifier Alacritty</code>
<br>
</details>

<details><summary>Set <strong>VSCodium</strong> as the default editor:</summary><br>
<code>defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier VSCodium</code>
<br>
</details>

<details><summary>Set <strong>BBEdit</strong> as the default editor:</summary><br>
<code>defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier BBEdit</code>
<br>
</details>

<details><summary>Set <strong>Visual Studio Code - Insiders</strong> as the default editor:</summary><br>
<code>defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier VSCodeInsiders</code>
<br>
</details>

<details><summary>Set <strong>TextMate</strong> as the default editor:</summary><br>
<code>defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier TextMate</code>
<br>
</details>

<details><summary>Set <strong>CotEditor</strong> as the default editor:</summary><br>
<code>defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier CotEditor</code>
<br>
</details>

<details><summary>Set <strong>MacVim</strong> as the default editor:</summary><br>
<code>defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier MacVim</code>
<br>
</details>

### 2) If you are using Dark Mode

I provided several icons along with the app in the [release](https://github.com/Ji4n1ng/OpenInTerminal/releases). You can right click on the app and select `Get Info`. Drag the icon to cover the default icon.

<div>
  <img src="./screenshots/lite-icons.png" width="600px">
  <br>
  <img src="./screenshots/lite-change_icon.gif" width="600px">
</div>

### 3) Open in a new Tab or Window

When you are using `Terminal` and `iTerm`, you can set a default to open a new tab or window. The **default** is to open a new window. 

#### For Terminal:

```
# Open a new Tab
defaults write wang.jianing.app.OpenInTerminal-Lite OIT_TerminalNewOption tab
# Open a new Window
defaults write wang.jianing.app.OpenInTerminal-Lite OIT_TerminalNewOption window
```

#### For iTerm:

```
# Open a new Tab
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false
# Open a new Window
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool true
```

For `Hyper` users, it is more recommended to open a new tab.

For `Alacritty` users, it is only supported to open a new window now.

## FAQ ❓

<details><summary>1. I accidentally clicked on the <code>Don't Allow</code>  button.</summary><br>
<p>You can run the following command in the terminal. This will reset the permissions in the System Preferences.</p>
<pre><code>tccutil reset AppleEvents
</code></pre>
</details>

<details><summary>2. Special characters in the <code>path</code>.</summary><br>
<p>Please do not use backslash <code>\</code> and double quotes <code>"</code>   in the path</p>
</details>

<details><summary>3. Why it cannot automatically switch icons when switching from/to Dark mode</summary><br>
<p>As for <code>OpenInTerminal-Lite</code>, the icon in Finder Toolbar is app icon not Finder extension icon. And I have not found a API to change the app icon (If you have any good idea, please let me know). Therefore, it is not currently possible to replace it automatically based on Dark mode.<br>
As for <code>OpenInTerminal</code>, the icon of it in Finder Toolbar is Finder extension icon. It can change automatically when switching between dark mode and light mode. So you can try to use OpenInTerminal.</p>
</details>

## Changes 🗒

**version 1.1.0**

- Support CotEditor and MacVim.

**version 1.0.3**

- Signed the application with the developer account. Bundle ID has changed.
- Support Korean.

<details><summary>old version</summary><br>
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

### Contributors

- [Camji55](https://github.com/Camji55)

### Translators

- [Dorian Eydoux](https://github.com/dorianeydx)
- [techinpark](https://github.com/techinpark)

### Reference projects

- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
