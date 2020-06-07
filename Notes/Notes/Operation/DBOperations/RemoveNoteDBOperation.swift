//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class RemoveNoteDBOperation: BaseDBOperation {
    private let uid: String
    
    init(uid: String, context: NSManagedObjectContext) {
        self.uid = uid
        
        super.init(context: context)
    }
    
    override func main() {
        let predicate = NSPredicate(format: "uid == %@", uid)
        let request = NSFetchRequest<ModelNote>(entityName: "ModelNote")
        request.predicate = predicate
        request.fetchLimit = 1
        
        backgroundContext.performAndWait {
            guard let note = try? backgroundContext.fetch(request).first else {
                DDLogError("Fetch request error")
                return
            }
            
            backgroundContext.delete(note)
            
            do {
                try backgroundContext.save()
            } catch {
                DDLogError(error.localizedDescription)
            }
            
            finish()
        }
    }
}
