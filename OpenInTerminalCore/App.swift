//
//  App.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/12/5.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import AppKit
import Foundation
import ScriptingBridge

public enum AppType: String, Codable {
    case terminal
    case editor
}

public struct App: Codable {
    public var name: String
    public var path: String?
    public var bundleId: String?
    public var type: AppType
    
    public init(name: String, type: AppType) {
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

public protocol Openable {
    func openOutsideSandbox() throws
    func openInSandbox(_ urls: [URL]) throws
}

extension App: Openable {
    
    public func openOutsideSandbox() throws {

        // Launch the `open` command directly, passing each path as a discrete
        // argument. This avoids building a shell command string or an AppleScript
        // source string from an untrusted path, which was exploitable for both
        // AppleScript injection and shell command injection via crafted folder
        // names. See the security advisory (Findings 1 & 2).
        //
        // `argv` is the full invocation: the program first, then its arguments.
        func run(_ argv: [String]) throws {
            guard let program = argv.first else { return }
            let process = Process()
            process.executableURL = URL(fileURLWithPath: program)
            process.arguments = Array(argv.dropFirst())
            logw(argv.joined(separator: " "))
            do {
                try process.run()
            } catch {
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
                let url = URL(fileURLWithPath: path)
                guard let terminal = SBApplication(bundleIdentifier: SupportedApps.terminal.bundleId) as TerminalApplication?,
                      let open = terminal.open else {
                    throw OITError.cannotAccessApp(self.name)
                }
                open([url])
                terminal.activate()
            } else if wantsCmuxNewWindow, let arguments = App.cmuxNewWindowArguments(path: path) {
                // cmux with the "new window" preference: drive the cmux CLI
                try run(arguments)
            } else {
                // this app is general (e.g. iTerm, Alacritty, kitty)
                var arguments = ["/usr/bin/open"] + DefaultsManager.shared.getOpenArguments(self)
                arguments.append(path)
                try run(arguments)
            }

        case .editor:
            // get paths
            var paths = try FinderManager.shared.getFullPathsToFrontFinderWindowOrSelectedFile()
            if paths.count == 0 {
                // No Finder window and no file selected.
                guard let desktopPath = FinderManager.shared.getDesktopPath() else { return }
                paths.append(desktopPath)
            }

            var arguments = ["/usr/bin/open"] + DefaultsManager.shared.getOpenArguments(self)
            // fix for neovim: the command template carries a "PATH" placeholder
            // token that must be replaced by the actual path arguments.
            if SupportedApps.is(self, is: .neovim) {
                arguments = arguments.flatMap { $0 == "PATH" ? paths : [$0] }
            } else {
                arguments.append(contentsOf: paths)
            }
            try run(arguments)
        }
    }
    
    public func openInSandbox(_ urls: [URL]) throws {
        // Build the invocation as a list of discrete arguments — the leading
        // program, the app-specific option tokens (trusted config from
        // getOpenArguments), then the raw target paths as individual elements.
        // The installed AppleScript shell-quotes every element via
        // `quoted form of`, so nothing here is manually escaped and a crafted
        // file/folder name cannot inject shell commands. This mirrors the
        // argument-array approach used by openOutsideSandbox.
        var arguments = ["/usr/bin/open"]
        arguments.append(contentsOf: DefaultsManager.shared.getOpenArguments(self))

        switch self.type {
        case .terminal:
            guard var url = urls.first else { return }
            url.getDirectory()
            if wantsCmuxNewWindow, let cmuxArguments = App.cmuxNewWindowArguments(path: url.path) {
                // cmux with the "new window" preference: drive the cmux CLI
                // instead of `open -a cmux`. Same argv discipline applies.
                arguments = cmuxArguments
            } else {
                arguments.append(url.path)
            }
        case .editor:
            let paths = urls.map { $0.path }
            // fix for neovim: the command template carries a "PATH" placeholder
            // token that must be replaced by the actual path arguments.
            if SupportedApps.is(self, is: .neovim) {
                arguments = arguments.flatMap { $0 == "PATH" ? paths : [$0] }
            } else {
                arguments.append(contentsOf: paths)
            }
        }

        // script
        guard let scriptURL = ScriptManager.shared.getScriptURL(with: Constants.generalScript) else { return }
        // excute
        guard FileManager.default.fileExists(atPath: scriptURL.path) else { return }
        guard let script = try? NSUserAppleScriptTask(url: scriptURL) else { return }
        let event = ScriptManager.shared.getScriptEvent(functionName: "openApp", arguments: arguments)
        script.execute(withAppleEvent: event) { (appleEvent, error) in
            if let error = error {
                logw("cannot execute applescript: \(error)")
            }
        }
    }
    
    // MARK: - cmux
    
    /// True when this app is cmux and the user asked for folders to open in a
    /// new cmux window rather than a new workspace (tab) of the current window.
    var wantsCmuxNewWindow: Bool {
        return SupportedApps.is(self, is: .cmux)
            && DefaultsManager.shared.getNewOption(.cmux) == .window
    }
    
    /// The full argv (program first) that opens `path` in a new cmux window via
    /// the cmux CLI bundled inside cmux.app, or `nil` when that CLI cannot be
    /// found — callers then fall back to the regular `open -a cmux` path.
    ///
    /// The script text is a fixed constant; `path` is handed over as a discrete
    /// positional argument, so it is never interpreted by the shell.
    static func cmuxNewWindowArguments(path: String) -> [String]? {
        var appURLs: [URL] = []
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: SupportedApps.cmux.bundleId) {
            appURLs.append(url)
        }
        appURLs.append(URL(fileURLWithPath: "/Applications/cmux.app"))
        for appURL in appURLs {
            let cli = appURL.appendingPathComponent("Contents/Resources/bin/cmux")
            if FileManager.default.isExecutableFile(atPath: cli.path) {
                return ["/bin/sh", "-c", Constants.Commands.cmuxNewWindow, "openinterminal-cmux", cli.path, path]
            }
        }
        logw("cmux CLI not found; falling back to open -a")
        return nil
    }
    
}

