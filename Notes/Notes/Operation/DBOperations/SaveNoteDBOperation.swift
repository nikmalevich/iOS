//
//  SaveNoteDBOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    
    init(note: Note, context: NSManagedObjectContext) {
        self.note = note
        
        super.init(context: context)
    }
    
    override func main() {
        let newNote = ModelNote(context: backgroundContext)
        newNote.title = note.title
        newNote.content = note.content
        newNote.uid = note.uid
        newNote.color = note.color.hexString
        newNote.importance = note.importance.rawValue
        newNote.selfDestructionDate = note.selfDestructionDate
        newNote.createdDate = Date()
        
        backgroundContext.performAndWait {
            do {
                try backgroundContext.save()
            } catch {
                DDLogError(error.localizedDescription)
            }
            
            finish()
        }
    }
}
