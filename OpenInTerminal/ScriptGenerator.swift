//
//  ScriptGenerator.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/10/15.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import OpenInTerminalCore

/// Install AppleScripts to $HOME/Library/Application Scripts/wang.jianing.OpenInTerminalFinderExtension
func checkScripts() throws {
    guard var scriptFolderPath = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
        throw OITMError.cannotAccessPath("$HOME/Library/Application Scripts/wang.jianing.OpenInTerminal")
    }
    scriptFolderPath.deleteLastPathComponent()
    let finderExScriptPath = scriptFolderPath.appendingPathComponent(Constants.finderExtensionIdentifier)
    if !FileManager.default.fileExists(atPath: finderExScriptPath.path) {
        try FileManager.default.createDirectory(atPath: finderExScriptPath.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }
    
    let terminals: [TerminalType] = [.terminal, .iTerm, .hyper, .alacritty]
    
    try terminals.forEach { terminal in
        let scriptPath = finderExScriptPath
            .appendingPathComponent(terminal.rawValue)
            .appendingPathExtension("scpt")
        
        if FileManager.default.fileExists(atPath: scriptPath.path) {
            return
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
                do shell script "open -a \(terminal.rawValue) " & quoted form of thePath
            on error
                set cwd to POSIX path of ((target of front Finder window) as text)
                do shell script "open -a \(terminal.rawValue) " & quoted form of cwd
            end try
        end tell
        """
        
        try script.write(to: scriptPath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    let editors: [EditorType] = [.vscode, .atom, .sublime, .vscodium, .bbedit, .vscodeInsiders, .textMate]
    
    try editors.forEach { editor in
        let scriptPath = finderExScriptPath
            .appendingPathComponent(editor.rawValue)
            .appendingPathExtension("scpt")
        
        if FileManager.default.fileExists(atPath: scriptPath.path) {
            return
        }
        
        let escapedName = editor.fullName.escaped
        
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
        
        try script.write(to: scriptPath, atomically: true, encoding: String.Encoding.utf8)
    }
}

fileprivate extension String {
    
    var escaped: String {
        
        var result = ""
        let set: [Character] = [" "]
        
        for char in self {
            if set.contains(char) {
                result += "\\\\"
            }
            result.append(char)
        }
        
        return result
    }
}
