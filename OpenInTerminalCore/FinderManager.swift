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
    
    /// Get path to front Finder window or selected file
    ///
    /// This method first checks if the user has selected files or folders.
    /// If so, return the path to the first selected one.
    /// Or check if the user has opened the Finder windows.
    /// If so, return the path to the top window.
    /// If neither of two cases, then return an empty path.
    public func getPathToFrontFinderWindowOrSelectedFile() throws -> String {
        
        let finder = SBApplication(bundleIdentifier: Config.Finder.id)! as FinderApplication
        
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
                    log("No Finder windows are opened or selected", .warn)
                    return ""
            }
            target = (firstWindow as! FinderFinderWindow).target?.get() as! FinderItem
        }
        
        var isDirectory: ObjCBool = false
        
        guard let targetUrl = target.URL,
            let url = URL(string: targetUrl) else {
                log("target url nil", .warn)
                return ""
        }
        
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            log("file does not exist", .warn)
            return ""
        }
        
        // if the selected is a file, then delete last path component
        guard isDirectory.boolValue else {
            return url.deletingLastPathComponent().absoluteString
        }
        
        return url.absoluteString
    }
    
    /// Determine if the app exists in the `/Applications` folder
    private func applicationExists(_ application: String) -> Bool {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: "/Applications").contains("\(application).app")
        } catch {
            return false
        }
    }
    
    /// Determine if the user has installed a terminal
    public func terminalIsInstalled(_ terminalType: TerminalType) -> Bool {
        switch terminalType {
        case .terminal:
            return true
        case .iTerm:
            return self.applicationExists(TerminalType.iTerm.name)
        case .hyper:
            return self.applicationExists(TerminalType.hyper.name)
        }
    }
}
