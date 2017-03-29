//
//  Comment.swift
//  RainbowList
//
//  Created by admin on 2017/2/27.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class RBComment: NSObject {
    
    var identifier: String
    var createTime: Date
    var content: String
    var eventId: String
    
    convenience init(content: String, eventId: String) {
        self.init(identifier: UUID().uuidString, content: content,eventId: eventId, createTime:Date())
    }
    
    init (identifier: String, content: String,eventId: String, createTime: Date){
        self.identifier = identifier
        self.content = content
        self.eventId = eventId
        self.createTime = createTime
    }
    
    override var description: String {
        return "\(super.description)\n{\n identifier:\(identifier)\n content:\(content)\n createTime:\(createTime)\n}"
    }
}
