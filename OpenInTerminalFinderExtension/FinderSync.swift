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
        return "Open In Terminal"
    }
    
    override var toolbarItemToolTip: String {
        return "Open the current directory in the Terminal."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "Icon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        let menu = NSMenu(title: "")
        
        switch menuKind {

        case .contextualMenuForContainer, .contextualMenuForItems:
            menu.addItem(withTitle: "Open with Default Terminal",
                         action: #selector(openDefaultTerminal),
                         keyEquivalent: "")
            menu.addItem(withTitle: "Open with Default Editor",
                         action: #selector(openDefaultEditor),
                         keyEquivalent: "")
        
        case .toolbarItemMenu:
            var hasTerminal = false
        
            if FinderManager.shared.terminalIsInstalled(.terminal) {
                menu.addItem(withTitle: TerminalType.terminal.name,
                             action: #selector(openTerminal),
                             keyEquivalent: "")
                hasTerminal = true
            }
        
            if FinderManager.shared.terminalIsInstalled(.iTerm) {
                menu.addItem(withTitle: TerminalType.iTerm.name,
                             action: #selector(openITerm),
                             keyEquivalent: "")
                hasTerminal = true
            }
        
            if FinderManager.shared.terminalIsInstalled(.hyper) {
                menu.addItem(withTitle: TerminalType.hyper.name,
                             action: #selector(openHyper),
                             keyEquivalent: "")
                hasTerminal = true
            }
            
            if FinderManager.shared.terminalIsInstalled(.alacritty) {
                menu.addItem(withTitle: TerminalType.alacritty.name,
                             action: #selector(openAlacritty),
                             keyEquivalent: "")
                hasTerminal = true
            }
            
            if hasTerminal {
                let separator = NSMenuItem.separator()
                separator.title = "------------------"
                menu.addItem(separator)
            }
            
            if FinderManager.shared.editorIsInstalled(.vscode) {
                menu.addItem(withTitle: EditorType.vscode.name,
                             action: #selector(openVSCode),
                             keyEquivalent: "")
            }
        
            if FinderManager.shared.editorIsInstalled(.atom)  {
                menu.addItem(withTitle: EditorType.atom.name,
                             action: #selector(openAtom),
                             keyEquivalent: "")
            }
            
            if FinderManager.shared.editorIsInstalled(.sublime) {
                menu.addItem(withTitle: EditorType.sublime.name,
                             action: #selector(openSublime),
                             keyEquivalent: "")
            }
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
}

