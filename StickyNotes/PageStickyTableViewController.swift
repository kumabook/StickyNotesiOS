//
//  PageStickyTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/13/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class PageStickyTableViewController: UITableViewController {
    var cellHeight: CGFloat = 160
    let reuseIdentifier = "PageStickyTableViewCell"
    var page: PageEntity? {
        didSet {
            self.tableView.reloadData()
        }
    }

    func reloadData() {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "PageStickyTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        title = "Stickies"
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let page = page else { return 0 }
        return page.stickies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath:indexPath) as! PageStickyTableViewCell
        guard let page = page else { return cell }
        let sticky = page.stickies[indexPath.item]

        cell.contentLabel.text = sticky.content.characters.count > 0 ? sticky.content : "No content"
        cell.dateLabel.text = sticky.updatedAt.passedTime
        cell.locationLabel.text = "position: (\(sticky.top),\(sticky.left))"
        cell.tagLabel.text = sticky.tags.reduce("", combine: {
            return $0 + " " + $1.name
        }) as String
        if sticky.tags.count == 0 {
            cell.tagLabel.text = "No tag"
        }

        return cell
    }
}
