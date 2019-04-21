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
        createStatusBar()
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
    
    // MARK: Notification
    
    func addObserver() {
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openTerminal),
                                 notification: .openTerminal)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openITerm),
                                 notification: .openITerm)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openHyper),
                                 notification: .openHyper)
    }
    
    func removeObserver() {
        OpenNotifier.removeObserver(observer: self, notification: .openTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openITerm)
        OpenNotifier.removeObserver(observer: self, notification: .openHyper)
    }
    
    // MARK: Notification Actions
    
    @objc func openTerminal() {
        TerminalManager.shared.openTerminal(.terminal)
    }
    
    @objc func openITerm() {
        TerminalManager.shared.openTerminal(.iTerm)
    }
    
    @objc func openHyper() {
        TerminalManager.shared.openTerminal(.hyper)
    }
    
    // MARK: Status Bar
    
    func createStatusBar() {
        
        let statusBar = NSStatusBar.system
        
        let item = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
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
    
}
