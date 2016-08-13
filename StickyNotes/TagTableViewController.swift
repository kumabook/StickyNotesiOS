//
//  TagTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import RealmSwift

class TagTableViewController: UITableViewController {
    var cellHeight: CGFloat = 80
    let reuseIdentifier = "TagTableViewCell"
    var tags: Results<TagEntity>!

    func reloadData() {
        tags = StickyRepository.sharedInstance.tags
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tags"
        
        let nib = UINib(nibName: "TabTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)

        reloadData()
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
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
        return tags.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath:indexPath) as! TabTableViewCell
        let tag = tags[indexPath.item]
        cell.nameLabel.text          = tag.name
        cell.tagImageView?.tintColor = Color.values[indexPath.item % Color.values.count].backgroundColor
        cell.stickiesNumLabel.text   = "\(tag.stickies.count) stickies"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = TagStickyTableViewController(tag: self.tags[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}
