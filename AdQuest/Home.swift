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
    @IBOutlet weak var animationView: AnimationView!
    
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
    
    @IBAction func showAd(_ sender: AnyObject) {
        print("Button pressed")
        
        
        
        // Alternate source of ads. DEBUG refactor
        if adQuestHelper.randFraction() < 0.33 {
            if chartboostHelper.showRewardedVideo() == false {
                if (iteration%2 == 0 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                    if (iteration%2 == 1 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                        animationView.imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Skull")
                    }
                }
            }
        }else{
            if (iteration%2 == 0 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                if (iteration%2 == 1 ? adMobHelper.showInterstitial(self) : chartboostHelper.showInterstitial(self)) == false {
                    animationView.imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Skull")
                }
            }
        }
        iteration += 1
    }
    
    @IBAction func testInterstitial(_ sender: AnyObject) {
        completedInterstitial()
    }
    
    @IBAction func testVideo(_ sender: AnyObject) {
        completedRewardedVideo()
    }
    
    @IBAction func reset(_ sender: AnyObject) {
        adQuestHelper.reset()
        progressView.setProgress()
        updateLabels()
    }
    
    @IBAction func test(_ sender: AnyObject) {
        UnityAds.sharedInstance().setZone("video")
        // DEBUG - Known bug https://devforums.apple.com/thread/229668?tstart=0
        let tempBool = true
        if tempBool {
            UnityAds.sharedInstance().show()
        }else{
            print("UnityAds not ready")
        }
    }
    
    func updateLabels() {
        // DEBUG - probs dont need this function seeing as level is only label needing updating
        DispatchQueue.main.async(execute: {
            self.updateLevelLabel(nil)
            self.experienceLabel.text = "Exp: \(self.adQuestHelper.getExperience())/\(self.adQuestHelper.experienceNeeded()) Luck: \(String(format: "%.5f", self.adQuestHelper.getLuck()))"
        })
    }
    
    func updateLevelLabel(_ level: Int?) {
        let lev = (level == nil) ? adQuestHelper.getLevel() : level
        
        DispatchQueue.main.async(execute: {
            self.levelLabel.text = String(lev!)
        })
    }
    
    func addExperience(_ experience: Int) {
        var experienceGained = Int(Double(experience) * (adQuestHelper.randFraction() + 0.5) * adQuestHelper.clickBonus)
        
        if adQuestHelper.lucky() == true {
            experienceGained *= 5
            animationView.imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Clover")
        }
        
        print("Experience gained: \(experienceGained)")
        
        animationView.imageCollectAnimation(self.progressView.center, quantity: experienceGained/8+2, size: 30.0, imageName: "Coin", completion: {
            self.adQuestHelper.incrementExperience(experienceGained, completion: { timesLevelUp in
                self.levelUp(timesLevelUp, completion: {
                    self.progressView.animateProgress(self.adQuestHelper.experienceFraction(), completion: {
                        self.updateLabels()
                    })
                })
            })
        })
    }
    
    func levelUp(_ times: Int, completion: @escaping () -> Void) {
        if times > 0 {
            self.progressView.animateProgress(1.0, completion: {
                self.progressView.setProgress()
                self.animationView.imageExplodeAnimation(self.progressView.center, quantity: 50, size: 30.0, imageName: "Star")
                self.updateLevelLabel(self.adQuestHelper.getLevel() - times + 1)
                self.levelUp(times - 1, completion: completion)
            })
        }else{
            completion()
        }
    }
    
    // MARK: - UnityAds delegate methods
    
    func unityAdsVideoCompleted(_ rewardItemKey: String!, skipped: Bool) {
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
}
