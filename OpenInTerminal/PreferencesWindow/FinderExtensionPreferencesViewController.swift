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

    @IBOutlet weak var terminalTextField: NSTextField!
    @IBOutlet weak var terminalWindowButton: NSButton!
    @IBOutlet weak var terminalTabButton: NSButton!
    @IBOutlet weak var terminalClearButton: NSButton!
    
    
    @IBOutlet weak var iTermTextField: NSTextField!
    @IBOutlet weak var iTermWindowButton: NSButton!
    @IBOutlet weak var iTermTabButton: NSButton!
    @IBOutlet weak var iTermClearButton: NSButton!
    
    @IBOutlet weak var hyperTextField: NSTextField!
    
    @IBOutlet weak var alacrittyTextField: NSTextField!
    
    @IBOutlet weak var vscodeTextField: NSTextField!
    @IBOutlet weak var atomTextField: NSTextField!
    @IBOutlet weak var sublimeTextField: NSTextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        refreshTextFieldEnabledState()
        refreshButtonNewOptionState()
        refreshButtonClearOptionState()
        refreshButtonEnabledState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Refresh UI
    
    func refreshTextFieldEnabledState() {
        let terminals: [(TerminalType, NSTextField)] =
            [(.terminal, terminalTextField),
             (.iTerm, iTermTextField),
             (.hyper, hyperTextField),
             (.alacritty, alacrittyTextField)]

        terminals.forEach { terminal, textField in
            let isInstalled = FinderManager.shared.terminalIsInstalled(terminal)
            textField.isEnabled = isInstalled
            if isInstalled {
                textField.textColor = .labelColor
                textField.stringValue = "\(terminal.rawValue)"
            } else {
                textField.textColor = .secondaryLabelColor
                textField.stringValue = "\(terminal.rawValue) (Not Installed)"
            }
        }
        
        let editors: [(EditorType, NSTextField)] =
            [(.vscode, vscodeTextField),
             (.atom, atomTextField),
             (.sublime, sublimeTextField)]
        
        editors.forEach { editor, textField in
            let isInstalled = FinderManager.shared.editorIsInstalled(editor)
            textField.isEnabled = isInstalled
            if isInstalled {
                textField.textColor = .labelColor
                textField.stringValue = "\(editor.fullName)"
            } else {
                textField.textColor = .secondaryLabelColor
                textField.stringValue = "\(editor.fullName) (Not Installed)"
            }
        }
    }
    
    func refreshButtonEnabledState() {
        terminalWindowButton.isEnabled = terminalTextField.isEnabled
        terminalTabButton.isEnabled = terminalTextField.isEnabled
        terminalClearButton.isEnabled = terminalTextField.isEnabled

        iTermWindowButton.isEnabled = terminalTextField.isEnabled
        iTermTabButton.isEnabled = terminalTextField.isEnabled
        iTermClearButton.isEnabled = terminalTextField.isEnabled
    }
    
    func refreshButtonNewOptionState() {
        let terminals: [(TerminalType, NSButton, NSButton)] =
            [(.terminal, terminalWindowButton, terminalTabButton),
             (.iTerm, iTermWindowButton, iTermTabButton)]
        
        terminals.forEach { terminal, windowButton, tabButton in
            let _newOption = TerminalManager.shared.getNewOption(terminal)
            if let newOption = _newOption {
                if newOption == .window {
                    windowButton.state = .on
                    tabButton.state = .off
                } else {
                    windowButton.state = .off
                    tabButton.state = .on
                }
            } else {
                // First usage. There is no UserDefaults
                log("First usage. Setting Buttons NewOption")
                TerminalManager.shared.setNewOption(terminal, .window)
            }
        }
    }
    
    func refreshButtonClearOptionState() {
        let terminals: [(TerminalType, NSButton)] =
            [(.terminal, terminalClearButton),
             (.iTerm, iTermClearButton)]
        
        terminals.forEach { terminal, button in
            let _clearOption = TerminalManager.shared.getClearOption(terminal)
            if let clearOption = _clearOption {
                button.state = clearOption == .clear ? .on : .off
            } else {
                // First usage. There is no UserDefaults
                log("First usage. Setting Buttons NewOption")
                TerminalManager.shared.setClearOption(terminal, .noClear)
            }
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func terminalWindowButtonClicked(_ sender: NSButton) {
        terminalTabButton.state = .off
        TerminalManager.shared.setNewOption(.terminal, .window)
    }
    
    @IBAction func terminalTabButtonClicked(_ sender: NSButton) {
        terminalWindowButton.state = .off
        TerminalManager.shared.setNewOption(.terminal, .tab)
    }
    
    @IBAction func terminalClearButtonClicked(_ sender: NSButton) {
        let clearOption: ClearOptionType = terminalClearButton.state == .on ? .clear : .noClear
        TerminalManager.shared.setClearOption(.terminal, clearOption)
    }
    
    @IBAction func iTermWindowButtonClicked(_ sender: NSButton) {
        iTermTabButton.state = .off
        TerminalManager.shared.setNewOption(.iTerm, .window)
    }
    
    @IBAction func iTermTabButtonClicked(_ sender: NSButton) {
        iTermWindowButton.state = .off
        TerminalManager.shared.setNewOption(.iTerm, .tab)
    }
    
    @IBAction func iTermClearButtonClicked(_ sender: NSButton) {
        let clearOption: ClearOptionType = iTermClearButton.state == .on ? .clear : .noClear
        TerminalManager.shared.setClearOption(.iTerm, clearOption)
    }
}
