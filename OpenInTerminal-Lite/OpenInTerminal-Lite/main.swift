//
//  main.swift
//  OpenInTerminal-Lite
//
//  Created by Jianing Wang on 2019/4/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import OpenInTerminalCore

do {

    var path = try FinderManager.shared.getPathToFrontFinderWindowOrSelectedFile()
    if path == "" {
        // No Finder windows are opened or selected, so open home directory
        path = NSHomeDirectory()
    }

    guard let terminalType = TerminalManager.shared.getTerminal() else {
        throw OITLError.cannotGetTerminal
    }
    
    let terminal = terminalType.instance()
    
    if let newOption = TerminalManager.shared.getNewOption(terminalType) {
        try terminal.open(path, newOption)
    } else {
        try terminal.open(path, .window)
    }
    

} catch {
    
    log(error)
}
