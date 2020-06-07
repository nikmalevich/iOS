//
//  EditNoteView.swift
//  Notes
//
//  Created by ios_school on 2/7/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class EditNoteViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var colorsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var noteContentHeight: NSLayoutConstraint!
    @IBOutlet weak var noteContent: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var whiteView: SetColorView!
    @IBOutlet weak var redView: SetColorView!
    @IBOutlet weak var greenView: SetColorView!
    @IBOutlet weak var customColorView: SetColorView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var note: Note?
    var addOrEditNote: ((Note) -> Void)?
    
    private var currentColor: UIColor {
        if whiteView.isActive {
            return .white
        }
        else if redView.isActive {
            return .red
        }
        else if greenView.isActive {
            return .green
        }
        else {
            return customColorView.backgroundColor ?? .black
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if dateSwitch.isOn {
            datePicker.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.colorsTopConstraint.constant = self.datePicker.bounds.height
                self.view.layoutIfNeeded()
            })
        } else {
            datePicker.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.colorsTopConstraint.constant = 15
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func whiteTapped(_ sender: UITapGestureRecognizer) {
        setFlag(with: .white)
    }
    
    @IBAction func redTapped(_ sender: UITapGestureRecognizer) {
        setFlag(with: .red)
    }
    
    @IBAction func greenTapped(_ sender: UITapGestureRecognizer) {
        setFlag(with: .green)
    }
    
    @IBAction func customColorTapped(_ sender: UITapGestureRecognizer) {
        if !customColorView.isColorSelected {
            contentView.endEditing(true)
            
            performSegue(withIdentifier: "ColorPickerSegue", sender: nil)
        }
        
        setFlag(with: .black)
    }
    
    @IBAction func customColorLongTapped(_ sender:
        UILongPressGestureRecognizer) {
        if sender.state == .began {
            contentView.endEditing(true)
            
            performSegue(withIdentifier: "ColorPickerSegue", sender: nil)
        
            setFlag(with: .black)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ColorPickerViewController, segue.identifier == "ColorPickerSegue" {
            controller.setCurrentColor = { [weak self] in
                controller.colorPickerView.currentColorView.backgroundColor = self?.customColorView.backgroundColor
                controller.colorPickerView.currentColorLabel.text = self?.customColorView.backgroundColor?.hexString
                
                let brightness = Float(self?.customColorView.backgroundColor?.brightness ?? 1.0)
                if brightness == 0.0 {
                    controller.colorPickerView.currentBrightnessSlider.value = 1.0
                } else {
                    controller.colorPickerView.currentBrightnessSlider.value = brightness
                }
            }
            controller.setCustomColor = { [weak self] color in
                self?.customColorView.backgroundColor = color
                self?.customColorView.isColorSelected = true
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if titleTextField.text == "" {
            createAlert(message: "Вы не ввели заголовок заметки")
        } else if noteContent.text == "" {
            createAlert(message: "Вы не ввели текст заметки")
        } else {
            guard let title = titleTextField.text else { return }
            let color = currentColor
            let selfDestructionDate: Date?
                
            if dateSwitch.isOn {
                selfDestructionDate = datePicker.date
            } else {
                selfDestructionDate = nil
            }
            
            let newNote: Note
            
            if let uid = note?.uid {
                newNote = Note(uid: uid, title: title, content: noteContent.text, color: color, importance: .common, selfDestructionDate: selfDestructionDate)
            } else {
                newNote = Note(title: title, content: noteContent.text, color: color, importance: .common, selfDestructionDate: selfDestructionDate)
            }
                
            addOrEditNote?(newNote)
            performSegue(withIdentifier: "backToNotesVC", sender: nil)
        }
    }
    
    private func createAlert(message: String) {
        let alert = UIAlertController(title: "Неверные данные", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToEditNoteVC(segue: UIStoryboardSegue) {
    }
    
    func textViewDidChange(_ textView: UITextView) {
        noteContentHeight.constant = textView.intrinsicContentSize.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteContent.delegate = self
        
        whiteView.layer.borderWidth = 1
        whiteView.layer.borderColor = UIColor.black.cgColor
        whiteView.isActive = true
        redView.layer.borderWidth = 1
        redView.layer.borderColor = UIColor.black.cgColor
        greenView.layer.borderWidth = 1
        greenView.layer.borderColor = UIColor.black.cgColor
        customColorView.isColorSelected = false
        customColorView.layer.borderWidth = 1
        customColorView.layer.borderColor = UIColor.black.cgColor
        noteContentHeight.constant = 40
        noteContent.layer.borderWidth = 1
        noteContent.layer.borderColor = UIColor.black.cgColor
        
        if let note = note {
            titleTextField.text = note.title
            noteContent.text = note.content
            noteContentHeight.constant = noteContent.intrinsicContentSize.height
            let color = note.color
            setFlag(with: color)
            
            if (color != .white) && (color != .red) && (color != .green) {
                customColorView.isColorSelected = true
                customColorView.backgroundColor = note.color
            }
            
            if let selfDestructionDate = note.selfDestructionDate {
                dateSwitch.isOn = true
                datePicker.date = selfDestructionDate
                datePicker.isHidden = false
                colorsTopConstraint.constant = datePicker.bounds.height
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            bottomConstraint.constant = keyboardFrame.cgRectValue.height
        }
    }
    
    @objc private func keyboardWillDisappear() {
        bottomConstraint.constant = 35
    }
    
    private func setFlag(with color: UIColor) {
        whiteView.isActive = false
        redView.isActive = false
        greenView.isActive = false
        customColorView.isActive = false
        
        switch color {
        case .white:
            whiteView.isActive = true
        case .red:
            redView.isActive = true
        case .green:
            greenView.isActive = true
        default:
            customColorView.isActive = true
        }
    }
}
