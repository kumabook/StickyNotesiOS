//
//  StickyTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/11/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class StickyTableViewController: UITableViewController {
    var cellHeight: CGFloat = 164
    let reuseIdentifier      = "StickyTableViewCell"
    let reuseIdentifierForAd = "tableViewCellForAdView"
    var stickies: Results<StickyEntity>!
    var frequencyAdsInCells = 5
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        let nib = UINib(nibName: "StickyTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierForAd)
        reloadData()
    }

    func reload() {
        reloadData()
        tableView.reloadData()
        if APIClient.shared.isLoggedIn {
            Store.shared.dispatch(FetchStickiesAction())
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    func reloadData() {
        stickies = Store.shared.state.value.stickiesRepository.items
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Store.shared.state.value.stickiesRepository.state.signal.observeValues() { [weak self] state in
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
        Store.shared.state.subscribe {[weak self] _ in
            self?.reloadData()
            self?.tableView.reloadData()
        }
    }

    func getSticky(at indexPath: IndexPath) -> StickyEntity {
        let index = indexPath.row
        if !PaymentManager.shared.isPremiumUser {
            return stickies[index - index / frequencyAdsInCells]
        }
        return stickies[index]
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !PaymentManager.shared.isPremiumUser && indexPath.row % frequencyAdsInCells == 0 {
            return cellHeight
        }
        let sticky = getSticky(at: indexPath)
        return cellHeight - (sticky.tags.count == 0 ? 36 : 0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !PaymentManager.shared.isPremiumUser {
            return stickies.count + (stickies.count / frequencyAdsInCells)
        }
        return stickies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % frequencyAdsInCells == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierForAd, for:indexPath)
            let size = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: cellHeight))
            if cell.contentView.subviews.count == 0, let adView = GADNativeExpressAdView(adSize: size) {
                if let config = Config.default {
                    adView.adUnitID = config.admobTableViewCellAdUnitID
                }
                adView.rootViewController = self
                adView.load(GADRequest())
                cell.contentView.addSubview(adView)
                adView.snp.makeConstraints() { make in
                    make.top.equalTo(cell.contentView)
                    make.bottom.equalTo(cell.contentView)
                    make.left.equalTo(cell.contentView)
                    make.right.equalTo(cell.contentView)
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! StickyTableViewCell
        let sticky = getSticky(at: indexPath)
        cell.updateView(sticky)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % frequencyAdsInCells == 0 {
            return
        }
        let sticky = getSticky(at: indexPath)
        if let page = sticky.page {
            let vc = WebViewController(page: page)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
