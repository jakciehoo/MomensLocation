//
//  String+AddText.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/22/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import Foundation



extension String {
    mutating func addText(text:String?, withSeparator separator:String = ""){
        if let text = text {
            if !isEmpty{
                self += separator
            }
            self += text
        }
    }
}