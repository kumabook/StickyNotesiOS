//
//  HelpWebViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/07/06.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import UIKit

class SNWebViewController: UIViewController {
    var url: URL!
    var webView: UIWebView!
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Help".localize()
        navigationItem.backBarButtonItem?.title = ""
        webView = UIWebView(frame: view.frame)
        view.addSubview(webView)
        let req = URLRequest(url: url)
        webView.loadRequest(req)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back() {
        let _ = navigationController?.popViewController(animated: true)
    }
}
