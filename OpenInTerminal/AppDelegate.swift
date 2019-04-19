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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(openTerminal), name: NSNotification.Name("openTerminal"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(openITerm), name: NSNotification.Name("openITerm"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(openHyper), name: NSNotification.Name("openHyper"), object: nil)
        
        TerminalManager.shared.openTerminal()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self, name: NSNotification.Name("openTerminal"), object: nil)
        DistributedNotificationCenter.default().removeObserver(self, name:NSNotification.Name("openITerm"), object: nil)
        DistributedNotificationCenter.default().removeObserver(self, name: NSNotification.Name("openHyper"), object: nil)
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
