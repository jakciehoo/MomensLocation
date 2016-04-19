//
//  FirstViewController.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/15/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore
import AudioToolbox

class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var messgaeLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    
    @IBOutlet weak var getButton: UIButton!
    
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel:UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    var logoVisible = false
    let locationManager = CLLocationManager()
    var location:CLLocation?
    var updatingLocation = false
    var lastLocationError:NSError?
    let geocoder = CLGeocoder()
    var placemark:CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError:NSError?
    var timer:NSTimer?
    var soundID:SystemSoundID = 0
    var managedObjectContext:NSManagedObjectContext!

    lazy var logoButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
        button.sizeToFit()
        button.addTarget(self, action: Selector("getLocation:"), forControlEvents: .TouchUpInside)
        button.center.x = CGRectGetMidX(self.view.bounds)
        button.center.y = 220
        return button
        
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        loadSoundEffect("Sound.caf")
        // Do any additional setup after loading the view, typically from a nib.
        //self.tabBarController?.tabBarItem.image?.imageWithRenderingMode(.AlwaysOriginal)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getLocation(sender: UIButton) {
        let authStatus:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServiceDeniedAlert()
            return
        }
        if logoVisible {
            hideLogoView()
        }
        if updatingLocation {
            stopLocationManager()
        }else{
            location = nil
            placemark = nil
            lastLocationError = nil
            lastLocationError = nil
            startLocationManager()

        }
        updateLabels()
        configureGetButton()
    }
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError\(error)")
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetButton()
   
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations\(newLocation)")
        //1
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        //2
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        //3
        
         var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location?.horizontalAccuracy > newLocation.horizontalAccuracy {
            //4
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            //5
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We are done!")
                stopLocationManager()
                configureGetButton()
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding{
                print("*** Going to Geocode")
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(location!, completionHandler: {
                    placemarks, error in
                    print("*** Found placemarks:\(placemarks),error:\(error)")
                    self.lastLocationError = error
                    if error == nil && !placemarks!.isEmpty {
                        if self.placemark == nil {
                            print("FIRST TIME!")
                            self.playSoundEffect()
                        }
                        self.placemark = placemarks!.last
                    }else{
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
            
        }else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
        
        lastLocationError = nil
        location = newLocation
        updateLabels()
    }
    func showLocationServiceDeniedAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Location Services Disabled", comment: "定位服务未开启"), message: NSLocalizedString("Please enable location services for this app in settings", comment: "请在设置里为应用程序开启定位服务"), preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%0.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%0.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messgaeLabel.text = ""
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            }else if performingReverseGeocoding {
                addressLabel.text = NSLocalizedString("Searching for Address...", comment: "正在查询地理位置...")
            }else if lastLocationError != nil {
                addressLabel.text = NSLocalizedString("Error Finding Address", comment: "查询错误")
            }else {
                addressLabel.text = NSLocalizedString("No Address Found", comment: "找不到位置信息")
            }
            latitudeTextLabel.hidden = false
            longitudeTextLabel.hidden = false

        }else{
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = true
            var statusMessage:String
            if let error = lastLocationError{
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = NSLocalizedString("Location Services Disabled", comment: "定位服务未开启")
                }else{
                    statusMessage = NSLocalizedString("Error Getting Location", comment: "获取位置错误")
                }
            }else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = NSLocalizedString("Location Services Disabled", comment: "定位服务未开启")
            }else if updatingLocation {
                statusMessage = NSLocalizedString("Searching...", comment: "正在查找中")
            }else {
                statusMessage = ""
                showLogoView()
            }
            messgaeLabel.text = statusMessage
            latitudeTextLabel.hidden = true
            longitudeTextLabel.hidden = true
        }
    }
    func stringFromPlacemark(placemark:CLPlacemark) -> String {
        
        var line1 = ""
        line1.addText(placemark.subThoroughfare)
        line1.addText(placemark.thoroughfare, withSeparator: " ")
        var line2 = ""
        line2.addText(placemark.locality)
        line2.addText(placemark.administrativeArea, withSeparator: " ")
        line2.addText(placemark.postalCode, withSeparator: " ")
        if line1.isEmpty {
            return line2 + "\n "
        }else {
            return line1 + "\n" + line2
        }
    }
    func stopLocationManager(){
        if updatingLocation{
            if let timer = timer {
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
    }
    func configureGetButton(){
        
        let spinnerTag = 1000
        if updatingLocation {
            getButton.setTitle(NSLocalizedString("Stop", comment: "停止按钮") , forState: .Normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
                spinner.center = messgaeLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        }else {
            getButton.setTitle(NSLocalizedString("Get My Location", comment: "获取位置按钮"), forState: .Normal)
            if let spinner = view.viewWithTag(spinnerTag){
                spinner.removeFromSuperview()
            }
        }
    }
    func didTimeOut(){
        print("*** Time Out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError (domain: "MomentsLocationErrordomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    //MARK: - Logo View
    
    func showLogoView(){
        if !logoVisible {
            logoVisible = true
            containerView.hidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        if !logoVisible { return }
        logoVisible = false
        containerView.hidden = false
        
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        let centerX = CGRectGetMidX(view.bounds)
        let pannelMover = CABasicAnimation(keyPath: "position")
        pannelMover.removedOnCompletion = false
        pannelMover.fillMode = kCAFillModeForwards
        pannelMover.duration = 0.6
        pannelMover.fromValue = NSValue(CGPoint:containerView.center)
        pannelMover.toValue = NSValue(CGPoint:CGPoint(x: centerX, y: containerView.center.y))
        pannelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        pannelMover.delegate = self
        containerView.layer.addAnimation(pannelMover, forKey: "pannelMover")
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.removedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(CGPoint:logoButton.center)
        logoMover.toValue = NSValue(CGPoint:CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.removedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")

    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
        
    }
    
    //MARK - Sound Effect
    
    func  loadSoundEffect(name:String){
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil){
            //Initializes and returns a newly created NSURL object as a file URL with a specified path.
            let fileURL = NSURL.fileURLWithPath(path, isDirectory: false)

            //Creates a system sound object.
            let error = AudioServicesCreateSystemSoundID(fileURL, &soundID)
            if Int32(error) != kAudioServicesNoError {
                print("Error code \(error) loading sound at path:\(path)")
                return
            }
        }
    }
    func unloadSoundEffect(){
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    func playSoundEffect(){
        //Plays a system sound object.
        AudioServicesPlaySystemSound(soundID)
    }

}

