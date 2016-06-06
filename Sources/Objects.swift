//
//  Objects.swift
//  GeoConfess
//
//  Created by MobileGod on 4/6/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import Foundation
import SwiftyJSON

struct NotificationModel {
    static let MeetRequestModel = "MeetRequest"
    static let MessageModel = "Message"
}

struct Priest {
    
    let id: UInt64
    let name: String?
    let surname: String?
    
    init(id: UInt64, name: String?, surname: String?) {
        self.id      = id
        self.name    = name
        self.surname = surname
    }
	
	init(fromJSON json: [String: JSON]) {
		self.id      = json["id"]!.uInt64!
		self.name    = json["name"]?.string
		self.surname = json["surname"]?.string
	}
}

struct Penitent {
	
    let id: UInt64
    let name : String
    let surname: String
    let location: CLLocationCoordinate2D
	
    init(id: UInt64, name: String, surname: String, latitude: String, longitude: String) {
        self.id = id
        self.name = name
        self.surname = surname
        self.location = CLLocationCoordinate2D(
			latitude:  CLLocationDegrees(latitude)!,
			longitude: CLLocationDegrees(longitude)!)
    }
}

struct Recurrence {
    
    var id: Int64!
    var spot_id: Int64!
    var start_at: String!
    var stop_at: String!
    var date: String?
    var week_days: [String]?
    
    init(id: Int64!, spot_id: Int64!, start_at: String!, stop_at: String!, date: String?, week_days: [String]?){
        
        self.id = id
        self.spot_id = spot_id
        self.start_at = start_at
        self.stop_at = stop_at
        self.date = date
        self.week_days = week_days
    }
}

// TODO: Should this really be a *struct*?

// TODO: All fields are optionals -- we can do better.

struct Spot {
    
    var id: Int64!
    var name: String!
    var activity_type: String! // TODO: This should be an *enum*.
    var latitude: Double?
    var longitude: Double?
    var street: String?
    var postcode: String?
    var city: String?
    var state: String?
    var country: String?
    var priest: Priest!
    var recurrences: [JSON]
    
    init(id: Int64!,        name: String!,      activity_type: String!, latitude: Double?,  longitude: Double?,
         street: String?,   postcode: String?,  city: String?,          state: String?,     country: String?,
         priest: Priest!,   recurrences: [JSON]){
        
        self.id = id
        self.name = name
        self.activity_type = activity_type
        self.latitude = latitude
        self.longitude = longitude
        self.street = street
        self.postcode = postcode
        self.city = city
        self.state = state
        self.country = country
        self.priest = priest
        self.recurrences = recurrences
    }
    
    func getInfo() -> String {
        if self.recurrences.count == 0 {
            return ""
        }
        
        let recurrence = self.recurrences.first!
        var info: String = recurrence["start_at"].stringValue + "~" + recurrence["stop_at"].stringValue + ", "
        
        if recurrence["date"].stringValue != "" {
            info = info + recurrence["date"].stringValue + ", "
        } else {
            let arrWeekdays = recurrence["week_days"].arrayValue
            for weekday in arrWeekdays{
                info = info + weekday.stringValue + ", "
            }
        }
        
        if info.characters.count > 2 {
            info = info.substringToIndex(info.endIndex.advancedBy(-2))
        }
        return info
    }
}

struct Church {
    
    var id: Int64!
    var name: String!
    var latitude: Double!
    var longitude: Double!
    var street: String!
    var postCode: String!
    var city: String!
    var state: String!
    var country: String!
    
    init(id: Int64, name: String, latitude: Double, longitude: Double, street: String, postCode: String, city: String, state: String, country: String){
        
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.street = street
        self.postCode = postCode
        self.city = city
        self.state = state
        self.country = country
    }
}

struct MeetRequestNotification {
    var id: Int64!
    var status: String!
    var penitent: Penitent!
    var priest: Priest!
    
    init(id: Int64!, status: String!, penitent: Penitent!, priest: Priest!) {
        self.id = id
        self.status = status
        self.penitent = penitent
        self.priest = priest
    }
}
