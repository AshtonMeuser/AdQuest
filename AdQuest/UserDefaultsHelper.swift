//
//  UserDefaultsHelper.swift
//  AdQuest
//
//  Created by Ashton Meuser on 2016-03-24.
//  Copyright © 2016 Ashton Meuser. All rights reserved.
//

import Foundation

protocol UserDefaulsHelperDelegate {
}

private let userDefaultsHelper = UserDefaultsHelper()

class UserDefaultsHelper: NSObject {
    
    var delegate : UserDefaulsHelperDelegate?
    let defaults = UserDefaults.standard
    
    class var sharedInstance: UserDefaultsHelper {
        return userDefaultsHelper
    }
    
    func get(_ name: String) -> AnyObject? {
        return defaults.object(forKey: name) as AnyObject?
    }
    
    func set(_ name: String, value: AnyObject) {
        defaults.set(value, forKey: name)
    }
}

