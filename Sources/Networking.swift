//
//  Networking.swift
//  geoconfess
//
//  Created by MobileGod on 4/6/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol GetPirestSpotDelegate {
    
    func getPirestSpotDidSucceed(data: JSON)
    func getPirestSpotDidFail(error:NSError)
}

protocol GetAllSpotsDelegate {
    
    func getAllSpotsDidSucceed(data: JSON)
    func getAllSpotsDidFail(error:NSError)
}

protocol CreateSpotFromMapDelegate {
    
    func  createSpotFromMapDidSucceed(data: JSON)
    func  createSpotFromMapDidFail(error:NSError)
}

protocol DeleteSpotDelegate {
    
    func deleteSpotDidSucceed(data: JSON)
    func deleteSpotDidFail(error:NSError)
}

protocol CreateRecurrentWithDateDelegate{
    
    func createRecurrenceWithDateDidSucceed(data: JSON)
    func createRecurrenceWithDateDidFail(error:NSError)
}

protocol CreateRecurrenceWithWeekDaysDelegate {
    
    func createRecurrenceWithWeekDaysDidSucceed(data: JSON)
    func createRecurrenceWithWeekDaysDidFail(error:NSError)
}

protocol UpdateRecurrenceWithDateDelegate {
    
    func updateRecurrenceWithDateDidSucceed(data: JSON)
    func updateRecurrenceWithDateDidFail(error:NSError)
}

protocol UpdateRecurrenceWithWeekDaysDelegate {
    
    func updateRecurrenceWithWeekDaysDidSucceed(data: JSON)
    func updateRecurrenceWithWeekDaysDidFail(error:NSError)
}

class Networking{
    
    static var getPirestSpotDelegate: GetPirestSpotDelegate?
    static var getAllSpotDelegate: GetAllSpotsDelegate?
    static var createSpotFromMapDelegate: CreateSpotFromMapDelegate?
    static var deleteSpotDelegate: DeleteSpotDelegate?
    static var createRecurrenceWithDateDelegate: CreateRecurrentWithDateDelegate?
    static var createRecurrenceWithWeekDaysDelegate: CreateRecurrenceWithWeekDaysDelegate?
    static var updateRecurrenceWithDateDelegate: UpdateRecurrenceWithDateDelegate?
    static var updateRecurrenceWithWeekDaysDelegate: UpdateRecurrenceWithWeekDaysDelegate?
    
    // Load Pirest`s Spots
    class func loadPirestSpot(){
        
        if let token: String = User.current.oauth.accessToken {
            
            let parameters = ["access_token":token]
        
            let alamofireMethod:Alamofire.Method = .GET
            let link = Constants.spotsLink_Pirest
            Alamofire
                .request(alamofireMethod, Constants.baseURL + link, parameters:parameters,encoding: .URL, headers: nil)
                .response { (request, response, data, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.getPirestSpotDelegate?.getPirestSpotDidFail(error!)
                        return
                    }
                    
                    let  jsonData = JSON(data: data!)
                    print(jsonData)
                    self.getPirestSpotDelegate?.getPirestSpotDidSucceed(jsonData)
            }
        }
    }
    
    // Create Spot from Map
    class func createSpotFromMap(name: String, activity_type: String, latitude: Double, longitude: Double, street: String, postcode: String, city: String, state: String, country: String){
        
        if let token: String = User.current.oauth.accessToken{
            
            let parameters = [
                              "access_token": token,
                              "spot[name]": name,
                              "spot[activity_type]": activity_type,
                              "spot[latitude]": latitude,
                              "spot[longitude]": longitude,
                              "spot[street]": street,
                              "spot[postcode]": postcode,
                              "spot[city]": city,
                              "spot[state]": state,
                              "spot[country]": country
            ]
            
            let alamofireMethod: Alamofire.Method = .POST
            let link = Constants.spotsLink_All
            Alamofire
                .request(alamofireMethod, Constants.baseURL + link, parameters:parameters as? [String : AnyObject],encoding: .URL, headers: nil)
                .response { (request, response, data, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.createSpotFromMapDelegate?.createSpotFromMapDidFail(error!)
                        return
                    }
                    
                    let  jsonData = JSON(data: data!)
                    print(jsonData)
                    self.createSpotFromMapDelegate?.createSpotFromMapDidSucceed(jsonData)
            }
        }
    }
    
    // Delete Spot with id
    class func deleteSpot(id: Int64){
        
        if let token: String = User.current.oauth.accessToken{
            
            let parameters = ["access_token": token]
            let alamofireMethod: Alamofire.Method = .DELETE
            let link = Constants.spotsLink_All + "/\(id)"
            
            Alamofire
                .request(alamofireMethod, Constants.baseURL + link, parameters:parameters,encoding: .URL, headers: nil)
                .response { (request, response, data, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.deleteSpotDelegate?.deleteSpotDidFail(error!)
                        return
                    }
                    
                    let  jsonData = JSON(data: data!)
                    print(jsonData)
                    self.deleteSpotDelegate?.deleteSpotDidSucceed(jsonData)
            }
        }
    }

    class  func createRecurrenceWithDate(spotID: Int64, date: String, start_at: String, stop_at: String){
        
        if let token: String = User.current.oauth.accessToken{
            
            let parameters = ["access_token": token, "recurrence[date]": date, "recurrence[start_at]": start_at, "recurrence[stop_at]": stop_at, "recurrence[week_days]": NSArray()]
            let alamofireMethod: Alamofire.Method = .POST
            let link = Constants.spotsLink_All + "/" + spotID.description + "/" + "recurrences"
            Alamofire
                .request(alamofireMethod, Constants.baseURL + link, parameters:parameters,encoding: .URL, headers: nil)
                .response { (request, response, data, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.createRecurrenceWithDateDelegate?.createRecurrenceWithDateDidFail(error!)
                        return
                    }
                    
                    let  jsonData = JSON(data: data!)
                    print(jsonData)
                    self.createRecurrenceWithDateDelegate?.createRecurrenceWithDateDidSucceed(jsonData)
            }
        }
    }
    
    class func createRecurrence_WeekDays(spotID: Int64, days: NSArray, start_at: String, stop_at: String){
        
        if let token: String = User.current.oauth.accessToken{
            
            let parameters = ["access_token": token, "recurrence[week_days]": days, "recurrence[start_at]": start_at, "recurrence[stop_at]": stop_at, "recurrence[date]": ""]
            let alamofireMethod: Alamofire.Method = .POST
            let link = Constants.spotsLink_All + "/" + spotID.description + "/" + "recurrences"
            Alamofire
                .request(alamofireMethod, Constants.baseURL + link, parameters:parameters,encoding: .URL, headers: nil)
                .response { (request, response, data, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.createRecurrenceWithWeekDaysDelegate?.createRecurrenceWithWeekDaysDidFail(error!)
                        return
                    }
                    
                    let  jsonData = JSON(data: data!)
                    print(jsonData)
                    self.createRecurrenceWithWeekDaysDelegate?.createRecurrenceWithWeekDaysDidSucceed(jsonData)
            }
        }
    }
    
    class func updateRecurrenceWithDate(recurrenceID: Int64, date: String, start_at: String, stop_at: String){
        
        if let token: String = User.current.oauth.accessToken{
            
            let parameters = ["access_token": token, "recurrence[date]": date, "recurrence[start_at]": start_at, "recurrence[stop_at]": stop_at,"recurrence[week_days]": NSArray()]
            let alamofireMethod: Alamofire.Method = .PATCH
            let link = Constants.RecurrenceLink + "/" + recurrenceID.description
            Alamofire
                .request(alamofireMethod, Constants.baseURL + link, parameters:parameters,encoding: .URL, headers: nil)
                .response { (request, response, data, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.updateRecurrenceWithDateDelegate?.updateRecurrenceWithDateDidFail(error!)
                        return
                    }
                    
                    let  jsonData = JSON(data: data!)
                    print(jsonData)
                    self.updateRecurrenceWithDateDelegate?.updateRecurrenceWithDateDidSucceed(jsonData)
            }
        }
    }
    
    class func updateRecurrence_WeekDays(recurrenceID: Int64, days: NSArray, start_at: String, stop_at: String){
        
        if let token: String = User.current.oauth.accessToken{
            
            let parameters = ["access_token": token, "recurrence[start_at]": start_at, "recurrence[stop_at]": stop_at, "recurrence[date]": "", "recurrence[week_days]": days]
            let alamofireMethod: Alamofire.Method = .PATCH
            let link = Constants.RecurrenceLink + "/" + recurrenceID.description
            Alamofire
                .request(alamofireMethod, Constants.baseURL + link, parameters:parameters,encoding: .URL, headers: nil)
                .response { (request, response, data, error) in
                    if error != nil{
                        print(error?.localizedDescription)
                        self.updateRecurrenceWithWeekDaysDelegate?.updateRecurrenceWithWeekDaysDidFail(error!)
                        return
                    }
                    
                    let  jsonData = JSON(data: data!)
                    print(jsonData)
                    self.updateRecurrenceWithWeekDaysDelegate?.updateRecurrenceWithWeekDaysDidSucceed(jsonData)
            }
        }
    }
    
}
