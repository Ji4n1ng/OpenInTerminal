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
        }
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
        default:
            let escapedName = self.rawValue.nameSpaceEscaped
            openScript = """
            do shell script "open -a \(escapedName) " & quoted form of thePath
            """
        }
        let script = """
        tell application "Finder"
            set finderSelList to selection as alias list
        end tell

        set thePath to ""

        if finderSelList ≠ {} then
            repeat with i in finderSelList
                set contents of i to POSIX path of (contents of i)
            end repeat
            
            set thePath to item 1 of finderSelList
        end if

        if finderSelList = {} then
            tell application "Finder"
                set thePath to POSIX path of ((target of front Finder window) as text)
            end tell
        end if

        tell application "Finder"
            try
                do shell script "cd " & quoted form of thePath
            on error
                try
                    set thePath to POSIX path of ((target of front Finder window) as text)
                    do shell script "cd " & quoted form of thePath
                on error
                    set thePath to POSIX path of (path to desktop)
                end try
            end try
        end tell

        \(openScript)
        """
        return script
    }
    
}
