//
//  EditorType.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum EditorType: String {
    
    case textEdit = "TextEdit"
    case vscode = "VSCode"
    case atom = "Atom"
    case sublime = "Sublime"
    case vscodium = "VSCodium"
    case bbedit = "BBEdit"
    case vscodeInsiders = "VSCodeInsiders"
    case textMate = "TextMate"
    case cotEditor = "CotEditor"
    case macVim = "MacVim"
    
    // JetBrains
    case appCode = "AppCode"
    case cLion = "CLion"
    case goLand = "GoLand"
    case intelliJIDEA = "IntelliJ_IDEA"
    case phpStorm = "PhpStorm"
    case pyCharm = "PyCharm"
    case rubyMine = "RubyMine"
    case webStorm = "WebStorm"
    
    public var fullName: String {
        switch self {
        case .textEdit:
            return "TextEdit"
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
            
        case .appCode:
            return "AppCode"
        case .cLion:
            return "CLion"
        case .goLand:
            return "GoLand"
        case .intelliJIDEA:
            return "IntelliJ IDEA"
        case .phpStorm:
            return "PhpStorm"
        case .pyCharm:
            return "PyCharm"
        case .rubyMine:
            return "RubyMine"
        case .webStorm:
            return "WebStorm"
        }
    }
    
    public var bundleId: String {
        switch self {
        case .textEdit:
            return "com.apple.TextEdit"
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
        
        case .appCode:
            return "com.jetbrains.appcode"
        case .cLion:
            return "com.jetbrains.clion"
        case .goLand:
            return "com.jetbrains.goland"
        case .intelliJIDEA:
            return "com.jetbrains.intellij"
        case .phpStorm:
            return "com.jetbrains.PhpStorm"
        case .pyCharm:
            return "com.jetbrains.pycharm"
        case .rubyMine:
            return "com.jetbrains.rubymine"
        case .webStorm:
            return "com.jetbrains.webstorm"
        }
    }
    
    public func instance() -> Editor {
        switch self {
        case .textEdit:
            return TextEditApp()
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
        
        case .appCode:
            return AppCodeApp()
        case .cLion:
            return CLionApp()
        case .goLand:
            return GoLandApp()
        case .intelliJIDEA:
            return InterlliJIDEAApp()
        case .phpStorm:
            return PhpStormApp()
        case .pyCharm:
            return PyCharmApp()
        case .rubyMine:
            return RubyMineApp()
        case .webStorm:
            return WebStormApp()
        }
    }
}

public extension EditorType {
    
    init?(by fullName: String) {
        switch fullName {
        case "TextEdit":
            self = .textEdit
        case "Visual Studio Code":
            self = .vscode
        case "Atom":
            self = .atom
        case "Sublime Text":
            self = .sublime
        case "VSCodium":
            self = .vscodium
        case "BBEdit":
            self = .bbedit
        case "Visual Studio Code - Insiders":
            self = .vscodeInsiders
        case "TextMate":
            self = .textMate
        case "CotEditor":
            self = .cotEditor
        case "MacVim":
            self = .macVim
        
        case "AppCode":
            self = .appCode
        case "CLion":
            self = .cLion
        case "GoLand":
            self = .goLand
        case "IntelliJ IDEA":
            self = .intelliJIDEA
        case "PhpStorm":
            self = .phpStorm
        case "PyCharm":
            self = .pyCharm
        case "RubyMine":
            self = .rubyMine
        case "WebStorm":
            self = .webStorm
        default:
            return nil
        }
    }
    
}

extension EditorType: Scriptable {
    
    public func getScript() -> String {
        let escapedName = self.fullName.nameSpaceEscaped
        
        let script = """
        tell application "Finder"
            set finderSelList to selection as alias list
            
            if finderSelList ≠ {} then
                set theSelected to item 1 of finderSelList
                set thePath to POSIX path of (contents of theSelected)
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

        do shell script "open -a \(escapedName) " & quoted form of thePath
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
