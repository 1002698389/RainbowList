//
//  PhotoSelectViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/9.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import Photos

protocol PhotoSelectDelegate: NSObjectProtocol {
    func completeSelect(photoSelectViewController: PhotoSelectViewController, assets: [PHAsset])
}

private let kPhotoCellIdentifier = "kPhotoCellIdentifier"
private let kPhotoCellMinMargin: CGFloat = 1
private let kPhotoColumn: CGFloat = 4

class PhotoSelectViewController: UIViewController {

    weak var delegate: PhotoSelectDelegate?
    var allPhotos: PHFetchResult<PHAsset>?
    var thumbnailSize: CGSize!
    var previousPreheatRect = CGRect.zero
    
    lazy var authView: UIView = {
        var view = UIView()
        view.isHidden = true
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        label.text = "未能获得访问相册的权限"
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
    
    lazy var closeItem: UIBarButtonItem = {
        let closeItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(closeBtnClicked))
        closeItem.tintColor = UIColor.white
        let spaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        return closeItem
    }()
    
    lazy var doneItem: UIBarButtonItem = {
        var doneItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneBtnClicked))
        doneItem.tintColor = UIColor.lightGray
        doneItem.isEnabled = false
        return doneItem
    }()
    
    lazy var photoCollectionView: UICollectionView = {
        
//        let inset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = kPhotoCellMinMargin
        flowLayout.minimumInteritemSpacing = kPhotoCellMinMargin
        let cellWidth = floor((self.view.bounds.size.width - (kPhotoColumn - 1) * kPhotoCellMinMargin) / kPhotoColumn)
        flowLayout.itemSize = CGSize(width: cellWidth,height: cellWidth)
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.contentInset = inset
        collectionView.allowsMultipleSelection = true
        collectionView.register(PhotoSelectCell.classForCoder(), forCellWithReuseIdentifier: kPhotoCellIdentifier)
        return collectionView
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: ThemeManager.shared.themeColorHexString)
        self.navigationItem.leftBarButtonItem = closeItem
        self.navigationItem.rightBarButtonItem = doneItem
        
        view.addSubview(photoCollectionView)
        view.addSubview(authView)
        
        photoCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        authView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.size.equalTo(CGSize(width: k_SCREEN_WIDTH, height: 200))
        }
        
        self.refreshAuthorization{
            self.reloadPhotos()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    deinit {
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Method
    
    func closeBtnClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneBtnClicked() {
        
        var assets:[PHAsset] = []
        if let indexPaths = self.photoCollectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths{
                assets.append(allPhotos![indexPath.item] )
            }
        }
        self.delegate?.completeSelect(photoSelectViewController: self, assets: assets)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //跳到系统设置页面
    func jumpToSettingPage() {
        SystemUtil.jumpToSettingPage()
    }
    
    func reloadPhotos() {
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                     PHAssetMediaType.image.rawValue)
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (self.photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)

        photoCollectionView.reloadData()
    }
    func refreshAuthorization(completedHandller: @escaping ()->()) {
        
        //申请权限
        PHPhotoLibrary.requestAuthorization { (state) in
            if state == .denied  {
                DispatchQueue.main.async(execute: {
                    self.authView.isHidden = false
                    self.photoCollectionView.isHidden = true
                })
            }else if state == .authorized{
                DispatchQueue.main.async(execute: {
                    self.authView.isHidden = true
                    self.photoCollectionView.isHidden = false
                    completedHandller()
                })
            }
        }
    }

    func refreshDoneButtonState(){
        
        UIView.setAnimationsEnabled(false)
        if let indexPaths = self.photoCollectionView.indexPathsForSelectedItems {
            
            if indexPaths.count > 0 {
                self.doneItem.isEnabled = true
                self.doneItem.tintColor = UIColor.white
                self.doneItem.title = "完成(\(indexPaths.count))"
            }else {
                self.doneItem.isEnabled = false
                self.doneItem.tintColor = UIColor.lightGray
                self.doneItem.title = "完成"
            }
        }else {
            self.doneItem.isEnabled = false
            self.doneItem.tintColor = UIColor.lightGray
            self.doneItem.title = "完成"
        }
        UIView.setAnimationsEnabled(true)
    }
}

extension PhotoSelectViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: PhotoSelectCell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoCellIdentifier, for: indexPath) as? PhotoSelectCell
            else { fatalError("unexpected cell in collection view") }
        
        if let photos = allPhotos {
            let asset = photos.object(at: indexPath.item)
            cell.representedAssetIdentifier = asset.localIdentifier
            PHImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.thumbnailImage = image
                }
            })
        }
        
        
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        refreshDoneButtonState()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        refreshDoneButtonState()
    }
}


