//
//  CameraViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/12.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import Photos

protocol  CameraViewControllerDelegate: class{
    
    func cameraVCDidCanceled(cameraViewController: CameraViewController)
    func cameraVCDidSuccessed(cameraViewController: CameraViewController, image: UIImage)
}

class CameraViewController: UIImagePickerController{

    weak var cameraDelegate: CameraViewControllerDelegate?
    
    lazy var authView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.black
        view.isHidden = true
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        label.text = "未能获得访问相机的权限"
        view.addSubview(label)
        
        let btn = UIButton()
        btn.setTitle("去设置", for: .normal)
        btn.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .normal)
        btn.addTarget(self, action: #selector(jumpToSettingPage), for: .touchUpInside)
        view.addSubview(btn)
        
        label.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-20)
        })
        btn.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(20)
        })
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.sourceType = UIImagePickerControllerSourceType.camera
        self.allowsEditing = false
        
        self.view.addSubview(authView)
        
        authView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.refreshAuthorization()
    }
    
    //跳到系统设置页面
    func jumpToSettingPage() {
        SystemUtil.jumpToSettingPage()
    }
    func refreshAuthorization() {
        //申请权限
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (allow) in
            
            if allow {
                DispatchQueue.main.async(execute: {
                    self.authView.isHidden = true
                })
            }else{
                DispatchQueue.main.async(execute: {
                    self.authView.isHidden = false
                })
            }
        }
//        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
//        
//        if status != .authorized {
//            self.authView.isHidden = false
//        }else{
//            self.authView.isHidden = true
//        }
    }
}
extension CameraViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.cameraDelegate?.cameraVCDidSuccessed(cameraViewController: self, image: img)
        picker.dismiss(animated: true, completion: nil)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
