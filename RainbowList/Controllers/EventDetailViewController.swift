//
//  EventDetailViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/2.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import Photos
import Toast_Swift

private let kCellIdentifierForContent = "kCellIdentifierForContent"
private let kCellIdentifierForRemark = "kCellIdentifierForRemark"
private let kCellIdentifierForList = "kCellIdentifierForList"
private let kCellIdentifierForPriority = "kCellIdentifierForPriority"
private let kCellIdentifierForAlarm = "kCellIdentifierForAlarm"
private let kCellIdentifierForAttachment = "kCellIdentifierForAttachment"
private let kCellIdentifierForComment = "kCellIdentifierForComment"
private let kCellIdentifierForDesc = "kCellIdentifierForDesc"

class EventDetailViewController: UITableViewController {

    
    let kSectionIndexForContent = 0
    let kSectionIndexForRemark = 1
    let kSectionIndexForList = 2
    let kSectionIndexForAttachment = 3
    let kSectionIndexForComment = 4
    
    let kSectionHeaderHeight: CGFloat = 30
    var enableSelectRow = true
    
    var event: RBEvent
    var oldListId: String
    
    // MARK: - Life Cycle
    init(event: RBEvent) {
        self.event = event
        oldListId = event.list.identifier
        super.init(style: .grouped)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(presentNewVC(notification:)), name: Notification.Name(rawValue: NotificationConstants.presentNewViewControllerNotification), object: nil)

        setupSubviews()
        
        self.event.comments = DBManager.shared.findeAllComments(forEvent: self.event)
        self.tableView.reloadSections([kSectionIndexForComment], with: UITableViewRowAnimation.automatic)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Inherit Method
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.editButtonItem.title = editing ? "保存" : "编辑"
        tableView.setEditing(editing, animated: true)
        tableView.reloadData()
        
        if !editing {//
            self.editButtonItem.isEnabled = false
            //保存更新
            saveUpdate()
        }
    }
    
    // MARK: Setup Method
    func setupSubviews() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        customTableView()
    }
    func customTableView() {
        tableView.backgroundColor = UIColor(hex: 0xF0EFF5)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .singleLine
        tableView.allowsSelectionDuringEditing = true
        
        tableView.register(EventContentCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForContent)
        tableView.register(EventRemarkCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForRemark)
        tableView.register(EventSelectTextCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForList)
        tableView.register(EventSelectTextCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForAlarm)
        tableView.register(EventSelectTextCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForPriority)
        tableView.register(EventAttachmentCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForAttachment)
        tableView.register(EventCommentCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForComment)
        tableView.register(EventDescriptionCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForDesc)
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
    }
    // MARK: - Public Method
    
    
    // MARK: - Interaction Event Handler
    
    // MARK: - Private Method
   
    func showAddPictureSheet() {
        let controller = UIAlertController(
            title: "选择图片来源",
            message: nil,
            preferredStyle: .actionSheet)
        
        let actionPhotoAlbum = UIAlertAction(title: "相册",
                                        style: UIAlertActionStyle.default,
                                        handler: {(paramAction:UIAlertAction!) in

                                            let photoVC = PhotoSelectViewController()
                                            let nav = UINavigationController(rootViewController: photoVC)
                                            photoVC.delegate = self
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.presentNewViewControllerNotification), object: nil, userInfo: [NotificationConstants.presentNewViewControllerKey:nav])
                                        })
        
        let actionCamera = UIAlertAction(title: "相机",
                                           style: UIAlertActionStyle.default,
                                           handler: {(paramAction:UIAlertAction!) in
                                            
                                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                                let cameraVC = CameraViewController()
                                                cameraVC.cameraDelegate = self
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.presentNewViewControllerNotification), object: nil, userInfo: [NotificationConstants.presentNewViewControllerKey:cameraVC])
                                                
                                            } else {
                                                self.view.makeToast("相机不可用!")
                                            }
                                        })
        
        let actionCancel = UIAlertAction(title: "取消",
                                         style: UIAlertActionStyle.cancel,
                                         handler: {(paramAction:UIAlertAction!) in
        })
        
        controller.addAction(actionPhotoAlbum)
        controller.addAction(actionCamera)
        controller.addAction(actionCancel)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func showListChooseView() {
        let listView = ListChoosePopView(currentList: self.event.list)
        listView.show(inView: self.navigationController?.view) { list in
            self.event.list = list
            self.tableView.reloadData()
        }
    }
    
    func showDateChooseView() {
        let dateView = DateChoosePopView(date: self.event.alarm?.ringTime, repeatType: self.event.alarm?.repeatType)
        dateView.show(inView: self.navigationController?.view, chooseCompleted: {
            date, repeatType in
            if date != nil {
                if let alarm = self.event.alarm {
                    alarm.ringTime = date!
                    alarm.repeatType = repeatType!
                }else {
                    self.event.alarm = RBAlarm(ringTime: date!, eventId: self.event.identifier)
                }
                
            }else {
                self.event.alarm = nil
            }
            
            self.tableView.reloadData()
            
        }, dismissCompleted: nil)
        
    }
    
    func showPriorityChooseView() {
        let priorityView = PriorityChoosePopView(priority: self.event.priority)
        priorityView.show(inView: self.navigationController?.view) { priority in
            self.event.priority = priority
            self.tableView.reloadData()
        }
    }
    
    func showAddNewCommentView() {
        let inputView = CommentEditPopView()
        inputView.show(inView: self.navigationController?.view) { content in
            let comment = RBComment(content: content, eventId: self.event.identifier)
            
            if var comments = self.event.comments {
                comments.append(comment)
                self.event.comments = comments
            }else {
                var comments = [RBComment]()
                comments.append(comment)
                self.event.comments = comments
            }
            //用于数据库更新
            if self.event.commentsToAddForUpdate == nil {
                self.event.commentsToAddForUpdate = [RBComment]()
            }
            self.event.commentsToAddForUpdate!.append(comment)
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.event.comments!.count, section: self.kSectionIndexForComment)], with: .bottom)
            self.tableView.endUpdates()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.tableView.scrollToRow(at: IndexPath(row: self.event.comments!.count, section: self.kSectionIndexForComment), at: UITableViewScrollPosition.bottom, animated: true)
            })
            
            
        }
    }

    func saveUpdate() {
        //更改清单分组，视为新建
        if self.event.list.identifier != self.oldListId {
            self.event.createTime = Date()
        }
        if DBManager.shared.updateEvent(event: self.event) {
            UIApplication.shared.keyWindow?.makeToast("更新成功！", duration: 1, position: .center)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.refreshEventListShouldRequeryFromDatabaseNotification), object: nil)
                self.navigationController?.popViewController(animated: true)
            })
        }else {
            view.makeToast("更新失败！", duration: 1, position: .center)
            self.editButtonItem.isEnabled = true
        }
        
        event.imagesToAddForUpdate = nil
        event.imagesToDeleteForUpdate = nil
        event.commentsToAddForUpdate = nil
        event.commentsToDeleteForUpdate = nil
    }
    
    // MARK: Notification Handler
    
    func presentNewVC(notification: Notification) {
        if self === self.navigationController?.topViewController {
            if let userInfo = notification.userInfo {
                if let vc = userInfo[NotificationConstants.presentNewViewControllerKey] as? UIViewController {
                    self.navigationController?.present(vc, animated: true, completion: nil)
                }
            }
        }
        
    }
    
}

// MARK: extensions
extension EventDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        /*  
            section0:内容
            section1:备注
            section2:清单，提醒，优先级
            section3:附件
            section4:评论 
         */
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == kSectionIndexForList {//清单，提醒，优先级
            return 3
        }else if section == kSectionIndexForAttachment {
            return (self.event.images?.count ?? 0) > 0 ? 2 : 1
        }else if section == kSectionIndexForComment { //评论
            return  1 + (self.event.comments?.count ?? 0)
        }
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            if (self.event.images?.count ?? 0) > 0 {
                return CGFloat.leastNonzeroMagnitude
            }else {
                return kSectionHeaderHeight
            }
        }
        return kSectionHeaderHeight
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        //section0:内容
        case kSectionIndexForContent:
            let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForContent) as! EventContentCell
            cell.content = self.event.content
            cell.delegate = self
            cell.isEditingState = self.isEditing
            return cell
        //section1:备注
        case kSectionIndexForRemark:
            let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForRemark) as! EventRemarkCell
            cell.content = self.event.remark ?? ""
            cell.isEditingState = self.isEditing
            cell.delegate = self
            return cell
            
        //三个带右箭头的cell：清单，提醒，优先级
        case kSectionIndexForList:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForList) as! EventSelectTextCell
                cell.config(description: "清单:",
                            content:self.event.list.name,
                            textAlignment: .right,
                            textColor: UIColor(hexString: event.list.themeColorHexString))
                cell.isEditingState = self.isEditing
                return cell
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForAlarm) as! EventSelectTextCell
                
                if let alarm = self.event.alarm {
                    cell.config(description: "提醒:",
                                content: DateUtil.stringInReadableFormat(date: alarm.ringTime, repeatType: alarm.repeatType),
                                textAlignment: .right,
                                textColor: UIColor.darkGray)
                }else {
                    cell.config(description: "提醒:",
                                content: "无提醒",
                                textAlignment: .right,
                                textColor: UIColor(hexString: "#2E2E3B"))
                }
                cell.isEditingState = self.isEditing
                return cell

            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForList) as! EventSelectTextCell
                let arr = Array.init(repeating: "!", count: self.event.priority)
                if arr.count > 0 {
                    cell.config(description: "优先级:",
                                content: "\(arr.joined())",
                        textAlignment: .right,
                        textColor: UIColor(hexString: ThemeManager.shared.themeColorHexString),
                        font: UIFont.boldSystemFont(ofSize: 18))
                }else{
                    cell.config(description: "优先级:",
                                content: PriroityOption.normalImportantString,
                                textAlignment: .right,
                                textColor: UIColor(hexString: "#2E2E3B"),
                                font: UIFont.systemFont(ofSize: 15))
                }
                cell.isEditingState = self.isEditing
                return cell

            default:
                break
            }
        //section3:附件
        case kSectionIndexForAttachment:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForDesc) as! EventDescriptionCell
                cell.desc = "附件(\(self.event.images?.count ?? 0))"
                cell.isEditingState = self.isEditing
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForAttachment) as! EventAttachmentCell
                cell.delegate = self
                cell.images = self.event.images
                cell.isEditingState = self.isEditing
                return cell
            }
            
        //section4:评论
        case kSectionIndexForComment:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForDesc) as! EventDescriptionCell
                cell.desc = "评论(\(self.event.comments?.count ?? 0))"
                cell.isEditingState = self.isEditing
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForComment) as! EventCommentCell
                cell.comment = self.event.comments?[indexPath.row-1]
                cell.isEditingState = self.isEditing
                return cell
            }
            
        default:
            fatalError("generate cell error!")
            
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !self.isEditing || !self.enableSelectRow{
            return
        }
        
        switch indexPath.section {
        case kSectionIndexForContent:
            break
        case kSectionIndexForRemark:
            break
        case kSectionIndexForList:
            //清单选择
            if indexPath.row == 0 {
                showListChooseView()
            }
            //提醒
            else if indexPath.row == 1 {
                showDateChooseView()
            }
            //优先级
            else if indexPath.row == 2 {
                showPriorityChooseView()
            }
        case kSectionIndexForAttachment:
            //添加图片
            if indexPath.row == 0{
                showAddPictureSheet()
            }
        case kSectionIndexForComment:
            if indexPath.row == 0 {
                showAddNewCommentView()
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        //右上角编辑状态下允许左滑删除评论
        if !self.isEditing {
            return false
        }
        
        if indexPath.section == kSectionIndexForComment {
            return indexPath.row > 0
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if var comments = self.event.comments {
                comments.remove(at: indexPath.row - 1)
                self.event.comments = comments
                
                //用于数据库更新
                if event.commentsToDeleteForUpdate == nil {
                    event.commentsToDeleteForUpdate = [RBComment]()
                }
                if let com = self.event.comments?[indexPath.row-1] {
                    event.commentsToDeleteForUpdate!.append(com)
                    if event.commentsToAddForUpdate?.contains(com) ?? false{
                        if let index = event.commentsToAddForUpdate?.index(of: com) {
                            event.commentsToAddForUpdate?.remove(at: index)
                        }
                    }
                }
            }
        }
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .bottom)
        self.tableView.endUpdates()
    }

}
extension EventDetailViewController: EventContentCellDelegate {
    
    func contentChanged(contentCell: EventContentCell,  text: String) {
        self.event.content = text
        let contentOffset = tableView.contentOffset
        print("content offset: ===== \(contentOffset)")
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
    }
    func beginEdit(contentCell: EventContentCell) {
        self.enableSelectRow = false
    }
    func endEdit(contentCell: EventContentCell) {
        self.enableSelectRow = true
    }
}

extension EventDetailViewController: EventRemarkCellDelegate {
    
    func remarkChanged(remarkCell: EventRemarkCell, text: String) {
        self.event.remark = text
        let contentOffset = tableView.contentOffset
        print("content offset: ===== \(contentOffset)")
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
//        let rect = self.view.convert(remarkCell.frame, from: tableView)
//        tableView.scrollRectToVisible(rect, animated: false)
//        print("=======\(rect)")
        UIView.setAnimationsEnabled(true)
//        tableView.setContentOffset(contentOffset, animated: false)
    }
    func beginEdit(remarkCell: EventRemarkCell) {
        self.enableSelectRow = false
    }
   
    func endEdit(remarkCell: EventRemarkCell) {
        self.enableSelectRow = true
    }
    
}
extension EventDetailViewController: EventAttachmentCellDelegate {
    
    func deleteImage(image: RBImage) {
        event.images = event.images?.filter() {
            $0 !== image
        }
        if event.images?.count == 0 {
            tableView.reloadSections([kSectionIndexForAttachment], with: .none)
            event.images = nil
        }
        
        //用于数据库操作
        if event.imagesToDeleteForUpdate == nil {
            event.imagesToDeleteForUpdate = [RBImage]()
        }
        event.imagesToDeleteForUpdate?.append(image)
        if event.imagesToAddForUpdate!.contains(image){
            if let index = event.imagesToAddForUpdate?.index(of: image) {
                event.imagesToAddForUpdate?.remove(at: index)
            }
        }
    }
}

extension EventDetailViewController: PhotoSelectDelegate {
    func completeSelect(photoSelectViewController: PhotoSelectViewController, assets: [PHAsset]) {
        
        for i in 0..<assets.count {
            let ass = assets[i]
            let id = String(self.event.identifier) + String(Date.timeIntervalSinceReferenceDate) + "_i"
            let img = RBImage(identifier: id, event: self.event)
            
            let showWidth = CGFloat(ass.pixelWidth / ass.pixelHeight) * (EventAttachmentCell.photoHeight)
            let thumbNailSize = CGSize(width: showWidth * UIScreen.main.scale, height: EventAttachmentCell.photoHeight * UIScreen.main.scale)
                
            PHImageManager.default().requestImage(for: ass, targetSize: thumbNailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                
                img.thumbnail = image
                
                self.tableView.reloadData()
            })
            PHImageManager.default().requestImageData(for: ass, options: nil, resultHandler: { (data, string, _, _) in
                img.originalData = data
            })
            
            if self.event.images == nil {
                self.event.images = [RBImage]()
            }
            self.event.images?.insert(img, at: 0)
            
            //用于数据库操作
            if event.imagesToAddForUpdate == nil {
                event.imagesToAddForUpdate = [RBImage]()
            }
            event.imagesToAddForUpdate?.append(img)
        }
    }
}


extension EventDetailViewController: CameraViewControllerDelegate {
    func cameraVCDidCanceled(cameraViewController: CameraViewController) {
        print("cancel")
    }
    func cameraVCDidSuccessed(cameraViewController: CameraViewController, image: UIImage) {
        print("success")
        
        let id = String(self.event.identifier) + String(Date.timeIntervalSinceReferenceDate)
        let img = RBImage(identifier: id, event: self.event)
        img.thumbnail = image.reSizeImageToMaxSize(size: k_SCREEN_WIDTH / 2)
        img.original = image
        
        if self.event.images == nil {
            self.event.images = [RBImage]()
        }
        self.event.images?.insert(img, at: 0)
        
        //用于数据库操作
        if event.imagesToAddForUpdate == nil {
            event.imagesToAddForUpdate = [RBImage]()
        }
        event.imagesToAddForUpdate?.append(img)
        
        self.tableView.reloadData()
    }
}
