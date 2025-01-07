//
//  AdvancedPreferencesViewController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/5/5.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore
import ServiceManagement
import ShortcutRecorder

class AdvancedPreferencesViewController: PreferencesViewController {
    
    @IBOutlet weak var defaultTerminalShortcut: RecorderControl!
    @IBOutlet weak var defaultEditorShortcut: RecorderControl!
    @IBOutlet weak var copyPathShortcut: RecorderControl!
    @IBOutlet weak var resetPreferencesButton: NSButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultTerminalShortcut.bind(.value, to: Defaults, withKeyPath: Constants.Key.defaultTerminalShortcut)
        defaultEditorShortcut.bind(.value, to: Defaults, withKeyPath: Constants.Key.defaultEditorShortcut)
        copyPathShortcut.bind(.value, to: Defaults, withKeyPath: Constants.Key.copyPathShortcut)
    }
    
    
    // MARK: Button Actions
    
    @IBAction func resetPreferencesButtonClicked(_ sender: NSButton) {
        let alert = NSAlert()
        
        alert.messageText = NSLocalizedString("alert.reset_preferences_title", comment: "Reset User Preferences?")
        alert.informativeText = NSLocalizedString("alert.reset_preferences_description", comment: "⚠️ Note that this will reset all user preferences")
        
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        
        let yesString = NSLocalizedString("general.yes", comment: "Yes")
        alert.addButton(withTitle: yesString).refusesFirstResponder = true
        
        let modalResult = alert.runModal()
        
        switch modalResult {
        case .alertFirstButtonReturn:
            print("Cancel Resetting User Preferences")
        case .alertSecondButtonReturn:
            logw("Reset User Preferences")
            SMLoginItemSetEnabled(Constants.Id.LauncherApp as CFString, false)
            DefaultsManager.shared.removeAllUserDefaults()
            DefaultsManager.shared.firstSetup()
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.setStatusToggle()
        default:
            print("Cancel Resetting User Preferences")
        }
    }
    
    @IBAction func quitButtonClicked(_ sender: NSButton) {
        LaunchNotifier.postNotification(.terminateApp, object: Bundle.main.bundleIdentifier!)
        NSApp.terminate(self)
    }
    
}
