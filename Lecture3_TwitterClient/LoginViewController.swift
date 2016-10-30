//
//  LoginViewController.swift
//  Lecture3_TwitterClient
//
//  Created by Truong Vo Duy Thuc on 10/29/16.
//  Copyright © 2016 thuctvd. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginTwitter(_ sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion(completion: { (user, error) in
            if error != nil {
                print(error)
                return
            }
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
