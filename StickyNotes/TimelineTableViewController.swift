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
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Stickies"

        self.reloadData()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(TimelineTableViewController.reload), for: UIControlEvents.valueChanged)
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
    }
}
