//
//  FinderSync.swift
//  OpenInTerminalFinderExtension
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Cameron Ingham. All rights reserved.
//

import Cocoa
import FinderSync
import OpenInTerminalCore
import Carbon

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [.skipHiddenVolumes]) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }

    override var toolbarItemName: String {
        return NSLocalizedString("toolbar.item_name",
                                 comment: "Open in Terminal")
    }
    
    override var toolbarItemToolTip: String {
        return NSLocalizedString("toolbar.item_tooltip",
                                 comment: "Open current directory in Terminal.")
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "Icon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        var menu = NSMenu(title: "")
        
        switch menuKind {

        case .contextualMenuForContainer,
             .contextualMenuForItems:
            // need to hide or not
            let isHideContextMenuItems = DefaultsManager.shared.isHideContextMenuItems.bool
            guard !isHideContextMenuItems else { return NSMenu() }
            
            // show custom menu or default
            let isCustomMenu = DefaultsManager.shared.isApplyToContext.bool
            if isCustomMenu {
                menu = createCustomMenu()
            } else {
                menu = createDefaultMenu()
            }
            
        case .toolbarItemMenu:
            // show custom menu or default
            let isCustomMenu = DefaultsManager.shared.isApplyToToolbar.bool
            if isCustomMenu {
                menu = createCustomMenu()
            } else {
                menu = createDefaultMenu()
            }
            
        default:
            break
        }
        
        return menu
    }
    
    var scriptPath: URL? {
        return try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    func fileScriptPath(fileName: String) -> URL? {
        return scriptPath?
            .appendingPathComponent(fileName)
            .appendingPathExtension("scpt")
    }
    
    func createDefaultMenu() -> NSMenu {
        let menu = NSMenu(title: "")
        
        var terminalTitle = ""
        if let terminal = DefaultsManager.shared.defaultTerminal {
            terminalTitle = NSLocalizedString("menu.open_in", comment: "Open in ") + terminal.rawValue
        } else {
            terminalTitle = NSLocalizedString("menu.open_with_default_terminal",
                                              comment: "Open with default Terminal")
        }
        let openInTerminalItem = NSMenuItem(title: terminalTitle,
                                            action: #selector(openDefaultTerminal),
                                            keyEquivalent: "")
        let terminalIcon = NSImage(named: "context_menu_icon_terminal")!
        openInTerminalItem.image = terminalIcon
        menu.addItem(openInTerminalItem)
        
        var editorTitle = ""
        if let editor = DefaultsManager.shared.defaultEditor {
            editorTitle = NSLocalizedString("menu.open_in", comment: "Open in ") + editor.rawValue
        } else {
            editorTitle = NSLocalizedString("menu.open_with_default_editor",
                                            comment: "Open with default Editor")
        }
        let openInEditorItem = NSMenuItem(title: editorTitle,
                                            action: #selector(openDefaultEditor),
                                            keyEquivalent: "")
        let editorIcon = NSImage(named: "context_menu_icon_editor")!
        openInEditorItem.image = editorIcon
        menu.addItem(openInEditorItem)
        
        let copyPathItem = NSMenuItem(title: NSLocalizedString("menu.copy_path_to_clipboard",
                                                               comment: "Copy path to Clipboard"),
                                            action: #selector(copyPathToClipboard),
                                            keyEquivalent: "")
        let copyPathIcon = NSImage(named: "context_menu_icon_path")
        copyPathItem.image = copyPathIcon
        menu.addItem(copyPathItem)
        
        return menu
    }
    
    func createCustomMenu() -> NSMenu {
        let menu = NSMenu(title: "")
        
        // get saved custom apps
        let customAppsString = DefaultsManager.shared.customMenuOptions
        let customApps = customAppsString.components(separatedBy: ",").filter {
            $0 != ""
        }.sortedIgnoreCase()
        
        customApps.forEach { appName in
            if let terminal = TerminalType(rawValue: appName) {
                let terminalTitle = NSLocalizedString("menu.open_in", comment: "Open in ") + terminal.rawValue
                let menuItem = NSMenuItem(title: terminalTitle,
                                          action: #selector(CustomMenuItemClicked),
                                          keyEquivalent: "")
                let terminalIcon = NSImage(named: "context_menu_icon_terminal")!
                menuItem.image = terminalIcon
                menu.addItem(menuItem)
            } else if let editor = EditorType(rawValue: appName) {
                let editorTitle = NSLocalizedString("menu.open_in", comment: "Open in ") + editor.rawValue
                let menuItem = NSMenuItem(title: editorTitle,
                                          action: #selector(CustomMenuItemClicked),
                                          keyEquivalent: "")
                let editorIcon = NSImage(named: "context_menu_icon_editor")!
                menuItem.image = editorIcon
                menu.addItem(menuItem)
            }
        }
        
        let copyPathItem = NSMenuItem(title: NSLocalizedString("menu.copy_path_to_clipboard",
                                                               comment: "Copy path to Clipboard"),
                                            action: #selector(copyPathToClipboard),
                                            keyEquivalent: "")
        let copyPathIcon = NSImage(named: "context_menu_icon_path")
        copyPathItem.image = copyPathIcon
        menu.addItem(copyPathItem)
        
        return menu
    }

    // MARK: - Actions
    
    func openTerminal(_ terminal: TerminalType) {
        var scriptPath: URL
        if terminal == .terminal,
            let newOption = DefaultsManager.shared.getNewOption(.terminal),
            newOption == .tab {
            guard let fileScriptPath = fileScriptPath(fileName: terminal.rawValue + "-tab") else { return }
            scriptPath = fileScriptPath
        } else {
            guard let fileScriptPath = fileScriptPath(fileName: terminal.rawValue) else { return }
            scriptPath = fileScriptPath
        }
        guard FileManager.default.fileExists(atPath: scriptPath.path) else { return }
        guard let script = try? NSUserAppleScriptTask(url: scriptPath) else { return }
        script.execute(completionHandler: nil)
    }
    
    func openEditor(_ editor: EditorType) {
        if (editor == .vscode) {
            var path = "open -a Visual\\ Studio\\ Code"
            if let items = FIFinderSyncController.default().selectedItemURLs(), items.count > 0 {
                items.forEach { (url) in
                    path += " \(url.path)"
                }
            } else if let url = FIFinderSyncController.default().targetedURL() {
                path = url.path
            } else {
                return
            }
            let appleScript = try! NSUserAppleScriptTask(url: fileScriptPath(fileName: editor.rawValue)!)
            appleScript.execute(withAppleEvent: getScriptEvent(functionName: "openVSCode", path)) { (appleEvent, error) in
                if let error = error {
                    print(error)
                }
            }
        } else {
            guard let scriptPath = fileScriptPath(fileName: editor.rawValue) else { return }
            guard FileManager.default.fileExists(atPath: scriptPath.path) else { return }
            guard let script = try? NSUserAppleScriptTask(url: scriptPath) else { return }
            script.execute(completionHandler: nil)
        }
    }
    
    // MARK: - Menu Actions
    
    @objc func openDefaultTerminal() {
        guard let terminal = DefaultsManager.shared.defaultTerminal else { return }
        openTerminal(terminal)
    }
    
    @objc func openDefaultEditor() {
//        openEditor(.vscode)
        guard let editor = DefaultsManager.shared.defaultEditor else { return }
        openEditor(editor)
    }
    
    @objc func CustomMenuItemClicked(_ sender: NSMenuItem) {
        let appName = sender.title[8...]
        if let terminal = TerminalType(rawValue: appName) {
            openTerminal(terminal)
        } else if let editor = EditorType(rawValue: appName) {
            openEditor(editor)
        }
    }
    
    @objc func copyPathToClipboard() {
        var path = ""
        if let items = FIFinderSyncController.default().selectedItemURLs(), items.count > 0 {
            let newItems = items.compactMap { (url) -> String? in
                return url.path
            }
            path = newItems.joined(separator: "\n")
        } else if let url = FIFinderSyncController.default().targetedURL() {
            path = url.path
        } else {
            return
        }
        
        // Set string
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
    }
    
    func getScriptEvent(functionName: String, _ parameter: String) -> NSAppleEventDescriptor {
        let parameters = NSAppleEventDescriptor.list()
        parameters.insert(NSAppleEventDescriptor(string: parameter), at: 0)

        let event = NSAppleEventDescriptor(
            eventClass: AEEventClass(kASAppleScriptSuite),
            eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        event.setDescriptor(NSAppleEventDescriptor(string: functionName), forKeyword: AEKeyword(keyASSubroutineName))
        event.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))
        return event
    }
}

fileprivate extension String {
    
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
    
}
