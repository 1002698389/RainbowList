//
//  UIColorExtension.swift
//  RainbowList
//
//  Created by admin on 2017/2/28.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit


extension UIColor {
    
    public convenience init(hexString: String?, alpha: CGFloat = 1.0) {
        guard let hexString = hexString else {
            self.init(red:1, green:1, blue:1, alpha:1)
            return
        }
        
        let hex = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner   = Scanner(string: hexString)
        
        if hex.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        
        if scanner.scanHexInt32(&color) {
            self.init(hex: color)
        }
        else {
            self.init(hex: 0x000000)
        }
    }

    public convenience init(hex: UInt32?, alpha: CGFloat = 1.0) {
        guard let hex = hex else {
            self.init(red:1, green:1, blue:1, alpha:1)
            return
        }
        
        let mask = 0x000000FF
        
        let r = Int(hex >> 16) & mask
        let g = Int(hex >> 8) & mask
        let b = Int(hex) & mask
        
        let red   = CGFloat(r) / 255
        let green = CGFloat(g) / 255
        let blue  = CGFloat(b) / 255
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    

}
