//
//  TwitterCell.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/29/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit

@objc protocol UITwitterCellDelegate {
    @objc optional func twitterCell (twitterCell: TwitterCell, replyTo tweet: Tweet)
}

class TwitterCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userpageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var tweet: Tweet?
    var delegate: UITwitterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImage.clipsToBounds = true
        avatarImage.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onReply(_ sender: AnyObject) {
        delegate?.twitterCell!(twitterCell: self, replyTo: tweet!)
    }
    @IBAction func onRetweet(_ sender: AnyObject) {
        if let tweet = tweet {
            if tweet.retweeted == false {
                TwitterClient.sharedInstance.retweet(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.drawUI(tweet: self.tweet!)
                    }
                }
            } else {
                TwitterClient.sharedInstance.unretweet(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.tweet?.numRetweets -= 1
                        if (self.tweet?.numRetweets)! < 0 {
                            self.tweet?.numRetweets = 0
                        }
                        self.tweet?.retweeted = false
                        self.drawUI(tweet: self.tweet!)
                    }
                }
            }
            
        }
    }
    @IBAction func onLike(_ sender: AnyObject) {
        if let tweet = tweet {
            if tweet.favorited == false {
                TwitterClient.sharedInstance.favorite(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.drawUI(tweet: self.tweet!)
                    }
                }
            } else {
                TwitterClient.sharedInstance.unfavorite(id: tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(dic: response!)
                        self.drawUI(tweet: self.tweet!)
                    }
                }
            }
        }
    }

    func drawUI(tweet: Tweet) {
        self.tweet = tweet
        
        userpageLabel.text = tweet.user?.name
        usernameLabel.text = "@\((tweet.user?.screenName)!)"
        descriptionLabel.text = tweet.text
        avatarImage.setImageWith(URL(string: (tweet.user?.profileImageUrl)!)!)
        timeLabel.text = tweet.timeString()
        
        retweetCountLabel.text = "\(tweet.numRetweets)"
        favoriteCountLabel.text = "\(tweet.numFavorites)"
        
        if tweet.retweeted {
            retweetButton.setImage(UIImage(named: "retweet-highlight"), for: .normal)
        }
        else {
            retweetButton.setImage(UIImage(named: "retweet"), for: .normal)
        }
        
        if tweet.favorited {
            favoriteButton.setImage(UIImage(named: "heart-highlight"), for: .normal)
        }
        else {
            favoriteButton.setImage(UIImage(named: "heart"), for: .normal)
        }
        
        retweetButton.isEnabled = tweet.user?.screenName! != User.currentUser!.screenName

    }
}
