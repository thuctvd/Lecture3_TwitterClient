//
//  TweetDetailViewController.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/30/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var userPageLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var reTweetButton: UIButton!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImage.clipsToBounds = true
        avatarImage.layer.cornerRadius = 5
        
        drawUI()
    }
    
    func drawUI() {
        if let tweet = tweet {
            userPageLabel.text = tweet.user?.name
            usernameLabel.text = "@\((tweet.user?.screenName)!)"
            contentLabel.text = tweet.text
            avatarImage.setImageWith(URL(string: (tweet.user?.profileImageUrl)!)!)
            timeLabel.text = tweet.timeString()
            
            retweetCountLabel.text = "\(tweet.numRetweets)"
            favoriteCountLabel.text = "\(tweet.numFavorites)"
            
            if tweet.retweeted {
                reTweetButton.setImage(UIImage(named: "retweet-highlight"), for: .normal)
            }
            else {
                reTweetButton.setImage(UIImage(named: "retweet"), for: .normal)
            }
            
            if tweet.favorited {
                favoriteButton.setImage(UIImage(named: "heart-highlight"), for: .normal)
            }
            else {
                favoriteButton.setImage(UIImage(named: "heart"), for: .normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReTweet(_ sender: AnyObject) {
        if let tweet = tweet {
            if tweet.retweeted == false {
                TwitterClient.sharedInstance.retweet(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.drawUI()
                    }
                }
            } else {
                TwitterClient.sharedInstance.unretweet(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.tweet?.numRetweets = (self.tweet?.numRetweets)! - 1
                        if (self.tweet?.numRetweets)! < 0 {
                            self.tweet?.numRetweets = 0
                        }
                        self.tweet?.retweeted = false
                        self.drawUI()
                    }
                }
            }
            
        }
    }
    
    @IBAction func onFavorite(_ sender: AnyObject) {
        if let tweet = tweet {
            if tweet.favorited == false {
                TwitterClient.sharedInstance.favorite(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.drawUI()
                    }
                }
            } else {
                TwitterClient.sharedInstance.unfavorite(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.drawUI()
                    }
                }
            }
        }
    }
    @IBAction func onReply(_ sender: AnyObject) {
        
    }

    @IBAction func onBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
