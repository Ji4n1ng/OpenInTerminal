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

    @IBOutlet weak var launchButton: NSButton!
    @IBOutlet weak var quickToggleButton: NSButton!
    @IBOutlet weak var chooseToggleActionButton: NSPopUpButton!
    @IBOutlet weak var hideStatusItemButton: NSButton!
    @IBOutlet weak var defaultTerminalButton: NSPopUpButton!
    @IBOutlet weak var defaultEditorButton: NSPopUpButton!
    
    lazy var quickToggleTerminalMenuItem: NSMenuItem = {
        return NSMenuItem(title: QuickToggleType.openWithDefaultTerminal.name,
                          action: #selector(quickToggleTerminalClicked),
                          keyEquivalent: "")
    }()
    
    lazy var quickToggleEditorMenuItem: NSMenuItem = {
        return NSMenuItem(title: QuickToggleType.openWithDefaultEditor.name,
                          action: #selector(quickToggleEditorClicked),
                          keyEquivalent: "")
    }()
    
    lazy var quickToggleCopyPathMenuItem: NSMenuItem = {
        return NSMenuItem(title: QuickToggleType.copyPathToClipboard.name,
                          action: #selector(quickToggleCopyPathClicked),
                          keyEquivalent: "")
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initQuickToggleAction()
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
    
    // MARK: Init UI
    
    func initQuickToggleAction() {
        chooseToggleActionButton.removeAllItems()
        [quickToggleTerminalMenuItem, quickToggleEditorMenuItem,
         quickToggleCopyPathMenuItem].forEach {
            $0.target = self
            chooseToggleActionButton.menu?.addItem($0)
        }
    }
    
    // MARK: Refresh UI
    
    func refreshButtonState() {
        let isLaunchAtLogin = CoreManager.shared.launchAtLogin.bool
        launchButton.state = isLaunchAtLogin ? .on : .off
        
        let isHideStatusItem = CoreManager.shared.hideStatusItem.bool
        hideStatusItemButton.state = isHideStatusItem ? .on : .off
        
        let isQuickToggle = CoreManager.shared.quickToggle.bool
        quickToggleButton.state = isQuickToggle ? .on : .off
        chooseToggleActionButton.isEnabled = isQuickToggle
        
        if let quickToggleType = CoreManager.shared.quickToggleType {
            switch quickToggleType {
            case .openWithDefaultTerminal:
                chooseToggleActionButton.select(quickToggleTerminalMenuItem)
            case .openWithDefaultEditor:
                chooseToggleActionButton.select(quickToggleEditorMenuItem)
            case .copyPathToClipboard:
                chooseToggleActionButton.select(quickToggleCopyPathMenuItem)
            }
        }
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
            [.vscode, .atom, .sublime, .vscodium, .bbedit]
        
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
    
    @IBAction func launchButtonClicked(_ sender: NSButton) {
        let isLaunch = launchButton.state == .on
        CoreManager.shared.launchAtLogin.bool = isLaunch
        SMLoginItemSetEnabled(Constants.launcherAppIdentifier as CFString, isLaunch)
    }
    
    @IBAction func hideStatusItemButtonTapped(_ sender: NSButton) {
        let isHide = hideStatusItemButton.state == .on
        CoreManager.shared.hideStatusItem.bool = isHide
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.setStatusItemVisible()
    }
    
    @IBAction func quickToggleButtonClicked(_ sender: NSButton) {
        let isQuickToggle = quickToggleButton.state == .on
        CoreManager.shared.quickToggle.bool = isQuickToggle
        chooseToggleActionButton.isEnabled = isQuickToggle
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.setStatusToggle()
        logw("Quick Toggle set to \(sender.state.rawValue)")
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
    
    @objc func quickToggleTerminalClicked(_ sender: NSMenuItem) {
        CoreManager.shared.quickToggleType = .openWithDefaultTerminal
        chooseToggleActionButton.select(quickToggleTerminalMenuItem)
    }
    
    @objc func quickToggleEditorClicked(_ sender: NSMenuItem) {
        CoreManager.shared.quickToggleType = .openWithDefaultEditor
        chooseToggleActionButton.select(quickToggleEditorMenuItem)
    }
    
    @objc func quickToggleCopyPathClicked(_ sender: NSMenuItem) {
        CoreManager.shared.quickToggleType = .copyPathToClipboard
        chooseToggleActionButton.select(quickToggleCopyPathMenuItem)
    }
}
