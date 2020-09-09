//
//  KittyApp.swift
//  OpenInTerminalCore
//
//  Created by gucheng on 2020/9/8.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

final class KittyApp: Terminal {
    
    func open(_ path: String, _ newOption: NewOptionType) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        let source = """
        do shell script "open -na kitty --args -1 --directory \(url.path.specialCharEscaped)"
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            throw OITError.cannotAccessApp(TerminalType.kitty.rawValue)
        }
    }
    
}
