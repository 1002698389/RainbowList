//
//  EventCommentCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/16.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class EventCommentCell: EventDetailCell {

    var timeLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "#9B9B9B")
        return label
    }()
    
    var contentLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(hexString: "#2E2E3B")
        label.numberOfLines = -1
        return label
    }()
    

    var comment: RBComment? {
        
        didSet {
            timeLabel.text = DateUtil.stringInReadableFormat(date: comment?.createTime)
            contentLabel.text = comment?.content
        }
    }
    
    // MARK: - Life Cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
//        self.selectionStyle = .none
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
    }

    
    // MARK: - Private Method
    func setupSubViews() {
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(contentLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(20)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-23)
        }
    }
}
