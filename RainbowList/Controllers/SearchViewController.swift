//
//  SearchViewController.swift
//  RainbowList
//
//  Created by admin on 2017/5/25.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {

    var themeColor: UIColor?
    var searchBarTopConstraint: Constraint?
    
    lazy var searchBar: UISearchBar = {
        var bar = UISearchBar()
        
        return bar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        view.isUserInteractionEnabled = true
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = themeColor
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(dismissView))
        
        setupSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25) {
            self.searchBarTopConstraint?.update(offset: 40)
            self.view.layoutIfNeeded()
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    func setupSubviews() {
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(40)
            searchBarTopConstraint = make.top.equalTo(view).offset(-40).constraint
        }
        view.setNeedsLayout()
    }
    
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
