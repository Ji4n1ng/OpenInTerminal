//
//  PhpStormApp.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/4/6.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

final class PhpStormApp: Editor {
    
    func open(_ paths: [String]) throws {
        
        let checkedPaths = paths.compactMap {
            URL(string: $0)
        }.map {
            $0.path.specialCharEscaped
        }
        
        if checkedPaths.count == 0 {
            throw OITError.wrongUrl
        }
        
        let joinedPaths = checkedPaths.joined(separator: " ")
        
        let source = """
        do shell script "open -a PhpStorm \(joinedPaths)"
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            throw OITError.cannotAccessApp(EditorType.phpStorm.rawValue)
        }
    }
    
}
