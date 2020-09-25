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
    
    /// Get full path to front Finder window or selected file
    public func getFullPathToFrontFinderWindowOrSelectedFile() throws -> String {
        
        let finder = SBApplication(bundleIdentifier: Constants.Finder.id)! as FinderApplication
        
        var target: FinderItem
        
        guard let selection = finder.selection,
            let selectionItems = selection.get() else {
                throw OITError.cannotAccessFinder
        }
        
        if let firstItem = (selectionItems as! Array<AnyObject>).first {
            
            // Files or folders are selected
            target = firstItem as! FinderItem
        }
        else {
            
            // Check if there are opened finder windows
            guard let windows = finder.FinderWindows?(),
                let firstWindow = windows.firstObject else {
                    print("No Finder windows are opened or selected")
                    return ""
            }
            target = (firstWindow as! FinderFinderWindow).target?.get() as! FinderItem
        }
        
        guard let targetUrl = target.URL,
            let url = URL(string: targetUrl) else {
                print("target url nil")
                return ""
        }
        
        return url.absoluteString
    }
    
    /// Get full paths to front Finder windows or selected files
    public func getFullPathsToFrontFinderWindowOrSelectedFile() throws -> [String] {
        
        let finder = SBApplication(bundleIdentifier: Constants.Finder.id)! as FinderApplication
        
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
        }.map {
            $0.absoluteString
        }
        
        return paths
    }
    
    /// Get path to front Finder window or selected file.
    /// If the selected one is file, return it's parent path.
    public func getPathToFrontFinderWindowOrSelectedFile() throws -> String {
        
        let fullPath = try getFullPathToFrontFinderWindowOrSelectedFile()
        
        guard fullPath != "" else { return "" }
        
        guard let url = URL(string: fullPath) else {
            throw OITError.wrongUrl
        }
        
        var isDirectory: ObjCBool = false
        
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            print("file does not exist")
            return ""
        }
        
        // if the selected is a file, then delete last path component
        guard isDirectory.boolValue else {
            return url.deletingLastPathComponent().absoluteString
        }
        
        return url.absoluteString
    }
    
//    /// Determine if the app exists in the `/Applications` folder
//    private func applicationExists(_ application: String) -> Bool {
//        var isInApplication = false
//        let applicationDir = "/Applications/"
//        let applicationPath = applicationDir + application + ".app"
//        if FileManager.default.fileExists(atPath: applicationPath) {
//            isInApplication = true
//        }
//        
//        var isInHomeApplication = false
//        var homeApplicationDirURL: URL
//        if #available(OSX 10.12, *) {
//            homeApplicationDirURL = FileManager.default.homeDirectoryForCurrentUser
//        } else {
//            // Fallback on earlier versions
//            homeApplicationDirURL = URL(fileURLWithPath: NSHomeDirectory())
//        }
//        homeApplicationDirURL.appendPathComponent("Applications")
//        let homeApplicationPath = homeApplicationDirURL.path + "/" + application + ".app"
//        if FileManager.default.fileExists(atPath: homeApplicationPath) {
//            isInHomeApplication = true
//        }
//        return isInApplication || isInHomeApplication
//    }
//    
//    /// Determine if the user has installed the terminal
//    public func terminalIsInstalled(_ terminalType: TerminalType) -> Bool {
//        switch terminalType {
//        case .terminal:
//            return true
//        case .iTerm, .hyper, .alacritty:
//            return self.applicationExists(terminalType.rawValue)
//        }
//    }
//    
//    /// Determine if the user has installed the editor
//    public func editorIsInstalled(_ editorType: EditorType) -> Bool {
//        return self.applicationExists(editorType.fullName)
//    }
    
    /// Get all installed applications
    public func getAllInstalledApps() -> Set<String> {

        var applications: Set<String> = Set()
        
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
            
            var levelCount = 0
            
            while !searchDirs.isEmpty {
                // to avoid an infinite loop
                levelCount += 1
                if levelCount > 20 {
                    break
                }
                
                var tmpDirs = searchDirs
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
                            let appName = fileURL.deletingPathExtension().lastPathComponent
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
                                    // skip alias directory
                                    if !isAlias {
                                        tmpDirs.insert(fileURL)
                                    }
                                }
                            } else {
                                // file exists and is not a directory
                            }
                        } else {
                            // file does not exist
                        }
                    }
                    tmpDirs.remove(currentDir)
                }
                searchDirs = tmpDirs
            }
            
        } catch {
            print(error.localizedDescription)
            logw(error.localizedDescription)
        }
        
        return applications
    }
    
}
