import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView:MKMapView!
    var locations = [Location]()
    
    var manageObjectContext:NSManagedObjectContext!{
        didSet{
            NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: manageObjectContext, queue: NSOperationQueue.mainQueue()){
                notification in
                
                if let dictionary = notification.userInfo{
                    print(dictionary["inserted"])
                    print(dictionary["deleted"])
                    print(dictionary["updated"])
                    
                }
                if self.isViewLoaded(){
                    self.updateLocations()
                    
                }

            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if !locations.isEmpty{
            showLocation()
        }
    }
    
    @IBAction func showUser(){
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocation(){
        let region = regionForAnnotations(locations)
        mapView.setRegion(region, animated: true)
        
    }
    //更新地理位置信息
    func updateLocations() {
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: manageObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        var error:NSError?
        let foundObjects: [AnyObject]?
        do {
            foundObjects = try manageObjectContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            foundObjects = nil
        }
        
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        mapView.removeAnnotations(locations)
        locations = foundObjects as! [Location]
        mapView.addAnnotations(locations)
    }
    //将所有图标显示在地图范围内
    func regionForAnnotations(annotations:[MKAnnotation]) -> MKCoordinateRegion {
        var region:MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)

                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)

            }
            
            let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2 ,longitude:topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
            
        }
        return mapView.regionThatFits(region)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation"{
            let navigtaionController = segue.destinationViewController as! UINavigationController
            let controller = navigtaionController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = manageObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }

}

extension MapViewController:MKMapViewDelegate{
        
        func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
            if annotation is Location {
                let identifier = "Location"
                var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
                if annotationView == nil {
                    annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    
                    annotationView.enabled = true
                    annotationView.canShowCallout = true
                    annotationView.animatesDrop = false
                    annotationView.pinColor = .Green
                    annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
                    let rightButton = UIButton(type: .DetailDisclosure)
                    rightButton.addTarget(self, action: Selector("ShowLocationDetails:"), forControlEvents: .TouchUpInside)
                    annotationView.rightCalloutAccessoryView = rightButton
                    
                }else {
                    annotationView.annotation = annotation
                }
                
                let button = annotationView.rightCalloutAccessoryView as! UIButton
                if let index = locations.indexOf(annotation as! Location) {
                    button.tag = index
                }
                return annotationView
            }
            return nil
            
        }
        func ShowLocationDetails(sender:UIButton){
            performSegueWithIdentifier("EditLocation", sender: sender)
            
        }
        
}
extension MapViewController:UINavigationBarDelegate{
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}