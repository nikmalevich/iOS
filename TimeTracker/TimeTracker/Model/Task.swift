//
//  Task.swift
//  TimeTracker
//
//  Created by Admin on 19/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

enum ExecutionStatus: String, Codable {
    case notStarted
    case performed
    case completed
}

struct Task: Codable {
    let uid: String
    let name: String
    let description: String
    let projectName: String
    let performers: [User]?
    let status: ExecutionStatus
    let deadline: Date
    let start: Date?
    let finish: Date?
    
    init(uid: String = UUID().uuidString, name: String, description: String, projectName: String, status: ExecutionStatus = .notStarted, deadline: Date, start: Date? = nil, finish: Date? = nil) {
        self.uid = uid
        self.name = name
        self.description = description
        self.projectName = projectName
        self.performers = nil
        self.status = status
        self.deadline = deadline
        self.start = start
        self.finish = finish
    }
}
