//
//  Tweet.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/29/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import Foundation

class Tweet: NSObject {
    var id: String?
    var user: User?
    var text: String?
    var timestamp : NSDate?
    var isRetweet = false
    var retweetName: String?
    
    var numRetweets = 0
    var numFavorites = 0
    var favorited = false
    var retweeted = false
    
    init(dictionary: NSDictionary) {
        var dic = dictionary

        if let reweetDic = dictionary["retweeted_status"] as? NSDictionary,
            let userDic = dictionary["user"] as? NSDictionary {
            let retweetUser = User(dictionary: userDic)
            
            retweetName = retweetUser.name
            
            dic = reweetDic
            
            isRetweet = true
        }
        
        id = "\(dic["id"]!)"
        
        user = User(dictionary: dic["user"] as! NSDictionary)
        text = dic["text"] as? String
        numRetweets  = dic["retweet_count"] as! Int
        numFavorites  = dic["favorite_count"] as! Int
        favorited  = dic["favorited"] as! Bool
        retweeted  = dic["retweeted"] as! Bool
        
        let timestampString = dic["created_at"] as? String
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)! as NSDate?
        }
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
    func updateFromDic(dic:NSDictionary) {
        let tweet = Tweet(dictionary: dic)
        self.id = tweet.id
        self.user = tweet.user
        self.text = tweet.text

        
        self.numRetweets = tweet.numRetweets
        self.numFavorites = tweet.numFavorites
        self.retweeted = tweet.retweeted
        self.favorited = tweet.favorited
    }

    func timeString() -> String {
        return timeAgo(sinceDate: self.timestamp!, numericDates: true) ?? ""
    }
    
    func timeAgo(sinceDate date:NSDate, numericDates:Bool) -> String? {
        let calendar = NSCalendar.current
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date as Date : now as Date
        
        let components:DateComponents = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear, .month, . year], from: earliest as Date, to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!)year"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1mon ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)week"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) day"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hour"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1h ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            // minutes ago
            return "\(components.minute!) min"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 min"
            } else {
                return "A min"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!)sec"
        } else {
            return "Just Now"
        }
    }

}
