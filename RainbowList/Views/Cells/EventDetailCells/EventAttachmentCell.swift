//
//  EventAttachmentCell.swift
//  RainbowList
//
//  Created by admin on 2017/3/16.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
protocol EventAttachmentCellDelegate: NSObjectProtocol {
    
    func deleteImage(image: RBImage)
}

class EventAttachmentCell: EventDetailCell {

    static var photoHeight: CGFloat {
        return 200
    }
    
    weak var delegate: EventAttachmentCellDelegate?
    let kImageMargin: CGFloat = 5
    let kButtonBaseTag = 1000
    let kImageViewBaseTag = 2000
    
    lazy var contentScrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    var imageViews = [UIImageView]()
    
    private var _oldImages: [RBImage]?
    
    var images: [RBImage]?{
        
        didSet {
            _oldImages = images
            
            //清空子视图
            contentScrollView.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            imageViews.removeAll()
            
            if let imgs = images {
                var sumWidth: CGFloat = kImageMargin
                for i in 0 ..< imgs.count {
                    if let img = imgs[i].thumbnail {
                        let showWidth = img.size.width / img.size.height * (EventAttachmentCell.photoHeight)
                        let frame = CGRect(x: sumWidth, y: 0, width: showWidth, height: EventAttachmentCell.photoHeight)
                        let imgView = generateImageView(frame: frame, image:img)
                        imgView.tag = kImageViewBaseTag + i
                        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView(gesture:)))
                        imgView.isUserInteractionEnabled = true
                        imgView.addGestureRecognizer(tap)
                        
                        contentScrollView.addSubview(imgView)
                        sumWidth += showWidth + kImageMargin
                        imgView.clipsToBounds = true
                        imageViews.append(imgView)
                    }
                }
                contentScrollView.contentSize = CGSize(width: sumWidth, height: EventAttachmentCell.photoHeight)
            }
            
            if let imgs = images, let oldImgs = _oldImages {
                if imgs.count > oldImgs.count {
                    contentScrollView.setContentOffset(CGPoint.zero, animated: false)
                }
            }
            
            
            if self.isEditingState {
                addDeleteButtons()
                scaleImageViewsFrame()
            }
        }
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
    }
    
    override var isEditingState: Bool {
        
        didSet {
            removeDeleteButtons()
            resetImageViewsFrame()
            
            if isEditingState {
                addDeleteButtons()
                scaleImageViewsFrame()
            }
        }
    }
    
    // MARK: - Life Cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.imageViews.count == 1 && !self.isEditingState{
            let imgView = self.imageViews.first
            imgView?.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
//            imgView?.frame = bounds.insetBy(dx: 10, dy: 0)
//            imgView?.contentMode = .scaleAspectFill
        }
    }
    
    // MARK: - Private Method
    func setupSubViews() {
        contentView.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(10, 0, 10, 0))
            make.height.equalTo(EventAttachmentCell.photoHeight).priority(.high)
            make.width.equalTo(k_SCREEN_WIDTH)
        }
    }
    
    func generateImageView(frame: CGRect, image: UIImage?) -> UIImageView {
        let imgView = UIImageView(frame: frame)
        imgView.contentMode = .scaleAspectFill
        imgView.image = image
        return imgView
    }

    func getTag(index: Int) -> Int {
        return kButtonBaseTag + index
    }
    func getIndex(tag: Int) -> Int {
        return tag - kButtonBaseTag
    }
   
    func addDeleteButtons() {
        
        for i in 0 ..< self.imageViews.count {
            let imgView = self.imageViews[i]
            //添加删除按钮
            let btnWidth: CGFloat = 30
            let btn = UIButton(frame: CGRect(x: imgView.frame.origin.x, y: imgView.frame.origin.y, width: btnWidth, height: btnWidth))
            btn.setImage(UIImage(named:"yi"), for: .normal)
            btn.addTarget(self, action: #selector(deleteBtnClicked(sender:)), for: .touchUpInside)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.backgroundColor = UIColor.red
            btn.layer.cornerRadius = btnWidth / 2
            btn.layer.masksToBounds = true
            btn.tag = getTag(index: i)
            contentScrollView.addSubview(btn)
        }
    }
    func removeDeleteButtons() {
        contentScrollView.subviews.forEach({ (view) in
            if view is UIButton {
                view.removeFromSuperview()
            }
        })
    }
    
    func scaleImageViewsFrame() {
        
        for i in 0 ..< self.imageViews.count {
            let imageView = self.imageViews[i]
            let imgOffset: CGFloat = 12
            imageView.frame = CGRect(x: imageView.frame.origin.x + imgOffset,
                                     y: imageView.frame.origin.y + imgOffset,
                                     width: imageView.bounds.size.width - imgOffset,
                                     height: imageView.bounds.size.height - imgOffset * 2)
            
        }
    }
    func resetImageViewsFrame() {
        
        var sumWidth:  CGFloat = kImageMargin
        for i in 0 ..< self.imageViews.count {
            let imgView = self.imageViews[i]
            if let imgs = self.images{
                if let img = imgs[i].thumbnail {
                    let showWidth = img.size.width / img.size.height * (EventAttachmentCell.photoHeight)
                    imgView.frame = CGRect(x: sumWidth, y: 0, width: showWidth, height: EventAttachmentCell.photoHeight)
                    sumWidth += showWidth + kImageMargin
                }
            }
        }
        
        if self.imageViews.count == 1 && !self.isEditingState {
            let imgView = self.imageViews.first
            imgView?.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        }

    }
    
    func deleteBtnClicked(sender: UIButton) {
        
        let index = getIndex(tag: sender.tag)
        if let img = self.images?[index] {
            self.delegate?.deleteImage(image: img)
        }
        self.images?.remove(at: index)
    }
    
    func tapImageView(gesture: UITapGestureRecognizer){
        
        if let view = gesture.view {
            let index = view.tag - kImageViewBaseTag
            if let img = self.images?[index] {
                RBImageViewer().show(image: img)
            }
        }
    }
}
