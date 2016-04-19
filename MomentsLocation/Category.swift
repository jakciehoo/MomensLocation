//
//  Category.swift
//  MomentsLocation
//
//  Created by HooJackie on 3/30/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import Foundation
import CoreData


class Category:NSManagedObject {
    @NSManaged var  name:String
    @NSManaged var date:String
    @NSManaged var locations:NSSet
    
}
