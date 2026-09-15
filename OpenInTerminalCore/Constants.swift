//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/17.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import Security

struct Constants {
    
    /// Identifier
    struct Id {
        /// The app group name as registered with Apple, without a team prefix.
        static let BaseGroup = "group.wang.jianing.app.OpenInTerminal"

        /// The app group identifier actually used for the shared `UserDefaults`
        /// suite and the group container.
        ///
        /// On macOS an app group identifier must be prefixed with the Team ID
        /// for any process that is **not** sandboxed. The main OpenInTerminal
        /// app is unsandboxed (it has to launch arbitrary terminals), so the
        /// bare `group.` form is not a domain it owns: since macOS 26 `cfprefsd`
        /// silently drops every write to it. The settings therefore never
        /// reached the sandboxed Finder extension, which read an empty suite,
        /// found no default terminal and built an empty menu — clicking the
        /// toolbar item did nothing.
        ///
        /// Both targets declare `$(TeamIdentifierPrefix)group.…` in their
        /// entitlements; this resolves the same string at runtime from the
        /// running code's own signature. Falls back to the bare name for
        /// ad-hoc/unsigned local builds, which have no team to prefix with.
        static let Group: String = {
            guard let team = teamIdentifier() else { return BaseGroup }
            return "\(team).\(BaseGroup)"
        }()

        /// The Team ID of the certificate this bundle is signed with, if any.
        private static func teamIdentifier() -> String? {
            var code: SecCode?
            guard SecCodeCopySelf([], &code) == errSecSuccess, let code else { return nil }
            var staticCode: SecStaticCode?
            guard SecCodeCopyStaticCode(code, [], &staticCode) == errSecSuccess,
                  let staticCode else { return nil }
            var info: CFDictionary?
            guard SecCodeCopySigningInformation(staticCode,
                                                SecCSFlags(rawValue: kSecCSSigningInformation),
                                                &info) == errSecSuccess,
                  let dict = info as? [String: Any] else { return nil }
            return dict[kSecCodeInfoTeamIdentifier as String] as? String
        }

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
