//
//  SaveNoteOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CoreData

class SaveNoteOperation: AsyncOperation {
    private let saveToDb: SaveNoteDBOperation
    private let dbQueue: OperationQueue
    
    private(set) var result: Bool?
    
    init(note: Note, notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue, token: String, gistID: String, context: NSManagedObjectContext) {
        
        saveToDb = SaveNoteDBOperation(note: note, context: context)
        self.dbQueue = dbQueue

        super.init()
        
        saveToDb.completionBlock = {
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
        dbQueue.addOperation(saveToDb)
    }
}
