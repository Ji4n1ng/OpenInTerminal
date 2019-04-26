//
//  AppDelegate.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import OpenInTerminalCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem?
    var preferencesController: NSWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        createStatusBarItem()
        addObserver()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem!)
        
        removeObserver()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
}

extension AppDelegate {
    
    // MARK: Status Bar
    
    func createStatusBarItem() {
        
        let statusBar = NSStatusBar.system
        
        let item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        let icon = NSImage(assetIdentifier: .StatusBarIcon)
        icon.isTemplate = true // Support Dark Mode
        item.button?.image = icon
        
        let statusBarMenu = NSMenu()
        
        let preferencesItem = NSMenuItem(title: "Preferences...",
                                         action: #selector(showPreferences(_:)),
                                         keyEquivalent: "")
        
        let quitItem = NSMenuItem(title: "Quit",
                                  action: #selector(quit),
                                  keyEquivalent: "")
        
        [preferencesItem, NSMenuItem.separator(), quitItem].forEach {
            statusBarMenu.addItem($0)
        }
        
        item.menu = statusBarMenu
        statusItem = item
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
        log("quit")
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
    }
    
    // MARK: Notification Actions
    
    @objc func openDefaultTerminal() {
        guard let terminalType = TerminalManager.shared.getDefaultTerminal() else {
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
        guard let editorType = EditorManager.shared.getDefaultEditor() else {
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
    
    
}
