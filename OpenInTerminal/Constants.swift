//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/20.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import Foundation
import OpenInTerminalCore

struct Constants {
    
    struct Id {
        static let LauncherApp = "wang.jianing.app.OpenInTerminalHelper"
        static let FinderExtension = "wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension"
        static let CustomAppCell = NSUserInterfaceItemIdentifier(rawValue: "customAppCell")
        static let CustomMenuCell = NSUserInterfaceItemIdentifier(rawValue: "customMenuCell")
        static let CustomInputViewController = "CustomInputViewController"
    }
    
    static let none = "None"
    
    struct Key {
        static let defaultTerminalShortcut = "OIT_DefaultTerminalShortcut"
        static let defaultEditorShortcut = "OIT_DefaultEditorShortcut"
        static let copyPathShortcut = "OIT_CopyPathShortcut"
    }
    
//    static let allTerminals: [SupportedApps] = [.terminal, .iTerm, .hyper, .alacritty, .kitty]
//    static let allEditors: [SupportedApps] = [.textEdit, .vscode, .atom, .sublime, .vscodium, .bbedit, .vscodeInsiders, .textMate, .cotEditor, .macVim, .appCode, .cLion, .goLand, .intelliJIDEA, .phpStorm, .pyCharm, .rubyMine, .webStorm]
    static let PreferencesStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
}

extension NSImage {
    
    enum AssetIdentifier: String {
        case StatusBarIcon
    }
    
    convenience init(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)!
    }
}

extension NSStoryboard {
    
    enum StoryboardIdentifier: String {
        case Preferences
    }
    
    convenience init(storyboardIdentifier: StoryboardIdentifier) {
        self.init(name: storyboardIdentifier.rawValue, bundle: nil)
    }
}
