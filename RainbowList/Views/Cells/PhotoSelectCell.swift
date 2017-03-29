//
//  PhotoSelectCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class PhotoSelectCell: UICollectionViewCell {
    
    var representedAssetIdentifier: String!
    
    lazy var imageView: UIImageView = {
        var imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.image = UIImage(named: "add")
        return imView
    }()
    lazy var checkButton: UIButton = {
        var btn = UIButton()
        btn.setImage(UIImage(named: "unchecked"), for: .normal)
        btn.setImage(UIImage(named: "checked"), for: .selected)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(checkButton)
        
        imageView.frame = bounds
        let btnWidth: CGFloat = 25
        checkButton.frame = CGRect(x: bounds.width - btnWidth, y: 0, width: btnWidth, height: btnWidth)
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var isSelected: Bool {
        didSet{
            checkButton.isSelected = isSelected
        }
    }
}
