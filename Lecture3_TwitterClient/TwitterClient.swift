//
//  TwitterClient.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/29/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "neaLRJESozIcazskqLocrIU7i" //"JxUiG0fZyXliskmGJZYLjZcc4" //"Sz6KQ6wwxhsMy149tp7BBqswr"
let twitterConsumerSecret = "40thao2Bw7jiQXZi7wb2cDnn69ACWWlDpyN84ULang4R2YtN9a" //"2rW7IMZQ9Iz73JTwm800PGoaRHTPa3Vz59nDRXx2I1NIEaiipo" //"DEzlIwwdYMBmCYpOlvRlxmzPH5RbNHfdyrpoTsUw8AIJvLu2Qw"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((_ user: User?, _ error: Error?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL as URL!, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance!
    }
    
    func loginWithCompletion(completion: @escaping (_ user: User?,_ error:Error?) -> Void) {
        loginCompletion = completion
        self.requestSerializer.removeAccessToken()
        self.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterclientthuctvd://oauth"), scope: nil,
                                       success: { (credential: BDBOAuth1Credential?) -> Void in
                                        
                                        let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(credential!.token!)")!
                                        print("have got request token")
                                        UIApplication.shared.open(authURL, options: [:], completionHandler: nil)
            }, failure:  { (error: Error?) -> Void in
                print("\(error?.localizedDescription)")
        })
    }
    
    func openURL(url: URL) {
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query!),
                                      success: { (credential:BDBOAuth1Credential?) -> Void in
                                        self.requestSerializer.saveAccessToken(credential)
                                        self.get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (urlSessionDataTask, response) in
                                                let user = User(dictionary: response as! NSDictionary)
                                                User.currentUser = user
                                                self.loginCompletion?(user, nil)
                                                print("have got access token")
                                            }, failure: { (urlSessionDataTask, error) in
                                                print("\(error.localizedDescription)")
                                        })
            },
                                      failure: { (error:Error?) -> Void in
                                        print("\(error?.localizedDescription)")
            }
        )
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()) {
        TwitterClient.sharedInstance.get("1.1/statuses/home_timeline.json", parameters: params, progress: nil,
            success: { (urlSessionDataTask, response) in
                print("have got timeline fetch success")
                let tweets = Tweet.tweetsWithArray(array: response as! [NSDictionary])
                completion(tweets, nil)
            },
            failure: { (task: URLSessionDataTask?, error:Error?) -> Void in
                completion(nil, error)
            }
        )
    }
    
    func tweet(message:String, callBack: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        let params = [
            "status": message
        ]
        TwitterClient.sharedInstance.post("1.1/statuses/update.json", parameters: params, progress: nil,
            success: { (urlsessionTask, response) in
                callBack(response as? NSDictionary, nil)
            },
            failure: { (task: URLSessionDataTask?, error:Error?) -> Void in
                callBack(nil, error)
                print("tweet error")
                print("\(error?.localizedDescription)")
            }
        )
    }
    
    func retweet(id:String, callBack: @escaping (_ response:NSDictionary?, _ error:Error?) -> ()) {
        TwitterClient.sharedInstance.post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil,
            success: { (urlsessionTask, response) in
                callBack(response as? NSDictionary, nil)
            },
            failure: { (task: URLSessionDataTask?, error:Error?) -> Void in
                callBack(nil, error)
            })
    }
    
    func unretweet(id:String, callBack: @escaping (_ response:NSDictionary?, _ error:Error?) -> ()) {
        TwitterClient.sharedInstance.get("1.1/statuses/show/\(id).json?include_my_retweet=1", parameters: nil, progress: nil, success: { (urlsessionTask, response) in
            if  let dic = response as? NSDictionary,
                let current_user_retweet = dic["current_user_retweet"] as? NSDictionary,
                let retweet_id = current_user_retweet["id_str"]
            {
                TwitterClient.sharedInstance.post("1.1/statuses/destroy/\(retweet_id).json", parameters: nil, progress: nil,
                                                  success: { (urlSessionTask, response) -> Void in
                                                    callBack(response as? NSDictionary, nil)
                    },
                                                  failure: { (task: URLSessionDataTask?, error:Error?) -> Void in
                                                    callBack(nil, error)
                    }
                )
            }

            },
            failure: { (task: URLSessionDataTask?, error:Error?) -> Void in
                callBack(nil, error)
            }
        )
    }
    
    func favorite(id:String, callBack: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        let params = [
            "id": id
        ]
        TwitterClient.sharedInstance.post("1.1/favorites/create.json", parameters: params, progress: nil,
                                          success: { (urlSessionTask, response) in
                                            callBack(response as? NSDictionary, nil)
            },
                                          failure: {(task: URLSessionDataTask?, error: Error?) -> Void in
                                            callBack(nil, error)
            }
        )
        
    }
    
    func unfavorite(id:String, callBack: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        let params = [
            "id": id
        ]
        TwitterClient.sharedInstance.post("1.1/favorites/destroy.json", parameters: params, progress: nil,
                                          success: { (urlSessionTask, response) in
                                            callBack(response as? NSDictionary, nil)
            },
                                          failure: {(task: URLSessionDataTask?, error: Error?) -> Void in
                                            callBack(nil, error)
            }
        )
    }
}
