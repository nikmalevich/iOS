//
//  BaseBackendOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation

enum NetworkError {
    case unreachable
    case url
    case data
    case code
    case content
    case json
}

class BaseBackendOperation: AsyncOperation {
    internal let token: String
    internal let gistID: String
    
    init(token: String, gistID: String) {
        self.token = token
        self.gistID = gistID
        
        super.init()
    }
}
