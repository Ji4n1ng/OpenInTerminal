<div align="center">
  <img width="80%" src="https://github.com/user-attachments/assets/43667e33-d02d-4a0e-8ca9-fd1cf411b24a"><br/><br/>
  <a href="./README.md">English</a> | <a href="./Resources/README-zh.md">中文</a> | <a href="./Resources/README-tr.md">Türkçe</a> | <a href="./Resources/README-de.md">Deutsch</a>
</div>

## How to use 🚀

| Core Features | OpenInTerminal |
| --- | --- |
| Open items (e.g., folders or files) in Terminal or Editor. | ![](https://user-images.githubusercontent.com/11001224/78589385-b797b880-7872-11ea-9062-c11a49461598.gif) | 
| Open the selected item in your preferred apps (e.g., Github Desktop, Fork). | ![](https://user-images.githubusercontent.com/11001224/104891620-28483580-59ac-11eb-9fb5-3e4dec7863cc.gif) |

### More features

| Features | OpenInTerminal | OpenInTerminal-Lite & OpenInEditor-Lite |
| --- | --- | --- |
| Support Terminal, [iTerm](https://www.iterm2.com/), [Hyper](https://github.com/zeit/hyper), [Alacritty](https://github.com/jwilm/alacritty), [kitty](https://sw.kovidgoyal.net/kitty/), [Warp](https://www.warp.dev), [WezTerm](https://wezfurlong.org/wezterm/index.html), [Tabby](https://tabby.sh), [Ghostty](https://ghostty.org/), [cmux](https://github.com/manaflow-ai/cmux). | ✅ | ✅ |
| Support TextEdit, Xcode, [Visual Studio Code](https://code.visualstudio.com/), [VSCode Insiders](https://code.visualstudio.com/insiders/), [Atom](https://atom.io/), [Sublime Text](https://www.sublimetext.com/), [VSCodium](https://github.com/VSCodium/vscodium), [BBEdit](https://www.barebones.com/products/bbedit/), [TextMate](https://macromates.com), [CotEditor](https://coteditor.com/), [MacVim](https://github.com/macvim-dev/macvim), [JetBrains](https://www.jetbrains.com/)(AppCode, CLion, GoLand, IntelliJ IDEA, PhpStorm, PyCharm, RubyMine, WebStorm, Android Studio, Fleet), [Typora](https://typora.io/), [Nova](https://nova.app/), [Cursor](https://cursor.sh/), [notepad--](https://github.com/cxasm/notepad--), [neovim](https://neovim.io/). | ✅ | ✅ |
| Open in custom apps. (⚠️ Not all apps support.) | ✅ | ✅ |
| Support English, Chinese, French, Russian, Italian, Spanish, Turkish, German and Korean | ✅ | ✅ |
| GUI preferences | ✅ | ❌ |
| Support keyboard shortcuts. | ✅ | ❌ |

## OpenInTerminal vs OpenInTerminal-Lite 👀

Wondering which one to choose? If you're all about fancy features and GUI settings, go for `OpenInTerminal`. But if you just want to open your terminal quickly and without fuss, `OpenInTerminal-Lite` is your buddy.

I personally prefer `OpenInTerminal-Lite`. Why? It's a one-click wonder (while the other makes you click twice 😂) and it's more lightweight.

Check **OpenInTerminal-Lite** Docs: [English](./Resources/README-Lite.md) | [中文](./Resources/README-Lite-zh.md) | [Deutsch](./Resources/README-Lite-de.md)


## Installation 🖥

> ⚠️ **Important:** Signed builds are no longer provided for **OpenInTerminal**, **OpenInTerminal-Lite**, or **OpenInEditor-Lite**. Before using these apps, please either trust the unsigned binaries or sign them yourself. See the [Configuration](./Resources/README-Config.md) document for how to install and trust unsigned apps.

```
brew install --cask openinterminal
```

Or manually download it from [release](https://github.com/Ji4n1ng/OpenInTerminal/releases).

## Configuration and FAQ ⚙️

Please check the [Configuration](./Resources/README-Config.md) document.

Note: If you're on macOS 15 and above then you must follow the instructions in this document to make the context menu items appear.

## Support ❤️

Open-source projects cannot live long without your help. If you like OpenInTerminal, please consider supporting this project by becoming a sponsor. Your user icon or company logo shows up on the README with a link to your home page.

Become a sponsor through [GitHub Sponsors](https://github.com/sponsors/Ji4n1ng) 💖.

| PayPal | AliPay | WeChat Pay |
| --- | --- | --- |
| [paypal.me/ji4ning](https://www.paypal.me/ji4ning) | <img src="./Resources/Support-Alipay.jpg" width="50%"> | <img src="./Resources/Support-WeChatPay.jpg" width="50%"> |

<!-- ### Backers & Sponsors -->
<!---->
<!-- <a href="https://github.com/wcoder"><img src="https://avatars.githubusercontent.com/u/766193?v=4" width="10%" style="border-radius:10px;" /></a> -->


## Changes 🗒

<details><summary>show all</summary><br>
<p><strong>version 2.3.9</strong></p>
<ul>
<li>Security: Fixed an AppleScript/command injection vulnerability that allowed arbitrary command execution via a crafted folder name when opening it in a non-default terminal or an editor. Thanks to Paul Gerste (<a href="https://www.sonarsource.com">Sonar</a>) for the responsible disclosure.</li>
<li>Added support for Zed, Emacs, Kakoune, GitKraken, and cmux.</li>
<li>Added an option to limit global keyboard shortcuts to Finder-only shortcuts. (#251, #243)</li>
<li>Introduced a new default app icon with automatic light/dark mode support.</li>
<li>Added an option to display the Finder context menu items in a submenu.</li>
<li>Fixed the Finder extension icon being rendered as a template icon.</li>
<li>Improved startup responsiveness by fetching installed applications on a background thread.</li>
<li>Fixed the keyboard shortcut overlapping the "Open in ..." title in the status bar menu.</li>
</ul>
<p><strong>version 2.3.8</strong></p>
<ul>
<li>Support "open in neovim" for Alacritty, WezTerm, and kitty users.</li>
<li>Customize open command for kitty users</li>
<li>Copy path with escaping</li>
<li>Support fork, notepad--, Ghostty</li>
<li>Support nix installed applications</li>
</ul>
<p><strong>version 2.3.7</strong></p>
<ul>
<li>Support Korean</li>
<li>Support Warp</li>
<li>Support WezTerm</li>
<li>Support Tabby</li>
<li>Support Fleet</li>
<li>Support Nova</li>
<li>Support Cursor</li>
<li>Support Xcode</li>
<li>For kitty users: open in a signle instance instead of a new one</li>
</ul>
<p><strong>version 2.3.6</strong></p>
<ul>
<li>Support German</li>
<li>Search apps installed by JetBrains Toolbox</li>
<li>Support Android Studio</li>
</ul>
<p><strong>version 2.3.5</strong></p>
<ul>
<li>Support dragging to reorder custom menu</li>
<li>Support Turkish</li>
<li>Support Typora</li>
</ul>
<p><strong>version 2.3.4</strong></p>
<ul>
<li>Update icons in context menu</li>
</ul>
<p><strong>version 2.3.3</strong></p>
<ul>
<li>Fix: cannot open path with white space when using shortcut</li>
</ul>
<p><strong>version 2.3.2</strong></p>
<ul>
<li>Fix: cannot open path with white space</li>
</ul>
<p><strong>version 2.3.1</strong></p>
<ul>
<li>Fix: cannot open alacritty</li>
<li>Feat: add quit button in preferences</li>
</ul>
<p><strong>version 2.3.0</strong></p>
<ul>
<li>Open custom apps. (Not all apps support)</li>
<li>Show icon in context menu. (For stability, old Mac models are not recommended to display icons)</li>
</ul>
<p><strong>version 2.2.3</strong></p>
<ul>
<li>Support kitty</li>
<li>Open multi-selected files in editors</li>
</ul>
<p><strong>version 2.2.2</strong></p>
<ul>
<li>Support Italian and Spanish</li>
<li>Fix: does not show Terminal and TextEdit</li>
</ul>
<p><strong>version 2.2.1</strong></p>
<ul>
<li>Support JetBrains</li>
<li>Fix: check whether an application exists</li>
</ul>
<p><strong>version 2.2.0</strong></p>
<ul>
<li>Custom Finder menu options</li>
<li>Support Russian</li>
<li>Support PhpStorm</li>
<li>Fix: doesn't work when opening desktop in terminal</li>
</ul>
<p><strong>version 2.1.1</strong></p>
<ul>
<li>Signed the application with the developer account. Bundle ID has changed</li>
<li>Support Finder Extension Standalone Operation Mode</li>
<li>Support CotEditor and MacVim</li>
<li>User can hide context menu items</li>
<li>Finder context menu item's title will change to the current default terminal or editor</li>
</ul>
<p><strong>version 2.0.5</strong></p>
<ul>
<li>Fix: check application exist bug</li>
</ul>
<p><strong>version 2.0.4</strong></p>
<ul>
<li>Support TextMate</li>
<li>Fix: keyboard shortcut bug</li>
</ul>
<p><strong>version 2.0.3</strong></p>
<ul>
<li>Fix: Finder context menu icon supports dark mode</li>
</ul>
<p><strong>version 2.0.2</strong></p>
<ul>
<li>Support Visual Studio Code - Insiders</li>
<li>Support for hiding the status bar icon</li>
</ul>
<p><strong>version 2.0.1</strong></p>
<ul>
<li>Support BBEdit</li>
<li>Add icon in Finder context menu</li>
<li>Fix: check application folder under home directory</li>
</ul>
<p><strong>version 0.10.2</strong></p>
<ul>
<li>Fix: Finder context menu does not appear on other disks.</li>
</ul>
<p><strong>version 0.10.1</strong></p>
<ul>
<li>iTerm will not leave `cd xxx` in history.</li>
<li>You need to click the `window` button or the `tab` button of iTerm again in `Preferences`.</li>
</ul>
<p><strong>version 0.10.0</strong></p>
<ul>
<li>Support keyboard shortcuts.</li>
<li>Support VSCodium.</li>
</ul>
<p><strong>version 0.9.1</strong></p>
<ul>
<li>Support French.</li>
</ul>
<p><strong>version 0.9.0</strong></p>
<ul>
<li>OpenInTerminal has been released after several weeks of development. If you have suggestions or there are bugs, please feel free to open an issue.</li>
</ul>
<p><strong>version 0.4.1</strong></p>
<ul>
<li>Support <code>Alacritty</code></li>
</ul>
<p><strong>version 0.4.0</strong></p>
<ul>
<li>You can set a default to open a new tab or window when using <code>Terminal</code> and <code>Hyper</code>.</li>
</ul>
<p><strong>version 0.3.0</strong></p>
<ul>
<li>Change name to <code>OpenInTerminal-Lite</code> (<code>OpenInTerminal</code> will come as a more powerful version in the future.)</li>
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

Thanks to all [backers](https://github.com/sponsors/Ji4n1ng) and [contributors](https://github.com/Ji4n1ng/OpenInTerminal/graphs/contributors). Your work makes OpenInTerminal better.

### Reference projects

- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)
