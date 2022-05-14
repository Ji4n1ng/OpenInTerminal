<p align="center">
  <img width="100%" src="https://user-images.githubusercontent.com/11001224/104892184-d522b280-59ac-11eb-9c06-5ffd044dce7d.png"><br/><br/>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/releases/tag/v1.2.5"><img src="https://img.shields.io/badge/Version-1.2.5-blue.svg"></a>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg"></a>
  <img src="https://img.shields.io/badge/Made With-Swift-red.svg">
  <a href="https://travis-ci.org/Ji4n1ng/OpenInTerminal"><img src="https://img.shields.io/travis/Ji4n1ng/OpenInTerminal.svg"></a>
</p>

[English](./README-Lite.md) | [中文说明](./README-Lite-zh.md) | Deutsch

## Verwendung 🚀

### 1) Aktuelles Verzeichnis im Terminal (oder Editor) öffnen

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78589363-b23a6e00-7872-11ea-841d-79227b1125ce.gif" width="600px">
</div>

### 2) Ausgewählten Ordner oder Datei im Terminal (oder Editor) öffnen

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78589359-afd81400-7872-11ea-8032-8035d4412b19.gif" width="600px">
</div>

### 3) Öffne die Auswahl in X (z.B. Github Desktop)

<div>
  <img src="https://user-images.githubusercontent.com/11001224/104891620-28483580-59ac-11eb-9fb5-3e4dec7863cc.gif" width="600px">
</div>

## Installation 🖥

### Homebrew

1. Führen Sie den folgenden Befehl aus

```
brew install --cask openinterminal-lite
# oder
brew install --cask openineditor-lite
```

2. Im `/Programme` Ordner, halten Sie die `command ⌘` Taste gedrückt und ziehen Sie das Programm in die Finder Symbolleiste.

>  ⚠️ macOS fragt Sie nach Ihrer Berechtigung für den Zugriff auf den Finder und andere Anwendungen, wenn Sie die App zum ersten Mal ausführen. Bitte geben Sie OpenInTerminal diese Berechtigungen.

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590414-67215a80-7874-11ea-97a1-fb8996db6984.gif" width="600px">
</div>

### Manuell

1. Herunterladen von [release](https://github.com/Ji4n1ng/OpenInTerminal/releases).
2. Bewegen Sie das Programm in `/Programme`.
3. Halten Sie die `⌘ command` Taste gedrückt und ziehen Sie das Programm in die Finder Symbolleiste.

## Unterstützung ❤️

Danke für Ihre Unterstützung!

| PayPal | AliPay | WeChat Pay |
| --- | --- | --- |
| [paypal.me/ji4ning](https://www.paypal.me/ji4ning) | <img src="./Support-Alipay.jpg" width="50%"> | <img src="./Support-WeChatPay.jpg" width="50%"> |

## Einstellungen 🔨

### 1) Standard-Terminal (oder Editor) einstellen

Sie werden aufgefordert, das Standardterminal (oder den Editor) festzulegen, das/der nach dem ersten Start geöffnet werden soll.

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78600459-8b396780-7885-11ea-8226-2fe45e539134.png" width="45%">
  <img src="https://user-images.githubusercontent.com/11001224/78600438-88d70d80-7885-11ea-9bcb-d70fcaaf7334.png" width="45%">
</div>

Das Auswahlfeld wird nicht mehr angezeigt, wenn Sie das Standardterminal eingestellt haben. Wenn Sie das Standard-Terminal zurücksetzen möchten, geben Sie bitte den folgenden Befehl in das Terminal ein. Führen Sie die Anwendung dann einfach erneut aus.

```
# Für OpenInTerminal-Lite:
defaults remove wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal
# Für OpenInEditor-Lite:
defaults remove wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor
```

Legen Sie die folgende Anwendung als Standardanwendung zum Öffnen fest:

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
| AppCode | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor AppCode` |
| CLion | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor CLion` |
| GoLand | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor GoLand` |
| IntelliJ IDEA | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor IntelliJ\ IDEA` |
| PhpStorm | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor PhpStorm` |
| PyCharm | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor PyCharm` |
| RubyMine | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor RubyMine` |
| WebStorm | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor WebStorm` |
| Android Studio | `defaults write wang.jianing.app.OpenInEditor-Lite LiteDefaultEditor Android\ Studio` |

Insbesondere wenn Sie eine benutzerdefinierte Anwendung als Standardanwendung verwenden möchten, können Sie diesen Befehl ebenfalls verwenden. Nehmen Sie `GitHub Desktop` als Beispiel.

```
defaults write wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal GitHub\ Desktop
```

### 2) Wenn Sie den Dunkelmodus verwenden

Ich habe mehrere Icons zusammen mit der App auf der [release Seite](https://github.com/Ji4n1ng/OpenInTerminal/releases) bereitgestellt.

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78600452-8aa0d100-7885-11ea-8a90-cc88b9233dac.png" width="600px">
</div>

#### a. Manuelle Änderung des Symbols

Klicken Sie mit der rechten Maustaste auf die Anwendung und wählen Sie `Informationen`. Ziehen Sie das neue Symbol über das alte.

<div>
  <img src="https://user-images.githubusercontent.com/11001224/78590421-68eb1e00-7874-11ea-91e3-61cfd5ba3a26.gif" width="600px">
</div>

#### b. Automatisches Ändern des Symbols mit [Hammerspoon](https://www.hammerspoon.org)

Dieses Verfahren ist besonders nützlich für diejenigen, die den automatischen Wechsel zwischen Hell- und Dunkelmodus von macOS nutzen.

1. Installieren Sie Hammerspoon indem Sie entweder [den neuesten Release herunterladen](https://github.com/Hammerspoon/hammerspoon/releases/latest) und es in den `/Programme` Ordner ziehen, oder mithilfe von Homebrew:
```
brew install --cask hammerspoon
```

2. Installieren Sie das [fileicon](https://github.com/mklement0/fileicon) Hilfsprogramm um das Anwendungssymbol programmatisch zu ändern:
```
brew install fileicon
```

3. Erstellen Sie den `~/.hammerspoon/Icons` Ordner und verschieben Sie die Symbole dahon

4. Erstellen Sie die `~/.hammerspoon/init.lua` Datei (falls sie nicht schon existiert) und fügen den folgenden Code ein:
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

Jetzt können Sie die Konfigurationsdatei neu laden (oder hammerspoon neu starten) und fertig! Die Icons sollten sich automatisch aktualisieren, wenn Sie vom hellen in den Dunkelmodus wechseln und andersherum. Vergessen Sie nicht, die Option "Launch Hammerspoon at login" zu aktivieren.

### 3) In einem neuen Tab oder Fenster öffnen, wenn Sie iTerm verwenden

Wenn Sie `iTerm`verwenden, können Sie festlegen, dass standardmäßig eine neue Registerkarte oder ein neues Fenster geöffnet wird. Die **Standardeinstellung** ist ein neues Fenster zu öffnen. 

```
# Einen neuen Tab öffnen
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false
# Ein neues Fenster öffnen
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool true
```

## FAQ ❓

<details><summary>1. Ich habe versehentlich auf <code>Nicht erlauben</code> geklickt.</summary><br>
<p>Sie können den folgenden Befehl in einem Terminal ausführen. Dadurch werden die Berechtigungen in den Systemeinstellungen zurückgesetzt.</p>
<pre><code># Für OpenInTerminal-Lite:
tccutil reset AppleEvents wang.jianing.app.OpenInTerminal-Lite
# Für OpenInEditor-Lite:
tccutil reset AppleEvents wang.jianing.app.OpenInEditor-Lite
</code></pre>
</details>

<details><summary>2. Sonderzeichen im <code>Pfad</code>.</summary><br>
<p>Bitte verwenden Sie keine Backslashes <code>\</code> oder doppelte Anführungszeichen <code>"</code> in dem Pfad.</p>
</details>

<details><summary>3. Warum können die Symbole beim Wechsel vom/zum dunklen Modus nicht automatisch gewechselt werden?</summary><br>
<p>Was <code>OpenInTerminal-Lite</code> betrifft, so ist das Symbol in der Finder-Symbolleiste das Symbol der Anwendung und nicht das Symbol der Finder-Erweiterung. Und ich habe keine API gefunden um das Programmsymbol zu ändern (Wenn Sie eine gute Idee haben, lassen Sie es mich bitte wissen).  
<p>Hinzugefügt: Dank des Beitrags (#126) von @MatteoCarnelos kann <code>OpenInTerminal-Lite</code> nun automatisch Icons mit Hammerspoon wechseln.</p><br>
Was <code>OpenInTerminal</code> betrifft, so ist das Symbol in der Finder-Symbolleiste das Symbol der Finder-Erweiterung. Es kann sich automatisch ändern, wenn Sie zwischen dunklem und hellem Modus wechseln. Sie können also versuchen, OpenInTerminal zu verwenden.</p>
</details>

<details><summary>4. Mein benutzerdefiniertes Programm funktioniert nicht.</summary><br>
<p>Wenn Ihre benutzerdefinierte Anwendung nicht mit dem folgenden Befehl funktioniert, kann die Anwendung nicht unterstützt werden. Zum Beispiel, GitHub Desktop:</p>
<code>open -a GitHub\ Desktop ~/Desktop</code>
</details>

## Changes 🗒

<details><summary>Alle anzeigen</summary><br>
<p><strong>Version 1.2.4</strong></p>
<ul>
<li>Unterstützung von Türkisch</li>
</ul>
<p><strong>Version 1.2.3</strong></p>
<ul>
<li>Fehlerbehebung: Pfad mit Leerzeichen kann nicht geöffnet werden, wenn Terminal verwendet wird</li>
</ul>
<p><strong>Version 1.2.2</strong></p>
<ul>
<li>Fehlerbehebung: kann nicht alacritty öffnen</li>
<li>Fehlerbehebung: kann nicht den Standard-Editor einstellen</li>
</ul>
<p><strong>Version 1.2.1</strong></p>
<ul>
<li>Fehlerbehebung: kann nicht alacritty öffnen</li>
<li>Fehlerbehebung: kann nicht den Standard-Editor einstellen</li>
</ul>
<p><strong>Version 1.2.0</strong></p>
<ul>
<li>Öffnen von benutzerdefinierten Programmen. (Nicht alle werden unterstützt)</li>
<li>Symbol im Big Sur Stil</li>
</ul>
<p><strong>Version 1.1.5</strong></p>
<ul>
<li>Fehler in OpenInEditor-Lite behoben</li>
</ul>
<p><strong>Version 1.1.4</strong></p>
<ul>
<li>Unterstützung von kitty</li>
<li>Öffnen mehrerer ausgewählter Dateien in Editoren</li>
</ul>
<p><strong>Version 1.1.3</strong></p>
<ul>
<li>Unterstützung von Italienisch und Spanisch</li>
</ul>
<p><strong>Version 1.1.2</strong></p>
<ul>
<li>Unterstützung von JetBrains</li>
</ul>
<p><strong>Version 1.1.1</strong></p>
<ul>
<li>Unterstützung von Russisch und Koreanisch</li>
<li>Unterstützung von PhpStorm</li>
</ul>
<p><strong>Version 1.1.0</strong></p>
<ul>
<li>Unterstützung von CotEditor und MacVim</li>
</ul>
<p><strong>Version 1.0.3</strong></p>
<ul>
<li>Programm wurde mit dem Entwicklerkonto signiert. Bundle ID hat sich geändert</li>
<li>Unterstützung von Koreanisch</li>
</ul>
<p><strong>Version 1.0.2</strong></p>
<ul>
<li>Unterstützung von TextMate</li>
<li>OpenInEditor-Lite Standardsymbol geändert</li>
</ul>
<p><strong>Version 1.0.1</strong></p>
<ul>
<li>Unterstützung von Visual Studio Code - Insiders</li>
</ul>
<p><strong>Version 1.0.0</strong></p>
<ul>
<li>Unterstützung von BBEdit</li>
<li>Fehlerbehebung: Anwendungsordner im Home-Verzeichnis prüfen</li>
</ul>
<p><strong>Version 0.4.4</strong></p>
<ul>
<li>iTerm hinterlässt nicht mehr `cd xxx` im Verlauf</li>
<li>Fehlerbehebung: Symbol blinkt nicht im Dock</li>
</ul>
<p><strong>Version 0.4.3</strong></p>
<ul>
<li>Lokalisierungsfehler behoben</li>
</ul>
<p><strong>Version 0.4.2</strong></p>
<ul>
<li>Unterstützung von Französisch</li>
</ul>
<p><strong>Version 0.4.1</strong></p>
<ul>
<li>Unterstützung von Alacritty</li>
</ul>
<p><strong>Version 0.4.0</strong></p>
<ul>
<li>Sie können festlegen, dass ein neuer Tab oder ein neues Fenster geöffnet wird, wenn Sie Terminal und Hyper verwenden.</li>
</ul>
<p><strong>Version 0.3.0</strong></p>
<ul>
<li>Name zu <code>OpenInTerminal-Lite</code> geändert. (<code>OpenInTerminal</code> wird in Zukunft in einer leistungsfähigeren Version erscheinen.)</li>
<li>Behebung eines Fehlers, bei dem einige Sonderzeichen im Pfad zum Absturz des Programms beim Öffnen von Hyper führten.</li>
</ul>
<p><strong>Version 0.2.0</strong></p>
<ul>
<li>Terminalauswahl hinzugefügt</li>
<li>Abbrechen des Befehls <code>clear</code> beim Öffnen von iTerm</li>
</ul>
<p><strong>Version 0.1.1</strong></p>
<ul>
<li>Unterstützung von <code>Hyper</code></li>
<li>Beim Öffnen von iTerm der Erstellung eines neuen Tabs Priorität einräumen</li>
</ul>
<p><strong>Version 0.1.0</strong></p>
<ul>
<li>Erste Veröffentlichung</li>
</ul>
<br>
</details>

## Besonderen Dank an ❤️

### Mitwirkende

- [Camji55](https://github.com/Camji55)
- [gucheen](https://github.com/gucheen)
- [uclort](https://github.com/uclort)
- [MatteoCarnelos](https://github.com/MatteoCarnelos)

### Übersetzer

- [Dorian Eydoux](https://github.com/dorianeydx)
- [techinpark](https://github.com/techinpark)
- [Egor](https://github.com/Rogue85)
- [arendruni](https://github.com/arendruni)
- [panta97](https://github.com/panta97)
- [bkzspam](https://github.com/bkzspam)

### Referenzprojekte

- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)
