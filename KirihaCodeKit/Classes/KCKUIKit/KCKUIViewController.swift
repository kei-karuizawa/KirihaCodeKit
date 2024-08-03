//
//  KCKUIViewController.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/6.
//

import UIKit

// MARK: - KCKUIViewController.

public extension UIViewController {
    
    static func kiriha_currentActivityViewController() -> UIViewController? {
        let rootViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        guard let rootVC = rootViewController else {
            return nil
        }
        return UIViewController.kiriha_findCurrentActivityViewController(from: rootVC)
    }
    
    private static func kiriha_findCurrentActivityViewController(from viewController: UIViewController) -> UIViewController? {
        var currentActivityViewController: UIViewController?
        
        // 先判断根视图控制器是否有其他视图控制器弹出，如果有，那么当前的视图控制器肯定在它之上。
        if viewController.presentedViewController != nil {
            let nextRootVC: UIViewController? = viewController.presentedViewController
            if nextRootVC != nil {
                currentActivityViewController = self.kiriha_findCurrentActivityViewController(from: nextRootVC!)
            } else {
                return nil
            }
            
        } else if viewController.isKind(of: UITabBarController.self) {
            let nextRootVC: UIViewController? = (viewController as! UITabBarController).selectedViewController
            if nextRootVC != nil {
                currentActivityViewController = self.kiriha_findCurrentActivityViewController(from: nextRootVC!)
            } else {
                return nil
            }
        } else if viewController.isKind(of: UINavigationController.self) {
            let nextRootVC: UIViewController? = (viewController as! UINavigationController).visibleViewController
            if nextRootVC != nil {
                currentActivityViewController = self.kiriha_findCurrentActivityViewController(from: nextRootVC!)
            } else {
                return nil
            }
        } else {
            // 根视图为非导航类。
            currentActivityViewController = viewController
        }
        
        return currentActivityViewController
    }
}

open class KCKUIViewController: UIViewController {
    
    // MARK: - UIViewController.

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addNotification()
        self.createUI()
        self.handleBusiness()
        self.sendRequestWhenViewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sendRequestWhenViewWillAppear()
    }
    
    open func addNotification() {}
    open func createUI() {}
    open func handleBusiness() {}
    open func sendRequestWhenViewDidLoad() {}
    open func sendRequestWhenViewWillAppear() {}
    
    // MARK: - deinit.
        
    deinit {
        print("\(NSStringFromClass(self.classForCoder)) 已释放。")
        NotificationCenter.default.removeObserver(self)
    }

}
