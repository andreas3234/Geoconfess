//
//  File.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/19/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let cellID = "NotificationCell"

final class NotificationListVC: AppViewControllerWithToolbar, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tblNotificationList: UITableView!
    
    var arrayNotifications: Array<Notification> = []

    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        makeInterface()
    }
 
    func makeInterface() {
        tblNotificationList.delegate = self
        tblNotificationList.dataSource = self
        
        tblNotificationList.tableFooterView = UIView()
        tblNotificationList.backgroundColor = UIColor.whiteColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotifications()
    }
    
	func getNotifications()
	{
		//Make parameters.
		var params = [String : AnyObject]()
		params["access_token"] = User.current.oauth.accessToken
		
		MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		
		//Call get notification list API
		APICalls.sharedInstance.actualNotificationsOfCurrentUser(params) { (response, error) in
			guard error == nil else {
				logError("Getting notifications failed!")
				self.showAlert(message: "Getting notifications failed!")
				return
			}
			log("Getting notifications successfully!")
			print(response)
			let dicArray = response as! NSArray
			var i: Int = 0
			for dic in dicArray{
				let element = Notification()
				element.loadDictionary(dic as! NSDictionary)
				self.arrayNotifications.insert(element, atIndex: i)
				i = i + 1
			}
			MBProgressHUD.hideHUDForView(self.view, animated: true)
		}
    }

    // MARK: - Table View Methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 61
    }
	
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNotifications.count
    }
	
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! NotificationCell

        let notification: Notification = arrayNotifications[indexPath.row]
        
        cell.isViewed = !notification.unread
        
        if notification.unread == true {
            notification.markNotificationAsRead()
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification: Notification = arrayNotifications[indexPath.row]

		switch User.current.role {
		case .Priest:
			if (notification.content as! MeetRequestNotification).status == "pending" {
				//user lands on screen - booking request
			}
			else if (notification.content as! MeetRequestNotification).status == "refused" {
				//remove from notification
			} else {
				//user lands on chat
			}
		case .User, .Admin:
            if (notification.content as! MeetRequestNotification).status == "pending" {
                //user lands on priest page for pending request
            } else if (notification.content as! MeetRequestNotification).status == "refused" {
                //user lands on priest page for refused request
            } else {
                //user lands on chat
            }
        }
    }
}
