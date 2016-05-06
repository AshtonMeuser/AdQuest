//
//  AdMobHelper.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-03-27.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import Foundation
import GoogleMobileAds
import UIKit

protocol AdMobHelperDelegate {
    func completedInterstitial()
    func completedBanner()
    func clickedAd()
    func noAd()
}

enum AdType {
    case Banner, Interstitial
}

private let adMobHelper = AdMobHelper()

class AdMobHelper: NSObject, GADBannerViewDelegate, GADInterstitialDelegate {
    
    var delegate : AdMobHelperDelegate?
    
    var bannerView: GADBannerView?
    var interstitial: GADInterstitial?
    var clickedBanner = false
    var clickedAd: AdType?
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AdMobHelper.applicationDidBecomeActive), name: "applicationDidBecomeActive", object: nil)
    }
    
    class var sharedInstance: AdMobHelper {
        return adMobHelper
    }
    
    func cacheInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-5503249014811748/7516954952")

        if let inter = interstitial {
            inter.delegate = self
            // DEBUG
            let request = GADRequest()
            request.testDevices = ["e3237a34257e69c1d1c5b5dcbb0b2dcd"]
            inter.loadRequest(request)
        }
    }
    
    func showBannerAd(rootViewController: UIViewController, banner: GADBannerView) {
        bannerView = banner
        
        if let ban = bannerView {
            ban.delegate = self
            ban.adUnitID = "ca-app-pub-5503249014811748/4703089358"
            ban.rootViewController = rootViewController
            // DEBUG
            let request = GADRequest()
            request.testDevices = ["e3237a34257e69c1d1c5b5dcbb0b2dcd"]
            ban.loadRequest(request)
        }
    }
    
    func showInterstitial(rootViewController: UIViewController) -> Bool {
        if let inter = interstitial {
            if inter.isReady {
                inter.presentFromRootViewController(rootViewController)
                return true
            }else{
                cacheInterstitial()
            }
        }
        return false
    }
    
    func applicationDidBecomeActive() {
        print("return to app admob")
        if let type = clickedAd {
            switch type {
            case .Banner:
                delegate?.completedInterstitial()
            case .Interstitial:
                delegate?.completedBanner()
            }
            clickedAd = nil
        }
//        if clickedBanner == true {
//            clickedBanner = false
//            delegate?.completedBanner()
//        }
    }
    
    // MARK: - AdMob Delegate Methods
    
    // Banner
    func adViewWillLeaveApplication(bannerView: GADBannerView!) {
        clickedBanner = true
        clickedAd = .Banner
        delegate?.clickedAd()
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
            print("AdMob banner failed: \(error.localizedDescription)")
    }
    
    func adViewDidReceiveAd(bannerView: GADBannerView!) {}
    func adViewWillPresentScreen(bannerView: GADBannerView!) {}
    func adViewWillDismissScreen(bannerView: GADBannerView!) {}
    func adViewDidDismissScreen(bannerView: GADBannerView!) {}
    
    // Interstitial
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob interstitial failed: \(error.localizedDescription)")
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        print("dismiss admob")
        cacheInterstitial()
        delegate?.completedInterstitial()
    }
    
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        print("leave app admob")
        if clickedAd != .Banner {
            delegate?.clickedAd()
        }
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {}
    func interstitialDidReceiveAd(ad: GADInterstitial!) {}
    func interstitialWillPresentScreen(ad: GADInterstitial!) {}
}
