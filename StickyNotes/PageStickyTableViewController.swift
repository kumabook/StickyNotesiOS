//
//  PageStickyTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/13/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class PageStickyTableViewController: UITableViewController {
    var cellHeight: CGFloat = 160
    var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    let reuseIdentifier = "PageStickyTableViewCell"
    var page: PageEntity? {
        didSet {
            self.tableView.reloadData()
        }
    }

    func reloadData() {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "PageStickyTableViewCell", bundle: nil)
        title = "Sticky list"
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        Store.shared.state.subscribe {[weak self] state in
            switch state.mode.value {
            default:
                self?.reloadData()
                break
            }
        }
    }

    func editButtonTapped(_ sticky: StickyEntity) {
        let vc = EditStickyViewController(sticky: sticky)
        navigationController?.pushViewController(vc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        title = "Stickies"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let page = page else { return 0 }
        return page.stickies.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let page = page else { return [] }
        let sticky = page.stickies[indexPath.item]
        let remove = UITableViewRowAction(style: .default, title: "Remove".localize()) { (action, indexPath) in
            Store.shared.dispatch(DeleteStickyAction(sticky: sticky))
        }
        remove.backgroundColor = UIColor.red
        return [remove]
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for:indexPath) as! PageStickyTableViewCell
        guard let page = page else { return cell }
        let sticky = page.stickies[indexPath.item]
        cell.updateView(sticky)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let page = page else { return }
        let sticky = page.stickies[indexPath.item]
        Store.shared.dispatch(JumpStickyAction(sticky: sticky))
    }
}
