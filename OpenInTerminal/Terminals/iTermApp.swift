//
//  iTermApp.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/11.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

final class iTermApp : Terminal {
    
    func open(_ path: String) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        let source = """
        tell application "iTerm"
            set isRunning to (application "iTerm" is running)
            activate
        
            tell current window
        
                if (count of tabs) < 1 then
                    create window with default profile
                    set isRunning to false
                end if
        
                if isRunning then
                    set newTab to (create tab with default profile)
        
                    tell newTab
                        select
                    end tell
                end if
        
                tell current session
                    write text "cd \(url.path.itermEscaped)"
                end tell
            end tell
        end tell
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            log(error, .error)
            throw OITError.cannotAccessIterm
        }
    }
    
}


fileprivate extension String {
    
    // FIXME: if path contains "\", application will crash.
    var itermEscaped: String {
        
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
