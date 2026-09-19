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
            try App.run(argv, for: self.name)
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
            } else if let cmuxOption = cmuxCLIOption {
                // cmux with the "new window" / "new tab" preference: drive the cmux CLI
                try App.openCmux(path: path, option: cmuxOption)
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
            if let cmuxOption = cmuxCLIOption,
               let requestURL = App.cmuxRequestURL(path: url.path, option: cmuxOption) {
                // cmux with the "new window" / "new tab" preference. The shell
                // started by the Finder extension's AppleScript is sandboxed: it
                // can neither reach cmux's control socket nor pass arguments
                // through `open`, so hand the request to the unsandboxed main
                // app, which runs the cmux CLI (see AppDelegate.application(_:open:)).
                NSWorkspace.shared.open(requestURL)
                return
            }
            arguments.append(url.path)
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
    
    /// The cmux "new" option that needs the cmux CLI, i.e. `.window` or `.tab`,
    /// when this app is cmux and the user chose one of them. `nil` for other
    /// apps and for the default `.workspace` behaviour, which plain
    /// `open -a cmux <dir>` already provides.
    var cmuxCLIOption: NewOptionType? {
        guard SupportedApps.is(self, is: .cmux),
              let option = DefaultsManager.shared.getNewOption(.cmux),
              option == .window || option == .tab else {
            return nil
        }
        return option
    }
    
    /// Opens `path` in cmux in a new window or a new tab by running the cmux
    /// CLI bundled in cmux.app (see `Constants.Commands.cmuxOpen`). Only works
    /// from an unsandboxed process; the Finder extension goes through
    /// `cmuxRequestURL(path:option:)` instead.
    public static func openCmux(path: String, option: NewOptionType) throws {
        try run(cmuxArguments(path: path, option: option), for: SupportedApps.cmux.name)
    }
    
    /// `openinterminal://cmux/<path>?mode=<window|tab>` — the request the Finder
    /// extension sends to the main app. The path travels in the URL path
    /// component, so `URLComponents` percent-encodes it in full.
    public static func cmuxRequestURL(path: String, option: NewOptionType) -> URL? {
        var components = URLComponents()
        components.scheme = Constants.urlScheme
        components.host = Constants.cmuxURLHost
        components.path = path
        components.queryItems = [URLQueryItem(name: Constants.cmuxURLModeQueryItem, value: option.rawValue)]
        return components.url
    }
    
    /// The directory and option named by a `cmuxRequestURL(path:option:)` URL,
    /// or `nil` when the URL is not such a request, names an unsupported mode,
    /// or does not name an existing directory.
    public static func cmuxRequest(from url: URL) -> (path: String, option: NewOptionType)? {
        guard url.scheme == Constants.urlScheme,
              url.host == Constants.cmuxURLHost,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let mode = components.queryItems?.first(where: { $0.name == Constants.cmuxURLModeQueryItem })?.value,
              let option = NewOptionType(rawValue: mode),
              option == .window || option == .tab else {
            return nil
        }
        let path = components.path
        var isDirectory: ObjCBool = false
        guard !path.isEmpty,
              FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return nil
        }
        return (path, option)
    }
    
    /// The full argv (program first) that opens `path` in cmux with `option`.
    ///
    /// The script text is a fixed constant; the CLI path, the mode and `path`
    /// are handed over as discrete positional arguments, so they are never
    /// interpreted by the shell. The script itself falls back to
    /// `open -b com.cmuxterm.app` when the CLI is not where we expect it.
    static func cmuxArguments(path: String, option: NewOptionType) -> [String] {
        let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: SupportedApps.cmux.bundleId)
            ?? URL(fileURLWithPath: "/Applications/cmux.app")
        let cli = appURL.appendingPathComponent("Contents/Resources/bin/cmux").path
        return ["/bin/sh", "-c", Constants.Commands.cmuxOpen, "openinterminal-cmux", cli, option.rawValue, path]
    }
    
    /// Runs `argv` (program first) as a child process without any shell.
    private static func run(_ argv: [String], for appName: String) throws {
        guard let program = argv.first else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: program)
        process.arguments = Array(argv.dropFirst())
        logw(argv.joined(separator: " "))
        do {
            try process.run()
        } catch {
            throw OITError.cannotAccessApp(appName)
        }
    }
    
}
