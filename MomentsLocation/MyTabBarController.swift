//
//  MyTabBarController.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/22/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
