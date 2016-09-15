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
    case banner, interstitial
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdMobHelper.applicationDidBecomeActive), name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
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
            inter.load(request)
        }
    }
    
    func showBannerAd(_ rootViewController: UIViewController, banner: GADBannerView) {
        bannerView = banner
        
        if let ban = bannerView {
            ban.delegate = self
            ban.adUnitID = "ca-app-pub-5503249014811748/4703089358"
            ban.rootViewController = rootViewController
            // DEBUG
            let request = GADRequest()
            request.testDevices = ["e3237a34257e69c1d1c5b5dcbb0b2dcd"]
            ban.load(request)
        }
    }
    
    func showInterstitial(_ rootViewController: UIViewController) -> Bool {
        if let inter = interstitial {
            if inter.isReady {
                inter.present(fromRootViewController: rootViewController)
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
            case .banner:
                delegate?.completedInterstitial()
            case .interstitial:
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
    func adViewWillLeaveApplication(_ bannerView: GADBannerView!) {
        clickedBanner = true
        clickedAd = .banner
        delegate?.clickedAd()
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
            print("AdMob banner failed: \(error.localizedDescription)")
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {}
    func adViewWillPresentScreen(_ bannerView: GADBannerView!) {}
    func adViewWillDismissScreen(_ bannerView: GADBannerView!) {}
    func adViewDidDismissScreen(_ bannerView: GADBannerView!) {}
    
    // Interstitial
    func interstitial(_ ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob interstitial failed: \(error.localizedDescription)")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        print("dismiss admob")
        cacheInterstitial()
        delegate?.completedInterstitial()
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial!) {
        print("leave app admob")
        if clickedAd != .banner {
            delegate?.clickedAd()
        }
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial!) {}
    func interstitialDidReceiveAd(_ ad: GADInterstitial!) {}
    func interstitialWillPresentScreen(_ ad: GADInterstitial!) {}
}
