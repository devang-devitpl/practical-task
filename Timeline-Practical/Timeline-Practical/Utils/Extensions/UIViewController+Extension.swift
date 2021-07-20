//
//  UIViewController+Extension.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import UIKit

//MARK:- UIAlert View Methods -
extension UIViewController {
    
    func displayAlert(title: String?, message: String?, buttonName: String = "OK", completion: (()->())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: buttonName, style: .cancel) { (action) in
            completion?()
        }
        controller.addAction(actionButton)
        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
        }
    }
    
    func displayAlert(title: String?, message: String?, alertActions action: [UIAlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        action.forEach({ controller.addAction($0) })
        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
        }
    }
}

extension UIApplication {
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
