//
//  RBImage.swift
//  RainbowList
//
//  Created by admin on 2017/3/13.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

class RBImage: NSObject {
        
    // MARK: - Public Method
    
    //沙盒相对路径，不含文件名
    static func getRelativeThumbnailUrlForEvent(event: RBEvent) -> URL{
        return (documentUrl?.appendingPathComponent("images/\(event.identifier)/thumbnail/"))!
    }
    static func  getRelativeOriginalUrlForEvent(event: RBEvent) -> URL {
        return (documentUrl?.appendingPathComponent("images/\(event.identifier)/original/"))!
    }
    
    var identifier: String  //生成规则：对应Event的identifier+image+序号(0,1,2,3...)
    
    unowned let event: RBEvent
    
    private var _originalData: Data?
    
    var originalData: Data? {
        get {
            if _originalData == nil {
                
                if let img = _original {
                    
                    _originalData = UIImageJPEGRepresentation(img, 0.8)
                    
                }else {
                    _originalData = try? Data(contentsOf: self.fullFileNameForOriginal)
                    
                }
            }
            return _originalData
        }
        set {
            _originalData = newValue
        }
    }
    
    //缩略图
    private var _thumbnailData: Data?
    
    var thumbnailData: Data? {
        get {
            if _thumbnailData == nil {
                
                if let img = _thumbnail {
                    
                    _thumbnailData = UIImageJPEGRepresentation(img, 0.8)
                    
                }else {
                    
                    _thumbnailData = try? Data(contentsOf: self.fullFileNameForThumbnail)
                }
            }
            return _thumbnailData
        }
        set {
            _thumbnailData = newValue
        }
    }
    
    //原图
    private var _original: UIImage?
    
    var original: UIImage? {
        
        get {
            if _original == nil {
                if let d = originalData {
                    _original = UIImage.init(data: d)
                }
            }
            return _original
        }
        
        set {
            _original = newValue
        }
    }
    
    //缩略图
    private var _thumbnail: UIImage?
    
    var thumbnail: UIImage? {
        
        get {
            if _thumbnail == nil {
                if let d = thumbnailData {
                    _thumbnail = UIImage.init(data: d)
                }
            }
            return _thumbnail
        }
        
        set {
            _thumbnail = newValue
        }
    }

    //完整文件路径，含文件名
    var fullFileNameForThumbnail: URL {
        return RBImage.getRelativeThumbnailUrlForEvent(event: self.event).appendingPathComponent("\(identifier).jpg")
    }
    var fullFileNameForOriginal: URL {
        return RBImage.getRelativeOriginalUrlForEvent(event: self.event).appendingPathComponent("\(identifier).jpg")

    }
    
    init (identifier: String, event:RBEvent){
        
        self.identifier = identifier
        self.event = event
        
        super.init()
    }
    
    override var description: String {
        return "\(super.description)\n{\n identifier:\(identifier)\n fullFileNameForOriginal:\(fullFileNameForOriginal)\n  fullFileNameForThumbnail:\(fullFileNameForThumbnail)\n \n}"
    }
    
    
  
}
