//
//  MarkCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/27.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class MarkCell: UICollectionViewCell {
    
    var markLayer = CALayer()
    var pointLayer = CALayer()
    
    var themeColor: UIColor? {
        didSet {
            markLayer.backgroundColor = themeColor?.cgColor
        }
    }
    
    var hasUsed: Bool = false {
        didSet {
            pointLayer.isHidden = !hasUsed
        }
    }
    
    override init(frame: CGRect) {
        
        let width = frame.width
        let height = frame.height
        let margin: CGFloat = 8
        markLayer.frame = CGRect(x: margin, y: margin, width: width - margin * 2, height: height - margin * 2)
        markLayer.cornerRadius = (width - margin * 2) / 2
        markLayer.masksToBounds = true
        markLayer.borderColor = UIColor.white.cgColor
        
        let pointWidth: CGFloat = 4
        pointLayer.frame = CGRect(x: (width - pointWidth)/2, y: height - pointWidth, width: pointWidth, height: pointWidth)
        pointLayer.cornerRadius = pointWidth / 2
        pointLayer.masksToBounds = true
        pointLayer.backgroundColor = UIColor.darkGray.cgColor
        pointLayer.isHidden = true
        
        super.init(frame: frame)
        
        contentView.layer.addSublayer(markLayer)
        contentView.layer.addSublayer(pointLayer)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet{
            markLayer.borderWidth = isSelected ? 3 : 0
        }
    }
}
