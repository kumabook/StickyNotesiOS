//
//  PageTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import RealmSwift

class PageTableViewController: UITableViewController {
    var cellHeight: CGFloat = 80
    let reuseIdentifier = "PageTableViewCell"
    var pages: Results<PageEntity>!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pages"

        let nib = UINib(nibName: "PageTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        pages = StickyRepository.sharedInstance.pages
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let page = pages[indexPath.item]
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath:indexPath) as! PageTableViewCell
        cell.titleLabel.text = page.title
        cell.thumbImageView.image = UIImage(named: "no_image")
        cell.stickiesNumLabel.text = "\(page.stickies.count) stickies"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url = NSURL(string: pages[indexPath.item].url) {
            let vc = WebViewController(url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
