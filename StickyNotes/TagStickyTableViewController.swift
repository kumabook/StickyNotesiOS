//
//  TagStickyTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class TagStickyTableViewController: UITableViewController {
    var cellHeight: CGFloat = 80
    let reuseIdentifier = "PageTableViewCell"
    var tag: TagEntity!
    var pageDict: [PageEntity:[StickyEntity]] = [:]
    var pages: [PageEntity] = []
    init(tag: TagEntity) {
        self.tag = tag
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = tag.name

        let nib = UINib(nibName: "PageTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)

        pageDict = [:]
        tag.stickies.forEach() { s in
            guard let page = s.page else { return }
            if pageDict[page] == nil {
                pageDict[page] = [s]
            } else {
                pageDict[page]?.append(s)
            }
        }
        pages = pageDict.keys.map { $0 }
    }
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
        cell.stickiesNumLabel.text = "\(pageDict[page]!.count)/\(page.stickies.count) stickies"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = WebViewController(page: pages[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}
