//
//  ColorPaletteView.swift
//  Notes
//
//  Created by ios_school on 2/9/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class ColorPaletteView: UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for y: CGFloat in stride(from: 0.0, to: rect.height, by: 1) {
            let saturation: CGFloat = (rect.height - y) / rect.height
            
            for x: CGFloat in stride(from: 0.0 ,to: rect.width, by: 1) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: 1)
                
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }
    
    public func color(point: CGPoint, brightness: CGFloat) -> UIColor {
        let hue = point.x / bounds.width
        let saturation = (bounds.height - point.y) / bounds.height
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
