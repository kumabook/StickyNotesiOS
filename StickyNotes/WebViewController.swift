//
//  WebViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/8/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import WebKit
import ReactiveCocoa

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
        func getSticky(dic: [String:AnyObject]) -> Sticky? {
            guard let obj = dic["sticky"] else { return nil }
            guard let s = try? Sticky.decodeValue(obj) else { return nil }
            return s
        }
        func getStickyEntity(dic: [String:AnyObject]) -> StickyEntity? {
            guard let s = getSticky(dic) else { return nil }
            guard let stickies = vc?.page?.stickies else { return nil }
            guard let sticky = stickies.map({ $0 }).filter({ $0.id == s.id }).first else { return nil }
            return sticky
        }
        func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
            guard let body = message.body as? String else { return }
            if message.name != "stickynotes" { return }
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(body.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
            guard let dic = json as? [String: AnyObject] else { return }
            guard let type = dic["type"] as?  String else { return }
            switch type {
            case "create-sticky":
                vc?.createSticky()
            case "update-sticky":
                guard let editSticky = getSticky(dic) else { return }
                guard let sticky = getStickyEntity(dic) else { return }
                vc?.updateSticky(sticky, editSticky: editSticky)
            case "select-sticky":
                guard let sticky = getStickyEntity(dic) else { return }
                vc?.showStickies(sticky)
            default:
                break
            }
        }
    }
    var appDelegate: AppDelegate { return UIApplication.sharedApplication().delegate as! AppDelegate }
    var webView:     WKWebView?
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
        let _webView = createWebView()
        view.addSubview(_webView)
        webView = _webView
        webView!.navigationDelegate = self
        messageHandler = MessageHandler(vc: self)
        webView!.configuration.userContentController.addScriptMessageHandler(messageHandler!, name: "stickynotes")
        let item = UIBarButtonItem(title: "Stickies", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(WebViewController.showStickies))
        navigationItem.rightBarButtonItem = item
        navigationItem.title = page!.title

        if let str = page?.url, url = NSURL(string: str) {
            webView?.loadRequest(NSURLRequest(URL: url))
        }
        Store.sharedInstance.state.subscribe {[weak self] state in
            guard let strongSelf = self else { return }
            switch state.mode.value {
            case .JumpSticky(let sticky):
                strongSelf.jumpToSticky(sticky)
                UIScheduler().schedule {
                    Store.sharedInstance.dispatch(ShowingPageAction(page: strongSelf.page!))
                }
            default: break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        observer = Observer(viewController: self)
        appDelegate.observableWindow.addObserver(observer!)
        Store.sharedInstance.state.subscribe {[weak self] state in
            switch state.mode.value {
            default:
                self?.reloadStickies()
                break
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView?.navigationDelegate = nil
        webView?.removeFromSuperview()
        if let observer = observer {
            appDelegate.observableWindow.removeObserver(observer)
        }
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
    
    func updateSticky(sticky: StickyEntity, editSticky: Sticky) {
        Store.sharedInstance.dispatch(EditStickyAction(sticky: sticky,
                                                   editSticky: StickyEntity(sticky: editSticky)))
    }

    func showStickies(sticky: StickyEntity?) {
        guard let page = page else { return }
        Store.sharedInstance.dispatch(ListStickyAction(page: page))
    }

    func jumpToSticky(sticky: StickyEntity) {
        try! webView?.evaluateJavaScript("StickyNotes.jumpToSticky(\(sticky.toJSONString()))") { (val, error) in
            print("callback \(val) \(error)")
        }
    }
    
    func reloadStickies() {
        guard let objs = page?.stickies.map({ $0.toParameter() }) else { return }
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(objs, options: .PrettyPrinted)
            let jsonString = String(data: data, encoding: NSUTF8StringEncoding)!
            webView?.evaluateJavaScript("StickyNotes.reloadStickies(\(jsonString))") { (val, error) in
                print("callback \(val) \(error)")
            }
        } catch {
            print("Failed to reload stickies")
        }
    }

    func loadURL(url: NSURL) {
        if let webView = webView {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {}
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.reloadStickies()
    }
}