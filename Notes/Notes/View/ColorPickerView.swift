//
//  ColorPickerView.swift
//  Notes
//
//  Created by ios_school on 2/9/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

@IBDesignable
class ColorPickerView: UIView {
    @IBOutlet weak var colorPaletteView: ColorPaletteView!
    @IBOutlet weak var currentColorView: UIView!
    @IBOutlet weak var currentBrightnessSlider: UISlider!
    @IBOutlet weak var currentColorLabel: UILabel!
    
    var currentLocation = CGPoint(x: 0, y: 0)
    var colorSelected: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    private func setupViews() {
        let xibView = loadViewFromXib()
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ColorPickerView", bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }
    
    @IBAction func drivesColorPalette(_ sender: UIPanGestureRecognizer) {
        currentLocation = sender.location(in: colorPaletteView)
        
        let color = colorPaletteView.color(point: currentLocation, brightness: CGFloat(currentBrightnessSlider?.value ?? 1))
        
        currentColorView.backgroundColor = color
        currentColorLabel.text = color.hexString
    }
    
    @IBAction func currentBrightnessSliderChanged(_ sender: UISlider) {
        let color = colorPaletteView.color(point: currentLocation, brightness: CGFloat(sender.value))
        
        currentColorView.backgroundColor = color
        currentColorLabel.text = color.hexString
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        colorSelected?()
    }
}
