//
//  NewTweetViewController.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/30/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit

@objc protocol UINewTweetViewDelegate {
    @objc func newTweetView(_ newTweetViewContorller: NewTweetViewController, response: NSDictionary?)
}

class NewTweetViewController: UIViewController {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userPageLabel: UILabel!
    @IBOutlet weak var contentTextArea: UITextView!
    @IBOutlet weak var counterLabel: UIBarButtonItem!
    
    let maxLength = 140
    var delegate: UINewTweetViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextArea.delegate = self
        
        contentTextArea.text = ""
        updateCounter()
        
        contentTextArea.becomeFirstResponder()
        
        avatarImage.clipsToBounds = true
        avatarImage.layer.cornerRadius = 5
        
        if let user = User.currentUser {
            avatarImage.setImageWith(URL(string: user.profileImageUrl!)!)
            userPageLabel.text = user.name!
            usernameLabel.text = "@\(user.screenName!)"
        }
    }
    
    func updateCounter() {
        let strLength = (contentTextArea.text?.characters.count)!
        
        UIView.setAnimationsEnabled(false)
        counterLabel.title = "\(maxLength - strLength)"
        UIView.setAnimationsEnabled(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onCreateTweet(_ sender: AnyObject) {
        if contentTextArea.text.characters.count > 0 {
            TwitterClient.sharedInstance.tweet(message: contentTextArea.text, callBack: { (response, error) -> () in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                self.delegate?.newTweetView(self, response: response)
            })
            
            dismiss(animated: true, completion: nil)
        }
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

extension NewTweetViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateCounter()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = contentTextArea.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= maxLength
    }
}
