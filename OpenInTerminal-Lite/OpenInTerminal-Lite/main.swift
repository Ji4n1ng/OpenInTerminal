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

    if let terminalType = DefaultsManager.shared.defaultTerminal {
        TerminalManager.shared.openTerminal(terminalType)
    } else {
        guard let selectedTerminal = TerminalManager.shared.pickTerminalAlert() else {
            throw OITLError.cannotGetTerminal
        }
        DefaultsManager.shared.defaultTerminal = selectedTerminal
        TerminalManager.shared.openTerminal(selectedTerminal)
    }
    
} catch {
    logw(error.localizedDescription)
}
