//
//  FinderManager.swift
//  OpenInTerminalCore
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Cameron Ingham. All rights reserved.
//

import Cocoa
import ScriptingBridge

public class FinderManager {
    
    public static var shared = FinderManager()

    public func getFrontmostObsidianFileUrl() -> URL? {
        guard NSWorkspace.shared.frontmostApplication?.bundleIdentifier == SupportedApps.obsidian.bundleId else {
            return nil
        }

        guard let vaultPath = getFrontmostObsidianVaultPath(),
              let activeFilePath = getFrontmostObsidianActiveFilePath() else {
            return nil
        }

        let activeFileUrl = URL(fileURLWithPath: vaultPath).appendingPathComponent(activeFilePath)
        guard FileManager.default.fileExists(atPath: activeFileUrl.path) else {
            return nil
        }

        return activeFileUrl
    }

    public func getFrontmostObsidianDirectoryPath() -> String? {
        guard let activeFileUrl = getFrontmostObsidianFileUrl() else { return nil }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: activeFileUrl.path, isDirectory: &isDirectory) else {
            return nil
        }

        if isDirectory.boolValue {
            return activeFileUrl.path
        }

        return activeFileUrl.deletingLastPathComponent().path
    }

    private func getFrontmostObsidianVaultPath() -> String? {
        let obsidianConfigUrl = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("obsidian")
            .appendingPathComponent("obsidian.json")

        guard let data = try? Data(contentsOf: obsidianConfigUrl),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let vaults = json["vaults"] as? [String: [String: Any]] else {
            return nil
        }

        func timestamp(_ vault: [String: Any]) -> Double {
            if let doubleValue = vault["ts"] as? Double {
                return doubleValue
            }
            if let intValue = vault["ts"] as? Int {
                return Double(intValue)
            }
            return 0
        }

        let openVault = vaults.values.filter { vault in
            vault["open"] as? Bool == true
        }.max { left, right in
            timestamp(left) < timestamp(right)
        }
        let latestVault = vaults.values.max { left, right in
            timestamp(left) < timestamp(right)
        }

        guard let path = (openVault ?? latestVault)?["path"] as? String else {
            return nil
        }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return nil
        }

        return path
    }

    private func getFrontmostObsidianActiveFilePath() -> String? {
        for cliUrl in obsidianCliUrls {
            guard FileManager.default.isExecutableFile(atPath: cliUrl.path),
                  let output = runObsidianCli(cliUrl) else {
                continue
            }

            for line in output.components(separatedBy: .newlines) {
                let columns = line.split(separator: "\t", maxSplits: 1, omittingEmptySubsequences: false)
                guard columns.count == 2,
                      columns[0] == "path" else {
                    continue
                }

                let path = String(columns[1])
                guard !path.isEmpty,
                      !path.hasPrefix("/") else {
                    return nil
                }

                return path
            }
        }

        return nil
    }

    private var obsidianCliUrls: [URL] {
        var urls = [
            URL(fileURLWithPath: "/Applications/Obsidian.app/Contents/MacOS/obsidian-cli"),
            URL(fileURLWithPath: "/opt/homebrew/bin/obsidian"),
            URL(fileURLWithPath: "/usr/local/bin/obsidian")
        ]

        if let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: SupportedApps.obsidian.bundleId) {
            urls.insert(appUrl.appendingPathComponent("Contents/MacOS/obsidian-cli"), at: 0)
        }

        return urls.reduce(into: [URL]()) { result, url in
            if !result.contains(url) {
                result.append(url)
            }
        }
    }

    private func runObsidianCli(_ cliUrl: URL) -> String? {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = cliUrl
        process.arguments = ["file"]
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            return nil
        }

        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            return nil
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }

    /// Get full url to front Finder window or selected file
    public func getFullUrlToFrontFinderWindowOrSelectedFile() throws -> URL? {

        let finder = SBApplication(bundleIdentifier: Constants.Id.Finder)! as FinderApplication
        
        var target: FinderItem
        
        guard let selection = finder.selection,
            let selectionItems = selection.get() else {
                throw OITError.cannotAccessFinder
        }
        
        if let firstItem = (selectionItems as! Array<AnyObject>).first {
            // Files or folders selected
            target = firstItem as! FinderItem
        } else {
            // Check if there are finder windows opened
            guard let windows = finder.FinderWindows?(),
                let firstWindow = windows.firstObject else {
                    print("No Finder windows are opened or selected")
                    return nil
            }
            target = (firstWindow as! FinderFinderWindow).target?.get() as! FinderItem
        }
        
        guard let targetUrl = target.URL,
            let url = URL(string: targetUrl) else {
                print("target url nil")
                return nil
        }
        
        return url
    }
    
    /// Get full path to front Finder window or selected file
    public func getFullPathToFrontFinderWindowOrSelectedFile() throws -> String {
        guard let url = try getFullUrlToFrontFinderWindowOrSelectedFile() else {
            return ""
        }
        return url.path
    }
    
    /// Get full urls to front Finder windows or selected files
    public func getFullUrlsToFrontFinderWindowOrSelectedFile() throws -> [URL] {
        
        let finder = SBApplication(bundleIdentifier: Constants.Id.Finder)! as FinderApplication
        
        var targets: [FinderItem]
        
        guard let selection = finder.selection,
            let selectionItems = selection.get() else {
                throw OITError.cannotAccessFinder
        }
        
        if let items = selectionItems as? Array<FinderItem>,
            items.count > 0 {
            // Files or folders are selected
            targets = items
        } else {
            // Check if there are opened finder windows
            guard let windows = finder.FinderWindows?(),
                let firstWindow = windows.firstObject else {
                    print("No Finder windows are opened or selected")
                    return []
            }
            let topFinderWindow = (firstWindow as! FinderFinderWindow).target?.get() as! FinderItem
            targets = [topFinderWindow]
        }
        
        let paths = targets.compactMap {
            $0.URL
        }.compactMap {
            URL(string: $0)
        }
        
        return paths
    }
    
    /// Get full paths to front Finder windows or selected files
    public func getFullPathsToFrontFinderWindowOrSelectedFile() throws -> [String] {
        let urls = try getFullUrlsToFrontFinderWindowOrSelectedFile()
        let paths = urls.map {
            $0.path
        }
        return paths
    }
    
    /// Get path to front Finder window or selected file.
    /// If the selected one is file, return it's parent path.
    public func getPathToFrontFinderWindowOrSelectedFile() throws -> String {
        if let obsidianDirectoryPath = getFrontmostObsidianDirectoryPath() {
            return obsidianDirectoryPath
        }
        
        guard let fullUrl = try getFullUrlToFrontFinderWindowOrSelectedFile() else {
            return ""
        }
        
        var isDirectory: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: fullUrl.path, isDirectory: &isDirectory) else {
            print("file does not exist")
            return ""
        }
        
        // if the selected is a file, then delete last path component
        guard isDirectory.boolValue else {
            return fullUrl.deletingLastPathComponent().path
        }
        
        return fullUrl.path
    }
    
    public func getDesktopPath() -> String? {
        let homePath = NSHomeDirectory()
        guard let homeUrl = URL(string: homePath) else { return nil }
        let desktopPath = homeUrl.appendingPathComponent("Desktop").path
        return desktopPath
    }
    
    /// Get all installed applications' names
    public func getAllInstalledApps() -> Set<String> {
        var applications: Set<String> = Set()
        // add system application
        applications.insert("Terminal")
        applications.insert("TextEdit")
        applications.insert("neovim")
        // search
        do {
            var searchDirs: Set<URL> = Set()
            let fileManager = FileManager.default
            // search `/Applications`
            let applicationDir = "/Applications"
            if let applicationURL = URL(string: applicationDir) {
                searchDirs.insert(applicationURL)
            }
            // search `$HOME/Applications`
            let userApplicationDirURL = fileManager.urls(for: .applicationDirectory, in: .userDomainMask)
            if userApplicationDirURL.count > 0 {
                searchDirs.insert(userApplicationDirURL[0])
            }
            // search `$HOME/Library/Application Support/JetBrains/Toolbox
            let libraryDirURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
            if libraryDirURL.count > 0 {
                let libDirURL = libraryDirURL[0]
                let toolboxURL = libDirURL.appendingPathComponent("Application Support")
                    .appendingPathComponent("JetBrains")
                    .appendingPathComponent("Toolbox")
                if fileManager.fileExists(atPath: toolboxURL.path) {
                    searchDirs.insert(toolboxURL)
                }
            }
            
            var levelCount = 0
            
            while !searchDirs.isEmpty {
                // to avoid an infinite loop
                levelCount += 1
                if levelCount > 20 {
                    break
                }
                
                var tmpSearchDirs = searchDirs
                for currentDir in searchDirs {
                    let fileURLs = try fileManager.contentsOfDirectory(at: currentDir, includingPropertiesForKeys: nil)
                    for fileURL in fileURLs {
                        // skip the hidden
                        let baseName = fileURL.lastPathComponent
                        if baseName.hasPrefix(".") {
                            continue
                        }
                        // add to applications
                        if baseName.hasSuffix(".app") {
                            var appName = fileURL.deletingPathExtension().lastPathComponent
                            
                            // nixpkgs fixes
                            do {
                                // iTerm is installed as iTerm2.app
                                if appName == "iTerm2" {
                                    appName = "iTerm"
                                }
                                // IntelliJ IDEA and PyCharm community edition have CE appended
                                else if appName == "IntelliJ IDEA CE" {
                                    appName = "IntelliJ IDEA"
                                } else if appName == "PyCharm CE" {
                                    appName = "PyCharm"
                                }
                            }
                            
                            applications.insert(appName)
                            continue
                        }
                        // add subdirectory to searchDirs
                        var isDir : ObjCBool = false
                        if fileManager.fileExists(atPath: fileURL.path, isDirectory:&isDir) {
                            if isDir.boolValue {
                                // file exists and is a directory
                                
                                // check if it is a alias
                                var isAlias: AnyObject? = nil
                                do {
                                    try (fileURL as NSURL).getResourceValue(&isAlias, forKey: URLResourceKey.isAliasFileKey)
                                } catch _ {}
                                if let isAlias = isAlias as? Bool {
                                    // for nix-darwin users, applications installed through nix will be installed into a symlinked (alias) directory called "Nix Apps"
                                    if fileURL.lastPathComponent == "Nix Apps" {
                                        // symlink needs to be resolved first
                                        tmpSearchDirs.insert(URL(string: try fileManager.destinationOfSymbolicLink(atPath: fileURL.absoluteString.removingPercentEncoding!.replacingOccurrences(of: "file://", with: "")))!)
                                    }
                                    // skip alias directory
                                    else if !isAlias {
                                        tmpSearchDirs.insert(fileURL)
                                    }
                                }
                            } else {
                                // file exists and is not a directory
                            }
                        } else {
                            // file does not exist
                        }
                    }
                    tmpSearchDirs.remove(currentDir)
                }
                searchDirs = tmpSearchDirs
            }
            
        } catch {
            print(error.localizedDescription)
            logw(error.localizedDescription)
        }
        
        return applications
    }
    
}
