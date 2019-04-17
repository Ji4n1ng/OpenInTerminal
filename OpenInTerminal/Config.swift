//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/17.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

struct Config {
    
    struct Key {
        static let terminalBundleIdentifier = "OIT_TerminalBundleIdentifier"
        static let clear = "OIT_Clear"
    }
    
    struct Finder {
        static let id = "com.apple.Finder"
    }
    
    static var userPreferredTerminal: TerminalType? {
        return UserDefaults.standard
            .string(forKey: Config.Key.terminalBundleIdentifier)
            .map(TerminalType.init(rawValue: )) ?? nil
    }
    
    static var needClear: Bool? {
        return UserDefaults.standard
            .bool(forKey: Config.Key.clear)
    }
    
}


enum TerminalType: String {
    
    case terminal = "com.apple.Terminal"
    case iTerm = "com.googlecode.iterm2"
    case hyper = "co.zeit.hyper"
    
    var name: String {
        switch self {
        case .terminal:
            return "Terminal"
        case .iTerm:
            return "iTerm2"
        case .hyper:
            return "Hyper"
        }
    }
    
    func instance() -> Terminal {
        switch self {
        case .terminal:
            return TerminalApp()
        case .iTerm:
            return iTermApp()
        case .hyper:
            return HyperApp()
        }
    }
    
}
