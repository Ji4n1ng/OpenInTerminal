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

    if let terminal = TerminalManager.shared.getTerminal() {
        try terminal.open(path)
    }

} catch {
    
    print(error)
}
