//
//  LoginViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import APIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(sender: AnyObject) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }

        let request = AccessTokenRequest(email: email, password: password)
        Session.sendRequest(request) { result in
            switch result {
            case .Success(let accessToken):
                print("accessToken: \(accessToken)")
                APIClient.sharedInstance.accessToken = accessToken
                self.fetchStickies()
            case .Failure(let error):
                print("error: \(error)")
            }
        }
    }

    func fetchStickies() {
        let request = StickiesRequest(newerThan: NSDate(timeIntervalSince1970: 0))
        Session.sendRequest(request) { result in
            switch result {
            case .Success(let stickies):
                print("stickies \(stickies)")
            case .Failure(let error):
                print("error: \(error)")
            }
        }
    }
}
