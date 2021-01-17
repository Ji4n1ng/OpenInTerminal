//
//  AppManager.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/12/18.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

public class AppManager {
    
    public static var shared = AppManager()
    
    public func pickTerminalAlert() -> App? {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("alert.pick_terminal_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_terminal_description", comment: "Please select one of the following terminals as the default terminal to open.")
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.terminal.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.iTerm.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.hyper.name).refusesFirstResponder = true
        let modalResult = alert.runModal()
        switch modalResult {
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return SupportedApps.terminal.app
        case .alertThirdButtonReturn:
            return SupportedApps.iTerm.app
        default:
            return SupportedApps.hyper.app
        }
    }
    
    public func pickEditorAlert() -> App? {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("alert.pick_editor_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_editor_description", comment: "Please select one of the following editors as the default editor to open.")
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.vscode.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.sublime.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.atom.name).refusesFirstResponder = true
        let modalResult = alert.runModal()
        switch modalResult {
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return SupportedApps.vscode.app
        case .alertThirdButtonReturn:
            return SupportedApps.sublime.app
        default:
            return SupportedApps.atom.app
        }
    }
    
    public static func getApplicationName(from path: String?) -> String {
        guard let validPath = path else {
            return "Invalid Name"
        }
        guard let validBundle = Bundle.init(url: URL.init(fileURLWithPath: validPath)) else {
            return getApplicationFileName(from: validPath)
        }
        let CFBundleDisplayName = validBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let CFBundleName = validBundle.object(forInfoDictionaryKey: "CFBundleName") as? String
        let FileName = getApplicationFileName(from: validPath)
        return CFBundleDisplayName ?? CFBundleName ?? FileName
    }
    
    public static func getApplicationName(from path: URL) -> String {
        return getApplicationName(from: path.path)
    }
    
    public static func getApplicationFileName(from path: String) -> String {
        var rawName = FileManager().displayName(atPath: path).removingPercentEncoding!
        let lowercased = rawName.lowercased()
        if lowercased.hasSuffix(".app") {
            let start = rawName.startIndex
            let end = rawName.index(rawName.endIndex, offsetBy: -4)
            rawName = String(rawName[start..<end])
        }
        return rawName
    }
    
    // 从路径获取应用图标
    public static func getApplicationIcon(from path: String?) -> NSImage {
        guard let validPath = path else {
            return #imageLiteral(resourceName: "SF.cube")
        }
        return NSWorkspace.shared.icon(forFile: validPath)
    }
    
    public static func getApplicationIcon(from path: URL) -> NSImage {
        return getApplicationIcon(from: path.path)
    }
}
