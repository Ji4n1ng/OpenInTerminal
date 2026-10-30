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
        func runOpen(_ arguments: [String]) throws {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = arguments
            logw("open " + arguments.joined(separator: " "))
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
            } else if SupportedApps.is(self, is: .herdr) {
                try openInHerdr(path)
            } else {
                // this app is general (e.g. iTerm, Alacritty, kitty)
                var arguments = DefaultsManager.shared.getOpenArguments(self)
                arguments.append(path)
                try runOpen(arguments)
            }

        case .editor:
            // get paths
            var paths = try FinderManager.shared.getFullPathsToFrontFinderWindowOrSelectedFile()
            if paths.count == 0 {
                // No Finder window and no file selected.
                guard let desktopPath = FinderManager.shared.getDesktopPath() else { return }
                paths.append(desktopPath)
            }

            var arguments = DefaultsManager.shared.getOpenArguments(self)
            // fix for neovim: the command template carries a "PATH" placeholder
            // token that must be replaced by the actual path arguments.
            if SupportedApps.is(self, is: .neovim) {
                arguments = arguments.flatMap { $0 == "PATH" ? paths : [$0] }
            } else {
                arguments.append(contentsOf: paths)
            }
            try runOpen(arguments)
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
            if SupportedApps.is(self, is: .herdr) {
                guard let herdr = App.herdrExecutableURL else {
                    throw OITError.cannotAccessApp(self.name)
                }
                arguments = [herdr.path] + App.herdrOpenArguments(url.path)
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

        // Herdr's CLI needs an open Herdr window: if Herdr isn't running yet,
        // launch it first and retry while its window starts.
        if SupportedApps.is(self, is: .herdr) && !App.isHerdrRunning {
            let launch = ScriptManager.shared.getScriptEvent(
                functionName: "openApp",
                arguments: ["/usr/bin/open", "-b", SupportedApps.herdr.bundleId])
            script.execute(withAppleEvent: launch) { (_, _) in
                App.executeScript(at: scriptURL, event: event, retries: App.herdrLaunchRetries)
            }
            return
        }
        App.executeScript(at: scriptURL, event: event, retries: 0)
    }

    /// Runs the installed script, retrying after a short delay on failure.
    static func executeScript(at scriptURL: URL, event: NSAppleEventDescriptor, retries: Int) {
        guard let script = try? NSUserAppleScriptTask(url: scriptURL) else { return }
        script.execute(withAppleEvent: event) { (appleEvent, error) in
            guard let error = error else { return }
            if retries > 0 {
                DispatchQueue.global().asyncAfter(deadline: .now() + App.herdrRetryInterval) {
                    executeScript(at: scriptURL, event: event, retries: retries - 1)
                }
            } else {
                logw("cannot execute applescript: \(error)")
            }
        }
    }

}

// MARK: - Herdr

/// Herdr has no URL scheme and doesn't open folders as documents. Its app
/// binary doubles as its CLI (`Herdr do space.new --folder <path>`), which talks
/// to an open Herdr window, so the window has to be up first.
extension App {

    static let herdrRetryInterval: TimeInterval = 0.25
    static let herdrLaunchRetries = 40  // ~10 s for Herdr to open its window

    static var herdrExecutableURL: URL? {
        guard let appURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: SupportedApps.herdr.bundleId) else { return nil }
        return Bundle(url: appURL)?.executableURL
    }

    static var isHerdrRunning: Bool {
        return NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == SupportedApps.herdr.bundleId
        }
    }

    /// Arguments for a new Herdr space at `path`; the path stays one argument.
    static func herdrOpenArguments(_ path: String) -> [String] {
        return ["do", "space.new", "--folder", path]
    }

    func openInHerdr(_ path: String) throws {
        guard let herdr = App.herdrExecutableURL else {
            throw OITError.cannotAccessApp(self.name)
        }

        func run(_ executable: URL, _ arguments: [String]) -> Int32 {
            let process = Process()
            process.executableURL = executable
            process.arguments = arguments
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            logw(executable.path + " " + arguments.joined(separator: " "))
            do {
                try process.run()
            } catch {
                return -1
            }
            process.waitUntilExit()
            return process.terminationStatus
        }

        let arguments = App.herdrOpenArguments(path)
        if run(herdr, arguments) != 0 {
            // No Herdr window yet: launch Herdr and retry while it starts.
            _ = run(URL(fileURLWithPath: "/usr/bin/open"), ["-b", SupportedApps.herdr.bundleId])
            var opened = false
            for _ in 0..<App.herdrLaunchRetries {
                Thread.sleep(forTimeInterval: App.herdrRetryInterval)
                if run(herdr, arguments) == 0 {
                    opened = true
                    break
                }
            }
            guard opened else { throw OITError.cannotAccessApp(self.name) }
        }

        NSWorkspace.shared.runningApplications
            .first { $0.bundleIdentifier == SupportedApps.herdr.bundleId }?
            .activate(options: .activateIgnoringOtherApps)
    }
}

