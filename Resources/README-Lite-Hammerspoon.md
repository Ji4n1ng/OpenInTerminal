<p align="center">
  <img width="100%" src="https://user-images.githubusercontent.com/11001224/78588756-bf0a9200-7871-11ea-9aba-b00284c07c21.png"><br/><br/>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/releases/tag/1.1.2"><img src="https://img.shields.io/badge/Version-1.1.2-blue.svg"></a>
  <a href="https://github.com/Ji4n1ng/OpenInTerminal/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg"></a>
  <img src="https://img.shields.io/badge/Made With-Swift-red.svg">
  <a href="https://travis-ci.org/Ji4n1ng/OpenInTerminal"><img src="https://img.shields.io/travis/Ji4n1ng/OpenInTerminal.svg"></a>
</p>

## Automating dark/light icon switching with Hammerspoon

### 1) Install Hammerspoon

```
brew cask install hammerspoon
```

### 2) Install `darkmode` spoon

```shell
mkdir -p ~/.hammerspoon/Spoons
cd ~/.hammerspoon/Spoons
git clone git@github.com:malob/DarkMode.spoon.git
```

### 3) Download pre-converted macOS icons

Put icons to the folder `~/.hammerspoon/icons`.

### 4) Add this snippet to Hammerspoon config

```lua
-- Set OpenInEditor-Lite Finder icon
local function setOpenInEditorLiteIcon(isDarkMode)
  -- Path to the app
  local app = "/Applications/OpenInEditor-Lite.app"
  -- Path to icons
  local iconsFolder = hs.fs.currentDir() .. "/icons"
  -- Remove existing attribute and icon
  pcall(hs.fs.xattr.remove, app, "com.apple.FinderInfo")
  os.remove(app .. "/Icon\r")
  -- Swap icon
  if isDarkMode then
    hs.execute('cp "' .. iconsFolder .. '/vscode_dark" "' .. app .. '/Icon\r"' )
    hs.execute('xattr -wx com.apple.FinderInfo "0000000000000000040000000000000000000000000000000000000000000000" "'
      .. app .. '"')
  else
    hs.execute('cp "' .. iconsFolder .. '/vscode_light" "' .. app .. '/Icon\r"' )
    hs.execute('xattr -wx com.apple.FinderInfo "0000000000000000040000000000000000000000000000000000000000000000" "'
      .. app .. '"')
  end
end

-- Set OpenInTerminal-Lite Finder icon
local function setOpenInTerminalLiteIcon(isDarkMode)
  -- Path to the app
  local app = "/Applications/OpenInTerminal-Lite.app"
  -- Path to icons
  local iconsFolder = hs.fs.currentDir() .. "/icons"
  -- Remove existing attribute and icon
  pcall(hs.fs.xattr.remove, app, "com.apple.FinderInfo")
  os.remove(app .. "/Icon\r")
  -- Swap icon
  if isDarkMode then
    hs.execute('cp "' .. iconsFolder .. '/iterm_dark" "' .. app .. '/Icon\r"' )
    hs.execute('xattr -wx com.apple.FinderInfo "0000000000000000040000000000000000000000000000000000000000000000" "'
      .. app .. '"')
  else
    hs.execute('cp "' .. iconsFolder .. '/iterm_white" "' .. app .. '/Icon\r"' )
    hs.execute('xattr -wx com.apple.FinderInfo "0000000000000000040000000000000000000000000000000000000000000000" "'
      .. app .. '"')
  end
end

-- Load DarkMode spoon
hs.loadSpoon("DarkMode")
spoon.DarkMode.callbackFn = function(isDarkMode)
end
spoon.DarkMode:setSchedule("18:00:00", "06:00:00")
spoon.DarkMode:start()
```
