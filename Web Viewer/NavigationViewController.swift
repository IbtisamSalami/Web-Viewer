//
//  NavigationViewController.swift
//  Web Viewer
//
//  Created by Ibtisam on 15/10/2022.
//

import UIKit

class NavigationViewController: UINavigationController{
    
    override var preferredStatusBarStyle: UIStatusBarStyle
        {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.backButtonTitle = " "
        } else {
            // Fallback on earlier versions
        }
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.white]
        UINavigationBar.appearance().tintColor = .blue
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().backgroundColor = .white
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)
        UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
        
        UINavigationBar.appearance().backIndicatorImage = #imageLiteral(resourceName: "back_en")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back_en")
        UINavigationBar.appearance().backItem?.title = ""
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        self.interactivePopGestureRecognizer?.isEnabled = true
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.blue
            appearance.titleTextAttributes =  [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
            appearance.configureWithDefaultBackground()
            appearance.setBackIndicatorImage(#imageLiteral(resourceName: "back_en.pdf"), transitionMaskImage: #imageLiteral(resourceName: "back_en.pdf"))
            appearance.backgroundColor = .white
            if #available(iOS 14.0, *) {
                self.navigationItem.backButtonDisplayMode = .minimal
            } else {
                navigationItem.backButtonTitle = ""
            }
            appearance.shadowImage = UIImage()
            appearance.backgroundImage = UIImage()
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        self.interactivePopGestureRecognizer?.view?.semanticContentAttribute = .forceRightToLeft
        UIViewController.swizzle()
    }
}
extension UIView {
    static func isRightToLeft() -> Bool {
        return UIView.appearance().semanticContentAttribute == .forceRightToLeft
    }
}
private let swizzling: (UIViewController.Type, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
    if let originalMethod = class_getInstanceMethod(forClass, originalSelector), let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) {
        let didAddMethod = class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension UIViewController {
    
    static func swizzle() {
        let originalSelector1 = #selector(viewDidLoad)
        let swizzledSelector1 = #selector(swizzled_viewDidLoad)
        swizzling(UIViewController.self, originalSelector1, swizzledSelector1)
    }
    
    @objc open func swizzled_viewDidLoad() {
        if let _ = navigationController {
            if #available(iOS 14.0, *) {
                navigationItem.backButtonDisplayMode = .minimal
            } else {
                if #available(iOS 11.0, *) {
                    navigationItem.backButtonTitle = ""
                }
            }
        }
        swizzled_viewDidLoad()
    }
}
