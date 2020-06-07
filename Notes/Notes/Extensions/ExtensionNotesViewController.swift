//
//  ExtensionNotesViewController.swift
//  Notes
//
//  Created by ios_school on 2/16/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit
import CoreData

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebook.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoteTableViewCell
        let note = notebook.notes[indexPath.row]
        
        cell.title.text = note.title
        cell.content.text = note.content
        cell.colorView.backgroundColor = note.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentNote = notebook.notes[indexPath.row]
        
        performSegue(withIdentifier: "EditNoteSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, nil) in
            guard let `self` = self else { return }
            self.loadIndicator.isHidden = false
            self.loadIndicator.startAnimating()

            let uid = self.notebook.notes[indexPath.row].uid
            
            self.notebook.remove(with: uid)
            
            let removeNoteOperation = RemoveNoteOperation(uid: uid, notebook: self.notebook, backendQueue: self.backendQueue, dbQueue: self.dbQueue, token: self.token ?? "", gistID: self.gistID ?? "", context: self.context)
            
            removeNoteOperation.completionBlock = {
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    self.loadIndicator.isHidden = true
                    self.loadIndicator.stopAnimating()
                }
            }
            
            self.queue.addOperation(removeNoteOperation)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
