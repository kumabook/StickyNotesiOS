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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localize(), style: .plain, target: self, action: #selector(EditStickyViewController.save))

        hideKeyboardButton.isHidden = true
        tagTextField.text = sticky.tags.map { $0.name }.joined(separator: ",")
        tagTextField.delegate = self
        contentTextView.text = sticky.content
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 8

        colorView.backgroundColor = sticky.backgroundColor

        colorSlider.minimumTrackTintColor = UIColor.clear
        colorSlider.maximumTrackTintColor = UIColor.clear
        colorSlider.backgroundColor = UIColor.clear
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = Float(Color.values.count)
        colorSlider.value        = Float(Color.values.index { $0.id == sticky.color } ?? 0) + 0.5
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

    override func viewWillLayoutSubviews() {
        guard let height = height else { return }
        view.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: height)
        super.viewWillLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditStickyViewController.keyboardWillBeShown(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditStickyViewController.keyboardWillBeHidden(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func keyboardWillBeShown(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { return }
        guard let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        guard let superHeight = view.superview?.frame.height else { return }

        height = superHeight - keyboardFrame.height
        view.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: height!)
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
            self.hideKeyboardButton.isHidden = false
        }) 
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        guard let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        guard let superHeight = view.superview?.frame.height else { return }
        height = superHeight
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height!)
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
            self.hideKeyboardButton.isHidden = true
        }) 
    }

    @IBAction func keyboardButtonTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }

    func save() {
        editSticky.content = contentTextView.text
        if let text = tagTextField.text {
            editSticky.tags.append(contentsOf: text.components(separatedBy: ",").map {
                return TagEntity.findOrCreateBy(name: String($0.trimmingCharacters(in: .whitespacesAndNewlines)))
            })
        }
        Store.shared.dispatch(EditStickyAction(sticky: sticky, editSticky: editSticky))
        let _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func colorChanged(_ sender: AnyObject) {
        let index = min(Int(colorSlider.value), Color.values.count - 1)
        editSticky.color = Color.values[index].id
        colorView.backgroundColor = Color.values[index].backgroundColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
