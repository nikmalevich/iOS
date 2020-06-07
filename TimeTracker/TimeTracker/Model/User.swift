import Foundation

struct User: Codable {
    let isPM: Bool
    let projectsID: [String]?
    let userTasksID: [String]?
    
    init(isPM: Bool) {
        self.isPM = isPM
        self.projectsID = nil
        self.userTasksID = nil
    }
}
