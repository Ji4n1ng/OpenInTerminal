//
//  Error.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/10.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

enum OITError: Error {
    
    case cannotAccessFinder
    case cannotAccessApp(_ appName: String)
    case wrongUrl
    case cannotSetItermNewOption
    
}

extension OITError : CustomStringConvertible {

    var description: String {

        switch self {
            
        case .cannotAccessFinder:
            return "Cannot access Finder, please check permissions."
        case .cannotAccessApp(let appName):
            return "Cannot access \(appName), please check permissions."
        case .wrongUrl:
            return "Oops, got a wrong url"
        case .cannotSetItermNewOption:
            return "Cannot set iTerm new option"
        }
    }
}
