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

// MARK: - Openable

protocol Openable {
    func openOutsideSandbox() throws
    func openInSandbox(_ paths: [String]) throws
}

extension App: Openable {
    
    func openOutsideSandbox() throws {
        
        func excute(_ source: String) throws {
            guard let script = NSAppleScript(source: source) else {
                throw OITError.cannotCreateAppleScript(source)
            }
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if error != nil {
                throw OITError.cannotAccessApp(self.name)
            }
        }
        
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
                    // open in a new window
                    guard let terminal = SBApplication(bundleIdentifier: SupportedApps.terminal.bundleId) as TerminalApplication?,
                          let open = terminal.open else {
                        throw OITError.cannotAccessApp(self.name)
                    }
                    open([url])
                    terminal.activate()
                case .tab:
                    // open in a new tab
                    let source = ScriptManager.shared.getTerminalNewTabAppleScript(url: url)
                    try excute(source)
                }
            } else {
                // this app is general
                var openCommand = ScriptManager.shared.getOpenCommand(self, escapeCount: 2)
                openCommand += " " + path.specialCharEscaped(2)
                let source = """
                do shell script "\(openCommand)"
                """
                try excute(source)
            }
            
        case .editor:
            // get paths
            var paths = try FinderManager.shared.getFullPathsToFrontFinderWindowOrSelectedFile()
            if paths.count == 0 {
                // No Finder window and no file selected.
                guard let desktopPath = FinderManager.shared.getDesktopPath() else { return }
                paths.append(desktopPath)
            }
            
            var openCommand = ScriptManager.shared.getOpenCommand(self, escapeCount: 2)
            paths.forEach {
                openCommand += " \($0.specialCharEscaped(2))"
            }
            let source = """
            do shell script "\(openCommand))"
            """
            try excute(source)
        }
    }
    
    func openInSandbox(_ paths: [String]) throws {
        switch self.type {
        case .terminal:
            guard var path = paths.first else { return }
            guard let url = URL(string: path) else {
                throw OITError.wrongUrl
            }
            // check the path is directory or not
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
                return
            }
            // if the selected is a file, then delete last path component
            if isDirectory.boolValue == false {
                path = url.deletingLastPathComponent().path
            }
            // get open command, e.g. "open -a Terminal /Users/user/Desktop/test\ folder"
            var openCommand = ScriptManager.shared.getOpenCommand(self)
            openCommand += path.specialCharEscaped()
            // script
            guard var scriptURL = ScriptManager.shared.getScriptURL(with: Constants.generalScript) else { return }
            // handle exceptional case
            if SupportedApps.is(self, is: .terminal) {
                if let newOption = DefaultsManager.shared.getNewOption(.terminal),
                   newOption == .tab {
                    openCommand = ScriptManager.shared.getTerminalNewTabCommand(path: path)
                    guard let tabScriptURL = ScriptManager.shared.getScriptURL(with: Constants.terminalNewTabScript) else { return }
                    scriptURL = tabScriptURL
                }
            }
            // excute
            guard FileManager.default.fileExists(atPath: scriptURL.path) else { return }
            guard let script = try? NSUserAppleScriptTask(url: scriptURL) else { return }
            let event = ScriptManager.shared.getScriptEvent(functionName: "openApp", openCommand)
            script.execute(withAppleEvent: event) { (appleEvent, error) in
                if let error = error {
                    logw("cannot execute applescript: \(error)")
                }
            }
        case .editor:
            // get open command, e.g. "open -a TextEdit /Users/user/Desktop/test\ folder /Users/user/Documents"
            var openCommand = ScriptManager.shared.getOpenCommand(self)
            paths.forEach {
                openCommand += " " + $0.specialCharEscaped()
            }
            // script
            guard let scriptURL = ScriptManager.shared.getScriptURL(with: Constants.generalScript) else { return }
            // excute
            guard FileManager.default.fileExists(atPath: scriptURL.path) else { return }
            guard let script = try? NSUserAppleScriptTask(url: scriptURL) else { return }
            let event = ScriptManager.shared.getScriptEvent(functionName: "openApp", openCommand)
            script.execute(withAppleEvent: event) { (appleEvent, error) in
                if let error = error {
                    logw("cannot execute applescript: \(error)")
                }
            }
        }
    }
    
    
}
