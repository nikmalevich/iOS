//
//  ColorView.swift
//  Notes
//
//  Created by ios_school on 2/19/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class SetColorView: UIView {
    var isColorSelected = true {
        didSet {
            setNeedsDisplay()
        }
    }
    var isActive = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isColorSelected {
            if isActive {
                super.drawFlag(using: context)
            }
        } else {
            for y: CGFloat in stride(from: 0.0 ,to: rect.height, by: 1.0) {
                let saturation: CGFloat
                let brightness: CGFloat
                
                if y < rect.height / 2.0 {
                    saturation = 2.0 * y / rect.height
                    brightness = 1.0
                } else {
                    saturation = 2.0 * (rect.height - y) / rect.height
                    brightness = 2.0 * (rect.height - y) / rect.height
                }
                
                for x : CGFloat in stride(from: 0.0 ,to: rect.width, by: 1.0) {
                    let hue = x / rect.width
                    let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                    
                    context.setFillColor(color.cgColor)
                    context.fill(CGRect(x: x, y: y, width: 1,height: 1))
                }
            }
        }
    }

}
