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
        menu.addItem(withTitle: TerminalType.terminal.name,
                     action: #selector(openTerminal),
                     keyEquivalent: "")
        
        if FinderManager.shared.terminalIsInstalled(.iTerm) {
            menu.addItem(withTitle: TerminalType.iTerm.name,
                         action: #selector(openITerm),
                         keyEquivalent: "")
        }
        
        if FinderManager.shared.terminalIsInstalled(.hyper) {
            menu.addItem(withTitle: TerminalType.hyper.name,
                         action: #selector(openHyper),
                         keyEquivalent: "")
        }
        
        return menu
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
}

