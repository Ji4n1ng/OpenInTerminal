//
//  TerminalManager.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/16/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import AppKit

public class TerminalManager {
    
    public static let shared: TerminalManager = TerminalManager()
    
    public func openTerminal(_ terminalType: TerminalType = .terminal) {
        do {
            var path = try FinderManager.shared.getPathToFrontFinderWindowOrSelectedFile()
            if path == "" {
                // No Finder windows are opened or selected, so open home directory
                path = NSHomeDirectory()
            }
            
            switch terminalType {
            case .terminal:
                let terminal = TerminalApp()
                try terminal.open(path)
            case .iTerm:
                let terminal = iTermApp()
                try terminal.open(path)
            case .hyper:
                let terminal = HyperApp()
                try terminal.open(path)
            }
        } catch {
            log(error, .error)
        }
    }
}
