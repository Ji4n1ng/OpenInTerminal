# OpenInTerminal Configurations

## Installing Unsigned Apps

On first launch, macOS may refuse to open the app — for example `"OpenInTerminal" is damaged and can't be opened`, or `cannot be opened because Apple cannot check it for malicious software`.

1. Move the app (`OpenInTerminal.app`, `OpenInTerminal-Lite.app` or `OpenInEditor-Lite.app`) into `/Applications`.

2. Remove the quarantine flag macOS attaches to downloaded or copied apps (repeat for each app, changing the name):

   ```
   xattr -dr com.apple.quarantine /Applications/OpenInTerminal.app
   ```

   This step matters: besides clearing the "damaged" warning, it stops macOS from running the app from a random read-only location (*App Translocation*), which would otherwise prevent the Finder extension from registering.

3. Launch the app.

Prefer not to use the command line? Control-click (right-click) the app in Finder, choose `Open`, and confirm in the dialog. On macOS 15 (Sequoia) or later, open `System Settings` -> `Privacy & Security`, scroll to the **Security** section, and click `Open Anyway` after the first blocked launch.

## Finder Extension Configuration

To enable Finder Extension, right click on Finder toolbar, select `Customize Toolbar...` as shown below:

<div>
  <img src="https://github.com/user-attachments/assets/c834f0d1-2f9d-4200-984c-3f6330eaeb2d" width="400px">
</div>

Then drag the `OpenInTerminal` icon to the toolbar:

<div>
  <img src="https://github.com/user-attachments/assets/261eb747-27f0-4484-9654-40cab8a52008" width="400px">
</div>

### Finder Extension Not Showing Up in System Settings on macOS 15 and later

#### 1) Enable the Finder Extension in Settings (Tahoe)

Go to `System Settings` -> `General` -> `Login Items & Extensions` -> `OpenInTerminal Extensions`, and enable `File Provider`.

#### 2) Manually Enable the Finder Extension (macOS 15)

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

#### 3) Use FinderSyncer

Alternatively, you could use a GUI tool called [FinderSyncer](https://zigz.ag/FinderSyncer/) to enable the extension.

### Checking Finder Extension Permissions on macOS 14 and Earlier

For macOS 14 and earlier, ensure the Finder Extension is enabled via System Preferences:

1. Open the OpenInTerminal app.
2. Navigate to `System Preferences` -> `Extensions` -> `Finder Extensions`.
3. Check the checkbox next to `OpenInTerminalFinderExtension`, as shown below:

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590336-448f4180-7874-11ea-827c-ad3a7bffca5e.png" width="400px">
</div>

## Where Preferences Are Saved

The full app saves preferences in its own `wang.jianing.app.OpenInTerminal`
UserDefaults domain. On its first launch after updating, it copies the old settings
from the legacy App Group container once, without deleting them or overwriting
settings already saved in the new domain. On macOS 15 and later, macOS can ask
whether OpenInTerminal may access data from other apps. Allow it to keep your old
settings. If the old installation could not save settings, choose your terminal and
editor again after updating.

The host publishes Finder preferences as `shared-settings.plist` in
`~/Library/Application Scripts/wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension/`.
The Finder extension reads that snapshot whenever it builds a menu. This uses the
same directory as its existing AppleScripts and works with ad-hoc signing; an App
Group provisioning profile or Full Disk Access is not required. Launch the host
once after installation to publish preferences and install its scripts.

To run the preference regression checks:

```sh
Tests/SharedPreferences/run.sh
```

## Custom Configuration

### For Obsidian Users

When Obsidian is the frontmost app, OpenInTerminal can open terminals in the directory of the active note and editors with the active note file. This applies to the keyboard shortcuts and the menu bar menu. The Finder toolbar and the Finder context menu still use the Finder selection.

This requires Obsidian's official command-line tool, which is bundled with recent Obsidian desktop releases. Turn it on in Obsidian under **Settings → General → Command line interface**.

OpenInTerminal checks the following paths:

```
/Applications/Obsidian.app/Contents/MacOS/obsidian-cli
/opt/homebrew/bin/obsidian
/usr/local/bin/obsidian
```

If the Obsidian CLI is unavailable, does not answer within 2 seconds, or cannot resolve the active file, OpenInTerminal falls back to the normal Finder-based behavior.

### For Neovim Users

If you select Neovim as your editor in OpenInTerminal, the app will use Kitty as the default terminal. To switch to a different terminal (supported options: Alacritty, WezTerm, and Kitty), update the configuration with the following command. Adjust the Neovim path (`/opt/homebrew/bin/nvim` in this example) to match your installation, then quit and reopen OpenInTerminal so the Finder extension receives the change:

```
defaults write wang.jianing.app.OpenInTerminal NeovimCommand "open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
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

If you want to customize this behavior, you can run the following command in your terminal. Adjust the open command as you want, then quit and reopen OpenInTerminal so the Finder extension receives the change:

```
defaults write wang.jianing.app.OpenInTerminal KittyCommand "open -na kitty --args --single-instance --instance-group 1 --directory"
```

## FAQ ❓

<details><summary>Oops, hit <code>Don't Allow</code> button by mistake.</summary><br>
<p>No sweat! Just run the following command in your terminal, and it'll reset the permissions in System Preferences.</p>
<br><code>tccutil reset AppleEvents wang.jianing.app.OpenInTerminal</code><br>
<p>If no prompt appears after the reset, see the next question.</p>
</details>

<details><summary>Nothing happens, and no prompt asks to control Finder.</summary><br>
<p>Opening a terminal or editor from the menu bar or with a global shortcut does nothing. macOS never shows the prompt that says “OpenInTerminal” wants access to control “Finder”. OpenInTerminal is not listed in System Settings > Privacy & Security > Automation, and <code>tccutil reset AppleEvents wang.jianing.app.OpenInTerminal</code> does not help. The log <code>~/Library/Logs/OpenInTerminal/OpenInTerminal-0.log</code> shows <code>Cannot access Finder, please check permissions.</code></p>
<p>This happens when System Integrity Protection (SIP) is disabled and the boot-arg <code>amfi_get_out_of_my_way=1</code> is set. With AMFI off, macOS does not show this prompt for apps that Apple did not sign. It denies the access instead. This affects all such apps that control other apps; it is not a bug in OpenInTerminal.</p>
<p>To check, run these commands. This is the cause if SIP is <code>disabled</code> and boot-args contains <code>amfi_get_out_of_my_way=1</code>.</p>
<pre><code>csrutil status
nvram boot-args</code></pre>
<p>The system log also shows it (use the full path, because <code>log</code> is a zsh builtin). Look for <code>Policy disallows prompt for wang.jianing.app.OpenInTerminal</code>.</p>
<pre><code>/usr/bin/log show --last 5m --predicate 'process == "tccd" AND eventMessage CONTAINS "Policy disallows"'</code></pre>
<p>To fix it, remove the boot-arg and restart your Mac. This command removes all boot-args. If you need other boot-args, set them again without <code>amfi_get_out_of_my_way=1</code>.</p>
<pre><code>sudo nvram -d boot-args</code></pre>
<p>After the restart, open a Finder window, use OpenInTerminal again, and click <code>Allow</code> (or <code>OK</code>) in the prompt.</p>
<p>If you must keep AMFI off, there is no supported fix. Apps that got the permission before you set the boot-arg keep it, so they still work.</p>
</details>

<details><summary>Special characters in the <code>path</code>.</summary><br>
<p>Please do not use backslash <code>\</code> and double quotes <code>"</code> in the path.</p>
</details>

<details><summary>Open two Terminal windows on Mojave</summary><br>
<p>This problem usually occurs when you first start Terminal. Try using <code>⌘W</code> to close Terminal window, instead of using <code>⌘Q</code> to quit Terminal.</p>
</details>

<details><summary>OpenInTerminal doesn't work as I expected</summary><br>
<p>OpenInTerminal works as the following order:</p>
<ul>
<li>1. Open the file or folder you selected.</li>
<li>2. If nothing's selected, it opens the top Finder window.</li>
<li>3. If there's no Finder window, it opens the desktop.</li>
</ul>
</details>

<details><summary>My custom app doesn't work.</summary><br>
<p>If your custom application doesn't work with the following command, then it's not supported. For example, GitHub Desktop:</p>
<code>open -a GitHub\ Desktop ~/Desktop</code>
</details>
