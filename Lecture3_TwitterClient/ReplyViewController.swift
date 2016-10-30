//
//  ReplyViewController.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/30/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit

@objc protocol ReplyViewControllerDelegate {
    @objc func replyView(_ replyViewController: ReplyViewController, response: NSDictionary?)
}

class ReplyViewController: UIViewController {

    @IBOutlet weak var userPageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var counterLabel: UIBarButtonItem!
    
    let maxCharacter = 140
    var targetUserName = ""
    var id = ""
    var delegate: ReplyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentLabel.becomeFirstResponder()
        contentLabel.delegate = self
        contentLabel.text = "\(targetUserName) "
        contentLabel.becomeFirstResponder()
        
        updateCounter()
        avatarImage.clipsToBounds = true
        avatarImage.layer.cornerRadius = 5
        
        if let user = User.currentUser {
            avatarImage.setImageWith(URL(string: user.profileImageUrl!)!)
            userPageLabel.text = user.name!
            usernameLabel.text = "@\(user.screenName!)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCounter() {
        let strLength = (contentLabel.text?.characters.count)!
        
        UIView.setAnimationsEnabled(false)
        counterLabel.title = "\(maxCharacter - strLength)"
        UIView.setAnimationsEnabled(true)
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onReply(_ sender: AnyObject) {
        if contentLabel.text.characters.count > 0 {
            TwitterClient.sharedInstance.reply(contentLabel.text, id: id, callBack: { (response, error) -> () in
                self.delegate?.replyView(self, response: response!)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}

extension ReplyViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateCounter()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = contentLabel.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= maxCharacter
    }
}
