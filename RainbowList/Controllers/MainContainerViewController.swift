//
//  MainContainerViewController.swift
//  RainbowList
//
//  Created by admin on 2017/2/24.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit


class MainContainerViewController: UIViewController {
    
    static let kMainShadowViewMaxAlpha:CGFloat = 0.1
    
    var leftMenuViewController: UIViewController!
    var leftMenuView: UIView!
    var mainNavController: UINavigationController!
    var mainView: UIView!
    var shouldHideStatusBar = false
    
    var lefMenuMaxWidth: CGFloat = 140
    
    var panGestureStartLocation: CGPoint?
    var isLeftMenuOpen: Bool = false
    var isLeftMenuOpenEntirely: Bool = false
    
    //左边菜单展开后，右边内容视图上的遮罩层
    lazy var mainMaskView: UIView = {
        var view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeLeftMenu)))
        return view
    }()
    
    // MARK: - override Method
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshLeftMenuMaxWidth()
        
        
        //添加侧滑手势
        view.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(gesture:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        //添加主内容视图
        mainNavController = UINavigationController(rootViewController: EventListViewController())
        addChildViewController(mainNavController)
        mainView = mainNavController.view
        mainView.frame = view.bounds
        view.addSubview(mainView)
        mainNavController.didMove(toParentViewController: self)

        //添加左侧滑菜单
        leftMenuViewController = LeftMenuViewController()
        addChildViewController(leftMenuViewController)
        leftMenuView = leftMenuViewController.view
        leftMenuView.frame = CGRect(x: 0, y: 0, width: self.lefMenuMaxWidth, height: k_SCREEN_HEIGHT)
        view.insertSubview(leftMenuView, at: 0)
        leftMenuViewController.didMove(toParentViewController: self)
        
        //添加遮罩层
        mainView.addSubview(mainMaskView)
        
        
        //监听通知
        NotificationCenter.default.addObserver(self, selector: #selector(openLeftMenu), name: NSNotification.Name(rawValue: NotificationConstants.openLeftMenuNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeLeftMenu), name: NSNotification.Name(rawValue: NotificationConstants.closeLeftMenuNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openLeftMenuEntirely), name: NSNotification.Name(rawValue: NotificationConstants.openLeftMenuEntirelyNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jumpToSettingPage), name: NSNotification.Name(rawValue: NotificationConstants.jumpToSettingPageNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLeftMenuMaxWidth), name: Notification.Name(NotificationConstants.refreshLeftMenuMaxWidthNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - custom method
    
    func openLeftMenu() {
        shouldHideStatusBar = true
        UIView.animate(withDuration: 0.25, animations: {
            self.mainView.frame = CGRect(x: self.lefMenuMaxWidth, y: 0, width: k_SCREEN_WIDTH, height: k_SCREEN_HEIGHT)
            self.leftMenuView.frame = CGRect(x: 0, y: 0, width: self.lefMenuMaxWidth, height: k_SCREEN_HEIGHT)
            self.mainMaskView.alpha = MainContainerViewController.kMainShadowViewMaxAlpha
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (_) in
            self.isLeftMenuOpen = true
            self.isLeftMenuOpenEntirely = false
        }
    }

    func closeLeftMenu() {
        shouldHideStatusBar = false
        UIView.animate(withDuration: 0.25, animations: {
            self.mainView.frame = CGRect(x: 0, y: 0, width: k_SCREEN_WIDTH, height: k_SCREEN_HEIGHT)
            self.leftMenuView.frame = CGRect(x: -self.lefMenuMaxWidth, y: 0, width: self.lefMenuMaxWidth, height: k_SCREEN_HEIGHT)
            self.mainMaskView.alpha = 0
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (_) in
            self.isLeftMenuOpen = false
            self.isLeftMenuOpenEntirely = false
        }
       
    }

    func openLeftMenuEntirely() {
        shouldHideStatusBar = true
        UIView.animate(withDuration: 0.25, animations: {
            self.mainView.frame = CGRect(x: k_SCREEN_WIDTH, y: 0, width: k_SCREEN_WIDTH, height: k_SCREEN_HEIGHT)
            self.leftMenuView.frame = CGRect(x: 0, y: 0, width: k_SCREEN_WIDTH, height: k_SCREEN_HEIGHT)
            self.mainMaskView.alpha = MainContainerViewController.kMainShadowViewMaxAlpha
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (_) in
            self.isLeftMenuOpen = true
            self.isLeftMenuOpenEntirely = true
        }
    }
    
    func expandLeftMenu(offset: CGFloat) {
        
        if offset > 0 {
            if self.isLeftMenuOpen {
                return
            }
            
            leftMenuView.frame = CGRect(x: -self.lefMenuMaxWidth + min(offset, self.lefMenuMaxWidth), y: 0, width: self.lefMenuMaxWidth, height: k_SCREEN_HEIGHT)
            mainView.frame = CGRect(x: min(offset, self.lefMenuMaxWidth), y: 0, width: k_SCREEN_WIDTH, height: k_SCREEN_HEIGHT)
            
            
            mainMaskView.alpha = min(MainContainerViewController.kMainShadowViewMaxAlpha * offset / self.lefMenuMaxWidth, MainContainerViewController.kMainShadowViewMaxAlpha)
            
            
        }else if offset < 0 {
            
            if !self.isLeftMenuOpen {
                return
            }
            
            leftMenuView.frame = CGRect(x: max(offset, -self.lefMenuMaxWidth), y: 0, width: self.lefMenuMaxWidth, height: k_SCREEN_HEIGHT)
            mainView.frame = CGRect(x: max(self.lefMenuMaxWidth+offset, 0), y: 0, width: k_SCREEN_WIDTH, height: k_SCREEN_HEIGHT)
            
            mainMaskView.alpha = max(MainContainerViewController.kMainShadowViewMaxAlpha * (self.lefMenuMaxWidth+offset) / self.lefMenuMaxWidth, 0)
        }
        
//        print("----\(mainShadowView.alpha)")
    }
    
    func endPangesture(offset: CGFloat) {
        
        if offset > 0 {
            if leftMenuView.frame.origin.x > -(self.lefMenuMaxWidth / 3.0 * 2) {
                openLeftMenu()
            }else {
                closeLeftMenu()
            }
        }else{
            
            if leftMenuView.frame.origin.x < -(lefMenuMaxWidth / 3.0){
                closeLeftMenu()
            }else {
                openLeftMenu()
            }
        }
    }
    
    //侧滑手势
    func panDetected(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.view)
//        print("translation:\(translation)")
        
        if mainNavController.viewControllers.count == 1 {
            //侧滑菜单
            switch gesture.state {
            case .began:
                break
                //            print("pan began")
                
            case .changed:
                //            print("changed")
                expandLeftMenu(offset: translation.x)
                
            case .ended:
                //            print("end")
                endPangesture(offset: translation.x)
                
            case .cancelled:
                //            print("cancelled")
                
                endPangesture(offset: translation.x)
                
            default:
                print("pan other state")
            }
        } else {
            
        }
        
    }
    
    
    func jumpToSettingPage() {
        
        closeLeftMenu()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.35) {
//            self.mainNavController.pushViewController(SettingViewController(), animated: true)
            let settingVC = UIStoryboard(name: "Setting", bundle: Bundle.main).instantiateInitialViewController()!
            self.mainNavController.pushViewController(settingVC, animated: true)
        }
    }

    func refreshLeftMenuMaxWidth() {
        lefMenuMaxWidth = CGFloat(UserDefaults.standard.float(forKey: k_Defaultkey_LeftMenuMaxWidth))
    }

}

extension MainContainerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isLeftMenuOpenEntirely
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let view = otherGestureRecognizer.view {
            if view is UITableView {
                return false
            }
        }
        return true
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        
//        if let view = otherGestureRecognizer.view {
//            if view === self.leftMenuView {
//                return true
//            }
//        }
//        return false
//    }
}
