//
//  SaveNotesBackendOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    private(set) var result: SaveNotesBackendResult?
    private let notes: [Note]
    
    init(notes: [Note], token: String, gistID: String) {
        self.notes = notes
        
        super.init(token: token, gistID: gistID)
    }
    
    private func save(completion: @escaping(SaveNotesBackendResult) -> Void) {
        let urlString = "https://api.github.com/gists/\(gistID)"
        guard let url = URL(string: urlString) else {
            DDLogError("URL error")
            completion(.failure(.url))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        
        guard let data = try? JSONSerialization.data(withJSONObject: notes.map { $0.json }) else {
            DDLogError("Data error")
            completion(.failure(.data))
            return
        }
        
        guard let content = String(data: data, encoding: .utf8) else {
            DDLogError("Content error")
            completion(.failure(.content))
            return
        }
        
        let gistFile = SaveGistFile(content: content)
        
        let gist = SaveGist(files: ["ios-course-notes-db": gistFile])
        
        request.httpBody = try? JSONEncoder().encode(gist)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    completion(.success)
                default:
                    completion(.failure(.unreachable))
                }
            }
        }.resume()
    }
    
    override func main() {
        guard NetStatus.shared.isConnected else {
            result = .failure(.unreachable)
            
            finish()
            return
        }
        
        save { [weak self] result in
            self?.result = result
            
            self?.finish()
        }
    }
}
