//
//  UIColorExtension.swift
//  Notes
//
//  Created by ios_school on 2/5/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
    public func RGBComponents() -> [CGFloat] {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
            
        return [r, g, b, a]
    }
    
    var hexString: String {
        let rgb = RGBComponents()
        let rgbHex: Int = (Int(rgb[0] * 255) << 16) | (Int(rgb[1] * 255) << 8) | (Int(rgb[2] * 255) << 0)
        
        return String(format: "#%06x", rgbHex)
    }
    
    var brightness: CGFloat {
        var brightness: CGFloat = 0.0
        
        self.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        
        return brightness
    }
    
    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.count

        Scanner(string: hexNormalized).scanHexInt32(&rgb)

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
