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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        OpenNotifier.addObserver(observer: self, selector: .openInDefaultTerminalNotification, notification: .openDefaultTerminal)
        OpenNotifier.addObserver(observer: self, selector: .openTerminalNotification, notification: .openTerminal)
        OpenNotifier.addObserver(observer: self, selector: .openITermNotification, notification: .openITerm)
        OpenNotifier.addObserver(observer: self, selector: .openHyperNotification, notification: .openHyper)
        
        TerminalManager.shared.openTerminal()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openITerm)
        OpenNotifier.removeObserver(observer: self, notification: .openHyper)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        TerminalManager.shared.openTerminal()
        return true
    }
    
    @objc func openDefaultTerminal() {
        TerminalManager.shared.openTerminal()
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
}

fileprivate extension Selector {
    static let openInDefaultTerminalNotification = #selector(AppDelegate.openDefaultTerminal)
    static let openTerminalNotification = #selector(AppDelegate.openTerminal)
    static let openITermNotification = #selector(AppDelegate.openITerm)
    static let openHyperNotification = #selector(AppDelegate.openHyper)
}

