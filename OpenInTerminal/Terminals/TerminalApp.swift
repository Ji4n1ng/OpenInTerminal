//
//  TerminalApp.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/11.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import ScriptingBridge

final class TerminalApp : Terminal {

    func open(_ path: String) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        let terminal = SBApplication(bundleIdentifier: TerminalType.terminal.rawValue)! as TerminalApplication
        
        guard let open = terminal.open else {
            throw OITError.cannotAccessTerminal
        }
        
        open([url])
        
        terminal.activate()
    }
    
}
