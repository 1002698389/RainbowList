//
//  EventSelectTextCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/16.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class EventSelectTextCell: EventDetailCell {
    
    static let kTextDefaultFont: UIFont = UIFont.systemFont(ofSize: 14)

    
    lazy var descLabel: UILabel = {
        var label = UILabel()
        label.text = "清单:"
        label.font = kTextDefaultFont
        label.textColor = UIColor.darkGray
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = ""
        label.font =  UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var arrowView: UIImageView = {
        var imgView = UIImageView()
        imgView.image = UIImage(named: "arrow")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imgView.contentMode = .scaleAspectFit
        imgView.isHidden = true
        imgView.tintColor = UIColor.lightGray
        return imgView
    }()
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {}
    
    override var isEditingState: Bool {
        
        didSet {
            arrowView.snp.updateConstraints { (make) in
                make.width.equalTo(isEditingState ? 16 : 0)
            }
            arrowView.isHidden = !isEditingState
        }
    }
    // MARK: - Private Method
    func setupSubViews() {
        contentView.addSubview(descLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowView)
        
        descLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(60)
            make.height.equalTo(kCellNormalHeight).priority(999)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(descLabel.snp.right).offset(20)
            make.centerY.equalTo(descLabel)
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16)
            make.width.equalTo(0)
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(10)
        }
    }
    
    func config(description:String, content: String, textAlignment: NSTextAlignment, textColor: UIColor, font: UIFont = EventSelectTextCell.kTextDefaultFont) {
        
        descLabel.text = description
        titleLabel.textColor = textColor
        titleLabel.font = font
        titleLabel.textAlignment = textAlignment
        titleLabel.text = content
    }
}
