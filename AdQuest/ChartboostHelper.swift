//
//  ChartboostHelper.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-03-24.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import Foundation

protocol ChartboostHelperDelegate {
    func completedRewardedVideo()
    func completedInterstitial()
    func clickedAd()
    func noAd()
}

private let chartboostHelper = ChartboostHelper()

class ChartboostHelper: NSObject, ChartboostDelegate {
    
    var delegate : ChartboostHelperDelegate?
    
    var clickedInterstitial = false
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChartboostHelper.applicationDidBecomeActive), name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }
    
    class var sharedInstance: ChartboostHelper {
        return chartboostHelper
    }
    
    func cacheRewardedVideo() {
        Chartboost.cacheRewardedVideo(CBLocationDefault)
    }
    
    func cacheInterstitial() {
        Chartboost.cacheInterstitial(CBLocationDefault)
    }
    
    func showInterstitial(_ rootViewController: UIViewController) -> Bool {
        if Chartboost.hasInterstitial(CBLocationDefault) == true {
            Chartboost.showInterstitial(CBLocationDefault)
            return true
        }else{
            cacheInterstitial()
        }
        return false
    }
    
    func showRewardedVideo() -> Bool {
//        return false // DEBUG
        if Chartboost.hasRewardedVideo(CBLocationDefault) {
            Chartboost.showRewardedVideo(CBLocationDefault)
            return true
        }else{
            Chartboost.cacheRewardedVideo(CBLocationDefault)
        }
        return false
    }
    
    func applicationDidBecomeActive() {
        if clickedInterstitial == true {
            clickedInterstitial = false
            delegate?.completedInterstitial()
        }
    }
    
    // MARK: - Chartboost Delegate Methods
    
    // Rewarded video
    func didCompleteRewardedVideo(_ location: String!, withReward reward: Int32) {
        cacheRewardedVideo()
    }
    
    func didFail(toLoadRewardedVideo location: String!, withError error: CBLoadError) {
        print("Video load failed \(error.rawValue)")
    }
    
    func didClickRewardedVideo(_ location: String!) {
        delegate?.clickedAd()
    }
    
    func didDismissRewardedVideo(_ location: String!) {
        delegate?.completedRewardedVideo()
    }
    
    func didCacheRewardedVideo(_ location: String!) {}
    
    // Interstitial
    func didFail(toLoadInterstitial location: String!, withError error: CBLoadError) {
        print("Chartboost interstitial failed: \(error.rawValue)")
    }
    
//    func didDismissInterstitial(location: String!) {
//        cacheInterstitial()
//        delegate?.completedInterstitial()
//    }
    
    func didCloseInterstitial(_ location: String!) {
        cacheInterstitial()
        delegate?.completedInterstitial()
    }
    
    func didClickInterstitial(_ location: String!) {
        clickedInterstitial = true
        delegate?.clickedAd()
    }
    
    func didCacheInterstitial(_ location: String!) {}
}
