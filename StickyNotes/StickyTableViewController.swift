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
    var cellHeight: CGFloat = 164
    let reuseIdentifier = "StickyTableViewCell"
    var stickies: Results<StickyEntity>!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        let nib = UINib(nibName: "StickyTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        reloadData()
    }

    func reload() {
        reloadData()
        tableView.reloadData()
        Store.sharedInstance.dispatch(FetchStickiesAction())
    }
    
    func reloadData() {
        stickies = Store.sharedInstance.state.value.stickiesRepository.items
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Store.sharedInstance.state.value.stickiesRepository.state.signal.observeValues() { [weak self] state in
            switch state {
            case .normal:
                self?.refreshControl?.endRefreshing()
                self?.reloadData()
                self?.tableView.reloadData()
            case .fetching:
                self?.refreshControl?.beginRefreshing()
            case .updating:
                self?.refreshControl?.beginRefreshing()
            }
        }
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.reloadData()
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sticky = stickies[indexPath.item]
        return cellHeight - (sticky.tags.count == 0 ? 36 : 0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stickies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for:indexPath) as! StickyTableViewCell
        let sticky = stickies[indexPath.item]
        cell.updateView(sticky)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sticky = stickies[indexPath.item]
        if let page = sticky.page {
            let vc = WebViewController(page: page)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
