

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    
    var managedObjectContext:NSManagedObjectContext!
    
    //you use a fetched results controller to efficiently manage the results returned from a Core Data fetch 
    //request to provide data for a UITableView object.
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: true)
        //let sortDescriptor2 = NSSortDescriptor(key: "category", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor1]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController( fetchRequest: fetchRequest,managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category.name",cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
        }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)
        //The color of separator rows in the table view.
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        navigationItem.rightBarButtonItem = editButtonItem()
       performFetch()
    }
    func performFetch(){
        //Executes the receiver’s fetch request.
        var error:NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            fatalCoreDataError(error)
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }




    //MARK: - UITableViewDataSource
    //每个section的行数量
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            let sectionInfo = fetchedResultsController.sections![section] 
            return sectionInfo.numberOfObjects
    
    }
    //section数量
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    //设施每个section的标题
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] 
        return sectionInfo.name.uppercaseString
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationCell
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location

        cell.configureForLocation(location)

        return cell
    }
    //实现删除行功能
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            if editingStyle == .Delete {
            let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            managedObjectContext.deleteObject(location)
                location.removePhotoFile()
            var error:NSError?
            do {
                try managedObjectContext.save()
            } catch let error1 as NSError {
                error = error1
            fatalCoreDataError(error)
            }
        }
    }
    

    //制定section header的样式
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
        //println("\(tableView.sectionFooterHeight)")
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFontOfSize(11)
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 1)
        
        label.backgroundColor = UIColor.clearColor()
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        let viewRect =  CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)
        view.addSubview(label)
        view.addSubview(separator)
        return view
    }
    //跳转到编辑页面
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let locationdetailsViewcontroller = navigationController.topViewController as! LocationDetailsViewController
            locationdetailsViewcontroller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
                locationdetailsViewcontroller.locationToEdit = location
            }
        }else if segue.identifier == "EditImage"{
            let imageEditVieController = segue.destinationViewController as! ImageEditViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
                imageEditVieController.location = location
            }
        }
    }

}

extension LocationsViewController:NSFetchedResultsControllerDelegate{
    //Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    //Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)  {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert(object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            print("*** NSFetchedResultsChangeDelete(object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            print("*** NSFetchedResultsChangeUpdate(object)")
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! LocationCell
            let location = controller.objectAtIndexPath(indexPath!) as! Location
            cell.configureForLocation(location)
        case .Move:
            print("*** NSFetchedResultsChangeMove(object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
            
        }
    }

    //Notifies the receiver of the addition or removal of a section.
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert(section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            print("*** NSFetchedResultsChangeDelete(section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Update:
            print("*** NSFetchedResultsChangeUpdate(section)")

        case .Move:
            print("*** NSFetchedResultsChangeMove(section)")
            
        }

    }
    //Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}

