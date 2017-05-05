//
//  UserRegistrationViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/05.
//  Copyright © 2017 kumabook. All rights reserved.
//

import UIKit

class UserRegistrationViewController: UIViewController {

    @IBOutlet weak var emailTextField:                UITextField!
    @IBOutlet weak var passwordTextField:             UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var registerButton:                UIButton!
    @IBOutlet weak var cancelButton:                  UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func register(_ sender: Any) {
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
}
