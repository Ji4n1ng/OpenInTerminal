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
    
    @IBOutlet weak var iTermTextField: NSTextField!
    @IBOutlet weak var iTermWindowButton: NSButton!
    @IBOutlet weak var iTermTabButton: NSButton!
    
    @IBOutlet weak var customMenuTableView: NSTableView!
    @IBOutlet weak var addMenuOptionButton: NSButton!
    var addOptionMenu: NSMenu = NSMenu()
    @IBOutlet weak var applyToToolbarButton: NSButton!
    @IBOutlet weak var applyToContextButton: NSButton!
    
    @IBOutlet weak var noIconButton: NSButton!
    @IBOutlet weak var simpleIconButton: NSButton!
    @IBOutlet weak var originalIconButton: NSButton!
    
    @IBOutlet weak var pathNoButton: NSButton!
    @IBOutlet weak var pathYesButton: NSButton!
    
    private var dragDropType = NSPasteboard.PasteboardType(rawValue: "private.table-row")
    
    var allInstalledAppNames: Set<String> = Set() {
        didSet {
            DispatchQueue.main.async {
                self.refreshSupportedApps()
            }
        }
    }
    var installedSupportedAppNames: [String] = []
        
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
        customMenuTableView.registerForDraggedTypes([dragDropType])
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // fetch installed apps
        DispatchQueue.global(qos: .background).async {
            self.allInstalledAppNames = FinderManager.shared.getAllInstalledApps()
        }
        // get saved custom menu apps
        if let customMenuOptions = DefaultsManager.shared.customMenuOptions {
            self.customMenuOptions = customMenuOptions
        }
        refreshSupportedApps()
        refreshCustomButtons()
        refreshIconTypeOptionState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Refresh UI
    
    func refreshSupportedApps() {
        // get all installed supported apps
        installedSupportedAppNames = SupportedApps.allCases.map(\.name)
            .filter(allInstalledAppNames.contains)
            .sortedIgnoreCase()
        installedApplicationsTextField.stringValue = installedSupportedAppNames.joined(separator: ", ")
        
        // get all not installed supported apps
        let notInstalledSupportedApps = SupportedApps.allCases.map(\.name)
            .filter { !installedSupportedAppNames.contains($0) }
            .sortedIgnoreCase()
        notInstalledApplicationsTextField.stringValue = notInstalledSupportedApps.joined(separator: ", ")
        
        // refresh text field enabled state
        let terminals: [(SupportedApps, NSTextField)] = [
            (.iTerm, iTermTextField)
        ]
        terminals.forEach { terminal, textField in
            let isInstalled = installedSupportedAppNames.contains(terminal.name)
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
        
        // refresh button state
        iTermWindowButton.isEnabled = iTermTextField.isEnabled
        iTermTabButton.isEnabled = iTermTextField.isEnabled
        
        let terminalStates: [(SupportedApps, NSButton, NSButton)] = [
            (.iTerm, iTermWindowButton, iTermTabButton)
        ]
        terminalStates.forEach { terminal, windowButton, tabButton in
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
    
    func refreshCustomButtons() {
        let isApplyToToolbar = DefaultsManager.shared.isCustomMenuApplyToToolbar
        applyToToolbarButton.state = isApplyToToolbar ? .on : .off

        let isApplyToContext = DefaultsManager.shared.isCustomMenuApplyToContext
        applyToContextButton.state = isApplyToContext ? .on : .off
        
        let isPathEscaped = DefaultsManager.shared.isPathEscaped
        if isPathEscaped {
            pathYesButton.state = .on
            pathNoButton.state = .off
        } else {
            pathYesButton.state = .off
            pathNoButton.state = .on
        }
    }
    
    func offIconTypeButtons() {
        noIconButton.state = .off
        simpleIconButton.state = .off
        originalIconButton.state = .off
    }
    
    func refreshIconTypeOptionState() {
        offIconTypeButtons()
        let option = DefaultsManager.shared.customMenuIconOption
        switch option {
        case .no:
            noIconButton.state = .on
        case .simple:
            simpleIconButton.state = .on
        case .original:
            originalIconButton.state = .on
        }
    }
    
    func refreshAddOptionMenu() {
        addOptionMenu.removeAllItems()
        
        // 1. Installed Supported Apps
        let installedSupportedMenu = NSMenu()
        installedSupportedAppNames.forEach {
            let menuItem = NSMenuItem(title: $0,
              action: #selector(selectSupportedApp),
              keyEquivalent: "")
            menuItem.target = self
            menuItem.image = NSImage(named: $0)
            menuItem.image?.size = NSSize(width: 14, height: 14)
            installedSupportedMenu.addItem(menuItem)
        }
        let installedSupportedMenuItem = NSMenuItem()
        installedSupportedMenuItem.title = NSLocalizedString("pref.custom.menu.installed_supported", comment: "Installed Supported Apps")
        addOptionMenu.addItem(installedSupportedMenuItem)
        addOptionMenu.setSubmenu(installedSupportedMenu, for: installedSupportedMenuItem)
        
        // 2. All Supported Apps
        let supportedMenu = NSMenu()
        SupportedApps.allCases.forEach {
            let menuItem = NSMenuItem(title: $0.name,
                                      action: #selector(selectSupportedApp),
                                      keyEquivalent: "")
            menuItem.target = self
            menuItem.image = NSImage(named: $0.name)
            menuItem.image?.size = NSSize(width: 14, height: 14)
            supportedMenu.addItem(menuItem)
        }
        let supportedMenuItem = NSMenuItem()
        supportedMenuItem.title = NSLocalizedString("pref.custom.menu.all_supported", comment: "All Supported Apps")
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
            menuItem.image?.size = NSSize(width: 14, height: 14)
            runningMenu.addItem(menuItem)
            let app = App(name: name, type: .terminal)
            runningApps.append(app)
        }
        let runningMenuItem = NSMenuItem()
        runningMenuItem.title = NSLocalizedString("pref.custom.menu.running_apps", comment: "Running Apps")
        addOptionMenu.addItem(runningMenuItem)
        addOptionMenu.setSubmenu(runningMenu, for: runningMenuItem)
        
        // 4. Manually Select From Finder
        let manuallySelectTitle = NSLocalizedString("pref.custom.menu.manually_select", comment: "Manually Select From Finder")
        let manuallySelectMenuItem = NSMenuItem(title: manuallySelectTitle,
                                                action: #selector(selectManuallySelect),
                                                keyEquivalent: "")
        manuallySelectMenuItem.target = self
        addOptionMenu.addItem(manuallySelectMenuItem)
        
        // 5. Manually Input
        let manuallyInputTitle = NSLocalizedString("pref.custom.menu.manually_input", comment: "Manually Input")
        let manuallyInputMenuItem = NSMenuItem(title: manuallyInputTitle,
                                                action: #selector(selectManuallyInput),
                                                keyEquivalent: "")
        manuallyInputMenuItem.target = self
        addOptionMenu.addItem(manuallyInputMenuItem)
        
    }
    
    // MARK: Button Actions
    
    @IBAction func iTermWindowButtonClicked(_ sender: NSButton) {
        iTermTabButton.state = .off
        DefaultsManager.shared.setNewOption(.iTerm, .window)
    }
    
    @IBAction func iTermTabButtonClicked(_ sender: NSButton) {
        iTermWindowButton.state = .off
        DefaultsManager.shared.setNewOption(.iTerm, .tab)
    }
    
    @IBAction func pathNoButtonClicked(_ sender: NSButton) {
        pathYesButton.state = .off
        DefaultsManager.shared.isPathEscaped = false
    }
    
    @IBAction func pathYesButtonClicked(_ sender: NSButton) {
        pathNoButton.state = .off
        DefaultsManager.shared.isPathEscaped = true
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
    
    @IBAction func noIconButtonClicked(_ sender: NSButton) {
        offIconTypeButtons()
        noIconButton.state = .on
        DefaultsManager.shared.customMenuIconOption = .no
    }
    
    @IBAction func simpleIconButtonClicked(_ sender: NSButton) {
        offIconTypeButtons()
        simpleIconButton.state = .on
        DefaultsManager.shared.customMenuIconOption = .simple
    }
    
    @IBAction func originalIconButtonClicked(_ sender: NSButton) {
        offIconTypeButtons()
        originalIconButton.state = .on
        DefaultsManager.shared.customMenuIconOption = .original
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
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: self.dragDropType)
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
            if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        var oldIndexOffset = 0
        var newIndexOffset = 0
        
        customMenuOptions.move(with: IndexSet(oldIndexes), to: row)

        // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
        // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                // ⬇️
                tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                // ⬆️
                tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }
        tableView.endUpdates()

        return true
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
            if result == NSApplication.ModalResponse.OK {
                if let appPath = openPanel.url?.path,
                   let _ = Bundle(url: openPanel.url!)?.bundleIdentifier {
                    let name = AppManager.getApplicationFileName(from: appPath)
                    self.showCustomInputViewController(name)
                } else {
                    // 对于没有 bundleId 的应用可能是快捷方式, 给予提示
                }
            }
        })
    }
    
    
}
