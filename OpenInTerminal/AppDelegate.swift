//
//  AppDelegate.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBOutlet weak var statusBarMenu: NSMenu!
    
    lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(storyboardIdentifier: .Preferences)
        return storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
    }()
    
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
            preferencesWindowController.window?.makeKeyAndOrderFront(self)
        }
        
        return true
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
    }
    
    func removeObserver() {
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultEditor)
        OpenNotifier.removeObserver(observer: self, notification: .copyPathToClipboard)
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
            var paths = try FinderManager.shared.getFullPathsToFrontFinderWindowOrSelectedFile()
            if paths.count == 0 {
                // No Finder window and no file selected.
                let homePath = NSHomeDirectory()
                guard let homeUrl = URL(string: homePath) else { return }
                paths.append(homeUrl.appendingPathComponent("Desktop").path)
            } else {
                paths = paths.compactMap {
                    URL(string: $0)
                }.map {
                    $0.path
                }
            }
            let pathString = paths.joined(separator: "\n")
            // Set string
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(pathString, forType: .string)
        } catch {
            logw(error.localizedDescription)
        }
    }
}

extension AppDelegate {
    
    // MARK: - Global Shortcuts
    
    func bindShortcuts() {
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.defaultTerminalShortcut) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.openDefaultTerminal()
        }
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.defaultEditorShortcut) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.openDefaultEditor()
        }
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.copyPathShortcut) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.copyPathToClipboard()
        }
    }
}
