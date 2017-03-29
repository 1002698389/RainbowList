//
//  List.swift
//  RainbowList
//
//  Created by admin on 2017/2/27.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class RBList: NSObject {
    
    var identifier: String
    var createTime: Date
    var name: String
    var themeColorHexString: String
    var orderNum: Int
    
    init (identifier: String, name: String, themeColorHexString: String,orderNum: Int, createTime: Date){
        self.identifier = identifier
        self.name = name
        self.themeColorHexString = themeColorHexString
        self.createTime = createTime
        self.orderNum = orderNum
    }
    
    convenience init(name: String, themeColorHexString: String) {

        self.init(identifier: UUID().uuidString, name: name, themeColorHexString: themeColorHexString, orderNum: 0, createTime: Date())
    }

    
    override var description: String {
        return "\(super.description)\n{\n identifier:\(identifier)\n name:\(name)\n ThemeColorHex:\(themeColorHexString)\n createTime:\(createTime)\n}"
    }
}
