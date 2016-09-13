//
//  EditStickyViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/16/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class EditStickyViewController: UIViewController, UITextFieldDelegate {
    var sticky: StickyEntity!
    var editSticky: StickyEntity!
    
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var colorSlider: ColorSlider!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var sliderBackgroundImageView: UIImageView!
    @IBOutlet weak var hideKeyboardButton: UIButton!

    var height: CGFloat?
    init(sticky: StickyEntity) {
        self.sticky = sticky
        editSticky = sticky.clone()
        
        super.init(nibName: "EditStickyViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(EditStickyViewController.save))

        hideKeyboardButton.hidden = true
        tagTextField.text = sticky.tags.map { $0.name }.joinWithSeparator(",")
        tagTextField.delegate = self
        contentTextView.text = sticky.content
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        contentTextView.layer.cornerRadius = 8

        colorView.backgroundColor = sticky.backgroundColor

        colorSlider.minimumTrackTintColor = UIColor.clearColor()
        colorSlider.maximumTrackTintColor = UIColor.clearColor()
        colorSlider.backgroundColor = UIColor.clearColor()
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = Float(Color.values.count)
        colorSlider.value        = Float(Color.values.indexOf { $0.id == sticky.color } ?? 0) + 0.5
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

    override func viewWillLayoutSubviews() {
        guard let height = height else { return }
        view.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: height)
        super.viewWillLayoutSubviews()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditStickyViewController.keyboardWillBeShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditStickyViewController.keyboardWillBeHidden(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func keyboardWillBeShown(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else { return }
        guard let duration = info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        guard let superHeight = view.superview?.frame.height else { return }

        height = superHeight - keyboardFrame.height
        view.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: height!)
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
            self.hideKeyboardButton.hidden = false
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let duration = info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else { return }
        guard let superHeight = view.superview?.frame.height else { return }
        height = superHeight
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height!)
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
            self.hideKeyboardButton.hidden = true
        }
    }

    @IBAction func keyboardButtonTapped(sender: AnyObject) {
        view.endEditing(true)
    }

    func save() {
        editSticky.content = contentTextView.text
        if let text = tagTextField.text {
            editSticky.tags.appendContentsOf(text.characters.split(",").map {
                return TagEntity.findOrCreateBy(name: String($0))
            })
        }
        Store.sharedInstance.dispatch(EditStickyAction(sticky: sticky, editSticky: editSticky))
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func colorChanged(sender: AnyObject) {
        let index = min(Int(colorSlider.value), Color.values.count - 1)
        editSticky.color = Color.values[index].id
        colorView.backgroundColor = Color.values[index].backgroundColor
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
