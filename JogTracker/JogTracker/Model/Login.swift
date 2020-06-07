import Foundation

struct LoginResponse: Codable {
    let response: Login
}

struct Login: Codable {
    let token: String
    
    enum CodingKeys: String, CodingKey {
      case token = "access_token"
    }
}
