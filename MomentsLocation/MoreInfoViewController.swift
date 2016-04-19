//
//  MoreInfoViewController.swift
//  MomentsLocation
//
//  Created by HooJackie on 4/28/15.
//  Copyright (c) 2015 jackie. All rights reserved.
//

import UIKit
import MessageUI

class MoreInfoViewController: UITableViewController,MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(red: 105/255, green: 121/255, blue: 0/255, alpha: 1)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0 && indexPath.row == 1){
            displayComposerSheet()
        }
        if (indexPath.section == 0 && indexPath.row == 2){
            shareToFriends("990532627")
        }
        if(indexPath.section == 0 && indexPath.row == 0){
            goToAppstorePageRaisal("990532627")
        }
        if (indexPath.section == 1 && indexPath.row == 1){
            displayComposerSheet()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    //跳转到评价页面
    func goToAppstorePageRaisal(appID:String){
        let urlToOpen = "itms-apps://itunes.apple.com/cn/app/id\(appID)?mt=8"
        UIApplication.sharedApplication().openURL(NSURL(string: urlToOpen)!)
    }
    
    //调用系统邮件方法
    func displayComposerSheet(){
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject(NSLocalizedString("Enter Your Subject", comment: "输入邮件主题"))
        let recipients = ["niat05ethjh1112@163.com"]
        picker.setToRecipients(recipients)
        self.presentViewController(picker, animated: true
        , completion: nil)
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //关闭邮件发送窗口

    }
    //推荐给其他朋友
    func shareToFriends(appID:String){
        let imagePath = NSBundle.mainBundle().pathForResource("AppIcon1024", ofType: "png")
        let urlToOpen = "itms-apps://itunes.apple.com/cn/app/id\(appID)?mt=8"

        let publishContent = ShareSDK.content("我在使用丁丁出行记程序，分享我的此时此刻, 非常有意思的一款软件，大家也下载来试试吧", defaultContent: "丁丁出行记", image: ShareSDK.imageWithPath(imagePath), title: "丁丁出行记", url: urlToOpen, description: "这是程序MomentsLocation界面", mediaType: SSPublishContentMediaTypeImage)
        let container = ShareSDK.container()
        //container.setIPadContainerWithView(sender, arrowDirect: UIPopoverArrowDirection.Up)
        ShareSDK.showShareActionSheet(container, shareList: nil, content: publishContent, statusBarTips: true, authOptions: nil, shareOptions: nil, result: {
            (type , state , statusInfo , error , end) in
            
        })
    }
    
    //MARK:- tableview DataSouce
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.backgroundColor = UIColor(red: 138/255, green: 160/255, blue: 60/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.whiteColor()
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

}
