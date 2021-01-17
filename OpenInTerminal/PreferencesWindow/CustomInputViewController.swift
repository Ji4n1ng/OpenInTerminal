//
//  CustomInputViewController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2021/1/14.
//  Copyright © 2021 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore

class CustomInputViewController: NSViewController {
    
    @IBOutlet weak var appNameTextField: NSTextField!
    @IBOutlet weak var terminalTypeButton: NSButton!
    @IBOutlet weak var editorTypeButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var confirmButton: NSButton!
    var appName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appNameTextField.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        terminalTypeButton.state = .off
        editorTypeButton.state = .off
        if let name = appName {
            appNameTextField.stringValue = name
        }
        refreshConfirmState()
    }
    
    @IBAction func terminalTypeButtonClicked(_ sender: NSButton) {
        editorTypeButton.state = .off
        refreshConfirmState()
    }
    
    @IBAction func editorTypeButtonClicked(_ sender: NSButton) {
        terminalTypeButton.state = .off
        refreshConfirmState()
    }
    
    @IBAction func cancelButtonClicked(_ sender: NSButton) {
        dismiss(nil)
    }
    
    @IBAction func confirmButtonClicked(_ sender: NSButton) {
        confirmButton.isEnabled = false
        if let presenting = presentingViewController as? CustomPreferencesViewController {
            let name = appNameTextField.stringValue
            let type: AppType = terminalTypeButton.state == .on ? .terminal : .editor
            let app = App(name: name, type: type)
            presenting.addCustomApp(app)
            dismiss(nil)
        }
    }
    
    func refreshConfirmState() {
        if appNameTextField.stringValue.count > 0 && (terminalTypeButton.state == .on || editorTypeButton.state == .on) {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
    
}

extension CustomInputViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        refreshConfirmState()
    }
    
}
