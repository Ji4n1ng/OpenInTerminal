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
        let isHideStatusItem = DefaultsManager.shared.isHideStatusItem.bool
        statusItem.isVisible = !isHideStatusItem
    }
    
    func setStatusToggle() {
        let isQuickToogle = DefaultsManager.shared.isQuickToggle.bool
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
            $0.bundleIdentifier == Constants.launcherAppIdentifier
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
        if let terminalType = DefaultsManager.shared.defaultTerminal {
            TerminalManager.shared.openTerminal(terminalType)
        } else {
            guard let selectedTerminal = TerminalManager.shared.pickTerminalAlert() else {
                return
            }
            DefaultsManager.shared.defaultTerminal = selectedTerminal
            TerminalManager.shared.openTerminal(selectedTerminal)
        }
    }
    
    @objc func openDefaultEditor() {
        if let editorType = DefaultsManager.shared.defaultEditor {
            EditorManager.shared.openEditor(editorType)
        } else {
            guard let selectedEditor = EditorManager.shared.pickEditorAlert() else {
                return
            }
            DefaultsManager.shared.defaultEditor = selectedEditor
            EditorManager.shared.openEditor(selectedEditor)
        }
    }
    
    @objc func copyPathToClipboard() {
        do {
            var path = try FinderManager.shared.getFullPathToFrontFinderWindowOrSelectedFile()
            if path == "" {
                // No Finder window and no file selected.
                let homePath = NSHomeDirectory()
                guard let homeUrl = URL(string: homePath) else { return }
                path = homeUrl.appendingPathComponent("Desktop").path
            } else {
                guard let url = URL(string: path) else { return }
                path = url.path
            }
            
            // Set string
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(path, forType: .string)
            
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
