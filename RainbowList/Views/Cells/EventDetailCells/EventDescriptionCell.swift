//
//  EventDescriptionCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/16.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class EventDescriptionCell: EventDetailCell {

    static let kTextDefaultFont: UIFont = UIFont.systemFont(ofSize: 14)
    
    var desc: String? {
        didSet{
            descLabel.text = desc
        }
    }
    
    var descLabel: UILabel = {
        var label = UILabel()
        label.text = "清单:"
        label.font = kTextDefaultFont
        label.textColor = UIColor.darkGray
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        return label
    }()
    
    var addBtn: UIButton = {
        var button = UIButton()
        let img = UIImage.init(named: "add")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(img, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        return button;
    }()
    
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
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {}
    override var isEditingState: Bool {
        
        didSet {
            addBtn.snp.updateConstraints { (make) in
                make.width.equalTo(self.isEditingState ? kCellNormalHeight : 0)
            }
            addBtn.isHidden = !isEditingState
        }
    }
    
    
    // MARK: - Private Method
    func setupSubViews() {
        contentView.addSubview(descLabel)
        contentView.addSubview(addBtn)
        
        descLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(kCellNormalHeight).priority(999)
        }
        addBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(kCellNormalHeight)
        }
    }
}
