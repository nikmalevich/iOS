//
//  ViewController.swift
//  Notes
//
//  Created by ios_school on 1/31/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    internal var notebook = FileNotebook()
    internal let reuseIdentifier = "note cell"
    internal var currentNote: Note?
    internal let queue = OperationQueue()
    internal let dbQueue = OperationQueue()
    internal let backendQueue = OperationQueue()
    internal var token: String?
    internal var gistID: String?
    
    internal var context: NSManagedObjectContext!
    
    @IBAction func addNoteButtonTapped(_ sender: UIBarButtonItem) {
        currentNote = nil
        
        self.performSegue(withIdentifier: "EditNoteSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EditNoteViewController, segue.identifier == "EditNoteSegue" {
            controller.note = currentNote
            
            controller.addOrEditNote = { [weak self] note in
                guard let `self` = self else { return }
                
                self.notebook.add(note)
                
                let saveNoteOperation = SaveNoteOperation(note: note, notebook: self.notebook, backendQueue: self.backendQueue, dbQueue: self.dbQueue, token: self.token ?? "", gistID: self.gistID ?? "", context: self.context)
                
                self.queue.addOperation(saveNoteOperation)
            }
        }
    }
    
    @IBAction func editTableButtonTapped(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
    
    @IBAction func unwindToNotesVC(segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = NSPersistentContainer(name:
            "Model")
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Failed to load store")
            }
            
            self.context = container.viewContext
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        
        loadNotes()

        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 1
    }
    
    @objc func managedObjectContextDidSave(notification: Notification) {
        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadNotes()
    }
    
    private func loadNotes() {
        loadIndicator.isHidden = false
        loadIndicator.startAnimating()
        
        let loadNotesOperation = LoadNotesOperation(notebook: self.notebook, backendQueue: self.backendQueue, dbQueue: self.dbQueue, token: self.token ?? "", gistID: self.gistID ?? "", context: self.context)
        
        loadNotesOperation.completionBlock = { [weak self] in
            OperationQueue.main.addOperation {
                if let newNotebook = loadNotesOperation.result {
                    self?.notebook = newNotebook
                }
                
                self?.tableView.reloadData()
                self?.loadIndicator.isHidden = true
                self?.loadIndicator.stopAnimating()
            }
        }
        
        self.queue.addOperation(loadNotesOperation)
    }
}

