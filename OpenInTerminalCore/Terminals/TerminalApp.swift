//
//  TerminalApp.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/11.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import ScriptingBridge

final class TerminalApp: Terminal {

    func open(_ path: String, _ newOption: NewOptionType) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        if newOption == .window {
            
            let terminal = SBApplication(bundleIdentifier: TerminalType.terminal.bundleId)! as TerminalApplication
            guard let open = terminal.open else {
                throw OITError.cannotAccessApp(TerminalType.terminal.rawValue)
            }
            open([url])
            terminal.activate()
            
        } else {
            
            let source = """
            if not application "Terminal" is running then
                tell application "Terminal"
                    do script "cd \(url.path.terminalEscaped)"
                    activate
                end tell
            else
                tell application "Terminal"
                    if not (exists window 1) then
                        do script "cd \(url.path.terminalEscaped)"
                        activate
                    else
                        activate
                        tell application "System Events" to keystroke "t" using command down
                        repeat while contents of selected tab of window 1 starts with linefeed
                            delay 0.01
                        end repeat
                        do script "cd \(url.path.terminalEscaped)" in window 1
                    end if
                end tell
            end if
            """
            let script = NSAppleScript(source: source)!
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if error != nil {
                throw OITError.cannotAccessApp(TerminalType.terminal.rawValue)
            }
        }
    }
    
}

fileprivate extension String {
    
    // FIXME: if path contains "\" or """, application will crash.
    // Special symbols have been tested, except for backslashes and double quotes.
    var terminalEscaped: String {
        
        var result = ""
        let set = CharacterSet.alphanumerics
        
        for char in self.unicodeScalars {
            if set.contains(char) || char == "/" {
                result.unicodeScalars.append(char)
            } else {
                result += "\\\\"
                result.unicodeScalars.append(char)
            }
        }
        
        return result
    }
}
