//
//  CreateListViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit

private let kBackgroundColor = UIColor(hex: 0x233142)
private let kTextfieldHeight: CGFloat = 50
private let kCellIdentifier = "kCellIdentifier"
private let kCollecionViewInset = UIEdgeInsetsMake(10, 20, 10, 20)
private let kCollectionViewColumnCount: CGFloat = 5
private let kMinimumItemSpacing: CGFloat = 15

class CreateOrUpdateListViewController: UIViewController {


    var oldList: RBList?
    
    lazy var themeColorHexStrings: [String] = {
//        var colors = [String]()
//        for i in 0..<ThemeManager.shared.allPredefinedColorHexStrings.count {
//            let hexStr = ThemeManager.shared.allPredefinedColorHexStrings.reversed()[i]
//            if ThemeManager.shared.usedColorHexStrings.contains(hexStr){
//                colors.append(hexStr)
//            }else{
//                colors.insert(hexStr, at: 0)
//            }
//        }
//        return colors
        return ThemeManager.shared.allPredefinedColorHexStrings
    }()
    var selectedThemeColorHexString: String = ThemeManager.shared.allPredefinedColorHexStrings.first! {
        didSet {
            let color = UIColor(hexString: selectedThemeColorHexString)
            self.markView.backgroundColor = color
            textField.textColor = color
            textField.tintColor = color
        }
    }
    
    lazy var textField: UITextField = {
        var field = UITextField()
        field.font = UIFont.systemFont(ofSize: 18)
        field.attributedPlaceholder = NSAttributedString(string: "填写清单名称", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        field.layer.cornerRadius = 5
        field.backgroundColor = UIColor(hex: 0x2C3E50)
        field.layer.masksToBounds = true
        field.tintColor = UIColor(hexString:self.themeColorHexStrings.first)
        field.textColor = UIColor(hexString:self.themeColorHexStrings.first)
        field.delegate = self
        field.enablesReturnKeyAutomatically = true
        field.returnKeyType = .done
        field.leftView = self.leftView
        field.leftViewMode = .always
        return field
    }()
    
    lazy var markView: UIView = {
        var mark = UIView()
        mark.backgroundColor = UIColor(hexString:self.themeColorHexStrings.first)
        return mark
    }()
    
    lazy var leftView: UIView = {
        let width: CGFloat = 40
        let height: CGFloat = 40
        var view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
       
        let markWidth: CGFloat = 25
        self.markView.frame = CGRect(x: (width - markWidth) / 2, y: (height - markWidth) / 2, width: markWidth, height: markWidth)
        self.markView.layer.cornerRadius = markWidth / 2
        self.markView.layer.masksToBounds = true
        view.addSubview(self.markView)
        
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        var collection: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.clear
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.contentInset = kCollecionViewInset
        collection.register(MarkCell.classForCoder(), forCellWithReuseIdentifier: kCellIdentifier)
        collection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCollectionView(sender:))))
        return collection
    }()
    
    lazy var flowLayout: UICollectionViewFlowLayout  = {
        var layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = kMinimumItemSpacing
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        let cellWidth = (UIScreen.main.bounds.size.width - kCollecionViewInset.left - kCollecionViewInset.right) / kCollectionViewColumnCount - kMinimumItemSpacing
        layout.itemSize = CGSize(width: cellWidth,height: cellWidth)
        return layout
    }()
    // MARK: - Life Cycle
    
    init(list: RBList? = nil) {
        self.oldList = list
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kBackgroundColor
        
        customNavgation()
        setupSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
        
        //list不为空，说明是修改
        if let list = self.oldList {
            let index = themeColorHexStrings.index(of: list.themeColorHexString) ?? 0
            collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .top)
            selectedThemeColorHexString = list.themeColorHexString
            textField.text = list.name
        }else{
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    // MARK: Inherit Method
    override var prefersStatusBarHidden: Bool {
        return true
    }
    // MARK: Setup Method
    func setupSubviews() {
        view.addSubview(textField)
        view.addSubview(collectionView)
        
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(kTextfieldHeight)
            make.top.equalToSuperview().offset(20)
        }
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(textField.snp.bottom)
        }
    }
    func customNavgation() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = kBackgroundColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        let img = UIImage(named: "close")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(closePage))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
    }
    func addList() {
        let list = RBList(name: textField.text ?? "", themeColorHexString: selectedThemeColorHexString)
        DBManager.shared.createList(list: list)
        NotificationCenter.default.post(name: Notification.Name.init(NotificationConstants.refreshListDataWithCreationNotification), object: nil)
    }
    
    func updateList(list: RBList) {
        list.themeColorHexString = selectedThemeColorHexString
        list.name = textField.text ?? ""
        DBManager.shared.updateList(list: list)
        NotificationCenter.default.post(name: Notification.Name.init(NotificationConstants.refreshListDataWithUpdateNotification), object: nil)
    }
    // MARK: - Public Method
    
    // MARK: - Interaction Event Handler
    func closePage() {
        self.dismiss(animated: true, completion: nil)
    }
    func tapCollectionView(sender: UIGestureRecognizer) {
        if let _ = collectionView.indexPathForItem(at: sender.location(in: self.collectionView)) {
            sender.cancelsTouchesInView = false
        }else {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: - Private Method
    
    // MARK: Notification Handler
}

extension CreateOrUpdateListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let list = self.oldList {
            updateList(list: list)
        }else{
            addList()
        }
        dismiss(animated: true, completion: nil)
        return true
    }
}


extension CreateOrUpdateListViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themeColorHexStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! MarkCell
        let colorHex = themeColorHexStrings[indexPath.row]
        cell.themeColor = UIColor(hexString: colorHex)
        cell.hasUsed = ThemeManager.shared.usedColorHexStrings.contains(colorHex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hexString = themeColorHexStrings[indexPath.item]
        selectedThemeColorHexString = hexString
    }
}
