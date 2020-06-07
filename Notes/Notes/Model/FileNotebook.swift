import CocoaLumberjack

enum FileNotebookError: Error {
    case JSData
    case JSON
    case File
}

class FileNotebook {
    private(set) var notes = [Note]()
        
    #if DEBUG
        private let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    #else
        private let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    #endif
    
    public func add(_ note: Note) {
        guard let replayIndex = notes.firstIndex(where: { $0.uid == note.uid }) else {
            notes.append(note)
            
            DDLogInfo("Note with id \(note.uid) is added")
            return
        }
        
        notes.remove(at: replayIndex)
        notes.append(note)
        
        DDLogInfo("Note with id \(note.uid) is overwritten")
    }
    
    public func remove(with uid: String) {
        guard let index = notes.firstIndex(where: { $0.uid == uid }) else {
            DDLogInfo("Note with id \(uid) doesn't exist")
            return
        }
        
        notes.remove(at: index)
        
        DDLogInfo("Note with id \(uid) is removed")
    }
    
    public func saveToFile(fileName: String) throws {
        let file = path.appendingPathComponent(fileName)
        
        guard let jsdata = try? JSONSerialization.data(withJSONObject: notes.map { $0.json }, options: []) else { throw FileNotebookError.JSData }
        
        if FileManager.default.createFile(atPath: file.path, contents: jsdata) {
            DDLogInfo("Note are saved to file")
        } else {
            throw FileNotebookError.File
        }
    }
    
    public func loadFromFile(fileName: String) throws {
        let file = path.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: file.path) else { throw FileNotebookError.File }
        
        guard let jsdata = FileManager.default.contents(atPath: file.path) else { throw FileNotebookError.JSData }
            
        guard let jsons = try? JSONSerialization.jsonObject(with: jsdata) as? [[String: Any]] else { throw FileNotebookError.JSON }
                
        notes.removeAll()
                    
        for json in jsons {
            if let note = Note.parse(json: json) {
                self.add(note)
            }
        }
        
        DDLogInfo("Note are loaded from file")
    }
}
