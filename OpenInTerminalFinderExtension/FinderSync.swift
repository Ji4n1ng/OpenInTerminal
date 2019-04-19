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
        return NSImage(named: "TerminalIcon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "Terminal", action: #selector(openTerminal), keyEquivalent: "")
        
        if FinderManager.shared.terminalIsInstalled(.iTerm) {
            menu.addItem(withTitle: "iTerm", action: #selector(openITerm), keyEquivalent: "")
        }
        
        if FinderManager.shared.terminalIsInstalled(.hyper) {
            menu.addItem(withTitle: "Hyper", action: #selector(openHyper), keyEquivalent: "")
        }
        
        return menu
    }
    
    @objc func openTerminal() {
         DistributedNotificationCenter.default().post(name: NSNotification.Name("openTerminal"), object: nil)
    }
    
    @objc func openITerm() {
        DistributedNotificationCenter.default().post(name: NSNotification.Name("openITerm"), object: nil)
    }
    
    @objc func openHyper() {
         DistributedNotificationCenter.default().post(name: NSNotification.Name("openHyper"), object: nil)
    }
}

