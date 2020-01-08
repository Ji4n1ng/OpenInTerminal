//
//  EditorType.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum EditorType: String {
    
    case vscode = "VSCode"
    case atom = "Atom"
    case sublime = "Sublime"
    case vscodium = "VSCodium"
    case bbedit = "BBEdit"
    case vscodeInsiders = "VSCodeInsiders"
    case textMate = "TextMate"
    case cotEditor = "CotEditor"
    case macVim = "MacVim"
    
    public var fullName: String {
        switch self {
        case .vscode:
            return "Visual Studio Code"
        case .atom:
            return "Atom"
        case .sublime:
            return "Sublime Text"
        case .vscodium:
            return "VSCodium"
        case .bbedit:
            return "BBEdit"
        case .vscodeInsiders:
            return "Visual Studio Code - Insiders"
        case .textMate:
            return "TextMate"
        case .cotEditor:
            return "CotEditor"
        case .macVim:
            return "MacVim"
        }
    }
    
    public var bundleId: String {
        switch self {
        case .vscode:
            return "com.microsoft.VSCode"
        case .atom:
            return "com.github.atom"
        case .sublime:
            return "com.sublimetext.3"
        case .vscodium:
            return "com.visualstudio.code.oss"
        case .bbedit:
            return "com.barebones.bbedit"
        case .vscodeInsiders:
            return "com.microsoft.VSCodeInsiders"
        case .textMate:
            return "com.macromates.TextMate"
        case .cotEditor:
            return ""
        case .macVim:
            return ""
        }
    }
    
    public func instance() -> Editor {
        switch self {
        case .vscode:
            return VSCodeApp()
        case .atom:
            return AtomApp()
        case .sublime:
            return SublimeApp()
        case .vscodium:
            return VSCodiumApp()
        case .bbedit:
            return BBEditApp()
        case .vscodeInsiders:
            return VSCodeInsidersApp()
        case .textMate:
            return TextMateApp()
        case .cotEditor:
            return CotEditorApp()
        case .macVim:
            return MacVimApp()
        }
    }
}

extension EditorType: Scriptable {
    
    public func getScript() -> String {
        let escapedName = self.fullName.nameSpaceEscaped
        
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
            do shell script "open -a \(escapedName) " & quoted form of thePath
        end tell
        """
        
        return script
    }
    
}

extension String {
    
    /// handle space in name
    var nameSpaceEscaped: String {
        let replaced = self.replacingOccurrences(of: " ", with: "\\\\ ")
        return replaced
    }
}
