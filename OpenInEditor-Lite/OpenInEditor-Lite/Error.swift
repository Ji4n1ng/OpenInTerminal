//
//  Error.swift
//  OpenInEditor-Lite
//
//  Created by Jianing Wang on 2019/6/25.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

enum OITLError: Error {
    
    case cannotGetEditor
    
}

extension OITLError : CustomStringConvertible {
    
    var description: String {
        
        switch self {
            
        case .cannotGetEditor:
            return "There is no default editor. And user did not pick a editor."
        }
    }
}
