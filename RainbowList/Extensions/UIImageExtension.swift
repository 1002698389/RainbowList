//
//  UIImageExtension.swift
//  RainbowList
//
//  Created by admin on 2017/3/14.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

extension UIImage {
    
    func reSizeImage(reSize:CGSize)->UIImage {
        
        UIGraphicsBeginImageContextWithOptions(reSize,false, UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    func reSizeImageToMaxSize(size:CGFloat)->UIImage {
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if self.size.width < size && self.size.height < size {
            return self
        }
        
        let ratio = self.size.height / self.size.width
        if ratio > 1{
            width = size
            height =  ratio * width
        }else {
            height = size
            width = height / ratio
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height),false, UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height));
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
}
