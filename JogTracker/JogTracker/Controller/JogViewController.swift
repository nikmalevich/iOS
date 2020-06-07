//
//  NewJogViewController.swift
//  JogTracker
//
//  Created by Admin on 03/06/2020.
//  Copyright © 2020 nikmal. All rights reserved.
//

import UIKit

class JogViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    var jog: GetJog?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.minimumDate = Date()
        
        guard let jog = jog else { return }
        
        datePicker.date = Date(timeIntervalSince1970: jog.date)
        distanceTextField.text = String(jog.distance)
        timeTextField.text = String(jog.time)
    }

}
