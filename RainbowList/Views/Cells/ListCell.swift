//
//  ListCell.swift
//  RainbowList
//
//  Created by admin on 2017/2/27.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

let kTagViewWidth: CGFloat = 20.0

class ListCell: UITableViewCell {

    lazy var markView: UIView = {
        var view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = kTagViewWidth / 2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var cellMaskView: UIView = {
        var view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.black
        view.alpha = 0
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        var label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "这里是标题"
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.numberOfLines = 1
        return label;
    }()
    
    // MARK: - Lift Cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor.black
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
    }
    
    func setupSubViews() {
        
        contentView.addSubview(cellMaskView)
        contentView.addSubview(markView)
        contentView.addSubview(nameLabel)
        
        markView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(10)
            make.width.height.equalTo(kTagViewWidth)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(markView.snp.right).offset(10)
            make.top.bottom.right.equalToSuperview().inset(UIEdgeInsetsMake(5, 0, 5, 5))
        }
        
        cellMaskView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    
    // MARK: - Public Method
    
    var list: RBList? {
        
        didSet {
            markView.backgroundColor = UIColor(hexString: list?.themeColorHexString)
            let luminance = UIColor(hexString: list?.themeColorHexString).luminance
            if luminance < CGFloat(0.5) {
                nameLabel.textColor = UIColor(hexString: list?.themeColorHexString).lighter()
            }else {
                nameLabel.textColor = UIColor(hexString: list?.themeColorHexString)
            }            
            nameLabel.text = list?.name
        }
    }
    
    // MARK: - inherit Method
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        cellMaskView.alpha = selected ? 0.5 : 0
    }
}
