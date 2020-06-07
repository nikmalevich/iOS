import UIKit.UIColor

enum NoteKey: String {
    case uid
    case title
    case content
    case color
    case importance
    case selfDestructionDate
}

extension Note {
    var json: [String: Any] {
        var json = [String: Any]()
            
        json[NoteKey.uid.rawValue] = uid
        json[NoteKey.title.rawValue] = title
        json[NoteKey.content.rawValue] = content
        if (color != .white) {
            json[NoteKey.color.rawValue] = self.color.RGBComponents()
        }
        if (self.importance != .common) {
            json[NoteKey.importance.rawValue] = importance.rawValue
        }
        if let date = selfDestructionDate {
            json[NoteKey.selfDestructionDate.rawValue] = date.timeIntervalSince1970
        }
            
        return json
    }
    
    static func parse(json: [String: Any]) -> Note? {
        var uid: String?
        var title: String?
        var content: String?
        var color: UIColor?
        var importance: Importance?
        var selfDestructionDate: Date?
        
        for (key, value) in json {
            switch (key, value) {
            case let (NoteKey.uid.rawValue, value as String):
                uid = value
            case let (NoteKey.title.rawValue, value as String):
                title = value
            case let (NoteKey.content.rawValue, value as String):
                content = value
            case let (NoteKey.color.rawValue, value as [CGFloat]):
                let numOfComponentsForRGB = 4
                
                if (value.count == numOfComponentsForRGB) {
                    color = UIColor(red: value[0], green: value[1], blue: value[2], alpha: value[3])
                }
            case let (NoteKey.importance.rawValue, value as String):
                importance = Importance(rawValue: value)
            case let (NoteKey.selfDestructionDate.rawValue, value as TimeInterval):
                selfDestructionDate = Date(timeIntervalSince1970: value)
            default:
                break
            }
        }
        
        if let uid = uid, let title = title, let content = content {
            return Note(uid: uid, title: title, content: content, color: color ?? .white, importance: importance ?? .common, selfDestructionDate: selfDestructionDate)
        }
        
        return nil
    }
}
