//
//  TimelineTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import Breit

class TimelineTableViewController: StickyTableViewController {
    func newPage() {
    }
    func search() {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Stickies"
        reloadData()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(TimelineTableViewController.reload), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Store.sharedInstance.state.value.stickiesRepository.state.signal.observeValues() { [weak self] state in
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
        Store.sharedInstance.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
        tabBarController?.title = "タイムライン"
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_page"), style: .plain, target: self, action: #selector(TimelineTableViewController.newPage))
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(TimelineTableViewController.search))
    }
}
