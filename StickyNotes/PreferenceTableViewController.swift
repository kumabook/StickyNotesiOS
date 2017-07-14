//
//  ProfileTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class PreferenceTableViewController: UITableViewController {
    enum Item: Int {
        case loginOrLogout = 0
        case sync          = 1
        case tutorial      = 2
        case purchase      = 3
        case restore       = 4
        case support       = 5
        static let count   = 6
        var label: String {
            switch self {
            case .loginOrLogout:
                if APIClient.shared.accessToken == nil {
                    return "Login".localize()
                } else {
                    return "Logout".localize()
                }
            case .sync:
                let sync = "Sync".localize()
                if let lastSyncedAt = APIClient.shared.lastSyncedAt {
                    return String(format: "%@ (%@ ago)".localize(), sync, lastSyncedAt.passedTime)
                } else {
                    return sync
                }
            case .tutorial:
                return "Tutorial".localize()
            case .purchase:
                return "Upgrade to Premium".localize()
            case .restore:
                return "Restore purchases".localize()
            case .support:
                return "Support".localize()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Store.shared.state.subscribe {[weak self] _ in
            self?.tableView.reloadData()
        }
        Store.shared.state.value.accountState.signal.observe {[weak self] state in
            guard let _ = state.value else { return }
            self?.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = "Preferences".localize()
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Item.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let c = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") {
            cell = c
        } else {
            cell = UITableViewCell()
        }
        guard let item = Item(rawValue: indexPath.item) else { return cell }
        cell.textLabel?.text =  item.label
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = Item(rawValue: indexPath.item) else { return }
        switch item {
        case .loginOrLogout:
            if APIClient.shared.accessToken == nil {
                let vc = LoginViewController()
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let alertController = UIAlertController(title: "Logout".localize(),
                                                      message: "Are you sure you want to logout?".localize(),
                                               preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "No".localize(), style: .cancel) { action in
                    })
                alertController.addAction(UIAlertAction(title: "Yes".localize(), style: .default) { action in
                    Store.shared.dispatch(LogoutAction())
                    })
                present(alertController, animated: true, completion: nil)

            }
        case .sync:
            if APIClient.shared.isLoggedIn {
                Store.shared.dispatch(FetchStickiesAction())
            } else {
                let _ = UIAlertController.show(self, title: "Login is required".localize(), message: "You can sync stickies between multiple devices".localize()) {_ in
                    let vc = LoginViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        case .tutorial:
            UserDefaults.standard.set(false, forKey: "webview_coach_finish")
            UserDefaults.standard.set(false, forKey: "timeline_coach_finish")
            AppDelegate.shared.slideMenu?.showTutorial()
        case .purchase:
            let _ = UIAlertController.showPurchaseAlert(self)
        case .restore:
            PaymentManager.shared.restorePurchase()
        case .support:
            guard let url = URL(string: "https://twitter.com/stickynotesjp") else { return }
            UIApplication.shared.openURL(url)
        }
    }
}
