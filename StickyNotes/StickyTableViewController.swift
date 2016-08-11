//
//  StickyTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class StickyTableViewController: UITableViewController {
    var cellHeight: CGFloat = 120
    let reuseIdentifier = "StickyTableViewCell"
    var stickies: [StickyEntity]!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if let page = sticky.page {
            cell.pageLabel.text = page.title
        } else {
            cell.pageLabel.text = ""
        }
        cell.dateLabel.text = sticky.updatedAt.passedTime
        cell.tagLabel.text = sticky.tags.reduce("", combine: {
            return $0 + $1.name
        }) as String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sticky = stickies[indexPath.item]
        if let str = sticky.page?.url, url = NSURL(string: str) {
            let vc = WebViewController(url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
