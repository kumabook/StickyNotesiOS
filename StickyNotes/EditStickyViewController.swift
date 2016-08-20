//
//  EditStickyViewController.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 8/16/16.
//  Copyright © 2016 kumabook. All rights reserved.
//

import UIKit

class EditStickyViewController: UIViewController {
    var sticky: StickyEntity!
    var editSticky: StickyEntity!
    
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
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
        
        tagTextField.text = sticky.tags.map { $0.name }.joinWithSeparator(",")
        contentTextView.text = sticky.content
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        contentTextView.layer.cornerRadius = 8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
}