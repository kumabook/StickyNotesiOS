//
//  WebViewController+NewPage.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/04/28.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension WebViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func enterViewMode() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(WebViewController.enterNewPageMode))
        navigationItem.titleView = nil
        navigationItem.title = page?.title ?? ""
        collectionView?.removeFromSuperview()
    }
    func enterNewPageMode() {
        searchController = UISearchController(searchResultsController:  nil)
        searchController?.searchBar.placeholder = "Search or enter address"
        searchController?.searchBar.returnKeyType = UIReturnKeyType.go
        
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = true
        
        navigationItem.titleView = searchController?.searchBar
        navigationItem.rightBarButtonItem = nil
        
        definesPresentationContext = true
        searchController?.searchBar.becomeFirstResponder()
        collectionView = createCollectionView()
        view.addSubview(collectionView!)
    }

    public func updateSearchResults(for searchController: UISearchController) {
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        if let url = URL(string: text), let schema = url.scheme, schema == "http" || schema == "https" {
            loadURL(url)
        } else {
            let q = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? text
            loadURL(URL(string: "http://google.com/search?q=\(q)")!)
        }
        searchController?.isActive = false
        mode = .view
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if page != nil {
            mode = .view
        }
    }
}

extension WebViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var sites: [Site] {
        return Site.defaultSites
    }
    func createCollectionView() -> UICollectionView {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - toolbarHeight)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SiteCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.autoresizesSubviews = true
        collectionView.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                           UIViewAutoresizing.flexibleHeight,
                                           UIViewAutoresizing.flexibleBottomMargin,
                                           UIViewAutoresizing.flexibleLeftMargin,
                                           UIViewAutoresizing.flexibleRightMargin,
                                           UIViewAutoresizing.flexibleTopMargin,
                                           UIViewAutoresizing.flexibleBottomMargin]
        collectionView.alwaysBounceVertical = true
        return collectionView
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SiteCollectionViewCell
        let site = sites[indexPath.row]
        cell.titleLabel.text = site.title
        cell.imageView.sd_setImage(with: site.imageURL, placeholderImage: UIImage(named: "no_image"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize: CGFloat = view.frame.size.width / 3
        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let site = sites[indexPath.row]
        loadURL(site.url)
    }
}
