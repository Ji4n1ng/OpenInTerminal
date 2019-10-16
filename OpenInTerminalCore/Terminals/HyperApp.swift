//
//  HyperApp.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/15.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

final class HyperApp: Terminal {
    
    func open(_ path: String, _ newOption: NewOptionType) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        let source = """
        do shell script "open -a Hyper \(url.path.specialCharEscaped)"
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            throw OITError.cannotAccessApp(TerminalType.hyper.rawValue)
        }
    }
    
}
