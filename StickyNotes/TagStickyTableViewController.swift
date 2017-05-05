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
    func reloadData() {
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
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = tag.name

        let nib = UINib(nibName: "PageTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        reloadData()
        Store.shared.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let page = pages[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for:indexPath) as! PageTableViewCell
        cell.titleLabel.text = page.title
        cell.thumbImageView.sd_setImage(with: page.visualUrl.flatMap({ URL(string: $0) }), placeholderImage: UIImage(named: "no_image"))
        cell.stickiesNumLabel.text = "\(pageDict[page]!.count)/\(page.stickies.count) stickies"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WebViewController(page: pages[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}
