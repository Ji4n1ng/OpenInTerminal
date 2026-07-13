//
//  FinderSync.swift
//  OpenInTerminalFinderExtension
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Cameron Ingham. All rights reserved.
//

import Cocoa
import FinderSync
import OpenInTerminalCore
import Carbon

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [.skipHiddenVolumes]) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }

    override var toolbarItemName: String {
        return NSLocalizedString("toolbar.item_name",
                                 comment: "Open in Terminal")
    }
    
    override var toolbarItemToolTip: String {
        return NSLocalizedString("toolbar.item_tooltip",
                                 comment: "Open current directory in Terminal.")
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "Icon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        var menu = NSMenu(title: "")
        
        switch menuKind {

        case .contextualMenuForContainer,
             .contextualMenuForItems:
            // need to hide or not
            let isHideContextMenuItems = DefaultsManager.shared.isHideContextMenuItems
            guard !isHideContextMenuItems else { return NSMenu() }

            // the submenu grouping only applies to the Finder context menu
            let useSubmenu = DefaultsManager.shared.isContextMenuUseSubmenu

            // show custom menu or default
            let isCustomMenuApplyToContext = DefaultsManager.shared.isCustomMenuApplyToContext
            if isCustomMenuApplyToContext {
                menu = createCustomMenu(useSubmenu: useSubmenu)
            } else {
                menu = createDefaultMenu(useSubmenu: useSubmenu)
            }

        case .toolbarItemMenu:
            // the toolbar menu never groups items into a submenu
            let isCustomMenuApplyToToolbar = DefaultsManager.shared.isCustomMenuApplyToToolbar
            if isCustomMenuApplyToToolbar {
                menu = createCustomMenu(useSubmenu: false)
            } else {
                menu = createDefaultMenu(useSubmenu: false)
            }
            
        default:
            break
        }
        
        return menu
    }
    
    var scriptPath: URL? {
        return try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    func fileScriptPath(fileName: String) -> URL? {
        return scriptPath?
            .appendingPathComponent(fileName)
            .appendingPathExtension("scpt")
    }
    
    var copyPathItem: NSMenuItem {
        get {
            let copyPathItem = NSMenuItem(title: NSLocalizedString("menu.copy_path_to_clipboard",
                                                                   comment: "Copy path to Clipboard"),
                                                action: #selector(copyPathToClipboard),
                                                keyEquivalent: "")
            if DefaultsManager.shared.customMenuIconOption == .simple {
                let copyPathIcon = NSImage(named: "context_menu_icon_path")
                copyPathItem.image = copyPathIcon
            } else if DefaultsManager.shared.customMenuIconOption == .original {
                let copyPathIcon = NSImage(named: "context_menu_icon_color_path")
                copyPathItem.image = copyPathIcon
            }
            return copyPathItem
        }
    }
    
    /// Wraps the given items into a single "Open in..." submenu.
    func makeSubmenuItem(with itemsMenu: NSMenu) -> NSMenuItem {
        let submenuItem = NSMenuItem(title: NSLocalizedString("menu.submenu_title",
                                                              comment: "Open in..."),
                                     action: nil,
                                     keyEquivalent: "")
        submenuItem.submenu = itemsMenu
        return submenuItem
    }

    func createDefaultMenu(useSubmenu: Bool) -> NSMenu {
        let menu = NSMenu(title: "")

        // when submenu grouping is enabled, add the items into a separate
        // menu that will be attached under a single top level item
        let itemsMenu = useSubmenu ? NSMenu(title: "") : menu

        guard let terminal = DefaultsManager.shared.defaultTerminal else { return menu }
        let terminalTitle = terminal.name
        let openInTerminalItem = NSMenuItem(title: terminalTitle,
                                            action: #selector(openDefaultTerminal),
                                            keyEquivalent: "")
        let terminalIcon = DefaultsManager.shared.getAppIcon(terminal)
        openInTerminalItem.image = terminalIcon
        itemsMenu.addItem(openInTerminalItem)

        guard let editor = DefaultsManager.shared.defaultEditor else { return menu }
        let editorTitle = editor.name
        let openInEditorItem = NSMenuItem(title: editorTitle,
                                            action: #selector(openDefaultEditor),
                                            keyEquivalent: "")
        let editorIcon = DefaultsManager.shared.getAppIcon(editor)
        openInEditorItem.image = editorIcon
        itemsMenu.addItem(openInEditorItem)

        // add "Copy Path"
        itemsMenu.addItem(self.copyPathItem)

        // attach the items menu under a single top level item when needed
        if useSubmenu {
            menu.addItem(makeSubmenuItem(with: itemsMenu))
        }

        return menu
    }

    func createCustomMenu(useSubmenu: Bool) -> NSMenu {
        let menu = NSMenu(title: "")

        // get saved custom apps
        guard let customApps = DefaultsManager.shared.customMenuOptions else {
            return menu
        }

        // when submenu grouping is enabled, add the items into a separate
        // menu that will be attached under a single top level item
        let itemsMenu = useSubmenu ? NSMenu(title: "") : menu

        customApps.forEach { app in
            let itemTitle = app.name
            let menuItem = NSMenuItem(title: itemTitle,
                                      action: #selector(customMenuItemClicked),
                                      keyEquivalent: "")
            let appIcon = DefaultsManager.shared.getAppIcon(app)
            menuItem.image = appIcon
            itemsMenu.addItem(menuItem)
        }

        // add "Copy Path"
        itemsMenu.addItem(self.copyPathItem)

        // attach the items menu under a single top level item when needed
        if useSubmenu {
            menu.addItem(makeSubmenuItem(with: itemsMenu))
        }

        return menu
    }

    // MARK: - Actions
    
    func getSelectedPathsFromFinder() -> [URL] {
        var urls = [URL]()
        if let items = FIFinderSyncController.default().selectedItemURLs(), items.count > 0 {
            items.forEach {
                urls.append($0)
            }
        } else if let url = FIFinderSyncController.default().targetedURL() {
            urls.append(url)
        }
        return urls
    }
    
    func open(_ app: App) {
        let urls = getSelectedPathsFromFinder()
        do {
            try app.openInSandbox(urls)
        } catch {
            logw("Failed to open \(app.name) with \(urls)")
        }
    }
    
//    func openTerminal(_ terminal: TerminalType) {
//        var scriptPath: URL
//        if terminal == .terminal,
//            let newOption = DefaultsManager.shared.getNewOption(.terminal),
//            newOption == .tab {
//            guard let fileScriptPath = fileScriptPath(fileName: terminal.rawValue + "-tab") else { return }
//            scriptPath = fileScriptPath
//        } else {
//            guard let fileScriptPath = fileScriptPath(fileName: terminal.rawValue) else { return }
//            scriptPath = fileScriptPath
//        }
//        guard FileManager.default.fileExists(atPath: scriptPath.path) else { return }
//        guard let script = try? NSUserAppleScriptTask(url: scriptPath) else { return }
//        script.execute(completionHandler: nil)
//    }
//
//    func openEditor(_ editor: EditorType) {
//        if (editor == .vscode) {
//            var path = "open -a Visual\\ Studio\\ Code"
//            if let items = FIFinderSyncController.default().selectedItemURLs(), items.count > 0 {
//                items.forEach { (url) in
//                    path += " \(url.path.specialCharEscaped2)"
//                }
//            } else if let url = FIFinderSyncController.default().targetedURL() {
//                path = url.path.specialCharEscaped2
//            } else {
//                return
//            }
//            let appleScript = try! NSUserAppleScriptTask(url: fileScriptPath(fileName: editor.rawValue)!)
//            appleScript.execute(withAppleEvent: getScriptEvent(functionName: "openVSCode", path)) { (appleEvent, error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//        } else {
//            guard let scriptPath = fileScriptPath(fileName: editor.rawValue) else { return }
//            guard FileManager.default.fileExists(atPath: scriptPath.path) else { return }
//            guard let script = try? NSUserAppleScriptTask(url: scriptPath) else { return }
//            script.execute(completionHandler: nil)
//        }
//    }
    
    // MARK: - Menu Actions
    
    @objc func openDefaultTerminal() {
        guard let terminal = DefaultsManager.shared.defaultTerminal else { return }
        open(terminal)
    }
    
    @objc func openDefaultEditor() {
        guard let editor = DefaultsManager.shared.defaultEditor else { return }
        open(editor)
    }
    
    @objc func customMenuItemClicked(_ sender: NSMenuItem) {
        guard let customApps = DefaultsManager.shared.customMenuOptions else { return }
        let appName = sender.title
        for app in customApps {
            if app.name == appName {
                open(app)
                break
            }
        }
    }
    
    @objc func copyPathToClipboard() {
        let urls = getSelectedPathsFromFinder()
        var paths = urls.map { $0.path }
        if DefaultsManager.shared.isPathEscaped {
            paths = paths.map { $0.specialCharEscaped() }
        }
        let pathString = paths.joined(separator: "\n")
        // Set string
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(pathString, forType: .string)
    }
    
}

fileprivate extension String {
    
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
    
}
