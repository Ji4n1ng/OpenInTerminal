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
    
    
    // MARK: - Deprecated Functions
    
    /// **[Deprecated]** This script can run independently without additional parameters.
    @available(*, deprecated, message: "Use getGeneralScript()")
    func getAppleScript(app: App) -> String {
        switch app.type {
        case .terminal:
            let openCommand = DefaultsManager.shared.getOpenCommand(app, escapeCount: 2)
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
            let openCommand = DefaultsManager.shared.getOpenCommand(app, escapeCount: 2)
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
}

