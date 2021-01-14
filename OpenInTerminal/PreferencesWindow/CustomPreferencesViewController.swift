//
//  CustomPreferencesViewController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore

class CustomPreferencesViewController: PreferencesViewController {
    
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
    var addOptionMenu: NSMenu = NSMenu()
    @IBOutlet weak var applyToToolbarButton: NSButton!
    @IBOutlet weak var applyToContextButton: NSButton!
    
    var allInstalledAppNames: Set<String> = Set()
    var installedSupportedApps = [App]() {
        didSet {
            let _installedApps = installedSupportedApps.map {
                $0.name
            }.sortedIgnoreCase()
            installedApplicationsTextField.stringValue = _installedApps.joined(separator: ", ")
        }
    }
    var notInstalledSupportedApps = [App]() {
        didSet {
            let _notInstalledApps = notInstalledSupportedApps.map {
                $0.name
            }.sortedIgnoreCase()
            notInstalledApplicationsTextField.stringValue = _notInstalledApps.joined(separator: ", ")
        }
    }
    var customMenuOptions = [App]() {
        didSet {
            customMenuTableView.reloadData()
            if customMenuOptions != DefaultsManager.shared.customMenuOptions {
                DefaultsManager.shared.customMenuOptions = customMenuOptions
            }
        }
    }
    var runningApps = [App]()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customMenuTableView.dataSource = self
        customMenuTableView.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // get all installed apps
        allInstalledAppNames = FinderManager.shared.getAllInstalledApps()
        
        // get all installed supported apps
        let installedTerminals = SupportedApps.terminals.filter {
            allInstalledAppNames.contains($0.name)
        }.map {
            $0.app
        }
        let installedEditors = SupportedApps.editors.filter {
            allInstalledAppNames.contains($0.name)
        }.map {
            $0.app
        }
        installedSupportedApps = (installedTerminals + installedEditors).sortedIgnoreCase()

        // get all not installed supported apps
        let allTerminals = SupportedApps.terminals.map {
            $0.app
        }
        let allEditors = SupportedApps.editors.map {
            $0.app
        }
        let allApps = allTerminals + allEditors
        notInstalledSupportedApps = allApps.filter {
            !installedSupportedApps.contains($0)
        }.sortedIgnoreCase()
        
        // get saved custom menu apps
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
            let isInstalled = installedSupportedApps.contains(terminal.app)
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
    
    func refreshAddOptionMenu() {
        addOptionMenu.removeAllItems()
        
        // 1. Installed Supported Apps
        let installedSupportedMenu = NSMenu()
        installedSupportedApps.forEach {
            let menuItem = NSMenuItem(title: $0.name,
              action: #selector(selectSupportedApp),
              keyEquivalent: "")
            menuItem.target = self
            installedSupportedMenu.addItem(menuItem)
        }
        let installedSupportedMenuItem = NSMenuItem()
        installedSupportedMenuItem.title = "Installed Supported Apps"
        addOptionMenu.addItem(installedSupportedMenuItem)
        addOptionMenu.setSubmenu(installedSupportedMenu, for: installedSupportedMenuItem)
        
        // 2. All Supported Apps
        let supportedMenu = NSMenu()
        SupportedApps.allCases.forEach {
            let menuItem = NSMenuItem(title: $0.name,
                                      action: #selector(selectSupportedApp),
                                      keyEquivalent: "")
            menuItem.target = self
            supportedMenu.addItem(menuItem)
        }
        let supportedMenuItem = NSMenuItem()
        supportedMenuItem.title = "All Supported Apps"
        addOptionMenu.addItem(supportedMenuItem)
        addOptionMenu.setSubmenu(supportedMenu, for: supportedMenuItem)
        
        // 3. Running Applications
        let runningMenu = NSMenu()
        let runningApplications = NSWorkspace.shared.runningApplications
        runningApps.removeAll()
        for runningApp in runningApplications {
            guard runningApp.activationPolicy == .regular else { continue }
            guard let bundleURL = runningApp.bundleURL else { continue }
            let icon = AppManager.getApplicationIcon(from: bundleURL)
            let name = AppManager.getApplicationFileName(from: bundleURL.path)
            let menuItem = NSMenuItem(title: name,
                                      action: #selector(selectRunningApp),
                                      keyEquivalent: "")
            menuItem.target = self
            menuItem.image = icon
            runningMenu.addItem(menuItem)
            let app = App(name: name, type: .terminal)
            runningApps.append(app)
        }
        let runningMenuItem = NSMenuItem()
        runningMenuItem.title = "Running Apps"
        addOptionMenu.addItem(runningMenuItem)
        addOptionMenu.setSubmenu(runningMenu, for: runningMenuItem)
        
        // 4. Manually Select From Finder
        let manuallySelectMenuItem = NSMenuItem(title: "Manually Select From Finder",
                                                action: #selector(selectManuallySelect),
                                                keyEquivalent: "")
        manuallySelectMenuItem.target = self
        addOptionMenu.addItem(manuallySelectMenuItem)
        
        // 5. Manually Input
        let manuallyInputMenuItem = NSMenuItem(title: "Manually Input",
                                                action: #selector(selectManuallyInput),
                                                keyEquivalent: "")
        manuallyInputMenuItem.target = self
        addOptionMenu.addItem(manuallyInputMenuItem)
        
//        SupportedApps.allCases.forEach {
//            let menuItem = NSMenuItem(title: $0.name,
//              action: #selector(selectAddOptionApp),
//              keyEquivalent: "")
//            menuItem.target = self
//            supportedMenu.addItem(menuItem)
//        }
//        let supportedMenuItem = NSMenuItem()
//        supportedMenuItem.title = "All Supported Apps"
//        addOptionMenu.addItem(supportedMenuItem)
//        addOptionMenu.setSubmenu(supportedMenu, for: supportedMenuItem)
        
//        addOptionApps = (installedSupportedApps + customApps).filter {
//            !customMenuOptions.contains($0)
//        }
//        let sorted = addOptionApps.map {
//            $0.name
//        }.sortedIgnoreCase()
//        sorted.forEach {
//            let menuItem = NSMenuItem(title: $0,
//                action: #selector(selectAddOptionApp),
//                keyEquivalent: "")
//            menuItem.target = self
//            addOptionMenu.addItem(menuItem)
//        }
    }
    
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
        refreshAddOptionMenu()
        let point = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
        addOptionMenu.popUp(positioning: nil, at: point, in: sender.superview)
    }
    
    @objc func selectSupportedApp(_ sender: NSMenuItem) {
        let selectedAppName = sender.title
        SupportedApps.allCases.forEach {
            if $0.name == selectedAppName {
                customMenuOptions.append($0.app)
            }
        }
    }
    
    @objc func selectRunningApp(_ sender: NSMenuItem) {
        let selectedAppName = sender.title
        runningApps.forEach {
            if $0.name == selectedAppName {
                showCustomInputViewController($0.name)
            }
        }
    }
    
    @objc func selectManuallySelect(_ sender: NSMenuItem) {
        openFileSelectPanel()
    }
    
    @objc func selectManuallyInput(_ sender: NSMenuItem) {
        showCustomInputViewController()
    }
    
    func addCustomApp(_ app: App) {
        customMenuOptions.append(app)
        // TODO: generate script
    }
    
    @IBAction func removeMenuOptionButtonClicked(_ sender: NSButton) {
        let row = customMenuTableView.selectedRow
        guard row >= 0 else { return }

        if let view = customMenuTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView {
            let appName = view.textField?.stringValue ?? ""
            for customApp in customMenuOptions {
                if customApp.name == appName {
                    customMenuOptions.remove(element: customApp)
                }
            }
        }
    }
    
    @IBAction func applyToToolbarButtonClicked(_ sender: NSButton) {
        let isApplyTo = applyToToolbarButton.state == .on
        DefaultsManager.shared.isCustomMenuApplyToToolbar = isApplyTo
    }
    
    @IBAction func applyToContextButtonClicked(_ sender: NSButton) {
        let isApplyTo = applyToContextButton.state == .on
        DefaultsManager.shared.isCustomMenuApplyToContext = isApplyTo
    }
    
    func showCustomInputViewController(_ appName: String = "") {
        guard let customInputViewController = Constants.PreferencesStoryboard.instantiateController(withIdentifier: Constants.Id.CustomInputViewController) as? CustomInputViewController else {
            return
        }
        if appName != "" {
            customInputViewController.appName = appName
        }
        self.presentAsSheet(customInputViewController)
    }
}

extension CustomPreferencesViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == customMenuTableView {
            return customMenuOptions.count
        } else {
            return 0
        }
    }

}

extension CustomPreferencesViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: Constants.Id.CustomMenuCell, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = customMenuOptions[row].name
            return cell
        }
        return nil
    }
    
}

extension CustomPreferencesViewController: NSMenuDelegate {

    func openFileSelectPanel() {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first!
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["app", "App", "APP"]
        openPanel.beginSheetModal(for: view.window!, completionHandler: {
            result in
            if result.rawValue == NSFileHandlingPanelOKButton && result == NSApplication.ModalResponse.OK {
                if let appPath = openPanel.url?.path,
                   let appBundleId = Bundle(url: openPanel.url!)?.bundleIdentifier {
                    print("appPath: \(appPath)")
                    print("appBundleId: \(appBundleId)")
                    let name = AppManager.getApplicationFileName(from: appPath)
                    self.showCustomInputViewController(name)
                } else {
                    // 对于没有 bundleId 的应用可能是快捷方式, 给予提示
                }
            }
        })
    }
    
    
}
