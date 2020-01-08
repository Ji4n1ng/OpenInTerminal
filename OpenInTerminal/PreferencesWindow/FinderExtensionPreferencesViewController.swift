//
//  TerminalPreferencesViewController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore

class FinderExtensionPreferencesViewController: PreferencesViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var installedApplicationsTextField: NSTextField!
    @IBOutlet weak var notInstalledApplicationsTextField: NSTextField!
    
    @IBOutlet weak var terminalTextField: NSTextField!
    @IBOutlet weak var terminalWindowButton: NSButton!
    @IBOutlet weak var terminalTabButton: NSButton!
    
    @IBOutlet weak var iTermTextField: NSTextField!
    @IBOutlet weak var iTermWindowButton: NSButton!
    @IBOutlet weak var iTermTabButton: NSButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        refreshInstalledApplicationsTextField()
        refreshTextFieldEnabledState()
        refreshButtonNewOptionState()
        refreshButtonEnabledState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Refresh UI
    
    func refreshInstalledApplicationsTextField() {
        let installedTerminals = Constants.allTerminals.filter {
            FinderManager.shared.terminalIsInstalled($0)
        }.map {
            $0.rawValue
        }
        let installedEditors = Constants.allEditors.filter {
            FinderManager.shared.editorIsInstalled($0)
        }.map {
            $0.fullName
        }
        let installedApps = installedTerminals + installedEditors
        installedApplicationsTextField.stringValue = installedApps.sorted().joined(separator: ", ")
        
        let notInstalledTerminals = Constants.allTerminals.filter {
            !FinderManager.shared.terminalIsInstalled($0)
        }.map {
            $0.rawValue
        }
        let notInstalledEditors = Constants.allEditors.filter {
            !FinderManager.shared.editorIsInstalled($0)
        }.map {
            $0.fullName
        }
        let notInstalledApps = notInstalledTerminals + notInstalledEditors
        notInstalledApplicationsTextField.stringValue = notInstalledApps.sorted().joined(separator: ", ")
    }
    
    func refreshTextFieldEnabledState() {
        let terminals: [(TerminalType, NSTextField)] =
            [(.terminal, terminalTextField),
             (.iTerm, iTermTextField)]

        terminals.forEach { terminal, textField in
            let isInstalled = FinderManager.shared.terminalIsInstalled(terminal)
            textField.isEnabled = isInstalled
            if isInstalled {
                textField.textColor = .labelColor
                textField.stringValue = "\(terminal.rawValue)"
            } else {
                textField.textColor = .secondaryLabelColor
                let notInstalledString = NSLocalizedString("pref.toolbar.not_installed", comment: "Not Installed")
                textField.stringValue = "\(terminal.rawValue) (\(notInstalledString))"
            }
        }
    }
    
    func refreshButtonEnabledState() {
        terminalWindowButton.isEnabled = terminalTextField.isEnabled
        terminalTabButton.isEnabled = terminalTextField.isEnabled

        iTermWindowButton.isEnabled = iTermTextField.isEnabled
        iTermTabButton.isEnabled = iTermTextField.isEnabled
    }
    
    func refreshButtonNewOptionState() {
        let terminals: [(TerminalType, NSButton, NSButton)] =
            [(.terminal, terminalWindowButton, terminalTabButton),
             (.iTerm, iTermWindowButton, iTermTabButton)]
        
        terminals.forEach { terminal, windowButton, tabButton in
            let _newOption = DefaultsManager.shared.getNewOption(terminal)
            if let newOption = _newOption {
                if newOption == .window {
                    windowButton.state = .on
                    tabButton.state = .off
                } else {
                    windowButton.state = .off
                    tabButton.state = .on
                }
            }
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func terminalWindowButtonClicked(_ sender: NSButton) {
        terminalTabButton.state = .off
        do {
            try DefaultsManager.shared.setNewOption(.terminal, .window)
        } catch {
            logw(error.localizedDescription)
        }
    }
    
    @IBAction func terminalTabButtonClicked(_ sender: NSButton) {
        terminalWindowButton.state = .off
        do {
            try DefaultsManager.shared.setNewOption(.terminal, .tab)
        } catch {
            logw(error.localizedDescription)
        }
    }
    
    @IBAction func iTermWindowButtonClicked(_ sender: NSButton) {
        iTermTabButton.state = .off
        do {
            try DefaultsManager.shared.setNewOption(.iTerm, .window)
        } catch {
            logw(error.localizedDescription)
        }
    }
    
    @IBAction func iTermTabButtonClicked(_ sender: NSButton) {
        iTermWindowButton.state = .off
        do {
            try DefaultsManager.shared.setNewOption(.iTerm, .tab)
        } catch {
            logw(error.localizedDescription)
        }
    }
    
}
