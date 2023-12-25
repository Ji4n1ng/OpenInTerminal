//
//  ScriptManager.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/12/7.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation
import Carbon

public class ScriptManager {
    
    public static var shared = ScriptManager()
    
    // MARK: - Get AppleScript
    
    /// get `open` command
    public func getOpenCommand(_ app: App, escapeCount: Int = 1) -> String {
        if SupportedApps.is(app, is: .alacritty) {
            return "open -na Alacritty --args --working-directory"
        } else if SupportedApps.is(app, is: .kitty) {
            return "open -na kitty --args --single-instance --instance-group 1 --directory"
        } else if SupportedApps.is(app, is: .wezterm) {
            return "open -na wezterm --args start --cwd"
        } else if SupportedApps.is(app, is: .tabby) {
            return "open -na tabby --args --directory"
        } else {
            return "open -a \(app.name.nameSpaceEscaped(escapeCount))"
        }
    }
    
    /// This script requires parameters to be passed in.
    /// `parameter`: open -a
    public func getGeneralScript() -> String {
        let script = """
        on openApp(command)
            tell application "Finder"
                activate
                do shell script command
            end tell
        end openApp
        """
        return script
    }
    
    public func getGeneralScriptName() -> String {
        return Constants.generalScript
    }
    
    /// **[Deprecated]** This script can run independently without additional parameters.
    @available(*, deprecated, message: "Use getGeneralScript()")
    func getAppleScript(app: App) -> String {
        switch app.type {
        case .terminal:
            let openCommand = self.getOpenCommand(app, escapeCount: 2)
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

            do shell script "\(openCommand) " & quoted form of thePath
            """
            return script
        case .editor:
            let openCommand = self.getOpenCommand(app, escapeCount: 2)
            let script = """
            tell application "Finder"
                set pathList to {}
                
                set finderSelList to selection as alias list
                
                if finderSelList = {} then
                    tell application "Finder"
                        try
                            set thePath to POSIX path of ((target of front Finder window) as text)
                        on error
                            set thePath to POSIX path of (path to desktop)
                        end try
                        set end of pathList to thePath
                    end tell
                end if
                
                if finderSelList ≠ {} then
                    repeat with theSelected in finderSelList
                        set thePath to POSIX path of (contents of theSelected)
                        set end of pathList to thePath
                    end repeat
                end if
                
            end tell

            set scriptStr to "\(openCommand)"

            repeat with thePath in pathList
                set scriptStr to scriptStr & " " & quoted form of thePath
            end repeat

            do shell script scriptStr
            """
            return script
        }
    }
    
    /// Open path in a new tab of Terminal
    public func getTerminalNewTabAppleScript() -> String {
        let script = """
        on openApp(command)
            if not application "Terminal" is running then
                tell application "Terminal"
                    do script command
                    activate
                end tell
            else
                tell application "Terminal"
                    if not (exists window 1) then
                        do script command
                        activate
                    else
                        activate
                        tell application "System Events" to keystroke "t" using command down
                        repeat while contents of selected tab of window 1 starts with linefeed
                            delay 0.01
                        end repeat
                        do script command in window 1
                    end if
                end tell
            end if
        end openApp
        """
        return script
    }
    
    public func getTerminalNewTabScriptName() -> String {
        return Constants.terminalNewTabScript
    }
    
    public func getTerminalNewTabCommand(path: String) -> String {
        let command = "cd \(path.terminalPathEscaped())"
        return command
    }
    
    /// Open path in a new tab of Terminal
    public func getTerminalNewTabAppleScript(url: URL) -> String {
        let script = """
        if not application "Terminal" is running then
            tell application "Terminal"
                do script "cd \(url.path.terminalPathEscaped())"
                activate
            end tell
        else
            tell application "Terminal"
                if not (exists window 1) then
                    do script "cd \(url.path.terminalPathEscaped())"
                    activate
                else
                    activate
                    tell application "System Events" to keystroke "t" using command down
                    repeat while contents of selected tab of window 1 starts with linefeed
                        delay 0.01
                    end repeat
                    do script "cd \(url.path.terminalPathEscaped())" in window 1
                end if
            end tell
        end if
        """
        return script
    }
    
    /// **[Deprecated]** Open path in a new tab of Terminal
    func getTerminalNewTabAppleScript2() -> String {
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
        return script
    }
    
    
    
    // MARK: - Utils
    
    public func getScriptURL(with name: String) -> URL? {
        let scriptFolderURL = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let url = scriptFolderURL else { return nil }
        let fileURL = url
            .appendingPathComponent(name)
            .appendingPathExtension("scpt")
        return fileURL
    }
    
    func getScriptEvent(functionName: String, _ parameter: String) -> NSAppleEventDescriptor {
        let parameters = NSAppleEventDescriptor.list()
        parameters.insert(NSAppleEventDescriptor(string: parameter), at: 0)

        let event = NSAppleEventDescriptor(
            eventClass: AEEventClass(kASAppleScriptSuite),
            eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        event.setDescriptor(NSAppleEventDescriptor(string: functionName), forKeyword: AEKeyword(keyASSubroutineName))
        event.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))
        return event
    }
}

// MARK: - Escape

extension String {
    
    /// Handle space in name.
    /// `count`: number of escape characters.
    func nameSpaceEscaped(_ count: Int = 1) -> String {
        let escapeChar = String(repeating: "\\", count: count)
        let escapeSpace = escapeChar + " "
        let replaced = self.replacingOccurrences(of: " ", with: escapeSpace)
        return replaced
    }
    
    /// Handle special char in path.
    /// `count`: number of escape characters.
    func specialCharEscaped(_ count: Int = 1) -> String {
        let escapeChar = String(repeating: "\\", count: count)
        var result = ""
        let set: [Character] = [" ", "(", ")", "&", "|", ";",
                                "\"", "'", "<", ">", "`"]
        for char in self {
            if set.contains(char) {
                result += escapeChar
            }
            result.append(char)
        }
        return result
    }
    
    // FIXME: if path contains "\" or """, application will crash.
    // Special symbols have been tested, except for backslashes and double quotes.
    func terminalPathEscaped() -> String {
        var result = ""
        let set = CharacterSet.alphanumerics
        for char in self.unicodeScalars {
            if set.contains(char) || char == "/" {
                result.unicodeScalars.append(char)
            } else {
                result += "\\\\"
                result.unicodeScalars.append(char)
            }
        }
        return result
    }
}
