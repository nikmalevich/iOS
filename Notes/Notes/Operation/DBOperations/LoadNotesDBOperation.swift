//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack

class LoadNotesDBOperation: BaseDBOperation {
    private(set) var result: [Note]?
    
    override func main() {
        let request = NSFetchRequest<ModelNote>(entityName: "ModelNote")
        
        backgroundContext.performAndWait {
            guard let notes = try? backgroundContext.fetch(request) else {
                DDLogError("Fetch request error")
                return
            }
            
            result = [Note]()
            
            for note in notes {
                guard let uid = note.uid, let title = note.title, let content = note.content, let color = UIColor(hex: note.color ?? ""), let importance = note.importance else {
                    DDLogError("Node error")
                    
                    return
                }
                
                result?.append(Note(uid: uid, title: title, content: content, color: color, importance: Importance(rawValue: importance) ?? .common, selfDestructionDate: note.selfDestructionDate))
            }
        }
        
        finish()
    }
}
