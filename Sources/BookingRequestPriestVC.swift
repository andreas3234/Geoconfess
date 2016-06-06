//
//  BookingRequestPriestVC.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/15/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

class BookingViewController: AppViewControllerWithToolbar {
	
	var thisSpotData: NSDictionary!
}

final class BookingRequestPriestVC: BookingViewController {
	
    @IBOutlet weak private var lblPriestName: UILabel!
    @IBOutlet weak private var lblDistance: UILabel!
    @IBOutlet weak private var bookButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!
	
    override func viewDidLoad() {
		NSUserDefaults.standardUserDefaults().objectForKey("requestsForUser")
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Set Up a back button...
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "Back Button"), forState: .Normal)
        button.frame = CGRectMake(0, 0, 30, 30)
        button.addTarget(self, action: #selector(BookingRequestPriestVC.onBack),
                         forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        // Set string values...
        self.lblPriestName.text = self.thisSpotData["priest"]?["surname"]
        self.lblDistance.text = String(format: "à %d mètres",
                                       integer_t(self.calculateDistance()))
    }
    
    func onBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Calculate distance from user to priest...
    func calculateDistance() -> CLLocationDistance {
        let from = User.current.location!
        let to   = CLLocation(latitude:  thisSpotData["latitude"]!.doubleValue,
                              longitude: thisSpotData["longitude"]!.doubleValue)
		return to.distanceFromLocation(from)
    }
    
    /// Send request to a priest.
    @IBAction func sendRequest(sender: UIButton) {
        // Get information of the request against a priest.
        var request = [String: AnyObject]()
        request["latitude"]  = User.current.location!.coordinate.latitude
        request["longitude"] = User.current.location!.coordinate.longitude
        request["priest_id"] = thisSpotData["priest"]?["id"]
        
        //Make parameters.
        var params = [String : AnyObject]()
        params["access_token"] = User.current.oauth.accessToken
        params["request"] = request
        
        print("Prameters of sendRequest api call:\(params)")
        
        //Call createReqest API
        APICalls.sharedInstance.createRequest(params) { (response, error) in
			guard error == nil else {
				logError("Creating request failed!")
				self.showAlert(message: "Creating request failed!")
				return
			}
			log("Created request successfully!")
			let nextViewController = self.storyboard!
				.instantiateViewControllerWithIdentifier("BookingRequestPendingPriestVC")
				as! BookingRequestPendingPriestVC
			nextViewController.thisSpotData = self.thisSpotData as NSDictionary
			self.navigationController?.pushViewController(nextViewController,
			                                              animated: true)
        }
    }
    
    /// Add a priest to favorite.
    @IBAction func addToFavorite(sender: UIButton) {
        // Create a favorite about a priest.
        var favorite = [String: AnyObject]()
        favorite["priest_id"] = self.thisSpotData["priest"]!["id"]
        
        // Make Parameters.
        var params = [String: AnyObject]()
        params["access_token"] = User.current.oauth.accessToken
        params["favorite"] = favorite
        
        print("Prameters of createFavorite api call:\(params)")
        
        //Call createFavorite API.
        APICalls.sharedInstance.createFavorite(params) { (response, error) in
			guard error == nil else {
				logError("Creating favorite failed!")
				self.showAlert(message: "Creating favorite failed!")
				return
			}
			log("Created favorite successfully!")
			print("SpotData:\(self.thisSpotData)")
			self.showAlert(
				message: "\(self.thisSpotData["name"]!) has been added to favorite!")
			self.favoriteButton.enabled = false
        }
    }
}
