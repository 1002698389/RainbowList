//
//  EventDetailCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/17.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class EventDetailCell: UITableViewCell {

    let kCellNormalHeight: CGFloat = 40
    var isEditingState: Bool = false
    
    // MARK: - Life Cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
