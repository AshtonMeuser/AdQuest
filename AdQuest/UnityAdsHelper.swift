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
    
    var clickedVideo = false
    
    override init() {
        super.init()
        
        UnityAds.sharedInstance().setZone("video")
        UnityAds.sharedInstance().delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(UnityAdsHelper.applicationDidBecomeActive), name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }
    
    class var sharedInstance: UnityAdsHelper {
        return unityAdsHelper
    }
    
    func showRewardedVideo() -> Void {
        UnityAds.sharedInstance().show()
    }
    
    func applicationDidBecomeActive() {
        if clickedVideo == true {
            clickedVideo = false
            delegate?.completedInterstitial()
        }
    }
    
    // MARK: - UnityAds Delegate Methods
    
    // Video
    func unityAdsVideoCompleted(_ rewardItemKey: String!, skipped: Bool) {
        delegate?.completedRewardedVideo()
    }
    
    func unityAdsDidHide() {}
    func unityAdsDidShow() {}
    func unityAdsWillHide() {}
    func unityAdsWillShow() {}
    func unityAdsFetchFailed() {}
    func unityAdsVideoStarted() {}
    func unityAdsFetchCompleted() {}
    func unityAdsWillLeaveApplication() {
        clickedVideo = true
        delegate?.clickedAd()
    }
}
