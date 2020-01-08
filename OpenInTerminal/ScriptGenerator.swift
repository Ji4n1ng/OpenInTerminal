//
//  ScriptGenerator.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/10/15.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import OpenInTerminalCore

/// Install AppleScripts to $HOME/Library/Application Scripts/wang.jianing.app.OpenInTerminalFinderExtension
func checkScripts() throws {
    guard var scriptFolderPath = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
        throw OITMError.cannotAccessPath("$HOME/Library/Application Scripts/wang.jianing.app.OpenInTerminal")
    }
    scriptFolderPath.deleteLastPathComponent()
    let finderExScriptPath = scriptFolderPath.appendingPathComponent(Constants.finderExtensionIdentifier)
    if !FileManager.default.fileExists(atPath: finderExScriptPath.path) {
        try FileManager.default.createDirectory(atPath: finderExScriptPath.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }
    
    func writeScriptIfNeeded(at path: URL, with script: String) throws {
        if FileManager.default.fileExists(atPath: path.path) {
            return
        }
        try script.write(to: path, atomically: true, encoding: String.Encoding.utf8)
    }
    
    // write terminal scripts
    let terminals: [TerminalType] = Constants.allTerminals
    try terminals.forEach { terminal in
        let scriptPath = finderExScriptPath
            .appendingPathComponent(terminal.rawValue)
            .appendingPathExtension("scpt")
        try writeScriptIfNeeded(at: scriptPath, with: terminal.getScript())
    }
    
    // write editor scripts
    let editors: [EditorType] = Constants.allEditors
    try editors.forEach { editor in
        let scriptPath = finderExScriptPath
            .appendingPathComponent(editor.rawValue)
            .appendingPathExtension("scpt")
        try writeScriptIfNeeded(at: scriptPath, with: editor.getScript())
    }
    
    // write terminal new tab script
    let terminalTabScriptPath = finderExScriptPath
        .appendingPathComponent(TerminalType.terminal.rawValue + "-tab")
        .appendingPathExtension("scpt")
    let terminalTabScript = """
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

    if not application "Terminal" is running then
        tell application "Terminal"
            do script "cd " & quoted form of thePath
            activate
        end tell
    else
        tell application "Terminal"
            if not (exists window 1) then
                do script "cd " & quoted form of thePath
                activate
            else
                activate
                tell application "System Events" to keystroke "t" using command down
                repeat while contents of selected tab of window 1 starts with linefeed
                    delay 0.01
                end repeat
                do script "cd " & quoted form of thePath in window 1
            end if
        end tell
    end if
    """
    try writeScriptIfNeeded(at: terminalTabScriptPath, with: terminalTabScript)
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
