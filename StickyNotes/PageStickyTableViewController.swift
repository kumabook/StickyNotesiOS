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
        title = "Sticky list"
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

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        guard let page = page else { return [] }
        let sticky = page.stickies[indexPath.item]
        let remove = UITableViewRowAction(style: .Default, title: "Remove".localize()) { (action, indexPath) in
            Store.sharedInstance.dispatch(DeleteStickyAction(sticky: sticky))
        }

        remove.backgroundColor = UIColor.redColor()
        return [remove]
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath:indexPath) as! PageStickyTableViewCell
        guard let page = page else { return cell }
        let sticky = page.stickies[indexPath.item]
        cell.updateView(sticky)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let page = page else { return }
        let sticky = page.stickies[indexPath.item]
        let vc = EditStickyViewController(sticky: sticky)
        navigationController?.pushViewController(vc, animated: true)
    }
}
