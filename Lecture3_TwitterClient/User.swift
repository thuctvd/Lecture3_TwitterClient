//
//  User.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/29/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit
var _currentUser: User?
let currentUserKey = "currentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User {
    
    var name: String?
    var screenName: String?
    var profileImageUrl: String?
    var tagline: String?
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        self.name = dictionary["name"] as? String
        self.screenName = dictionary["screen_name"] as? String
        self.profileImageUrl = dictionary["profile_image_url"] as? String
        self.tagline = dictionary["description"] as? String
    }
    
    static var currentUser:User? {
        get {
            if _currentUser == nil {
                let data = UserDefaults.standard.object(forKey: currentUserKey) as? NSData
                if data != nil {
                    let dictionary = try! JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                let data = try! JSONSerialization.data(withJSONObject: (user?.dictionary)!, options: .prettyPrinted)
                UserDefaults.standard.set(data, forKey: currentUserKey)
                
            } else {
                UserDefaults.standard.set(nil, forKey: currentUserKey)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: userDidLogoutNotification), object: nil)
    }
}
