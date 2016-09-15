//
//  ProgressView.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-03-26.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import UIKit
import CoreGraphics

class ProgressView: UIView {
    
    let progressLine = CAShapeLayer()
    var currentAngle = -2.5 * M_PI + 0.01
    let lineWidth: CGFloat = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createProgress()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createProgress()
    }
    
    func createPath(_ startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let rect = CGRect(x: lineWidth/2, y: lineWidth/2, width: self.frame.width-lineWidth, height: self.frame.height-lineWidth)
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        
        return path.cgPath
    }
    
    func createProgress() {
        // Create line
        progressLine.path = createPath(CGFloat(-M_PI/2), endAngle: CGFloat(currentAngle))
        progressLine.strokeColor = self.tintColor.cgColor
        progressLine.fillColor = UIColor.clear.cgColor
        progressLine.lineWidth = lineWidth
        progressLine.lineCap = kCALineCapRound
        
        // Add line to view
        self.layer.insertSublayer(progressLine, above: self.layer)
    }
    
    func setProgress(_ fraction: Double = 0.0) {
        let frac = normalizeFraction(fraction)
        
        // Update path
        currentAngle = (-2.5 + 2 * frac) * M_PI + 0.01
        if currentAngle > -M_PI / 2 {
            currentAngle = -M_PI / 2 - 0.01
        }
        progressLine.path = createPath(CGFloat(-M_PI/2.0), endAngle: CGFloat(currentAngle))
    }
    
    func animateProgress(_ fraction: Double, completion: @escaping () -> Void) {
        let frac = normalizeFraction(fraction)
        
        // Update path
        var endAngle = (-2.5 + 2 * frac) * M_PI + 0.01
        if endAngle > -M_PI / 2 {
            endAngle = -M_PI / 2 - 0.01
        }
        progressLine.path = createPath(CGFloat(-M_PI/2.0), endAngle: CGFloat(endAngle))
        
        // Animate progress line from 0.0 to 1.0
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = ((fraction * 2 * M_PI) - (currentAngle + 2.5 * M_PI)) / M_PI * 1.5
        animateStrokeEnd.fromValue = (currentAngle + 2.5 * M_PI) / (fraction * 2 * M_PI)
        animateStrokeEnd.toValue = 1.0
        
        // Add animation
        progressLine.add(animateStrokeEnd, forKey: "animate stroke end animation")
        
        // Save progress
        currentAngle = (-2.5 + 2 * fraction) * M_PI - 0.01
        
        // Wait before calling completion
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(animateStrokeEnd.duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            completion()
        }
    }
    
    func resetProgress() {
        currentAngle = -2.5 * M_PI + 0.01
        progressLine.path = createPath(CGFloat(-M_PI/2), endAngle: CGFloat(currentAngle))
    }
    
    func normalizeFraction(_ fraction: Double) -> Double {
        if fraction > 1.0 {
            return 1.0
        }else if fraction < 0.0 {
            return 0.0
        }else{
            return fraction
        }
    }
}
