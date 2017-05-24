//
//  DateUtil.swift
//  RainbowList
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

private let dateFormatter = DateFormatter()
private let oneDayInterval: Double = 60 * 60 * 24
private let twoDayInterval: Double = oneDayInterval * 2
private let calendar = Calendar.current

final class DateUtil: NSObject {
    
    class func stringInReadableFormat(date: Date?) -> String {
        
        guard let date = date else {
            return ""
        }
        
        let dateYear = calendar.component(.year, from: date)
        let thisYear = calendar.component(.year, from: Date())
        
        let isThisYear = dateYear == thisYear
        
        var dayFormat = "M月d日 "
        
        if isThisYear {
            
            if calendar.isDateInToday(date){
                dayFormat = ""
            }else if calendar.isDateInYesterday(date){
                dayFormat = "昨天 "
            }else if calendar.isDateInTomorrow(date){
                dayFormat = "明天 "
            }else {
                if calendar.isDateInToday(date.addingTimeInterval(twoDayInterval)) {
                    dayFormat = "前天 "
                }else if calendar.isDateInToday(date.addingTimeInterval(-twoDayInterval)){
                    dayFormat = "后天 "
                }
            }
            
        }else{
            dayFormat = "yyyy年M月d日 "
        }
        
        dateFormatter.dateFormat = dayFormat + "a h:mm"
        return dateFormatter.string(from: date)
    }
    
    class func stringInReadableFormat(date: Date?, repeatType: RBRepeatType) -> String {
        
        guard let date = date else {
            return ""
        }
        
        var dayFormat = ""
        
        switch repeatType {
        case .none:
            return stringInReadableFormat(date: date)
        case .everyDay:
            dayFormat = "每日"
        case .everyWeek:
            let weekComponent = calendar.component(.weekday, from: date)
            switch weekComponent {
            case 1:
                dayFormat = "每周日"
            case 2:
                dayFormat = "每周一"
            case 3:
                dayFormat = "每周二"
            case 4:
                dayFormat = "每周三"
            case 5:
                dayFormat = "每周四"
            case 6:
                dayFormat = "每周五"
            case 7:
                dayFormat = "每周六"
            default:
                return ""
            }
        case .everyMonth:
            let dayComponent = calendar.component(.day, from: date)
            dayFormat = "每月\(dayComponent)日"
        }
    
        dateFormatter.dateFormat = dayFormat + "a h:mm"
        return dateFormatter.string(from: date)
    }
    
    class func reduceAccuracyToDay(date: Date) -> Date?{
        let components = calendar.dateComponents([.year, .month, .day,], from: date)
        return calendar.date(from: components)
    }
    
    class func getNextNeatDate() -> Date {
        
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        
        if components.minute ?? 0 <= 30 {
            components.minute = 30
        }else {
            let time = now.addingTimeInterval(1800)
            components = calendar.dateComponents([.year, .month, .day, .hour], from: time)
        }
        
        if let date = calendar.date(from: components){
            return date
        }
        return now
    }
}
