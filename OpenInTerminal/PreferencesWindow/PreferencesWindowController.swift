//
//  PreferencesWindowController.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/20.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {

        // Hide the window instead of closing
        self.window?.orderOut(sender)
        return false
    }

}
