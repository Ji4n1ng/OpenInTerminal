//
//  AlacrittyApp.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/25.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

final class AlacrittyApp: Terminal {
    
    func open(_ path: String, _ newOption: NewOptionType, _ clear: ClearOptionType) throws {
        
        let source = """
        do shell script "open -na alacritty --args --working-directory  \(path.editorEscaped)"
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            throw OITError.cannotAccessApp(TerminalType.alacritty.rawValue)
        }
    }
    
}
