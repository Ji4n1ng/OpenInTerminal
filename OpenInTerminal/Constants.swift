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
    
    static let none = "None"
    static let launcherAppIdentifier = "wang.jianing.app.OpenInTerminalHelper"
    static let finderExtensionIdentifier = "wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension"
    
    struct Key {
        static let defaultTerminalShortcut = "OIT_DefaultTerminalShortcut"
        static let defaultEditorShortcut = "OIT_DefaultEditorShortcut"
        static let copyPathShortcut = "OIT_CopyPathShortcut"
    }
    
    /// .terminal, .iTerm, .hyper, .alacritty
    static let allTerminals: [TerminalType] = [.terminal, .iTerm, .hyper, .alacritty]
    /// .vscode, .atom, .sublime, .vscodium, .bbedit, .vscodeInsiders, .textMate, .cotEditor, .macVim
    static let allEditors: [EditorType] = [.vscode, .atom, .sublime, .vscodium, .bbedit, .vscodeInsiders, .textMate, .cotEditor, .macVim]
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
