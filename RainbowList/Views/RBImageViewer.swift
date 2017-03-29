//
//  RBImageViewer.swift
//  RainbowList
//
//  Created by admin on 2017/3/22.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class RBImageViewer: UIView {
    
    var image: RBImage?
    //背景
    
    var scrollView: UIScrollView
    var imageView: UIImageView
    
    
    // MARK: - Life Cycle
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    override init(frame: CGRect) {
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))

        super.init(frame: frame)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.black
        scrollView.maximumZoomScale = 4
        self.addSubview(scrollView)
        scrollView.addSubview(imageView)
        

        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tapGesture)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("-------deinit:(\(NSStringFromClass(type(of: self))))")
    }
    
    //显示自己
    func show(image: RBImage) {
        self.image = image
        self.imageView.image = image.original
        
        if self.superview == nil {
            let window = UIApplication.shared.keyWindow
            window?.addSubview(self)

            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
            }
        }
        
        initZoomScale()
    }
    
    func dismiss() {
        self.image?.original = nil
        
        if self.superview != nil {
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        }
    }
    
    func initZoomScale() {
        
        self.scrollView.zoomScale = 1
        if let img = self.image?.original {
            let widthScale: CGFloat = self.scrollView.bounds.size.width / img.size.width
            let heightScale: CGFloat = self.scrollView.bounds.size.height / img.size.height
            let minScale: CGFloat = min(widthScale, heightScale)
            self.scrollView.contentSize = img.size
            self.imageView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(img.size.width), height: CGFloat(img.size.height))
            self.scrollView.minimumZoomScale = minScale
            self.scrollView.zoomScale = minScale
        }
        adjustImageViewCenter()
    }
    
    func adjustImageViewCenter() {
        
        if let img = self.image?.original {
            
            let yOffset: CGFloat = max(0, (self.scrollView.bounds.size.height - img.size.height * self.scrollView.zoomScale) / 2)
            let xOffset: CGFloat = max(0, (self.scrollView.bounds.size.width - img.size.width * self.scrollView.zoomScale) / 2)
            self.imageView.frame = CGRect(x: CGFloat(xOffset),
                                          y: CGFloat(yOffset),
                                          width: CGFloat(img.size.width * self.scrollView.zoomScale),
                                          height: CGFloat(img.size.height * self.scrollView.zoomScale))
        }
    }
}

extension RBImageViewer: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustImageViewCenter()
    }
}
