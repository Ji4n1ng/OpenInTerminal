//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/17.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Finder {
        static let id = "com.apple.Finder"
    }
    
    struct Key {
        static let firstUsage = "OIT_FirstUsage"
        static let launchAtLogin = "OIT_LaunchAtLogin"
        static let quickToggle = "OIT_QuickToggle"
        static let quickToggleType = "OIT_QuickToggleType"
        
        static let defaultTerminal = "OIT_TerminalBundleIdentifier"
        static let defaultEditor = "OIT_EditorBundleIdentifier"
        
        static let terminalNewOption = "OIT_TerminalNewOption"
        static let iTermNewOption = "OIT_iTermNewOption"
        
        static let terminalClearOption = "OIT_TerminalClearOption"
        static let iTermClearOption = "OIT_iTermClearOption"
        
        static let copyPathToClipboardVisible = "OIT_CopyPathToClipboardVisible"
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

public enum VisibleType: String {
    case visible
    case invisible
}

public enum ClearOptionType: String {
    case clear
    case noClear
}

public enum BoolType: String {
    case _true
    case _false
    
    public var bool: Bool {
        get {
            return self == ._true
        }
        
        set {
            self = newValue ? ._true : ._false
        }
    }
}
