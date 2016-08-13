//
//  WebViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/8/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    class Observer: WindowObserver {
        weak var viewController: WebViewController?
        init(viewController: WebViewController) {
            self.viewController = viewController
        }
        override func longTapped(coordinate: CGPoint) {
        }
    }
    class MessageHandler: NSObject, WKScriptMessageHandler {
        weak var vc: WebViewController?
        init(vc: WebViewController) {
            self.vc = vc
        }
        func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
            if let body = message.body as? String {
                if message.name == "stickynotes" {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(body.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
                    if let dic = json as? [String: AnyObject],
                        type = dic["type"] as? String
                        where type == "create-sticky" {
                        vc?.createSticky()
                    }
                }
            }
        }
        
    }
    var appDelegate: AppDelegate { return UIApplication.sharedApplication().delegate as! AppDelegate }
    var webView:    WKWebView?
    var page: PageEntity?
    var observer: Observer?
    var messageHandler: MessageHandler?
    init(page: PageEntity) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        webView!.configuration.userContentController.removeScriptMessageHandlerForName("stickynotes")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = createWebView()
        view.addSubview(webView!)
        webView!.navigationDelegate = self
        messageHandler = MessageHandler(vc: self)
        webView!.configuration.userContentController.addScriptMessageHandler(messageHandler!, name: "stickynotes")
        let item = UIBarButtonItem(title: "Stickies", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(WebViewController.showStickies))
        navigationItem.rightBarButtonItem = item

        if let str = page?.url, url = NSURL(string: str) {
            webView?.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        observer = Observer(viewController: self)
        appDelegate.observableWindow.addObserver(observer!)
        appDelegate.pageStickies?.page = self.page
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView!.navigationDelegate = nil
        if let _observer = observer {
            appDelegate.observableWindow.removeObserver(_observer)
        }
        appDelegate.pageStickies?.page = self.page
    }
    
    private func createWebView() -> WKWebView {
        let script = WKUserScript(source: getSource(), injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(script)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController;
        return WKWebView(frame: view.bounds, configuration: configuration)
    }
    
    private func getSource() -> String {
        let bundle                  = NSBundle.mainBundle()
        let userScriptPath: String = bundle.pathForResource("stickynotes-userscript", ofType: "js")!
        return try! String(contentsOfFile: userScriptPath)
    }
    
    func createSticky() {
        // TODO
    }
    
    func showStickies() {
        guard let app = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        app.slideMenu?.openRight()
    }
    
    func loadURL(url: NSURL) {
        if let _webView = webView {
            _webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {}
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("frame: \(webView.frame)")
        print("contentSize: \(webView.scrollView.contentSize)")
    }
}