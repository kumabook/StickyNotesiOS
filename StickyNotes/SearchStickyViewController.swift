//
//  SearchStickyViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/04/28.
//  Copyright © 2017 kumabook. All rights reserved.
//

import UIKit
import SnapKit

class SearchStickyViewController: StickyTableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    enum Mode {
        case wait
        case searching
        case result
    }
    var mode: Mode = .wait
    var searchController: UISearchController!
    var query: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = ""
        searchController = UISearchController(searchResultsController:  nil)

        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true

        navigationItem.titleView = searchController.searchBar

        definesPresentationContext = true

        refreshControl = nil
        automaticallyAdjustsScrollViewInsets = true
    }

    func createFooterView(message: String) -> UIView {
        let footerView      = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
        let label           = UILabel()
        label.textAlignment = .left
        label.text          = message
        label.numberOfLines = 3
        footerView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.height.equalTo(footerView)
            make.center.equalTo(footerView)
            make.leadingMargin.greaterThanOrEqualTo(10)
        }
        return footerView
    }

    func createInstructionFooterView() -> UIView {
        return createFooterView(message: "付箋の内容・タグ名・タイトルまたはURLで検索")
    }

    func createNoResultFooterView() -> UIView {
        return createFooterView(message: "検索結果なし")
    }

    override func reload() {
        // do nothing
    }

    override func reloadData() {
        // do nothing
        stickies = StickyEntity.empty()
        tableView.tableFooterView = createInstructionFooterView()
    }

    public func updateSearchResults(for searchController: UISearchController) {
        switch mode {
        case .searching:
            if let query = searchController.searchBar.text, !query.isEmpty {
                stickies = StickyEntity.search(by: query)
                tableView.tableFooterView = stickies.count == 0 ? createNoResultFooterView() : nil
            } else {
                stickies = StickyEntity.empty()
                tableView.tableFooterView = createInstructionFooterView()
            }
        case .result:
            if let query = query {
                stickies = StickyEntity.search(by: query)
                tableView.tableFooterView = stickies.count == 0 ? createNoResultFooterView() : nil
            } else {
                stickies = StickyEntity.empty()
                tableView.tableFooterView = createNoResultFooterView()
            }
        case .wait:
            if let query = query {
                stickies = StickyEntity.search(by: query)
                tableView.tableFooterView = stickies.count == 0 ? createNoResultFooterView() : nil
            } else {
                stickies = StickyEntity.empty()
                tableView.tableFooterView = createInstructionFooterView()
            }
        }
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        query = searchBar.text
        mode = .result
        searchController.isActive = false
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = query
        mode = .searching
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        mode = .wait
    }
}
