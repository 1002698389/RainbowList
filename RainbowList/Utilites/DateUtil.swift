//
//  DateUtil.swift
//  RainbowList
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

final class DateUtil: NSObject {
    
    static let dateFormatter = DateFormatter()
    static let oneDayInterval: Double = 60 * 60 * 24
    static let twoDayInterval: Double = oneDayInterval * 2
    static let calendar = Calendar.current
    
    
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
        
        dateFormatter.dateFormat = dayFormat + "a hh:mm"
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
