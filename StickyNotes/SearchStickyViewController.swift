//
//  SearchStickyViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/04/28.
//  Copyright © 2017 kumabook. All rights reserved.
//

import UIKit

class SearchStickyViewController: StickyTableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
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
    }

    override func reload() {
        reloadData()
    }

    override func reloadData() {
        if searchController?.isActive ?? false {
            if let query = searchController?.searchBar.text, !query.isEmpty {
                stickies = StickyEntity.search(by: query)
                tableView.reloadData()
                return
            }
        } else {
            if let query = query, !query.isEmpty {
                stickies = StickyEntity.search(by: query)
                tableView.reloadData()
                return
            }
        }
        stickies = StickyEntity.empty()
        tableView.reloadData()
    }

    public func updateSearchResults(for searchController: UISearchController) {
        reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        query = searchBar.text
        searchController.isActive = false
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = query
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = query
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = query
    }
}
