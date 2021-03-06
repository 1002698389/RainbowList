//
//  EventListViewController.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import DynamicColor

private let eventCellIdentifier = "listCellIdentifier"
private let kAddButtonWidth: CGFloat = 56
private let kFooterViewHeight: CGFloat = 100

class EventListViewController: UIViewController {
    
    
    var events: [RBEvent]?
    var list: RBList?
    var archivedEventsDictionary: [Date:[RBEvent]]?
    var shouldShowArchivedData: Bool = false
    var archivedEventsCount: Int = 0
    
    var titleLineNumbers: Int = 0
    var remarkLineNumbers: Int = 0
    
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(EventCell.classForCoder(), forCellReuseIdentifier: eventCellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
        return tableView;
    }()
    
    lazy var titleButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0,width: 200, height:44))
        let img = UIImage.init(named: "menu")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.setTitle("标题", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.tintColor = UIColor(hex: 0xCCCCCC)
        btn.contentHorizontalAlignment = .left
        btn.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0)
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        btn.addTarget(self, action:#selector(titleBtnClicked) , for: .touchUpInside)
        return btn

    }()
    lazy var addEventButton: UIButton = {
        return self.generateNewAddButton()
    }()
    
    lazy var centerAddEventButton: UIButton = {
        return self.generateNewAddButton()
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.addSubview(self.centerAddEventButton)
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "创建新的项目"
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(label)
        
        self.centerAddEventButton.snp.makeConstraints({ (make) in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(kAddButtonWidth)
        })
        
        label.snp.makeConstraints({ (make) in
            make.top.equalTo(self.centerAddEventButton.snp.bottom).offset(5)
            make.centerX.equalTo(self.centerAddEventButton)
        })
        
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor(hex: 0xF0EFF5)
        shouldShowArchivedData = ConfigManager.shared.shouldShowArchiveData
        
        setupSubviews()
        addNotifications()
        
        //加载第一个清单
        showData(inList: DBManager.shared.findAlllist().first)
        
        self.titleLineNumbers = ConfigManager.shared.maxLineNumbersForEventCellContent
        self.remarkLineNumbers = ConfigManager.shared.maxLineNumbersForEventCellRemark
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Private Method
    
    func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(addEventButton)
        view.addSubview(emptyView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()//.inset(UIEdgeInsetsMake(0, 10, 0, 10))
        }
        addEventButton.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview().inset(UIEdgeInsetsMake(0, 0, 20, 20))
            make.width.height.equalTo(kAddButtonWidth)
        }
        emptyView.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalTo(150)
        }
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleButton)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"search"), style: .plain, target: self, action: #selector(searchBtnClicked))
    }
    
    func addNotifications() {
        //监听通知
        NotificationCenter.default.addObserver(self, selector: #selector(changeList(notification:)), name: Notification.Name(rawValue: NotificationConstants.selectListNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList(notification:)), name: Notification.Name(rawValue: NotificationConstants.refreshEventListShouldRequeryFromDatabaseNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableViewWithoutRequeryDatabase(notification:)), name: Notification.Name(rawValue: NotificationConstants.refreshEventListShouldNotRequeryNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentNewVC(notification:)), name: Notification.Name(rawValue: NotificationConstants.presentNewViewControllerNotification), object: nil)
    }
    
    func presentNewVC(notification: Notification) {
        if self === self.navigationController?.topViewController {
            if let userInfo = notification.userInfo {
                if let vc = userInfo[NotificationConstants.presentNewViewControllerKey] as? UIViewController {
                    self.navigationController?.present(vc, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func changeList(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let list = userInfo[NotificationConstants.selectedListKey] as? RBList {
                showData(inList: list)
            }else {
                showData(inList: nil)
            }
        }
    }

    func refreshList(notification: Notification) {
        showData(inList: self.list, scrollToTop: true)
    }
    
    func refreshTableViewWithoutRequeryDatabase(notification: Notification){
        self.titleLineNumbers = ConfigManager.shared.maxLineNumbersForEventCellContent
        self.remarkLineNumbers = ConfigManager.shared.maxLineNumbersForEventCellRemark
        self.tableView.reloadData()
    }
    func generateNewAddButton() -> UIButton {
        let btn = UIButton()
        let img = UIImage.init(named: "add_event")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btn.setImage(img, for: .normal)
        btn.tintColor = UIColor(hex: 0xCCCCCC)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = kAddButtonWidth / 2.0
        btn.layer.masksToBounds = true
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
        return btn
    }
    
    func showData(inList list: RBList?, scrollToTop: Bool = false) {
        self.list = list
        
        guard let list = list else {
            navigationController?.navigationBar.barTintColor = UIColor.gray
            titleButton.tintColor = UIColor.black
            titleButton.setTitle("无数据", for: .normal)
            titleButton.setTitleColor(UIColor.white, for: .normal)
            addEventButton.isHidden = true
            emptyView.isHidden = true
            return
        }
        
        centerAddEventButton.tintColor = UIColor(hexString: list.themeColorHexString)
        addEventButton.tintColor = UIColor(hexString: list.themeColorHexString)
        navigationController?.navigationBar.barTintColor = UIColor(hexString: list.themeColorHexString)
        titleButton.tintColor = UIColor(hexString: list.themeColorHexString).darkened()
        titleButton.setTitle(list.name, for: .normal)
        titleButton.setTitleColor(UIColor.white, for: .normal)
        
        self.events = DBManager.shared.findEvents(inList:list, isFinished: false)
        self.archivedEventsCount = DBManager.shared.findArchivedEventsCount(inList: list)
        if shouldShowArchivedData {
            self.archivedEventsDictionary = DBManager.shared.findArchivedEventsDictionary(inList: list)
        }
        
        tableView.reloadData()
        
        if self.events!.count > 0 {
            if scrollToTop {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        refreshEmptyView()
    }
    
    func titleBtnClicked() {
//        print("left button clicked")
        self.tableView.setEditing(false, animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.openLeftMenuNotification), object: nil)
    }

    func createButtonClicked() {
        self.tableView.setEditing(false, animated: true)
        
        if self.list != nil {
            let inputView = EventInputView(list: self.list!)
            inputView.delegate = self
            inputView.show(inView: self.navigationController?.view)
        }
        
    }
    
    func refreshEmptyView() {
        let count1 = self.events?.count ?? 0
        let count2 = self.archivedEventsCount
        
        emptyView.isHidden = count1 + count2 > 0
        addEventButton.isHidden = !emptyView.isHidden

    }
    func showOrHideArchive() {
        shouldShowArchivedData = !shouldShowArchivedData
        showData(inList: self.list)
        ConfigManager.shared.shouldShowArchiveData = shouldShowArchivedData
    }
    
    
    func archive(event: RBEvent) {
        
        if event.alarm != nil{
            let hasShow = ConfigManager.shared.hasShowAlertForArchiveData
            
            if !hasShow {
                let alert = UIAlertController(title: "提示", message: "归档后，此项目相关提醒将被取消！", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: {
                    _ in
                    self.realArchive(event: event)
                }))
                self.present(alert, animated: true, completion: nil)
                
                ConfigManager.shared.hasShowAlertForArchiveData = true
            }else {
                realArchive(event: event)
            }
        }else {
            realArchive(event: event)
        }
    }
    func realArchive(event: RBEvent) {
        event.isFinished = true
        tableView.reloadData()
        
        DBManager.shared.changeState(forEvent: event, isFinished: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.showData(inList: self.list)
        }
    }
    
    func unarchive(event: RBEvent) {
        event.isFinished = false
        tableView.reloadData()
        DBManager.shared.changeState(forEvent: event, isFinished: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.showData(inList: self.list, scrollToTop: true)
        }
    }
 
    func searchBtnClicked() {
        let vc = SearchViewController()
        vc.themeColor = UIColor(hexString: self.list?.themeColorHexString)
//        let nav = UINavigationController(rootViewController: vc)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.definesPresentationContext = true
        navigationController?.present(vc, animated: true, completion: nil)
    }
}

extension EventListViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if shouldShowArchivedData {
            return 1 + (archivedEventsDictionary?.count ?? 0)
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return events?.count ?? 0
        }else {
            if let dic = archivedEventsDictionary {
                let key = Array(dic.keys)[section-1]
                return dic[key]?.count ?? 0
            }
        }
            
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: eventCellIdentifier) as! EventCell
        
        if indexPath.section == 0 {
            cell.event = events?[indexPath.row]
            
        }else{
            if let dic = archivedEventsDictionary {
                let key = Array(dic.keys)[indexPath.section-1]
                if let evs = dic[key] {
                    cell.event = evs[indexPath.row]
                }
            }
        }
        cell.delegate = self
        cell.setNumberOfLines(forTitle: self.titleLineNumbers, forRemark: self.remarkLineNumbers)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if let event = self.events?[indexPath.row]{
                let detailVC = EventDetailViewController(event: event)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }else {
            if let dic = archivedEventsDictionary {
                let key = Array(dic.keys)[indexPath.section-1]
                if let evs = dic[key] {
                    let event = evs[indexPath.row]
                    let detailVC = EventDetailViewController(event: event)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //未归档项目
        if indexPath.section == 0 {
            guard let event = self.events?[indexPath.row] else {
                return nil
            }
            let archive = UITableViewRowAction(style: .normal, title: "归档") { action, index in
                self.archive(event: event)
            }
            archive.backgroundColor = UIColor.darkGray
            
            let delete = UITableViewRowAction(style: .normal, title: "删除") { action, index in
                DBManager.shared.deleteEvent(event: event)
                if let index = self.events?.index(of: event) {
                    self.events?.remove(at: index)
//                    self.tableView.reloadData()
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.refreshEmptyView()
                }
            }
            delete.backgroundColor = UIColor.red
            
            return [delete, archive]
            
        }else{
            //已归档项目
            if var dic = archivedEventsDictionary {
                let key = Array(dic.keys)[indexPath.section-1]
                if var evs = dic[key] {
                    let event = evs[indexPath.row]
                    let archive = UITableViewRowAction(style: .normal, title: "解档") { action, index in
                        self.unarchive(event: event)
                    }
                    archive.backgroundColor = UIColor.darkGray
                    
                    let delete = UITableViewRowAction(style: .normal, title: "删除") { action, index in
                        DBManager.shared.deleteEvent(event: event)
                        self.showData(inList: self.list)
//                        if let index = evs.index(of: event){
//                            evs.remove(at: index)
//                            dic[key] = evs
//                            self.tableView.beginUpdates()
//                            self.tableView.deleteRows(at: [indexPath], with: .none)
//                            self.tableView.endUpdates()
//                        }
                    }
                    delete.backgroundColor = UIColor.red
                    
                    return [delete, archive]
                }
            }
        }
        
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNonzeroMagnitude : 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return kFooterViewHeight
        }
        
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section > 0 {
            if let dic = archivedEventsDictionary {
                let key = Array(dic.keys)[section-1]
                let df = DateFormatter()
                df.dateFormat = "yyyy年MM月dd日"
                return df.string(from: key)
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section > 0 || self.archivedEventsCount == 0 {
            return nil
        }
        
        let footerView = UIView(frame: tableView.rectForFooter(inSection: section))
        
        let btnWidth: CGFloat = 80
        let btnHeight: CGFloat = 25
        let btn = UIButton(frame: CGRect(x: (k_SCREEN_WIDTH - btnWidth) / 2,
                                         y: (kFooterViewHeight - btnHeight) / 2,
                                         width: btnWidth,
                                         height: btnHeight))
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.setTitle(shouldShowArchivedData ? "隐藏已归档" : "显示已归档", for: .normal)
//        btn.backgroundColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.addTarget(self, action: #selector(showOrHideArchive), for: .touchUpInside)
        footerView.addSubview(btn)
        
        return footerView
    }
}

extension EventListViewController: EventInputViewDelegate {
    
    func finishedInput(inputView: EventInputView) {
        showData(inList: self.list, scrollToTop: true)
    }

}
extension EventListViewController: EventCellDelegate {
    func archiveBtnClicked(cell: EventCell) {
        
        if let indexPath = self.tableView.indexPath(for: cell) {
            
            if indexPath.section == 0 {
                if let event = self.events?[indexPath.row] {
                    if event.isFinished {
                        unarchive(event: event)
                    }else {
                        archive(event: event)
                    }
                }
            }else {
                if let dic = archivedEventsDictionary {
                    let key = Array(dic.keys)[indexPath.section-1]
                    if var evs = dic[key] {
                        let event = evs[indexPath.row]
                        if event.isFinished {
                            unarchive(event: event)
                        }else {
                            archive(event: event)
                        }
                    }
                }
            }
        }
    }
}
