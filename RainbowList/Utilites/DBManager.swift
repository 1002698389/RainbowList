//
//  DBManager.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import FMDB


final class DBManager: NSObject {

    static let shared = DBManager()
    
    let dbQueue: FMDatabaseQueue
    
    //cache
    
    var listCache: [RBList]?
    
    private override init() {
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let path = documentPath.appending("/list.db")
        dbQueue = FMDatabaseQueue(path: path)
        super.init()
        
        createTable()
    }
    
    // MARK: - 数据表操作
    
    func createTable() {
        
        //清单表
        var sql = "CREATE TABLE IF NOT EXISTS tb_list(id TEXT PRIMARY KEY, name TEXT, theme_color_hex TEXT, order_num INTEGER, create_time INTEGER);"
        
        //事件表
        sql += "CREATE TABLE IF NOT EXISTS tb_event(id TEXT PRIMARY KEY, list_id TEXT, alarm_id TEXT, content TEXT, remark TEXT,image_ids TEXT, priority INTEGER, is_finished BOOL, create_time TEXT, update_time TEXT);"
        
        //闹钟表 1.01增加字段repeat_type
        sql += "CREATE TABLE IF NOT EXISTS tb_alarm(id TEXT PRIMARY KEY, event_id TEXT, create_time TEXT, ring_time TEXT, repeat_type INTEGER);"
        
        //评论表
        sql += "CREATE TABLE IF NOT EXISTS tb_comment(id TEXT PRIMARY KEY,event_id TEXT, content TEXT, create_time TEXT);"
        
        dbQueue.inDatabase { (db) -> Void in
            db?.executeStatements(sql)
        }
        
        updateTable()
    }
    
    func updateTable() {
        
        dbQueue.inDatabase { (db) -> Void in
            
            if let exist = db?.columnExists("repeat_type", inTableWithName: "tb_alarm") {
                if !exist {
                    db?.executeStatements("ALTER TABLE tb_alarm ADD repeat_type INTEGER;")
                }
            }
        }
    }
    
    func insertDefaultData() {
        
        let sql = "INSERT INTO tb_list(id, name, order_num, theme_color_hex, create_time) values(?,?,?,?,?);"
        
        dbQueue.inTransaction { (db, rollback) in
            do {
//                try db?.executeUpdate("delete from tb_list", values: nil)
                
                try db?.executeUpdate(sql, values: [UUID().uuidString, "待办", k_ListTable_OrderBase * 2,ThemeManager.shared.allPredefinedColorHexStrings[0], Date().timeIntervalSince1970])
                try db?.executeUpdate(sql, values: [UUID().uuidString, "购物", k_ListTable_OrderBase * 3,ThemeManager.shared.allPredefinedColorHexStrings[19], Date().timeIntervalSince1970])
                try db?.executeUpdate(sql, values: [UUID().uuidString, "电影", k_ListTable_OrderBase * 4,ThemeManager.shared.allPredefinedColorHexStrings[16], Date().timeIntervalSince1970])
                try db?.executeUpdate(sql, values: [UUID().uuidString, "书单", k_ListTable_OrderBase * 5,ThemeManager.shared.allPredefinedColorHexStrings[11], Date().timeIntervalSince1970])
                try db?.executeUpdate(sql, values: [UUID().uuidString, "锻炼", k_ListTable_OrderBase * 6,ThemeManager.shared.allPredefinedColorHexStrings[7], Date().timeIntervalSince1970])
                try db?.executeUpdate(sql, values: [UUID().uuidString, "旅游", k_ListTable_OrderBase * 7,ThemeManager.shared.allPredefinedColorHexStrings[3], Date().timeIntervalSince1970])
                try db?.executeUpdate(sql, values: [UUID().uuidString, "其他", k_ListTable_OrderBase * 8,ThemeManager.shared.allPredefinedColorHexStrings[21], Date().timeIntervalSince1970])
            }catch {
                print("========insert data error!")
            }
            
        }
    }
    
    // MARK:  List
    
    func findAlllist() -> [RBList] {
        
        if self.listCache != nil {
            return self.listCache!
        }
        
        let sql = "SELECT id, name, theme_color_hex, order_num, create_time FROM tb_list ORDER BY order_num;"
        var lists = [RBList]()
        dbQueue.inDatabase { (db) in
            do {
                if let result = try db?.executeQuery(sql, values: nil) {
                    while result.next() {
                        let id = result.string(forColumn: "id") ?? ""
                        let name = result.string(forColumn: "name") ?? ""
                        let colorHex = result.string(forColumn: "theme_color_hex") ?? ""
                        let createTimeInterval = result.longLongInt(forColumn: "create_time")
                        let createTime = Date(timeIntervalSince1970: TimeInterval(createTimeInterval))
                        let orderNum = Int(result.int(forColumn: "order_num"))
                        
                        let list = RBList(identifier: id, name: name, themeColorHexString: colorHex,orderNum: orderNum, createTime: createTime)
                        lists.append(list)
                    }
                }
            }catch let error as NSError {
                print("error: \(error)")
            }
            
        }
        self.listCache = lists
        return lists
    }

    
    func createList(list: RBList) {
        MobClick.event(UMEvent_CreateNewList)
        dbQueue.inTransaction { (db, rollback) in
            do {
                var listCount: Int = 0
                let sql_query = "select count(id) from tb_list"
                if let result = try db?.executeQuery(sql_query, values: []) {
                    while result.next() {
                        listCount = Int(result.int(forColumnIndex: 0))
                    }
                }
                let orderNum = (listCount + 1) * k_ListTable_OrderBase
                let sql_insert = "INSERT INTO tb_list(id, name, theme_color_hex, order_num, create_time) values(?,?,?,?,?);"
                try db?.executeUpdate(sql_insert, values: [list.identifier, list.name, UIColor(hexString: list.themeColorHexString).toHexString(), orderNum, list.createTime.timeIntervalSince1970])
                
            }catch {
                print("========data operation error!")
            }
        }
        self.listCache?.append(list)
    }
    
    func updateList(list: RBList) {
        MobClick.event(UMEvent_ModifyList)
        dbQueue.inDatabase { db in
            do {
                let sql = "UPDATE tb_list SET name = ?, theme_color_hex = ? WHERE id = ?;"
                try db?.executeUpdate(sql, values: [list.name, list.themeColorHexString, list.identifier])
            }catch {
                print("========data operation error!")
            }
        }
        self.listCache = nil
    }
    
    func deleteList(list: RBList) {
        MobClick.event(UMEvent_DeleteList)
        //先删事件
        let events = self.findEvents(inList: list)
        for event in events {
            self.deleteEvent(event: event)
        }
        dbQueue.inDatabase { db in
            do {
                //删清单
                let sql_delete_list = "delete from tb_list where id = ?"
                try db?.executeUpdate(sql_delete_list, values: [list.identifier])
            }catch {
                print("========data operation error!")
            }
        }
        self.listCache = listCache?.filter{$0.identifier != list.identifier}
    }
    
    func changeListOrder(list: RBList, newOrderNum: Int) {
        MobClick.event(UMEvent_ModifyListOrder)
        dbQueue.inDatabase { db in
            do {
                let sql = "UPDATE tb_list SET order_num = ? WHERE id = ?;"
                try db?.executeUpdate(sql, values:[newOrderNum, list.identifier])
            }catch {
                print("========data operation error!")
            }
        }
        
        listCache = nil
    }
    func recreateListOrders(lists: [RBList]) {
        
        MobClick.event(UMEvent_RecreateListOrder)
        dbQueue.inDatabase { db in
            do {
                for i in 0..<lists.count {
                    let list = lists[i]
                    let newOrderNum = (i + 1) * k_ListTable_OrderBase
                    let sql = "UPDATE tb_list SET order_num = ? WHERE id = ?;"
                    try db?.executeUpdate(sql, values:[newOrderNum, list.identifier])
                }
            }catch {
                print("========data operation error!")
            }
        }
        
        listCache = nil
    }
    
    // MARK:  Event
    func findEvent(eventId: String) -> RBEvent? {
        let sql = "SELECT e.id, e.list_id, e.content, e.remark, e.create_time as event_create_time, e.update_time as event_update_time, e.is_finished, e.priority, e.image_ids, e.alarm_id, a.ring_time, a.create_time as alarm_create_time, a.repeat_type, (SELECT count(id) FROM tb_comment WHERE event_id = e.id) as comments_count, l.name as list_name, l.theme_color_hex, l.order_num, l.create_time as list_create_time FROM tb_event as e LEFT JOIN tb_alarm as a on e.alarm_id == a.id LEFT JOIN tb_list as l on e.list_id == l.id WHERE e.id = ? ORDER BY event_update_time DESC;"

        var rtnEvent: RBEvent? = nil
        dbQueue.inDatabase { (db) in
            do {
                if let result = try db?.executeQuery(sql, values: [eventId]) {
                    while result.next() {
                        let id = result.string(forColumn: "id") ?? ""
                        let listId = result.string(forColumn: "list_id") ?? ""
                        let content = result.string(forColumn: "content") ?? ""
                        let remark = result.string(forColumn: "remark")
                        let createTimeInterval = result.longLongInt(forColumn: "event_create_time")
                        let updateTimeInterval = result.longLongInt(forColumn: "event_update_time")
                        let createTime = Date(timeIntervalSince1970: TimeInterval(createTimeInterval))
                        let updateTime = Date(timeIntervalSince1970: TimeInterval(updateTimeInterval))
                        let priority = Int(result.int(forColumn: "priority"))
                        let isFinished = result.bool(forColumn: "is_finished")
                        let commentCount = Int(result.int(forColumn: "comments_count"))
                        let listName = result.string(forColumn: "list_name") ?? ""
                        let themeColor = result.string(forColumn: "l.theme_color_hex") ?? ""
                        let orderNum = Int(result.int(forColumn: "order_num"))
                        let listCreateTimeInterval = result.longLongInt(forColumn: "list_create_time")
                        let listCreateTime = Date(timeIntervalSince1970: TimeInterval(listCreateTimeInterval))
                        let repeatType = Int(result.int(forColumn: "repeat_type"))
                        
                        let list = RBList(identifier: listId, name: listName, themeColorHexString: themeColor, orderNum: orderNum, createTime: listCreateTime)
                        let event = RBEvent(identifier: id, content: content, list: list, createTime: createTime, updateTime: updateTime)
                        event.remark = remark
                        event.list = list
                        event.priority = priority
                        event.isFinished = isFinished
                        event.commentCount = commentCount
                        
                        if let imageIdString = result.string(forColumn: "image_ids") {
                            let ids = imageIdString.components(separatedBy: ",")
                            let images = ids.map({ (id) -> RBImage in
                                return RBImage(identifier: id, event: event)
                            })
                            event.images = images
                        }
                        
                        //有闹铃
                        if let alarmId = result.string(forColumn: "alarm_id") {
                            let ringTimeInterval = result.longLongInt(forColumn: "ring_time")
                            let ringTime = Date(timeIntervalSince1970: TimeInterval(ringTimeInterval))
                            let ringCreateTimeInterval = result.longLongInt(forColumn: "alarm_create_time")
                            let ringCreateTime = Date(timeIntervalSince1970: TimeInterval(ringCreateTimeInterval))
                            let alarm = RBAlarm(identifier: alarmId, ringTime: ringTime, eventId: event.identifier, createTime: ringCreateTime, repeatType: RBRepeatType(rawValue: repeatType)!)
                            event.alarm = alarm
                        }
                        
                        rtnEvent = event
                    }
                }
                
                
            }catch let error as NSError {
                print("error: \(error)")
            }
            
        }
        return rtnEvent
    }
    
    func findEvents(inList list: RBList, isFinished: Bool = false) -> [RBEvent] {
        
        let sql = "SELECT e.id, e.list_id, e.content, e.remark, e.create_time as event_create_time, e.update_time as event_update_time, e.is_finished, e.priority, e.image_ids, e.alarm_id, a.ring_time, a.create_time as alarm_create_time, a.repeat_type, (SELECT count(id) FROM tb_comment WHERE event_id = e.id) as comments_count FROM tb_event as e LEFT JOIN tb_alarm as a on e.alarm_id == a.id WHERE e.list_id = ? and e.is_finished = \(isFinished ? 1: 0) ORDER BY event_update_time DESC;"
        
        var events = [RBEvent]()
        dbQueue.inDatabase { (db) in
            do {
                if let result = try db?.executeQuery(sql, values: [list.identifier]) {
                    while result.next() {
//                        print(result.resultDictionary())
                        
                        let id = result.string(forColumn: "id") ?? ""
                        let content = result.string(forColumn: "content") ?? ""
                        let remark = result.string(forColumn: "remark")
                        let createTimeInterval = result.longLongInt(forColumn: "event_create_time")
                        let updateTimeInterval = result.longLongInt(forColumn: "event_update_time")
                        let createTime = Date(timeIntervalSince1970: TimeInterval(createTimeInterval))
                        let updateTime = Date(timeIntervalSince1970: TimeInterval(updateTimeInterval))
                        let priority = Int(result.int(forColumn: "priority"))
                        let isFinished = result.bool(forColumn: "is_finished")
                        let commentCount = Int(result.int(forColumn: "comments_count"))
                        let repeatType = Int(result.int(forColumn: "repeat_type"))
                        
                        let event = RBEvent(identifier: id, content: content, list: list, createTime: createTime, updateTime: updateTime)
                        event.remark = remark
                        event.list = list
                        event.priority = priority
                        event.isFinished = isFinished
                        event.commentCount = commentCount
                        
                        if let imageIdString = result.string(forColumn: "image_ids") {
                            let ids = imageIdString.components(separatedBy: ",")
                            let images = ids.map({ (id) -> RBImage in
                                return RBImage(identifier: id, event: event)
                            })
                            event.images = images
                        }
                        
                        //有闹铃
                        if let alarmId = result.string(forColumn: "alarm_id") {
                            let ringTimeInterval = result.longLongInt(forColumn: "ring_time")
                            let ringTime = Date(timeIntervalSince1970: TimeInterval(ringTimeInterval))
                            let ringCreateTimeInterval = result.longLongInt(forColumn: "alarm_create_time")
                            let ringCreateTime = Date(timeIntervalSince1970: TimeInterval(ringCreateTimeInterval))
                            let alarm = RBAlarm(identifier: alarmId, ringTime: ringTime, eventId: event.identifier, createTime: ringCreateTime, repeatType: RBRepeatType(rawValue: repeatType)!)
                            event.alarm = alarm
                        }
                        events.append(event)

//                        print("========\(event)")
                    }
                }
                
                
            }catch let error as NSError {
                print("error: \(error)")
            }
            
        }
        
        return events
    }
    
    func addNewEvent(event: RBEvent) {
        MobClick.event(UMEvent_CreateNewEvent)
        UserNotificationManager.shared.addUserNotification(forEvent: event)
        
        let sql_alarm = "INSERT INTO tb_alarm(id, event_id, ring_time, create_time, repeat_type) values(?,?,?,?,?);"
        
        let sql_event = "INSERT INTO tb_event(id, list_id, alarm_id, content, remark, priority, image_ids, is_finished, create_time, update_time) values(?,?,?,?,?,?,?,?,?,?);"
        
        dbQueue.inTransaction { (db, rollback) in
            do {
                if let alarm = event.alarm {
                    try db?.executeUpdate(sql_alarm, values: [alarm.identifier, event.identifier, alarm.ringTime.timeIntervalSince1970 , alarm.createTime.timeIntervalSince1970, alarm.repeatType.rawValue])
                }
                
                let alarmId: Any = event.alarm?.identifier ?? NSNull()
                let remark: Any = event.remark ?? NSNull()
                var image_ids: Any =  NSNull()
                if let imgs = event.images {
                    let imageIds: [String] = imgs.map({ (image: RBImage) -> String in
                        return image.identifier
                    })
                    image_ids = imageIds.joined(separator: ",")
                }
                try db?.executeUpdate(sql_event, values: [event.identifier, event.list.identifier, alarmId, event.content, remark, event.priority, image_ids,event.isFinished, event.createTime.timeIntervalSince1970, event.updateTime.timeIntervalSince1970])
                
                if event.images != nil {
                    //保存图片
                    self.saveImages(images: event.images!, forEvent: event)
                }
                
            }catch {
                print("========data operation error!")
            }
        }
        
    }
    
    func deleteEvent(event: RBEvent) {
        MobClick.event(UMEvent_DeleteEvent)
        
        UserNotificationManager.shared.removeUserNotification(forEvent: event)
        
        dbQueue.inTransaction { (db, rollback) in
            do {
                //删评论
                if event.comments != nil {
                    let sql_comment = "DELETE FROM tb_comment WHERE event_id = ?"
                    try db?.executeUpdate(sql_comment, values: [event.identifier])
                }
                //删闹钟
                if let alarm = event.alarm {
                    let sql_alarm = "DELETE FROM tb_alarm WHERE id = ?"
                    try db?.executeUpdate(sql_alarm, values: [alarm.identifier])
                }
                //删图片
                if event.images != nil {
                    self.deleteAllImages(forEvent: event)
                }
                
                //删事件
                let sql_event = "DELETE FROM tb_event WHERE id = ?"
                try db?.executeUpdate(sql_event, values: [event.identifier])
                
            }catch {
                print("========data operation error!")
            }
        }
    }
    
    //FIXME: 关联对象目前是删掉重建，后面优化为把需要具体更新的关联对象传过来，针对具体变更更新
    func updateEvent(event: RBEvent) {
        MobClick.event(UMEvent_ModifyEvent)
        UserNotificationManager.shared.removeUserNotification(forEvent: event)
        UserNotificationManager.shared.addUserNotification(forEvent: event)
        
        dbQueue.inTransaction { (db, rollback) in
            do {
                //更新闹钟
                let sql_alarm_delete = "DELETE FROM tb_alarm WHERE event_id = ?"
                try db?.executeUpdate(sql_alarm_delete, values: [event.identifier])
                if let alarm = event.alarm {
                    let sql_alarm_insert = "INSERT INTO tb_alarm(id, event_id, ring_time, create_time) values(?,?,?,?);"
                    try db?.executeUpdate(sql_alarm_insert, values: [alarm.identifier, event.identifier, alarm.ringTime.timeIntervalSince1970 , alarm.createTime.timeIntervalSince1970])
                }
                
                //更新评论
                let sql_comment_delete = "DELETE FROM tb_comment WHERE event_id = ?"
                try db?.executeUpdate(sql_comment_delete, values: [event.identifier])
                if let comments = event.comments {
                    for i in 0..<comments.count {
                        let com = comments[i]
                        let sql_comment_insert = "INSERT INTO tb_comment(id, event_id, content, create_time) values(?,?,?,?);"
                        try db?.executeUpdate(sql_comment_insert, values: [com.identifier, event.identifier, com.content, com.createTime.timeIntervalSince1970])
                    }
                }
                //可选字段
                let alarmId: Any = event.alarm?.identifier ?? NSNull()
                let remark: Any = event.remark ?? NSNull()
                var image_ids: Any =  NSNull()
                if let imgs = event.images {
                    let imageIds: [String] = imgs.map({ (image: RBImage) -> String in
                        return image.identifier
                    })
                    image_ids = imageIds.joined(separator: ",")
                }
                //更新event
                let sql_event_update = "UPDATE tb_event SET list_id = ?, content = ?, remark = ?, alarm_id = ?, priority = ?, image_ids = ?, is_finished = ?, create_time = ?, update_time = ? WHERE id = ?;"
                try db?.executeUpdate(sql_event_update, values: [event.list.identifier, event.content, remark, alarmId, event.priority, image_ids, event.isFinished,event.createTime.timeIntervalSince1970, Date(), event.identifier])
                
                //更新图片
                if event.imagesToDelete != nil {
                    //保存图片
                    self.deleteImages(images: event.imagesToDelete!)
                }
                if event.imagesToAdd != nil {
                    //保存图片
                    self.saveImages(images: event.imagesToAdd!, forEvent: event)
                }
                
            }catch {
                print("========data operation error!")
            }
        }
    }
    
    func findeAllComments(forEvent event: RBEvent) -> [RBComment]?{
        
        let sql = "SELECT id, content, create_time FROM tb_comment WHERE event_id = ?;"
        var comments = [RBComment]()
        
        dbQueue.inDatabase { (db) in
            do {
                if let result = try db?.executeQuery(sql, values: [event.identifier]) {
                    while result.next() {
                        let id = result.string(forColumn: "id") ?? ""
                        let content = result.string(forColumn: "content") ?? ""
                        let createTimeInterval = result.longLongInt(forColumn: "create_time")
                        let createTime = Date(timeIntervalSince1970: TimeInterval(createTimeInterval))
                        
                        let comment = RBComment(identifier: id, content: content, eventId: event.identifier, createTime: createTime)
                        comments.append(comment)
                    }
                }
            }catch let error as NSError {
                print("error: \(error)")
            }
        }
        
        return comments.count > 0 ? comments : nil
    }
    
    func changeState(forEvent event: RBEvent, isFinished: Bool) {
        MobClick.event(isFinished ? UMEvent_ArchiveEvent : UMEvent_UnarchiveEvent)
        if isFinished {
            UserNotificationManager.shared.removeUserNotification(forEvent: event)
        }else{
            UserNotificationManager.shared.addUserNotification(forEvent: event)
        }
        
        dbQueue.inDatabase { (db) in
            do {
                //更新event
                let sql_event_update = "UPDATE tb_event SET is_finished = ?, update_time = ? WHERE id = ?;"
                try db?.executeUpdate(sql_event_update, values: [isFinished, Date().timeIntervalSince1970, event.identifier])
            }catch {
                print("========data operation error!")
            }
        }
    }
    
    func findArchivedEventsDictionary(inList list: RBList) -> [Date:[RBEvent]] {

        var dic = [Date:[RBEvent]]()
        let events = self.findEvents(inList: list, isFinished: true)
        
        for i in 0..<events.count{
            let event = events.reversed()[i]
            if let key = DateUtil.reduceAccuracyToDay(date: event.updateTime) {
                if dic[key] == nil {
                    dic[key] = [RBEvent]()
                }
                dic[key]?.insert(event, at: 0)
            }
        }
        return dic
    }
    
    func findArchivedEventsCount(inList list: RBList) -> Int {
        
        var count = 0
        let sql = "SELECT count(id) FROM tb_event WHERE list_id = ? and is_finished = 1;"
        
        dbQueue.inDatabase { (db) in
            do {
                if let result = try db?.executeQuery(sql, values: [list.identifier]) {
                    while result.next() {
                        count = Int(result.int(forColumnIndex: 0))
                    }
                }
            }catch let error as NSError {
                print("error: \(error)")
            }
        }
        return count
    }
  
    
    // MARK: - 图片处理
    
    func saveImages(images: [RBImage], forEvent event: RBEvent) {
        
        let start = CFAbsoluteTimeGetCurrent()
        //创建目录
        if !FileManager.default.fileExists(atPath: RBImage.getRelativeThumbnailUrlForEvent(event: event).path) && !FileManager.default.fileExists(atPath: RBImage.getRelativeOriginalUrlForEvent(event: event).path){
            do {
                try FileManager.default.createDirectory(atPath: RBImage.getRelativeThumbnailUrlForEvent(event: event).path, withIntermediateDirectories: true, attributes: nil)
                
                try FileManager.default.createDirectory(atPath: RBImage.getRelativeOriginalUrlForEvent(event: event).path, withIntermediateDirectories: true, attributes: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        
        for img in images {
            if !FileManager.default.fileExists(atPath: img.fullFileNameForThumbnail.path) && !FileManager.default.fileExists(atPath: img.fullFileNameForOriginal.path){
                
                do {
                    try img.thumbnailData?.write(to: img.fullFileNameForThumbnail)
                    try img.originalData?.write(to: img.fullFileNameForOriginal)
                } catch {
                    print(error)
                }
            } else {
                print("Image has exist!")
            }
        }
        
        let end = CFAbsoluteTimeGetCurrent()
        print("保存图片消耗时间:\(end - start)")
    }
    
    func deleteAllImages(forEvent event: RBEvent) {
        //创建目录
        if FileManager.default.fileExists(atPath: RBImage.getRelativeOriginalUrlForEvent(event: event).path) {
            do {
                try FileManager.default.removeItem(atPath: RBImage.getRelativeThumbnailUrlForEvent(event: event).path)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        if FileManager.default.fileExists(atPath: RBImage.getRelativeOriginalUrlForEvent(event: event).path){
            do {
                try FileManager.default.removeItem(atPath: RBImage.getRelativeOriginalUrlForEvent(event: event).path)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    
    func deleteImages(images: [RBImage]) {
        for img in images {
            if FileManager.default.fileExists(atPath: img.fullFileNameForOriginal.path){
                do {
                    try FileManager.default.removeItem(atPath: img.fullFileNameForOriginal.path)
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
            if FileManager.default.fileExists(atPath: img.fullFileNameForThumbnail.path){
                do {
                    try FileManager.default.removeItem(atPath: img.fullFileNameForThumbnail.path)
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
        }
    }
}
