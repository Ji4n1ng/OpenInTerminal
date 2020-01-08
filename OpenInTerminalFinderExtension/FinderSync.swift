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
        
        func createMenu() -> NSMenu {
            
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
        
        switch menuKind {

        case .contextualMenuForContainer,
             .contextualMenuForItems:
            let isHideContextMenuItems = DefaultsManager.shared.isHideContextMenuItems.bool
            if isHideContextMenuItems {
                break
            } else {
                menu = createMenu()
            }
            
        case .toolbarItemMenu:
            menu = createMenu()
            
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

    // MARK: Notification Actions
    
    @objc func openDefaultTerminal() {
        guard let terminal = DefaultsManager.shared.defaultTerminal else { return }
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
    
    @objc func openDefaultEditor() {
        guard let editor = DefaultsManager.shared.defaultEditor else { return }
        guard let scriptPath = fileScriptPath(fileName: editor.rawValue) else { return }
        guard FileManager.default.fileExists(atPath: scriptPath.path) else { return }
        guard let script = try? NSUserAppleScriptTask(url: scriptPath) else { return }
        script.execute(completionHandler: nil)
    }
    
    @objc func copyPathToClipboard() {
        var path = ""
        if let items = FIFinderSyncController.default().selectedItemURLs(), items.count > 0 {
            path = items[0].path
        } else if let url = FIFinderSyncController.default().targetedURL() {
            path = url.path
        } else {
            return
        }
        
        // Set string
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
    }
}

