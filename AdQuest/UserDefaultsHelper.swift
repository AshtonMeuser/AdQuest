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
    let defaults = NSUserDefaults.standardUserDefaults()
    
    class var sharedInstance: UserDefaultsHelper {
        return userDefaultsHelper
    }
    
    func get(name: String) -> AnyObject? {
        return defaults.objectForKey(name)
    }
    
    func set(name: String, value: AnyObject) {
        defaults.setObject(value, forKey: name)
    }
}

