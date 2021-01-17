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
    
    if let terminalName = DefaultsManager.shared.liteDefaultTerminal {
        let terminal = App(name: terminalName, type: .terminal)
        try terminal.openOutsideSandbox()
    } else {
        guard let selectedTerminal = AppManager.shared.pickTerminalAlert() else {
            throw OITLError.cannotGetTerminal
        }
        DefaultsManager.shared.liteDefaultTerminal = selectedTerminal.name
        try selectedTerminal.openOutsideSandbox()
    }
    
} catch {
    logw(error.localizedDescription)
}
