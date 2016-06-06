//
//  ConfessionViewController.swift
//  GeoConfess
//
//  Created by MobileGod on 4/6/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

/// Controls the first screen of the priest spots setup workflow.
final class PriestSpotsViewController: AppViewControllerWithToolbar {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

    @IBAction func iAmMobileTapped(sender: UIButton) {
        //confessionButton.setBackgroundImage(UIImage(named: "disponible"), forState: .Normal)
        showProgressHUD()
		
		let userCoordinate = User.current.location!.coordinate
		
        var spot = [String: AnyObject]()
        spot["name"] = User.current.name
        spot["activity_type"] = "dynamic"
        spot["latitude"]  = userCoordinate.latitude
        spot["longitude"] = userCoordinate.longitude
        
        var params = [String : AnyObject]()
        params["access_token"] = User.current.oauth.accessToken
        params["spot"] = spot
        
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setValue(userCoordinate.latitude,  forKeyPath: "old_latitude")
		defaults.setValue(userCoordinate.longitude, forKeyPath: "old_longitude")
		
        APICalls.sharedInstance.createSpot(params) { (response, error) in
			if error == nil {
                let dict = response as! NSDictionary
				defaults.setValue(dict["activity_type"], forKeyPath: "activity_type")
                defaults.setValue(dict["id"], forKeyPath: "spotID")
				self.performSegueWithIdentifier("showMap", sender: self)
            } else {
				logError("Creating spot failed: \(error)")
            }
			self.dismissProgressHUD()
        }
    }
}
