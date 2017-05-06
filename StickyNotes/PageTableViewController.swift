//
//  PageTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

class PageTableViewController: UITableViewController {
    var cellHeight: CGFloat = 80
    let reuseIdentifier = "PageTableViewCell"
    var pages: Results<PageEntity>!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pages"

        let nib = UINib(nibName: "PageTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        reloadData()
        Store.shared.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
        tableView.contentInset.bottom += tabBarController?.tabBar.frame.height ?? 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func reload() {
        reloadData()
        Store.shared.dispatch(FetchStickiesAction())
    }

    func reloadData() {
        pages = Store.shared.state.value.stickiesRepository.pages
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = "ページ"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    // MARK: - Table view data source

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
        cell.stickiesNumLabel.text = "\(page.stickies.count) stickies"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WebViewController(page: pages[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}
