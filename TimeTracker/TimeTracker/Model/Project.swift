//
//  Project.swift
//  TimeTracker
//
//  Created by Admin on 19/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

struct Project: Codable {
    let uid: String
    let name: String
    let description: String
    let tasksUID: [String]?
    
    init(name: String, description: String) {
        self.uid = UUID().uuidString
        self.name = name
        self.description = description
        self.tasksUID = nil
    }
}
