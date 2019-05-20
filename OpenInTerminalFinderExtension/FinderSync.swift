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
        let pathURL = URL(fileURLWithPath: "/", isDirectory: true)
        FIFinderSyncController.default().directoryURLs = Set([pathURL])
    }

    override var toolbarItemName: String {
        return NSLocalizedString("toolbar.item_name",
                                 comment: "Open in Terminal")
    }
    
    override var toolbarItemToolTip: String {
        return NSLocalizedString("toolbar.item_tooltip",
                                 comment: "打开当前路径到终端")
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "Icon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        let menu = NSMenu(title: "")
        
        switch menuKind {

        case .contextualMenuForContainer, .contextualMenuForItems:
            menu.addItem(withTitle: NSLocalizedString("menu.open_with_default_terminal",
                                                      comment: "Open with default Terminal"),
                         action: #selector(openDefaultTerminal),
                         keyEquivalent: "")
            menu.addItem(withTitle: NSLocalizedString("menu.open_with_default_editor",
                                                      comment: "Open with default Editor"),
                         action: #selector(openDefaultEditor),
                         keyEquivalent: "")
            menu.addItem(withTitle: NSLocalizedString("menu.copy_path_to_clipboard",
                                                      comment: "Copy path to Clipboard"),
                         action: #selector(copyPathToClipboard),
                         keyEquivalent: "")
        
        case .toolbarItemMenu:
        
            menu.addItem(withTitle: TerminalType.terminal.rawValue,
                         action: #selector(openTerminal),
                         keyEquivalent: "")

            if FinderManager.shared.terminalIsInstalled(.iTerm) {
                menu.addItem(withTitle: TerminalType.iTerm.rawValue,
                             action: #selector(openITerm),
                             keyEquivalent: "")
            }
        
            if FinderManager.shared.terminalIsInstalled(.hyper) {
                menu.addItem(withTitle: TerminalType.hyper.rawValue,
                             action: #selector(openHyper),
                             keyEquivalent: "")
            }
            
            if FinderManager.shared.terminalIsInstalled(.alacritty) {
                menu.addItem(withTitle: TerminalType.alacritty.rawValue,
                             action: #selector(openAlacritty),
                             keyEquivalent: "")
            }
            
            let separator = NSMenuItem.separator()
            separator.title = "-----------------------"
            menu.addItem(separator)
            
            var hasEditor = false
            
            if FinderManager.shared.editorIsInstalled(.vscode) {
                menu.addItem(withTitle: EditorType.vscode.fullName,
                             action: #selector(openVSCode),
                             keyEquivalent: "")
                hasEditor = true
            }
        
            if FinderManager.shared.editorIsInstalled(.atom)  {
                menu.addItem(withTitle: EditorType.atom.fullName,
                             action: #selector(openAtom),
                             keyEquivalent: "")
                hasEditor = true
            }
            
            if FinderManager.shared.editorIsInstalled(.sublime) {
                menu.addItem(withTitle: EditorType.sublime.fullName,
                             action: #selector(openSublime),
                             keyEquivalent: "")
                hasEditor = true
            }
            
            if FinderManager.shared.editorIsInstalled(.vscodium) {
                menu.addItem(withTitle: EditorType.vscodium.fullName,
                             action: #selector(openVSCodium),
                             keyEquivalent: "")
                hasEditor = true
            }
            
            if hasEditor {
                let separator = NSMenuItem.separator()
                separator.title = "-----------------------"
                menu.addItem(separator)
            }
            
            menu.addItem(withTitle: NSLocalizedString("menu.copy_path_to_clipboard",
                                                      comment: "Copy path to Clipboard"),
                         action: #selector(copyPathToClipboard),
                         keyEquivalent: "")
        default:
            break
        }
        
        return menu
    }
    
    // MARK: Notification Actions
    
    @objc func openDefaultTerminal() {
        OpenNotifier.postNotification(.openDefaultTerminal)
    }
    
    @objc func openTerminal() {
        OpenNotifier.postNotification(.openTerminal)
    }
    
    @objc func openITerm() {
        OpenNotifier.postNotification(.openITerm)
    }
    
    @objc func openHyper() {
        OpenNotifier.postNotification(.openHyper)
    }
    
    @objc func openAlacritty() {
        OpenNotifier.postNotification(.openAlacritty)
    }
    
    @objc func openDefaultEditor() {
        OpenNotifier.postNotification(.openDefaultEditor)
    }
    
    @objc func openVSCode() {
        OpenNotifier.postNotification(.openVSCode)
    }
    
    @objc func openAtom() {
        OpenNotifier.postNotification(.openAtom)
    }
    
    @objc func openSublime() {
        OpenNotifier.postNotification(.openSublime)
    }
    
    @objc func openVSCodium() {
        OpenNotifier.postNotification(.openVSCodium)
    }
    
    @objc func copyPathToClipboard() {
        OpenNotifier.postNotification(.copyPathToClipboard)
    }
}

