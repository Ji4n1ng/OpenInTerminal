//
//  App.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/12/5.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation
import ScriptingBridge

public enum AppType: String, Codable {
    case terminal
    case editor
}

public struct App: Codable {
    var name: String
    var shortName: String?
    var path: String?
    var bundleId: String?
    var type: AppType
    
    init(name: String, type: AppType) {
        self.name = name
        self.type = type
    }
}

extension App: Equatable {
    public static func == (lhs: App, rhs: App) -> Bool {
        return lhs.name == rhs.name && lhs.bundleId == rhs.bundleId
    }
}

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

public extension App {
    
    // MARK: - AppleScript
    
    /// get `open` command
    func getOpenCommand(escapeCount: Int = 1) -> String {
        if SupportedApps.is(self, is: .alacritty) {
            return "open -na Alacritty --args --working-directory"
        } else if SupportedApps.is(self, is: .kitty) {
            return "open -na kitty --args --directory"
        } else {
            return "open -a \(self.name.nameSpaceEscaped(escapeCount))"
        }
    }
    
    /// This script requires parameters to be passed in.
    /// `parameter`: open -a
    static func getAppleScript() -> String {
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
    
    /// **[Deprecated]** This script can run independently without additional parameters.
    func getAppleScript2() -> String {
        switch self.type {
        case .terminal:
            let openCommand = self.getOpenCommand(escapeCount: 2)
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
            let openCommand = self.getOpenCommand(escapeCount: 2)
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
    static func getTerminalNewTabAppleScript() -> String {
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
    
    static func getTerminalNewTabCommand(path: String) -> String {
        let command = "cd \(path.terminalPathEscaped())"
        return command
    }
    
    /// **[Deprecated]** Open path in a new tab of Terminal
    static func getTerminalNewTabAppleScript2() -> String {
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

// MARK: - Openable

protocol Openable {
    func openOutsideSandbox() throws
    func openInSandbox(_ paths: [String]) throws
}

extension App: Openable {
    
    func openOutsideSandbox() throws {
        switch self.type {
        case .terminal:
            // get path
            var path = try FinderManager.shared.getPathToFrontFinderWindowOrSelectedFile()
            if path == "" {
                // No Finder window and no file selected.
                guard let desktopPath = FinderManager.shared.getDesktopPath() else { return }
                path = desktopPath
            }
            
            if SupportedApps.is(self, is: .terminal) {
                // this app is supported: Terminal
                guard let url = URL(string: path) else {
                    throw OITError.wrongUrl
                }
                let newOption = DefaultsManager.shared.getNewOption(.terminal) ?? .window
                switch newOption {
                case .window:
                    let terminal = SBApplication(bundleIdentifier: SupportedApps.terminal.bundleId)! as TerminalApplication
                    guard let open = terminal.open else {
                        throw OITError.cannotAccessApp(SupportedApps.terminal.name)
                    }
                    open([url])
                    terminal.activate()
                case .tab:
                    let command = App.getTerminalNewTabCommand(path: url.path)
                    print(command)
                }
            } else {
                var openCommand = getOpenCommand(escapeCount: 2)
                openCommand += " " + path.specialCharEscaped(2)
                let source = """
                do shell script "\(openCommand)"
                """
                guard let script = NSAppleScript(source: source) else {
                    throw OITError.cannotCreateAppleScript(source)
                }
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                if error != nil {
                    throw OITError.cannotAccessApp(self.name)
                }
            }
            
        case .editor:
            // get path
            var paths = try FinderManager.shared.getFullPathsToFrontFinderWindowOrSelectedFile()
            if paths.count == 0 {
                // No Finder window and no file selected.
                guard let desktopPath = FinderManager.shared.getDesktopPath() else { return }
                paths.append(desktopPath)
            }
            
            var openCommand = getOpenCommand(escapeCount: 2)
            paths.forEach {
                openCommand += " \($0.specialCharEscaped(2))"
            }
            let source = """
            do shell script "\(openCommand))"
            """
            guard let script = NSAppleScript(source: source) else {
                throw OITError.cannotCreateAppleScript(source)
            }
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if error != nil {
                throw OITError.cannotAccessApp(self.name)
            }
        }
    }
    
    func openInSandbox(_ paths: [String]) throws {
        switch self.type {
        case .terminal:
            guard var path = paths.first else { return }
            guard let url = URL(string: path) else {
                throw OITError.wrongUrl
            }
            // the path can only be directory
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
                return
            }
            // if the selected is a file, then delete last path component
            if isDirectory.boolValue == false {
                path = url.deletingLastPathComponent().path
            }
            
            var openCommand = getOpenCommand()
            openCommand += path.specialCharEscaped()
            
            guard let scriptURL = FinderManager.shared.get else { return }
            guard FileManager.default.fileExists(atPath: scriptPath.path) else { return }
            guard let script = try? NSUserAppleScriptTask(url: scriptPath) else { return }
            script.execute(completionHandler: nil)
            // check fileExist
            // if not install it
            // excute
        
        case .editor:
            // path check
            var openCommand = getOpenCommand()
            paths.forEach {
                openCommand += " " + $0.specialCharEscaped()
            }
            print(openCommand)
            // check fileExist
            // if not install it
            // excute
        }
    }
    
    
}
