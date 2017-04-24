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
            needLoginMessageView.isHidden = true
            putButton.addTarget(self, action: #selector(PutStickyViewController.putSticky), for: .touchUpInside)
            cancelButton.addTarget(self, action: #selector(PutStickyViewController.cancel), for: .touchUpInside)
            colorSlider.addTarget(self, action: #selector(PutStickyViewController.colorChanged(_:)), for: .valueChanged)
        } else {
            stickyView.isHidden = true
        }
        self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.transform = CGAffineTransform.identity;
            if APIClient.sharedInstance.isLoggedIn {
                return
            }
            let queue = DispatchQueue.main
            let startTime = DispatchTime.now() + Double(Int64(self.delaySec * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            queue.asyncAfter(deadline: startTime) {
                self.complete()
            }
        }) 
        
        colorView.backgroundColor = color.backgroundColor
        
        colorSlider.minimumTrackTintColor = UIColor.clear
        colorSlider.maximumTrackTintColor = UIColor.clear
        colorSlider.backgroundColor = UIColor.clear
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = Float(Color.values.count)
        colorSlider.value        = Float(Color.values.index { $0.id == color.id } ?? 0) + 0.5
        colorSlider.setThumbImage(UIImage(named: "down_arrow"), for: UIControlState())
        colorSlider.setThumbImage(UIImage(named: "down_arrow"), for: UIControlState.highlighted)
        
        let size = sliderBackgroundImageView.frame.size
        UIGraphicsBeginImageContextWithOptions(size, true, 0);
        let context = UIGraphicsGetCurrentContext()
        
        let w = size.width / CGFloat(Color.values.count)
        Color.values.enumerated().forEach { (i, v) in
            v.backgroundColor.setFill()
            context?.fill(CGRect(x: w * CGFloat(i), y: 0, width: w, height: size.height))
        }
        sliderBackgroundImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchPage(onSuccess: @escaping (String, String) -> (), onFailure: @escaping () -> ()) {
        self.extensionContext!.inputItems.forEach { inputItem in
            (inputItem as AnyObject).attachments.flatMap({ $0 })?.forEach { _itemProvider in
                guard  let itemProvider = _itemProvider as? NSItemProvider else { return onFailure() }
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (value, error) in
                        guard let url = value as? URL else { onFailure(); return }
                        self.complete(onSuccess(url.absoluteString, url.absoluteString))
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil) { (item, error) in
                        guard let results: NSDictionary = item as? NSDictionary                                else { onFailure(); return }
                        guard let dic = results[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { onFailure(); return }
                        guard let url = dic["url"] as? String, let title = dic["title"] as? String                 else { onFailure(); return }
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

    func newSticky(url: String, title: String) {
        let sticky = StickyEntity()
        sticky.id      = 0
        sticky.uuid    = UUID().uuidString
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
        if let tags = tagTextField.text?.characters.split(separator: ",").map({ String($0) }) {
            sticky.tags.append(objectsIn: tags.map {
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

    func colorChanged(_ sender: AnyObject) {
        let index = min(Int(colorSlider.value), Color.values.count - 1)
        color = Color.values[index]
        colorView.backgroundColor = color.backgroundColor
    }

    func cancel() {
        complete()
    }
    
    func complete() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
