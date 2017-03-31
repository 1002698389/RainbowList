//
//  OpenSourceListViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/31.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import WebKit

class OpenSourceListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            if let urlStr = cell.textLabel?.text {
                if let url = URL(string: urlStr) {
                    let webVC = RBWebViewController(url: url)
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
            }
        }
    }
}

