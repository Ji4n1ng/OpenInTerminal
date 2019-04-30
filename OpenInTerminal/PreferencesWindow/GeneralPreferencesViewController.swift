//
//  GeneralPreferencesViewController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore
import ServiceManagement

class GeneralPreferencesViewController: PreferencesViewController {

    // MARK: Properties

//    @IBOutlet weak var launchButton: NSButton!
    @IBOutlet weak var quickOpenButton: NSButton!
    @IBOutlet weak var defaultTerminalButton: NSPopUpButton!
    @IBOutlet weak var defaultEditorButton: NSPopUpButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        refreshButtonState()
        refreshDefaultTerminal()
        refreshDefaultEditor()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Refresh UI
    
    func refreshButtonState() {
//        guard let launchAtLogin = CoreManager.shared.launchAtLogin else { return }
//        launchButton.state = launchAtLogin == ._true ? .on : .off
        
        guard let quickOpen = CoreManager.shared.quickOpen else { return }
        quickOpenButton.state = quickOpen == ._true ? .on : .off
    }
    
    func refreshDefaultTerminal() {
        defaultTerminalButton.removeAllItems()
        
        defaultTerminalButton.addItem(withTitle: Constants.none)
        
        let terminals: [TerminalType] =
            [.terminal, .iTerm, .hyper, .alacritty]
        
        terminals.forEach { terminal in
            let isInstalled = FinderManager.shared.terminalIsInstalled(terminal)
            if isInstalled {
                defaultTerminalButton.addItem(withTitle: terminal.rawValue)
            }
        }
        
        if let defaultTerminal = TerminalManager.shared.getDefaultTerminal() {
            let index = defaultTerminalButton.indexOfItem(withTitle: defaultTerminal.rawValue)
            defaultTerminalButton.selectItem(at: index)
        } else {
            let index = defaultTerminalButton.indexOfItem(withTitle: Constants.none)
            defaultTerminalButton.selectItem(at: index)
        }
    }
    
    func refreshDefaultEditor() {
        defaultEditorButton.removeAllItems()
        
        defaultEditorButton.addItem(withTitle: Constants.none)
        
        let editors: [EditorType] =
            [.vscode, .atom, .sublime]
        
        editors.forEach { editor in
            let isInstalled = FinderManager.shared.editorIsInstalled(editor)
            if isInstalled {
                defaultEditorButton.addItem(withTitle: editor.rawValue)
            }
        }
        
        if let defaultEditor = EditorManager.shared.getDefaultEditor() {
            let index = defaultEditorButton.indexOfItem(withTitle: defaultEditor.rawValue)
            defaultEditorButton.selectItem(at: index)
        } else {
            let index = defaultEditorButton.indexOfItem(withTitle: Constants.none)
            defaultEditorButton.selectItem(at: index)
        }
    }
    
    // MARK: Button Actions
    
//    @IBAction func launchButtonClicked(_ sender: NSButton) {
//        let isLaunch = launchButton.state == .on
//        let launchAtLogin: BoolType = isLaunch ? ._true : ._false
//        CoreManager.shared.launchAtLogin = launchAtLogin
//        SMLoginItemSetEnabled(Constants.launcherAppIdentifier as CFString, isLaunch)
//    }
    
    @IBAction func quickOpenButtonClicked(_ sender: NSButton) {
        let quickOpen: BoolType = quickOpenButton.state == .on ? ._true : ._false
        CoreManager.shared.quickOpen = quickOpen
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.setStatusToggle()
        logw("Quick Open set to \(sender.state.rawValue)")
    }
    
    @IBAction func defaultTerminalButtonClicked(_ sender: NSPopUpButton) {
        let itemTitles = sender.itemTitles
        let index = sender.indexOfSelectedItem
        let title = itemTitles[index]

        if title == Constants.none {
            TerminalManager.shared.removeDefaultTerminal()
        }
        
        if let terminal = TerminalType(rawValue: title) {
            TerminalManager.shared.setDefaultTerminal(terminal)
        }
    }
    
    @IBAction func defaultEditorButtonClicked(_ sender: NSPopUpButton) {
        let itemTitles = sender.itemTitles
        let index = sender.indexOfSelectedItem
        let title = itemTitles[index]
        
        if title == Constants.none {
            EditorManager.shared.removeDefaultEditor()
        }
        
        if let editor = EditorType(rawValue: title) {
            EditorManager.shared.setDefaultEditor(editor)
        }
    }
}
