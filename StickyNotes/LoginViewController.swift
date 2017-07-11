//
//  LoginViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import APIKit
import MBProgressHUD
import ReactiveSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    var hud: MBProgressHUD?
    var observer: Disposable?
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
        observer = Store.shared.state.value.accountState.signal.observe {
            guard let state = $0.value else { return }
            switch state {
            case .loggingIn, .loggingOut:
                self.showProgress()
            case .failToLogin(let e):
                self.hideProgress()
                self.showAlert(error: e)
            case .login, .logout:
                self.hideProgress()
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        switch Store.shared.state.value.accountState.value {
        case .login(_):
            self.navigationController?.popViewController(animated: true)
        default:
            break
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        observer?.dispose()
        observer = nil
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
        let _ = UIAlertController.show(self, title: "Network error", message: error.localizedDescription) { _ in
        }
    }

    @IBAction func login(_ sender: AnyObject) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Store.shared.dispatch(LoginAction(email: email, password: password))
    }

    @IBAction func register(_ sender: Any) {
        let vc = UserRegistrationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func resetPassword(_ sender: Any) {
        if let url = APIClient.shared.passwordResetURL {
            UIApplication.shared.openURL(url)
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
}
