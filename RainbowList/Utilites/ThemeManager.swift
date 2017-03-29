//
//  ThemeManager.swift
//  RainbowList
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit


final class ThemeManager: NSObject {

    static let shared = ThemeManager()
    private override init() {
    }
    
    static let kDefaultThemeColorHexString: String = "#666666"
    
    var themeColorHexString: String = ThemeManager.kDefaultThemeColorHexString
    
    var allPredefinedColorHexStrings: [String] = ["#F44336","#e91e63","#9c27b0","#C36EE0","#673ab7",
                                            "#3f51b5","#1565C0","#03a9f4","#00bcd4","#5CA4F4",
                                            "#009688","#4caf50","#7EDC3F","#8bc34a","#cddc39",
                                            "#E0C11E","#ffc107","#EE9E1B","#ff9800","#EF6C00",
                                            "#872341","#795548","#9C875F","#607d8b","#9e9e9e"]
    var usedColorHexStrings: [String] {
        return DBManager.shared.findAlllist().map{$0.themeColorHexString}
    }

   
    
    
}
