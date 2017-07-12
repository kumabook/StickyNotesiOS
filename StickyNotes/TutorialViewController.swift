//
//  TutorialViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/07/09.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import UIKit
import SlideMenuControllerSwift
import EAIntroView

extension SlideMenuController: EAIntroDelegate {
    func needTutorial() -> Bool {
        return !UserDefaults.standard.bool(forKey: "tutorial_finish")
    }
    func showTutorial() {
        let titlePage            = EAIntroPage()
        titlePage.titleIconView  = UIImageView(image: UIImage(named: "title_icon"))
        titlePage.title          = "Welcom to Sticky Notes"
        titlePage.titleFont      = UIFont.boldSystemFont(ofSize: 28)
        titlePage.titlePositionY = view.bounds.height / 2
        titlePage.desc           = "Put a stickies on your web"
        titlePage.bgColor        = UIColor.themeLightColor
        titlePage.descFont       = UIFont.systemFont(ofSize: 20)

        let page2 = EAIntroPage()
        page2.titleIconView = UIImageView(image: UIImage(named: "tutorial_put"))
        page2.title = "ウェブページに付箋を貼り付けよう"
        page2.desc  = "アプリ内ブラウザのウェブページ上で三回連続でタップすると付箋を作成できます。付箋にはメモを残したり、タグ付けして管理することができます。"
        page2.bgColor = Color.get("olive")?.backgroundColor ?? UIColor.cyan
        
        let page3 = EAIntroPage()
        page3.titleIconView = UIImageView(image: UIImage(named: "tutorial_share"))
        page3.title = "ウェブページに付箋を貼り付けよう"
        page3.desc  = "StickyNotesの共有拡張機能を有効にすると、Safariなどの別のアプリから付箋を作成できます。"
        page3.bgColor = UIColor.themeColor


        let page4 = EAIntroPage()
        page4.titleIconView = UIImageView(image: UIImage(named: "tutorial_sync"))
        page4.title = "PCとも同期"
        page4.desc  = "PCのFirefox のAddonをインストールすると保存した付箋をPCとの間で同期することができます。"
        page4.bgColor = Color.get("olive")?.backgroundColor ?? UIColor.cyan

        let intro = EAIntroView(frame: view.bounds, andPages: [titlePage, page2, page3, page4])
        intro?.delegate = self
        intro?.show(in: view, animateDuration: 0.25)
    }
    public func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        UserDefaults.standard.set(true, forKey: "tutorial_finish")
        if let nav = mainViewController as? UINavigationController,
           let tbc = nav.visibleViewController as? UITabBarController {
            tbc.selectedIndex = 0
        }
        if !UserDefaults.standard.bool(forKey: "login_finish") {
            let vc = UINavigationController(rootViewController: LoginViewController())
            present(vc, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "login_finish")
        }
    }
}
