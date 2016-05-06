//
//  Home.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-03-23.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import UIKit
import AudioToolbox
import GoogleMobileAds

class Home: UIViewController, AdQuestHelperDelegate, ChartboostHelperDelegate, AdMobHelperDelegate, UnityAdsDelegate {
    
    let chartboostHelper: ChartboostHelper = ChartboostHelper.sharedInstance
    let adMobHelper = AdMobHelper.sharedInstance
    let adQuestHelper = AdQuestHelper.sharedInstance
    let unityAdsHelper = UnityAdsHelper.sharedInstance
    var iteration = 0

    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        

        // Set delegates
        chartboostHelper.delegate = self
        adMobHelper.delegate = self
        adQuestHelper.delegate = self
        Chartboost.setDelegate(chartboostHelper)
        
        // Load first ads
        chartboostHelper.cacheRewardedVideo()
        chartboostHelper.cacheInterstitial()
        adMobHelper.cacheInterstitial()
        adMobHelper.showBannerAd(self, banner: bannerView)
        progressView.setProgress(adQuestHelper.experienceFraction())
        updateLabels()
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showAd(sender: AnyObject) {
        print("Button pressed")
        
        
        
        // Alternate source of ads. DEBUG refactor
        if adQuestHelper.randFraction() < 0.33 {
            if chartboostHelper.showRewardedVideo() == false {
                if (iteration%2 == 0 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                    if (iteration%2 == 1 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                        imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Skull")
                    }
                }
            }
        }else{
            if (iteration%2 == 0 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                if (iteration%2 == 1 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                    imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Skull")
                }
            }
        }
        iteration += 1
    }
    
    @IBAction func testInterstitial(sender: AnyObject) {
        completedInterstitial()
    }
    
    @IBAction func testVideo(sender: AnyObject) {
        completedRewardedVideo()
    }
    
    @IBAction func reset(sender: AnyObject) {
        adQuestHelper.reset()
        progressView.setProgress()
        updateLabels()
    }
    
    @IBAction func test(sender: AnyObject) {
        UnityAds.sharedInstance().setZone("video")
        if UnityAds.sharedInstance().canShow() == true {
            UnityAds.sharedInstance().show()
        }else{
            print("UnityAds not ready")
        }
    }
    
    func updateLabels() {
        // DEBUG - probs dont need this function seeing as level is only label needing updating
        dispatch_async(dispatch_get_main_queue(),{
            self.updateLevelLabel(nil)
            self.experienceLabel.text = "Exp: \(self.adQuestHelper.getExperience())/\(self.adQuestHelper.experienceNeeded()) Luck: \(String(format: "%.5f", self.adQuestHelper.getLuck()))"
        })
    }
    
    func updateLevelLabel(level: Int?) {
        let lev = (level == nil) ? adQuestHelper.getLevel() : level
        
        dispatch_async(dispatch_get_main_queue(),{
            self.levelLabel.text = String(lev!)
        })
    }
    
    func scaleRanges(number: Double, inMin: Double, inMax: Double, outMin: Double, outMax: Double) -> Double {
        var out = (outMax - outMin) * (number - inMin) / (inMax - inMin) + outMin
        if out < outMin {
            out = outMin
        }else if out > outMax {
            out = outMax
        }
        return out
    }
    
    func addExperience(experience: Int) {
        var experienceGained = Int(Double(experience) * (adQuestHelper.randFraction() + 0.5) * adQuestHelper.clickBonus)
        
        if adQuestHelper.lucky() == true {
            experienceGained *= 5
            self.imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Clover")
        }
        
        print("Experience gained: \(experienceGained)")
        
        self.imageCollectAnimation(self.progressView.center, quantity: experienceGained/8+2, size: 30.0, imageName: "Coin", completion: {
            self.adQuestHelper.incrementExperience(experienceGained, completion: { timesLevelUp in
                self.levelUp(timesLevelUp, completion: {
                    self.progressView.animateProgress(self.adQuestHelper.experienceFraction(), completion: {
                        self.updateLabels()
                    })
                })
            })
        })
    }
    
    func levelUp(times: Int, completion: () -> Void) {
        if times > 0 {
            self.progressView.animateProgress(1.0, completion: {
                self.progressView.setProgress()
                self.imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Star")
                self.updateLevelLabel(self.adQuestHelper.getLevel() - times + 1)
                self.levelUp(times - 1, completion: completion)
            })
        }else{
            completion()
        }
    }
    
    // MARK: - UnityAds delegate methods
    
    func unityAdsVideoCompleted(rewardItemKey: String!, skipped: Bool) {
        print("completed unity ad")
    }
    
    // MARK: - AdQuestHelper delegate methods
    
    // MARK: - ChartboostHelper, AdMobHelper delegate methods
    
    func completedInterstitial() {
        print("Completed interstitial")
        addExperience(20)
    }
    
    func completedRewardedVideo() {
        print("Completed video")
        addExperience(80)
    }
    
    func completedBanner() {
        print("Completed banner")
        addExperience(20)
    }
    
    func clickedAd() {
        print("Clicked ad")
        adQuestHelper.clickBonus = 3.0
    }
    
    func noAd() {
        print("No ad")
    }
    
    // MARK: - Navigation

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//    }
    
    // MARK: - Animation
    
    func imageCollectAnimation(center: CGPoint, quantity: Int, size: CGFloat, imageName: String, completion: () -> Void) {
        let radius = scaleRanges(Double(quantity), inMin: 10, inMax: 100, outMin: 120, outMax: 200)
        let animationDuration = 1.4
        
        let cent = CGPointMake(center.x-size/2, center.y-size/2)
        
        for _ in 1...quantity {
            let theta = adQuestHelper.randFraction() * 2.0 * M_PI
            let r = Double(arc4random_uniform(UInt32(radius-80.0))) + 80.0
            let xNew = CGFloat(r*cos(theta)) + cent.x
            let yNew = CGFloat(r*sin(theta)) + cent.y
            let duration = NSTimeInterval(adQuestHelper.randFraction() * 0.7 + 0.2)
            
            let item = UIImageView()
            item.image = UIImage(named: imageName)
            item.frame = CGRectMake(cent.x, cent.y, size, size)
            
            self.view.insertSubview(item, belowSubview: progressView)
            
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
            self.view.insertSubview(item, belowSubview: progressView)
            
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
}
