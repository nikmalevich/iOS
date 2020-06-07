//
//  ColorPickerViewController.swift
//  Notes
//
//  Created by ios_school on 2/16/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    var setCurrentColor: (() -> Void)?
    var setCustomColor: ((UIColor) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorPickerView.colorPaletteView.layer.borderWidth = 1
        colorPickerView.colorPaletteView.layer.borderColor = UIColor.black.cgColor
        colorPickerView.currentColorView.layer.borderWidth = 1
        colorPickerView.currentColorView.layer.borderColor = UIColor.black.cgColor
        colorPickerView.currentColorView.layer.cornerRadius = 10
        setCurrentColor?()
        colorPickerView.colorSelected = { [weak self] in
            self?.performSegue(withIdentifier: "BackEditNoteSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EditNoteViewController, segue.identifier == "BackEditNoteSegue" {
            setCustomColor?(colorPickerView.currentColorView.backgroundColor ?? .black)
        }
    }

}
