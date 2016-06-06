//
//  APICalls.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 01.02.16.
//  Copyright © 2016 Christian Dimitrov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

final class APICalls {
	
    let baseURL = App.serverAPI
    
    class var sharedInstance: APICalls {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: APICalls? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = APICalls()
        }
        
        return Static.instance!
    }
    
/*
*---------------------------------------- SPOTs -----------------------------------------------*/
    
    // Create Spot
    func createSpot(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Creates spot. For admin and priest only. Returns code 201 with spot data if spot successfully created.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/spots/create.html
        
        let url = self.baseURL + "/spots"
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                log("result: \(response.result)")
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Create spot error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    // Delete Spot
    func deleteSpot(params: [String : AnyObject]!, spot_id: String, completion: (error: NSError?) -> Void)
    {
        // TODO: Destroys spot. For priest only. Returns code 200 with no content if spot successfully destroyed.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/spots/destroy.html

        let url = self.baseURL + "/spots/" + spot_id;
        Alamofire.request(.DELETE, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(error: nil)
            case .Failure(let error):
                logError("Delete spot error: \(error)")
                completion(error: error)
            }
        }
    }
    
    // Update Spot
    func updateSpot(params: [String : AnyObject]!, spot_id: String, completion: (error: NSError?) -> Void)
    {
        // TODO: Updates spot data. For priest only. Returns code 200 and {result: “success”} if spot successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/spots/update.html

        let url = self.baseURL + "/spots/" + spot_id
		
        Alamofire.request(.PATCH, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(error: nil)
            case .Failure(let error):
                logError("Update spot error: \(error)")
                completion(error: error)
            }
        }
    }
    
    // Update Spot
    func updateSpot_put(params: [String : AnyObject]!, spot_id: String, completion: (error: NSError?) -> Void)
    {
        // TODO: Updates spot data. For priest only. Returns code 200 and {result: “success”} if spot successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/spots/update.html
        
        let url = self.baseURL + "/spots/" + spot_id
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(error: nil)
            case .Failure(let error):
                logError("Update spot error: \(error)")
                completion(error: error)
            }
        }
    }
    
    // Get Spots list.
    func listSpots(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: List of all spots.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/spots/index.html

        let url = self.baseURL + "/spots"
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success(let value):
                completion(response: value, error: nil)
            case .Failure(let error):
                logError("List spot error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    // Show Spot
    func showSpot(params: [String : AnyObject]!, spot_id: String, completion: (error: NSError?) -> Void)
    {
        // TODO: Show spot with certain ID
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/spots/show.html

        let url = self.baseURL + "/spots/" + spot_id
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(error: nil)
            case .Failure(let error):
                logError("Show spot error: \(error)")
                completion(error: error)
            }
        }
    }
    
    // My spots
    func mySpots(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: List of all spots of current user (priest only).
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/spots/me_spots_stub.html

        let url = self.baseURL + "/me/spots"
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success(let value):
                log("result: \(response.result)")
                completion(response: value, error: nil)
            case .Failure(let error):
                logError("List spot error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- MEET REQUESTS -----------------------------------------------*/
    
    //Show Request
    func showRequest(params: [String : AnyObject]!, request_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Show request with certain ID. Extended information about penitent available for priest only. Extended information about priest available for penitent only.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/show.html

        let url = self.baseURL + "/requests/" + request_id;
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Show request error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //All Requests of Current User
    func allRequestsOfCurrentUser(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: All active requests where priest_id or penitent_id equal to current_user.id. Extended information about penitent available for priest only. Extended information about priest available for penitent only.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/index.html

        let url = self.baseURL + "/requests";
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Get all requests error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Create and send request
    func createRequest(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Creates request Returns code 201 with request data if request successfully created.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/create.html

        let url = self.baseURL + "/requests";
        
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Create request error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update Request
    func updateRequest(params: [String : AnyObject]!, request_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates request data Returns code 200 and {result: “success”} if request successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/update.html

        let url = self.baseURL + "/requests/" + request_id;
        
        Alamofire.request(.PATCH, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update request error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update Request
    func updateRequest_put(params: [String : AnyObject]!, request_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates request data Returns code 200 and {result: “success”} if request successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/update.html
        
        let url = self.baseURL + "/requests/" + request_id;
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update request error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Destroy Request
    func destroyRequest(params: [String : AnyObject]!, request_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Destroys request Returns code 200 with no content if request successfully destroyed.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/destroy.html

        let url = self.baseURL + "/requests/" + request_id;
        
        Alamofire.request(.DELETE, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Destroy request error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Accept Request
    func acceptRequest(params: [String : AnyObject]!, request_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Sets status to accepted Returns code 200 with no content if request successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/accept.html

        let url = self.baseURL + "/requests/" + request_id + "accept";
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Accept request error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Refuse Request
    func refuseRequest(params: [String : AnyObject]!, request_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Sets status to refused Returns code 200 with no content if request successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/meet_requests/refuse.html

        let url = self.baseURL + "/requests/" + request_id + "refuse";
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Refuse request error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- FAVORITES -----------------------------------------------*/
    
    //All favorites of Current User
    func getUserFavorites(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: All favorites of current_user.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/favorites/index.html

        let url = self.baseURL + "/favorites";
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Get all favorites error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Create favorite
    func createFavorite(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Add priest to favorites Returns code 201 with favorite data if favorite successfully created.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/favorites/create.html

        let url = self.baseURL + "/favorites";
        
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Add favorite error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Destroy favorite
    func destroyFavorite(params: [String : AnyObject]!, priest_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Remove priest from favorites Returns code 200 with no content if favorite successfully destroyed.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/favorites/destroy.html

        let url = self.baseURL + "/favorites/" + priest_id;
        
        Alamofire.request(.DELETE, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Delete favorite error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- MESSAGES -----------------------------------------------*/
    
    //All messages of current user
    func allMessagesFromCurrentUser(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: All messages where sender_id or recipient_id equal to current_user.id
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/messages/index.html
        
        let url = self.baseURL + "/messages";
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Get all messages error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Show message
    func showMessage(params: [String : AnyObject]!, message_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Show message with certain ID.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/messages/show.html
        
        let url = self.baseURL + "/messages/" + message_id;
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Show message error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Create message
    func createMessage(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Creates message Returns code 201 with no content if message successfully created.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/messages/create.html
        
        let url = self.baseURL + "/messages";
        
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Create message error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update message
    func updateMessage(params: [String : AnyObject]!, message_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates message data Returns code 200 and {result: “success”} if message successfully updated.

        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/messages/update.html
        
        let url = self.baseURL + "/messages/" + message_id;
        
        Alamofire.request(.PATCH, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update message error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update message
    func updateMessage_put(params: [String : AnyObject]!, message_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates message data Returns code 200 and {result: “success”} if message successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/messages/update.html
        
        let url = self.baseURL + "/messages/" + message_id;
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update message error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Destroy message
    func destroyMessage(params: [String : AnyObject]!, message_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Destroys message Returns code 200 with no content if message successfully destroyed.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/messages/destroy.html
        
        let url = self.baseURL + "/messages/" + message_id;
        
        Alamofire.request(.DELETE, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Destroy message error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- USERS -----------------------------------------------*/
    
    //Show user
    func showUser(params: [String : AnyObject]!, user_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Show user data.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/users/show.html
        
        let url = self.baseURL + "/users/" + user_id;
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Show user error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update user
    func updateUser(params: [String : AnyObject]!, user_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates user data Returns code 200 and {result: “success”} if user successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/users/update.html
        
        let url = self.baseURL + "/users/" + user_id;
        
        Alamofire.request(.PATCH, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update user error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update user
    func updateUser_put(params: [String : AnyObject]!, user_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates user data Returns code 200 and {result: “success”} if user successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/users/update.html
        
        let url = self.baseURL + "/users/" + user_id;
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update user error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Destroy user
    func destroyUser(params: [String : AnyObject]!, user_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Destroys the user with all associated spots Returns code 200 with no content if user successfully destroyed.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/users/destroy.html
        
        let url = self.baseURL + "/users/" + user_id;
        
        Alamofire.request(.DELETE, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Destroy user error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Activate user
    func activateUser(params: [String : AnyObject]!, user_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Sets user.active to true Returns code 200 with no content if user successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/users/activate.html
        
        let url = self.baseURL + "/users/" + user_id + "/activate";
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Activate user error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Deactivate user
    func deactivateUser(params: [String : AnyObject]!, user_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Sets user.active to false Returns code 200 with no content if user successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/users/deactivate.html
        
        let url = self.baseURL + "/users/" + user_id + "/deactivate";
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Deactivate user error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- REGISTRATIONS -----------------------------------------------*/
    
    //Register user
    func registerUser(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Users registration Returns code 201 and {result: “success”} if user successfully created and errors otherwise.

        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/registrations/create.html
        
        let url = self.baseURL + "/registrations";
        
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Registration user error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- NOTIFICATIONS -----------------------------------------------*/
    
    //Actual notifications of current user
    func actualNotificationsOfCurrentUser(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Last 99 notifications of current user not older than 1 month.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/notifications/index.html
        
        let url = self.baseURL + "/notifications";
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Get notifications error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Show notification
    func showNotification(params: [String : AnyObject]!, notification_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Show notification by ID.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/notifications/show.html
        
        let url = self.baseURL + "/notifications/" + notification_id;
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Show notification error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Mark notification as read
    func markNotificationAsRead(params: [String : AnyObject]!, notification_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Mark notification by ID as read. Returns code 200 with no content if notification successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/notifications/mark_read.html
        
        let url = self.baseURL + "/notifications/" + notification_id + "/mark_read";
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Mark notification error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- PASSWORDS -----------------------------------------------*/
    
    //Send reset password instructions.
    func sendResetPasswordInstructions(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Sends reset password instruction on given email address. Returns code 201 if passwords instructions email successfully sent. Returns code 404 if user with given email doesn’t exist. Returns code 400 if email doesn’t present.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/passwords/create.html
        
        let url = self.baseURL + "/passwords";
        
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Send reset password instructions error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
/*
*---------------------------------------- RECURRENCES -----------------------------------------------*/
    
    //Recurrences list
    func recurrencesList(params: [String : AnyObject]!, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: All available recurrences for this spot.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/index.html
        
        let url = self.baseURL + "/recurrences";
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Get recurrences list error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Recurrences list
    func recurrencesListFromSpots(params: [String : AnyObject]!, spot_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: All available recurrences for this spot.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/index.html
        
        let url = self.baseURL + "/spots/" + spot_id + "/recurrences";
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Get recurrences list error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Show Recurrence
    func showRecurrence(params: [String : AnyObject]!, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Show recurrence with certain ID.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/show.html
        
        let url = self.baseURL + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Show recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Show Recurrence
    func showRecurrenceFromSpot(params: [String : AnyObject]!, spot_id: String, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Show recurrence with certain ID.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/show.html
        
        let url = self.baseURL + "/spots/" + spot_id + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Show recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Create Recurrence
    func createRecurrence(params: [String : AnyObject]!, spot_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Creates recurrence. For admin and priest only. Returns code 201 with recurrence data if recurrence successfully created.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/create.html
        
        let url = self.baseURL + "/spots/" + spot_id + "/recurrences";
        
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Create recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update Recurrence
    func updateRecurrenceFromSpots(params: [String : AnyObject]!, spot_id: String, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates recurrence data. For admin and priest only. Returns code 200 and {result: “success”} if recurrence successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/update.html
        
        let url = self.baseURL + "/spots/" + spot_id + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.PATCH, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update Recurrence
    func updateRecurrenceFromSpots_put(params: [String : AnyObject]!, spot_id: String, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates recurrence data. For admin and priest only. Returns code 200 and {result: “success”} if recurrence successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/update.html
        
        let url = self.baseURL + "/spots/" + spot_id + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update Recurrence
    func updateRecurrence(params: [String : AnyObject]!, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates recurrence data. For admin and priest only. Returns code 200 and {result: “success”} if recurrence successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/update.html
        
        let url = self.baseURL + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.PATCH, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Update Recurrence
    func updateRecurrence_put(params: [String : AnyObject]!, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Updates recurrence data. For admin and priest only. Returns code 200 and {result: “success”} if recurrence successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/update.html
        
        let url = self.baseURL + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Destroy Recurrence
    func destroyRecurrence(params: [String : AnyObject]!, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Destroys recurrence. For priest and admin only. Returns code 200 with no content if recurrence successfully destroyed.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/destroy.html
        
        let url = self.baseURL + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.DELETE, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Destroy recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Destroy Recurrence
    func DestroyRecurrenceFromSpots(params: [String : AnyObject]!, spot_id: String, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Destroys recurrence. For priest and admin only. Returns code 200 with no content if recurrence successfully destroyed.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/destroy.html
        
        let url = self.baseURL + "/spots/" + spot_id + "/recurrences/" + recurrence_id;
        
        Alamofire.request(.DELETE, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Destroy recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Recurrences of the priest
    func recurrencesOfPriest(params: [String : AnyObject]!, priest_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: All recurrences for passed priest.

        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/for_priest.html
        
        let url = self.baseURL + "/recurrences/for_priest/" + priest_id;
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Update recurrence error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
    
    //Confirm priest availability
    func confirmPriestAvailability(params: [String : AnyObject]!, recurrence_id: String, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        // TODO: Confirm priest availability for the recurrence for today. Returns code 200 with no content if recurrence successfully updated.
        
        // The corresponding API is documented here:
        // https://geoconfess.herokuapp.com/apidoc/V1/recurrences/confirm_availability.html
        
        let url = self.baseURL + "/recurrences/" + recurrence_id + "/confirm_availability";
        
        Alamofire.request(.PUT, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                logError("Confirm priest availability error: \(error)")
                completion(response: nil, error: error)
            }
        }
    }
}







// TODO: Remove this in the future?

/// Converts string-ish dictionary to an URL compatible **quey string**.
///
/// For instance, turns this:
///
/// 		["user": "paulo", "pass": 123, "admin":true]
///
/// into this:
///
/// 		"user=paulo&pass=123&admin=true"
///
func urlQueryStringFromDictionary(dict: [String: String]) -> String {
    var query: [String] = []
    for (key, value) in dict {
        query.append("\(key)=\(value)")
    }
    return query.joinWithSeparator("&")
}


