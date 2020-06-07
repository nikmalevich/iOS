//
//  LoadNotesBackendOperation.swift
//  Notes
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum LoadNotesBackendResult {
    case success([Note])
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {
    private(set) var result: LoadNotesBackendResult?
    
    override init(token: String, gistID: String) {
        super.init(token: token, gistID: gistID)
    }
    
    private func load(completion: @escaping(LoadNotesBackendResult) -> Void) {
        let urlString = "https://api.github.com/gists/\(gistID)"
        guard let url = URL(string: urlString) else {
            DDLogError("URL error")
            completion(.failure(.url))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DDLogError("Error: \(error?.localizedDescription ?? "no description")")
                completion(.failure(.unreachable))
                return
            }
            
            guard let data = data else {
                DDLogError("Data error")
                completion(.failure(.data))
                return
            }
            
            guard let gist = try? JSONDecoder().decode(SaveGist.self, from: data) else {
                DDLogError("Decode error")
                completion(.failure(.code))
                return
            }
            
            guard let contentData = gist.files["ios-course-notes-db"]?.content.data(using: .utf8) else {
                DDLogError("Content error")
                completion(.failure(.content))
                return
            }
            
            guard let jsons = try? JSONSerialization.jsonObject(with: contentData) as? [[String : Any]] else {
                DDLogError("Jsons error")
                completion(.failure(.json))
                return
            }
            
            var notes = [Note]()
            
            for json in jsons {
                if let note = Note.parse(json: json) {
                    notes.append(note)
                } else {
                    DDLogError("Parse json error")
                }
            }
            
            completion(.success(notes))
        }.resume()
    }
    
    override func main() {
        guard NetStatus.shared.isConnected else {
            result = .failure(.unreachable)
            
            finish()
            return
        }
        
        load { [weak self] result in
            self?.result = result
            
            self?.finish()
        }
    }
}
