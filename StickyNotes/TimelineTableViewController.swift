//
//  TimelineTableViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/6/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import Breit
import Instructions

class TimelineTableViewController: StickyTableViewController {
    let coachMarksController = CoachMarksController()
    func newPage() {
        let vc = WebViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func search() {
        let vc = SearchStickyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Stickies"
        reloadData()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(TimelineTableViewController.reload), for: .valueChanged)
        tableView.contentInset.bottom += tabBarController?.tabBar.frame.height ?? 0

        coachMarksController.delegate = self
        coachMarksController.dataSource = self
        coachMarksController.overlay.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Store.shared.state.value.stickiesRepository.state.signal.observeValues() { [weak self] state in
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
        Store.shared.state.subscribe {[weak self] _ in
            self?.reloadData()
        }
        tabBarController?.title = "タイムライン"
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_page"), style: .plain, target: self, action: #selector(TimelineTableViewController.newPage))
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(TimelineTableViewController.search))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needCoach() {
            coachMarksController.start(on: self)
        }
    }
}

extension TimelineTableViewController: CoachMarksControllerDelegate {
    func needCoach() -> Bool {
        return !UserDefaults.standard.bool(forKey: "timeline_coach_finish")
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        UserDefaults.standard.set(true, forKey: "timeline_coach_finish")
    }
}

extension TimelineTableViewController: CoachMarksControllerDataSource {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            if let view = tabBarController?.navigationItem.leftBarButtonItem?.value(forKey: "view") as? UIView {
                return coachMarksController.helper.makeCoachMark(for: view)
            }
        case 1:
            if let view = tabBarController?.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
                return coachMarksController.helper.makeCoachMark(for: view)
            }
        default:
            break
        }
        return coachMarksController.helper.makeCoachMark(for: self.view)
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = "アプリ内ブラウザもしくはSafariなどの共有拡張機能から付箋を作成できます。"
            coachViews.bodyView.nextLabel.text = "OK"
        case 1:
            coachViews.bodyView.hintLabel.text = "メモの内容・タグ名・ページ名で検索ができます。"
            coachViews.bodyView.nextLabel.text = "OK"
        default:
            break
        }
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

