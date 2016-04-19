

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    //配置cell显示项
    func configureForLocation(location:Location){
        if location.locationDescription.isEmpty{
            descriptionLabel.text = NSLocalizedString("No Description", comment: "没有日志")
        }else{
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            text.addText(placemark.subThoroughfare)
            text.addText(placemark.thoroughfare, withSeparator: " ")
            text.addText(placemark.locality, withSeparator: ", ")
            addressLabel.text = text
            
            
            
        }else {
            addressLabel.text = String(format: NSLocalizedString("Lat: %.8f, Long: %.8f", comment: "纬度: %.8f, 经度: %.8f"), location.latitude, location.longitude)
        }
        photoImageView.image = imageForLocation(location)
    }
    func imageForLocation(location:Location) -> UIImage {
        if location.hasPhoto {
            if let image = location.photoImage {
                return image.resizedImageWithBounds(CGSize(width:52,height:52))
            }
        }
        return UIImage(named: "No Photo")!
    }
    //Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        //descriptionLabel.lineBreakMode = .ByTruncatingTail
        //descriptionLabel.sizeToFit()
        addressLabel.textColor = UIColor.yellowColor()
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        //addressLabel.sizeToFit()
        
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        //The view used as the background of the cell when it is selected.
        selectedBackgroundView = selectionView
        //The view’s Core Animation layer used for rendering. (read-only)
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        //A Boolean value that determines whether subviews are confined to the bounds of the view.
        photoImageView.clipsToBounds = true
        
        
        //The inset values for the cell’s content.You can use this property to add space between the current cell’s contents and the left and right edges of the table.
        //The separatorInset moves the separator lines between the cells a bit to the right so there are no lines between the thumbnail images.
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }
    //The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.
    override func layoutSubviews() {
        super.layoutSubviews()
        if let sv = superview{
            descriptionLabel.frame.size.width = sv.frame.width - descriptionLabel.frame.origin.x - 10
            addressLabel.frame.size.width = sv.frame.width - addressLabel.frame.origin.x - 10
        }
    }

}
