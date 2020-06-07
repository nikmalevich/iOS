//
//  RemoveNoteOperation.swift
//  Notes
//
//  Created by ios_school on 2/28/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteOperation: AsyncOperation {
    private let removeFromDb: RemoveNoteDBOperation
    private let dbQueue: OperationQueue
    
    private(set) var result: Bool?
    
    init(uid: String, notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue, token: String, gistID: String, context: NSManagedObjectContext) {
        
        removeFromDb = RemoveNoteDBOperation(uid: uid, context: context)
        self.dbQueue = dbQueue

        super.init()
        
        removeFromDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes, token: token, gistID: gistID)
            
            saveToBackend.completionBlock = {
                switch saveToBackend.result! {
                case .success:
                    self.result = true
                case .failure:
                    self.result = false
                }
                
                self.finish()
            }
            
            backendQueue.addOperation(saveToBackend)
        }
    }
    
    override func main() {
        dbQueue.addOperation(removeFromDb)
    }
}
