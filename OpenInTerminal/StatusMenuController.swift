//
//  StatusMenuController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/30.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore
import MASShortcut

class StatusMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var defaultTerminalMenuItem: NSMenuItem!
    @IBOutlet weak var defaultEditorMenuItem: NSMenuItem!
    @IBOutlet weak var copyPathMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    
    // MARK: Menu life cycle
    
    func setMenuItemTitle() {
        var terminalTitle = ""
        if let terminal = DefaultsManager.shared.defaultTerminal {
            terminalTitle = NSLocalizedString("menu.open_in", comment: "Open in ") + terminal.rawValue
        } else {
            terminalTitle = NSLocalizedString("menu.open_with_default_terminal",
                                              comment: "Open with default Terminal")
        }
        defaultTerminalMenuItem.title = terminalTitle
        
        var editorTitle = ""
        if let editor = DefaultsManager.shared.defaultEditor {
            editorTitle = NSLocalizedString("menu.open_in", comment: "Open in ") + editor.rawValue
        } else {
            editorTitle = NSLocalizedString("menu.open_with_default_editor",
                                            comment: "Open with default Editor")
        }
        defaultEditorMenuItem.title = editorTitle
    }
    
    override func awakeFromNib() {
        Log.logger.directory = "~/Library/Logs/OpenInTerminal"
        #if DEBUG
        Log.logger.name = "OpenInTerminal-debug"
        #else
        Log.logger.name = "OpenInTerminal"
        #endif
        //Edit printToConsole parameter in Edit Scheme > Run > Arguments > Environment Variables
        Log.logger.printToConsole = ProcessInfo.processInfo.environment["print_log"] == "true"
        
        statusMenu.delegate = self
        
        copyPathMenuItem.title = NSLocalizedString("menu.copy_path_to_clipboard", comment: "Copy path to Clipboard")
        preferencesMenuItem.title = NSLocalizedString("menu.preferences", comment: "Preferences...")
        quitMenuItem.title = NSLocalizedString("menu.quit", comment: "Quit")
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        setMenuItemTitle()
        let menuItems: [(NSMenuItem, String)] =
            [(defaultTerminalMenuItem, Constants.Key.defaultTerminalShortcut),
             (defaultEditorMenuItem, Constants.Key.defaultEditorShortcut),
             (copyPathMenuItem, Constants.Key.copyPathShortcut)]
        
        menuItems.forEach { item, key in
            assignKeyboardShortcutToMenuItem(item, userDefaultsKey: key)
        }
    }
    
    func assignKeyboardShortcutToMenuItem(_ menuItem: NSMenuItem, userDefaultsKey: String) {
        if let data = UserDefaults.standard.value(forKey: userDefaultsKey),
            let shortcut = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? MASShortcut {
            let flags = NSEvent.ModifierFlags.init(rawValue: shortcut.modifierFlags)
            menuItem.keyEquivalentModifierMask = flags
            menuItem.keyEquivalent = shortcut.keyCodeString.lowercased()
        } else {
            menuItem.keyEquivalentModifierMask = []
            menuItem.keyEquivalent = ""
        }
    }
    
    // MARK: Menu Item Actions
    
    @IBAction func openDefaultTerminal(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.openDefaultTerminal()
    }
    
    @IBAction func openDefaultEditor(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.openDefaultEditor()
    }
    
    @IBAction func copyPathToClipboard(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.copyPathToClipboard()
    }
    
    @IBAction func showPreferences(_ sender: NSMenuItem) {
        let preferencesWindowController = (NSApplication.shared.delegate as? AppDelegate)?.preferencesWindowController
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindowController?.showWindow(sender)
    }
    
    @IBAction func quit(_ sender: NSMenuItem) {
        LaunchNotifier.postNotification(.terminateApp, object: Bundle.main.bundleIdentifier!)
        NSApp.terminate(self)
    }
    
}
