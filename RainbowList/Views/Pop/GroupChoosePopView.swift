//
//  ListChoosePopView.swift
//  RainbowList
//
//  Created by admin on 2017/3/19.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit

typealias ListChooseCompletedBlock = (RBList) -> Void

class ListChoosePopView: UIView {
    
    static let kCellIdentifierForContent = "kCellIdentifierForContent"
    static let kContentViewMaxHeight = k_SCREEN_HEIGHT / 3 * 2
    static let kCellRowHeight: CGFloat = 50
    
    var contentViewBottomConstraint: Constraint?
    
    var listChooseCompletedBlock: ListChooseCompletedBlock?
    
    var currentList: RBList

    lazy var list: [RBList] = {
        return DBManager.shared.findAlllist()
    }()
    
    lazy var contentHeight: CGFloat = {
        return  min(ListChoosePopView.kContentViewMaxHeight, ListChoosePopView.kCellRowHeight * CGFloat(self.list.count))
    }()
    
    //背景
    lazy var backgroundView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.alpha = 0
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBackgroundView)))
        return view
    }()
    
    //主视图
    lazy var contentView: UIView = {
        var view = UIView()
        
        view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = kCellRowHeight
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: ListChoosePopView.kCellIdentifierForContent)
        tableView.bounces = CGFloat(self.list.count) * ListChoosePopView.kCellRowHeight > ListChoosePopView.kContentViewMaxHeight
        return tableView
    }()
    // MARK: - Life Cycle
    init(currentList: RBList) {
        self.currentList = currentList
        super.init(frame: UIScreen.main.bounds)
        addSubview(backgroundView)
        addSubview(contentView)
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(contentHeight)
            self.contentViewBottomConstraint = make.bottom.equalTo(self.snp.bottom).offset(self.contentHeight).constraint
        }
        self.layoutIfNeeded()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("-------list choose pop view deinit")
    }
    
    
    //MARK: - Public Method
    
    //显示自己
    func show(inView view: UIView?, chooseCompleted: @escaping ListChooseCompletedBlock) {
        
        self.listChooseCompletedBlock = chooseCompleted
        
        if self.superview == nil {
            if let v = view {
                v.addSubview(self)
            }else {
                let window = UIApplication.shared.keyWindow
                window?.addSubview(self)
            }
            UIView.animate(withDuration: 0.25) {
                self.backgroundView.alpha = 1
                self.contentViewBottomConstraint?.update(offset: 0)
                self.layoutIfNeeded()
            }
        }
    }
    
    func dismiss(completed: (() -> Void)? = nil) {
        if self.superview != nil {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundView.alpha = 0
                self.contentViewBottomConstraint?.update(offset: self.contentHeight)
                self.layoutIfNeeded()
            }, completion: { (_) in
                
                if let block = completed {
                    block()
                }
                self.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Interaction Event Handler
    func tapBackgroundView() {
        self.dismiss()
    }
}


extension ListChoosePopView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListChoosePopView.kCellIdentifierForContent)!
        
        let list = self.list[indexPath.row]
        cell.textLabel?.text = list.name
        cell.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        if currentList.identifier == list.identifier {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let list = self.list[indexPath.row]
        
        self.currentList = list
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.35) {
            self.dismiss(){
                if let block = self.listChooseCompletedBlock {
                    block(list)
                }
                self.listChooseCompletedBlock = nil
            }
        }
    }
}
