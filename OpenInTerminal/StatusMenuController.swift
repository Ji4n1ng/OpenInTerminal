//
//  StatusMenuController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/30.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore

class StatusMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var defaultTerminalMenuItem: NSMenuItem!
    @IBOutlet weak var defaultEditorMenuItem: NSMenuItem!
    @IBOutlet weak var copyPathMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    
    // MARK: Menu life cycle
    
    override func awakeFromNib() {
        Log.logger.directory = "~/Library/Logs/OpenInTerminal"
        #if DEBUG
        Log.logger.name = "OpenInTerminal-debug"
        #else
        Log.logger.name = "OpenInTerminal"
        #endif
        //Edit printToConsole parameter in Edit Scheme > Run > Arguments > Environment Variables
        Log.logger.printToConsole = ProcessInfo.processInfo.environment["print_log"] == "true"
        
        
//        statusMenu.delegate = self
//        preferencesMenuItem.title = NSLocalizedString("menu.preferences", comment: "Preferences...")
//        quitMenuItem.title = NSLocalizedString("menu.quit", comment: "Quit Shifty")

    }
    
    // MARK: Menu Item Actions
    
    @IBAction func openDefaultTerminal(_ sender: NSMenuItem) {
        
    }
    
    @IBAction func openDefaultEditor(_ sender: NSMenuItem) {
        
    }
    
    @IBAction func copyPathToClipboard(_ sender: NSMenuItem) {
        
    }
    
    @IBAction func showPreferences(_ sender: NSMenuItem) {
        let preferencesWindowController = (NSApplication.shared.delegate as? AppDelegate)?.preferencesWindowController
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindowController?.showWindow(sender)
    }
    
    @IBAction func quit(_ sender: NSMenuItem) {
        
    }
    
}
