//
//  CodableNote.swift
//  Notes
//
//  Created by ios_school on 3/11/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation

struct SaveGist: Codable {
    let files: [String : SaveGistFile]
}

struct SaveGistFile: Codable {
    let content: String
}

struct LoadGist: Codable {
    let id: String
    let files: [String : LoadGistFile]
}

struct LoadGistFile: Codable {
    let filename: String
}
