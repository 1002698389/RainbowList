//
//  LeftMenuViewController.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit


class LeftMenuViewController: UIViewController {

    static let kBottomToolbarHeight: CGFloat = 50.0
    static let kUpperToolbarHeight: CGFloat = 50.0
    static let kFooterViewHeight: CGFloat = 50
    static let kVerMargin: CGFloat = 20
    static let cellIdentifier = "cellIdentifier"
    static let kTableviewRowHeight: CGFloat = 40
    static let kTableviewHeight: CGFloat = k_SCREEN_HEIGHT - LeftMenuViewController.kUpperToolbarHeight - LeftMenuViewController.kBottomToolbarHeight - LeftMenuViewController.kVerMargin * 2
    
    var selectedList: RBList?
    var selectRowByCode: Bool = false
    var lists = [RBList]()
    
    lazy var upperToolbar: UIView = {
        var tool: UIView = UIView()
        tool.addSubview(self.edittingButton)
        self.edittingButton.snp.makeConstraints({ (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(tool.snp.height)
        })
        
        
        return tool
    }()
    lazy var bottomToolbar: UIView = {
        var tool: UIView = UIView()
        tool.addSubview(self.settingButton)
        self.settingButton.snp.makeConstraints({ (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(tool.snp.height)
        })
        return tool
    }()

    lazy var edittingButton: UIButton = {
        var btn = UIButton()
        btn.setImage(UIImage.init(named: "editting"), for: .normal)
        btn.addTarget(self, action: #selector(beginEditing), for: .touchUpInside)
        return btn
    }()
    
    lazy var closeButton: UIButton = {
        var btn = UIButton()
        let img = UIImage(named: "back")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btn.tintColor = UIColor.lightGray
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(endEditing), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    lazy var settingButton: UIButton = {
        var btn = UIButton()
        btn.setImage(UIImage.init(named: "setting"), for: .normal)
        btn.addTarget(self, action: #selector(settingBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    lazy var addButton: UIButton = {
        var btn = UIButton()
        let img = UIImage(named: "add_event")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btn.tintColor = UIColor.lightGray
        btn.setImage(img, for: .normal)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(addBtnClicked), for: .touchUpInside)
        return btn
    }()
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.bounces = false
        tableView.allowsSelectionDuringEditing = true
        tableView.register(ListCell.classForCoder(), forCellReuseIdentifier: LeftMenuViewController.cellIdentifier)
        tableView.rowHeight = LeftMenuViewController.kTableviewRowHeight
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = self.view.bounds
        layer.colors = [UIColor.purple.cgColor,UIColor.orange.cgColor,UIColor.purple.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        return layer
    }()
    
    var panGesture: UIPanGestureRecognizer?
    //MARK:-  Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#233142")
        view.isUserInteractionEnabled = true
//        view.layer.addSublayer(gradientLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDataAndScrollToBottom), name: Notification.Name.init(NotificationConstants.refreshListDataWithCreationNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: Notification.Name.init(NotificationConstants.refreshListDataWithUpdateNotification), object: nil)
        
        setupSubviews()
        refreshData()
        
        selectFirstRow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - custom method
    func setupSubviews() {
        view.addSubview(upperToolbar)
        view.addSubview(bottomToolbar)
        view.addSubview(tableView)
        view.addSubview(closeButton)
        
        upperToolbar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(LeftMenuViewController.kUpperToolbarHeight)
        }
        bottomToolbar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(LeftMenuViewController.kBottomToolbarHeight)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(upperToolbar.snp.bottom).offset(LeftMenuViewController.kVerMargin)
            make.height.equalTo(LeftMenuViewController.kTableviewHeight)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(-50)
        }
        
        view.layoutIfNeeded()
    }
    
    func refreshDataAndScrollToBottom() {
        refreshData()
        if lists.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: lists.count - 1, section: 0), at: .bottom, animated: true)
            if lists.count == 1 {
                self.selectFirstRow()
            }
        }
    }
    
    func refreshData() {
        lists.removeAll()
        lists.append(contentsOf:DBManager.shared.findAlllist())
        tableView.reloadData()
        tableView.bounces = CGFloat(lists.count) * LeftMenuViewController.kTableviewRowHeight > LeftMenuViewController.kTableviewHeight
    }
    func selectFirstRow() {
        if lists.count > 0 {
            let firsRow = IndexPath.init(row: 0, section: 0)
            selectRowByCode = true
            self.tableView.selectRow(at: firsRow, animated: false, scrollPosition: .none)
            self.tableView(self.tableView, didSelectRowAt: firsRow)
            selectRowByCode = false
        }
    }
    func beginEditing() {
        
        MobClick.event(UMEvent_ClickEditListButton)
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: NotificationConstants.openLeftMenuEntirelyNotification), object: nil)

        self.closeButton.isHidden = false
        self.addButton.isHidden = false
        self.settingButton.isHidden = true
        self.edittingButton.isHidden = true
        UIView.setAnimationsEnabled(false)
        self.tableView.isEditing = true
        self.tableView.reloadData()
        UIView.setAnimationsEnabled(true)
        
        UIView.animate(withDuration: 0.25) {
            self.closeButton.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(10)
            }
            self.view.layoutIfNeeded()
        }
    }
    func endEditing() {
        
        self.closeButton.isHidden = true
        self.addButton.isHidden = true
        self.settingButton.isHidden = false
        self.edittingButton.isHidden = false
        self.tableView.setEditing(false, animated: false)
        self.tableView.reloadData()
        
        if let list = self.selectedList {
            let listIds = self.lists.map{$0.identifier}
            if let index = listIds.index(of: list.identifier) {
                let indexPath = IndexPath(row: index, section: 0)
//                self.tableView(self.tableView, didSelectRowAt: indexPath)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotificationConstants.openLeftMenuNotification), object: nil)
    }
    func settingBtnClicked() {
        MobClick.event(UMEvent_ClickSettingButton)
        
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotificationConstants.jumpToSettingPageNotification), object: nil)
    }
    
    func addBtnClicked() {
        let createVC = CreateOrUpdateListViewController()
        let nav = UINavigationController(rootViewController: createVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    func deleteList(list: RBList) {
        
//        if self.lists.count == 1 {
//            view.makeToast("只少需要保留一个清单！")
//            return
//        }

        
        let alert = UIAlertController(title: "警告", message: "该清单中所有内容将被一同删除，且无法恢复!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: {
            _ in
            DBManager.shared.deleteList(list: list)
            self.refreshData()
            if list == self.selectedList {
                self.selectFirstRow()
            }
            if self.lists.count == 0 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationConstants.selectListNotification), object: nil, userInfo: [NotificationConstants.selectedListKey:""])
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LeftMenuViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LeftMenuViewController.cellIdentifier) as! ListCell
        cell.list = lists[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = lists[indexPath.row]
        if !tableView.isEditing || selectRowByCode {
            ThemeManager.shared.themeColorHexString = list.themeColorHexString
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationConstants.selectListNotification), object: nil, userInfo: [NotificationConstants.selectedListKey:list])
            selectedList = list
        }else{
            let createVC = CreateOrUpdateListViewController(list: list)
            let nav = UINavigationController(rootViewController: createVC)
            self.present(nav, animated: true, completion: nil)
        }
        
        if tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = self.lists[indexPath.row]
            self.deleteList(list: list)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath.row != destinationIndexPath.row {
            
            swap(&lists[sourceIndexPath.row], &lists[destinationIndexPath.row])
            
            let newRow = destinationIndexPath.row
            let prevOrderNum: Int = newRow > 0 ? lists[newRow - 1].orderNum : 0
            let nextOrderNum: Int = newRow < (lists.count - 1) ? lists[newRow + 1].orderNum : (lists.count + 1) * k_ListTable_OrderBase
            let newOrder: Int = (prevOrderNum + nextOrderNum) / 2
            print("\(lists[newRow].name)-new order: ========== \(newOrder)")
            
            if newOrder - prevOrderNum < 2 || nextOrderNum - newOrder < 2 {
                DBManager.shared.recreateListOrders(lists: lists)
                self.refreshData()
            }else{
                lists[newRow].orderNum = newOrder
                DBManager.shared.changeListOrder(list: lists[sourceIndexPath.row], newOrderNum: newOrder)
            }
            
            print(lists.map{"\($0.name)=\($0.orderNum)"})
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.isEditing {
            return LeftMenuViewController.kFooterViewHeight
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if tableView.isEditing {
            let footerView = UIView(frame: tableView.rectForFooter(inSection: section))
            footerView.backgroundColor = UIColor(hexString: "#233142")
            let btnWidth: CGFloat = 40
            let btnHeight: CGFloat = 40
            let btn = UIButton(frame: CGRect(x: (k_SCREEN_WIDTH - btnWidth) / 2,
                                             y: (LeftMenuViewController.kFooterViewHeight - btnHeight) / 2,
                                             width: btnWidth,
                                             height: btnHeight))
            btn.setTitleColor(UIColor.lightGray, for: .normal)
//            btn.setTitle("新增清单", for: .normal)
//            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            btn.tintColor = UIColor.white
            let img = UIImage(named: "plus_sign")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            btn.setImage(img, for: .normal)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.layer.cornerRadius = 20
            btn.backgroundColor = UIColor(hexString: "#1FAB89")
            btn.addTarget(self, action: #selector(addBtnClicked), for: .touchUpInside)
            footerView.addSubview(btn)
            
            return footerView
        }else {
            return nil
        }
    }
}

