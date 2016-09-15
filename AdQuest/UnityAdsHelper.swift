//
//  UnityAdsHelper.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-04-04.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import Foundation

protocol UnityAdsHelperDelegate {
    func completedRewardedVideo()
    func completedInterstitial()
    func clickedAd()
    func noAd()
}

private let unityAdsHelper = UnityAdsHelper()

class UnityAdsHelper: NSObject, UnityAdsDelegate {
    
    var delegate : UnityAdsHelperDelegate?
    
    var clickedInterstitial = false
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UnityAdsHelper.applicationDidBecomeActive), name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }
    
    class var sharedInstance: UnityAdsHelper {
        return unityAdsHelper
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
    
    // MARK: - UnityAds Delegate Methods
    
    // Video
    func unityAdsVideoCompleted(_ rewardItemKey: String!, skipped: Bool) {
        //
    }
    
    func unityAdsDidHide() {}
    func unityAdsDidShow() {}
    func unityAdsWillHide() {}
    func unityAdsWillShow() {}
    func unityAdsFetchFailed() {}
    func unityAdsVideoStarted() {}
    func unityAdsFetchCompleted() {}
    func unityAdsWillLeaveApplication() {}
}
