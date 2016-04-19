//
//  MomentsLocation.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/20/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Location: NSManagedObject,MKAnnotation {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: Category
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var photoID:NSNumber?
    
    var coordinate:CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title:String?{
        if locationDescription.isEmpty{
            return "(No Description)"
        }else {
            return locationDescription
        }
    }
    var subtitle:String?{
        return category.name
    }
    var hasPhoto:Bool {
        return photoID != nil
    }
    var photoPath:String {
        assert(photoID != nil, "No Photo ID set")
        let filename = "/Photo-\(photoID!.integerValue).jpg"
        return applicationDocumentDirectory.stringByAppendingString(filename)
    }
    var photoImage:UIImage?{
        return UIImage(contentsOfFile: photoPath)
    }
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("PhotoID")
        userDefaults.setInteger(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile(){
        if hasPhoto{
            let path = photoPath
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path){
                var error:NSError?
                do {
                    try fileManager.removeItemAtPath(path)
                } catch let error1 as NSError {
                    error = error1
                    print("Error removing file:\(error!)")
                }
            }
        }
    }

}
