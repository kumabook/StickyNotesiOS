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
        case help          = 2
        case version       = 3
        case license       = 4
        case purchase      = 5
        case restore       = 6
        static let count   = 7
        var label: String {
            switch self {
            case .loginOrLogout:
                if APIClient.shared.accessToken == nil {
                    return "ログイン"
                } else {
                    return "ログアウト"
                }
            case .sync:
                if let lastSyncedAt = APIClient.shared.lastSyncedAt {
                    return "同期 (\(lastSyncedAt) に実行)"
                } else {
                    return "同期"
                }
            case .help:
                return "ヘルプ"
            case .version:
                return "バージョン情報"
            case .license:
                return "ライセンス情報"
            case .purchase:
                return "プレミアムサービスを購入"
            case .restore:
                return "購入を復元"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Store.shared.state.subscribe {[weak self] _ in
            self?.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = "設定"
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
                let alertController = UIAlertController(title: "Logout",
                                                      message: "ログアウトしますか?",
                                               preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "いいえ", style: .cancel) { action in
                    })
                alertController.addAction(UIAlertAction(title: "はい", style: .default) { action in
                    Store.shared.dispatch(LogoutAction())
                    })
                present(alertController, animated: true, completion: nil)

            }
        case .sync:
            if APIClient.shared.isLoggedIn {
                Store.shared.dispatch(FetchStickiesAction())
            } else {
                let _ = UIAlertController.show(self, title: "ログインが必要です", message: "ログインをするとデバイス間でデータを共有することができます。") {_ in
                    let vc = LoginViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        default:
            break
        }
    }
}
