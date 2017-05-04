//
//  SearchStickyViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/04/28.
//  Copyright © 2017 kumabook. All rights reserved.
//

import UIKit

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

    func createHeaderView(message: String) -> UIView {
        let frame           = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3)
        let headerView      = UIView(frame: frame)
        let label           = UILabel()
        label.textAlignment = .center
        label.frame         = frame
        label.text          = message
        headerView.addSubview(label)
        return headerView
    }

    func createInstructionHeaderView() -> UIView {
        return createHeaderView(message: "付箋の内容・タグ名・タイトルまたはURLで検索")
    }

    func createNoResultHeaderView() -> UIView {
        return createHeaderView(message: "検索結果なし")
    }

    override func reload() {
        // do nothing
    }

    override func reloadData() {
        // do nothing
        stickies = StickyEntity.empty()
        tableView.tableHeaderView = createInstructionHeaderView()
    }

    public func updateSearchResults(for searchController: UISearchController) {
        switch mode {
        case .searching:
            if let query = searchController.searchBar.text, !query.isEmpty {
                stickies = StickyEntity.search(by: query)
                tableView.tableHeaderView = stickies.count == 0 ? createNoResultHeaderView() : nil
            } else {
                stickies = StickyEntity.empty()
                tableView.tableHeaderView = createInstructionHeaderView()
            }
        case .result:
            if let query = query {
                stickies = StickyEntity.search(by: query)
                tableView.tableHeaderView = stickies.count == 0 ? createNoResultHeaderView() : nil
            } else {
                stickies = StickyEntity.empty()
                tableView.tableHeaderView = createNoResultHeaderView()
            }
        case .wait:
            if let query = query {
                stickies = StickyEntity.search(by: query)
                tableView.tableHeaderView = stickies.count == 0 ? createNoResultHeaderView() : nil
            } else {
                stickies = StickyEntity.empty()
                tableView.tableHeaderView = createInstructionHeaderView()
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
