## OpenInTerminal Configurations

### Finder Extension Not Showing Up in System Settings on macOS 15

Starting with macOS 15, Apple removed the Finder Sync Extension configuration from System Settings. To enable the Finder Extension, use the `pluginkit` command-line tool as follows:

```
$ pluginkit -mAD -p com.apple.FinderSync -vvv
```

You should see output similar to the following:

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

To manually enable the Finder Extension, run the following command with the UUID from the output:

```
$ pluginkit -e "use" -u "F2547F13-4E43-4E88-9D8F-56DF05C020D8"
```

Alternatively, you could use a GUI tool called [FinderSyncer](https://zigz.ag/FinderSyncer/) to enable the extension.

### Checking Finder Extension Permissions on macOS 14 and Earlier

For macOS 14 and earlier, ensure the Finder Extension is enabled via System Preferences:

1. Open the OpenInTerminal app.
2. Navigate to `System Preferences` -> `Extensions` -> `Finder Extensions`.
3. Check the checkbox next to `OpenInTerminalFinderExtension`, as shown below:

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590336-448f4180-7874-11ea-827c-ad3a7bffca5e.png" width="400px">
</div>

### For Neovim Users

If you select Neovim as your editor in OpenInTerminal, the app will use Kitty as the default terminal. To switch to a different terminal (supported options: Alacritty, WezTerm, and Kitty), update the configuration with the following command. Replace `<Your Name>` with your username and adjust the Neovim path (`/opt/homebrew/bin/nvim` in this example) to match your installation:

```
defaults write /Users/<Your Name>/Library/Group\ Containers/group.wang.jianing.app.OpenInTerminal/Library/Preferences/group.wang.jianing.app.OpenInTerminal.plist NeovimCommand "open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
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

### For Kitty Users

The default launch behavior for kitty is to open a new instance for each command, like the following:

```
open -na kitty --args --single-instance --instance-group 1 --directory
```

If you want to customize this behavior, you can run the following command in your terminal. Make sure to replace `<Your Name>` with your username and adjust the open command as what you want:

```
defaults write /Users/<Your Name>/Library/Group\ Containers/group.wang.jianing.app.OpenInTerminal/Library/Preferences/group.wang.jianing.app.OpenInTerminal.plist KittyCommand "open -na kitty --args --single-instance --instance-group 1 --directory"
```

## FAQ ❓

<details><summary>1. What is the difference between OpenInTerminal and OpenInTerminal-Lite?</summary><br>
<p>OpenInTerminal's got two flavors: the regular and the lite. If you're into fancy features and GUI preferences, stick with the standard OpenInTerminal. But if you just wanna open terminal in a quick and stably way, OpenInTerminal-Lite is your friend.</p>
</details>

<details><summary>2. Oops, hit <code>Don't Allow</code> button by mistake.</summary><br>
<p>No sweat! Just run the following command in your terminal, and it'll reset the permissions in System Preferences.</p>
<br><code>tccutil reset AppleEvents wang.jianing.app.OpenInTerminal</code><br>
</details>

<details><summary>3. Special characters in the <code>path</code>.</summary><br>
<p>Please do not use backslash <code>\</code> and double quotes <code>"</code> in the path.</p>
</details>

<details><summary>4. Open two Terminal windows on Mojave</summary><br>
<p>This problem usually occurs when you first start Terminal. Try using <code>⌘W</code> to close Terminal window, instead of using <code>⌘Q</code> to quit Terminal.</p>
</details>

<details><summary>5. OpenInTerminal's Finder extension doesn't work.</summary><br>
<p>The Finder extension relies on AppleScript. So it's hard to guarantee its stability. When the extension doesn't work properly, try this: hold down the <code>Option(⌥)</code> key, right-click on Finder, and select <code>Relaunch</code>.</p>
<p>Got an older Mac like me? Maybe cancel showing the icon in the context menu in Preferences. If it still crashes frequently, consider switching to OpenInTerminal-Lite.</p>
</details>

<details><summary>6. OpenInTerminal doesn't work as I expected</summary><br>
<p>OpenInTerminal works as the following order:</p>
<ul>
<li>1. Open the file or folder you selected.</li>
<li>2. If nothing's selected, it opens the top Finder window.</li>
<li>3. If there's no Finder window, it opens the desktop.</li>
</ul>
</details>

<details><summary>7. My custom app doesn't work.</summary><br>
<p>If your custom application doesn't work with the following command, then it's not supported. For example, GitHub Desktop:</p>
<code>open -a GitHub\ Desktop ~/Desktop</code>
</details>
