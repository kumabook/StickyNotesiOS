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
        tags = StickyRepository.shared.tags
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tags"
        
        let nib = UINib(nibName: "TabTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)

        reloadData()
        Store.shared.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.title = "タグ"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
        Store.shared.state.value.stickiesRepository.state.signal.observeValues() { [weak self] state in
            switch state {
            case .normal:
                self?.refreshControl?.endRefreshing()
                self?.reloadData()
            case .fetching:
                self?.refreshControl?.beginRefreshing()
            case .updating:
                self?.refreshControl?.beginRefreshing()
            }
        }
        Store.shared.state.subscribe {[weak self] _ in
            self?.reloadData()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for:indexPath) as! TabTableViewCell
        let tag = tags[indexPath.item]
        cell.nameLabel.text          = tag.name
        cell.tagImageView?.tintColor = Color.values[indexPath.item % Color.values.count].backgroundColor
        cell.stickiesNumLabel.text   = "\(tag.stickies.count) stickies"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TagStickyTableViewController(tag: self.tags[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}
