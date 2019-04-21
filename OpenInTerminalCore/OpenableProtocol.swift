//
//  Terminal.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/10.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public protocol Openable {
    
    func open(_ path: String, _ newOption: NewOptionType) throws

}
