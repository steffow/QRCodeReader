//
//  UIApplication+TopViewController.swift
//  QRCodeReader
//
//  Created by Steffo Weber on 19.04.17.
//  Copyright © 2017 Steffo Weber. All rights reserved.
//

import Foundation
import UIKit


extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
