//
//  AppDelegate.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore
import ShortcutRecorder

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBOutlet weak var statusBarMenu: NSMenu!
    
    var terminalShortcutAction: ShortcutAction?
    var editorShortcutAction: ShortcutAction?
    var copyPathShortcutAction: ShortcutAction?
    var areShortcutsRegistered = false
    
    // MARK: - Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        DefaultsManager.shared.firstSetup()
        addObserver()
        terminateOpenInTerminalHelper()
        setStatusItemIcon()
        setStatusItemVisible()
        setStatusToggle()
        
        logw("")
        logw("App launched")
        logw("macOS \(ProcessInfo().operatingSystemVersionString)")
        logw("OpenInTerminal Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
        
        // bind global shortcuts
        bindShortcuts()
        
        do {
            // check scripts and install them if needed
            try checkScripts()
        } catch {
            logw(error.localizedDescription)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem)
        
        removeObserver()
        logw("App terminated")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showPreferencesWindow()
        }
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.Key.onlyActivateShortcutsInFinder {
            updateShortcutRegistration()
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
}

extension AppDelegate {
    
    // MARK: - Status Bar Item
    
    func setStatusItemIcon() {
        let icon = NSImage(assetIdentifier: .StatusBarIcon)
        icon.isTemplate = true // Support Dark Mode
        DispatchQueue.main.async {
            self.statusItem.button?.image = icon
        }
    }
    
    func setStatusItemVisible() {
        let isHideStatusItem = DefaultsManager.shared.isHideStatusItem
        statusItem.isVisible = !isHideStatusItem
    }
    
    func setStatusToggle() {
        let isQuickToogle = DefaultsManager.shared.isQuickToggle
        if isQuickToogle {
            statusItem.menu = nil
            if let button = statusItem.button {
                button.action = #selector(statusBarButtonClicked)
                button.sendAction(on: [.leftMouseUp, .leftMouseDown,
                                       .rightMouseUp, .rightMouseDown])
            }
        } else {
            statusItem.menu = statusBarMenu
        }
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseDown || event.type == .rightMouseUp
            || event.modifierFlags.contains(.control)
        {
            statusItem.menu = statusBarMenu
            statusItem.button?.performClick(self)
            statusItem.menu = nil
        } else if event.type == .leftMouseUp {
            if let quickToggleType = DefaultsManager.shared.quickToggleType {
                switch quickToggleType {
                case .openWithDefaultTerminal:
                    openDefaultTerminal()
                case .openWithDefaultEditor:
                    openDefaultEditor()
                case .copyPathToClipboard:
                    copyPathToClipboard()
                }
            }
        }
    }
    
    func terminateOpenInTerminalHelper() {
        let isRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == Constants.Id.LauncherApp
        }
        
        if isRunning {
            LaunchNotifier.postNotification(.terminateApp, object: Bundle.main.bundleIdentifier!)
        }
    }
    
    func showPreferencesWindow() {
        NSApp.setActivationPolicy(.regular) // show icon in Dock
        let preferencesWindowController: PreferencesWindowController = {
            let storyboard = NSStoryboard(storyboardIdentifier: .Preferences)
            let windowController = storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
            return windowController
        }()
        preferencesWindowController.window?.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindowController.showWindow(self)
        preferencesWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    // MARK: - Notification
    
    func addObserver() {
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openDefaultTerminal),
                                 notification: .openDefaultTerminal)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openDefaultEditor),
                                 notification: .openDefaultEditor)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(copyPathToClipboard),
                                 notification: .copyPathToClipboard)
        
        Defaults.addObserver(self, 
                             forKeyPath: Constants.Key.onlyActivateShortcutsInFinder, 
                             options: .new, 
                             context: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, 
                                                          selector: #selector(activeAppDidChange), 
                                                          name: NSWorkspace.didActivateApplicationNotification, 
                                                          object: nil)
    }
    
    func removeObserver() {
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultEditor)
        OpenNotifier.removeObserver(observer: self, notification: .copyPathToClipboard)
        
        Defaults.removeObserver(self, forKeyPath: Constants.Key.onlyActivateShortcutsInFinder)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    @objc func activeAppDidChange(_ notification: Notification) {
        updateShortcutRegistration()
    }
    
    // MARK: Notification Actions
    
    @objc func openDefaultTerminal() {
        var defaultTerminal: App
        if let terminal = DefaultsManager.shared.defaultTerminal {
            defaultTerminal = terminal
        } else {
            // if there is no defualt terminal, then pick one
            guard let selectedTerminal = AppManager.shared.pickTerminalAlert() else {
                return
            }
            DefaultsManager.shared.defaultTerminal = selectedTerminal
            defaultTerminal = selectedTerminal
        }
        do {
            try defaultTerminal.openOutsideSandbox()
        } catch {
            logw("\(error)")
        }
    }
    
    @objc func openDefaultEditor() {
        var defaultEditor: App
        if let editor = DefaultsManager.shared.defaultEditor {
            defaultEditor = editor
        } else {
            // if there is no defualt editor, then pick one
            guard let selectedEditor = AppManager.shared.pickEditorAlert() else {
                return
            }
            DefaultsManager.shared.defaultEditor = selectedEditor
            defaultEditor = selectedEditor
        }
        do {
            try defaultEditor.openOutsideSandbox()
        } catch {
            logw("\(error)")
        }
    }
    
    @objc func copyPathToClipboard() {
        do {
            var urls = try FinderManager.shared.getFullUrlsToFrontFinderWindowOrSelectedFile()
            if urls.count == 0 {
                // No Finder window and no file selected.
                let homePath = NSHomeDirectory()
                guard let homeUrl = URL(string: homePath) else { return }
                urls.append(homeUrl.appendingPathComponent("Desktop"))
            }
            let paths = urls.map { $0.path }
            let pathString = paths.joined(separator: "\n")
            // Set string
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(pathString, forType: .string)
        } catch {
            logw(error.localizedDescription)
        }
    }
    
//    func writeimage() {
//        SupportedApps.allCases.forEach {
//            let path = "/Applications/\($0.name).app"
//            guard FileManager.default.fileExists(atPath: path) else { return }
//
//            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
//            let destinationURL = desktopURL.appendingPathComponent("\($0.name).png")
//            let icon = AppManager.getApplicationIcon(from: path)
//
//            guard let tiffRepresentation = icon.tiffRepresentation,
//                  let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return }
//            let pngData = bitmapImage.representation(using: .png, properties: [:])
//            do {
//                try pngData?.write(to: destinationURL, options: .atomic)
//            } catch {
//                print("\($0.name)")
//                print(error)
//            }
//        }
//    }
}

extension AppDelegate {
    
    // MARK: - Global Shortcuts
    
    func bindShortcuts() {
        terminalShortcutAction = ShortcutAction(keyPath: Constants.Key.defaultTerminalShortcut, of: Defaults) { _ in
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.openDefaultTerminal()
            return true
        }
        
        editorShortcutAction = ShortcutAction(keyPath: Constants.Key.defaultEditorShortcut, of: Defaults) { _ in
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.openDefaultEditor()
            return true
        }
        
        copyPathShortcutAction = ShortcutAction(keyPath: Constants.Key.copyPathShortcut, of: Defaults) { _ in
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.copyPathToClipboard()
            return true
        }
        
        updateShortcutRegistration()
    }
    
    func updateShortcutRegistration() {
        let shouldRegister: Bool
        if DefaultsManager.shared.shouldOnlyActivateShortcutsInFinder {
            shouldRegister = NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.apple.finder"
        } else {
            shouldRegister = true
        }
        
        guard shouldRegister != areShortcutsRegistered else { return }
        
        if shouldRegister {
            if let action = terminalShortcutAction, action.shortcut != nil { GlobalShortcutMonitor.shared.addAction(action, forKeyEvent: .down) }
            if let action = editorShortcutAction, action.shortcut != nil { GlobalShortcutMonitor.shared.addAction(action, forKeyEvent: .down) }
            if let action = copyPathShortcutAction, action.shortcut != nil { GlobalShortcutMonitor.shared.addAction(action, forKeyEvent: .down) }
        } else {
            if let action = terminalShortcutAction, action.shortcut != nil { GlobalShortcutMonitor.shared.removeAction(action, forKeyEvent: .down) }
            if let action = editorShortcutAction, action.shortcut != nil { GlobalShortcutMonitor.shared.removeAction(action, forKeyEvent: .down) }
            if let action = copyPathShortcutAction, action.shortcut != nil { GlobalShortcutMonitor.shared.removeAction(action, forKeyEvent: .down) }
        }
        
        areShortcutsRegistered = shouldRegister
    }
}

extension AppDelegate: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // hide icon in Dock
    }
}
