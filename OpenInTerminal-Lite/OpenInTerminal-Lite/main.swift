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
    
    guard let terminalType = TerminalManager.shared.getOrPickDefaultTerminal() else {
        throw OITLError.cannotGetTerminal
    }
    
    TerminalManager.shared.openTerminal(terminalType)
    
} catch {
    logw(error.localizedDescription)
}
