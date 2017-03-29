//
//  RBPriorityChooseView.swift
//  RainbowList
//
//  Created by admin on 2017/3/12.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

protocol RBPriorityChooseViewDelegate: class{
    func cancelChoose(priorityView: RBPriorityChooseView)
    func confirmChoose(priorityView: RBPriorityChooseView, priority: Int)
}

class RBPriorityChooseView: UIView {

    static let kToolbarHeight: CGFloat = 40
    static let kCellIdentifier = "kCellIdentifier"
    static let rowHeigth: CGFloat = 80
    
    weak var delegate: RBPriorityChooseViewDelegate?
    let priorities: [Int] = [1, 2, 3]
    var selectedPriority: Int
    
    lazy var toolbar: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(hex: 0xf1f1f1)
        
        let upLine = UIView()
        upLine.backgroundColor = UIColor.lightGray
        view.addSubview(upLine)
        
        let deleteBtn = UIButton()
        deleteBtn.setTitle("移除优先级", for: .normal)
        deleteBtn.setTitleColor(UIColor.gray, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        deleteBtn.addTarget(self, action: #selector(deleteBtnClicked), for: .touchUpInside)
        view.addSubview(deleteBtn)
        
        view.addSubview(self.confirmButton)
        
        upLine.snp.makeConstraints({ (make) in
            make.left.right.top.equalTo(view)
            make.height.equalTo(0.5)
        })
        deleteBtn.snp.makeConstraints({ (make) in
            make.left.equalTo(view).offset(10)
            make.top.bottom.equalTo(view)
        })
        self.confirmButton.snp.makeConstraints({ (make) in
            make.right.equalTo(view).offset(-10)
            make.top.bottom.equalTo(view)
        })
        
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        var confirmBtn = UIButton()
        confirmBtn.setTitle("添加优先级", for: .normal)
        if self.selectedPriority == 0 {
            confirmBtn.setTitleColor(UIColor.clear, for: .normal)
            confirmBtn.isEnabled = false
        }else{
            confirmBtn.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .normal)
            confirmBtn.isEnabled = true
        }
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        confirmBtn.addTarget(self, action: #selector(confirmBtnClicked), for: .touchUpInside)
        return confirmBtn
    }()
    
    lazy var priorityListView: UITableView = {
        var tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = RBPriorityChooseView.rowHeigth
        tableView.register(PriorityCell.classForCoder(), forCellReuseIdentifier: RBPriorityChooseView.kCellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.bounces = false
        return tableView
    }()
    
    // MARK: - Life Cycle
    
    init(priority: Int) {
        selectedPriority = priority
        super.init(frame: CGRect.zero)
        
        setupSubview()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Inherit Method
    override func didMoveToSuperview() {
        let indexPath = IndexPath(row: self.priorities.index(of: self.selectedPriority) ?? -1, section: 0)
        self.priorityListView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    // MARK: Setup Method
    func setupSubview() {
        self.backgroundColor = UIColor.white
        addSubview(toolbar)
        addSubview(priorityListView)
        
        toolbar.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(RBPictureChooseView.kToolbarHeight)
        }
        
        priorityListView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 260, height: RBPriorityChooseView.rowHeigth * CGFloat(self.priorities.count)))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(RBPriorityChooseView.kToolbarHeight/2)
        }
    }
    // MARK: - Public Method
    
    
    // MARK: - Interaction Event Handler
    
    func deleteBtnClicked() {
        self.delegate?.cancelChoose(priorityView: self)
    }
    
    func confirmBtnClicked() {
        self.delegate?.confirmChoose(priorityView: self, priority: self.selectedPriority)
    }
}

extension RBPriorityChooseView: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RBPriorityChooseView.kCellIdentifier) as! PriorityCell
        cell.priority = priorities[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.confirmButton.isEnabled = true
        self.confirmButton.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .normal)
        self.selectedPriority = priorities[indexPath.row]
    }
    
}
