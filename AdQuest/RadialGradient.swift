//
//  RadialGradient.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-04-01.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import Foundation

class RadialGradient: UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        let gradientRef = CGGradient(colorsSpace: CGColorSpaceCreateDeviceGray(), colors: [UIColor.white.withAlphaComponent(1).cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray, locations: [0.0, 1.0])
        
        context?.drawRadialGradient(gradientRef!, startCenter: center, startRadius: 15, endCenter: center, endRadius: self.frame.width/2, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
}
