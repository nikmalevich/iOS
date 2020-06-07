import Foundation

struct GetJogResponse: Codable {
    let response: JogArray
}

struct PostJogResponse: Codable {
    let response: PostJog
}

struct JogArray: Codable {
    let jogs: [GetJog]
}

struct GetJog: Codable, Equatable {
    let id: Int
    let userID: String
    let date: TimeInterval
    let distance: Double
    let time: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case date
        case distance
        case time
    }
    
    init(postJog: PostJog) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        self.id = postJog.id
        self.userID = String(postJog.userID)
        self.date = dateFormatter.date(from: postJog.date)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        self.distance = postJog.distance
        self.time = postJog.time
    }
}

struct PostJog: Codable {
    let id: Int
    let userID: Int
    let date: String
    let distance: Double
    let time: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case date
        case distance
        case time
    }
}
