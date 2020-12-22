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
    
    @IBOutlet weak var customAppTableView: NSTableView!
    @IBOutlet weak var addAppButton: NSButton!
    @IBOutlet weak var customMenuTableView: NSTableView!
    @IBOutlet weak var addMenuOptionButton: NSButton!
    @IBOutlet weak var applyToToolbarButton: NSButton!
    @IBOutlet weak var applyToContextButton: NSButton!
    
    var allInstalledApps: Set<String> = Set()
    
    var installedSupportedApps: Set<String> = Set() {
        didSet {
            let _installedApps = Array(installedSupportedApps).sortedIgnoreCase()
            installedApplicationsTextField.stringValue = _installedApps.joined(separator: ", ")
        }
    }
    var notInstalledSupportedApps: Set<String> = Set() {
        didSet {
            let _notInstalledApps = Array(notInstalledSupportedApps).sortedIgnoreCase()
            notInstalledApplicationsTextField.stringValue = _notInstalledApps.joined(separator: ", ")
        }
    }
    var customApps = [App]() {
        didSet {
            
        }
    }
    var customMenuOptions = [App]() {
        didSet {
//            refreshCustomMenu()
//            DefaultsManager.shared.customApps = customApps
            customMenuTableView.reloadData()
        }
    }
    var customMenu: NSMenu!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customAppTableView.dataSource = self
        customAppTableView.delegate = self
        customMenuTableView.dataSource = self
        customMenuTableView.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // get all installed apps
        allInstalledApps = FinderManager.shared.getAllInstalledApps()
        
        // get all installed supported apps
        let installedTerminals = SupportedApps.terminals.filter {
            allInstalledApps.contains($0.name)
        }.map {
            $0.shortName
        }
        let installedEditors = SupportedApps.editors.filter {
            allInstalledApps.contains($0.name)
        }.map {
            $0.shortName
        }
        let installedApps = installedTerminals + installedEditors
        installedSupportedApps = Set(installedApps)

        // get all not installed supported apps
        let allTerminals = SupportedApps.terminals.map {
            $0.name
        }
        let allEditors = SupportedApps.editors.map {
            $0.name
        }
        let allApps = allTerminals + allEditors
        let notInstalledApps = allApps.filter {
            !installedApps.contains($0)
        }
        notInstalledSupportedApps = Set(notInstalledApps)
        
        // get saved custom apps
        if let customApps = DefaultsManager.shared.customApps {
            self.customApps = customApps
        }
        
        // get saved custom menu options
        if let customMenuOptions = DefaultsManager.shared.customMenuOptions {
            self.customMenuOptions = customMenuOptions
        }
        
        refreshTextFieldEnabledState()
        refreshButtonNewOptionState()
        refreshButtonState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Refresh UI
    
    func refreshTextFieldEnabledState() {
        let terminals: [(SupportedApps, NSTextField)] =
            [(.terminal, terminalTextField),
             (.iTerm, iTermTextField)]

        terminals.forEach { terminal, textField in
            let isInstalled = installedSupportedApps.contains(terminal.name)
            textField.isEnabled = isInstalled
            if isInstalled {
                textField.textColor = .labelColor
                textField.stringValue = "\(terminal.name)"
            } else {
                textField.textColor = .secondaryLabelColor
                let notInstalledString = NSLocalizedString("pref.toolbar.not_installed", comment: "Not Installed")
                textField.stringValue = "\(terminal.name) (\(notInstalledString))"
            }
        }
    }
    
    func refreshButtonState() {
        terminalWindowButton.isEnabled = terminalTextField.isEnabled
        terminalTabButton.isEnabled = terminalTextField.isEnabled

        iTermWindowButton.isEnabled = iTermTextField.isEnabled
        iTermTabButton.isEnabled = iTermTextField.isEnabled

        let isApplyToToolbar = DefaultsManager.shared.isCustomMenuApplyToToolbar
        applyToToolbarButton.state = isApplyToToolbar ? .on : .off

        let isApplyToContext = DefaultsManager.shared.isCustomMenuApplyToContext
        applyToContextButton.state = isApplyToContext ? .on : .off
    }
    
    func refreshButtonNewOptionState() {
        let terminals: [(SupportedApps, NSButton, NSButton)] =
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

//    func refreshCustomMenu() {
//        let menuApps = installedSupportedApps.filter {
//            !customApps.contains($0)
//        }
//        let sortedmenuApps = Array(menuApps).sortedIgnoreCase()
//        let menu = NSMenu(title: "")
//        sortedmenuApps.forEach {
//            let menuItem = NSMenuItem(title: $0,
//                action: #selector(selectMenuApp),
//                keyEquivalent: "")
//            menuItem.target = self
//            menu.addItem(menuItem)
//        }
//        customMenu = menu
//    }
    
    // MARK: Button Actions
    
    @IBAction func terminalWindowButtonClicked(_ sender: NSButton) {
        terminalTabButton.state = .off
        DefaultsManager.shared.setNewOption(.terminal, .window)
    }
    
    @IBAction func terminalTabButtonClicked(_ sender: NSButton) {
        terminalWindowButton.state = .off
        DefaultsManager.shared.setNewOption(.terminal, .tab)
    }
    
    @IBAction func iTermWindowButtonClicked(_ sender: NSButton) {
        iTermTabButton.state = .off
        DefaultsManager.shared.setNewOption(.iTerm, .window)
    }
    
    @IBAction func iTermTabButtonClicked(_ sender: NSButton) {
        iTermWindowButton.state = .off
        DefaultsManager.shared.setNewOption(.iTerm, .tab)
    }
    
    @IBAction func addMenuOptionButtonClicked(_ sender: NSButton) {
        let point = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
        customMenu.popUp(positioning: nil, at: point, in: sender.superview)
    }
    
    @objc func selectMenuApp(_ sender: NSMenuItem) {
//        let appName = sender.title
//        customApps.append(appName)
//        customApps.sortIgnoreCase()
    }
    
    @IBAction func removeMenuOptionButtonClicked(_ sender: NSButton) {
//        let row = customMenuTableView.selectedRow
//        guard row >= 0 else { return }
//
//        if let view = customMenuTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView {
//            let appName = view.textField?.stringValue ?? ""
//            if customApps.contains(appName) {
//                customApps.remove(element: appName)
//            }
//        }
    }
    
    @IBAction func applyToToolbarButtonClicked(_ sender: NSButton) {
        let isApplyTo = applyToToolbarButton.state == .on
        DefaultsManager.shared.isCustomMenuApplyToToolbar = isApplyTo
    }
    
    @IBAction func applyToContextButtonClicked(_ sender: NSButton) {
        let isApplyTo = applyToContextButton.state == .on
        DefaultsManager.shared.isCustomMenuApplyToContext = isApplyTo
    }
}

extension FinderExtensionPreferencesViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == customAppTableView {
            return customApps.count
        } else if tableView == customMenuTableView {
            return customMenuOptions.count
        } else {
            return 0
        }
    }

}

extension FinderExtensionPreferencesViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
//        if let cell = tableView.makeView(withIdentifier: Constants.CellIdentifier.customMenuCell, owner: nil) as? NSTableCellView {
//            cell.textField?.stringValue = customApps[row]
//            return cell
//        }
        return nil
    }
}
