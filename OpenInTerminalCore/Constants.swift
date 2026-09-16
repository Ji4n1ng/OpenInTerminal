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
        /// Historical app group name, without a Team ID prefix.
        static let BaseGroup = "group.wang.jianing.app.OpenInTerminal"

        /// Shared suite used by the unsandboxed host and the sandboxed Finder extension.
        ///
        /// Unsandboxed macOS processes only own an app group when the identifier is
        /// prefixed with the Team ID. The bare `group.` form is silently dropped by
        /// cfprefsd starting with macOS 26, so settings never reached the extension
        /// and the toolbar menu was built empty. Both entitlements declare
        /// `$(TeamIdentifierPrefix)` + BaseGroup; this resolves the same string from
        /// the running code's signature. Ad-hoc builds have no team and fall back to
        /// the bare name.
        static let Group: String = {
            guard let team = teamIdentifier() else { return BaseGroup }
            return "\(team).\(BaseGroup)"
        }()

        /// Team ID of the certificate this bundle is signed with, if any.
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
