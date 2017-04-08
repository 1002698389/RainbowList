//
//  Alarm.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

enum RBRepeatType: Int {
    case none
    case everyDay
    case everyWeek
    case everyMonth
}

class RBAlarm: NSObject {
    
    var identifier: String
    var ringTime : Date
    var createTime: Date
    var eventId: String
    var repeatType: RBRepeatType
    
    init (identifier: String, ringTime: Date, eventId: String, createTime: Date, repeatType: RBRepeatType){
        
        self.identifier = identifier
        self.ringTime = ringTime
        self.eventId = eventId
        self.createTime = createTime
        self.repeatType = repeatType
    }
    
    convenience init(ringTime: Date, eventId: String) {
        self.init(identifier: UUID().uuidString, ringTime: ringTime, eventId: eventId, createTime: Date(), repeatType: .none)
    }
 
    override var description: String {
        return "\(super.description)\n{\n identifier:\(identifier)\n ringTime:\(ringTime)\n \n}"
    }
}
