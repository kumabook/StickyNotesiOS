//
//  StickyEditor.swift
//  StickyNotes
//
//  Created by Hiroki Kumamoto on 2017/05/08.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol StickyEditorDelegate: class {
    func cancelStickyEditor()
    func completeStickyEditor(sticky: StickyEntity)
}

class StickyEditor: UIView {
    var color: Color = Color.values[3]
    weak var delegate:   StickyEditorDelegate?
    var sticky:          StickyEntity = StickyEntity()

    var titleLabel:      UILabel!
    var contentTextView: UITextView!
    var colorView:       UIView!
    var colorSlider:     ColorSlider!
    var sliderBGView: UIImageView!
    var tagImageView:    UIImageView!
    var tagTextField:    UITextField!
    var addButton:       UIButton!
    var cancelButton:    UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 215/255, green: 237/255, blue: 255/255, alpha: 1.0)

        titleLabel      = UILabel()
        contentTextView = UITextView()
        colorView       = UIView()
        colorSlider     = ColorSlider()
        sliderBGView    = UIImageView()
        tagImageView    = UIImageView()
        tagTextField    = UITextField()
        addButton       = UIButton()
        cancelButton    = UIButton()

        addSubview(titleLabel)
        addSubview(contentTextView)
        addSubview(sliderBGView)
        addSubview(colorView)
        addSubview(colorSlider)
        addSubview(tagImageView)
        addSubview(tagTextField)
        addSubview(addButton)
        addSubview(cancelButton)

        let headerHeight = 40
        let margin = 8

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(headerHeight)
            make.width.equalTo(80)
        }
        addButton.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(headerHeight)
            make.width.equalTo(80)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(80)
            make.right.equalTo(self).offset(-80)
            make.height.equalTo(headerHeight)
        }
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(margin)
            make.left.equalTo(self).offset(margin)
            make.right.equalTo(self).offset(-margin)
            make.bottom.equalTo(self.snp.bottom).offset(-80)
        }
        colorView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(12)
            make.left.equalTo(self).offset(8)
            make.width.equalTo(32)
            make.height.equalTo(16)
        }
        colorSlider.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(-8)
            make.left.equalTo(self).offset(56 + 2)
            make.right.equalTo(self).offset(-margin*2)
            make.height.equalTo(30)
        }
        sliderBGView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(12)
            make.left.equalTo(self).offset(56)
            make.right.equalTo(self).offset(-margin*2)
            make.height.equalTo(16)
        }
        tagImageView.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-margin)
            make.left.equalTo(self).offset(8)
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        tagTextField.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-margin)
            make.left.equalTo(self).offset(48)
            make.right.equalTo(self).offset(-margin)
            make.height.equalTo(40)
        }
        titleLabel.text = "新規作成"
        titleLabel.textAlignment = .center
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        cancelButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        addButton.setTitle("Put", for: UIControlState.normal)
        addButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        addButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        colorView.backgroundColor = UIColor.red
        tagImageView.image = UIImage(named: "tag")
        tagTextField.placeholder = "tag1, tag2, tag3, ..."
        
        colorView.backgroundColor = color.backgroundColor
        
        colorSlider.minimumTrackTintColor = UIColor.clear
        colorSlider.maximumTrackTintColor = UIColor.clear
        colorSlider.backgroundColor = UIColor.clear
        colorSlider.minimumValue = 0
        colorSlider.maximumValue = Float(Color.values.count)
        colorSlider.value        = Float(Color.values.index { $0.id == color.id } ?? 0) + 0.5
        colorSlider.setThumbImage(UIImage(named: "down_arrow"), for: UIControlState())
        colorSlider.setThumbImage(UIImage(named: "down_arrow"), for: UIControlState.highlighted)
        addButton.addTarget(self, action: #selector(StickyEditor.add), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(StickyEditor.cancel), for: .touchUpInside)
        colorSlider.addTarget(self, action: #selector(StickyEditor.colorChanged(_:)), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func dispose() {
        addButton.removeTarget(self, action: #selector(StickyEditor.add), for: .touchUpInside)
        cancelButton.removeTarget(self, action: #selector(StickyEditor.cancel), for: .touchUpInside)
        colorSlider.removeTarget(self, action: #selector(StickyEditor.colorChanged(_:)), for: .valueChanged)
        removeFromSuperview()
    }

    func newSticky() {
    }

    func updateView() {
        let size = sliderBGView.frame.size
        UIGraphicsBeginImageContextWithOptions(size, true, 0);
        let context = UIGraphicsGetCurrentContext()
        
        let w = size.width / CGFloat(Color.values.count)
        Color.values.enumerated().forEach { (i, v) in
            v.backgroundColor.setFill()
            context?.fill(CGRect(x: w * CGFloat(i), y: 0, width: w, height: size.height))
        }
        sliderBGView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        contentTextView.text = sticky.content
        tagTextField.text = sticky.tags.map { $0.name }.joined(separator: ",")
    }

    func colorChanged(_ sender: AnyObject) {
        let index = min(Int(colorSlider.value), Color.values.count - 1)
        color = Color.values[index]
        colorView.backgroundColor = color.backgroundColor
    }

    func cancel(_ sender: AnyObject) {
        delegate?.cancelStickyEditor()
    }
    
    func add(_ sender: AnyObject) {
        sticky.content = contentTextView.text
        sticky.color = color.id
        if let tags = tagTextField.text?.characters.split(separator: ",").map({ String($0) }) {
            sticky.tags.append(objectsIn: tags.map { TagEntity.findOrCreateBy(name: $0) })
        }
        delegate?.completeStickyEditor(sticky: sticky)
    }
}
