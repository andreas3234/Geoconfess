//
//  MobilePriestViewController.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/6/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import GoogleMaps

final class MobilePriestViewController: AppViewControllerWithToolbar,
	GMSMapViewDelegate {
	
	@IBOutlet weak private var map: GMSMapView!
	@IBOutlet weak private var myLocationButton: UIButton!
	
	let currentLocation = NSLocationTracker.sharedLocationManager().location?.coordinate
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		priestAvailabilityButton.addTarget(
			self, action: #selector(self.availableButtonTapped),
			forControlEvents: .TouchUpInside)
		
		// TODO: This idiom is fishy. We can do better.
		priestAvailabilityButton.setImage(
			UIImage(named: "disponible"), forState: .Normal)
		
		// GPS alert.
		showAlert(message:
			"Merci d'avoir activé la géolocalisation! Vous recevrez une notification " +
			"dès qu'un pénitent vous enverra une demande de confession.")
        
        // Map setup.
        map.myLocationEnabled = true
        map.settings.myLocationButton = false
        map.delegate = self
        map.camera = GMSCameraPosition(at: currentLocation!)
		
        // KVO.
        NSNotificationCenter.defaultCenter().addObserver(
			self, selector: #selector(self.locationUpdated(_:)),
			name: "locationUpdated", object: nil)
    }
    
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	// MARK: - 
	
	func localize() {
		map.camera = GMSCameraPosition(at: currentLocation!)
	}
	
    /// When recieved the local notification that notifies "locationUpdated".
    @objc private func locationUpdated(notification: NSNotification!) {
        // Get current location of user from location tracker and store it.
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setValue(currentLocation?.latitude,  forKeyPath: "old_latitude")
        defaults.setValue(currentLocation?.longitude, forKeyPath: "old_longitude")

        // Update map view..
        map.camera = GMSCameraPosition(at: currentLocation!)
		map.myLocationEnabled = true
		map.settings.myLocationButton = false

        // Get information of the spot of priest.
        let spotID = NSUserDefaults.standardUserDefaults().stringForKey("spotID")
        var spot = [String: AnyObject]()
        spot["latitude"]  = currentLocation?.latitude
        spot["longitude"] = currentLocation?.longitude
        
        // Make parameters.
        var params = [String : AnyObject]()
        params["access_token"] = User.current.oauth.accessToken
        params["spot"] = spot
        
        print("Paramter: \(params)")
        
        // Call updatedSpot api.
        APICalls.sharedInstance.updateSpot(params, spot_id: spotID!) { (error) in
			if error == nil {
				log("Updating Spot Success!\n")
            } else {
                log("Updating Spot Failed!\n")
				self.showAlert(message: "Updating spot failed!")
            }
        }
    }
    
    @IBAction func availableButtonTapped(sender: UIButton) {
        priestAvailabilityButton.setImage(
			UIImage(named: "indisponible"), forState: .Normal)
        Utility.showAlertWithDismissVC(
			"", message: "Géolocalisation désactivée. Merci d'avoir utilisé Geooconfess!",
			vc: self)
        
        // Stop location tracking.
        User.current.locationTracker.stopUpdatingLocation()
        
        // Prepare parameters of deleteSpot api call.
        let spotID = NSUserDefaults.standardUserDefaults().stringForKey("spotID")
        var params = [String : AnyObject]()
        params["access_token"] = User.current.oauth.accessToken
        print("Paramter: \(params)")
        
        // Call deleteSpot api.
		APICalls.sharedInstance.deleteSpot(params, spot_id: spotID!) { (error) in
            if error == nil {
                log("Deleting spot success!")
            } else {
                logError("Deleting spot failed!")
				self.showAlert(message: "Deleting spot failed!")
            }
        }
    }
}
