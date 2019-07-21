//
//  FinderSync.swift
//  OpenInTerminalFinderExtension
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Cameron Ingham. All rights reserved.
//

import Cocoa
import FinderSync

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
        
        let menu = NSMenu(title: "")
        
        switch menuKind {

        case .contextualMenuForContainer, .contextualMenuForItems, .toolbarItemMenu:
            
            let openInTerminalItem = NSMenuItem(title: NSLocalizedString("menu.open_with_default_terminal",
                                                                         comment: "Open with default Terminal"),
                                                action: #selector(openDefaultTerminal),
                                                keyEquivalent: "")
            openInTerminalItem.image = NSImage(named: "context_menu_icon_terminal")
            menu.addItem(openInTerminalItem)
            
            let openInEditorItem = NSMenuItem(title: NSLocalizedString("menu.open_with_default_editor",
                                                                         comment: "Open with default Editor"),
                                                action: #selector(openDefaultEditor),
                                                keyEquivalent: "")
            openInEditorItem.image = NSImage(named: "context_menu_icon_editor")
            menu.addItem(openInEditorItem)
            
            let copyPathItem = NSMenuItem(title: NSLocalizedString("menu.copy_path_to_clipboard",
                                                                   comment: "Copy path to Clipboard"),
                                                action: #selector(copyPathToClipboard),
                                                keyEquivalent: "")
            copyPathItem.image = NSImage(named: "context_menu_icon_path")
            menu.addItem(copyPathItem)
            
        default:
            break
        }
        
        return menu
    }
    
    // MARK: Notification Actions
    
    @objc func openDefaultTerminal() {
        OpenNotifier.postNotification(.openDefaultTerminal)
    }
    
    @objc func openDefaultEditor() {
        OpenNotifier.postNotification(.openDefaultEditor)
    }
    
    @objc func copyPathToClipboard() {
        OpenNotifier.postNotification(.copyPathToClipboard)
    }
}

