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
        case LoginOrLogout = 0
        var label: String {
            switch self {
            case .LoginOrLogout:
                if APIClient.sharedInstance.accessToken == nil {
                    return "Login"
                } else {
                    return "Logout"
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let c = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") {
            cell = c
        } else {
            cell = UITableViewCell()
        }
        guard let item = Item(rawValue: indexPath.item) else { return cell }
        cell.textLabel?.text =  item.label
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let item = Item(rawValue: indexPath.item) else { return }
        switch item {
        case .LoginOrLogout:
            if APIClient.sharedInstance.accessToken == nil {
                let vc = LoginViewController()
                navigationController?.pushViewController(vc, animated: true)
            } else {
                Store.sharedInstance.dispatch(LogoutAction())
            }
        }
    }
}
