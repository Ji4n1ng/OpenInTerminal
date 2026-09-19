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
    
    /// URL scheme handled by the main OpenInTerminal app. The sandboxed Finder
    /// extension uses it to hand requests to the (unsandboxed) main app.
    static let urlScheme = "openinterminal"
    /// `openinterminal://cmux/<directory>?mode=window|tab`: open the directory
    /// in cmux in a new window or a new tab.
    static let cmuxURLHost = "cmux"
    static let cmuxURLModeQueryItem = "mode"
    
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
        /// Opens a directory in cmux in a *new window* or a *new tab* through the
        /// cmux CLI bundled in cmux.app.
        ///
        /// Executed as `/bin/sh -c <script> <argv0> <cmux-cli-path> <mode> <directory>`
        /// where `<mode>` is `window` or `tab`. The directory is only ever read
        /// from the positional parameter `$3` and is never interpolated into the
        /// script text, so a crafted folder name cannot inject shell commands.
        ///
        /// window: create a window, add a workspace at the directory, close the
        /// blank workspace the window was created with.
        /// tab: add a terminal tab (surface) at the directory to the active
        /// workspace of the active window.
        /// If anything fails (the CLI is missing, or cmux is not running so
        /// there is no control socket) fall back to opening the directory with
        /// cmux directly, which launches cmux or adds a workspace to the current
        /// window (the "workspace" behaviour).
        ///
        /// This must run from an unsandboxed process (the main app or the Lite
        /// apps): the Finder extension's `do shell script` shell cannot reach
        /// cmux's control socket, so the extension hands the request to the main
        /// app via `openinterminal://cmux/<directory>?mode=<mode>` instead.
        static let cmuxOpen = """
        cli="$1"
        mode="$2"
        dir="$3"
        export CMUX_QUIET=1
        if [ -x "$cli" ]; then
            case "$mode" in
                window)
                    wid=$("$cli" new-window 2>/dev/null | awk '$1 == "OK" { print $2; exit }')
                    if [ -n "$wid" ]; then
                        initial=$("$cli" list-workspaces --window "$wid" --json 2>/dev/null | sed -n 's/^[[:space:]]*"id"[[:space:]]*:[[:space:]]*"\\([^"]*\\)".*/\\1/p' | head -n 1)
                        created=$("$cli" new-workspace --cwd "$dir" --window "$wid" --focus true 2>/dev/null | awk '$1 == "OK" { print $2; exit }')
                        if [ -n "$created" ]; then
                            if [ -n "$initial" ]; then
                                "$cli" close-workspace --workspace "$initial" --window "$wid" >/dev/null 2>&1
                            fi
                            exit 0
                        fi
                    fi
                    ;;
                tab)
                    created=$("$cli" new-surface --type terminal --working-directory "$dir" --focus true 2>/dev/null | awk '$1 == "OK" { print $2; exit }')
                    if [ -n "$created" ]; then
                        exit 0
                    fi
                    ;;
            esac
        fi
        exec /usr/bin/open -b com.cmuxterm.app "$dir"
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
    /// cmux only: a new workspace in the current window.
    case workspace
}

let encoder = JSONEncoder()
let decoder = JSONDecoder()

public enum CustomMenuIconOption: String {
    case no
    case simple
    case original
}
