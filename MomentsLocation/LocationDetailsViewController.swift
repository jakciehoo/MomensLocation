//
//  LocationDetailsViewController.swift
//  MomentsLocation
//
//  Created by HooJackie on 1/19/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit
import CoreLocation
import Dispatch
import CoreData

class LocationDetailsViewController:UITableViewController{
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark:CLPlacemark?
    var descrptionText = ""
    var categoryName = NSLocalizedString("No Category", comment: "未分类")
    var category:Category!
    
    let dateToString:String = {
        var date:NSDate = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd  HH:mm"
        var dateFormatterToString = formatter.stringFromDate(date)
        return dateFormatterToString
        
        }()
    
    var managedObjectContext:NSManagedObjectContext!
    
    var date = NSDate()
    var locationToEdit:Location? {
        didSet{
            if let location = locationToEdit {
                descrptionText = location.locationDescription
                self.category = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    
    
    private let dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        //Specifies a medium style, typically with abbreviated text, such as “Nov 23, 1937” or “3:30:32 PM”.
        formatter.dateStyle = .MediumStyle
        //Specifies a short style, typically numeric only, such as “11/23/37” or “3:30 PM”.
        formatter.timeStyle = .ShortStyle
     //   println(formatter)
        return formatter
    }()
    var image:UIImage?
    var observer:AnyObject!
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
 
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var addPhotoLabel:UILabel!
    
    deinit{
        print("*** deinit \(self)")
        //Removes all the entries specifying a given observer from the receiver’s dispatch table.
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(red: 138/255, green: 160/255, blue: 60/255, alpha: 1)
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        descriptionTextView.textColor = UIColor.whiteColor()
        descriptionTextView.backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)
        addPhotoLabel.textColor = UIColor.yellowColor()
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        addressLabel.textColor = UIColor.whiteColor()
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        if let location = locationToEdit {
            title = NSLocalizedString("Edit Location", comment: "编辑位置日志")
            if location.hasPhoto{
                if let image = location.photoImage{
                    showImage(image)
                }
            }
            self.categoryName = self.category.name
        }else {
            let categoryFetch = NSFetchRequest(entityName: "Category")
            categoryFetch.predicate = NSPredicate(format: "name == %@",categoryName)
            var error:NSError?
            let FetchResult = (try! self.managedObjectContext.executeFetchRequest(categoryFetch)) as! [Category]
            if FetchResult.count == 0{
                let NoCategory = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: managedObjectContext) as! Category
                NoCategory.name = categoryName
                NoCategory.date = dateToString
                do {
                    try self.managedObjectContext.save()
                    let Result = (try! self.managedObjectContext.executeFetchRequest(categoryFetch)) as! [Category]
                    self.category = Result[0]
                    
                } catch let error1 as NSError {
                    error = error1
                    print("save failed,error :\(error)")
                }

            }else {
                self.category = FetchResult[0] as Category
            }


        }
        categoryLabel.text = categoryName
        descriptionTextView.text = descrptionText
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        }else{
            addressLabel.text = NSLocalizedString("No Address Found", comment: "找不到地址")
        }
        dateLabel.text = formatDate(date)
        //增加单击手势
        let gestureRecongizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecongizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecongizer)
        listenForBackgroundNotification()
    }
    
    func hideKeyboard(gestureRecognizer:UIGestureRecognizer){
        //Returns the point computed as the location in a given view of the gesture represented by the receiver.
        let point = gestureRecognizer.locationInView(tableView)
        //Returns an index path identifying the row and section at the given point.
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    func stringFromPlacemark(placemark:CLPlacemark) -> String {
       var line = ""
        line.addText(placemark.subThoroughfare)
        
        line.addText(placemark.thoroughfare, withSeparator: " ")
        line.addText(placemark.locality, withSeparator: ", ")
        line.addText(placemark.administrativeArea, withSeparator: ", ")
        line.addText(placemark.postalCode, withSeparator: " ")
        line.addText(placemark.country, withSeparator: ", ")
        return line
    }
    //Called to notify the view controller that its view is about to layout its subviews.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    func formatDate(date:NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    //设置行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section,indexPath.row){
        case (0, 0):
            return 88
        case (1, _):
            return imageView.hidden ? 44 : 280
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000 )
            addressLabel.sizeToFit()       //Resizes and moves the receiver view so it just encloses its subviews.
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        default:
            return 44
        }

    }

    //只有选择section0 和section2 才返回选中行
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }else {
            return nil
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
            //点击add photo Section 弹出选择照片来源（照片库，活着摄像头）
        else if indexPath.section == 1 && indexPath.row == 0 {
            //takePhotoWithCamera()
           // choosePhotoFromLibrary()
            pickPhoto()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    //Tells the delegate the table view is about to draw a cell for a particular row.
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.backgroundColor = UIColor(red: 138/255, green: 160/255, blue: 60/255, alpha: 1)
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
        
        
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.whiteColor()
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    //制定section header的样式
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: 6, width: 300, height: 14)
        //println("\(tableView.sectionFooterHeight)")
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFontOfSize(12)
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 1)
        
        label.backgroundColor = UIColor.clearColor()
//        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
//        let separator = UIView(frame: separatorRect)
//        separator.backgroundColor = tableView.separatorColor
        
        let viewRect =  CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)
        view.addSubview(label)
        //view.addSubview(separator)
        return view
    }
    
    func showImage(image:UIImage){
        
        imageView.hidden = false
        //imageView.contentMode = .ScaleToFill
       // imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        imageView.image = image
        addPhotoLabel.hidden = true
    }
    //单击hudView实现关闭图标样式，
    @IBAction func done(sender: UIBarButtonItem) {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        var location:Location
        if let temp = locationToEdit {
            hudView.text = NSLocalizedString("Updated", comment: "已更新")
            location = temp
        }else {
            hudView.text = NSLocalizedString("Tagged", comment: "已记录")

        location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
            location.photoID = nil
        }
        location.locationDescription = descrptionText
        
        location.category = category
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image{
            if !location.hasPhoto{
                location.photoID = Location.nextPhotoID()
            }
            let data = UIImageJPEGRepresentation(image, 0.5)
            var error:NSError?
            do {
                try data!.writeToFile(location.photoPath, options: .DataWritingAtomic)
            } catch var error1 as NSError {
                error = error1
                print("Error writing file:\(error)")
            }
        }
        var locations = category.locations.mutableCopy() as! NSMutableSet
        locations.addObject(location)
        category.locations = locations.copy() as! NSSet
        
        var error:NSError?
        do {
            try managedObjectContext.save()
        } catch var error1 as NSError {
            error = error1
            fatalCoreDataError(error)
            return
        }
        
        afterDelay(0.6){
            self.dismissViewControllerAnimated(true , completion: nil)
        }
       //dismissViewControllerAnimated(true , completion: nil)
    }
    
    @IBAction func Cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true , completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory"{
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
            controller.managedContext = managedObjectContext
        }
    }
    
    //从categoryPickerViewController 关闭 unwind返回选择值
    @IBAction func categoryPickerDidPickCategory(segue:UIStoryboardSegue){
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
        self.category = controller.selectedCategory
    }
    
    
    //监听通知，Posted when the app enters the background.
    func listenForBackgroundNotification() {
       observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()){ [weak self] notification in
        if let strongSelf = self {
            if strongSelf.presentedViewController != nil {
                strongSelf.dismissViewControllerAnimated(false, completion: nil)
            }
            strongSelf.descriptionTextView.resignFirstResponder()
        }
            
        }
    }
    
    
}
extension LocationDetailsViewController:UITextViewDelegate {
    //Asks the delegate whether the specified text should be replaced in the text view.The delegate methods simply update the contents of the descriptionText instance variable whenever the user types into the text view.
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        descrptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
        
    }
    //Tells the delegate that editing of the specified text view has ended.
    func textViewDidEndEditing(textView: UITextView) {
        descrptionText = textView.text
    }
}
   //MARK: - 实现UIImageControllerDelegate代理,主要实现照片选择功能
extension LocationDetailsViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func takePhotoWithCamera(){
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    func choosePhotoFromLibrary(){
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    func pickPhoto(){
        if true || UIImagePickerController.isSourceTypeAvailable(.Camera){
            showPhotoMenu()
        }else {
            choosePhotoFromLibrary()
        }
    }
    func showPhotoMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "取消"), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title:  NSLocalizedString("Take Photo", comment: "拍照"), style: .Default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        let chooseFromLibraryAction = UIAlertAction(title: NSLocalizedString("Choose From Library", comment: "从相册选择"), style: .Default, handler: { _ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    //Tells the delegate that the user picked a still image or movie.pickerThe controller object managing the image picker interface.infoA dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //Specifies an image edited by the user.
        image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        if let image = image{
            showImage(image)
        }
        tableView.reloadData()
        dismissViewControllerAnimated(true , completion: nil)
    }
    //Tells the delegate that the user cancelled the pick operation.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true , completion: nil)
    }
}
