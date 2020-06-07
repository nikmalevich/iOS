//
//  AuthorizationViewControllerExtension.swift
//  Notes
//
//  Created by ios_school on 3/12/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
import WebKit
import CocoaLumberjack

extension AuthorizationViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            guard let components = URLComponents(string: url.absoluteString) else {
                DDLogError("WevView url error")
                return
            }
            
            if let code = components.queryItems?.first(where: { $0.name == PostKeys.code.rawValue })?.value {
                var urlComponents = URLComponents(string: "https://github.com/login/oauth/access_token")
                urlComponents?.queryItems = [
                    URLQueryItem(name: PostKeys.clientID.rawValue, value: clientID),
                    URLQueryItem(name: PostKeys.clientSecret.rawValue, value: clientSecret),
                    URLQueryItem(name: PostKeys.code.rawValue, value: code)
                ]
                
                guard let url = urlComponents?.url else {
                    DDLogError("Auth url error")
                    return
                }
                
                var getTokenRequest = URLRequest(url: url)
                getTokenRequest.httpMethod = "POST"
                getTokenRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                URLSession.shared.dataTask(with: getTokenRequest) { (data, response, error) in
                    if let response = response as? HTTPURLResponse {
                        switch response.statusCode {
                        case 200..<300:
                            guard let data = data else {
                                DDLogError("Data error")
                                return
                            }
                            
                            guard let accessToken = try? JSONDecoder().decode(AccessToken.self, from: data) else {
                                DDLogError("Decode error")
                                return
                            }
                            
                            self.token = accessToken.token
                        default:
                           DDLogError("Response error")
                        }
                    }
                    
                    guard let getURL = URL(string: "https://api.github.com/gists") else {
                        DDLogError("Url error")
                        return
                    }
                    
                    var getRequest = URLRequest(url: getURL)
                    getRequest.httpMethod = "GET"
                    getRequest.setValue("token \(self.token ?? "")", forHTTPHeaderField: "Authorization")
                    
                    URLSession.shared.dataTask(with: getRequest) { (data, response, error) in
                        guard error == nil else {
                            DDLogError("Error: \(error?.localizedDescription ?? "no description")")
                            return
                        }
                        
                        guard let data = data else {
                            DDLogError("Data error")
                            return
                        }
                        
                        guard let gists = try? JSONDecoder().decode([LoadGist].self, from: data) else {
                            DDLogError("Decode error")
                            return
                        }
                        
                        for gist in gists {
                            for file in gist.files {
                                if file.key == "ios-course-notes-db" {
                                    self.gistID = gist.id
                                }
                            }
                        }
                        
                        if self.gistID == nil {
                            var createRequest = URLRequest(url: getURL)
                            createRequest.httpMethod = "POST"
                            createRequest.setValue("token \(self.token ?? "")", forHTTPHeaderField: "Authorization")
                            
                            let gistFile = SaveGistFile(content: "[]")
                            let gist = SaveGist(files: ["ios-course-notes-db": gistFile])
                            
                            createRequest.httpBody = try? JSONEncoder().encode(gist)
                            
                            URLSession.shared.dataTask(with: createRequest) { (data, response, error) in
                                if let response = response as? HTTPURLResponse {
                                    switch response.statusCode {
                                    case 200..<300:
                                        guard let data = data else {
                                            DDLogError("Data error")
                                            return
                                        }
                                        
                                        guard let newGist = try? JSONDecoder().decode(LoadGist.self, from: data) else {
                                            DDLogError("Decode error")
                                            return
                                        }
                                        
                                        self.gistID = newGist.id
                                    default:
                                       DDLogError("Response error")
                                    }
                                }
                                
                                OperationQueue.main.addOperation {
                                    self.performSegue(withIdentifier: "NotesSegue", sender: nil)
                                }
                            }.resume()
                        } else {
                            OperationQueue.main.addOperation {
                                self.performSegue(withIdentifier: "NotesSegue", sender: nil)
                            }
                        }
                    }.resume()
                }.resume()
            }
            
            dismiss(animated: true, completion: nil)
        }
        do {
            decisionHandler(.allow)
        }
    }
}

