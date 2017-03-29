//
//  PictureCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/6.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
protocol PhotoShowCellDelegate: class {
    
    func deleteImage(photoShowCell: PhotoShowCell, identifier: String)
}

class PhotoShowCell: UICollectionViewCell {
    
    var representedAssetIdentifier: String!
    weak var delegate: PhotoShowCellDelegate?
    
    lazy var imageView: UIImageView = {
        var imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.clipsToBounds = true
        imView.backgroundColor = UIColor.orange
        return imView
    }()
    
    lazy var deleteBtn: UIButton = {
        var btn = UIButton()
        btn.setImage(UIImage(named:"delete"), for: .normal)
        btn.addTarget(self, action: #selector(deleteImg), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        contentView.addSubview(imageView)
        contentView.addSubview(deleteBtn)
        imageView.frame = CGRect(x: 8, y: 8, width: bounds.size.width-8, height: bounds.size.height-8)
        deleteBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event Handler
    
    func deleteImg() {
        self.delegate?.deleteImage(photoShowCell: self, identifier: representedAssetIdentifier)
    }
}
