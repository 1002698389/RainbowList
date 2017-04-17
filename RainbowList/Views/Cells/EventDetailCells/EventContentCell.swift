//
//  EventContentCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/16.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit


protocol EventContentCellDelegate: NSObjectProtocol {
    
    func contentChanged(contentCell: EventContentCell, text: String)
    func beginEdit(contentCell: EventContentCell)
    func endEdit(contentCell: EventContentCell)
}


class EventContentCell: EventDetailCell {

    static let kTextViewFontSize: CGFloat = 20
    
    weak var delegate: EventContentCellDelegate?
    
    lazy var textView: UITextView = {
        var textView = UITextView()
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: kTextViewFontSize)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.textColor = UIColor(hexString: "#2E2E3B")
        textView.returnKeyType = .done
        textView.enablesReturnKeyAutomatically = true
        textView.isEditable = false
        textView.backgroundColor = UIColor.white
        textView.isScrollEnabled = false
        textView.inputAccessoryView = self.toolbar
        //placeholder
        textView.addSubview(self.placeholderLabel)
        return textView
    }()

    lazy var placeholderLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: kTextViewFontSize)
        label.text = "内容不能为空!"
        label.sizeToFit()
        label.frame = CGRect(x: 15, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        label.textColor = UIColor.lightGray
        label.isHidden = true
        return label
    }()
    
    lazy var toolbar: UIView = {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: k_SCREEN_WIDTH, height: EventRemarkCell.kToolbarHeight))
        view.backgroundColor = UIColor(hex: 0xf6f6f6)
        
        let btn = UIButton()
        btn.setTitle("完成", for: .normal)
        btn.addTarget(self, action: #selector(endEdit), for: .touchUpInside)
        let titleColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        btn.setTitleColor(titleColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.right.equalTo(view).offset(-10)
            make.top.bottom.equalTo(view)
            make.width.equalTo(50)
        })
        
        return view
    }()
    
    var content: String? {
        
        didSet{
            textView.text = content
            placeholderLabel.isHidden = (content != "")
        }
    }
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
    }
    
    override var isEditingState: Bool {
        didSet {
            textView.isEditable = isEditingState
        }
    }
    
    
    
    // MARK: - Private Method
    func setupSubViews() {
        contentView.addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    func endEdit() {
        textView.resignFirstResponder()
    }
}

extension EventContentCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
        
        self.delegate?.contentChanged(contentCell: self, text: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            self.endEdit()
            return false
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.beginEdit(contentCell: self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.endEdit(contentCell: self)
    }
}
