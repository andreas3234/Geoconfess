//
//  BookingRequestChurchVC.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/16/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

final class BookingRequestChurchVC: BookingViewController {
	
    @IBOutlet weak private var lblChurchName: UILabel!
    @IBOutlet weak private var lblAddressOfChurch: UILabel!
    @IBOutlet weak private var lblTimeOfRecurrence: UILabel!

    @IBOutlet weak private var appleMapButton: UIButton!
	
    override func viewDidLoad() {
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
        print(self.thisSpotData)
        self.lblChurchName.text = self.thisSpotData["name"] as? String
        self.lblAddressOfChurch.text = NSString(format: "%@, %@, %@",
                                                (self.thisSpotData["street"] as? String)!,
                                                (self.thisSpotData["postcode"] as? String)!,
                                                (self.thisSpotData["city"] as? String)!) as String
        let recurrence = self.thisSpotData["recurrences"]!.objectAtIndex(0) as! NSDictionary
        self.lblTimeOfRecurrence.text = NSString(format: "%@, %@, %@",
                                                 recurrence["start_at"] as! NSString,
                                                 recurrence["stop_at"] as! NSString,
                                                 recurrence["date"] as! NSString) as String
    }
    
    func onBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
	
	@IBAction func mapButtonTapped(sender: AnyObject) {
		let nextViewController = self.storyboard!
			.instantiateViewControllerWithIdentifier("AppleMapVC")
			as! AppleMapVC
		nextViewController.data = self.thisSpotData!
		self.navigationController?.pushViewController(nextViewController,
		                                              animated: true)
	}
}