//
//  Notification.swift
//  GeoConfess
//
//  Created by Admin on 25/04/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

final class Notification {

	var id: Int64!
    var unread: Bool!
    var model: String!
    var action: String!
    var content: AnyObject!
    
    func loadDictionary(d: NSDictionary) {
        self.id = Int64(d["id"] as! String)!
        self.unread = (d["unread"] as! NSNumber).boolValue
        self.model = d["model"] as! String
        self.action = d["action"] as! String

        if model == NotificationModel.MeetRequestModel {
            let notificationInfo = d["meet_request"] as! NSDictionary
            
            let priestInfo = notificationInfo["priest"] as! NSDictionary
            let penitentInfo = notificationInfo["penitent"] as! NSDictionary

            let priest = Priest(id: UInt64(priestInfo["id"] as! String)!,
                                name: priestInfo["name"] as? String,
                                surname: priestInfo["surname"] as? String)
			
			let penitent = Penitent(id: UInt64(penitentInfo["id"] as! String)!,
                                    name: penitentInfo["name"] as! String,
                                    surname: penitentInfo["surname"] as! String,
                                    latitude: penitentInfo["latitude"] as! String,
                                    longitude: penitentInfo["longitude"] as! String)
            
            content = MeetRequestNotification(id: Int64(notificationInfo["id"] as! String),
                                              status: notificationInfo["status"] as! String,
                                              penitent: penitent,
                                              priest: priest) as! AnyObject
        } else if model == NotificationModel.MessageModel {
            preconditionFailure("Not implemented")
        }
    }
    
	func markNotificationAsRead() {
        //let userEmail = self.emailTextField.text!
		let URL = NSURL(string: "https://geoconfess.herokuapp.com/api/v1/notifications/\(self.id)" +  "?access_token=" + User.current.oauth.accessToken)
		NSLog(String(URL))
        
		Alamofire.request(.PUT, URL!, parameters: nil).responseJSON { response in
			NSLog(String(response.response!.statusCode))
			
			switch response.result {
			case .Success(let data):
				
				let jsonResult = JSON(data)
				let result = jsonResult["result"].string
				if result == "success" {
					NSLog("marked notification as read")
				} else {
					NSLog("failed to makr notification as read")
				}
				
			case .Failure(let error):
				print("Request Failed Reason: \(error)")
			}
        }
    }
}
