//
//  TerminalType.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum TerminalType: String {
    
    case terminal = "Terminal"
    case iTerm = "iTerm"
    case hyper = "Hyper"
    case alacritty = "Alacritty"
    case kitty = "kitty"
    
    public var bundleId: String {
        switch self {
        case .terminal:
            return "com.apple.Terminal"
        case .iTerm:
            return "com.googlecode.iterm2"
        case .hyper:
            return "co.zeit.hyper"
        case .alacritty:
            return "io.alacritty"
        case .kitty:
            return "net.kovidgoyal.kitty"
        }
    }
    
    public var fullName: String {
        return self.rawValue
    }
    
    public func instance() -> Terminal {
        switch self {
        case .terminal:
            return TerminalApp()
        case .iTerm:
            return iTermApp()
        case .hyper:
            return HyperApp()
        case .alacritty:
            return AlacrittyApp()
        case .kitty:
            return kittyApp()
        }
    }
    
}

public extension TerminalType {
    
    init?(by fullName: String) {
        switch fullName {
        case "Terminal":
            self = .terminal
        case "iTerm":
            self = .iTerm
        case "Hyper":
            self = .hyper
        case "Alacritty":
            self = .alacritty
        case "kitty":
            self = .kitty
        default:
            return nil
        }
    }
    
}

extension TerminalType: Scriptable {
    
    public func getScript() -> String {
        var openScript = ""
        switch self {
        case .alacritty:
            openScript = """
            do shell script "open -na Alacritty --args --working-directory " & quoted form of thePath
            """
        case .kitty:
            openScript = """
            do shell script "open -na kitty --args --directory " & quoted form of thePath
            """
        default:
            let escapedName = self.rawValue.nameSpaceEscaped
            openScript = """
            do shell script "open -a \(escapedName) " & quoted form of thePath
            """
        }
        let script = """
        tell application "Finder"
            set finderSelList to selection as alias list
            
            if finderSelList ≠ {} then
                set theSelected to item 1 of finderSelList
                set thePath to POSIX path of (contents of theSelected)
                try
                    do shell script "cd " & quoted form of thePath
                on error
                    set thePath to POSIX path of ((container of theSelected) as text)
                end try
            end if
            
            if finderSelList = {} then
                tell application "Finder"
                    try
                        set thePath to POSIX path of ((target of front Finder window) as text)
                    on error
                        set thePath to POSIX path of (path to desktop)
                    end try
                end tell
            end if
        end tell
        \(openScript)
        """
        return script
    }
    
}
