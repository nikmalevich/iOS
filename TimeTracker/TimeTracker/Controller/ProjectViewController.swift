//
//  ProjectViewController.swift
//  TimeTracker
//
//  Created by Admin on 19/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Firebase

class ProjectViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
    }
}
