//
//  AuthorizationViewController.swift
//  Notes
//
//  Created by ios_school on 3/12/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit
import WebKit
import CocoaLumberjack

enum PostKeys: String {
    case clientID = "client_id"
    case clientSecret = "client_secret"
    case code
    case scope
}

struct AccessToken: Codable{
    let token: String
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
    }
}

class AuthorizationViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    internal let clientID = "59cb44f8d11990bf5079"
    internal let clientSecret = "94335aa919e42c45ba067a2621d9095594da2c4d"
    internal var token: String?
    internal var gistID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard NetStatus.shared.isConnected else {
            performSegue(withIdentifier: "NotesSegue", sender: nil)
            
            return
        }
        
        webView.navigationDelegate = self
        
        let stringUrl = "https://github.com/login/oauth/authorize"
        var components = URLComponents(string: stringUrl)
        components?.queryItems = [
            URLQueryItem(name: PostKeys.clientID.rawValue, value: clientID),
            URLQueryItem(name: PostKeys.scope.rawValue, value: "gist")
        ]

        guard let url = components?.url else {
            DDLogError("Auth url error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        webView.load(request)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NotesViewController, segue.identifier == "NotesSegue" {
            controller.token = token
            controller.gistID = gistID
        }
    }
}
