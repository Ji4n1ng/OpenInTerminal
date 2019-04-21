//
//  TerminalPreferencesViewController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore

class TerminalPreferencesViewController: PreferencesViewController {
    
    // MARK: Properties

    @IBOutlet weak var terminalVisibleButton: NSButton!
    @IBOutlet weak var terminalWindowButton: NSButton!
    @IBOutlet weak var terminalTabButton: NSButton!
    
    @IBOutlet weak var iTermVisibleButton: NSButton!
    @IBOutlet weak var iTermWindowButton: NSButton!
    @IBOutlet weak var iTermTabButton: NSButton!
    
    @IBOutlet weak var hyperVisibleButton: NSButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        refreshButtonVisibleState()
        refreshButtonNewOptionState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Refresh UI
    
    func refreshButtonVisibleState() {
        let terminals: [(TerminalType, NSButton)] =
            [(.terminal, terminalVisibleButton),
             (.iTerm, iTermVisibleButton),
             (.hyper, hyperVisibleButton)]
        
        terminals.forEach { terminal, button in
            let _termianlVisible = TerminalManager.shared.getVisible(terminal)
            if let terminalVisible = _termianlVisible {
                if terminalVisible == .visible {
                    button.state = .on
                } else {
                    button.state = .off
                }
            } else {
                // First usage. There is no UserDefaults
                log("First usage. Setting Buttons Visible")
                TerminalManager.shared.setVisible(terminal, .visible)
            }
        }
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
    
    // MARK: Button Actions
    
    @IBAction func terminalVisibleButtonClicked(_ sender: NSButton) {
        let visble: VisibleType = terminalVisibleButton.state == .on ? .visible : .invisible
        TerminalManager.shared.setVisible(.terminal, visble)
    }
    
    @IBAction func terminalWindowButtonClicked(_ sender: NSButton) {
        terminalTabButton.state = .off
        TerminalManager.shared.setNewOption(.terminal, .window)
    }
    
    @IBAction func terminalTabButtonClicked(_ sender: NSButton) {
        terminalWindowButton.state = .off
        TerminalManager.shared.setNewOption(.terminal, .tab)
    }
    
    @IBAction func iTermVisibleButtonClicked(_ sender: NSButton) {
        let visble: VisibleType = iTermVisibleButton.state == .on ? .visible : .invisible
        TerminalManager.shared.setVisible(.iTerm, visble)
    }
    
    @IBAction func iTermWindowButtonClicked(_ sender: NSButton) {
        iTermTabButton.state = .off
        TerminalManager.shared.setNewOption(.iTerm, .window)
    }
    
    @IBAction func iTermTabButtonClicked(_ sender: NSButton) {
        iTermWindowButton.state = .off
        TerminalManager.shared.setNewOption(.iTerm, .tab)
    }
    
    @IBAction func hyperVisibleButtonClicked(_ sender: NSButton) {
        let visble: VisibleType = hyperVisibleButton.state == .on ? .visible : .invisible
        TerminalManager.shared.setVisible(.hyper, visble)
    }
}
