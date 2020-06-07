//
//  FeedbackViewController.swift
//  JogTracker
//
//  Created by Admin on 04/06/2020.
//  Copyright © 2020 nikmal. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {
    @IBOutlet weak var topicPickerView: UIPickerView!
    @IBOutlet weak var textView: UITextView!
    
    private let topics = [1, 2, 3, 5, 8]
    var curTopic = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
    }

}

extension FeedbackViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return topics.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(topics[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        curTopic = topics[row]
    }
}
