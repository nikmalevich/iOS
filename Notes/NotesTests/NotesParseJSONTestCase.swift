//
//  NotesParseJSONTestCase.swift
//  Notes
//
//  Created by ios_school on 2/1/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import XCTest
@testable import Notes

class NotesParseJSONTestCase: XCTestCase {
    let now = Date()
    lazy var json = [NoteKey.uid.rawValue: "nik", NoteKey.title.rawValue: "hello", NoteKey.content.rawValue: "world", NoteKey.color.rawValue: UIColor.black.RGBComponents(), NoteKey.importance.rawValue: Importance.important.rawValue, NoteKey.selfDestructionDate.rawValue: now.timeIntervalSince1970] as [String : Any]
        
    func testCorrectFullNote() {
        let note = Note(uid: "nik", title: "hello", content: "world", color: .black, importance: .important, selfDestructionDate: now)
        let parseNote = Note.parse(json: json)!
        
        XCTAssertTrue(note == parseNote)
    }
    
    func testCorrectNoteWithoutColor() {
        json[NoteKey.color.rawValue] = nil
        let parseNote = Note.parse(json: json)!
        
        XCTAssertEqual(parseNote.color, UIColor.white)
    }
    
    func testCorrectNoteWithoutDate() {
        json[NoteKey.selfDestructionDate.rawValue] = nil
        let parseNote = Note.parse(json: json)!
        
        XCTAssertNil(parseNote.selfDestructionDate)
    }
    
    func testIncorrectNoteWithoutUID() {
        json[NoteKey.uid.rawValue] = nil
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithoutTitle() {
        json[NoteKey.title.rawValue] = nil
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithoutContent() {
        json[NoteKey.content.rawValue] = nil
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithIncorrectNameUID() {
        json[NoteKey.uid.rawValue] = nil
        json["ui"] = "nik"
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithIncorrectNameTitle() {
        json[NoteKey.title.rawValue] = nil
        json["ttle"] = "hello"
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithIncorrectNameContent() {
        json[NoteKey.content.rawValue] = nil
        json["conent"] = "world"
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithIncorrectTypeUID() {
        json[NoteKey.uid.rawValue] = UIColor.black
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithIncorrectTypeTitle() {
        json[NoteKey.title.rawValue] = UIView()
        
        XCTAssertNil(Note.parse(json: json))
    }
    
    func testIncorrectNoteWithIncorrectTypeContent() {
        json[NoteKey.content.rawValue] = 1
        
        XCTAssertNil(Note.parse(json: json))
    }

}
