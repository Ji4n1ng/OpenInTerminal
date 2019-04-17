//
//  main.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/11.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import Cocoa
import ScriptingBridge

/// Get path to front Finder window or selected file
///
/// This method first checks if the user has selected files or folders.
/// If so, return the path to the first selected one.
/// Or check if the user has opened the Finder windows.
/// If so, return the path to the top window.
/// If neither of two cases, then return an empty path.
func getPathToFrontFinderWindowOrSelectedFile() throws -> String {
    
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

do {
    var path = try getPathToFrontFinderWindowOrSelectedFile()
    if path == "" {
        // No Finder windows are opened or selected, so open home directory
        path = NSHomeDirectory()
    }
    
    if let terminal = TerminalManager.shared.getTerminal() {
        try terminal.open(path)
    }
} catch {
    
    log(error, .error)
}
