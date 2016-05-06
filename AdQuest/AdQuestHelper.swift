//
//  AdQuestHelper.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-03-24.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import Foundation

protocol AdQuestHelperDelegate {
}

private let adQuestHelper = AdQuestHelper()

class AdQuestHelper: NSObject {
    
    var delegate : AdQuestHelperDelegate?
    private let userDefaultsHelper = UserDefaultsHelper.sharedInstance
    
    private var _clickBonus = 1.0
    var clickBonus: Double {
        set {
            _clickBonus = newValue
        }
        get {
            let bonus = _clickBonus
            _clickBonus = 1.0
            
            return bonus
        }
    }
    
    let levelFulcrum = 5.0
    let luckLow = 0.05
    let luckHigh = 0.2
    let expLow = 100.0
    let expMid = 500.0
    let expHigh = 2000.0
    
    override init() {
        
    }
    
    class var sharedInstance: AdQuestHelper {
        return adQuestHelper
    }
    
    func randFraction() -> Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
    
    func lucky() -> Bool {
        return (randFraction() < getLuck()) ? true : false
    }
    
    func getLuck() -> Double {
        let level = Double(getLevel())
        
        if level < levelFulcrum {
            return luckHigh - level * (luckHigh - luckLow) / levelFulcrum
        }else{
            return luckHigh - levelFulcrum * (luckHigh - luckLow) / level
        }
    }
    
    func experienceNeeded() -> Int {
        let level = Double(getLevel())
        
        if level < levelFulcrum {
            return Int(expLow + level * (expMid - expLow) / levelFulcrum)
        }else{
            return Int(expHigh - (expHigh - expMid) * levelFulcrum * 5 / (level + 4 * levelFulcrum))
        }
    }
    
    func experienceFraction() -> Double {
        return Double(getExperience())/Double(experienceNeeded())
    }
    
    func reset() {
        userDefaultsHelper.set("level", value: 0)
        userDefaultsHelper.set("experience", value: 0)
    }
    
    func getLevel() -> Int {
        if let level = userDefaultsHelper.get("level") as? Int {
            return level
        }else{
            return 0
        }
    }
    
    func getExperience() -> Int {
        if let experience = userDefaultsHelper.get("experience") as? Int {
            return experience
        }else{
            return 0
        }
    }
    
    func incrementLevel(increment: Int) {
        userDefaultsHelper.set("level", value: getLevel() + increment)
    }
    
    func incrementExperience(increment: Int, completion: (timesLevelUp: Int) -> Void) {
        var experience = getExperience()
        var needed = experienceNeeded()
        var timesLevelUp = 0
        
        while experience + increment >= needed {
            timesLevelUp += 1
            experience -= needed
            needed = experienceNeeded()
        }
        
        incrementLevel(timesLevelUp)
        userDefaultsHelper.set("experience", value: experience + increment)
        completion(timesLevelUp: timesLevelUp)
    }
}

