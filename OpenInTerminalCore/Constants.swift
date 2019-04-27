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
        static let quickOpen = "OIT_QuickOpen"
        
        static let defaultTerminal = "OIT_TerminalBundleIdentifier"
        static let defaultEditor = "OIT_EditorBundleIdentifier"
        
        static let terminalNewOption = "OIT_TerminalNewOption"
        static let iTermNewOption = "OIT_iTermNewOption"
        
        static let terminalClearOption = "OIT_TerminalClearOption"
        static let iTermClearOption = "OIT_iTermClearOption"
        
        static let copyPathToClipboardVisible = "OIT_CopyPathToClipboardVisible"
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
}
