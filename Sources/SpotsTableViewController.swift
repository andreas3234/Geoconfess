//
//  SpotsTableViewController.swift
//  GeoConfess
//
//  Created by MobileGod on 4/6/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit

final class SpotsTableViewController: AppViewControllerWithToolbar,
	UITableViewDelegate, UITableViewDataSource,
	GetPirestSpotDelegate, DeleteSpotDelegate {

    @IBOutlet weak private var tableView: UITableView!
    
    private var spots = [Spot]()
	
	private let arrWeekDays = [
		"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	
	private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Inits UITableView.
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "SpotsTableViewCell", bundle: nil),
                              forCellReuseIdentifier: "SpotsTableViewCell")
		
		// Initiailze delegates.
        Networking.getPirestSpotDelegate = self
        Networking.deleteSpotDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		
		// TODO: We should review this design in the future.
		// Initiailze delegate.
		Networking.getPirestSpotDelegate = self
		Networking.deleteSpotDelegate = self
		loadSpots()
    }
    
    // MARK: - Load Spots
		
	/// Load Spots and reload table.
    private func loadSpots() {
		showProgressHUD()
		spots = []
		Networking.loadPirestSpot()
    }
    
    // MARK: - getPirestSpotDelegate Mothods
    
    func getPirestSpotDidSucceed(data: JSON) {
        dismissProgressHUD()
        
        for spotJSON in data.array! {
			print("--\n\(spotJSON)\n--")
			let spot: Spot!
			if spotJSON["activity_type"].stringValue == "static" {
				let priest: Priest!
				//let priestInData = spotJSON["priest"]
				if let priestJSON = spotJSON["priest"].dictionary {
					priest = Priest(fromJSON: priestJSON)
				} else {
					priest = nil
				}
				
				spot = Spot(id: spotJSON["id"].int64Value,
				            name: spotJSON["name"].stringValue,
				            activity_type: "static",
				            latitude: spotJSON["latitude"].double,
                            longitude: spotJSON["longitude"].double,
                            street: spotJSON["street"].string,
                            postcode: spotJSON["postcode"].string,
                            city: spotJSON["city"].string,
                            state: spotJSON["state"].string,
                            country: spotJSON["country"].string,
                            priest: priest,
                            recurrences: spotJSON["recurrences"].arrayValue)
				
            } else {
                // spot = Spot(id: spotInData["id"].int64Value, name: spotInData["name"].stringValue, church: nil, activity_type: "dynamic", latitude: spotInData["latitude"].double, longitude: spotInData["longitude"].double)
				spot = nil
				continue
            }
			spots.append(spot)
        }
        print(spots)
        tableView.reloadData()
    }
    
    func getPirestSpotDidFail(error: NSError) {
        dismissProgressHUD()
        if error.code == -1003 {
			showAlert(title: "Error",
			          message: "Your internet does not seem to be working.")
        } else {
			showAlert(title: "Error",
			          message: error.localizedDescription)
        }
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
			"SpotsTableViewCell", forIndexPath: indexPath) as! SpotsTableViewCell
        
        cell.lblSpotName.text  = spots[indexPath.row].name
        cell.lblDetail.text = spots[indexPath.row].getInfo()
        cell.btnTrash.tag = Int(spots[indexPath.row].id)
        cell.btnEdit.tag = indexPath.row
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.lblSpotName.textColor = UIColor.darkGrayColor()
            cell.lblDetail.textColor = UIColor.darkGrayColor()
            cell.btnEdit.setImage(UIImage(named: "Pen"), forState: .Normal)
            cell.btnTrash.setImage(UIImage(named: "Trash"), forState: .Normal)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 200.0/255.0, green: 70.0/255.0, blue: 83.0/255.0, alpha: 1.0)
            cell.lblSpotName.textColor = UIColor.whiteColor()
            cell.lblDetail.textColor = UIColor.whiteColor()
            cell.btnEdit.setImage(UIImage(named: "Alpha Pen"), forState: .Normal)
            cell.btnTrash.setImage(UIImage(named: "Alpha Trash"), forState: .Normal)
        }
        
        cell.btnTrash.addTarget(
			self, action: #selector(self.onDeleteSpot),
			forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnEdit.addTarget(
			self, action: #selector(self.onEditSpot(_:)),
			forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)
		-> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int)
		-> CGFloat {
        return 0.1
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int)
		-> CGFloat {
        return 0.1
    }
    
    // MARK: - Click TrashButton
	
    func onDeleteSpot(sender: UIButton) {
        let alertVC = UIAlertController(title: "Delete a Spot?", message: "", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) {
			yesAction in
			self.dismissProgressHUD()
            Networking.deleteSpot(Int64(sender.tag))
        }
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - Click EditButton
    
    func onEditSpot(sender: UIButton) {
        let spot = spots[sender.tag].recurrences
        
        if spot.count == 0 {
            appDelegate.isCreatePage = true
            appDelegate.date = ""
            appDelegate.spotID = spots[sender.tag].id
            appDelegate.recurrenceID = -1
        } else {
            
            appDelegate.isCreatePage = false
            
            let recurrence = spot.first!
            appDelegate.recurrenceID = recurrence["id"].int64Value
            appDelegate.startHour = (recurrence["start_at"].stringValue as NSString).substringToIndex(2)
            appDelegate.startMins = (recurrence["start_at"].stringValue as NSString).substringFromIndex(3)
            appDelegate.stopHour = (recurrence["stop_at"].stringValue as NSString).substringToIndex(2)
            appDelegate.stopMins = (recurrence["stop_at"].stringValue as NSString).substringFromIndex(3)
            
            if recurrence["date"].stringValue != "" {
                appDelegate.date = recurrence["date"].stringValue
                appDelegate.arrChecks = [false, false, false, false, false, false, false]
            } else {
                appDelegate.date = ""
                let arrWeekDaysJSON = recurrence["week_days"].arrayValue
                for weekDay in arrWeekDaysJSON {
                    appDelegate.arrChecks[arrWeekDays.indexOf(weekDay.stringValue)!] = true
                }
            }
        }
        performSegueWithIdentifier("gotoEditRecurrence", sender: self)
    }
    
    // MARK: - DeleteSpotDelegate Methods
	
    func deleteSpotDidSucceed(data: JSON) {
        dismissProgressHUD()
        self.loadSpots()
    }
    
    func deleteSpotDidFail(error: NSError) {
        dismissProgressHUD()
        if error.code == -1003 {
			showAlert(title: "Error",
			          message: "Your internet does not seem to be working.")
        } else {
			showAlert(title: "Error",
			          message: error.localizedDescription)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoEditRecurrence" {
            let vc = segue.destinationViewController as! CreateRecurrenceWithDateViewController
            
            if appDelegate.isCreatePage {
                vc.spotID = appDelegate.spotID
            } else {
                vc.recurrenceID = appDelegate.recurrenceID
            }
        } else if segue.identifier == "gotoCreateSpot" {
            appDelegate.isCreatePage = true
        }
    }
}
