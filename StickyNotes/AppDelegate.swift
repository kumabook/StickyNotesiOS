//
//  AppDelegate.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/5/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import ReactiveSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var slideMenu: SlideMenuController?
    var pageStickies: PageStickyTableViewController?
    var observableWindow: ObservableWindow {
        return window as! ObservableWindow
    }
    var paymentManager: PaymentManager?
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let tbc = UITabBarController()

        let timeline = TimelineTableViewController()
        timeline.tabBarItem = UITabBarItem(title: "Stickies", image: UIImage(named: "content"), selectedImage: nil)
        tbc.addChildViewController(timeline)

        let tag = TagTableViewController()
        tag.tabBarItem = UITabBarItem(title: "Tags", image: UIImage(named: "tag"), selectedImage: nil)
        tbc.addChildViewController(tag)

        let page = PageTableViewController()
        page.tabBarItem = UITabBarItem(title: "Pages", image: UIImage(named: "page"), selectedImage: nil)
        tbc.addChildViewController(page)

        let profile = PreferenceTableViewController()
        profile.tabBarItem = UITabBarItem(title: "Preference", image: UIImage(named: "profile"), selectedImage: nil)
        tbc.addChildViewController(profile)
        let pageStickies = PageStickyTableViewController()
        self.pageStickies = pageStickies
        let stb = UINavigationController(rootViewController: pageStickies)
        SlideMenuOptions.rightPanFromBezel = false
        let smc = SlideMenuController(mainViewController: UINavigationController(rootViewController: tbc),
                                 rightMenuViewController: stb)
        tbc.navigationController?.navigationBar.tintColor = UIColor.themeColor
        tbc.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.themeColor]
        tbc.tabBar.tintColor = UIColor.themeColor
        slideMenu = smc
        window = ObservableWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.rootViewController = smc
        window!.makeKeyAndVisible()
        Store.sharedInstance.state.value.mode.signal.observe(Observer(value: { mode in
            switch mode {
            case .listSticky(let page):
                self.pageStickies?.page = page
                self.slideMenu?.openRight()
                DispatchQueue.main.async() {
                    Store.sharedInstance.dispatch(ListingStickyAction(page: page))
                }
            case .selectSticky(let sticky):
                self.pageStickies?.page = sticky.page
                self.slideMenu?.openRight()
            case .jumpSticky(_):
                self.slideMenu?.closeRight()
            default: break
            }
        }))
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

