//
//  StickyTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import RealmSwift

class StickyTableViewController: UITableViewController {
    var cellHeight: CGFloat = 160
    let reuseIdentifier = "StickyTableViewCell"
    var stickies: Results<StickyEntity>!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "StickyTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    func reload() {
        reloadData()
        Store.sharedInstance.dispatch(FetchStickiesAction())
    }
    
    func reloadData() {
        self.stickies = Store.sharedInstance.state.value.stickiesRepository.items
        self.tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Store.sharedInstance.state.value.stickiesRepository.state.signal.observeNext() { [weak self] state in
            switch state {
            case .Normal:
                self?.refreshControl?.endRefreshing()
                self?.reloadData()
            case .Fetching:
                self?.refreshControl?.beginRefreshing()
            }
        }
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stickies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath:indexPath) as! StickyTableViewCell
        let sticky = stickies[indexPath.item]
        cell.contentLabel.text = sticky.content
        if sticky.content.characters.count == 0 {
            cell.contentLabel.text = "No memo"
        }
        if let page = sticky.page {
            cell.pageLabel.text = page.title
        } else {
            cell.pageLabel.text = ""
        }
        cell.dateLabel.text = sticky.updatedAt.passedTime
        cell.tagLabel.text = sticky.tags.reduce("", combine: {
            return $0 + " " + $1.name
        }) as String
        if sticky.tags.count == 0 {
            cell.tagLabel.text = "No tag"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sticky = stickies[indexPath.item]
        if let page = sticky.page {
            let vc = WebViewController(page: page)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
