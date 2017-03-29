//
//  EventCell.swift
//  RainbowList
//
//  Created by admin on 2017/2/28.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit

class EventCell: UITableViewCell {
    
    let kMarkViewWidth: CGFloat = 40
    let kToolbarHeight: CGFloat = 15
    let kAlarmViewWidth: CGFloat = 140
    let kPictureViewWidth: CGFloat = 90
    let kCommentViewWidth: CGFloat = 80
    let kBtnMargin: CGFloat = 10
    let kPriorityWidth: CGFloat = 50
    
    lazy var contentBackgroundView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
//        view.layer.shadowOffset = CGSize(width: 0, height: 0.5)
//        view.layer.shadowOpacity = 0.5
        return view
    }()
    
    lazy var markButton: UIButton = {
        var button = UIButton()
        let img = UIImage.init(named: "unchecked_rect")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let imgSel = UIImage.init(named: "checked_rect_stroke")
        button.setImage(img, for: .normal)
        button.setImage(imgSel, for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 0)
        button.addTarget(self, action: #selector(markBtnClicked(sender:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button;
    }()
    
    lazy var contentLabel: UILabel = {
        var label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "这里是标题"
        label.textColor = UIColor(hexString: "#2E2E3B")
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        return label;
    }()
    lazy var remarkLabel: UILabel = {
        var label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "这里是备注"
        label.textColor = UIColor(hexString: "#9B9B9B")
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        label.numberOfLines = 0
        return label;
    }()
    
    lazy var toolbar: UIView = {
        var view = UIView()

        view.addSubview(self.alarmView)
        view.addSubview(self.pictureView)
        view.addSubview(self.commentView)
        
        self.alarmView.snp.makeConstraints({ (make) in
            make.left.equalToSuperview()
            make.centerY.height.equalToSuperview()
            make.width.equalTo(0)
        })
        self.pictureView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.alarmView.snp.left)
            make.centerY.height.equalToSuperview()
            make.width.equalTo(0)
        })
        self.commentView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.alarmView.snp.left)
            make.centerY.height.equalToSuperview()
            make.width.equalTo(0)
        })
        return view
    }()
    
    lazy var alarmView: UIButton = {
        var alarmBtn = self.generateToolbarButton(title: "", imageNameNormal: "alarm")
        alarmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        alarmBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3)
        return alarmBtn
    }()
    lazy var pictureView: UIButton = {
        var pictureBtn = self.generateToolbarButton(title: "", imageNameNormal: "picture")
        return pictureBtn
    }()
    lazy var commentView: UIButton = {
        var commentBtn = self.generateToolbarButton(title: "", imageNameNormal: "comment")
        return commentBtn
    }()
    
    lazy var priorityView: UIImageView = {
        var imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        let img = UIImage.init(named: "important")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        return imgView
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        setupSubViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        contentView.frame = CGRect(x: 10, y: 0, width: contentView.bounds.size.width - 20, height: contentView.bounds.size.height)
//    }
    
    // MARK: - Public
    
    var event: RBEvent? {
        
        didSet{
            contentLabel.text = event?.content
            remarkLabel.text = event?.remark
            
            self.priorityView.tintColor = UIColor(hexString: event?.list.themeColorHexString)
            self.alarmView.tintColor = UIColor(hexString: event?.list.themeColorHexString)
            self.pictureView.tintColor = UIColor(hexString: event?.list.themeColorHexString)
            self.commentView.tintColor = UIColor(hexString: event?.list.themeColorHexString)
            self.markButton.tintColor = UIColor(hexString: event?.list.themeColorHexString)
            
            if let alarm = event?.alarm {
                self.alarmView.setTitle("\(DateUtil.stringInReadableFormat(date: alarm.ringTime))", for: .normal)
            }else{
                self.alarmView.setTitle("", for: .normal)
            }
            if let imgs = self.event?.images{
                self.pictureView.setTitle(" \(imgs.count)", for: .normal)
            }else{
                self.pictureView.setTitle("", for: .normal)
            }
            if let comCount = self.event?.commentCount {
                if comCount > 0 {
                    self.commentView.setTitle(" \(comCount)", for: .normal)
                }else{
                    self.commentView.setTitle("", for: .normal)
                }
            }
            
            let priority = event?.priority ?? 0
            
            
            switch priority {
            case 0:
                self.priorityView.image = nil
            case 1:
                self.priorityView.image = UIImage(named:"important")?.withRenderingMode(.alwaysTemplate)
            case 2:
                self.priorityView.image = UIImage(named:"important_two")?.withRenderingMode(.alwaysTemplate)
            case 3:
                self.priorityView.image = UIImage(named:"important_three")?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
            
            if let finished = event?.isFinished {
                updateUI(isFinished: finished)
            }
            
            updateMyConstraints()
        }
    }
    
    func setNumberOfLines(forTitle titleNum: Int, forRemark remarkNum: Int) {
        contentLabel.numberOfLines = titleNum
        remarkLabel.numberOfLines = remarkNum
    }
    
    // MARK: - Private Method
    func setupSubViews() {
        
        contentView.addSubview(contentBackgroundView)
        contentView.addSubview(markButton)
        contentView.addSubview(contentLabel)
        contentView.addSubview(remarkLabel)
        contentView.addSubview(toolbar)
        contentView.addSubview(priorityView)
        
        contentBackgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        markButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentBackgroundView)
            make.left.equalTo(contentBackgroundView)
            make.width.height.equalTo(kMarkViewWidth)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(markButton).offset(9)
            make.left.equalTo(markButton.snp.right).offset(5)
            make.height.greaterThanOrEqualTo(22)
//            make.right.equalTo(contentView).offset(-10)
        }
        remarkLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.equalTo(contentLabel)
            make.right.equalTo(contentBackgroundView).offset(-10)
            make.height.greaterThanOrEqualTo(0)
        }
        toolbar.snp.makeConstraints { (make) in
            make.top.equalTo(remarkLabel.snp.bottom).offset(10)
            make.bottom.equalTo(contentBackgroundView).offset(-8)
            make.left.right.equalTo(remarkLabel)
            make.height.equalTo(kToolbarHeight)
        }
        priorityView.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel.snp.right)
            make.width.equalTo(kPriorityWidth)
            make.height.equalTo(20)
            make.right.equalTo(contentBackgroundView).offset(-10)
            make.centerY.equalTo(contentLabel)
        }
    }

    
    func generateToolbarButton(title: String, imageNameNormal: String) -> UIButton {
        let btn = UIButton()
        let img = UIImage.init(named: imageNameNormal)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont (ofSize: 14)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .selected)
        btn.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        btn.contentHorizontalAlignment = .left
        btn.isEnabled = false
        return btn
    }
    
    func updateUI(isFinished: Bool){
        
        self.markButton.isSelected = isFinished
        if isFinished {
            if let content = self.event?.content {
                let attr = NSMutableAttributedString(string: content)
                attr.addAttribute(NSStrikethroughStyleAttributeName, value: NSNumber.init(value: 1), range: NSMakeRange(0, content.characters.count))
                attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGray, range: NSMakeRange(0, content.characters.count))
                contentLabel.attributedText = attr
            }
        }else{
            self.contentLabel.text = self.event?.content
            self.contentLabel.textColor = UIColor(hexString: "#2E2E3B")
        }
    }
    
    func updateMyConstraints() {
        
        //显示备注
        if self.event?.remark != nil {
            self.remarkLabel.snp.updateConstraints({ (make) in
                make.top.equalTo(self.contentLabel.snp.bottom).offset(10)
            })
        }else{
            //无备注
            self.remarkLabel.snp.updateConstraints({ (make) in
                make.top.equalTo(self.contentLabel.snp.bottom).offset(0)
            })
        }
        
        //显示toolbar
        if self.event?.alarm != nil || self.event?.images != nil || self.event?.commentCount ?? 0 > 0{
            self.toolbar.snp.updateConstraints({ (make) in
                make.top.equalTo(self.remarkLabel.snp.bottom).offset(10)
                make.height.equalTo(kToolbarHeight)
            })
            
        }else {//不显示toolbar
            self.toolbar.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
                //没有toolbar也没有备注
                if self.event?.remark == nil {
                    make.top.equalTo(self.remarkLabel.snp.bottom).offset(5)
                }else{
                    make.top.equalTo(self.remarkLabel.snp.bottom)
                }
            })
        }
        
        let hasAlarm = self.event?.alarm != nil
        let hasPic = self.event?.images != nil
        let hasComment = self.event?.commentCount ?? 0 > 0
        
        //有闹钟
        if hasAlarm {
            self.alarmView.snp.updateConstraints({ (make) in
                make.width.equalTo(kAlarmViewWidth)
            })
        }else {
            self.alarmView.snp.updateConstraints({ (make) in
                make.width.equalTo(0)
            })
        }
        
        //有图片更新图片宽度
        if  hasPic{
            self.pictureView.snp.updateConstraints({ (make) in
                make.width.equalTo(kPictureViewWidth)
                if hasAlarm {
                    make.left.equalTo(self.alarmView.snp.left).offset(kAlarmViewWidth + kBtnMargin)
                }else {
                    make.left.equalTo(self.alarmView.snp.left)
                }
            })
        }else{
            self.pictureView.snp.updateConstraints({ (make) in
                make.left.equalTo(self.alarmView.snp.left)
                make.width.equalTo(0)
            })
        }
        
        //有评论更新评论宽度
        if hasComment {
            self.commentView.snp.updateConstraints({ (make) in
                make.width.equalTo(kCommentViewWidth)
                if !hasAlarm && !hasPic {
                    make.left.equalTo(self.alarmView.snp.left)
                }else if (hasAlarm && !hasPic) || (!hasAlarm && hasPic) {
                    make.left.equalTo(self.alarmView.snp.left).offset(kAlarmViewWidth + kBtnMargin)
                }else if hasAlarm && hasPic {
                    make.left.equalTo(self.alarmView.snp.left).offset(kAlarmViewWidth + kPictureViewWidth + kBtnMargin * 2)
                }
            })
        }else{
            self.commentView.snp.updateConstraints({ (make) in
                make.left.equalTo(self.alarmView.snp.left)
                make.width.equalTo(0)
            })
        }
        
        if let priority = event?.priority {
            if priority == 0 {
                self.priorityView.snp.updateConstraints({ (make) in
                    make.width.equalTo(0)
                })
            }else {
                self.priorityView.snp.updateConstraints({ (make) in
                    make.width.equalTo(kPriorityWidth)
                })
            }
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func markBtnClicked(sender: UIButton) {
        
        if let event = event {
            DBManager.shared.changeState(forEvent: event, isFinished: !sender.isSelected)
        }
        
        updateUI(isFinished: !sender.isSelected)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationConstants.refreshEventListShouldRequeryFromDatabaseNotification), object: nil, userInfo: nil)
        }
        
    }
}
