//
//  BookingAcceptedPriestVC.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/17/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

final class BookingAcceptedPriestVC: BookingViewController {
	
    @IBOutlet weak private var lblPriestName: UILabel!
    @IBOutlet weak private var lblAddressOfChurch: UILabel!
    @IBOutlet weak private var lblTimeOfRecurrence: UILabel!
    
    @IBOutlet weak private var chatButton: UIButton!
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
        self.lblPriestName.text = self.thisSpotData["church"]?["name"]
    }
    
    func onBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
