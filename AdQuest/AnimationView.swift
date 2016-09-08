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
    
    func imageCollectAnimation(center: CGPoint, quantity: Int, size: CGFloat, imageName: String, completion: () -> Void) {
        let radius = scaleRanges(Double(quantity), inMin: 10, inMax: 100, outMin: 120, outMax: 200)
        let animationDuration = 1.4
        
        let cent = CGPointMake(center.x-size/2, center.y-size/2)
        
        for _ in 1...quantity {
            let theta = AdQuestHelper.sharedInstance.randFraction() * 2.0 * M_PI
            let r = Double(arc4random_uniform(UInt32(radius-80.0))) + 80.0
            let xNew = CGFloat(r*cos(theta)) + cent.x
            let yNew = CGFloat(r*sin(theta)) + cent.y
            let duration = NSTimeInterval(adQuestHelper.randFraction() * 0.7 + 0.2)
            
            let item = UIImageView()
            item.image = UIImage(named: imageName)
            item.frame = CGRectMake(cent.x, cent.y, size, size)
            
            self.addSubview(item)
            
            // Animation 1
            dispatch_async(dispatch_get_main_queue(),{
                UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    item.frame = CGRectMake(xNew, yNew, size, size)
                    }, completion: { animationFinished in
                        // Animation 2
                        dispatch_async(dispatch_get_main_queue(),{
                            UIView.animateWithDuration(0.3, delay: animationDuration-duration, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                item.frame = CGRectMake(cent.x, cent.y, size, size)
                                }, completion: { animationFinished in
                                    // Remove item
                                    item.removeFromSuperview()
                            })
                        })
                })
            })
        }
        
        // Wait before calling completion
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animationDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            completion()
        }
    }
    
    func imageExplodeAnimation(center: CGPoint, quantity: Int, size: CGFloat, imageName: String) {
        let r = 500.0
        
        let cent = CGPointMake(center.x-size/2, center.y-size/2)
        
        for counter in 1...quantity {
            let theta = adQuestHelper.randFraction() * 2.0 * M_PI
            let xNew = CGFloat(r*cos(theta)) + cent.x
            let yNew = CGFloat(r*sin(theta)) + cent.y
            let duration = NSTimeInterval((adQuestHelper.randFraction() + 0.5) * 2.0)
            
            let item = UIImageView()
            item.image = UIImage(named: imageName)
            item.frame = CGRectMake(cent.x, cent.y, size, size)
            self.addSubview(item)
            
            dispatch_async(dispatch_get_main_queue(),{
                // Animation 1
                UIView.animateWithDuration(duration, delay: Double(counter)*0.015, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    item.frame = CGRectMake(xNew, yNew, size, size)
                    }, completion: { animationFinished in
                        // Remove item
                        item.removeFromSuperview()
                })
            })
        }
    }
    
    // MARK: - Helpers
    
    func scaleRanges(number: Double, inMin: Double, inMax: Double, outMin: Double, outMax: Double) -> Double {
        var out = (outMax - outMin) * (number - inMin) / (inMax - inMin) + outMin
        if out < outMin {
            out = outMin
        }else if out > outMax {
            out = outMax
        }
        return out
    }
}
