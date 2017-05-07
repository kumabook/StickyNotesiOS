//
//  WebViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/8/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import WebKit
import ReactiveSwift
import SnapKit
import GoogleMobileAds

class WebViewController: UIViewController, WKNavigationDelegate {
    enum Mode {
        case view
        case newPage
    }
    let toolbarHeight: CGFloat = 45.0
    class Observer: WindowObserver {
        weak var viewController: WebViewController?
        init(viewController: WebViewController) {
            self.viewController = viewController
        }
        override func longTapped(_ coordinate: CGPoint) {
        }
    }
    class MessageHandler: NSObject, WKScriptMessageHandler {
        weak var vc: WebViewController?
        init(vc: WebViewController) {
            self.vc = vc
        }
        func getSticky(_ dic: [String:AnyObject]) -> Sticky? {
            guard let obj = dic["sticky"] else { return nil }
            guard let s = try? Sticky.decodeValue(obj) else { return nil }
            return s
        }
        func getStickyEntity(_ dic: [String:AnyObject]) -> StickyEntity? {
            guard let s = getSticky(dic) else { return nil }
            guard let stickies = vc?.page?.stickies else { return nil }
            guard let sticky = stickies.map({ $0 }).filter({ $0.id == s.id }).first else { return nil }
            return sticky
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? String else { return }
            if message.name != "stickynotes" { return }
            let json: AnyObject? = try! JSONSerialization.jsonObject(with: body.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject?
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
    var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    var mode:             Mode = .view {
        didSet {
            switch mode {
            case .newPage:
                enterNewPageMode()
            case .view:
                enterViewMode()
            }
        }
    }
    var webView:          WKWebView?
    var bannerView:       GADBannerView?
    var page:             PageEntity? {
        didSet {
            mode = page == nil ? .newPage : .view
        }
    }
    var observer:         Observer?
    var messageHandler:   MessageHandler?
    var backButton:       UIBarButtonItem?
    var forwardButton:    UIBarButtonItem?
    var searchController: UISearchController?
    var collectionView:   UICollectionView?
    init(page: PageEntity? = nil) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "stickynotes")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bottomMargin = toolbarHeight
        if !PaymentManager.shared.isPremiumUser {
            let bannerView = createBannerView()
            bottomMargin += bannerView.frame.height
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints({ make in
                make.bottom.equalTo(view).offset(-toolbarHeight)
                make.height.equalTo(bannerView.frame.height)
                make.left.equalTo(view)
                make.right.equalTo(view)
            })
        }
        webView = createWebView()
        view.addSubview(webView!)
        webView!.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.bottom.equalTo(view).offset(-bottomMargin)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        webView!.navigationDelegate = self
        messageHandler = MessageHandler(vc: self)
        webView!.configuration.userContentController.add(messageHandler!, name: "stickynotes")

        navigationController?.navigationBar.topItem?.title = ""

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(WebViewController.enterNewPageMode))
        navigationItem.title = page?.title ?? ""

        if let str = page?.url, let url = URL(string: str) {
            let _ = webView?.load(URLRequest(url: url))
        }
        Store.shared.state.subscribe {[weak self] state in
            guard let strongSelf = self else { return }
            switch state.mode.value {
            case .jumpSticky(let sticky):
                strongSelf.jumpToSticky(sticky)
                UIScheduler().schedule {
                    guard let page = strongSelf.page else { return }
                    Store.shared.dispatch(ShowingPageAction(page: page))
                }
            default: break
            }
        }
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.height - toolbarHeight, width: view.frame.width, height: toolbarHeight))
        let back     = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(WebViewController.back))
        let forward  = UIBarButtonItem(image: UIImage(named:"forward"), style: .plain, target: self, action: #selector(WebViewController.forward))
        let space    = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let share    = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        let stickies = UIBarButtonItem(image: UIImage(named:"stickies"), style: .plain, target: self, action: #selector(WebViewController.showStickies(_:)))
        toolbar.setItems([back, space, forward, space, share, space, stickies], animated: true)
        toolbar.tintColor = UIColor.themeColor
        backButton    = back
        forwardButton = forward
        back.isEnabled    = false
        forward.isEnabled = false
        view.addSubview(toolbar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = Observer(viewController: self)
        appDelegate.observableWindow.addObserver(observer!)
        Store.shared.state.subscribe {[weak self] state in
            switch state.mode.value {
            default:
                self?.reloadStickies()
                break
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mode = page == nil ? .newPage : .view
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView?.navigationDelegate = nil
        webView?.removeFromSuperview()
        if let observer = observer {
            appDelegate.observableWindow.removeObserver(observer)
        }
    }
    
    fileprivate func createWebView() -> WKWebView {
        let script = WKUserScript(source: getSource(), injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(script)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController;
        return WKWebView(frame: view.frame, configuration: configuration)
    }

    fileprivate func createBannerView() -> GADBannerView {
        let bannerView                = GADBannerView()
        bannerView.adUnitID           = Config.default?.admobBannerAdUnitID ?? ""
        bannerView.rootViewController = self
        bannerView.adSize             = kGADAdSizeSmartBannerPortrait
        bannerView.load(GADRequest())
        return bannerView
    }

    func back() {
        let _ = webView?.goBack()
    }
    
    func forward() {
        let _ = webView?.goForward()
    }
    
    fileprivate func getSource() -> String {
        let bundle                  = Bundle.main
        let userScriptPath: String = bundle.path(forResource: "stickynotes-userscript", ofType: "js")!
        return try! String(contentsOfFile: userScriptPath)
    }
    
    func createSticky() {
        // TODO
    }
    
    func updateSticky(_ sticky: StickyEntity, editSticky: Sticky) {
        Store.shared.dispatch(EditStickyAction(sticky: sticky,
                                                   editSticky: StickyEntity(sticky: editSticky)))
    }

    func showStickies(_ sticky: StickyEntity?) {
        guard let page = page else { return }
        Store.shared.dispatch(ListStickyAction(page: page))
    }

    func jumpToSticky(_ sticky: StickyEntity) {
        try? webView?.evaluateJavaScript("StickyNotes.jumpToSticky(\(sticky.toJSONString()))") { (val, error) in
            if let error = error {
                    print("callback \(error)")
            } else if let val = val {
                print("callback \(val)")
            }
        }
    }
    
    func reloadStickies() {
        guard let stickies = page?.stickies else { return }
        let entities: [StickyEntity] = stickies.map({ $0 })
        let objs = entities.map { $0.toParameter() }
        do {
            let data = try JSONSerialization.data(withJSONObject: objs, options: .prettyPrinted)
            let jsonString = String(data: data, encoding: String.Encoding.utf8)!
            webView?.evaluateJavaScript("StickyNotes.reloadStickies(\(jsonString))") { (val, error) in
                if let error = error {
                    print("callback \(error)")
                } else if let val = val {
                    print("callback \(val)")
                }
            }
        } catch {
            print("Failed to reload stickies")
        }
    }

    func loadURL(_ url: URL) {
        if let webView = webView {
            webView.load(URLRequest(url: url))
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {}
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        backButton?.isEnabled    = webView.canGoBack
        forwardButton?.isEnabled = webView.canGoForward
        guard let url = webView.url?.absoluteString else { return }
        page = PageEntity.findOrCreateBy(url: url, title: webView.title ?? "")
        navigationItem.title = webView.title ?? url
        reloadStickies()
    }
}
