//
//  UIImage_Resize.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/22/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImageWithBounds(bounds:CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
