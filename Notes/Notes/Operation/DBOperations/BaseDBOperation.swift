//
//  BaseDBOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CoreData

class BaseDBOperation: AsyncOperation {
    internal let backgroundContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        super.init()
    }
}
