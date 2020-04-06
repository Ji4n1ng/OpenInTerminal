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
    
    @IBOutlet weak var customMenuTableView: NSTableView!
    @IBOutlet weak var addMenuOptionButton: NSButton!
    @IBOutlet weak var applyToToolbarButton: NSButton!
    @IBOutlet weak var applyToContextButton: NSButton!
    
    var installedApps = [String]() {
        didSet {
            installedApplicationsTextField.stringValue = installedApps.joined(separator: ", ")
        }
    }
    var customApps = [String]() {
        didSet {
            refreshCustomMenu()
            DefaultsManager.shared.customMenuOptions = customApps.joined(separator: ",")
            customMenuTableView.reloadData()
        }
    }
    var customMenu: NSMenu!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customMenuTableView.dataSource = self
        customMenuTableView.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // get all installed apps
        let installedTerminals = Constants.allTerminals.filter {
            FinderManager.shared.terminalIsInstalled($0)
        }.map {
            $0.rawValue
        }
        let installedEditors = Constants.allEditors.filter {
            FinderManager.shared.editorIsInstalled($0)
        }.map {
            $0.rawValue
        }
        installedApps = (installedTerminals + installedEditors).sortedIgnoreCase()
        
        // get saved custom apps
        let customAppsString = DefaultsManager.shared.customMenuOptions
        customApps = customAppsString.components(separatedBy: ",").filter {
            $0 != ""
        }.sortedIgnoreCase()
        
        refreshNotInstalledAppsTextField()
        refreshTextFieldEnabledState()
        refreshButtonNewOptionState()
        refreshButtonState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Refresh UI
    
    func refreshNotInstalledAppsTextField() {
        let notInstalledTerminals = Constants.allTerminals.filter {
            !FinderManager.shared.terminalIsInstalled($0)
        }.map {
            $0.rawValue
        }
        let notInstalledEditors = Constants.allEditors.filter {
            !FinderManager.shared.editorIsInstalled($0)
        }.map {
            $0.rawValue
        }
        let notInstalledApps = (notInstalledTerminals + notInstalledEditors).sortedIgnoreCase()
        notInstalledApplicationsTextField.stringValue = notInstalledApps.joined(separator: ", ")
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
    
    func refreshButtonState() {
        terminalWindowButton.isEnabled = terminalTextField.isEnabled
        terminalTabButton.isEnabled = terminalTextField.isEnabled

        iTermWindowButton.isEnabled = iTermTextField.isEnabled
        iTermTabButton.isEnabled = iTermTextField.isEnabled
        
        let isApplyToToolbar = DefaultsManager.shared.isApplyToToolbar.bool
        applyToToolbarButton.state = isApplyToToolbar ? .on : .off
        
        let isApplyToContext = DefaultsManager.shared.isApplyToContext.bool
        applyToContextButton.state = isApplyToContext ? .on : .off
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
    
    func refreshCustomMenu() {
        let menuApps = installedApps.filter {
            !customApps.contains($0)
        }
        
        let menu = NSMenu(title: "")
        menuApps.forEach {
            let menuItem = NSMenuItem(title: $0,
                action: #selector(selectMenuApp),
                keyEquivalent: "")
            menuItem.target = self
            menu.addItem(menuItem)
        }
        customMenu = menu
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
    
    @IBAction func addMenuOptionButtonClicked(_ sender: NSButton) {
        let point = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
        customMenu.popUp(positioning: nil, at: point, in: sender.superview)
    }
    
    @objc func selectMenuApp(_ sender: NSMenuItem) {
        let appName = sender.title
        customApps.append(appName)
        customApps.sortIgnoreCase()
    }
    
    @IBAction func removeMenuOptionButtonClicked(_ sender: NSButton) {
        let row = customMenuTableView.selectedRow
        guard row >= 0 else { return }
        
        if let view = customMenuTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView {
            let appName = view.textField?.stringValue ?? ""
            if customApps.contains(appName) {
                customApps.remove(element: appName)
            }
        }
    }
    
    @IBAction func applyToToolbarButtonClicked(_ sender: NSButton) {
        let isApplyTo = applyToToolbarButton.state == .on
        DefaultsManager.shared.isApplyToToolbar.bool = isApplyTo
    }
    
    @IBAction func applyToContextButtonClicked(_ sender: NSButton) {
        let isApplyTo = applyToContextButton.state == .on
        DefaultsManager.shared.isApplyToContext.bool = isApplyTo
    }
}

extension FinderExtensionPreferencesViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return customApps.count
    }

}

extension FinderExtensionPreferencesViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: Constants.CellIdentifier.customMenuCell, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = customApps[row]
            return cell
        }
        return nil
    }
}
