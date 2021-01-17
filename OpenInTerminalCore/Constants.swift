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
