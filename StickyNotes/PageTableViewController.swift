//
//  PageTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class PageTableViewController: UITableViewController {
    var pages: [PageEntity]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pages"
        
        self.pages = StickyRepository.sharedInstance.pages.map { $0 }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = pages[indexPath.item].title
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url = NSURL(string: pages[indexPath.item].url) {
            let vc = WebViewController(url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
