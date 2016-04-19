//
//  CategoryPickerViewController.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/20/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit
import Foundation
import CoreData


//struct Category {
//    let Name:String?
//    let Time:String?
//}

class CategoryPickerViewController: UITableViewController {

    var selectedCategoryName = ""
    var categories:[Category] = []
    var selectedIndexPath = NSIndexPath()
    var managedContext : NSManagedObjectContext!
    var selectedCategory:Category!
    
    let date:String = {
        var date:NSDate = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd  HH:mm"
        var dateFormatterToString = formatter.stringFromDate(date)
        return dateFormatterToString
        
        }()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        //tableView.registerClass(UITableViewCell.self,forCellReuseIdentifier: "CategoryPicker")

        loadCategories()
    }

    func loadCategories(){
        var error:NSError?
        let categoryFetch = NSFetchRequest(entityName: "Category")
        let sorter:NSSortDescriptor = NSSortDescriptor(key: "date", ascending:false )
        categoryFetch.sortDescriptors = [sorter]
        
        do {
            try categories = managedContext.executeFetchRequest(categoryFetch) as! [Category]

            
            
        } catch let error1 as NSError {
            error = error1
            print("FetchResult failed")
        }
    }
    
    
    @IBAction func addCategory(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: NSLocalizedString("New Category", comment: "创新新分类"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "取消"),
            style: .Default,
            handler: { (action: UIAlertAction) in
                
        })
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "保存"),
            style: .Default,
            handler: { (action: UIAlertAction) in
                
                let textField = alert.textFields![0] 
                if self.isNoCharactor(textField.text){
                    let alert = UIAlertView(title: "", message: NSLocalizedString("your input has errors", comment: "你的输入不正确哦"), delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    textField.textColor = UIColor.redColor()
                }else{
                    self.addCategoryWithName(textField.text!)
                }
                
        })
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.presentViewController(alert,
            animated: true,
            completion: nil)
    }
    //判断输入是否为空或者只有空格
    func isNoCharactor(string:NSString?)->Bool{
        if(string == nil){
            return true
        }
        let set = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimedString :NSString = string!.stringByTrimmingCharactersInSet(set)
        if trimedString.length == 0 {
            return true
        }
        return false
    }
    func addCategoryWithName(string:String){
        
        let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: managedContext)
        
        let newCategory = Category(entity: entity!, insertIntoManagedObjectContext: managedContext)
        newCategory.name = string
        newCategory.date = date
        var error: NSError?
        do {
            try managedContext!.save()
            categories.append(newCategory)
            tableView.reloadData()


        } catch let error1 as NSError {
            error = error1
            print("Could not save: \(error)")
               }
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

                return categories.count
    }
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CategoryPicker")!
        let category = categories[indexPath.row] as Category
        cell.textLabel?.text = category.name as String
        cell.detailTextLabel?.text = categories[indexPath.row].date as String
        if categories[indexPath.row].name == selectedCategoryName {
            cell.accessoryType = .Checkmark
            selectedIndexPath = indexPath
            
        }else{
            cell.accessoryType = .None
        }
        return cell
    }
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row != selectedIndexPath.row {
//            if let newCell = tableView.cellForRowAtIndexPath(indexPath){
//                newCell.accessoryType = .Checkmark
//            }
//            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath){
//                oldCell.accessoryType = .None
//            }
//            selectedIndexPath = indexPath
       // }
        let newCell = tableView.cellForRowAtIndexPath(indexPath)
        newCell?.accessoryType = .Checkmark
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell){
                selectedCategoryName = categories[indexPath.row].name
                selectedCategory = categories[indexPath.row]
                
            }
        }
    }
    //Tells the delegate the table view is about to draw a cell for a particular row.
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor.whiteColor()
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let categoryToRemove = categories[indexPath.row] as Category
            managedContext.deleteObject(categoryToRemove)

            let locations = categories[indexPath.row].locations.allObjects as! [Location]
            
            for location in locations{
                self.managedContext.deleteObject(location)
            }
            categories.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            var error:NSError?
            do {
                try managedContext.save()
            } catch let error1 as NSError {
                error = error1
                print("Could Not save \(error)", terminator: "")
            }
        }
        
    }

}

