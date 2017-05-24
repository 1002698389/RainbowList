//
//  PriorityChoosePopView.swift
//  RainbowList
//
//  Created by admin on 2017/3/20.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit

typealias PriorityChooseCompletedBlock = (Int) -> Void

private let kCellIdentifierForContent = "kCellIdentifierForContent"
private let kContentViewMaxHeight = k_SCREEN_HEIGHT / 2
private let kCellRowHeight: CGFloat = 50

class PriorityChoosePopView: UIView {

    
    var contentViewBottomConstraint: Constraint?
    
    var priorityChooseCompletedBlock: PriorityChooseCompletedBlock?
    
    var currentPriority: Int
    var priorities = [0, 1, 2, 3]
    var priorityNames = [PriroityOption.normalImportantString, PriroityOption.quiteImportantString, PriroityOption.veryImportantString, PriroityOption.extremelyImportantString]
    
    lazy var contentHeight: CGFloat = {
        return  min(kContentViewMaxHeight, kCellRowHeight * CGFloat(self.priorities.count))
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

//    lazy var priorityChooseView: RBPriorityChooseView = {
//        var priorityView = RBPriorityChooseView(priority: self.currentPriority)
//        priorityView.delegate = self
//        priorityView.backgroundColor = UIColor.white
//        return priorityView
//    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = kCellRowHeight
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: kCellIdentifierForContent)
        tableView.bounces = CGFloat(self.priorities.count) * kCellRowHeight > kContentViewMaxHeight
        return tableView
    }()
    // MARK: - Life Cycle
    init(priority: Int) {
        self.currentPriority = priority
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
        print("-------priority choose pop view deinit")
    }
    
    //MARK: - Public Method
    
    //显示自己
    func show(inView view: UIView?, chooseCompleted: @escaping PriorityChooseCompletedBlock) {
        
        self.priorityChooseCompletedBlock = chooseCompleted
        
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

//extension PriorityChoosePopView: RBPriorityChooseViewDelegate {
//    func cancelChoose(priorityView: RBPriorityChooseView) {
//        self.dismiss(){
//            if let block = self.priorityChooseCompletedBlock {
//                block(0)
//            }
//            self.priorityChooseCompletedBlock = nil
//        }
//    }
//    func confirmChoose(priorityView: RBPriorityChooseView, priority: Int) {
//        self.dismiss(){
//            if let block = self.priorityChooseCompletedBlock {
//                block(priority)
//            }
//            self.priorityChooseCompletedBlock = nil
//        }
//    }
//}

extension PriorityChoosePopView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierForContent)!
        
        let priority = self.priorities[indexPath.row]
        let name = self.priorityNames[indexPath.row]

        cell.textLabel?.text = name
        cell.tintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        
        if self.currentPriority == priority {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.currentPriority = self.priorities[indexPath.row]
        
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.35) {
            self.dismiss(){
                if let block = self.priorityChooseCompletedBlock {
                    block(self.currentPriority)
                }
                self.priorityChooseCompletedBlock = nil
            }
        }
    }
}

