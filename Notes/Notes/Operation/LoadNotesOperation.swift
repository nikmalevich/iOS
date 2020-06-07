//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Created by ios_school on 2/28/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CoreData

class LoadNotesOperation: AsyncOperation {
    private let loadFromBackend: LoadNotesBackendOperation
    private let backendQueue: OperationQueue

    private(set) var result: FileNotebook?

    init(notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue, token: String, gistID: String, context: NSManagedObjectContext) {
        loadFromBackend = LoadNotesBackendOperation(token: token, gistID: gistID)
        self.backendQueue = backendQueue

        super.init()

        loadFromBackend.completionBlock = {
            switch self.loadFromBackend.result {
            case let .success(notes):
                let newNotebook = FileNotebook()
                
                for note in notes {
                    newNotebook.add(note)
                }
                
                self.result = newNotebook
                
                self.finish()
            case .failure:
                let loadFromDB = LoadNotesDBOperation(context: context)

                loadFromDB.completionBlock = {
                    guard let notes = loadFromDB.result else { return }
                    
                    let newNotebook = FileNotebook()
                    
                    for note in notes {
                        newNotebook.add(note)
                    }
                    
                    self.result = newNotebook
                    
                    self.finish()
                }
                
                dbQueue.addOperation(loadFromDB)
            case .none:
                return
            }
        }
    }
    
    override func main() {
        backendQueue.addOperation(loadFromBackend)
    }
}
