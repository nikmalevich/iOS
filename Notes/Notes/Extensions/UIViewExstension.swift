//
//  ColorView.swift
//  Notes
//
//  Created by ios_school on 2/8/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

extension UIView {
    func drawFlag(using context: CGContext) {
        let centerPoint = CGPoint(x: bounds.width * 3 / 4, y: bounds.height / 4)
        let radius = bounds.height / 6
            
        context.addArc(center: centerPoint, radius: radius, startAngle: CGFloat(0).degreesToRadiant, endAngle: CGFloat(360).degreesToRadiant, clockwise: true)
        context.move(to: CGPoint(x: centerPoint.x - radius / 2, y: centerPoint.y))
        context.addLine(to: CGPoint(x: centerPoint.x, y: centerPoint.y + radius / 2))
        context.addLine(to: CGPoint(x: centerPoint.x + radius / 2, y: centerPoint.y - radius / 2))
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()
    }
}
