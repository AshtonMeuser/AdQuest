//
//  RadialGradient.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-04-01.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import Foundation

class RadialGradient: UIView {
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let center = CGPointMake(self.frame.width/2, self.frame.height/2)
        let gradientRef = CGGradientCreateWithColors(CGColorSpaceCreateDeviceGray(), [UIColor.whiteColor().colorWithAlphaComponent(1).CGColor, UIColor.whiteColor().colorWithAlphaComponent(0).CGColor] as CFArrayRef, [0.0, 1.0])
        
        CGContextDrawRadialGradient(context, gradientRef, center, 15, center, self.frame.width/2, CGGradientDrawingOptions.DrawsBeforeStartLocation)
    }
}
