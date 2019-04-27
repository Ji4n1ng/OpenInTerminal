//
//  AppDelegate.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: Properties
    
    var preferencesController: NSWindowController?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    lazy var statusBarMenu: NSMenu = {
        let menu = NSMenu()
        let preferencesItem = NSMenuItem(title: "Preferences...",
                                         action: #selector(showPreferences(_:)),
                                         keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit",
                                  action: #selector(quit),
                                  keyEquivalent: "")
        [preferencesItem, NSMenuItem.separator(), quitItem].forEach {
            menu.addItem($0)
        }
        return menu
    }()
    
    // MARK: Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
//        SMLoginItemSetEnabled(Constants.launcherAppIdentifier as CFString, false)
//        CoreManager.shared.removeAllUserDefaults()
        CoreManager.shared.firstSetup()
        terminateOpenInTerminalHelper()
        addObserver()
        setStatusBarIcon()
        setStatusToggle()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem)
        
        removeObserver()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
}

extension AppDelegate {
    
    // MARK: Status Bar Item
    
    func setStatusBarIcon() {
        let icon = NSImage(assetIdentifier: .StatusBarIcon)
        icon.isTemplate = true // Support Dark Mode
        DispatchQueue.main.async {
            self.statusItem.button?.image = icon
        }
    }
    
    func setStatusToggle() {
        guard let quickOpen = CoreManager.shared.quickOpen else { return }
        
        if quickOpen == ._true {
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
            openDefaultTerminal()
        }
    }
    
    // MARK: Status Bar Menu Actions
    
    @objc func showPreferences(_ sender: Any) {
        
        if preferencesController == nil {
            let storyboard = NSStoryboard(storyboardIdentifier: .Preferences)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if preferencesController != nil {
            preferencesController!.showWindow(sender)
        }
        
    }
    
    @objc func quit() {
        LaunchNotifier.postNotification(.terminateApp, object: Bundle.main.bundleIdentifier!)
        NSApp.terminate(self)
    }
    
    // MARK: OpenInTerminalHelper
    
    func terminateOpenInTerminalHelper() {
        let isRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == Constants.launcherAppIdentifier
        }
        
        if isRunning {
            LaunchNotifier.postNotification(.terminateApp, object: Bundle.main.bundleIdentifier!)
        }
        
    }
    
    // MARK: Notification
    
    func addObserver() {
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openDefaultTerminal),
                                 notification: .openDefaultTerminal)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openTerminal),
                                 notification: .openTerminal)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openITerm),
                                 notification: .openITerm)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openHyper),
                                 notification: .openHyper)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openAlacritty),
                                 notification: .openAlacritty)
        
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openDefaultEditor),
                                 notification: .openDefaultEditor)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openVSCode),
                                 notification: .openVSCode)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openAtom),
                                 notification: .openAtom)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openSublime),
                                 notification: .openSublime)
        
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(copyPathToClipboard),
                                 notification: .copyPathToClipboard)
    }
    
    func removeObserver() {
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openITerm)
        OpenNotifier.removeObserver(observer: self, notification: .openHyper)
        OpenNotifier.removeObserver(observer: self, notification: .openAlacritty)
        
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultEditor)
        OpenNotifier.removeObserver(observer: self, notification: .openVSCode)
        OpenNotifier.removeObserver(observer: self, notification: .openAtom)
        OpenNotifier.removeObserver(observer: self, notification: .openSublime)
        
        OpenNotifier.removeObserver(observer: self, notification: .copyPathToClipboard)
    }
    
    // MARK: Notification Actions
    
    @objc func openDefaultTerminal() {
        guard let terminalType = TerminalManager.shared.getOrPickDefaultTerminal() else {
            return
        }
        
        TerminalManager.shared.openTerminal(terminalType)
    }
    
    @objc func openTerminal() {
        TerminalManager.shared.openTerminal(.terminal)
    }
    
    @objc func openITerm() {
        TerminalManager.shared.openTerminal(.iTerm)
    }
    
    @objc func openHyper() {
        TerminalManager.shared.openTerminal(.hyper)
    }
    
    @objc func openAlacritty() {
        TerminalManager.shared.openTerminal(.alacritty)
    }
    
    @objc func openDefaultEditor() {
        guard let editorType = EditorManager.shared.getOrPickDefaultEditor() else {
            return
        }
        
        EditorManager.shared.openEditor(editorType)
    }
    
    @objc func openVSCode() {
        EditorManager.shared.openEditor(.vscode)
    }
    
    @objc func openAtom() {
        EditorManager.shared.openEditor(.atom)
    }
    
    @objc func openSublime() {
        EditorManager.shared.openEditor(.sublime)
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
            log(error, .error)
        }
    }
}
