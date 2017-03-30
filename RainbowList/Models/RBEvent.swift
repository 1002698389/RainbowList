//
//  Event.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

enum PriroityOption {
    static let normalImportantString = "一般"
    static let quiteImportantString = "比较重要!"
    static let veryImportantString = "非常重要!!"
    static let extremelyImportantString = "极其重要!!!"
}

class RBEvent: NSObject {

    var identifier: String
    var content: String
    var remark: String?
    var list: RBList
    var alarm: RBAlarm?
    var images: [RBImage]?
    var comments: [RBComment]?
    var commentCount: Int = 0
    var priority: Int = 0 //0-3：表示0-3个叹号, 0无叹号
    var isFinished = false
    var createTime: Date
    var updateTime: Date
    
    init(identifier: String, content: String, list: RBList, createTime: Date, updateTime: Date) {
        self.identifier = identifier
        self.content = content
        self.list = list
        self.createTime = createTime
        self.updateTime = updateTime
    }
    
    convenience init(list: RBList) {
        
        self.init(identifier: UUID().uuidString,content: "", list: list, createTime: Date(), updateTime: Date())
    }
    
    override var description: String {
        return "\(super.description)\n{\n identifier:\(identifier)\n content:\(content)\n remark:\(String(describing: remark))\n list:\(list)\n alarm:\(String(describing: alarm))\n priority:\(priority)\n isFinished:\(isFinished)\n createTime:\(createTime)\n updateTime:\(updateTime)\n}"
    }
    
    
    
    //临时对象
    var imagesToDelete: [RBImage]?
    var imagesToAdd: [RBImage]?
}


