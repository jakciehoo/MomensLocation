//
//  Functions.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/20/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import Foundation
import Dispatch
//实现
func afterDelay(seconds:Double,closure:() -> ()) {
    //Creates a dispatch_time_t relative to the default clock or modifies an existing dispatch_time_t.
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    //Enqueue a block for execution at the specified time.
    dispatch_after(when, dispatch_get_main_queue(),closure)
}
let applicationDocumentDirectory:String = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) 
    return paths[0]
}()
