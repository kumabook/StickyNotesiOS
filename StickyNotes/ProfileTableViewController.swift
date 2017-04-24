//
//  ProfileTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    enum Item: Int {
        case loginOrLogout = 0
        case sync          = 1
        var label: String {
            switch self {
            case .loginOrLogout:
                if APIClient.sharedInstance.accessToken == nil {
                    return "Login"
                } else {
                    return "Logout"
                }
            case .sync:
                return "Sync (latest sync \(APIClient.sharedInstance.lastSyncedAt.passedTime))"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = "プロフィール"
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if APIClient.sharedInstance.accessToken == nil {
            return 1
        }
        return 2
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
            if APIClient.sharedInstance.accessToken == nil {
                let vc = LoginViewController()
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let alertController = UIAlertController(title: "Logout",
                                                      message: "ログアウトしますか?",
                                               preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "いいえ", style: .cancel) { action in
                    })
                alertController.addAction(UIAlertAction(title: "はい", style: .default) { action in
                    Store.sharedInstance.dispatch(LogoutAction())
                    })
                present(alertController, animated: true, completion: nil)

            }
        case .sync:
            Store.sharedInstance.dispatch(FetchStickiesAction())
        }
    }
}
