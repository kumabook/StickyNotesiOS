//
//  PutStickyViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 9/8/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit
import MobileCoreServices

@objc(PutStickyViewController)
class PutStickyViewController: UIViewController {
    let delaySec: Double = 3

    @IBOutlet weak var stickyView: UIView!
    @IBOutlet weak var needLoginMessageView: UIView!
    @IBOutlet weak var putButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var sliderBackgroundImageView: UIImageView!
    @IBOutlet weak var colorSlider: ColorSlider!

    var color: Color = Color.values[3]

    override func viewDidLoad() {
        super.viewDidLoad()
        if APIClient.sharedInstance.isLoggedIn {
            needLoginMessageView.hidden = true
            putButton.addTarget(self, action: #selector(PutStickyViewController.putSticky), forControlEvents: .TouchUpInside)
            cancelButton.addTarget(self, action: #selector(PutStickyViewController.cancel), forControlEvents: .TouchUpInside)
            colorSlider.addTarget(self, action: #selector(PutStickyViewController.colorChanged(_:)), forControlEvents: .ValueChanged)
        } else {
            stickyView.hidden = true
        }
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height)
        UIView.animateWithDuration(1.0) {
            self.view.transform = CGAffineTransformIdentity;
            if APIClient.sharedInstance.isLoggedIn {
                return
            }
            let queue = dispatch_get_main_queue()
            let startTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self.delaySec * Double(NSEC_PER_SEC)))
            dispatch_after(startTime, queue) {
                self.complete()
            }
        }
        
        colorView.backgroundColor = color.backgroundColor
        
        colorSlider.minimumTrackTintColor = UIColor.clearColor()
        colorSlider.maximumTrackTintColor = UIColor.clearColor()
        colorSlider.backgroundColor = UIColor.clearColor()
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = Float(Color.values.count)
        colorSlider.value        = Float(Color.values.indexOf { $0.id == color.id } ?? 0) + 0.5
        colorSlider.setThumbImage(UIImage(named: "down_arrow"), forState: UIControlState.Normal)
        colorSlider.setThumbImage(UIImage(named: "down_arrow"), forState: UIControlState.Highlighted)
        
        let size = sliderBackgroundImageView.frame.size
        UIGraphicsBeginImageContextWithOptions(size, true, 0);
        let context = UIGraphicsGetCurrentContext()
        
        let w = size.width / CGFloat(Color.values.count)
        Color.values.enumerate().forEach { (i, v) in
            v.backgroundColor.setFill()
            CGContextFillRect(context, CGRectMake(w * CGFloat(i), 0, w, size.height))
        }
        sliderBackgroundImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchPage(onSuccess onSuccess: (String, String) -> (), onFailure: () -> ()) {
        self.extensionContext!.inputItems.forEach { inputItem in
            inputItem.attachments.flatMap({ $0 })?.forEach { _itemProvider in
                guard  let itemProvider = _itemProvider as? NSItemProvider else { return onFailure() }
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil) { (value, error) in
                        guard let url = value as? NSURL else { onFailure(); return }
                        self.complete(onSuccess(url.absoluteString, url.absoluteString))
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil) { (item, error) in
                        guard let results: NSDictionary = item as? NSDictionary                                else { onFailure(); return }
                        guard let dic = results[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { onFailure(); return }
                        guard let url = dic["url"] as? String, title = dic["title"] as? String                 else { onFailure(); return }
                        self.complete(onSuccess(url, title))
                    }
                } else {
                    onFailure()
                }
            }
        }
    }

    func putSticky() {
        fetchPage(onSuccess: {
            self.newSticky(url: $0, title: $1)
            }, onFailure: {
                self.complete()
        })
    }

    func newSticky(url url: String, title: String) {
        let sticky = StickyEntity()
        sticky.id      = 0
        sticky.uuid    = NSUUID().UUIDString
        sticky.left    = 0
        sticky.top     = 0
        sticky.width   = 100
        sticky.height  = 100
        sticky.content = contentTextView.text
        sticky.color   = color.id
        sticky.userId  = 0
        sticky.page = PageEntity()
        sticky.page?.title = title
        sticky.page?.url   = url
        if let tags = tagTextField.text?.characters.split(",").map({ String($0) }) {
            sticky.tags.appendContentsOf(tags.map {
                let tag = TagEntity()
                tag.name = String($0)
                return tag
                })
        }
        print(sticky)
        StickyRepository.sharedInstance.newStickies(sticky) { isSuccess in
            self.complete()
            return
        }
    }

    func colorChanged(sender: AnyObject) {
        let index = min(Int(colorSlider.value), Color.values.count - 1)
        color = Color.values[index]
        colorView.backgroundColor = color.backgroundColor
    }

    func cancel() {
        complete()
    }
    
    func complete() {
        self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
    }
}
