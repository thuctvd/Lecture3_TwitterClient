//
//  HomeViewController.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/29/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet] = [Tweet]()
    var offset: String?
    var loadingMoreResult = false
    
    var loadingViewIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initControls()
        loadData()
    }
    
    func initControls() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110
        
        refreshControl = UIRefreshControl()
        refreshControl.endRefreshing()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        addLoadingViewIndicatorAtBottomOfTableView()
    }
    
    func refresh() {
        loadData(offset: "")
    }
    
    func loadData(offset:String = "") {
        var params:NSDictionary = NSDictionary()
        if offset.isEmpty == false {
            params = [ "max_id": offset]
        } else {
            refreshControl.beginRefreshing()
        }
        
        TwitterClient.sharedInstance.homeTimelineWithParams(params: params) { (tweets, error) -> () in
            if error != nil {
                self.showAlert(title: "Error message", message: (error?.localizedDescription)!)
                return
            }
            print ("load data")
            if offset.isEmpty == false {
                if var tweets = tweets {
                    tweets.removeFirst()
                    self.tweets.append(contentsOf: tweets)
                }
            } else {
                self.tweets = tweets!
            }
            self.loadingMoreResult = false
            self.loadingViewIndicator.isHidden = true
            self.loadingViewIndicator.stopAnimating()
            
            self.tableView.reloadData()
            
            if let lastTweet = tweets?.last {
                self.offset = lastTweet.id
            }
            self.refreshControl.endRefreshing()
        }
    }

    func addLoadingViewIndicatorAtBottomOfTableView() {
        // add trigger at the end icon
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        loadingViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingViewIndicator.isHidden = true
        loadingViewIndicator.stopAnimating()
        loadingViewIndicator.center = tableViewFooter.center
        
        tableViewFooter.addSubview(loadingViewIndicator)
        tableView.tableFooterView = tableViewFooter
    }
    
    @IBAction func SignOut(_ sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadingViewIndicator.isHidden = true
        loadingViewIndicator.stopAnimating()
        loadingMoreResult = false
        
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            if let tweetCompose = navigationController.topViewController as? NewTweetViewController {
                tweetCompose.delegate = self
            } else if let nextViewController = navigationController.topViewController as? TweetDetailViewController {
                let indexPath = tableView.indexPathForSelectedRow
                let currentTweet = tweets[indexPath!.row]
                nextViewController.tweet = currentTweet
            } else if let tweetReply = navigationController.topViewController as? ReplyViewController {
                let tweet = sender as! Tweet
                tweetReply.targetUserName = "@\(tweet.user!.screenName!) "
                tweetReply.id = tweet.id!
                tweetReply.delegate = self
            }
        }
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, UITwitterCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterCell") as! TwitterCell
        
        if tweets.count > 0 {
            cell.drawUI(tweet: tweets[indexPath.row])
            cell.delegate = self
        }
        
        if !loadingMoreResult && loadingViewIndicator.isHidden && indexPath.row == tweets.count - 1{
            loadingViewIndicator.isHidden = false
            loadingViewIndicator.startAnimating()
            loadData(offset: offset!)
            loadingMoreResult = true
        }
        
        return cell
    }
    
    func twitterCell(twitterCell: TwitterCell, replyTo tweet: Tweet) {
        performSegue(withIdentifier: "TweetReply", sender: tweet)

    }
}

extension HomeViewController: ReplyViewControllerDelegate {
    
    func replyView(_ replyViewController: ReplyViewController, response: NSDictionary?) {
        if response != nil {
            tweets.insert(Tweet(dictionary: response!), at: 0)
            tableView.reloadData()
        }
    }
    
}

extension HomeViewController: UINewTweetViewDelegate {
    func newTweetView(_ newTweetViewContorller: NewTweetViewController, response: NSDictionary?) {
        if response != nil {
            tweets.insert(Tweet(dictionary: response!), at: 0)
            tableView.reloadData()
        }
    }
}
