//
//  TwitterCell.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/29/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit

@objc protocol UITwitterCellDelegate {
    @objc optional func twitterCellDelegate (twitterCell: TwitterCell, replyTo tweet: Tweet)
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
        
    }
    @IBAction func onRetweet(_ sender: AnyObject) {
        
    }
    @IBAction func onLike(_ sender: AnyObject) {
        
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
