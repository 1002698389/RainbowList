//
//  RBPictureChooseView.swift
//  RainbowList
//
//  Created by admin on 2017/3/6.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import Photos

protocol RBPictureChooseViewDelegate: NSObjectProtocol {
    
    func cancelChoose(pictureView: RBPictureChooseView)
    func confirmChoose(pictureView: RBPictureChooseView, chosenImages: [RBImage])
    
}

private let kPhotoShowCellIdentifier = "kPhotoShowCellIdentifier"
private let kPictureAddCellIdentifier = "kPictureAddCellIdentifier"
private let kPictureCellWidth: CGFloat = 90
private let kToolbarHeight: CGFloat = 40

class RBPictureChooseView: UIView {

    
    weak var delegate: RBPictureChooseViewDelegate?
    
    var event: RBEvent
    var images = [RBImage]()
    
    var thumbnailSize: CGSize!
    
    lazy var toolbar: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(hex: 0xf1f1f1)
        
        let upLine = UIView()
        upLine.backgroundColor = UIColor.lightGray
        view.addSubview(upLine)
        
        let deleteBtn = UIButton()
        deleteBtn.setTitle("移除图片", for: .normal)
        deleteBtn.setTitleColor(UIColor.gray, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        deleteBtn.addTarget(self, action: #selector(deleteBtnClicked), for: .touchUpInside)
        view.addSubview(deleteBtn)
        
        
        let photoBtn = UIButton()
        photoBtn.setTitle("相册", for: .normal)
        photoBtn.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString).lighter(), for: .normal)
        photoBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        photoBtn.addTarget(self, action: #selector(photoBtnClicked), for: .touchUpInside)
        view.addSubview(photoBtn)
        
        let line = UIView()
        line.backgroundColor = UIColor.lightGray
        view.addSubview(line)
        
        let cameraBtn = UIButton()
        cameraBtn.setTitle("相机", for: .normal)
        cameraBtn.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString).lighter(), for: .normal)
        cameraBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cameraBtn.addTarget(self, action: #selector(cameraBtnClicked), for: .touchUpInside)
        view.addSubview(cameraBtn)
        
        view.addSubview(self.confirmButton)
        
        upLine.snp.makeConstraints({ (make) in
            make.left.right.top.equalTo(view)
            make.height.equalTo(0.5)
        })
        deleteBtn.snp.makeConstraints({ (make) in
            make.left.equalTo(view).offset(10)
            make.top.bottom.equalTo(view)
        })
        photoBtn.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view).offset(-30)
            make.width.equalTo(40)
            make.top.bottom.equalTo(view)
        })
        line.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(1)
            make.top.bottom.equalTo(view).inset(UIEdgeInsetsMake(10, 0, 10, 0))
        })
        cameraBtn.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view).offset(30)
            make.width.equalTo(40)
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
        confirmBtn.setTitle("添加图片", for: .normal)
        let titleColor = UIColor.clear
        confirmBtn.setTitleColor(titleColor, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        confirmBtn.isEnabled = false
        confirmBtn.addTarget(self, action: #selector(confirmBtnClicked), for: .touchUpInside)
        return confirmBtn
    }()
    
    lazy var pictureCollectionView: UICollectionView = {
        let inset = UIEdgeInsetsMake(10, 10, 10, 10)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        flowLayout.scrollDirection = .vertical
        let cellWidth = (UIScreen.main.bounds.size.width - inset.left - inset.right)/3-5
        flowLayout.itemSize = CGSize(width: cellWidth,height: cellWidth)
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = inset
        collectionView.register(PhotoShowCell.classForCoder(), forCellWithReuseIdentifier: kPhotoShowCellIdentifier)
        return collectionView
    }()
    
    lazy var emptyView: UILabel = {
        var label = UILabel()
        label.text = "点击 “相册|相机” 按钮添加图片"
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    // MARK: - Life Cycle
    
    init(event: RBEvent) {
        self.event = event
        super.init(frame: CGRect.zero)
        
        if let imgs = event.images {
            self.images.append(contentsOf: imgs)
        }
        setupSubview()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        self.reloadData()
    }
    
    // MARK: Inherit Method
    
    // MARK: Setup Method
    func setupSubview() {
        self.backgroundColor = UIColor.white
        addSubview(toolbar)
        addSubview(pictureCollectionView)
        addSubview(emptyView)
        
        toolbar.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(kToolbarHeight)
        }
        pictureCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(toolbar.snp.bottom)
//            make.centerY.equalTo(self).offset(RBPictureChooseView.kToolbarHeight/2)
//            make.height.equalTo(RBPictureChooseView.kPictureCollectionViewHeight)
            make.left.right.bottom.equalTo(self)
        }
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(pictureCollectionView)
        }

        
        let scale = UIScreen.main.scale
        let cellSize = (self.pictureCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    // MARK: - Public Method
    
    
    // MARK: - Interaction Event Handler
    
    func deleteBtnClicked() {
        self.delegate?.cancelChoose(pictureView: self)
    }
    
    func confirmBtnClicked() {
        self.delegate?.confirmChoose(pictureView: self, chosenImages: self.images)
    }
    func photoBtnClicked() {
        
        let photoVC = PhotoSelectViewController()
        let nav = UINavigationController(rootViewController: photoVC)
        photoVC.delegate = self
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.presentNewViewControllerNotification), object: nil, userInfo: [NotificationConstants.presentNewViewControllerKey:nav])
    }
    func cameraBtnClicked() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraVC = CameraViewController()
            cameraVC.cameraDelegate = self
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.presentNewViewControllerNotification), object: nil, userInfo: [NotificationConstants.presentNewViewControllerKey:cameraVC])
            
        } else {
            makeToast("相机不可用!")
        }
    }
    
    // MARK: - Private Method
    
    func reloadData() {
        
        if self.images.count == 0 {
            self.emptyView.isHidden = false
            self.confirmButton.setTitleColor(UIColor.clear, for: .normal)
            self.confirmButton.isEnabled = false
        }else{
            self.emptyView.isHidden = true
            self.confirmButton.setTitleColor(UIColor(hexString: ThemeManager.shared.themeColorHexString), for: .normal)
            self.confirmButton.isEnabled = true
        }
        self.pictureCollectionView.reloadData()
    }
    
    // MARK: Notification Handler
    
}

extension RBPictureChooseView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PhotoShowCell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoShowCellIdentifier, for: indexPath) as! PhotoShowCell
        cell.delegate = self
        cell.representedAssetIdentifier = self.images[indexPath.item].identifier
        cell.imageView.image = self.images[indexPath.item].thumbnail
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let img = self.images[indexPath.item]
        RBImageViewer().show(image: img)
    }
}

extension RBPictureChooseView: PhotoSelectDelegate {
    func completeSelect(photoSelectViewController: PhotoSelectViewController, assets: [PHAsset]) {
        
        for i in 0..<assets.count {
            let ass = assets[i]
            
            let img = RBImage(identifier: ass.localIdentifier.replacingOccurrences(of: "/", with: "_"), event: self.event)
            self.images.append(img)
            
            PHImageManager.default().requestImage(for: ass, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                
                img.thumbnail = image
                
                self.reloadData()
            })
            PHImageManager.default().requestImageData(for: ass, options: nil, resultHandler: { (data, string, _, _) in
                print("=====request done:\(String(describing: string))")
                
                img.originalData = data
            })
        }
        
        self.reloadData()
    }
}

extension RBPictureChooseView: CameraViewControllerDelegate {
    func cameraVCDidCanceled(cameraViewController: CameraViewController) {
        print("cancel")
    }
    func cameraVCDidSuccessed(cameraViewController: CameraViewController, image: UIImage) {
        print("success")
        
        let id = String(self.event.identifier) + String(Date.timeIntervalSinceReferenceDate)
        let img = RBImage(identifier: id, event: self.event)
        img.thumbnail = image.reSizeImageToMaxSize(size: k_SCREEN_WIDTH / 2)
        img.originalData = UIImageJPEGRepresentation(image, 0.8)
        self.images.append(img)

        self.reloadData()
    }
}

extension RBPictureChooseView: PhotoShowCellDelegate {
    
    func deleteImage(photoShowCell: PhotoShowCell, identifier: String) {
        self.images = images.filter({$0.identifier != identifier})
        
        self.reloadData()
    }
}
