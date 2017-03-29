//
//  PriorityCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/12.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class PriorityCell: UITableViewCell {
    
    var selectedBackgroundColorView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(hex: 0xdddddd)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    var backgroundColorView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(hex: 0xf1f1f1)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    var imgView: UIImageView = {
        var imgView = UIImageView()
        imgView.contentMode = .center
        let img = UIImage.init(named: "important")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imgView.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        return imgView
    }()
    var titleLabel: UILabel = {
        var label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "比较重要！"
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label;
    }()
    var checkButton: UIButton = {
        var button = UIButton()
        let img = UIImage.init(named: "right")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(img, for: .normal)
        button.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        return button;
    }()

    
    
    var priority: Int {
        
        didSet{
            switch priority {
            case 1:
                self.imgView.image = UIImage(named: "important")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                self.titleLabel.text = "比较重要"
            case 2:
                self.imgView.image = UIImage(named: "important_two")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                self.titleLabel.text = "非常重要"
            case 3:
                self.imgView.image = UIImage(named: "important_three")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                self.titleLabel.text = "极其重要"
            default:
                break
            }
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.priority = 0
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubViews()
        
        self.selectedBackgroundView = selectedBackgroundColorView
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubViews() {
        
        contentView.addSubview(backgroundColorView)
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkButton)
        
        backgroundColorView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(5, 0, 5, 0))
        }
        
        imgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(100)
        }
        checkButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.contentView.snp.right).offset(-20)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkButton.isHidden = !isSelected
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectedBackgroundView?.frame = CGRect(x: 0, y: 5, width: bounds.size.width, height: bounds.size.height - 10)
    }
}
