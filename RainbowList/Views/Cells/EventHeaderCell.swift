//
//  EventHeaderCell.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class EventHeaderCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remainDaysLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateLabel.text = "2017年2月5日 （今天)"
        self.remainDaysLabel.text = "未完成的事项还有12件"
    }
}
