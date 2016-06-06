//
//  BookingRequestPendingPriestVC.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/17/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

final class BookingRequestPendingPriestVC: BookingViewController {
	
    @IBOutlet weak private var lblPriestName: UILabel!
    @IBOutlet weak private var lblStatus: UILabel!
    @IBOutlet weak private var lblDistance: UILabel!
	
	@IBOutlet weak private var btnPending: UIButton!
	@IBOutlet weak private var btnFavoris: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Up a back button...
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "Back Button"), forState: .Normal)
        button.frame = CGRectMake(0, 0, 30, 30)
        button.addTarget(self, action: #selector(BookingRequestPriestVC.onBack),
                         forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
		
		btnPending.enabled = false
        
        // Set string values...2
        lblPriestName.text = thisSpotData["priest"]!["surname"]
        lblDistance.text = String(format: "à %d mètres",
                                  integer_t(self.calculateDistance()))
    }
    
    func onBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// Calculate distance from user to priest.
    func calculateDistance() -> CLLocationDistance {
        let user   = User.current.location!
        let priest = CLLocation(latitude:  thisSpotData["latitude"]!.doubleValue,
                                longitude: thisSpotData["longitude"]!.doubleValue)
        return user.distanceFromLocation(priest)
    }
	
	@IBAction func favorisBtnTapped(sender: AnyObject) {
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
			self.btnFavoris.enabled = false
		}
	}
}