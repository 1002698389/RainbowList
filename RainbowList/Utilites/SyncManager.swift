//
//  SyncManager.swift
//  RainbowList
//
//  Created by admin on 2017/4/10.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class SyncManager: NSObject {
    
    static let shared = SyncManager()
    private override init() {
    }

    func iCloudDocumentURL() -> URL? {
        let fileManager = FileManager.default
        if let url = fileManager.url(forUbiquityContainerIdentifier: nil) {
            return url.appendingPathComponent("Documents")
        }
        return nil
    }
    
}
