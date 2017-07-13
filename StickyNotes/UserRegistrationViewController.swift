//
//  UserRegistrationViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/05.
//  Copyright © 2017 kumabook. All rights reserved.
//

import UIKit
import APIKit
import MBProgressHUD
import ReactiveSwift

class UserRegistrationViewController: UIViewController {

    @IBOutlet weak var emailTextField:                UITextField!
    @IBOutlet weak var passwordTextField:             UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var registerButton:                UIButton!

    var hud: MBProgressHUD?
    var observer: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.titleLabel?.text = "Sign up".localize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observer = Store.shared.state.value.accountState.signal.observe {
            guard let state = $0.value else { return }
            switch state {
            case .creating:
                self.showProgress()
            case .failToCreate(let e):
                self.hideProgress()
                self.showAlert(error: e)
            case .created:
                self.hideProgress()
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        observer?.dispose()
        observer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showProgress() {
        guard let view =  self.navigationController?.view else { return }
        hud = MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func hideProgress() {
        hud?.hide(animated: true)
        hud = nil
    }

    func showAlert(error: SessionTaskError) {
        let _ = UIAlertController.show(self, title: "Network error".localize(), message: error.localizedDescription) { _ in
        }
    }

    @IBAction func register(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let passwordConfirmation = passwordConfirmationTextField.text else { return }
        Store.shared.dispatch(CreateUserAction(email: email, password: password, passwordConfirmation: passwordConfirmation))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
}
