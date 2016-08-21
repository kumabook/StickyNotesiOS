//
//  AppDelegate.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/5/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var slideMenu: SlideMenuController?
    var pageStickies: PageStickyTableViewController?
    var observableWindow: ObservableWindow {
        return window as! ObservableWindow
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let tbc = UITabBarController()

        let timeline = TimelineTableViewController()
        timeline.tabBarItem = UITabBarItem(title: "Stickies", image: UIImage(named: "content"), selectedImage: nil)
        let timelineNav = UINavigationController(rootViewController:timeline)
        timelineNav.title = "Stickies"
        tbc.addChildViewController(timelineNav)

        let tag = TagTableViewController()
        tag.tabBarItem = UITabBarItem(title: "Tags", image: UIImage(named: "tag"), selectedImage: nil)
        let tagNav = UINavigationController(rootViewController:tag)
        tagNav.title = "Tags"
        tbc.addChildViewController(tagNav)

        let page = PageTableViewController()
        page.tabBarItem = UITabBarItem(title: "Pages", image: UIImage(named: "page"), selectedImage: nil)
        let pageNav = UINavigationController(rootViewController:page)
        pageNav.title = "Pages"
        tbc.addChildViewController(pageNav)

        let profile = UINavigationController(rootViewController: ProfileTableViewController())
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), selectedImage: nil)
        tbc.addChildViewController(profile)
        let pageStickies = PageStickyTableViewController()
        self.pageStickies = pageStickies
        let stb = UINavigationController(rootViewController: pageStickies)
        SlideMenuOptions.rightPanFromBezel = false
        let smc = SlideMenuController(mainViewController: tbc, rightMenuViewController: stb)
        slideMenu = smc
        window = ObservableWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = smc
        window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

