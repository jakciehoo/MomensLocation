//
//  ImageEditViewController.swift
//  MomentsLocation
//
//  Created by HooJackie on 4/24/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit
import CoreLocation

class ImageEditViewController: UIViewController {
    var descriptionLabel: UILabel = UILabel()
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var placemarkLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var scrollView: UIScrollView!
    var buttonContainer:UIView!
    var radialMenu:ASRadialMenu!
    var menuButton: UIButton!
    var button:ASRadialButton!
    
    let fonts = ["Avenir", "American Typewriter", "Avenir-HeavyOblique", "Noteworthy-Bold", "BradleyHandITCTT-Bold", "Didot-Italic","Arial-BoldMT","BradleyHandITCTT-Bold"]
    let colors = [UIColor.redColor(),UIColor.purpleColor(),UIColor.orangeColor(),UIColor.yellowColor(),UIColor.blackColor(),UIColor.cyanColor(),UIColor.blueColor(),UIColor.brownColor(),UIColor.greenColor(),UIColor.grayColor(),UIColor.lightGrayColor(),UIColor.magentaColor(),UIColor.whiteColor()]
    let filters = ["CIColorPosterize","CIVibrance","CIGloom","CIGaussianBlur","CIGammaAdjust","CIExposureAdjust","CISepiaTone","CISRGBToneCurveToLinear","CILinearToSRGBToneCurve","CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIColorInvert","CIPhotoEffectNoir", "CIPhotoEffectMono", "CIPhotoEffectProcess", "CIPhotoEffectTransfer", "CIVignetteEffect"]
    let filterLables = ["Posterize","Vibrance","Gloom","Gaussian","Camma","Exposure","Sepia","Linear","SRGBTone","Chrome", "Fade", "Instant","Invert","Noir", "Mono", "Process", "Transfer", "Vignette"]
    
    var location:Location!
    var imageThumbnail:UIImage!
    var imageFullSize:UIImage!
    var prevChosenFilterIndex:Int = -1
    var doubleTapped:Bool = false
    let animationDuration = 0.5
    let animationDelay = 0.1
    var visable = false

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.radialMenu = ASRadialMenu()
        self.radialMenu.delegate = self
        

        
        let tapView = UITapGestureRecognizer(target: self, action: "tapViewToShowButtons")
        tapView.delegate = self
        self.view.addGestureRecognizer(tapView)

        setupContent()

    }
    func setupContent(){
        if self.location?.hasPhoto == true{
            if let image = location.photoImage{
                self.imageView.image = image
                self.imageFullSize = self.imageWithImage(image, newSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height))
                self.imageThumbnail = self.imageWithImage(self.imageFullSize, newSize: CGSizeMake(50, 50))
            }
        }else{
            
        }
        let Bounds = self.view.bounds
        let x = CGFloat(arc4random() % (UInt32)(Bounds.size.width - 200.0))
        let y = CGFloat(arc4random() % (UInt32)(Bounds.size.height - 250.0))
        //self.descriptionLabel = UILabel()
        self.descriptionLabel.frame.origin.x = x
        self.descriptionLabel.frame.origin.y = y
        self.descriptionLabel.frame.size.width = 200
        self.descriptionLabel.text = location.locationDescription
        descriptionLabel.frame.size.width = 200
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "Arial", size: 27)
        let maxsize = descriptionLabel.sizeThatFits(CGSizeMake(descriptionLabel.frame.size.width,CGFloat(MAXFLOAT)))
        
        descriptionLabel.frame.size.height = maxsize.height
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.userInteractionEnabled = true
        descriptionLabel.multipleTouchEnabled = true
        self.viewContainer.addSubview(descriptionLabel)
        addGestureRecognizersToPiece(descriptionLabel)
        if let placemark = location.placemark{
            self.placemarkLabel.text = self.stringFromPlacemark(placemark)
        }
        self.latitudeLabel.text = "\(location.latitude)"
        self.longitudeLabel.text = "\(location.longitude)"
        self.dateLabel.text = "\(location.date)"
        
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
    //Resize an image
    func imageWithImage(image:UIImage,newSize:CGSize) -> UIImage{
        print("Resizing the image")
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    //将CLPlacemark类型转成string类型
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
    func tapViewToShowButtons(){


        if !visable{
            creatButtonsViewAnimation()
            createMenuButton()
            
        }else{
            if self.buttonContainer != nil{
                self.buttonContainer.removeFromSuperview()
            }
            if self.scrollView != nil{
                
                self.scrollView.removeFromSuperview()
            }
            if self.menuButton != nil {
                self.menuButton.removeFromSuperview()
                //self.menuButton
            }
        }

        self.visable = !self.visable
        
    }
    func creatButtonsViewAnimation(){
        buttonContainer = UIView(frame: CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.height, 200, 50))
        buttonContainer.layer.cornerRadius = 25
        buttonContainer.alpha = 0.0
        buttonContainer.backgroundColor = UIColor.whiteColor()
        let fontButton = UIButton(frame: CGRectMake(23, 0, 50, 50))
        fontButton.setBackgroundImage(UIImage(named: "Font"), forState: .Normal)
        fontButton.addTarget(self, action: "changeFonts:", forControlEvents: .TouchUpInside)
        let colorButton = UIButton(frame: CGRectMake(75, 0, 50, 50))
        colorButton.setBackgroundImage(UIImage(named: "Color"), forState: .Normal)
        colorButton.addTarget(self, action: "changeColor:", forControlEvents: .TouchUpInside)
        let filterButton = UIButton(frame: CGRectMake(127, 0, 50, 50))
        filterButton.setBackgroundImage(UIImage(named: "Filter"), forState: .Normal)
        filterButton.addTarget(self, action: "changeFilter:", forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(fontButton)
        buttonContainer.addSubview(colorButton)
        buttonContainer.addSubview(filterButton)
        self.view.addSubview(buttonContainer)
        UIView.animateWithDuration(self.animationDuration, delay: self.animationDelay, options: .CurveEaseOut, animations: {
            self.buttonContainer.alpha = 1.0
            self.buttonContainer.frame.origin.y -= 130
            
            }, completion: {completed in
                
        })

    }
    func createMenuButton(){
        menuButton = UIButton(frame: CGRectMake(self.view.bounds.size.width/2-25 , -50 , 50 ,50))
        menuButton.layer.cornerRadius = 25
        menuButton.backgroundColor = UIColor.whiteColor()
        menuButton.alpha = 0.5
        self.view.addSubview(menuButton)
        menuButton.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        UIView.animateWithDuration(self.animationDuration, delay: self.animationDelay, options: .CurveEaseOut, animations: {
            self.menuButton.frame.origin.y = 100
            
            }, completion: {completed in
                
        })
        

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func changeFonts(sender: UIButton) {
        if self.scrollView != nil{
            self.scrollView.removeFromSuperview()
        }
        if self.menuButton != nil {
            self.menuButton.removeFromSuperview()

        }
        createScrollViewAnimation()
        addFontToScrollView()
    }
    func changeFilter(sender: UIButton) {
        if self.scrollView != nil{
            self.scrollView.removeFromSuperview()
        }
        if self.menuButton != nil {
            self.menuButton.removeFromSuperview()
        }
        createScrollViewAnimation()
        addFilterToScrollView()

    }
    
    func changeColor(sender: UIButton) {
        if self.scrollView != nil{
            self.scrollView.removeFromSuperview()
        }
        if self.menuButton != nil {
            self.menuButton.removeFromSuperview()
        }
        createScrollViewAnimation()
        addColorToScrollView()
    }
    //添加用于改变的字体，颜色，滤镜到scrollview的方法
    func addFontToScrollView(){
        self.scrollView.contentSize = CGSizeMake(CGFloat(45 * self.fonts.count) , 52)
        for i in 0..<self.fonts.count{
            let fontButton = UIButton(frame: CGRect(x: 40*i + 4*i,y: 5, width: 40, height: 40))
            fontButton.tag = i + 100
            fontButton.setTitle("Aa", forState: .Normal)
            fontButton.layer.cornerRadius = 10
            fontButton.clipsToBounds = true
            fontButton.contentVerticalAlignment = .Bottom
            fontButton.contentHorizontalAlignment = .Center
            fontButton.layer.borderWidth = 1.0
            fontButton.layer.borderColor = UIColor.clearColor().CGColor
            fontButton.titleLabel?.font = UIFont(name: self.fonts[i], size: 30.0)
            fontButton.addTarget(self, action: "chooseFont:", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(fontButton)
            print("Create and add \(fonts[i]) button success")
        }
    }

    func addColorToScrollView(){

        self.scrollView.contentSize = CGSizeMake(CGFloat(45 * self.colors.count) , 52)
        for i in 0..<self.colors.count{
            let colorButton = UIButton(frame: CGRect(x: 40*i + 4*i,y: 5, width: 40, height: 40))
            colorButton.tag = i + 200
            colorButton.layer.cornerRadius = 10
            colorButton.clipsToBounds = true
            colorButton.layer.borderWidth = 1.0
            colorButton.layer.borderColor = UIColor.clearColor().CGColor
            colorButton.backgroundColor = self.colors[i]
            colorButton.addTarget(self, action: "chooseColor:", forControlEvents: .TouchUpInside)
            self.scrollView.addSubview(colorButton)
            print("Create and add color button success")
        }
        
    }
    func addFilterToScrollView(){

        self.scrollView.contentSize = CGSizeMake(CGFloat(40 * self.filters.count) , 52)
        for i in 0..<self.filters.count{
            print("Creating thumnail for \(self.filters[i]) filter")
            //create raw CIImage
            let rawThumbnailData = CIImage(image: self.imageThumbnail)
            let filter = CIFilter(name: self.filters[i])!
            filter.setDefaults()
            //set raw CIImage as input image
            filter.setValue(rawThumbnailData, forKey: "inputImage")
            let filterThumbnailData = filter.valueForKey("outputImage") as! CIImage
            let filterThumbnail = UIImage(CIImage: filterThumbnailData)
            let filterButton = UIButton(frame: CGRect(x: 35*i + 4*i, y: 3, width: 35, height: 35))
            filterButton.tag = i+100
            filterButton.backgroundColor = UIColor.whiteColor()
            filterButton.layer.borderWidth = 1.0
            filterButton.layer.borderColor = UIColor.clearColor().CGColor
            filterButton.addTarget(self, action: "chooseFilter:", forControlEvents: UIControlEvents.TouchUpInside)
            filterButton.setBackgroundImage(filterThumbnail, forState: .Normal)
            self.scrollView.addSubview(filterButton)
            
            let filterLabel = UILabel(frame: CGRect(x: 35*i + 4*i,y: 37,width: 35,height: 12))
            filterLabel.text = self.filterLables[i]
            filterLabel.font = UIFont(name: "Avenir", size: 9.0)
            filterLabel.textAlignment = .Center
            filterLabel.backgroundColor = UIColor.clearColor()
            filterLabel.textColor = UIColor.lightGrayColor()
            self.scrollView.addSubview(filterLabel)
            print("Adding UIButton add UILabel to scroll view")
        }
    }
    func createScrollViewAnimation(){
        self.scrollView = UIScrollView(frame: CGRectMake(self.view.bounds.size.width/2-150, self.view.bounds.height-202, 300, 52))
        self.scrollView.layer.cornerRadius = 10
        self.scrollView.backgroundColor = UIColor.darkGrayColor()
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alpha = 0.0
        self.view.addSubview(scrollView)
        UIView.animateWithDuration(self.animationDuration, delay: self.animationDelay, options: .CurveEaseOut, animations: {
            self.scrollView.alpha = 1.0
            self.scrollView.frame.origin.y = self.view.bounds.height - 190
            }, completion: nil)
    }
    

    //MARK: - Button Target Actions
    func chooseFont(sender:UIButton){
        print("Button pressed target action: chose font")
        let chosenFontIndex = sender.tag - 100
        self.descriptionLabel.font = UIFont(name: self.fonts[chosenFontIndex], size: 27.0)
        self.descriptionLabel.sizeToFit()
    }
    func chooseColor(sender:UIButton){
        print("Button pressed target action chose color")
        let chosenColorIndex = sender.tag - 200
        self.descriptionLabel.textColor = self.colors[chosenColorIndex]

    }
    @IBAction func chooseFilter(sender:UIButton){
        let chosenFilterIndex = sender.tag - 100
        print("chose \(filters[chosenFilterIndex])")
        //if a user double taps a filter preview, them remove the fitler
        if(self.prevChosenFilterIndex == chosenFilterIndex && !self.doubleTapped){
            self.doubleTapped = true
            //remove the border around chosen thumnail
            sender.layer.borderWidth = 0.0
            self.imageView.image = self.imageFullSize
            
        }else{
            //filter the image
            //remove border around previously chosen thumbnail
            if(prevChosenFilterIndex != -1){
                let prevSender = self.view.viewWithTag(self.prevChosenFilterIndex + 100) as? UIButton
                prevSender?.layer.borderWidth = 0.0
            }
            
            //draw borer around chosen thumbnail
            sender.layer.borderWidth = 3.0
            sender.layer.borderColor = UIColor.blueColor().CGColor
            
            let rawImageData = CIImage(image: self.imageFullSize)
            let filter = CIFilter(name: self.filters[chosenFilterIndex])!
            filter.setDefaults()
            filter.setValue(rawImageData, forKey: "inputImage")
            let filterImgData = filter.valueForKey("outputImage") as! CIImage
            let filterImg = UIImage(CIImage: filterImgData)
            self.imageView.image = filterImg
            
            //reset these variables
            self.prevChosenFilterIndex = chosenFilterIndex
            self.doubleTapped = false
        }
    }
    //MARK: - Screenshot
    func takeScreenshot(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
//给日志文字添加各种手势
extension ImageEditViewController:UIGestureRecognizerDelegate{
    //MARK: - Gesture Recognize Delegate
    //add rotation ,pan ,pinch gesture to moment text
    func addGestureRecognizersToPiece(piece:UIView){
        print("Adding rotation gesture recognizer to view")
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: "rotatePiece:")
        rotationGesture.delegate = self
        piece.addGestureRecognizer(rotationGesture)
        
        print("Adding pan gesture recognizers to viw")
        let panGesture = UIPanGestureRecognizer(target: self, action: "panPiece:")
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        piece.addGestureRecognizer(panGesture)
        
        print("Adding pinch gesture recognizers to view")
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchPiece:")
        pinchGesture.delegate = self
        piece.addGestureRecognizer(pinchGesture)
        print("Adding tap gesture recognizer")
        let tapPiece = UITapGestureRecognizer(target: self, action: "changeContent")
        tapPiece.numberOfTapsRequired = 1
        tapPiece.numberOfTouchesRequired = 1
        piece.addGestureRecognizer(tapPiece)
        
    }
    
    //use UIPanGestureRecognizer to shift the piece view center by the pan amount,and reset recognizer's translation to CGPointZero after applying so the next t
    func panPiece(recognizer:UIPanGestureRecognizer){
        let piece = recognizer.view!
        piece.superview?.bringSubviewToFront(piece)
        self.adjustAnchorPointForGestureRecognizer(recognizer)
        if(recognizer.state == .Began || recognizer.state == .Changed){
            let translation = recognizer.translationInView(piece.superview!)
            if(CGRectContainsPoint(self.view.frame, CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y))){
                piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y)
                recognizer.setTranslation(CGPointZero, inView: piece.superview!)
            }
        }
    }
    //rotate the piece by the current rotation
    func rotatePiece(recognizer:UIRotationGestureRecognizer){
        let piece = recognizer.view!
        self.adjustAnchorPointForGestureRecognizer(recognizer)
        if(recognizer.state == .Began || recognizer.state == .Changed){
            piece.transform = CGAffineTransformRotate(piece.transform, recognizer.rotation)
            recognizer.rotation = 0.0
            
        }
    }
    
    //scale the piece by the current scale
    func pinchPiece(recognizer:UIPinchGestureRecognizer){
        let piece = recognizer.view!
        self.adjustAnchorPointForGestureRecognizer(recognizer)
        if(recognizer.state == .Began || recognizer.state == .Changed){
            piece.transform = CGAffineTransformScale(piece.transform, recognizer.scale, recognizer.scale)
            recognizer.scale = 1.0
            
        }
    }
    func adjustAnchorPointForGestureRecognizer(recognizer:UIGestureRecognizer){
        if(recognizer.state == UIGestureRecognizerState.Began){
            let piece = recognizer.view!
            let locationInView = recognizer.locationInView(piece)
            let locationInSuperView = recognizer.locationInView(piece.superview)
            piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height)
            piece.center = locationInSuperView
        }
        
    }
    func changeContent(){
        let alert = UIAlertController(title: NSLocalizedString("New Journal", comment: "修改文字"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "取消"),
            style: .Default,
            handler: { (action: UIAlertAction) in
                
        })
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "修改"),
            style: .Default,
            handler: { (action: UIAlertAction) in
                
                let textField = alert.textFields![0] 
                if self.isNoCharactor(textField.text){
                    let alert = UIAlertView(title: "", message: NSLocalizedString("your input has errors", comment: "你太调皮了，输入不合理的字符"), delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    self.descriptionLabel.text = textField.text
                    self.descriptionLabel.sizeToFit()
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
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
//添加菜单按钮
extension ImageEditViewController:ASRadialMenuDelegate{

    
    func buttonPressed(sender: AnyObject) {
        
        self.radialMenu.buttonsWillAnimateFromButton(sender as! UIButton, frame: self.menuButton.frame, view: self.view)
        
    }
    
    func numberOfItemsInRadialMenu (radialMenu:ASRadialMenu)->NSInteger {
        
        return 3
    }
    func arcSizeInRadialMenu (radialMenu:ASRadialMenu)->NSInteger {
        
        return 180
    }
    func arcRadiousForRadialMenu (radialMenu:ASRadialMenu)->NSInteger {
        
        return 70
    }
    func radialMenubuttonForIndex(radialMenu:ASRadialMenu,index:NSInteger)->ASRadialButton {
        
        self.button = ASRadialButton()
        
        if index == 1 {
            button.frame = CGRectMake(0, 0, 50, 50)
            button.layer.cornerRadius = 25
            button.backgroundColor = UIColor.whiteColor()
            button.setImage(UIImage(named: "photoIcon"), forState:.Normal)
            button.setImage(UIImage(named: "photoIcon"), forState:.Highlighted)
            button.addTarget(self, action: "saveToPhoto", forControlEvents: .TouchUpInside)
            
        } else if index == 2 {
            button.frame = CGRectMake(0, 0, 50, 50)
            button.layer.cornerRadius = 25
            button.backgroundColor = UIColor.whiteColor()
            button.setImage(UIImage(named: "shareIcon"), forState:.Normal)
            button.setImage(UIImage(named: "shareIcon"), forState:.Highlighted)
            button.addTarget(self, action: "shareToFriends:", forControlEvents: .TouchUpInside)
            
        } else if index == 3 {
            button.frame = CGRectMake(0, 0, 50, 50)
            button.layer.cornerRadius = 25
            button.backgroundColor = UIColor.whiteColor()
            button.setImage(UIImage(named: "nextIcon"), forState:.Normal)
            button.setImage(UIImage(named: "nextIcon"), forState:.Highlighted)
            button.addTarget(self, action: "goBack", forControlEvents: .TouchUpInside)

        }
        
        return button
    }
    
    func saveToPhoto(){
        let image = takeScreenshot(self.viewContainer)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        let alert = UIAlertView(title: "保存成功", message: NSLocalizedString("已经将图片保存至照片中，请前往查看", comment: "saved successful to photo album"), delegate: self, cancelButtonTitle: NSLocalizedString("知道了", comment: "OK"))
        alert.show()
        
        
    }
    func shareToFriends(sender:UIButton){
        let imageWithText = self.takeScreenshot(self.viewContainer)
        
        let imageData = UIImagePNGRepresentation(imageWithText)
        let publishContent = ShareSDK.content("我在使用丁丁出行记程序，分享我的此时此刻", defaultContent: "丁丁出行记", image: ShareSDK.imageWithData(imageData, fileName: location.locationDescription, mimeType: "png"), title: "丁丁出行记", url: "http://weibo.com/hooyoo", description: location.locationDescription, mediaType: SSPublishContentMediaTypeImage)
        let container = ShareSDK.container()
        container.setIPadContainerWithView(sender, arrowDirect: UIPopoverArrowDirection.Up)
        ShareSDK.showShareActionSheet(container, shareList: nil, content: publishContent, statusBarTips: true, authOptions: nil, shareOptions: nil, result: {
            (type , state , statusInfo , error , end) in
            
        })
    }
    func goBack(){
        setupContent()
        
    }
    
    func radialMenudidSelectItemAtIndex(radialMenu:ASRadialMenu,index:NSInteger) {
        
        self.radialMenu.itemsWillDisapearIntoButton(self.menuButton)
        
    }

    
}
