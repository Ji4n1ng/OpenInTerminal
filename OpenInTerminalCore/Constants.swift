//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/17.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

struct Constants {
    
    /// Identifier
    struct Id {
        static let Group = "group.wang.jianing.app.OpenInTerminal"
        static let OpenInTerminalLite = "wang.jianing.app.OpenInTerminal-Lite"
        static let OpenInEditorLite = "wang.jianing.app.OpenInEditor-Lite"
        static let Finder = "com.apple.Finder"
    }
    
    /// General AppleScript for opening apps
    static let generalScript = "generalScript"
    /// AppleScript for opening a new tab in Terminal
    static let terminalNewTabScript = "terminalNewTabScript"
    
    struct Commands {
        static let alacritty = "open -na Alacritty --args --working-directory"
        static let kitty = "open -na kitty --args --single-instance --instance-group 1 --directory"
        static let wezterm = "open -na wezterm --args start --cwd"
        static let tabby = "open -na tabby --args --directory"
        /// "Open In NeoVim" only supports Alacritty, wezterm, and kitty.
        static let neovim = "open -na kitty --args /opt/homebrew/bin/nvim PATH"
//        static let neovim = "open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
//        static let neovim = "open -na Alacritty --args -e /opt/homebrew/bin/nvim PATH"
        static let gitkraken = "open -na GitKraken --args --path"
        /// Opens a directory in a *new* cmux window through the cmux CLI.
        ///
        /// Executed as `/bin/sh -c <script> <argv0> <cmux-cli-path> <directory>`.
        /// The directory is only ever read from the positional parameter `$2`
        /// and is never interpolated into the script text, so a crafted folder
        /// name cannot inject shell commands. Steps: create a window, add a
        /// workspace at the directory, close the blank workspace the window was
        /// created with. When cmux is not running (no control socket) the plain
        /// `cmux <directory>` form launches it, which already yields a new window.
        static let cmuxNewWindow = """
        export CMUX_QUIET=1
        cli="$1"
        dir="$2"
        if "$cli" ping >/dev/null 2>&1; then
            wid=$("$cli" new-window 2>/dev/null | awk '$1 == "OK" { print $2; exit }')
            if [ -n "$wid" ]; then
                initial=$("$cli" list-workspaces --window "$wid" --json 2>/dev/null | sed -n 's/^[[:space:]]*"id"[[:space:]]*:[[:space:]]*"\\([^"]*\\)".*/\\1/p' | head -n 1)
                if "$cli" new-workspace --cwd "$dir" --window "$wid" --focus true >/dev/null 2>&1; then
                    if [ -n "$initial" ]; then
                        "$cli" close-workspace --workspace "$initial" --window "$wid" >/dev/null 2>&1
                    fi
                    exit 0
                fi
            fi
        fi
        exec "$cli" "$dir"
        """
    }
    
}

public enum QuickToggleType: String {
    
    case openWithDefaultTerminal
    case openWithDefaultEditor
    case copyPathToClipboard
    
    public var name: String {
        switch self {
        case .openWithDefaultTerminal:
        return NSLocalizedString("menu.open_with_default_terminal", comment: "Open with default Terminal")
        case .openWithDefaultEditor:
        return NSLocalizedString("menu.open_with_default_editor", comment: "Open with default Editor")
        case .copyPathToClipboard:
        return NSLocalizedString("menu.copy_path_to_clipboard", comment: "Copy path to Clipboard")
        }
    }
}

public enum NewOptionType: String {
    case tab
    case window
}

let encoder = JSONEncoder()
let decoder = JSONDecoder()

public enum CustomMenuIconOption: String {
    case no
    case simple
    case original
}
