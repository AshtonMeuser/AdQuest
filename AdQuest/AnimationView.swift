//
//  AnimationView.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-09-08.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    
    let adQuestHelper = AdQuestHelper.sharedInstance
    
    func imageCollectAnimation(_ center: CGPoint, quantity: Int, size: CGFloat, imageName: String, completion: @escaping () -> Void) {
        let radius = scaleRanges(Double(quantity), inMin: 10, inMax: 100, outMin: 120, outMax: 200)
        let animationDuration = 1.4
        
        let cent = CGPoint(x: center.x-size/2, y: center.y-size/2)
        
        for _ in 1...quantity {
            let theta = AdQuestHelper.sharedInstance.randFraction() * 2.0 * M_PI
            let r = Double(arc4random_uniform(UInt32(radius-80.0))) + 80.0
            let xNew = CGFloat(r*cos(theta)) + cent.x
            let yNew = CGFloat(r*sin(theta)) + cent.y
            let duration = TimeInterval(adQuestHelper.randFraction() * 0.7 + 0.2)
            
            let item = UIImageView()
            item.image = UIImage(named: imageName)
            item.frame = CGRect(x: cent.x, y: cent.y, width: size, height: size)
            
            self.addSubview(item)
            
            // Animation 1
            DispatchQueue.main.async(execute: {
                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    item.frame = CGRect(x: xNew, y: yNew, width: size, height: size)
                    }, completion: { animationFinished in
                        // Animation 2
                        DispatchQueue.main.async(execute: {
                            UIView.animate(withDuration: 0.3, delay: animationDuration-duration, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                item.frame = CGRect(x: cent.x, y: cent.y, width: size, height: size)
                                }, completion: { animationFinished in
                                    // Remove item
                                    item.removeFromSuperview()
                            })
                        })
                })
            })
        }
        
        // Wait before calling completion
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(animationDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            completion()
        }
    }
    
    func imageExplodeAnimation(_ center: CGPoint, quantity: Int, size: CGFloat, imageName: String) {
        let r = 500.0
        
        let cent = CGPoint(x: center.x-size/2, y: center.y-size/2)
        
        for counter in 1...quantity {
            let theta = adQuestHelper.randFraction() * 2.0 * M_PI
            let xNew = CGFloat(r*cos(theta)) + cent.x
            let yNew = CGFloat(r*sin(theta)) + cent.y
            let duration = TimeInterval((adQuestHelper.randFraction() + 0.5) * 2.0)
            
            let item = UIImageView()
            item.image = UIImage(named: imageName)
            item.frame = CGRect(x: cent.x, y: cent.y, width: size, height: size)
            self.addSubview(item)
            
            DispatchQueue.main.async(execute: {
                // Animation 1
                UIView.animate(withDuration: duration, delay: Double(counter)*0.015, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    item.frame = CGRect(x: xNew, y: yNew, width: size, height: size)
                    }, completion: { animationFinished in
                        // Remove item
                        item.removeFromSuperview()
                })
            })
        }
    }
    
    // MARK: - Helpers
    
    func scaleRanges(_ number: Double, inMin: Double, inMax: Double, outMin: Double, outMax: Double) -> Double {
        var out = (outMax - outMin) * (number - inMin) / (inMax - inMin) + outMin
        if out < outMin {
            out = outMin
        }else if out > outMax {
            out = outMax
        }
        return out
    }
}
