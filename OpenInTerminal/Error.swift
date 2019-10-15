//
//  Error.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/10/15.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

enum OITMError: Error {
    
    case cannotAccessPath(_ path: String)
    
}

extension OITMError : CustomStringConvertible {
    
    var description: String {
        switch self {
        case .cannotAccessPath(let path):
            return "Cannot access path: \(path)"
        }
    }
}
