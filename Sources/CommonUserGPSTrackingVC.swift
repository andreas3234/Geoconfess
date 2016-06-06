//
//  CommonUserGPSTrackingVC.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/13/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import SideMenu

final class CommonUserGPSTrackingVC: AppViewControllerWithToolbar,
	GMSMapViewDelegate, UserLocationObserver,
	UIPopoverPresentationControllerDelegate {
	
	@IBOutlet weak private var map: GMSMapView!
	
	private var spotArray = NSMutableArray()
	private var spotsRefreshTimer: Timer!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		precondition(User.current != nil)
		
		// Create Side Menu.
        createMenu()
		
		// Load Information of Spots.
        loadSpots()

		// TODO: This is technically a hack to hide this button.
		priestAvailabilityButton.hidden = true

        // Setup Location Button.
        let locationButton = UIButton(type: .Custom)
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        locationButton.setImage(UIImage(named: "localiser-on"), forState: .Normal)
        locationButton.frame = CGRectMake(screenSize.width - 80, screenSize.height - 150, 50, 50)
        locationButton.addTarget(self, action: #selector(CommonUserGPSTrackingVC.localize),
                                 forControlEvents: .TouchUpInside)
        view.addSubview(locationButton)
    }
	
	private var locationUnknown = true
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let user = User.current!
		
		// Map setting.
		map.myLocationEnabled = true
		map.settings.myLocationButton = false
		map.delegate = self
		
		if let location = user.location {
			map.camera = GMSCameraPosition(at: location.coordinate)
			locationUnknown = false
		} else {
			locationUnknown = true
		}
		user.addLocationObserver(self)
		
		spotsRefreshTimer = Timer.scheduledTimerWithTimeInterval(120, repeats: true) {
			self.loadSpots()
		}
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		// TODO: This is related to logoff
		if let user = User.current {
			user.removeLocationObserver(self)
		}
		
		spotsRefreshTimer?.dispose()
	}

    func localize() {
		guard let location = User.current.location else { return }
        map.animateToCameraPosition(GMSCameraPosition(at: location.coordinate))
    }
    
    // MARK: - Main Menu
    
    internal var menuButton: UIButton!
    private var menuController: OldMenuViewController!
    private var sideMenuController: UISideMenuNavigationController!
    
    // Create a side menu...
    private func createMenu() {
        menuButton = UIButton(type: .Custom)
        menuButton.frame = rect(0, 0, 33, 23)
        menuButton.setImage(UIImage(named: "menu_icon"), forState: .Normal)
        menuButton.addTarget(
            self,
            action: #selector(MainViewController.menuButtonTapped(_:)),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        
        let mainMenuItem = UIBarButtonItem(customView: menuButton)
        navigationItem.setLeftBarButtonItem(mainMenuItem, animated: true)
        navigationController.navigationBar.barTintColor = UIColor.whiteColor()
        
        MenuViewController.createOn(mainController: self)
    }
    
    // Action of menu button.
    func menuButtonTapped(sender: UIButton) {
        assert(sender === menuButton)
        presentViewController(SideMenuManager.menuLeftNavigationController!,
                              animated: true, completion: nil)
    }
    
    //Building menu...
    func setMenuVisible(visible: Bool) {
        let screen = UIScreen.mainScreen().bounds
        let animationDurationInSeconds = 0.3
        // TODO: Review this code!
        
        if visible {
            menuController = OldMenuViewController.instantiateViewControllerForCommonUserGPSTrackingVC(self)
            view.addSubview(menuController.view)
            addChildViewController(menuController)
            menuController.view.layoutIfNeeded()
            
            let menuView = menuController.view
            menuView.frame = rect(0 - screen.width, 0, screen.width, screen.height)
            menuButton.enabled = false
            UIView.animateWithDuration(
                animationDurationInSeconds,
                animations: {
                    menuView.frame = rect(0, 0, screen.width, screen.height)
                    self.menuButton.enabled = true
                },
                completion: {
                    finished  in
                    /* empty */
                }
            )
        } else {
            UIView.animateWithDuration(
                animationDurationInSeconds,
                animations: {
                    self.menuController.view.frame.origin.x = -screen.width
                    self.menuController.view.layoutIfNeeded()
                    self.menuController.view.backgroundColor = UIColor.clearColor()
                },
                completion: {
                    finished  in
                    self.menuController.view.removeFromSuperview()
                    self.menuController.removeFromParentViewController()
                    self.menuController = nil
                }
            )
        }
    }
    
    /// Loading **spots** information.
    private func loadSpots() {
		guard let coordinate = User.current.location?.coordinate else { return }
		
        // Prepare parameters of listSpots api call.
        var params = [String : AnyObject]()
        
        params["access_token"] = User.current.oauth.accessToken
        params["now"] = 0
        params["lat"] = coordinate.latitude
        params["lng"] = coordinate.longitude
        params["distance"] = 20
        
		// Call listSpots api.
        APICalls.sharedInstance.listSpots(params) { (response, error) in
			guard error == nil else {
				logError("Listing spots failed: \(error)")
				self.showAlert(message: "Listing spot failed!")
				return
			}
			if response?.count > 0 {
				// Spots array.
				self.spotArray = (response as! NSMutableArray)
				self.setUpLocationMarkers()
			}
        }
    }
    
    /// Sets up location markers.
    func setUpLocationMarkers() {
		for spot in spotArray {
			let dic = spot as! NSDictionary
			// Get location of spot.
			let coordinate = CLLocationCoordinate2D(latitude: (dic["latitude"]?.doubleValue)!, longitude: (dic["longitude"]?.doubleValue)!)
			
			// Location marker setting...
			let locationMarker: GMSMarker!
			locationMarker = GMSMarker(position: coordinate)
			locationMarker.appearAnimation = kGMSMarkerAnimationPop
			locationMarker.map = self.map
			locationMarker.userData = dic
			
			if (dic["activity_type"])! as! String == "dynamic" {
				// If the spot is for *priest*.
				let priestIcon = UIImage(named: "cible-deplacement")!.imageWithRenderingMode(.Automatic)
				locationMarker.icon = priestIcon
			} else if (dic["activity_type"])! as! String == "static" {
				// If the spot is for *church*.
				let churchIcon = UIImage(named: "cible-statique")!.imageWithRenderingMode(.Automatic)
				locationMarker.icon = churchIcon
			}
		}
    }
    
    /// GMSMapView delegate.
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if marker.userData!["activity_type"] == "dynamic" {
			// If this spot is for priest...
            
            var params = [String : AnyObject]()
            params["access_token"] = User.current.oauth.accessToken
            params["party_id"] = marker.userData!["priest"]!["id"]
            
            APICalls.sharedInstance.allRequestsOfCurrentUser(params) { (response, error) in
                // Getting request information against this priest.
				guard error == nil else {
					log("Showing Request Failed!")
					self.showAlert(message: "Showing request failed!")
					return
				}
				log("Showing Request Success!")
				print(response)
				
				let nextViewController: String
				if response!.count == 0 {
					// If there is no pending, accepted 
					// or refused request to this priest.
					nextViewController = "BookingRequestPriestVC"
				} else {
					let dict = response!.objectAtIndex(0) as! NSDictionary
					switch dict["status"] as! String {
					case "pending", "refused":
						nextViewController = "BookingRequestPendingPriestVC"
					case "accepted":
						nextViewController = "BookingAcceptedPriestVC"
					default:
						preconditionFailure("unexpected status")
					}
				}
				let popoverContent = self.storyboard!
					.instantiateViewControllerWithIdentifier(nextViewController)
					as! BookingViewController
				popoverContent.thisSpotData = marker.userData as! NSDictionary
				self.navigationController!.pushViewController(popoverContent,
				                                              animated: true)
            }
        }
        else if marker.userData!["activity_type"] == "static" {
            let popoverContent = self.storyboard?
				.instantiateViewControllerWithIdentifier("BookingRequestChurchVC")
				as! BookingRequestChurchVC
            popoverContent.thisSpotData = marker.userData as! NSDictionary
            self.navigationController?.pushViewController(popoverContent, animated: true)
        }
        
        return true
    }
	
	// MARK: - User Location Observer
	
	func user(user: User, didUpdateLocation location: CLLocation) {
		let coordinate = location.coordinate
		
		// Get current location of user from location tracker and store it.
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setValue(coordinate.latitude,  forKeyPath: "old_latitude")
		defaults.setValue(coordinate.longitude, forKeyPath: "old_longitude")
		
		// Update map view.
		if locationUnknown {
			map.clear()
			map.camera = GMSCameraPosition(at: coordinate)
			map.myLocationEnabled = true
			map.settings.myLocationButton = false
			locationUnknown = false
		}
	}
}
